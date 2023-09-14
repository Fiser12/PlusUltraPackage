//
//  File.swift
//  
//
//  Created by Rubén García on 14/9/23.
//

import SwiftUI

public extension Color {    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
    
    var rgba: String {
#if os(iOS)
        let uiColor = UIColor(self)
        let rgbColor = uiColor
#elseif os(macOS)
        let rgbColor = NSColor(self).usingColorSpace(.extendedSRGB) ?? NSColor(red: 1, green: 1, blue: 1, alpha: 1)
#endif
        
        var (red, green, blue, alpha) = (CGFloat.zero, CGFloat.zero, CGFloat.zero, CGFloat.zero)
        
        rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = (Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255) << 0)
        return NSString(format: "#%06x", rgb) as String
    }
}
