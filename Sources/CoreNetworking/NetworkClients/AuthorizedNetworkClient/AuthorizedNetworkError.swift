//
//  AuthorizedNetworkError.swift
//  CoreNetworking
//
//  Created by Martin Troup on 29.08.2021.
//

import Core
import Foundation

public struct AuthorizedNetworkError: ErrorReportable {

    // MARK: - Cause

    public enum ErrorCause: Error, CustomDebugStringConvertible {
        public var debugDescription: String {
            let caseString: (String) -> String = { "ErrorCause.\($0)" }

            switch self {
            case .networkError:
                return caseString("networkError")
            case .localTokenError:
                return caseString("localTokenError")
            case .refreshTokenError:
                return caseString("refreshTokenError")
            }
        }

        case networkError
        case localTokenError
        case refreshTokenError
    }

    // MARK: - Properties

    public let catalogueID = ErrorCatalogueID.unassigned
    public let cause: ErrorCause
    public var stackID: UUID?
    public var underlyingError: ErrorReportable?

    public var causeDescription: CustomDebugStringConvertible? { cause.debugDescription }

    // MARK: - Initializers

    public init(cause: ErrorCause, stackID: UUID? = nil) {
        self.cause = cause
        self.stackID = stackID ?? UUID()
    }
}

// MARK: - NetworkError instances

public extension AuthorizedNetworkError {
    static var networkError: Self {
        .init(cause: .networkError)
    }

    static var localTokenError: Self {
        .init(cause: .localTokenError)
    }

    static var refreshTokenError: Self {
        .init(cause: .refreshTokenError)
    }
}
