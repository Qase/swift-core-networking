//
//  URLRequestComponent+body.swift
//  
//
//  Created by Martin Troup on 11.09.2021.
//

import Foundation
import Overture
import OvertureOperators

extension URLRequestComponent {
    public static func body<T: Encodable>(_ value: T, jsonEncoder: JSONEncoder = JSONEncoder()) -> Self {
        .init { urlRequest in
            Result<URLRequest, URLRequestError>.execute(
                { try jsonEncoder.encode(value)},
                onThrows: URLRequestError.bodyEncodingError
            )
                .map { urlRequest |> set(\URLRequest.httpBody, $0) }
        }
    }
}
