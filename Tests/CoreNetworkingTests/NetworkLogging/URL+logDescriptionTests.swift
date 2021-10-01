//
//  URL+logDescriptionTests.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 09.04.2021.
//

import CoreNetworking
import Foundation
import XCTest

class URL_logDescriptionTests: XCTestCase {

    struct User: Codable {
        let name: String
        let surname: String
    }

    func test_URLRequest_logDescription_property() {
        let user = User(name: "John", surname: "Doe")

        let sut = Request(endpoint: "https://www.google.com") {
            Method(.get)
            ComponentArray(
                Header(.acceptType, headerValue: "accept-type"),
                Header(.authorization, headerValue: "authorization")
            )
            Body(user)
        }

        func logDescriptionFromTemplate(header1: String, header2: String) -> String {
            """
            ============================================
            >>>>>>>>>>>>>>>>  REQUEST  >>>>>>>>>>>>>>>>>
            ============================================
            URL:        https://www.google.com
            METHOD:     GET
            HEADERS:    \(header1),
                        \(header2)
            BODY:       "{\\"name\\":\\"John\\",\\"surname\\":\\"Doe\\"}"
            ============================================
            """
        }

        let expectedPossibleLogDescriptions = [
            logDescriptionFromTemplate(
                header1: "\"Accept\" = \"accept-type\"",
                header2: "\"Authorization\" = \"authorization\""
            ),
            logDescriptionFromTemplate(
                header1: "\"Authorization\" = \"authorization\"",
                header2: "\"Accept\" = \"accept-type\""
            )
        ]

        switch sut.urlRequest {
        case let .success(urlRequest):
            XCTAssertTrue(expectedPossibleLogDescriptions.contains(urlRequest.logDescription))
        case let .failure(error):
            XCTFail("Unexpected failure: \(error).")
        }
    }

    func test_URLResponse_logDescription_property() {
        let urlResponse = URLResponse(
            url: URL(string: "https://www.google.com")!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )

        let user = User(name: "John", surname: "Doe")
        let userData = try! JSONEncoder().encode(user)

        let expectedLogDescription =
            """
            ============================================
            <<<<<<<<<<<<<<<  RESPONSE  <<<<<<<<<<<<<<<<<
            ============================================
            URL:        https://www.google.com
            BODY:        "{\\"name\\":\\"John\\",\\"surname\\":\\"Doe\\"}"
            ============================================
            """

        XCTAssertEqual(urlResponse.logDescription(withBody: userData), expectedLogDescription)
    }

    func test_HTTPURLResponse_logDescription_property_with_body() {
        let httpURLResponse = HTTPURLResponse(
            url: URL(string: "https://www.google.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "Accept": "accept-type",
                "Authorization": "authorization"
            ]
        )!

        let user = User(name: "John", surname: "Doe")
        let userData = try! JSONEncoder().encode(user)

        func logDescriptionFromTemplate(header1: String, header2: String) -> String {
            """
            ============================================
            <<<<<<<<<<<<<<<  RESPONSE  <<<<<<<<<<<<<<<<<
            ============================================
            URL:         https://www.google.com
            STATUS CODE: 200
            HEADERS:     \(header1),
                         \(header2)
            BODY:        "{\\"name\\":\\"John\\",\\"surname\\":\\"Doe\\"}"
            ============================================
            """
        }

        let expectedPossibleLogDescriptions = [
            logDescriptionFromTemplate(
                header1: "\"Accept\" = \"accept-type\"",
                header2: "\"Authorization\" = \"authorization\""
            ),
            logDescriptionFromTemplate(
                header1: "\"Authorization\" = \"authorization\"",
                header2: "\"Accept\" = \"accept-type\""
            )
        ]

        XCTAssertTrue(expectedPossibleLogDescriptions.contains(httpURLResponse.logDescription(withBody: userData)))
    }
}
