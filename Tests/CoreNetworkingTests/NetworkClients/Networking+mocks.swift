//
//  Networking+mocks.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 29.08.2021.
//

import Foundation
import CoreNetworking

extension URL {
    static let mock = URL(string: "https://reqres.in/api/users/1")!
}

extension Url {
    static let mock = "https://reqres.in/api/users/1"
}

extension Request {
    static var validMock: Self = Request(endpoint: .mock)
    static func invalidMock(withError error: URLRequestError) -> Self {
        Request(endpoint: .mock) {
            URLRequestComponent { _ in .failure(error) }
        }
    }
}

struct User: Codable, Equatable {
    let id: Int
    let firstName: String
    let lastName: String

    // mock:
    static let mock = User(id: 175_442, firstName: "John", lastName: "Doe")
}
