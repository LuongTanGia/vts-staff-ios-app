//
//  AppleAuthResult.swift
//  VTS_STAFF
//

import Foundation

public struct AppleAuthResult: Identifiable, Codable, CustomStringConvertible {
    public let id: String
    public let appleUserId: String
    public let identityToken: String
    public let authorizationCode: String?
    public let email: String?
    public let fullName: String?

    public init(
        appleUserId: String,
        identityToken: String,
        authorizationCode: String? = nil,
        email: String? = nil,
        fullName: String? = nil
    ) {
        self.id = appleUserId
        self.appleUserId = appleUserId
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.email = email
        self.fullName = fullName
    }
    
    public var description: String {
        return "AppleAuthResult(appleUserId: \(appleUserId), email: \(email ?? "nil"), fullName: \(fullName ?? "nil"))"
    }
}
