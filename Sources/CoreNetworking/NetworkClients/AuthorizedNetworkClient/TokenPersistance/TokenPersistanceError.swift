//
//  TokenPersistanceError.swift
//  CoreNetworking
//
//  Created by Martin Troup on 29.08.2021.
//

import Core
import Foundation

public struct TokenPersistanceError: ErrorReportable {

    // MARK: - Cause

    public enum ErrorCause: Error, CustomDebugStringConvertible {
        public var debugDescription: String {
            let caseString: (String) -> String = { "ErrorCause.\($0)" }

            switch self {
            case .loadTokenError:
                return caseString("loadTokenError")
            case .storeTokenError:
                return caseString("storeTokenError")
            case .deleteTokenError:
                return caseString("deleteTokenError")
            }
        }

        case loadTokenError
        case storeTokenError
        case deleteTokenError
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

public extension TokenPersistanceError {
    static var loadTokenError: Self {
        .init(cause: .loadTokenError)
    }

    static var storeTokenError: Self {
        .init(cause: .storeTokenError)
    }

    static var deleteTokenError: Self {
        .init(cause: .deleteTokenError)
    }
}
