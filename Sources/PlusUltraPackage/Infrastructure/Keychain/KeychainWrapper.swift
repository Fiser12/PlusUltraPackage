//
//  KeychainWrapper.swift
//  
//
//  Created by Rubén García on 22/9/23.
//

import Foundation

public protocol LoadedFromEnvironmentVariable {
    init(envText: String)
}

@propertyWrapper
public struct KeychainWrapper<Wrapped: LoadedFromEnvironmentVariable & Codable> {
    public let service: String
    private var cache: Wrapped?
    public var wrappedValue: Wrapped? {
        get {
            self.cache
        }
        set {
            self.cache = newValue
            self.encode()
        }
    }
    
    private func encode() {
        guard !EnvironmentHelpers.isRunningInDebug else { return }
        Task {
            if let data = try? JSONEncoder().encode(self.cache) {
                try? KeychainAccess.shared.set(data, key: self.service)
            } else {
                try? KeychainAccess.shared.remove(self.service)
            }
        }
    }
    
    public mutating func reload() {
        self.cache = decode
    }

    private var decode: Wrapped? {
        let data: Data?
        if EnvironmentHelpers.isRunningInPreview {
            data = nil
        } else if let envText = Self.getEnvironmentVar(service) {
            return Wrapped(envText: envText)
        } else {
            data = try? KeychainAccess.shared.getData(service) ?? "nil".data(using: .utf8)
        }
        guard let data, let wrapped = try? JSONDecoder().decode(Wrapped.self, from: data) else { return nil }
        return wrapped
    }

    static private func getEnvironmentVar(_ name: String) -> String? {
        guard let rawValue = getenv(name) else {
            return nil
        }
        return String(utf8String: rawValue)
    }

    public init(_ service: String) {
        self.service = service
        self.cache = decode
    }
}
