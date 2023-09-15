//
//  File.swift
//  
//
//  Created by Rubén García on 14/9/23.
//

import SwiftUI
import CoreGraphics

#if os(macOS)
public extension NSImage {
    var cgImage: CGImage? {
        cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
}

public typealias Imagen = NSImage
#else
public typealias Imagen = UIImage
public extension UIImage {
    convenience init?(cgImage: CGImage, size: CGSize) {
        guard let cgImage = cgImage.resize(to: size) else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
#endif

public extension Imagen {
#if os(macOS)
    typealias Size = NSSize
#else
    typealias Size = CGSize
#endif
    
    var swiftUIImage: Image {
#if os(macOS)
        Image(nsImage: self)
#else
        Image(uiImage: self)
#endif
    }
    
    func resizedMaintainingAspectRatio(width: CGFloat, height: CGFloat) -> Imagen? {
        let ratioX = width / size.width
        let ratioY = height / size.height
        let ratio = ratioX < ratioY ? ratioX : ratioY
        let newHeight = size.height * ratio
        let newWidth = size.width * ratio
        let newSize = CGSize(width: newWidth, height: newHeight)
        guard let cgImage else { return nil }
        return Imagen(cgImage: cgImage, size: newSize)
    }
}

public extension CGImage {
    func resize(to size: CGSize) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        )
        context?.interpolationQuality = .high
        context?.draw(self, in: CGRect(origin: .zero, size: size))
        
        return context?.makeImage()
    }
}

public extension Image {
    
    static func loadImage(url: URL) -> Imagen? {
        guard let data = try? Data(contentsOf: url), let imagen = Imagen(data: data) else {
            return nil
        }
        
        return imagen.resizedMaintainingAspectRatio(width: 100, height: 100)
    }
    
//FIX: No funciona
#if os(macOS)
    static func saveImage(url: URL) -> UUID? {
        guard let image = Self.loadImage(url: url), let data = image.tiffRepresentation else {
            return nil
        }
        
        let uuid = UUID()
        guard let imageURL = Self.appPath?.appendingPathComponent("\(uuid.uuidString).png") else {
            return nil
        }
        
        let imageRep = NSBitmapImageRep(data: data)
        let pngData = imageRep?.representation(using: .png, properties: [:])
        do {
            try pngData!.write(to: imageURL)
            return uuid
        } catch {
            log("SAVE_IMAGE: \(error)", level: .ERROR)
        }
        return nil
    }
#endif
    
    static var appPath: URL? {
        let fileManager = FileManager()
        let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        guard let id = Bundle.main.bundleIdentifier, let dir = url?.appendingPathComponent(id, isDirectory: true) else {
            return nil
        }
        
        guard fileManager.fileExists(atPath: dir.path) else {
            return nil
        }
        
        do {
            try fileManager.createDirectory(atPath: dir.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            log("APP_PATH: \(error)", level: .ERROR)
            return nil
        }
        
        return dir
    }
}
