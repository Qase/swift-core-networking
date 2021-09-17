//
//  TokenClientLive.swift
//  CoreNetworking
//
//  Created by Martin Troup on 28.08.2021.
//

import Combine
import Core
import Foundation

public class TokenClientLive<Token: TokenType> {
    private let loadToken: () -> AnyPublisher<Token, TokenPersistanceError>
    private let isTokenValid: (Token) -> AnyPublisher<Bool, Never>

    private let lock = NSRecursiveLock()
    private let refreshTokenRequestTrigger = PassthroughSubject<Token, Never>()

    private let currentRefreshTokenSuccess = PassthroughSubject<Token, Never>()
    private let currentRefreshTokenFailure = PassthroughSubject<TokenError, Never>()
    private let currentlyRefreshing = CurrentValueSubject<Bool, Never>(false)

    private var subscriptions = Set<AnyCancellable>()

    public init(
        loadToken: @escaping () -> AnyPublisher<Token, TokenPersistanceError>,
        isTokenValid: @escaping (Token) -> AnyPublisher<Bool, Never> = { _ in Just(true).eraseToAnyPublisher() },
        storeToken: @escaping (Token) -> AnyPublisher<Void, TokenPersistanceError>,
        refreshTokenRequest: @escaping (Token) -> AnyPublisher<Token, TokenError>,
        logger: @escaping (String) -> Void = { Swift.print($0) }
    ) {
        self.loadToken = loadToken
        self.isTokenValid = isTokenValid

        let refreshTokenJob: (Token) -> AnyPublisher<Token, TokenError> = { [weak self] invalidToken in
            guard let self = self else {
                return Fail(error: GeneralError.nilSelf)
                    .mapErrorReportable(to: TokenError.refreshError)
                    .eraseToAnyPublisher()
            }

            return refreshTokenRequest(invalidToken)
                .flatMap { newToken in
                    storeToken(newToken)
                        .map { _ in newToken }
                        .mapErrorReportable(to: TokenError.localTokenError)
                        .eraseToAnyPublisher()
                }
                .feedIsRunning(to: self.currentlyRefreshing)
                .eraseToAnyPublisher()
        }

        refreshTokenRequestTrigger.setFailureType(to: TokenError.self)
            .flatMapFirst(refreshTokenJob)
            .materialize()
            .sink(
                weak: self,
                logger: logger,
                receiveValue: { unwrappedSelf, value in
                    switch value {
                    case let .value(token):
                        self.currentRefreshTokenSuccess.send(token)
                    case let .failure(error):
                        self.currentRefreshTokenFailure.send(error)
                    case .finished:
                        ()
                    }
                }
            )
            .store(in: &subscriptions)
    }

    public var currentToken: AnyPublisher<Token, TokenError> {
        currentlyRefreshing
            .filter(!)
            .prefix(1)
            .flatMap { _ in self.loadToken() }
            .mapErrorReportable(to: TokenError.localTokenError)
            .flatMap { token in
                self.isTokenValid(token)
                    .map(onTrue:token, onFalse: TokenError.tokenLocallyInvalid)
            }
            .eraseToAnyPublisher()
    }

    public func refresh() -> AnyPublisher<Void, TokenError> {
        let refreshTokenRequest = loadToken()
            .mapErrorReportable(to: TokenError.localTokenError)
            .map { token -> Token in
                self.lock.lock()
                self.refreshTokenRequestTrigger.send(token)
                self.lock.unlock()

                return token
            }
            .map { _ in }
            .eraseToAnyPublisher()

        let refreshedToken = currentRefreshTokenSuccess
            .prefix(1)
            .setFailureType(to: TokenError.self)
            .eraseToAnyPublisher()

        let refreshTokenFailure = currentRefreshTokenFailure
            .flatMap { error -> AnyPublisher<Token, TokenError> in
                Fail(error: error).eraseToAnyPublisher()
            }

        let refreshTokenResponse = Publishers.Amb(first: refreshedToken, second: refreshTokenFailure)

        return Publishers.Zip(refreshTokenRequest, refreshTokenResponse)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

// MARK: - Publisher + feedIsRunning

private extension Publisher {
    func feedIsRunning<S: Subject>(to subject: S) -> Publishers.HandleEvents<Self> where S.Output == Bool {
        self.handleEvents(
            receiveSubscription: { _ in subject.send(true) },
            receiveCompletion: { _ in subject.send(false) },
            receiveCancel: { subject.send(false) }
        )
    }
}
