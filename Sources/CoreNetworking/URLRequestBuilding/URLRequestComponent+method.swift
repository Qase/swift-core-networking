//
//  URLRequestComponent+method.swift
//  
//
//  Created by Martin Troup on 11.09.2021.
//

import Foundation
import Overture
import OvertureOperators


private extension URLRequestComponent {
    static func method(_ method: HTTPMethod) -> Self {
        .init { urlRequest in
            urlRequest
                |> set(\URLRequest.httpMethod, method.rawValue)
                >>> Result.success
        }
    }
}

// MARK: - Syntax sugar

public typealias Method = URLRequestComponent

public extension Method {
    init(_ method: HTTPMethod) {
        self = URLRequestComponent.method(method)
    }
}
