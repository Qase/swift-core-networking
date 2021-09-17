//
//  URLRequester.swift
//  CoreNetworking
//
//  Created by Martin Troup on 10.04.2021.
//

import Combine
import Foundation

public struct URLRequester {
    var request: (URLSessionConfiguration)
        -> (URLRequest)
        -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

// MARK: - URLRequester instances

extension URLRequester {
    static let live: Self = .init { urlSessionConfiguration in
        { urlRequest in
            URLSession(configuration: urlSessionConfiguration)
                .dataTaskPublisher(for: urlRequest)
                .eraseToAnyPublisher()
        }
    }

    static func successMock<S: Scheduler>(
        withResponse response: (Data, URLResponse),
        delayedFor time: S.SchedulerTimeType.Stride,
        scheduler: S
    ) -> Self {
        .init { _ in
            { _ in
                Just(response)
                    .setFailureType(to: URLError.self)
                    .delay(for: time, scheduler: scheduler)
                    .eraseToAnyPublisher()
            }
        }
    }

    static func failureMock<S: Scheduler>(
        withError error: URLError,
        delayedFor time: S.SchedulerTimeType.Stride,
        scheduler: S
    ) -> Self {
        .init { _ in
            { _ in
                Fail<(data: Data, response: URLResponse), URLError>(error: error)
                    .delay(for: time, scheduler: scheduler)
                    .eraseToAnyPublisher()
            }
        }
    }

    static var unused: Self {
        .init { _ in
            { _ in
                fatalError("Should not be called!")
            }
        }
    }
}
