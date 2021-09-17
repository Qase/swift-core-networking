//
//  NetworkError.swift
//  CoreNetworking
//
//  Created by Martin Troup on 03.03.2021.
//

import Core
import Foundation

public struct NetworkError: ErrorReportable {

    // MARK: - Cause

    public enum ErrorCause: Error, CustomDebugStringConvertible {
        public var debugDescription: String {
            let caseString: (String) -> String = { "ErrorCause.\($0)" }

            switch self {
            case let .urlError(urlError):
                return caseString("urlError(urlError: \(urlError))")
            case .invalidResponse:
                return caseString("invalidResponse")
            case .unauthorized:
                return caseString("unauthorized")
            case let .clientError(statusCode):
                return caseString("clientError(statusCode: \(statusCode))")
            case let .serverError(statusCode):
                return caseString("serverError(statusCode: \(statusCode))")
            case .noConnection:
                return caseString("noConnection")
            case let .jsonDecodingError(error):
                return caseString("jsonDecodingError(error: \(error))")
            case .urlRequestError:
                return caseString("urlRequestError")
            }
        }

        case urlError(URLError)
        case invalidResponse
        case unauthorized
        case clientError(statusCode: Int)
        case serverError(statusCode: Int)
        case noConnection
        case jsonDecodingError(Error)
        case urlRequestError
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

public extension NetworkError {
    static var urlError: (URLError) -> Self {
        { .init(cause: .urlError($0)) }
    }

    static var invalidResponse: Self {
        .init(cause: .invalidResponse)
    }

    static var unauthorized: Self {
        .init(cause: .unauthorized)
    }

    static var clientError: (Int) -> Self {
        { .init(cause: .clientError(statusCode: $0)) }
    }

    static var serverError: (Int) -> Self {
        { .init(cause: .serverError(statusCode: $0)) }
    }

    static var noConnection: Self {
        .init(cause: .noConnection)
    }

    static var jsonDecodingError: (Error) -> Self {
        { .init(cause: .jsonDecodingError($0)) }
    }

    static var urlRequestError: Self {
        .init(cause: .urlRequestError)
    }
}
