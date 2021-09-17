//
//  AuthorizedNetworkClientTests+happy.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 29.08.2021.
//

import Combine
@testable import CoreNetworking
import Foundation
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

extension AuthorizedNetworkClientTests {
    func test_Data_with_headers_success_response_with_local_token() {
        var loadTokenCalled = false
        var authorizedRequestBuilderToken: TestToken? = nil

        authorizedNetworkClient = AuthorizedNetworkClient<TestToken>(
            networkClient: NetworkClient(
                urlSessionConfiguration: .default,
                urlRequester: .successMock(withResponse: (.userMock, HTTPURLResponse.mock), delayedFor: 1, scheduler: testScheduler),
                networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1)
            ),
            tokenClient: TokenClient<TestToken>(
                currentToken: Just(.mock)
                    .setFailureType(to: TokenError.self)
                    .handleEvents(receiveSubscription: { _ in
                        loadTokenCalled = true
                    })
                    .delay(for: 1, scheduler: self.testScheduler)
                    .eraseToAnyPublisher(),
                refreshToken: {
                    fatalError("Shoud not be called!")
                }
            ),
            authorizedRequestBuilder: { request, token in
                authorizedRequestBuilderToken = token
                return request
            }
        )

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), AuthorizedNetworkError> = Request.validMock
            .executeAuthorized(using: authorizedNetworkClient)

        var finished = false
        var valueReceived = false

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

        testScheduler.advance(by: 3)

        XCTAssertTrue(loadTokenCalled)
        XCTAssertEqual(authorizedRequestBuilderToken, .mock)

        XCTAssertTrue(valueReceived)
        XCTAssertTrue(finished)
    }

    func test_User_with_headers_success_response_with_local_token() {
        var loadTokenCalled = false
        var authorizedRequestBuilderToken: TestToken? = nil

        authorizedNetworkClient = AuthorizedNetworkClient<TestToken>(
            networkClient: NetworkClient(
                urlSessionConfiguration: .default,
                urlRequester: .successMock(withResponse: (.userMock, HTTPURLResponse.mock), delayedFor: 1, scheduler: testScheduler),
                networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1)
            ),
            tokenClient: TokenClient<TestToken>(
                currentToken: Just(.mock)
                    .setFailureType(to: TokenError.self)
                    .handleEvents(receiveSubscription: { _ in
                        loadTokenCalled = true
                    })
                    .delay(for: 1, scheduler: self.testScheduler)
                    .eraseToAnyPublisher(),
                refreshToken: {
                    fatalError("Shoud not be called!")
                }
            ),
            authorizedRequestBuilder: { request, token in
                authorizedRequestBuilderToken = token
                return request
            }
        )

        var valueReceived = false
        var finished = false

        let response: AnyPublisher<(headers: [HTTPHeader], object: User), AuthorizedNetworkError> = Request.validMock
            .executeAuthorized(using: authorizedNetworkClient)

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

        testScheduler.advance(by: 3)

        XCTAssertTrue(loadTokenCalled)
        XCTAssertEqual(authorizedRequestBuilderToken, .mock)

        XCTAssertTrue(valueReceived)
        XCTAssertTrue(finished)
    }

    func test_User_without_headers_success_response() {
        var loadTokenCalled = false
        var authorizedRequestBuilderToken: TestToken? = nil

        authorizedNetworkClient = AuthorizedNetworkClient<TestToken>(
            networkClient: NetworkClient(
                urlSessionConfiguration: .default,
                urlRequester: .successMock(withResponse: (.userMock, HTTPURLResponse.mock), delayedFor: 1, scheduler: testScheduler),
                networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1)
            ),
            tokenClient: TokenClient<TestToken>(
                currentToken: Just(.mock)
                    .setFailureType(to: TokenError.self)
                    .handleEvents(receiveSubscription: { _ in
                        loadTokenCalled = true
                    })
                    .delay(for: 1, scheduler: self.testScheduler)
                    .eraseToAnyPublisher(),
                refreshToken: {
                    fatalError("Shoud not be called!")
                }
            ),
            authorizedRequestBuilder: { request, token in
                authorizedRequestBuilderToken = token
                return request
            }
        )

        var valueReceived = false
        var finished = false

        let response: AnyPublisher<User, AuthorizedNetworkError> = Request(endpoint: .mock)
            .executeAuthorized(using: authorizedNetworkClient)

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

        testScheduler.advance(by: 3)

        XCTAssertTrue(loadTokenCalled)
        XCTAssertEqual(authorizedRequestBuilderToken, .mock)

        XCTAssertTrue(valueReceived)
        XCTAssertTrue(finished)
    }

    func test_unauthorized_failure() {
        let unauthorizedHTTPResponse: HTTPURLResponse = HTTPURLResponse(
            url: .mock,
            statusCode: 401,
            httpVersion: nil,
            headerFields: [String: String]()
        )!

        let successHTTPResponse: HTTPURLResponse = HTTPURLResponse(
            url: .mock,
            statusCode: 200,
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
                        let response = networkRequestCount == 0
                            ? (Data(), unauthorizedHTTPResponse)
                            : (.userMock, successHTTPResponse)

                        return Just(response)
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
                        .handleEvents(receiveSubscription: { _ in
                            refreshTokenCount += 1
                        })
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

        var valueReceived = false
        var finished = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), AuthorizedNetworkError> = Request.validMock
            .executeAuthorized(using: authorizedNetworkClient)

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
                    XCTAssertTrue(receivedHeaders.isEmpty)
                    XCTAssertEqual(body, .userMock)
                    valueReceived = true
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 6)

        XCTAssertEqual(networkRequestCount, 2)
        XCTAssertEqual(currentTokenCount, 2)
        XCTAssertEqual(refreshTokenCount, 1)
        XCTAssertEqual(authorizedRequestBuilderCount, 2)

        XCTAssertTrue(valueReceived)
        XCTAssertTrue(finished)
    }

    func test_local_validation_failure() {
        let successHTTPResponse: HTTPURLResponse = HTTPURLResponse(
            url: .mock,
            statusCode: 200,
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
                        return Just((.userMock, successHTTPResponse))
                            .setFailureType(to: URLError.self)
                            .handleEvents(receiveSubscription: { _ in
                                networkRequestCount += 1
                            })
                            .delay(for: 1, scheduler: self.testScheduler)
                            .eraseToAnyPublisher()
                    }
                },
                networkMonitorClient: .mock(withValues: [.available], onScheduler: testScheduler, every: 1)
            ),
            tokenClient: TokenClient<TestToken>(
                currentToken: {
                    let publisher = Publishers.Create<TestToken, TokenError> { factory in
                        if currentTokenCount == 0 {
                            factory.send(completion: .failure(.tokenLocallyInvalid))
                        } else {
                            factory.send(.mock)
                            factory.send(completion: .finished)
                        }

                        return AnyCancellable {}
                    }

                    return publisher
                        .handleEvents(receiveSubscription: { _ in currentTokenCount += 1 })
                        .delay(for: 1, scheduler: self.testScheduler)
                        .eraseToAnyPublisher()
                }(),
                refreshToken: {
                    Just(())
                        .setFailureType(to: TokenError.self)
                        .handleEvents(receiveSubscription: { _ in
                            refreshTokenCount += 1
                        })
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

        var valueReceived = false
        var finished = false

        let response: AnyPublisher<(headers: [HTTPHeader], body: Data), AuthorizedNetworkError> = Request.validMock
            .executeAuthorized(using: authorizedNetworkClient)

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
                    XCTAssertTrue(receivedHeaders.isEmpty)
                    XCTAssertEqual(body, .userMock)
                    valueReceived = true
                }
            )
            .store(in: &subscriptions)

        testScheduler.advance(by: 5)

        XCTAssertEqual(networkRequestCount, 1)
        XCTAssertEqual(currentTokenCount, 2)
        XCTAssertEqual(refreshTokenCount, 1)
        XCTAssertEqual(authorizedRequestBuilderCount, 1)

        XCTAssertTrue(valueReceived)
        XCTAssertTrue(finished)
    }
}
