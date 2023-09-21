//
//  SimpleLogger.swift
//  
//
//  Created by Rubén García on 22/9/23.
//

import Foundation
import os.log

public struct SimpleLoggerStrategy: LoggerStrategy {
    public func log(_ objects: Any..., separator: String, terminator: String, level: LogLevel) {
        objects.forEach { object in
            self.log(object, separator, terminator, level)
        }
    }
    
    public let log: (Any, String, String, LogLevel) -> Void
}

public extension SimpleLoggerStrategy {
    static let `default` = Self { object, separator, terminator, level in
        if level == .DEBUG {
            debugPrint("\(level.rawValue) \(String(describing: object))")
        } else {
            print("\(level.rawValue) \(String(describing: object))")
        }
    }
    
    static let osLog = Self { object, separator, terminator, level in
        os.Logger.main.log(level: level.osLog, "\(level.rawValue) \(String(describing: object))")
    }
}

public extension Logger {
    init(strategy: SimpleLoggerStrategy) {
        self.strategy = strategy
    }
}
