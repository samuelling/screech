#if DEBUG
import SwiftUI
import UIKit

/// Debug builds only. Launching with `-screenshot <scene>` stages the app for an App Store screenshot
/// (see .github/workflows/screenshots.yml). None of this is compiled into the Release build.
enum Screenshots {
    static let scene: String? = {
        let a = ProcessInfo.processInfo.arguments
        guard let i = a.firstIndex(of: "-screenshot"), i + 1 < a.count else { return nil }
        return a[i + 1]
    }()
    static var listenFirst: Bool { ["listen", "photo-receive", "locked"].contains(scene ?? "") }
    static var helpFirst: Bool { scene == "help" }

    static let pass = "owl banjo comet 41"
    static let secret = "The cookies are hidden behind the encyclopedias, top shelf. Tell no one."

    @MainActor static func apply(to m: ScreechModel) {
        guard let scene else { return }
        switch scene {
        case "send":
            m.passphrase = pass
            m.message = secret
        case "listen":
            m.passphrase = pass
            m.listening = true; m.carrier = true; m.receiveProgress = 0.62; m.levelDb = -17
            m.waterfall = tones()
            m.received = [note(.secret(secret), .sturdy, 40), note(.open("testing, testing. is this thing on?"), .classic, 37)]
            m.status = "RECEIVING A SECRET NOTE…"
        case "photo-send":
            m.passphrase = pass
            m.sendKind = .photo; m.mode = .quick; m.photoSize = "large"
            m.photoSource = postcard()
            Task { @MainActor in
                for _ in 0..<80 where m.outgoing == nil { try? await Task.sleep(nanoseconds: 100_000_000) }
                guard let o = m.outgoing else { return }
                m.sending = true
                m.sendRevealRows = o.encoded.h * 5 / 8
                m.status = "SENDING PHOTO · QUICK · \(Int(m.photoAirtime + 0.5)) S"
            }
        case "photo-receive":
            m.passphrase = pass
            m.listening = true; m.carrier = true; m.levelDb = -15
            m.waterfall = tones()
            let img = postcard()
            let (w, h) = PhotoCodec.fitSize(Int(img.size.width), Int(img.size.height), longest: 128)
            let enc = PhotoCodec.encode(rgba: PixelImage.rgba(from: img, w: w, h: h), w: w, h: h, quality: 35)
            var out = [UInt8](repeating: 0, count: w * h * 4)
            let k = enc.bands.count * 5 / 8
            for i in 0..<k { PhotoCodec.decodeBand(enc.bands[i], band: i, w: w, h: h, quality: 35, gray: false, into: &out) }
            var p = ReceivedPhoto(id: 1)
            p.date = at(40); p.mode = "quick"; p.w = w; p.h = h; p.bands = enc.bands.count
            p.got = k; p.next = k; p.status = .receiving; p.encrypted = true
            p.image = PixelImage.cgImage(rgba: out, w: w, h: h)
            m.photos = [p]; m.incomingPhotoFraction = 0.45
            m.received = [note(.secret("Sending you the view from here."), .quick, 39)]
            m.status = "RECEIVING PHOTO… STRIPE \(k + 1) OF \(enc.bands.count)"
        case "locked":
            m.listening = true; m.levelDb = -52
            m.waterfall = tones(tail: true)
            var p = ReceivedPhoto(id: 1)
            p.date = at(38); p.mode = "quick"; p.status = .locked; p.encrypted = true
            m.photos = [p]
            m.received = [note(.locked, .sturdy, 40)]
            m.status = "🔒 SECRET NOTE. ENTER THE PASSPHRASE TO READ IT."
        default: break
        }
    }

    /// today at 9:<minute>, to sit with the simulator's 9:41 status bar
    static func at(_ minute: Int) -> Date { Calendar.current.date(bySettingHour: 9, minute: minute, second: 0, of: Date()) ?? Date() }

    static func note(_ s: NoteStatus, _ mode: NoteMode, _ minute: Int) -> ReceivedNote {
        var flags = NoteFlag.encrypted
        if case .open = s { flags = 0 }
        return ReceivedNote(date: at(minute), mode: mode, source: "mic", flags: flags, bytes: [], status: s)
    }

    /// a real note, rendered and run through the app's own analyzer, so the line monitor shows what it really shows
    static func tones(tail: Bool = false) -> Waterfall {
        var wf = Waterfall(bands: 48, rows: 90)
        let text = "Meet at the usual place when the streetlights come on. Bring the map, the flashlight and the good snacks. If you are followed, whistle twice and keep walking."
        guard let packed = try? NoteCrypto.pack(text: text, passphrase: "", modeId: NoteMode.sturdy.id) else { return wf }
        var s = NoteSynth.render(payload: packed.payload, flags: packed.flags, mode: .sturdy, sampleRate: 48000, amplitude: 0.2, intro: false)
        if tail { s += [Float](repeating: 0, count: 48000 * 2) }
        var seed: UInt32 = 12345                                    // a little room noise
        for i in s.indices { seed = seed &* 1664525 &+ 1013904223; s[i] += (Float(seed >> 8) / Float(1 << 24) - 0.5) * 0.004 }
        let rows = SpectrumAnalyzer(sampleRate: 48000).process(s).rows
        let start = tail ? max(0, rows.count - 90) : max(0, min(rows.count - 90, rows.count / 3))
        for r in rows.dropFirst(start).prefix(90) { wf.push(r) }
        return wf
    }

    /// a drawn postcard (dusk over a lake, a sailboat), so no real photo is needed
    static func postcard() -> UIImage {
        let W: CGFloat = 640, H: CGFloat = 480, horizon: CGFloat = 300
        let fmt = UIGraphicsImageRendererFormat(); fmt.scale = 1; fmt.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: W, height: H), format: fmt).image { r in
            let c = r.cgContext
            let rgb = CGColorSpaceCreateDeviceRGB()
            func col(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor { CGColor(colorSpace: rgb, components: [r, g, b, a])! }
            func gradient(_ colors: [CGColor], _ stops: [CGFloat], from y0: CGFloat, to y1: CGFloat) {
                guard let g = CGGradient(colorsSpace: rgb, colors: colors as CFArray, locations: stops) else { return }
                c.saveGState(); c.clip(to: CGRect(x: 0, y: y0, width: W, height: y1 - y0))
                c.drawLinearGradient(g, start: CGPoint(x: 0, y: y0), end: CGPoint(x: 0, y: y1), options: [])
                c.restoreGState()
            }
            // sky
            gradient([col(0.09, 0.07, 0.30), col(0.48, 0.18, 0.50), col(0.95, 0.38, 0.38), col(1.0, 0.70, 0.30)], [0, 0.45, 0.8, 1], from: 0, to: horizon)
            // stars
            var seed: UInt32 = 7
            func rnd() -> CGFloat { seed = seed &* 1664525 &+ 1013904223; return CGFloat(seed >> 8) / CGFloat(1 << 24) }
            c.setFillColor(col(1, 1, 0.9, 0.9))
            for _ in 0..<26 { let x = rnd() * W, y = rnd() * 120; c.fill(CGRect(x: x, y: y, width: 4, height: 4)) }
            // sun
            c.setFillColor(col(1.0, 0.93, 0.62))
            c.fillEllipse(in: CGRect(x: 395, y: 205, width: 130, height: 130))
            // far hills
            c.setFillColor(col(0.22, 0.10, 0.34))
            c.beginPath(); c.move(to: CGPoint(x: 0, y: horizon))
            for (x, y) in [(0, 250), (70, 222), (150, 262), (230, 236), (320, 276), (400, 290), (500, 268), (570, 244), (640, 262), (640, 300)] as [(CGFloat, CGFloat)] { c.addLine(to: CGPoint(x: x, y: y)) }
            c.closePath(); c.fillPath()
            // water
            gradient([col(0.98, 0.56, 0.30), col(0.42, 0.20, 0.48), col(0.06, 0.08, 0.26)], [0, 0.35, 1], from: horizon, to: H)
            // the sun on the water
            c.setFillColor(col(1.0, 0.90, 0.60, 0.85))
            var y = horizon + 8, w: CGFloat = 120
            while y < H - 20 { c.fill(CGRect(x: 460 - w / 2 + (rnd() - 0.5) * 30, y: y, width: w, height: 7)); y += 18; w *= 0.84 }
            // sailboat
            c.setFillColor(col(0.07, 0.05, 0.14))
            c.beginPath(); c.move(to: CGPoint(x: 150, y: 352)); c.addLine(to: CGPoint(x: 270, y: 352)); c.addLine(to: CGPoint(x: 250, y: 374)); c.addLine(to: CGPoint(x: 166, y: 374)); c.closePath(); c.fillPath()
            c.fill(CGRect(x: 206, y: 228, width: 5, height: 126))
            c.setFillColor(col(0.98, 0.96, 0.90))
            c.beginPath(); c.move(to: CGPoint(x: 214, y: 232)); c.addLine(to: CGPoint(x: 214, y: 342)); c.addLine(to: CGPoint(x: 276, y: 342)); c.closePath(); c.fillPath()
            c.setFillColor(col(1.0, 0.45, 0.35))
            c.beginPath(); c.move(to: CGPoint(x: 202, y: 250)); c.addLine(to: CGPoint(x: 202, y: 342)); c.addLine(to: CGPoint(x: 160, y: 342)); c.closePath(); c.fillPath()
            // near shore and pines
            c.setFillColor(col(0.04, 0.03, 0.10))
            c.beginPath(); c.move(to: CGPoint(x: 0, y: H)); c.addLine(to: CGPoint(x: 0, y: 420)); c.addQuadCurve(to: CGPoint(x: 250, y: H), control: CGPoint(x: 150, y: 420)); c.closePath(); c.fillPath()
            for (x, top) in [(28, 250), (78, 300), (120, 345)] as [(CGFloat, CGFloat)] {
                c.fill(CGRect(x: x - 3, y: top, width: 6, height: 440 - top))
                var ty = top, half: CGFloat = 12
                while ty < 420 { c.beginPath(); c.move(to: CGPoint(x: x, y: ty)); c.addLine(to: CGPoint(x: x - half, y: ty + 34)); c.addLine(to: CGPoint(x: x + half, y: ty + 34)); c.closePath(); c.fillPath(); ty += 22; half += 5 }
            }
        }
    }
}
#endif
