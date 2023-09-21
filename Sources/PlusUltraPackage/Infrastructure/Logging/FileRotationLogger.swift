//
//  FileRotationLogger.swift
//  
//
//  Created by Rubén García on 22/9/23.
//

import Foundation

public extension SimpleLoggerStrategy {
    static func rotationFileLogger(directory: URL, maxLogsToKeep: Int) -> SimpleLoggerStrategy {
        return Self { object, separator, terminator, level in
            let logString = "\(level.rawValue) \(String(describing: object))\(terminator)"
            
            let currentLogFile = SimpleLoggerStrategy.getCurrentLogFile(directory: directory)
            let filePath = directory.appendingPathComponent(currentLogFile)
            
            if let data = logString.data(using: .utf8) {
                if FileManager.default.fileExists(atPath: filePath.path) {
                    let currentData = FileManager.default.contents(atPath: filePath.path)
                    let newData = currentData! + data
                    FileManager.default.createFile(atPath: filePath.path, contents: newData)
                } else {
                    FileManager.default.createFile(atPath: filePath.path, contents: data)
                }
            }
            
            if let logContents = try? String(contentsOf: filePath),
               logContents.split(separator: "\n").count > maxLogsToKeep {
                SimpleLoggerStrategy.rotateLogs(directory: directory, maxLogsToKeep: maxLogsToKeep)
            }
        }
    }
    
    private static func getCurrentLogFile(directory: URL) -> String {
        let fileManager = FileManager.default
        for i in 0..<Int.max {
            let logFile = "log_\(i).txt"
            if !fileManager.fileExists(atPath: directory.appendingPathComponent(logFile).path) {
                return logFile
            }
        }
        return "log_0.txt"
    }
    
    private static func rotateLogs(directory: URL, maxLogsToKeep: Int) {
        let fileManager = FileManager.default
        
        // Eliminar el archivo más antiguo si es necesario
        let oldestLogFile = directory.appendingPathComponent("log_\(maxLogsToKeep).txt")
        if fileManager.fileExists(atPath: oldestLogFile.path) {
            try? fileManager.removeItem(at: oldestLogFile)
        }
        
        // Mover todos los archivos una posición más alta
        for i in stride(from: maxLogsToKeep - 1, through: 0, by: -1) {
            let currentPath = directory.appendingPathComponent("log_\(i).txt")
            let newPath = directory.appendingPathComponent("log_\(i+1).txt")
            
            if fileManager.fileExists(atPath: currentPath.path) {
                try? fileManager.moveItem(at: currentPath, to: newPath)
            }
        }
    }
}
