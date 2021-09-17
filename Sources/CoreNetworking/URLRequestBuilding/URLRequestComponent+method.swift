//
//  URLRequestComponent+method.swift
//  
//
//  Created by Martin Troup on 11.09.2021.
//

import Foundation
import Overture
import OvertureOperators


extension URLRequestComponent {
    public static func method(_ method: HTTPMethod) -> Self {
        .init { urlRequest in
            urlRequest
                |> set(\URLRequest.httpMethod, method.rawValue)
                >>> Result.success
        }
    }
}
