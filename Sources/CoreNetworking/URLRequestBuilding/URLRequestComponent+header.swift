//
//  URLRequestComponent+header.swift
//  
//
//  Created by Martin Troup on 11.09.2021.
//

import Foundation
import Overture
import OvertureOperators

private extension URLRequestComponent {
    static func header(_ header: HTTPHeader) -> Self {
        .init { urlRequest in
            let headerFields = [(header.name, header.value)] |> Dictionary.init(uniqueKeysWithValues:)

            return urlRequest
                |> over(\URLRequest.allHTTPHeaderFields) { httpHeaderFields in
                    (httpHeaderFields ?? [:]).merging(headerFields) { $1 }
                }
                >>> Result.success
        }
    }
}

// MARK: - Syntax sugar

public typealias Header = URLRequestComponent

public extension Header {
    init(_ header: HTTPHeader) {
        self = URLRequestComponent.header(header)
    }

    init(_ name: String, headerValue: String) {
        self = URLRequestComponent.header(.init(name: name, value: headerValue))
    }

    init(_ name: HTTPHeaderName, headerValue: String) {
        self = URLRequestComponent.header(.init(name: name, value: headerValue))
    }
}
