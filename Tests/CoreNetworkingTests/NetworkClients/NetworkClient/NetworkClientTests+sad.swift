//
//  NetworkClientTests+sad.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 05.06.2021.
//

import Combine
@testable import CoreNetworking
import Foundation
import XCTest

extension NetworkClientTests {
    func test_clientError_failure() {
        let httpResponse: HTTPURLResponse = HTTPURLResponse(
            url: .mock,
            statusCode: 402,
            httpVersion: nil,
            headerFields: [String: String]()
        )!

        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: .successMock(withResponse: (Data(), httpResponse), delayedFor: 1, scheduler: testScheduler),
            networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1),
            loggerClient: consoleLogger
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> = Request.validMock
            .execute(using: networkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case let .clientError(statusCode: statusCode) where statusCode == 402:
                            errorReceived = true
                        default:
                            XCTFail("Unexpected event - failure: \(error.cause).")
                        }
                    }
                },
                receiveValue: { body in
                    XCTFail("Unexpect event - element: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 2)

        XCTAssertTrue(errorReceived)
    }

    func test_serverError_failure() {
        let httpResponse: HTTPURLResponse = HTTPURLResponse(
            url: .mock,
            statusCode: 500,
            httpVersion: nil,
            headerFields: [String: String]()
        )!

        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: .successMock(withResponse: (Data(), httpResponse), delayedFor: 1, scheduler: testScheduler),
            networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1),
            loggerClient: consoleLogger
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> = Request.validMock
            .execute(using: networkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case let .serverError(statusCode: statusCode) where statusCode == 500:
                            errorReceived = true
                        default:
                            XCTFail("Unexpected event - failure: \(error.cause).")
                        }
                    }
                },
                receiveValue: { body in
                    XCTFail("Unexpect event - element: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 2)

        XCTAssertTrue(errorReceived)
    }

    func test_unauthorized_failure() {
        let httpResponse: HTTPURLResponse = HTTPURLResponse(
            url: .mock,
            statusCode: 401,
            httpVersion: nil,
            headerFields: [String: String]()
        )!

        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: .successMock(withResponse: (Data(), httpResponse), delayedFor: 1, scheduler: testScheduler),
            networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1),
            loggerClient: consoleLogger
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> = Request.validMock
            .execute(using: networkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case .unauthorized:
                            errorReceived = true
                        default:
                            XCTFail("Unexpected event - failure: \(error.cause).")
                        }
                    }
                },
                receiveValue: { body in
                    XCTFail("Unexpect event - element: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 2)

        XCTAssertTrue(errorReceived)
    }

    func test_URLError_failure_response() {
        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: .failureMock(withError: URLError(.badServerResponse), delayedFor: 1, scheduler: testScheduler),
            networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1),
            loggerClient: consoleLogger
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> = Request.validMock
            .execute(using: networkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case .urlError(URLError(.badServerResponse)):
                            errorReceived = true
                        default:
                            XCTFail("Unexpected event - failure: \(error.cause).")
                        }
                    }
                },
                receiveValue: { body in
                    XCTFail("Unexpect event - element: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 2)

        XCTAssertTrue(errorReceived)
    }

    func test_invalidResponse_failure_response() {
        let urlResponse = URLResponse(url: .mock, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: .successMock(withResponse: (Data(), urlResponse), delayedFor: 1, scheduler: testScheduler),
            networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1),
            loggerClient: consoleLogger
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> = Request.validMock
            .execute(using: networkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case .invalidResponse:
                            errorReceived = true
                        default:
                            XCTFail("Unexpected event - failure: \(error.cause).")
                        }
                    }
                },
                receiveValue: { body in
                    XCTFail("Unexpect event - element: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 2)
        XCTAssertTrue(errorReceived)
    }

    func test_noConnection_failure_response() {
        let urlResponse = URLResponse(url: .mock, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: .successMock(withResponse: (Data(), urlResponse), delayedFor: 1, scheduler: testScheduler),
            networkMonitorClient: .mock(withValues: [.unavailable], onScheduler: testScheduler, every: 1),
            loggerClient: consoleLogger
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> = Request.validMock
            .execute(using: networkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case .noConnection:
                            errorReceived = true
                        default:
                            XCTFail("Unexpected event - failure: \(error.cause).")
                        }
                    }
                },
                receiveValue: { body in
                    XCTFail("Unexpect event - element: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 1)

        XCTAssertTrue(errorReceived)
    }

    func test_jsonDecodingError_failure_response() {
        let httpResponse: HTTPURLResponse = HTTPURLResponse(
            url: .mock,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [:]
        )!

        let data = "invalid-data".data(using: .utf8)!

        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: .successMock(withResponse: (data, httpResponse), delayedFor: 1, scheduler: testScheduler),
            networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1),
            loggerClient: consoleLogger
        )

        var errorReceived = false

        let response: AnyPublisher<User, NetworkError> = Request.validMock
            .execute(using: networkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case .jsonDecodingError:
                            errorReceived = true
                        default:
                            XCTFail("Unexpected event - failure: \(error.cause).")
                        }
                    }
                },
                receiveValue: { body in
                    XCTFail("Unexpect event - element: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 2)

        XCTAssertTrue(errorReceived)
    }

    func test_URLRequest_build_failure() {
        networkClient = NetworkClient(
            urlSessionConfiguration: .default,
            urlRequester: URLRequester(request: { _ in fatalError("Should not be used!") }),
            networkMonitorClient: .unused,
            loggerClient: consoleLogger
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), NetworkError> = Request
            .invalidMock(withError: .endpointParsingError)
            .execute(using: networkClient)
        
        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error) where error.underlyingError is URLRequestError:
                        errorReceived = true
                    case let .failure(error):
                        XCTFail("Unexpected event - error \(error).")
                    }
                },
                receiveValue: { body in
                    XCTFail("Unexpect event - element: \(body).")
                }
            )
            .store(in: &subscriptions)

        XCTAssertTrue(errorReceived)
    }
}
