//
//  NetworkClientType.swift
//  CoreNetworking
//
//  Created by Martin Troup on 05.04.2021.
//

import Combine
import Foundation
import Overture
import OvertureOperators

public protocol NetworkClientType {
    func request(_ urlRequest: URLRequest) -> AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError>
    func request<T: Decodable>(
        _ urlRequest: URLRequest,
        jsonDecoder: JSONDecoder
    ) -> AnyPublisher<(headers: [HTTPHeader], object: T), NetworkError>
    func request<T: Decodable>(_ urlRequest: URLRequest, jsonDecoder: JSONDecoder) -> AnyPublisher<T, NetworkError>
}

// MARK: - Syntax sugar functions with default `JSONDecoder`

public extension NetworkClientType {
    func request<T: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<(headers: [HTTPHeader], object: T), NetworkError> {
        request(urlRequest, jsonDecoder: JSONDecoder())
    }

    func request<T: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<T, NetworkError> {
        request(urlRequest, jsonDecoder: JSONDecoder())
    }
}
