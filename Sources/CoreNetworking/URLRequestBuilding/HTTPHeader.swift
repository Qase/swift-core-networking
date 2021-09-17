//
//  HTTPHeader.swift
//  CoreNetworking
//
//  Created by Martin Troup on 03.03.2021.
//

/// Accept-Type HTTP header values.
public enum AcceptTypeValue: String, CaseIterable {
    case any = "*/*"
    case json = "application/json"
    case xml = "application/xml"
}

/// Content-Type HTTP header values.
public enum ContentTypeValue: String, CaseIterable {
    case json = "application/json"
    case formUrlEncoded = "application/x-www-form-urlencoded"
}

/// Pre-defined HTTP header keys.
public enum HTTPHeaderName: String, CaseIterable {
    case acceptType = "Accept"
    case contentType = "Content-Type"
    case etag = "Etag"
    case ifMatch = "If-Match"
    case cacheControl = "Cache-Control"
    case authorization = "Authorization"
}

/// A representation of a single HTTP header's name / value pair.
public struct HTTPHeader: Equatable, Hashable {
    /// Name of the header.
    public let name: String

    /// Value of the header
    public let value: String

    /// Creates an instance from the given `name` and `value`.
    /// - Parameters:
    ///   - name: The name of the header.
    ///   - value: The value of the header.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }

    /// Creates an instance from the given `name` and `value`.
    /// - Parameters:
    ///   - name: A HTTPHeaderName instance.
    ///   - value: The value of the header.
    public init(name: HTTPHeaderName, value: String) {
        self.name = name.rawValue
        self.value = value
    }

    fileprivate init?(name: AnyHashable, value: Any) {
        guard let name = name as? String, let value = value as? String else {
            return nil
        }

        self.name = name
        self.value = value
    }

    /// Creates an `Accept`header.
    /// - Parameter value: The `Accept` value.
    /// - Returns: The HTTP header.
    public static func accept(_ value: AcceptTypeValue) -> Self {
        .init(name: HTTPHeaderName.acceptType.rawValue, value: value.rawValue)
    }

    /// Creates a `Content-Type` header.
    /// - Parameter value: The `Content-Type` value.
    /// - Returns: The HTTP header.
    public static func contentType(_ value: ContentTypeValue) -> Self {
        .init(name: HTTPHeaderName.contentType.rawValue, value: value.rawValue)
    }
}

/// HTTP Response Header
public typealias HTTPResponseHeaders = [AnyHashable: Any]

public extension HTTPResponseHeaders {
    var httpHeaders: [HTTPHeader] {
        compactMap(HTTPHeader.init)
    }
}

/// Subscript methods for `[HTTPHeader]`
public extension Array where Element == HTTPHeader {
    subscript(_ name: String) -> String? {
        first(where: { $0.name == name }).map(\.value)
    }

    subscript(_ name: HTTPHeaderName) -> String? {
        self[name.rawValue]
    }
}
