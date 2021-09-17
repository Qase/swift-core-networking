//
//  HTTPURLResponse+logDescription.swift
//  CoreNetworking
//
//  Created by Martin Troup on 05.04.2021.
//

import Foundation

public extension HTTPURLResponse {
    override func logDescription(withBody body: Data? = nil) -> String {
        let debugUrl = url?.absoluteString ?? "unknown"
        let debugHeaders = allHeaderFields
            .map { "\"\($0.0)\" = \"\($0.1)\"" }
            .joined(separator: ",\n\(String(repeating: " ", count: 13))")

        let debugBody = body
            .flatMap { String(data: $0, encoding: .utf8)?.debugDescription }
            ?? "n/a"

        return """
        ============================================
        <<<<<<<<<<<<<<<  RESPONSE  <<<<<<<<<<<<<<<<<
        ============================================
        URL:         \(debugUrl)
        STATUS CODE: \(statusCode)
        HEADERS:     \(debugHeaders)
        BODY:        \(debugBody)
        ============================================
        """
    }
}
