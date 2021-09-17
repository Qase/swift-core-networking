//
//  NetworkLoggerClient.swift
//  CoreNetworking
//
//  Created by Martin Troup on 05.04.2021.
//

import Foundation

public struct NetworkLoggerClient {
    public let logRequest: (URLRequest) -> Void
    public let logURLResponse: (URLResponse, Data?) -> Void
    public let logHTTPURLResponse: (HTTPURLResponse, Data?) -> Void
}

// MARK: - NetworkLoggerClient instances

extension NetworkLoggerClient {
    static let consoleLogger: NetworkLoggerClient = .init(
        logRequest: { print("\($0.logDescription)") },
        logURLResponse: { print("\($0.logDescription(withBody: $1))") },
        logHTTPURLResponse: { print("\($0.logDescription(withBody: $1))") }
    )
}
