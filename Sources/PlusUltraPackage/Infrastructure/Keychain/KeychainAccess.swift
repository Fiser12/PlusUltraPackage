//
//  KeychainWrapper.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 20/2/23.
//

import Foundation

public final class KeychainAccess {
    public static let shared = KeychainAccess(service: Bundle.main.bundleIdentifier!)
    
    let service: String
    
    public init(service: String) {
        self.service = service
    }
    
    public func get(_ key: String) throws -> String? {
        guard let data = try getData(key) else { return nil }
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainAccessError.conversionError
        }
        return string
    }
    
    public func getData(_ key: String) throws -> Data? {
        let query = self.query(key: key)
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainAccessError.unexpectedError
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainAccessError.securityError
        }
    }
    
    public subscript(key: String) -> Data? {
        get {
            try? getData(key)
        }
        
        set {
            guard let value = newValue else {
                try? remove(key)
                return
            }
            try? set(value, key: key)
        }
    }
    
    public func set(_ value: String, key: String) throws {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
            print("failed to convert string to data")
            throw KeychainAccessError.conversionError
        }
        try set(data, key: key)
    }
    
    public func set(_ value: Data, key: String) throws {
        let query = self.query(key: key)
        
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess, errSecInteractionNotAllowed:
            let attributes = self.query(key: key, value: value)
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if status != errSecSuccess {
                throw KeychainAccessError.securityError
            }
        case errSecItemNotFound:
            let query = self.query(key: key, value: value)
            status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                throw KeychainAccessError.securityError
            }
        default:
            throw KeychainAccessError.securityError
        }
    }
    
    public func remove(_ key: String) throws {
        let query = self.query(key: key)
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainAccessError.securityError
        }
    }
    
    private func query(key: String? = nil, value: Data? = nil) -> [String: Any]{
        var attributes = [String: Any]()
        
        if let key {
            attributes[Class] = String(kSecClassGenericPassword)
            attributes[AttributeService] = service
            attributes[AttributeAccount] = key
        }
        
        if let value {
            attributes[ValueData] = value
        } else {
            attributes[ReturnData] = kCFBooleanTrue
        }
        return attributes
    }
    
}

/** Class Key Constant */
private let Class = String(kSecClass)
private let AttributeType = String(kSecAttrType)
private let AttributeAccount = String(kSecAttrAccount)
private let AttributeService = String(kSecAttrService)
private let ReturnData = String(kSecReturnData)
private let ValueData = String(kSecValueData)

public enum KeychainAccessError: Error {
    case securityError
    case conversionError
    case unexpectedError
}

