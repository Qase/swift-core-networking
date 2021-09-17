//
//  URLRequestComponent+queryParameter.swift
//  
//
//  Created by Martin Troup on 11.09.2021.
//

import Foundation
import Overture
import OvertureOperators

public struct QueryParameter {
    public let name: String
    public let value: LosslessStringConvertible

    public init(name: String, value: LosslessStringConvertible) {
        self.name = name
        self.value = value
    }
}

public extension QueryParameter {
    var urlQueryItem: URLQueryItem {
        .init(name: name, value: String(describing: value))
    }
}

extension URLRequestComponent {
    public static func queryParameter(name: String, value: LosslessStringConvertible) -> Self {
        .init { urlRequest in
            Result<String, URLRequestError>.from(optional: urlRequest.url?.absoluteString, onNil: URLRequestError.endpointParsingError)
                .map(URLComponents.init(string:))
                .flatMap { $0.map(Result.success) ?? .failure(.invalidURLComponents) }
                .map(over(\.queryItems) { ($0 ?? []) + [URLQueryItem(name: name, value: String(describing: value))] })
                .map(\.url)
                .map { urlRequest |> set(\URLRequest.url, $0) }
        }
    }
}

