//
//  TokenError.swift
//  CoreNetworking
//
//  Created by Martin Troup on 30.05.2021.
//

import Core
import Foundation

public struct TokenError: ErrorReportable {
    // MARK: - Cause

    public enum ErrorCause: Error, CustomDebugStringConvertible {
        public var debugDescription: String {
            let caseString: (String) -> String = { "ErrorCause.\($0)" }

            switch self {
            case .localTokenError:
                return caseString("localTokenError")
            case .tokenLocallyInvalid:
                return caseString("tokenLocallyInvalid")
            case .refreshError:
                return caseString("refreshError")
            }
        }

        case localTokenError
        case tokenLocallyInvalid
        case refreshError
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

public extension TokenError {

    static var localTokenError: Self {
        .init(cause: .localTokenError)
    }

    static var refreshError: Self {
        .init(cause: .refreshError)
    }

    static var tokenLocallyInvalid: Self {
        .init(cause: .tokenLocallyInvalid)
    }
}
