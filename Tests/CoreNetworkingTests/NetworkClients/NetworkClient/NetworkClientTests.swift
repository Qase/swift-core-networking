//
//  NetworkClientTests.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 09.04.2021.
//

import Combine
import CombineSchedulers
@testable import CoreNetworking
import XCTest

class NetworkClientTests: XCTestCase {
    var networkClient: NetworkClientType!
    let consoleLogger = NetworkLoggerClient.consoleLogger

    var subscriptions = Set<AnyCancellable>()
    var testScheduler: TestScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>!

    override func setUp() {
        super.setUp()

        testScheduler = DispatchQueue.test
    }

    override func tearDown() {
        subscriptions = []
        networkClient = nil
        testScheduler = nil

        super.tearDown()
    }
}

