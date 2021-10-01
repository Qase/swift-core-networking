//
//  URLRequestComponent+queryParameter.swift
//  
//
//  Created by Martin Troup on 11.09.2021.
//

import Foundation
import Overture
import OvertureOperators

private extension URLRequestComponent {
    static func queryParameter(name: String, value: LosslessStringConvertible) -> Self {
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

// MARK: - Syntax sugar

public typealias QueryParameter = URLRequestComponent

public extension QueryParameter {
    init(_ name: String, parameterValue: LosslessStringConvertible) {
        self = URLRequestComponent.queryParameter(name: name, value: parameterValue)
    }
}

