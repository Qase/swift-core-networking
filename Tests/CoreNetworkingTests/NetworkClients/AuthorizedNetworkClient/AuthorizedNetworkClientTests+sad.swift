//
//  AuthorizedNetworkClientTests+sad.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 31.08.2021.
//

import Foundation
import Combine
@testable import CoreNetworking
import XCTest

extension AuthorizedNetworkClientTests {
    func test_unauthorized_again_after_successfull_refresh() {
        let unauthorizedHTTPResponse: HTTPURLResponse = HTTPURLResponse(
            url: .mock,
            statusCode: 401,
            httpVersion: nil,
            headerFields: [String: String]()
        )!

        var networkRequestCount = 0
        var currentTokenCount = 0
        var refreshTokenCount = 0
        var authorizedRequestBuilderCount = 0

        authorizedNetworkClient = AuthorizedNetworkClient<TestToken>(
            networkClient: NetworkClient(
                urlSessionConfiguration: .default,
                urlRequester: .init { _ in
                    { _ in
                        Just((Data(), unauthorizedHTTPResponse))
                            .setFailureType(to: URLError.self)
                            .handleEvents(receiveSubscription: { _ in networkRequestCount += 1 })
                            .delay(for: 1, scheduler: self.testScheduler)
                            .eraseToAnyPublisher()
                    }
                },
                networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1)
            ),
            tokenClient: TokenClient<TestToken>(
                currentToken: Just(.mock)
                    .setFailureType(to: TokenError.self)
                    .handleEvents(receiveSubscription: { _ in
                        currentTokenCount += 1
                    })
                    .delay(for: 1, scheduler: self.testScheduler)
                    .eraseToAnyPublisher(),
                refreshToken: {
                    Just(())
                        .setFailureType(to: TokenError.self)
                        .handleEvents(receiveSubscription: { _ in refreshTokenCount += 1 })
                        .delay(for: 1, scheduler: self.testScheduler)
                        .eraseToAnyPublisher()
                }
            ),
            authorizedRequestBuilder: { request, token in
                XCTAssertEqual(token, .mock)
                authorizedRequestBuilderCount += 1

                return request
            }
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), AuthorizedNetworkError> = Request.validMock
            .executeAuthorized(using: authorizedNetworkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case .networkError where error.underlyingError is NetworkError:
                            switch (error.underlyingError as! NetworkError).cause {
                            case .unauthorized:
                                errorReceived = true
                            default:
                                XCTFail("Unexpected event - failure: \(error).")
                            }
                        default:
                            XCTFail("Unexpected event - failure: \(error).")
                        }
                    }
                },
                receiveValue: { _, body in
                    XCTFail("Unexpected event - failure: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 6)

        XCTAssertEqual(networkRequestCount, 2)
        XCTAssertEqual(currentTokenCount, 2)
        XCTAssertEqual(refreshTokenCount, 1)
        XCTAssertEqual(authorizedRequestBuilderCount, 2)

        XCTAssertTrue(errorReceived)
    }

    func test_network_response_error_passed_through_without_refreshing() {
        let serverErrorHTTPResponse: HTTPURLResponse = HTTPURLResponse(
            url: .mock,
            statusCode: 500,
            httpVersion: nil,
            headerFields: [String: String]()
        )!

        var currentTokenCalled = false
        var authorizedRequestBuilderCalled = false

        authorizedNetworkClient = AuthorizedNetworkClient<TestToken>(
            networkClient: NetworkClient(
                urlSessionConfiguration: .default,
                urlRequester: .successMock(withResponse: (Data(), serverErrorHTTPResponse), delayedFor: 1, scheduler: testScheduler),
                networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1)
            ),
            tokenClient: TokenClient<TestToken>(
                currentToken: Just(.mock)
                    .setFailureType(to: TokenError.self)
                    .handleEvents(receiveSubscription: { _ in currentTokenCalled = true })
                    .delay(for: 1, scheduler: self.testScheduler)
                    .eraseToAnyPublisher(),
                refreshToken: {
                    fatalError("Should not be called!")
                }
            ),
            authorizedRequestBuilder: { request, token in
                XCTAssertEqual(token, .mock)
                authorizedRequestBuilderCalled = true

                return request
            }
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), AuthorizedNetworkError> = Request.validMock
            .executeAuthorized(using: authorizedNetworkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case .networkError where error.underlyingError is NetworkError:
                            switch (error.underlyingError as! NetworkError).cause {
                            case let .serverError(statusCode: statusCode) where statusCode == 500:
                                errorReceived = true
                            default:
                                XCTFail("Unexpected event - failure: \(error).")
                            }
                        default:
                            XCTFail("Unexpected event - failure: \(error).")
                        }
                    }
                },
                receiveValue: { _, body in
                    XCTFail("Unexpected event - failure: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 3)

        XCTAssertTrue(currentTokenCalled)
        XCTAssertTrue(authorizedRequestBuilderCalled)

        XCTAssertTrue(errorReceived)
    }

    func test_network_monitor_error_passed_through_without_refreshing() {
        var currentTokenCalled = false
        var authorizedRequestBuilderCalled = false

        authorizedNetworkClient = AuthorizedNetworkClient<TestToken>(
            networkClient: NetworkClient(
                urlSessionConfiguration: .default,
                urlRequester: .unused,
                networkMonitorClient: .mock(withValues: [.unavailable], onScheduler: testScheduler, every: 1)
            ),
            tokenClient: TokenClient<TestToken>(
                currentToken: Just(.mock)
                    .setFailureType(to: TokenError.self)
                    .handleEvents(receiveSubscription: { _ in currentTokenCalled = true })
                    .delay(for: 1, scheduler: self.testScheduler)
                    .eraseToAnyPublisher(),
                refreshToken: {
                    fatalError("Should not be called!")
                }
            ),
            authorizedRequestBuilder: { request, token in
                XCTAssertEqual(token, .mock)
                authorizedRequestBuilderCalled = true

                return request
            }
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), AuthorizedNetworkError> = Request.validMock
            .executeAuthorized(using: authorizedNetworkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case .networkError where error.underlyingError is NetworkError:
                            switch (error.underlyingError as! NetworkError).cause {
                            case .noConnection:
                                errorReceived = true
                            default:
                                XCTFail("Unexpected event - failure: \(error).")
                            }
                        default:
                            XCTFail("Unexpected event - failure: \(error).")
                        }
                    }
                },
                receiveValue: { _, body in
                    XCTFail("Unexpected event - failure: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 3)

        XCTAssertTrue(currentTokenCalled)
        XCTAssertTrue(authorizedRequestBuilderCalled)

        XCTAssertTrue(errorReceived)
    }

    func test_load_token_for_request_error_passed_through() {
        var currentTokenCalled = false

        authorizedNetworkClient = AuthorizedNetworkClient<TestToken>(
            networkClient: NetworkClient(
                urlSessionConfiguration: .default,
                urlRequester: .unused,
                networkMonitorClient: .unused
            ),
            tokenClient: TokenClient<TestToken>(
                currentToken: Fail(error: TokenError.localTokenError)
                    .handleEvents(receiveSubscription: { _ in currentTokenCalled = true })
                    .delay(for: 1, scheduler: self.testScheduler)
                    .eraseToAnyPublisher(),
                refreshToken: {
                    fatalError("Should not be called!")
                }
            ),
            authorizedRequestBuilder: { _, _  in
                fatalError("Should not be called!")
            }
        )

        var errorReceived = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), AuthorizedNetworkError> = Request.validMock
            .executeAuthorized(using: authorizedNetworkClient)

        response
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        XCTFail("Unexpected event - finished.")
                    case let .failure(error):
                        switch error.cause {
                        case .localTokenError where error.underlyingError is TokenError:
                            switch (error.underlyingError as! TokenError).cause {
                            case .localTokenError:
                                errorReceived = true
                            default:
                                XCTFail("Unexpected event - failure: \(error).")
                            }
                        default:
                            XCTFail("Unexpected event - failure: \(error).")
                        }
                    }
                },
                receiveValue: { _, body in
                    XCTFail("Unexpected event - failure: \(body).")
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 1)

        XCTAssertTrue(currentTokenCalled)

        XCTAssertTrue(errorReceived)
    }
}
