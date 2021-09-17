//
//  KeyValueStorageType+tokenPersistance.swift
//  
//
//  Created by Martin Troup on 05.09.2021.
//

import Combine
import Core
import Foundation

extension KeyValueStorageType {
    func store<Token: TokenType>(
        token: Token,
        forKey key: String,
        jsonEncoder: JSONEncoder = JSONEncoder()
    ) -> AnyPublisher<Void, TokenPersistanceError> {
        Result.Publisher(store(encodable: token, forKey: key))
            .mapErrorReportable(to: TokenPersistanceError.storeTokenError)
            .eraseToAnyPublisher()
    }

    func load<Token: TokenType>(
        forKey key: String,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<Token, TokenPersistanceError> {
        Result.Publisher(decodable(forKey: key, jsonDecoder: jsonDecoder))
            .mapErrorReportable(to: TokenPersistanceError.loadTokenError)
            .eraseToAnyPublisher()

    }
}
