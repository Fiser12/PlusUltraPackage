//
//  AppKitHelpers.swift
//  
//
//  Created by Rubén García on 14/9/23.
//

#if os(macOS)
import AppKit
import SwiftUI

public extension NSImage.Name {
    static let menuDebug = NSImage.Name("menuDebug")
    static let menu = NSImage.Name("menu")
}

public extension [NSWindow] {
    func getById(_ id: String) -> NSWindow? {
        filter { $0.tabbingIdentifier.contains(id) }.first
    }
}

public extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}
#endif
