//
//  URLResponse+logDescription.swift
//  CoreNetworking
//
//  Created by Martin Troup on 05.04.2021.
//

import Foundation

public extension URLResponse {
    @objc
    func logDescription(withBody body: Data? = nil) -> String {
        let debugUrl = url?.absoluteString ?? "unknown"

        let debugBody = body
            .flatMap { String(data: $0, encoding: .utf8)?.debugDescription }
            ?? "n/a"

        return """
        ============================================
        <<<<<<<<<<<<<<<  RESPONSE  <<<<<<<<<<<<<<<<<
        ============================================
        URL:        \(debugUrl)
        BODY:        \(debugBody)
        ============================================
        """
    }
}
