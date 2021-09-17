//
//  URLRequestBuilder.swift
//  
//
//  Created by Martin Troup on 11.09.2021.
//

import Foundation
import Overture
import OvertureOperators

@resultBuilder
public struct URLRequestBuilder {
    public static func buildBlock(_ params: URLRequestComponent...) -> URLRequestComponent {
        URLRequestComponent.array(params)
    }

    public static func buildBlock(_ param: URLRequestComponent) -> URLRequestComponent {
        param
    }
}
