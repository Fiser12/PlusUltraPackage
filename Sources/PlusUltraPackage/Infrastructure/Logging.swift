//
//  Logging.swift
//  SyncTion (macOS)
//
//  Created by Rubén on 26/12/22.
//

import Foundation
import os.log

public extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let main = Logger(subsystem: subsystem, category: "main")
}

public enum LogLevel: String {
    case DEBUG = "🔵"
    case INFO = "🟢"
    case DEFAULT = "🟡"
    case ERROR = "🔴"
    case FAULT = "⚫️"

    var osLog: OSLogType {
        switch self {
        case .DEBUG:
            return OSLogType.debug
        case .INFO:
            return OSLogType.info
        case .DEFAULT:
            return OSLogType.default
        case .ERROR:
            return OSLogType.error
        case .FAULT:
            return OSLogType.fault
        }
    }
}

public func log(_ object: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n", level: LogLevel = .INFO) {
    _log(object, separator: separator, terminator: terminator, level: .DEBUG)
}

private func _log(_ object: () -> Any, separator _: String = " ", terminator _: String = "\n", level: LogLevel = .INFO) {
    #if DEBUG
    print("\(level.rawValue) \(String(describing: object()))")
    #else
    let object = object()
    Logger.main.log(level: level.osLog, "\(level.rawValue) \(String(describing: object))")
    #endif
}


public func debug(_ object: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
    _log(object, separator: separator, terminator: terminator, level: .DEBUG)
}

public func info(_ object: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
    _log(object, separator: separator, terminator: terminator, level: .INFO)
}

public func warning(_ object: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
    _log(object, separator: separator, terminator: terminator, level: .DEFAULT)
}

public func error(_ object: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
    _log(object, separator: separator, terminator: terminator, level: .ERROR)
}

public func critical(_ object: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
    _log(object, separator: separator, terminator: terminator, level: .FAULT)
}
