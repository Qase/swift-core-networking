//
//  NetworkClient.swift
//  CoreNetworking
//
//  Created by Martin Troup on 01.04.2021.
//

import Combine
import CombineExt
import Foundation
import Network

public struct NetworkClient: NetworkClientType {
    private let urlSessionConfiguration: URLSessionConfiguration
    private let urlRequester: URLRequester
    private let networkMonitorClient: NetworkMonitorClient
    private let loggerClient: NetworkLoggerClient?

    public init(
        urlSessionConfiguration: URLSessionConfiguration,
        urlRequester: URLRequester,
        networkMonitorClient: NetworkMonitorClient,
        loggerClient: NetworkLoggerClient? = nil
    ) {
        self.urlSessionConfiguration = urlSessionConfiguration
        self.urlRequester = urlRequester
        self.networkMonitorClient = networkMonitorClient
        self.loggerClient = loggerClient
    }

    private var processedStatusCode: (Int) -> Result<Void, NetworkError> = { statusCode in
        switch statusCode {
        case 401:
            return .failure(.unauthorized)
        case 402..<500:
            return .failure(.clientError(statusCode))
        case 500..<600:
            return .failure(.serverError(statusCode))
        default:
            return .success(())
        }
    }

    private func performRequest(_ urlRequest: URLRequest) -> AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> {
        let isNetworkAvailable = networkMonitorClient.isNetworkAvailable
            .prefix(1)
            .setFailureType(to: NetworkError.self)
            .flatMapResult { isNetworkAvailable -> Result<Void, NetworkError> in
                isNetworkAvailable ? .success(()) : .failure(NetworkError.noConnection)
            }

        let request: AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> = Just<URLRequest>(urlRequest)
            .setFailureType(to: URLError.self)
            .handleEvents(receiveOutput: loggerClient?.logRequest)
            .flatMap(urlRequester.request(urlSessionConfiguration))
            .mapError(NetworkError.urlError)
            .flatMap { data, response -> AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    loggerClient?.logURLResponse(response, data)

                    return Fail<(headers: [HTTPHeader], body: Data), NetworkError>(error: NetworkError.invalidResponse)
                        .eraseToAnyPublisher()
                }

                loggerClient?.logHTTPURLResponse(httpResponse, data)

                return Result<Void, NetworkError>.Publisher(processedStatusCode(httpResponse.statusCode))
                    .map { (headers: httpResponse.allHeaderFields.httpHeaders, body: data) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return isNetworkAvailable
            .flatMap { _ in request }
            .eraseToAnyPublisher()
    }
}

// MARK: - NetworkClientType implementation

public extension NetworkClient {
    func request(_ urlRequest: URLRequest) -> AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> {
        performRequest(urlRequest)
    }

    func request<T: Decodable>(
        _ urlRequest: URLRequest,
        jsonDecoder: JSONDecoder
    ) -> AnyPublisher<(headers: [HTTPHeader], object: T), NetworkError> {
        request(urlRequest)
            .decode(type: T.self, decoder: jsonDecoder, mapError: NetworkError.jsonDecodingError)
    }

    func request<T: Decodable>(_ urlRequest: URLRequest, jsonDecoder: JSONDecoder) -> AnyPublisher<T, NetworkError> {
        request(urlRequest, jsonDecoder: jsonDecoder)
            .map(\.object)
            .eraseToAnyPublisher()
    }
}
