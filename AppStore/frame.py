#!/usr/bin/env python3
"""Turn the raw simulator captures (AppStore/screenshots/raw) into captioned App Store screenshots
(AppStore/screenshots/*.png, 1320x2868 for the 6.9" iPhone slot).

    python3 AppStore/frame.py

Needs Pillow and a bold monospaced font (DejaVu Sans Mono or Menlo)."""
import glob, os, sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1320, 2868
BG, GREEN, DIM = (3, 10, 5), (64, 255, 115), (47, 165, 82)
HERE = os.path.dirname(os.path.abspath(__file__))
CAPTIONS = {
    "send": (["TYPE A NOTE.", "SEND IT AS SOUND."], "Your iPhone screeches it like a dial-up modem."),
    "listen": (["THE OTHER PHONE", "HEARS IT."], "No internet. No Bluetooth. Just the air between."),
    "photo-send": (["PHOTOS TRAVEL TOO."], "Tiny, slow, and encrypted stripe by stripe."),
    "photo-receive": (["PAINTED IN", "FROM THE TOP."], "The way pictures loaded in 1996."),
    "locked": (["NO PASSPHRASE?", "JUST NOISE."], "AES-256, keyed by a phrase you share in person."),
    "help": (["A REAL MODEM", "IN YOUR POCKET."], "No account. No server. Nothing collected."),
}
FONTS = ["/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", "/System/Library/Fonts/Menlo.ttc",
         "/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf"]


def font(size):
    for f in FONTS:
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    sys.exit("no monospaced font found")


def fit(lines, width, biggest):
    size = biggest
    while size > 30 and max(font(size).getlength(l) for l in lines) > width:
        size -= 2
    return font(size)


def frame(raw, key, out):
    lines, sub = CAPTIONS[key]
    canvas = Image.new("RGB", (W, H), BG)
    # the headline, with a phosphor glow
    f = fit(lines, W - 180, 92)
    lh = int(f.size * 1.22)
    top = 140 if len(lines) == 2 else 140 + lh // 2
    glow = Image.new("RGB", (W, H), (0, 0, 0))
    g = ImageDraw.Draw(glow)
    for i, l in enumerate(lines):
        g.text((W / 2, top + i * lh), l, font=f, fill=GREEN, anchor="ma")
    canvas = Image.composite(Image.new("RGB", (W, H), GREEN), canvas,
                             glow.filter(ImageFilter.GaussianBlur(14)).convert("L").point(lambda v: int(v * 0.55)))
    d = ImageDraw.Draw(canvas)
    for i, l in enumerate(lines):
        d.text((W / 2, top + i * lh), l, font=f, fill=GREEN, anchor="ma")
    fs = fit([sub], W - 180, 40)
    d.text((W / 2, 140 + 2 * lh + 26), sub, font=fs, fill=DIM, anchor="ma")
    # scanlines over the caption, to match the app
    for y in range(0, 520, 6):
        d.line([(0, y), (W, y)], fill=(0, 0, 0), width=1)
    # the screenshot, scaled, rounded, outlined
    shot = Image.open(raw).convert("RGB")
    sw = 1056
    sh = round(shot.height * sw / shot.width)
    shot = shot.resize((sw, sh), Image.LANCZOS)
    x, y = (W - sw) // 2, H - sh - 70
    mask = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw - 1, sh - 1], radius=96, fill=255)
    halo = Image.new("L", (W, H), 0)
    ImageDraw.Draw(halo).rounded_rectangle([x - 8, y - 8, x + sw + 8, y + sh + 8], radius=104, fill=150)
    canvas = Image.composite(Image.new("RGB", (W, H), DIM), canvas, halo.filter(ImageFilter.GaussianBlur(30)))
    canvas.paste(shot, (x, y), mask)
    ImageDraw.Draw(canvas).rounded_rectangle([x - 3, y - 3, x + sw + 2, y + sh + 2], radius=99, outline=DIM, width=4)
    canvas.save(out, optimize=True)
    print(out, canvas.size)


if __name__ == "__main__":
    raws = sorted(glob.glob(os.path.join(HERE, "screenshots", "raw", "*.png")))
    if not raws:
        sys.exit("no raw screenshots in AppStore/screenshots/raw")
    for raw in raws:
        name = os.path.splitext(os.path.basename(raw))[0]          # e.g. 2-listen
        frame(raw, name.split("-", 1)[1], os.path.join(HERE, "screenshots", name + ".png"))
