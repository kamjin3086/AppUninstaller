#!/usr/bin/env swift

import Cocoa

// Icon sizes needed for macOS app
let sizes: [(size: Int, scale: Int, name: String)] = [
    (16, 1, "icon_16x16"),
    (16, 2, "icon_16x16@2x"),
    (32, 1, "icon_32x32"),
    (32, 2, "icon_32x32@2x"),
    (128, 1, "icon_128x128"),
    (128, 2, "icon_128x128@2x"),
    (256, 1, "icon_256x256"),
    (256, 2, "icon_256x256@2x"),
    (512, 1, "icon_512x512"),
    (512, 2, "icon_512x512@2x")
]

func drawIcon(in context: CGContext, size: CGFloat) {
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    
    // Background gradient (red)
    let cornerRadius = size * 0.195
    let bgPath = CGPath(roundedRect: rect.insetBy(dx: size * 0.04, dy: size * 0.04),
                        cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    context.saveGState()
    context.addPath(bgPath)
    context.clip()
    
    let colors = [
        CGColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0),
        CGColor(red: 0.93, green: 0.35, blue: 0.35, alpha: 1.0),
        CGColor(red: 0.84, green: 0.27, blue: 0.27, alpha: 1.0)
    ]
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                               colors: colors as CFArray,
                               locations: [0, 0.5, 1])!
    context.drawLinearGradient(gradient,
                                start: CGPoint(x: 0, y: size),
                                end: CGPoint(x: size, y: 0),
                                options: [])
    context.restoreGState()
    
    // Trash can
    let trashX = size * 0.28
    let trashY = size * 0.17
    let trashWidth = size * 0.44
    let trashHeight = size * 0.63
    
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    context.setShadow(offset: CGSize(width: 0, height: -size * 0.01), blur: size * 0.03,
                      color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.3))
    
    // Lid
    let lidRect = CGRect(x: trashX - size * 0.04, y: size - trashY - size * 0.06,
                         width: trashWidth + size * 0.08, height: size * 0.06)
    let lidPath = CGPath(roundedRect: lidRect, cornerWidth: size * 0.015, cornerHeight: size * 0.015, transform: nil)
    context.addPath(lidPath)
    context.fillPath()
    
    // Handle
    context.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
    context.setLineWidth(size * 0.035)
    context.setLineCap(.round)
    
    let handleY = size - trashY - size * 0.06
    context.move(to: CGPoint(x: size * 0.41, y: handleY))
    context.addLine(to: CGPoint(x: size * 0.41, y: handleY + size * 0.04))
    context.addQuadCurve(to: CGPoint(x: size * 0.47, y: handleY + size * 0.09),
                         control: CGPoint(x: size * 0.41, y: handleY + size * 0.09))
    context.addLine(to: CGPoint(x: size * 0.53, y: handleY + size * 0.09))
    context.addQuadCurve(to: CGPoint(x: size * 0.59, y: handleY + size * 0.04),
                         control: CGPoint(x: size * 0.59, y: handleY + size * 0.09))
    context.addLine(to: CGPoint(x: size * 0.59, y: handleY))
    context.strokePath()
    
    // Body
    context.setShadow(offset: CGSize(width: 0, height: -size * 0.01), blur: size * 0.02,
                      color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.2))
    
    let bodyPath = CGMutablePath()
    bodyPath.move(to: CGPoint(x: trashX, y: size - trashY - size * 0.08))
    bodyPath.addLine(to: CGPoint(x: trashX + size * 0.02, y: size - trashY - trashHeight + size * 0.07))
    bodyPath.addQuadCurve(to: CGPoint(x: trashX + size * 0.06, y: size - trashY - trashHeight),
                          control: CGPoint(x: trashX + size * 0.02, y: size - trashY - trashHeight))
    bodyPath.addLine(to: CGPoint(x: trashX + trashWidth - size * 0.06, y: size - trashY - trashHeight))
    bodyPath.addQuadCurve(to: CGPoint(x: trashX + trashWidth - size * 0.02, y: size - trashY - trashHeight + size * 0.07),
                          control: CGPoint(x: trashX + trashWidth - size * 0.02, y: size - trashY - trashHeight))
    bodyPath.addLine(to: CGPoint(x: trashX + trashWidth, y: size - trashY - size * 0.08))
    bodyPath.closeSubpath()
    
    context.addPath(bodyPath)
    context.fillPath()
    
    // Lines on trash
    context.setShadow(offset: .zero, blur: 0, color: nil)
    context.setStrokeColor(CGColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1))
    context.setLineWidth(size * 0.02)
    
    let lineTop = size - trashY - size * 0.12
    let lineBottom = size - trashY - trashHeight + size * 0.08
    
    // Left line
    context.move(to: CGPoint(x: size * 0.41, y: lineTop))
    context.addLine(to: CGPoint(x: size * 0.425, y: lineBottom))
    context.strokePath()
    
    // Center line
    context.move(to: CGPoint(x: size * 0.5, y: lineTop))
    context.addLine(to: CGPoint(x: size * 0.5, y: lineBottom))
    context.strokePath()
    
    // Right line
    context.move(to: CGPoint(x: size * 0.59, y: lineTop))
    context.addLine(to: CGPoint(x: size * 0.575, y: lineBottom))
    context.strokePath()
    
    // Flying app icon
    context.saveGState()
    context.translateBy(x: size * 0.62, y: size * 0.68)
    context.rotate(by: -0.26)
    
    let appSize = size * 0.14
    let appRect = CGRect(x: 0, y: 0, width: appSize, height: appSize)
    let appPath = CGPath(roundedRect: appRect, cornerWidth: appSize * 0.22, cornerHeight: appSize * 0.22, transform: nil)
    
    context.setFillColor(CGColor(red: 0.29, green: 0.56, blue: 0.85, alpha: 0.9))
    context.setShadow(offset: CGSize(width: 0, height: -size * 0.005), blur: size * 0.01,
                      color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.2))
    context.addPath(appPath)
    context.fillPath()
    
    // Lines on app icon
    context.setShadow(offset: .zero, blur: 0, color: nil)
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.8))
    context.fill(CGRect(x: appSize * 0.18, y: appSize * 0.55, width: appSize * 0.64, height: appSize * 0.09))
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.6))
    context.fill(CGRect(x: appSize * 0.18, y: appSize * 0.40, width: appSize * 0.50, height: appSize * 0.09))
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.4))
    context.fill(CGRect(x: appSize * 0.18, y: appSize * 0.25, width: appSize * 0.36, height: appSize * 0.09))
    
    context.restoreGState()
    
    // Sparkles
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.85))
    context.fillEllipse(in: CGRect(x: size * 0.72, y: size * 0.64, width: size * 0.024, height: size * 0.024))
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.65))
    context.fillEllipse(in: CGRect(x: size * 0.77, y: size * 0.70, width: size * 0.016, height: size * 0.016))
    context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.5))
    context.fillEllipse(in: CGRect(x: size * 0.69, y: size * 0.72, width: size * 0.012, height: size * 0.012))
}

func generateIcon(size: Int, scale: Int) -> NSImage {
    let pixelSize = size * scale
    let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    
    image.lockFocus()
    if let context = NSGraphicsContext.current?.cgContext {
        drawIcon(in: context, size: CGFloat(pixelSize))
    }
    image.unlockFocus()
    
    return image
}

// Get script directory
let scriptPath = CommandLine.arguments[0]
let scriptURL = URL(fileURLWithPath: scriptPath)
let baseDir = scriptURL.deletingLastPathComponent()
let iconsetDir = baseDir.appendingPathComponent("icon.iconset")

// Create iconset directory
try? FileManager.default.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

// Generate all sizes
for item in sizes {
    let image = generateIcon(size: item.size, scale: item.scale)
    let pngData = image.tiffRepresentation.flatMap { NSBitmapImageRep(data: $0)?.representation(using: .png, properties: [:]) }
    
    if let data = pngData {
        let filename = "\(item.name).png"
        let filepath = iconsetDir.appendingPathComponent(filename)
        try? data.write(to: filepath)
        print("Generated: \(filename)")
    }
}

print("\nIconset created at: \(iconsetDir.path)")
print("\nRun this command to create .icns file:")
print("iconutil -c icns \(iconsetDir.path)")
