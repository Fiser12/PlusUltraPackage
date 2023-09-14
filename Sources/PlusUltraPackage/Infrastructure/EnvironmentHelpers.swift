//
//  Constants.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 22/2/23.
//
import Foundation

final class EnvironmentHelpers {
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
