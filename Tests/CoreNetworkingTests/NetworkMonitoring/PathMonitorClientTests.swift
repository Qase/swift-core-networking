//
//  PathMonitorClientTests.swift
//  CoreNetworkingTests
//
//  Created by Martin Troup on 02.05.2021.
//

import CombineSchedulers
@testable import CoreNetworking
import XCTest

class PathMonitorClientTests: XCTestCase {
    func test_pathMonitorClient() {
        let testScheduler = DispatchQueue.test

        let pathMonitorClient = PathMonitorClient.mock(
            withValues: [.available, .unavailable, .available],
            onScheduler: testScheduler,
            every: 1
        )

        var receivedValues = [NetworkPath]()
        
        pathMonitorClient.setPathUpdateHandler {
            receivedValues.append($0)
        }
        
        pathMonitorClient.start(DispatchQueue.main)

        testScheduler.advance(by: 3)

        XCTAssertEqual(receivedValues, [.available, .unavailable, .available])
    }
}
