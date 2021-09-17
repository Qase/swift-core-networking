//
//  NetworkMonitorClientTests.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 02.04.2021.
//

import Combine
import CombineSchedulers
@testable import CoreNetworking
import Network
import XCTest

class NetworkMonitorClientTests: XCTestCase {
    private var testScheduler: TestScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        testScheduler = DispatchQueue.test
    }

    override func tearDown() {
        testScheduler = nil
        subscriptions = []

        super.tearDown()
    }

    func test_single_publisher() {
        let networkMonitorClient = NetworkMonitorClient.mock(
            withValues: [.available, .unavailable, .available],
            onScheduler: testScheduler,
            every: 1
        )

        var receivedValues = [Bool]()

        networkMonitorClient.isNetworkAvailable
            .sink {
                receivedValues.append($0)
            }
            .store(in: &subscriptions)

        testScheduler.advance(by: 3)

        XCTAssertEqual(receivedValues, [true, false, true])
    }

    func test_multiple_publishers_from_single_NetworkMonitorClient_instance() {
        let pathMonitorClient = NetworkMonitorClient.mock(
            withValues: [.available, .unavailable, .available],
            onScheduler: testScheduler,
            every: 1
        )

        let publisher1 = pathMonitorClient.isNetworkAvailable
        let publisher2 = pathMonitorClient.isNetworkAvailable

        var receivedValuesForPublisher1 = [Bool]()

        publisher1
            .sink {
                receivedValuesForPublisher1.append($0)
            }
            .store(in: &subscriptions)

        var receivedValuesForPublisher2 = [Bool]()

        publisher2
            .sink {
                receivedValuesForPublisher2.append($0)
            }
            .store(in: &self.subscriptions)

        testScheduler.advance(by: 3)

        XCTAssertEqual(receivedValuesForPublisher1, [true, false, true])
        XCTAssertEqual(receivedValuesForPublisher2, [true, false, true])
    }

    func test_multiple_delayed_publishers_from_single_NetworkMonitorClient_instance() {
        let pathMonitorClient = NetworkMonitorClient.mock(
            withValues: [.available, .unavailable, .available],
            onScheduler: testScheduler,
            every: 1
        )

        let publisher1 = pathMonitorClient.isNetworkAvailable
        let publisher2 = pathMonitorClient.isNetworkAvailable

        var receivedValuesForPublisher1 = [Bool]()

        publisher1
            .sink {
                receivedValuesForPublisher1.append($0)
            }
            .store(in: &subscriptions)

        var receivedValuesForPublisher2 = [Bool]()

        testScheduler.schedule(after: testScheduler.now.advanced(by: 3)) {
            publisher2
                .sink {
                    receivedValuesForPublisher2.append($0)
                }
                .store(in: &self.subscriptions)
        }

        testScheduler.advance(by: 3)

        XCTAssertEqual(receivedValuesForPublisher1, [true, false, true])
        XCTAssertEqual(receivedValuesForPublisher2, [false, true])
    }

    func test_single_publisher_instance_with_multiple_subscribers() {
        let pathMonitorClient = NetworkMonitorClient.mock(
            withValues: [.available, .unavailable, .available],
            onScheduler: testScheduler,
            every: 1
        )

        let publisher = pathMonitorClient.isNetworkAvailable

        var receivedValuesForPublisher1 = [Bool]()

        publisher
            .sink {
                receivedValuesForPublisher1.append($0)
            }
            .store(in: &subscriptions)

        var receivedValuesForPublisher2 = [Bool]()

        publisher
            .sink {
                receivedValuesForPublisher2.append($0)
            }
            .store(in: &self.subscriptions)

        testScheduler.advance(by: 3)

        XCTAssertEqual(receivedValuesForPublisher1, [true, false, true])
        XCTAssertEqual(receivedValuesForPublisher2, [true, false, true])
    }

    func test_single_publisher_instance_with_multiple_delayed_subscribers() {
        let pathMonitorClient = NetworkMonitorClient.mock(
            withValues: [.available, .unavailable, .available],
            onScheduler: testScheduler,
            every: 1
        )

        let publisher = pathMonitorClient.isNetworkAvailable

        var receivedValuesForPublisher1 = [Bool]()

        publisher
            .sink {
                receivedValuesForPublisher1.append($0)
            }
            .store(in: &subscriptions)

        var receivedValuesForPublisher2 = [Bool]()

        testScheduler.schedule(after: testScheduler.now.advanced(by: 3)) {
            publisher
                .sink {
                    receivedValuesForPublisher2.append($0)
                }
                .store(in: &self.subscriptions)
        }

        testScheduler.advance(by: 3)

        XCTAssertEqual(receivedValuesForPublisher1, [true, false, true])
        XCTAssertEqual(receivedValuesForPublisher2, [false, true])
    }
}
