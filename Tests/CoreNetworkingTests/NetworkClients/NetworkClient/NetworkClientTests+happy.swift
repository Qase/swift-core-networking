//
//  NetworkClientTests+happy.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 05.06.2021.
//

import Foundation
import Combine
@testable import CoreNetworking
import XCTest

private extension Array where Element == HTTPHeader {
    static var mock = [
        HTTPHeader.accept(.json),
        HTTPHeader.contentType(.json)
    ]
}

private extension HTTPURLResponse {
    static var mock = HTTPURLResponse(
        url: .mock,
        statusCode: 200,
        httpVersion: nil,
        headerFields: [
            "\(HTTPHeaderName.acceptType.rawValue)": "\(AcceptTypeValue.json.rawValue)",
            "\(HTTPHeaderName.contentType.rawValue)": "\(ContentTypeValue.json.rawValue)"
        ]
    )!
}

private extension Data {
    static var userMock = try! JSONEncoder().encode(User.mock)
}

extension NetworkClientTests {
    func test_Data_with_headers_success_response() {
        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: .successMock(withResponse: (.userMock, HTTPURLResponse.mock), delayedFor: 1, scheduler: testScheduler),
            networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1),
            loggerClient: consoleLogger
        )

        var valueReceived = false
        var finished = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> = Request.validMock
            .execute(using: networkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        finished = true
                    case let .failure(error):
                        XCTFail("Unexpected event - failure: \(error)")
                    }
                },
                receiveValue: { receivedHeaders, body in
                    XCTAssertTrue(Set([HTTPHeader].mock).symmetricDifference(Set(receivedHeaders)).isEmpty)
                    XCTAssertEqual(.userMock, body)
                    valueReceived = true
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 2)

        XCTAssertTrue(valueReceived)
        XCTAssertTrue(finished)
    }

    func test_User_with_headers_success_response() {
        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: .successMock(withResponse: (.userMock, HTTPURLResponse.mock), delayedFor: 1, scheduler: testScheduler),
            networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1),
            loggerClient: consoleLogger
        )

        var valueReceived = false
        var finished = false

        let response: AnyPublisher<(headers: [HTTPHeader], object: User), NetworkError> = Request.validMock
            .execute(using: networkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        finished = true
                    case let .failure(error):
                        XCTFail("Unexpected event - failure: \(error)")
                    }
                },
                receiveValue: { receivedHeaders, object in
                    XCTAssertTrue(Set([HTTPHeader].mock).symmetricDifference(Set(receivedHeaders)).isEmpty)
                    XCTAssertEqual(User.mock, object)
                    valueReceived = true
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 2)

        XCTAssertTrue(valueReceived)
        XCTAssertTrue(finished)
    }

    func test_User_without_headers_success_response() {
        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: .successMock(withResponse: (.userMock, HTTPURLResponse.mock), delayedFor: 1, scheduler: testScheduler),
            networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1),
            loggerClient: consoleLogger
        )

        var valueReceived = false
        var finished = false

        let response: AnyPublisher<User, NetworkError> = Request(endpoint: .mock)
            .execute(using: networkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        finished = true
                    case let .failure(error):
                        XCTFail("Unexpected event - failure: \(error)")
                    }
                },
                receiveValue: { object in
                    XCTAssertEqual(User.mock, object)
                    valueReceived = true
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 2)

        XCTAssertTrue(valueReceived)
        XCTAssertTrue(finished)
    }
}
