//
//  URLRequest+.swift
//  CoreNetworking
//
//  Created by Martin Troup on 03.03.2021.
//

import Foundation
import Overture
import OvertureOperators

public extension URLRequest {
    
    static func with(method: HTTPMethod) -> (URLRequest) -> URLRequest {
        { $0 |> set(\URLRequest.httpMethod, method.rawValue) }
    }

    static func with(headers: [HTTPHeader]) -> (URLRequest) -> URLRequest {
        { urlRequest in
            let headerFields = zip(headers.map(\.name), headers.map(\.value)) |> Dictionary.init(uniqueKeysWithValues:)

            return urlRequest |>
                over(\.allHTTPHeaderFields) { httpHeaderFields in
                    (httpHeaderFields ?? [:]).merging(headerFields) { $1 }
                }
        }
    }

    static func with<T: Encodable>(
        body: T,
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) -> (URLRequest) -> Result<URLRequest, URLRequestError> {
        { urlRequest in
            Result<Data, URLRequestError>.execute( { try jsonEncoder.encode(body) }, onThrows: URLRequestError.bodyEncodingError)
                .map { urlRequest |> set(\URLRequest.httpBody, $0) }
        }
    }
}

// MARK: - Syntax sugar functions to enhance ergonomics

private extension Result {
    static func lift(_ transform: @escaping (Success) -> Success) -> (Result<Success, Failure>) -> Result<Success, Failure> {
        { $0.map(transform) }
    }

    static func lift(
        _ transform: @escaping (Success) -> Result<Success, Failure>
    ) -> (Result<Success, Failure>) -> Result<Success, Failure> {
        { $0.flatMap(transform) }
    }
}

public extension URLRequest {
    static func with(method: HTTPMethod) -> (Result<URLRequest, URLRequestError>) -> Result<URLRequest, URLRequestError> {
        Result<URLRequest, URLRequestError>.lift(URLRequest.with(method: method))
    }

    static func with(headers: [HTTPHeader]) -> (Result<URLRequest, URLRequestError>) -> Result<URLRequest, URLRequestError> {
        Result<URLRequest, URLRequestError>.lift(URLRequest.with(headers: headers))
    }

    static func with<T: Encodable>(
        body: T,
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) -> (Result<URLRequest, URLRequestError>) -> Result<URLRequest, URLRequestError> {
        Result<URLRequest, URLRequestError>.lift(with(body: body, jsonEncoder: jsonEncoder))
    }
}
