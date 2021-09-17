//
//  AuthorizedNetworkClientType.swift
//  CoreNetworking
//
//  Created by Martin Troup on 29.08.2021.
//

import Combine
import Foundation

public protocol AuthorizedNetworkClientType {
    func authorizedRequest(_ urlRequest: URLRequest) -> AnyPublisher<(headers: [HTTPHeader], body: Data), AuthorizedNetworkError>
    func authorizedRequest<T: Decodable>(
        _ urlRequest: URLRequest,
        jsonDecoder: JSONDecoder
    ) -> AnyPublisher<(headers: [HTTPHeader], object: T), AuthorizedNetworkError>
    func authorizedRequest<T: Decodable>(_ urlRequest: URLRequest, jsonDecoder: JSONDecoder) -> AnyPublisher<T, AuthorizedNetworkError>
}

// MARK: - Syntax sugar functions with default `JSONDecoder`

public extension AuthorizedNetworkClientType {
    func authorizedRequest<T: Decodable>(
        _ urlRequest: URLRequest
    ) -> AnyPublisher<(headers: [HTTPHeader], object: T), AuthorizedNetworkError> {
        authorizedRequest(urlRequest, jsonDecoder: JSONDecoder())
    }

    func authorizedRequest<T: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<T, AuthorizedNetworkError> {
        authorizedRequest(urlRequest, jsonDecoder: JSONDecoder())
    }
}
