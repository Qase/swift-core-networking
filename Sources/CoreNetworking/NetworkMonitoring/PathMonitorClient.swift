//
//  PathMonitorClient.swift
//  CoreNetworking
//
//  Created by Martin Troup on 30.04.2021.
//

import Foundation
import Combine
import Network

struct PathMonitorClient {
    var setPathUpdateHandler: (@escaping (NetworkPath) -> Void) -> Void
    var start: (DispatchQueue) -> Void
    var cancel: () -> Void

    init(
        setPathUpdateHandler: @escaping (@escaping (NetworkPath) -> Void) -> Void,
        start: @escaping (DispatchQueue) -> Void,
        cancel: @escaping () -> Void
    ) {
        self.setPathUpdateHandler = setPathUpdateHandler
        self.start = start
        self.cancel = cancel
    }
}

// MARK: - PathMonitorClient instances

extension PathMonitorClient {
    static func live(withNWPathMonitor pathMonitor: NWPathMonitor) -> Self {
        .init(
            setPathUpdateHandler: { pathUpdateCallback in
                pathMonitor.pathUpdateHandler = { path in
                    pathUpdateCallback(NetworkPath(rawValue: path))
                }
            },
            start: { queue in
                pathMonitor.start(queue: queue)
            },
            cancel: {
                pathMonitor.cancel()
            }
        )
    }

    static func mock<S: Scheduler>(
        withValues values: [NetworkPath],
        onScheduler scheduler: S,
        every timeDelay: S.SchedulerTimeType.Stride
    ) -> Self {
        var emitter: PassthroughSubject<NetworkPath, Never>? = PassthroughSubject<NetworkPath, Never>()
        var subscriptions: Set<AnyCancellable>? = Set<AnyCancellable>()

        return .init(
            setPathUpdateHandler: { pathUpdateCallback in
                guard var localSubscriptions = subscriptions, let localEmitter = emitter else { return }
                defer { subscriptions = localSubscriptions }

                localEmitter
                    .sink { pathUpdateCallback($0) }
                    .store(in: &localSubscriptions)
            },
            start: { _ in
                guard var localSubscriptions = subscriptions, let localEmitter = emitter else { return }
                defer { subscriptions = localSubscriptions }

                Publishers.Sequence<[NetworkPath], Never>(sequence: values)
                    .flatMap(maxPublishers: .max(1)) { Just($0).delay(for: timeDelay, scheduler: scheduler) }
                    .subscribe(localEmitter)
                    .store(in: &localSubscriptions)
            },
            cancel: {
                subscriptions = nil
                emitter = nil
            }
        )
    }
}
