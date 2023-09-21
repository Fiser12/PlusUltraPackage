//
//  Constants.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 22/2/23.
//
import Foundation

public final class EnvironmentHelpers {
    public static var isRunningInPreview: Bool = {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }()

    public static var isRunningInDebug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    public static let isMacOSEnvironment: Bool = {
    #if os(macOS)
        true
    #else
        false
    #endif
    }()
}

@propertyWrapper
public struct EnvVariable<T> {
    private var value: T
    private let conversion: (String) -> T
    private let key: String
    
    public var wrappedValue: T {
        get {
            if let value = getenv(key), let str = String(utf8String: value) {
                return conversion(str)
            } else {
                return value
            }
        }
        set {
            value = newValue
        }
    }

    public init(wrappedValue: T, key: String, conversion: @escaping (String) -> T) {
        self.value = wrappedValue
        self.key = key
        self.conversion = conversion
    }
}
