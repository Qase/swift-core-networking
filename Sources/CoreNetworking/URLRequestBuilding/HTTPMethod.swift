//
//  HTTPMethod.swift
//  CoreNetworking
//
//  Created by Martin Troup on 03.03.2021.
//

public enum HTTPMethod: String, CaseIterable {
    case head = "HEAD"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
