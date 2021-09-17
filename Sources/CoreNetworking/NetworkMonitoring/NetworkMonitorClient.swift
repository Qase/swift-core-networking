//
//  NetworkMonitorClient.swift
//  CoreNetworking
//
//  Created by Martin Troup on 02.04.2021.
//

import Combine
import Network

// NOTE: The NetworkMonitorClient must be a class type since it has a lazy property which is mutating.
public final class NetworkMonitorClient {
    private let pathMonitorPublisher: NWPathMonitor.Publisher

    lazy var isNetworkAvailable: AnyPublisher<Bool, Never> = {
        pathMonitorPublisher
            .share(replay: 1)
            .map { $0.status == .satisfied }
            .eraseToAnyPublisher()
    }()

    public required init(pathMonitorPublisher: NWPathMonitor.Publisher) {
        self.pathMonitorPublisher = pathMonitorPublisher
    }
}

// MARK: - NetworkMonitorClient instances

extension NetworkMonitorClient {
    static func live(onQueue queue: DispatchQueue = .main) -> Self {
        .init(
            pathMonitorPublisher: NWPathMonitor.Publisher(
                monitorClient: .live(withNWPathMonitor: NWPathMonitor()),
                queue: queue
            )
        )
    }

    static func mock<S: Scheduler>(
        withValues values: [NetworkPath],
        onScheduler scheduler: S,
        every timeDelay: S.SchedulerTimeType.Stride
    ) -> Self {
        .init(
            pathMonitorPublisher: .init(
                monitorClient: .mock(withValues: values, onScheduler: scheduler, every: timeDelay),
                queue: .main
            )
        )
    }
    
    static var unused: Self {
        .init(
            pathMonitorPublisher: .init(
                monitorClient: .init(
                    setPathUpdateHandler: { _ in fatalError("Should not be used!") },
                    start: { _ in fatalError("Should not be used!") },
                    cancel: { fatalError("Should not be used!") }
                ),
                queue: .main
            )
        )
    }
}
