//
//  NetworkErrorTests.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 09.04.2021.
//

import Core
import CoreNetworking
import XCTest

class NetworkErrorTests: XCTestCase {
    func test_init() {
        let uuid = UUID(uuidString: "ffeac012-9911-11eb-a8b3-0242ac130003")!

        let networkError = NetworkError(cause: .invalidResponse, stackID: uuid)

        XCTAssertTrue({
            switch networkError.cause {
            case .invalidResponse: return true
            default: return false
            }
        }())
        XCTAssertNil(networkError.underlyingError)
        XCTAssertEqual(networkError.stackID, uuid)
        XCTAssertEqual(networkError.catalogueID, ErrorCatalogueID.unassigned)
    }

    func test_static_instance() {
        let networkError = NetworkError.noConnection

        XCTAssertTrue({
            switch networkError.cause {
            case .noConnection: return true
            default: return false
            }
        }())
        XCTAssertNil(networkError.underlyingError)
        XCTAssertEqual(networkError.catalogueID, ErrorCatalogueID.unassigned)
    }
}
