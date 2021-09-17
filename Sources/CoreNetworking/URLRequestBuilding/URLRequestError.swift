//
//  URLRequestError.swift
//  CoreNetworking
//
//  Created by Martin Troup on 27.03.2021.
//

import Core
import Foundation

public struct URLRequestError: ErrorReportable {

    // MARK: - Cause

    public enum ErrorCause: Error, CustomDebugStringConvertible {
        public var debugDescription: String {
            let caseString: (String) -> String = { "ErrorCause.\($0)" }
            
            switch self {
            case .endpointParsingError:
                return caseString("endpointParsingError")
            case .parameterParsingError:
                return caseString("parameterParsingError")
            case .invalidURLComponents:
                return caseString("invalidURLComponents")
            case let .bodyEncodingError(error):
                return caseString("bodyEncodingError(error: \(error))")
            }
        }

        case endpointParsingError
        case parameterParsingError
        case invalidURLComponents
        case bodyEncodingError(Error)
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

public extension URLRequestError {
    static var endpointParsingError: Self {
        .init(cause: .endpointParsingError)
    }

    static var parameterParsingError: Self {
        .init(cause: .parameterParsingError)
    }

    static var invalidURLComponents: Self {
        .init(cause: .invalidURLComponents)
    }

    static var bodyEncodingError: (Error) -> Self {
        { .init(cause: .bodyEncodingError($0)) }
    }
}
