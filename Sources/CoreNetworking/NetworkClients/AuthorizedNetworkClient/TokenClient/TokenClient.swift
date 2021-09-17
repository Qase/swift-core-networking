//
//  TokenClient.swift
//  CoreNetworking
//
//  Created by Martin Troup on 29.05.2021.
//

import Combine
import CombineExt
import Core
import CasePaths
import Overture

public protocol TokenType: Codable, Equatable, CustomStringConvertible {}

public struct TokenClient<Token: TokenType> {
    let currentToken: AnyPublisher<Token, TokenError>
    let refreshToken: () -> AnyPublisher<Void, TokenError>

    public init(
        currentToken: AnyPublisher<Token, TokenError>,
        refreshToken: @escaping () -> AnyPublisher<Void, TokenError>
    ) {
        self.currentToken = currentToken
        self.refreshToken = refreshToken
    }
}

// MARK: - Instances

extension TokenClient {
    static func live(
        loadToken: @escaping () -> AnyPublisher<Token, TokenPersistanceError>,
        isTokenValid: @escaping (Token) -> AnyPublisher<Bool, Never>,
        storeToken: @escaping (Token) -> AnyPublisher<Void, TokenPersistanceError>,
        refreshTokenRequest: @escaping (Token) -> AnyPublisher<Token, TokenError>,
        logger: @escaping (String) -> Void = { Swift.print($0) }
    ) -> Self {
        let refreshTokenClientLive = TokenClientLive(
            loadToken: loadToken,
            isTokenValid: isTokenValid,
            storeToken: storeToken,
            refreshTokenRequest: refreshTokenRequest,
            logger: logger
        )

        return .init(
            currentToken: refreshTokenClientLive.currentToken,
            refreshToken: refreshTokenClientLive.refresh
        )
    }
}
