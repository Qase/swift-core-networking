//
//  NetworkPath.swift
//  CoreNetworking
//  
//
//  Created by Martin Troup on 30.04.2021.
//

import Network

public struct NetworkPath: Equatable {
    let status: NWPath.Status
}

extension NetworkPath {
    init(rawValue: NWPath) {
        self.status = rawValue.status
    }
}

// MARK: - NetworkPath instances

extension NetworkPath {
    static var available: Self {
        .init(status: .satisfied)
    }

    static var unavailable: Self {
        .init(status: .unsatisfied)
    }
}
