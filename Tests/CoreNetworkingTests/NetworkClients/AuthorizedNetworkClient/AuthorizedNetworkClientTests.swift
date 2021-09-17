//
//  AuthorizedNetworkClientTests.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 29.08.2021.
//

import Combine
import CombineSchedulers
@testable import CoreNetworking
import XCTest

class AuthorizedNetworkClientTests: XCTestCase {
    var authorizedNetworkClient: AuthorizedNetworkClientType!
    let consoleLogger = NetworkLoggerClient.consoleLogger

    var subscriptions = Set<AnyCancellable>()
    var testScheduler: TestScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>!


    override func setUp() {
        super.setUp()

        testScheduler = DispatchQueue.test
    }

    override func tearDown() {
        subscriptions = []
        testScheduler = nil
        authorizedNetworkClient = nil

        super.tearDown()
    }
}

extension AuthorizedNetworkClientTests {
    struct TestToken: TokenType, Equatable {
        var value : String

        var description: String { "\(value)" }
    }
}

extension AuthorizedNetworkClientTests.TestToken {
    static var mock = AuthorizedNetworkClientTests.TestToken(value: "testToken")
}
