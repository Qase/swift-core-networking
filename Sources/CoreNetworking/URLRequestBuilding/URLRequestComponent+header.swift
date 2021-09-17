//
//  URLRequestComponent+header.swift
//  
//
//  Created by Martin Troup on 11.09.2021.
//

import Foundation
import Overture
import OvertureOperators

extension URLRequestComponent {
    public static func header(_ header: HTTPHeader) -> Self {
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
