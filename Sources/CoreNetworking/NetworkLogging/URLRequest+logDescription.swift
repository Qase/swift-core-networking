//
//  URLRequest+logDescription.swift
//  CoreNetworking
//
//  Created by Martin Troup on 05.04.2021.
//

import Foundation

public extension URLRequest {
    var logDescription: String {
        let debugUrl = url?.absoluteString ?? "unknown"
        let debugMethod = httpMethod ?? "unknown"
        let debugHeaders = allHTTPHeaderFields?
            .map { "\"\($0.0)\" = \"\($0.1)\"" }
            .joined(separator: ",\n\(String(repeating: " ", count: 12))")
            ?? "-none-"

        let debugBody = httpBody
            .flatMap { String(data: $0, encoding: .utf8)?.debugDescription }
            ?? "n/a"

        return """
        ============================================
        >>>>>>>>>>>>>>>>  REQUEST  >>>>>>>>>>>>>>>>>
        ============================================
        URL:        \(debugUrl)
        METHOD:     \(debugMethod)
        HEADERS:    \(debugHeaders)
        BODY:       \(debugBody)
        ============================================
        """
    }
}
