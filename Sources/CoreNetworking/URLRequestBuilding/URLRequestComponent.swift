//
//  URLRequestComponent.swift
//  
//
//  Created by Martin Troup on 11.09.2021.
//

import Foundation

public struct URLRequestComponent {
    public let build: (URLRequest) -> Result<URLRequest, URLRequestError>

    public init(_ build: @escaping (URLRequest) -> Result<URLRequest, URLRequestError>) {
        self.build = build
    }
}

// MARK: - URLRequestComponent + identity

extension URLRequestComponent {
    public static var identity: Self {
        .init { .success($0) }
    }
}

// MARK: - URLRequestComponent + array

extension URLRequestComponent {
    public static func array(_ components: URLRequestComponent...) -> Self {
        array(components)
    }

    public static func array(_ components: [URLRequestComponent]) -> Self {
        let combine: (URLRequestComponent, URLRequestComponent) -> URLRequestComponent = { component1, component2 in
            URLRequestComponent { component1.build($0).flatMap(component2.build) }
        }

        return .init { urlRequest in
            let combined = components.reduce(URLRequestComponent.identity, combine)

            return combined.build(urlRequest)
        }
    }
}
