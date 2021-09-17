//
//  NWPathMonitor+publisher.swift
//  CoreNetworking
//
//  Created by Martin Troup on 01.04.2021.
//

import Combine
import CombineExt
import Network

extension NWPathMonitor {
    private final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == NetworkPath {
        private var subscriber: S?
        private var requestedDemand: Subscribers.Demand = .none
        private var monitorClient: PathMonitorClient
        private let queue: DispatchQueue
        private var isRunning: Bool = false

        init(subscriber: S, monitorClient: PathMonitorClient, queue: DispatchQueue) {
            self.subscriber = subscriber
            self.monitorClient = monitorClient
            self.queue = queue
        }

        func request(_ demand: Subscribers.Demand) {
            if demand != .none {
                requestedDemand += demand
            }

            guard !isRunning else { return }

            isRunning = true

            monitorClient.setPathUpdateHandler { [weak self] path in
                guard let self = self, self.requestedDemand > .none else { return }

                self.requestedDemand -= .max(1)

                let newDemand = self.subscriber?.receive(path)

                if let newDemand = newDemand, newDemand != .none {
                    self.requestedDemand += newDemand
                }
            }

            monitorClient.start(queue)
        }

        func cancel() {
            monitorClient.cancel()
            subscriber = nil
        }
    }

    public struct Publisher: Combine.Publisher {
        public typealias Output = NetworkPath
        public typealias Failure = Never

        private let monitorClient: PathMonitorClient
        private let queue: DispatchQueue

        init(monitorClient: PathMonitorClient, queue: DispatchQueue) {
            self.monitorClient = monitorClient
            self.queue = queue
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = Subscription(subscriber: subscriber, monitorClient: monitorClient, queue: queue)
            subscriber.receive(subscription: subscription)
        }
    }
}
