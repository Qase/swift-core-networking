//
//  Publisher+decode.swift
//  CoreNetworking
//
//  Created by Martin Troup on 05.04.2021.
//

import Combine
import CombineExt
import Foundation

public extension Publisher {
    func decode<Item, Coder>(
        type: Item.Type,
        decoder: Coder,
        mapError errorMapper: @escaping (Error) -> NetworkError
    )
    -> AnyPublisher<(headers: [HTTPHeader], object: Item), NetworkError>
    where
        Item: Decodable,
        Coder: TopLevelDecoder,
        Coder.Input == Data,
        Self.Output == (headers: [HTTPHeader], body: Data),
        Self.Failure == NetworkError
    {
        let sharedUpstream = self.share(replay: 1)

        let headers = sharedUpstream.map(\.headers)

        let decoded = sharedUpstream.map(\.body)
            .decode(type: Item.self, decoder: decoder)
            .mapError(errorMapper)

        return Publishers.Zip(headers, decoded)
            .map { (headers: $0, object: $1) }
            .eraseToAnyPublisher()
    }
}
