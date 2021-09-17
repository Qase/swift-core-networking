//
//  AuthorizedNetworkClient.swift
//  CoreNetworking
//
//  Created by Martin Troup on 28.08.2021.
//

import Combine
import Foundation
import Overture
import OvertureOperators

public struct AuthorizedNetworkClient<Token: TokenType> {
    private let networkClient: NetworkClientType
    private let tokenClient: TokenClient<Token>
    private let authorizedRequestBuilder: (URLRequest, Token) -> URLRequest

    public init(
        networkClient: NetworkClientType,
        tokenClient: TokenClient<Token>,
        authorizedRequestBuilder: @escaping (URLRequest, Token) -> URLRequest
    ) {
        self.networkClient = networkClient
        self.tokenClient = tokenClient
        self.authorizedRequestBuilder = authorizedRequestBuilder
    }
}

// MARK: - AuthorizedNetworkClient + NetworkClientType

extension AuthorizedNetworkClient: NetworkClientType {
    public func request(_ urlRequest: URLRequest) -> AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> {
        networkClient.request(urlRequest)
    }

    public func request<T: Decodable>(_ urlRequest: URLRequest, jsonDecoder: JSONDecoder) -> AnyPublisher<T, NetworkError> {
        networkClient.request(urlRequest, jsonDecoder: jsonDecoder)
    }

    public func request<T: Decodable>(
        _ urlRequest: URLRequest,
        jsonDecoder: JSONDecoder
    ) -> AnyPublisher<(headers: [HTTPHeader], object: T), NetworkError> {
        networkClient.request(urlRequest, jsonDecoder: jsonDecoder)
    }
}

// MARK: - AuthorizedNetworkClient + AuthorizedNetworkClientType

extension AuthorizedNetworkClient: AuthorizedNetworkClientType {
    private func authorizedRequest<Response>(
        _ urlRequest: URLRequest,
        perform: @escaping (URLRequest) -> AnyPublisher<Response, NetworkError>,
        refreshToken: @escaping () -> AnyPublisher<Void, TokenError>
    ) -> AnyPublisher<Response, AuthorizedNetworkError> {
        tokenClient.currentToken
            .mapErrorReportable(to: AuthorizedNetworkError.localTokenError)
            .map(urlRequest |> curry(authorizedRequestBuilder))
            .flatMap { urlRequest in
                perform(urlRequest)
                    .mapErrorReportable(to: AuthorizedNetworkError.networkError)
            }
            .whenUnauthorized(refresh: refreshToken)
            .eraseToAnyPublisher()
    }


    public func authorizedRequest<T: Decodable>(
        _ urlRequest: URLRequest,
        jsonDecoder: JSONDecoder
    ) -> AnyPublisher<T, AuthorizedNetworkError> {
        authorizedRequest(
            urlRequest,
            perform: jsonDecoder |> flip(curry(networkClient.request(_:jsonDecoder:))),
            refreshToken: tokenClient.refreshToken
        )
    }


    public func authorizedRequest<T: Decodable>(
        _ urlRequest: URLRequest,
        jsonDecoder: JSONDecoder
    ) -> AnyPublisher<(headers: [HTTPHeader], object: T), AuthorizedNetworkError> {
        return authorizedRequest(
            urlRequest,
            perform: jsonDecoder |> flip(curry(networkClient.request(_:jsonDecoder:))),
            refreshToken: tokenClient.refreshToken
        )
    }

    public func authorizedRequest(
        _ urlRequest: URLRequest
    ) -> AnyPublisher<(headers: [HTTPHeader], body: Data), AuthorizedNetworkError> {
        authorizedRequest(
            urlRequest,
            perform: request,
            refreshToken: tokenClient.refreshToken
        )
    }
}

private extension Publisher where Failure == AuthorizedNetworkError {
    func whenUnauthorized(
        refresh: @escaping () -> AnyPublisher<Void, TokenError>
    ) -> AnyPublisher<Self.Output, Self.Failure> {
        retryWhen { errorPublisher in
            errorPublisher
                .scan([AuthorizedNetworkError]()) { $0 + [$1] }
                .flatMap { authorizedNetworkErrors -> AnyPublisher<Void, Self.Failure> in
                    guard
                        authorizedNetworkErrors.count == 1,
                        let authorizedNetworkError = authorizedNetworkErrors.first,
                        (authorizedNetworkError.isUnauthorized || authorizedNetworkError.isTokenLocallyInvalid)
                    else {
                        // NOTE: It is impossible for the errorPublisher not to emit any values, thus the force-unwrapping.
                        return Fail<Void, Self.Failure>(error: authorizedNetworkErrors.last!).eraseToAnyPublisher()
                    }

                    return refresh()
                        .mapErrorReportable(to: AuthorizedNetworkError.refreshTokenError)
                        .eraseToAnyPublisher()
                }
        }
    }
}

// MARK: - AuthorizedNetworkError + computed

private extension AuthorizedNetworkError {
    var isUnauthorized: Bool {
        if let networkError = underlyingError as? NetworkError, case .unauthorized = networkError.cause {
            return true
        }

        return false
    }

    var isTokenLocallyInvalid: Bool {
        if let tokenError = underlyingError as? TokenError, case .tokenLocallyInvalid = tokenError.cause {
            return true
        }

        return false
    }
}

