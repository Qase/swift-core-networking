//
//  Request.swift
//  
//
//  Created by Martin Troup on 12.09.2021.
//

import Foundation
import Combine
import Overture

public typealias Url = String

public struct Request {
    private let initialURLRequestResult: Result<URLRequest, URLRequestError>
    private let builder: () -> URLRequestComponent

    public var urlRequest: Result<URLRequest, URLRequestError> {
        initialURLRequestResult
            .flatMap(builder().build)
    }

    public init(
        endpoint: Url,
        @URLRequestBuilder builder: @escaping () -> URLRequestComponent = { URLRequestComponent.identity }
    ) {
        self.initialURLRequestResult = Result<URLRequest, URLRequestError>.from(
            optional: URL(string: endpoint),
            onNil: URLRequestError.endpointParsingError
        )
            .map { URLRequest(url: $0) }
        self.builder = builder
    }

    public init(
        initialRequest: Request,
        @URLRequestBuilder builder: @escaping () -> URLRequestComponent = { URLRequestComponent.identity }
    ) {
        self.initialURLRequestResult = initialRequest.urlRequest
        self.builder = builder
    }
}

// MARK: - Request + networkPublisher

extension Request {
    var networkPublisher: AnyPublisher<URLRequest, NetworkError> {
        Result.Publisher(self.urlRequest)
            .mapErrorReportable(to: NetworkError.urlRequestError)
            .eraseToAnyPublisher()
    }
}

// MARK: - Request + authorizedNetworkPublisher

extension Request {
    var authorizedNetworkPublisher: AnyPublisher<URLRequest, AuthorizedNetworkError> {
        networkPublisher
            .mapErrorReportable(to: AuthorizedNetworkError.networkError)
            .eraseToAnyPublisher()
    }
}

// MARK: - Request + NetworkClient

extension Request {
    public func execute(using networkClient: NetworkClientType)
    -> AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> {
        networkPublisher
            .flatMap(networkClient.request)
            .eraseToAnyPublisher()
    }

    public func execute<T: Decodable>(using networkClient: NetworkClientType, jsonDecoder: JSONDecoder = JSONDecoder())
    -> AnyPublisher<(headers: [HTTPHeader], object: T), NetworkError> {
        networkPublisher
            .flatMap(flip(curry(networkClient.request))(jsonDecoder))
            .eraseToAnyPublisher()
    }

    public func execute<T: Decodable>(using networkClient: NetworkClientType, jsonDecoder: JSONDecoder = JSONDecoder())
    -> AnyPublisher<T, NetworkError> {
        networkPublisher
            .flatMap(flip(curry(networkClient.request))(jsonDecoder))
            .eraseToAnyPublisher()
    }
}

// MARK: Request: AuthorizedNetworkClient

extension Request {
    func executeAuthorized(using authorizedNetworkClient: AuthorizedNetworkClientType)
    -> AnyPublisher<(headers: [HTTPHeader], body: Data), AuthorizedNetworkError> {
        authorizedNetworkPublisher
            .flatMap(authorizedNetworkClient.authorizedRequest)
            .eraseToAnyPublisher()
    }

    public func executeAuthorized<T: Decodable>(
        using authorizedNetworkClient: AuthorizedNetworkClientType,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<(headers: [HTTPHeader], object: T), AuthorizedNetworkError> {
        authorizedNetworkPublisher
            .flatMap(flip(curry(authorizedNetworkClient.authorizedRequest))(jsonDecoder))
            .eraseToAnyPublisher()
    }

    public func executeAuthorized<T: Decodable>(
        using authorizedNetworkClient: AuthorizedNetworkClientType,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T, AuthorizedNetworkError> {
        authorizedNetworkPublisher
            .flatMap(flip(curry(authorizedNetworkClient.authorizedRequest))(jsonDecoder))
            .eraseToAnyPublisher()
    }
}
