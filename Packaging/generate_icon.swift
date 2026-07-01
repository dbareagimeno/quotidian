// Generates the Quotidian app icon (1024x1024 PNG) with AppKit — no Xcode /
// design tools needed. Two gauge bars (echoing the menu bar icon) on a
// rounded-rect gradient. Usage: swift generate_icon.swift <output.png>
import AppKit

let size = 1024.0
guard CommandLine.arguments.count > 1 else {
    FileHandle.standardError.write("usage: swift generate_icon.swift <output.png>\n".data(using: .utf8)!)
    exit(1)
}
let outPath = CommandLine.arguments[1]

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size),
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext
ctx.clear(CGRect(x: 0, y: 0, width: size, height: size))

// --- Rounded-rect (squircle) background with gradient ---
let inset = 96.0
let bgRect = CGRect(x: inset, y: inset, width: size - 2 * inset, height: size - 2 * inset)
let bgRadius = 190.0
let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: bgRadius, yRadius: bgRadius)

NSGraphicsContext.saveGraphicsState()
bgPath.addClip()
let top = NSColor(calibratedRed: 0.55, green: 0.44, blue: 0.98, alpha: 1.0)     // violet
let bottom = NSColor(calibratedRed: 0.28, green: 0.20, blue: 0.66, alpha: 1.0)  // indigo
NSGradient(starting: top, ending: bottom)!.draw(in: bgRect, angle: -90)
// subtle top sheen
let sheen = NSGradient(colors: [NSColor.white.withAlphaComponent(0.18), NSColor.white.withAlphaComponent(0.0)])!
sheen.draw(in: CGRect(x: bgRect.minX, y: bgRect.midY, width: bgRect.width, height: bgRect.height / 2), angle: -90)
NSGraphicsContext.restoreGraphicsState()

// --- Two gauge bars ---
let barW = 168.0
let gap = 92.0
let groupW = barW * 2 + gap
let startX = (size - groupW) / 2
let barH = 486.0
let barY = (size - barH) / 2
let barRadius = 66.0

func drawBar(x: Double, fillFraction: Double) {
    let trackRect = CGRect(x: x, y: barY, width: barW, height: barH)
    NSColor.white.withAlphaComponent(0.24).setFill()
    NSBezierPath(roundedRect: trackRect, xRadius: barRadius, yRadius: barRadius).fill()

    let fh = max(barH * fillFraction, barW) // never shorter than a full pill
    let fillRect = CGRect(x: x, y: barY, width: barW, height: fh)
    NSColor.white.withAlphaComponent(0.96).setFill()
    NSBezierPath(roundedRect: fillRect, xRadius: barRadius, yRadius: barRadius).fill()
}

drawBar(x: startX, fillFraction: 0.42)              // "5h" bar
drawBar(x: startX + barW + gap, fillFraction: 0.72) // "weekly" bar

NSGraphicsContext.restoreGraphicsState()

guard let data = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("failed to encode PNG\n".data(using: .utf8)!)
    exit(1)
}
try! data.write(to: URL(fileURLWithPath: outPath))
print("wrote \(outPath)")
