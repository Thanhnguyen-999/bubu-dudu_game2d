#!/usr/bin/env python3
"""Sinh texture cánh hoa (petal) + đám mây nhỏ, PNG RGBA, không cần lib ngoài."""
import struct, zlib, os, math

def write_png(path, w, h, px):
    def chunk(tag, data):
        c = tag + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xffffffff)
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        raw += px[y * w * 4:(y + 1) * w * 4]
    out = b"\x89PNG\r\n\x1a\n"
    out += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    out += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    out += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(out)

def make_petal(size=24):
    w = h = size
    px = bytearray(w * h * 4)
    cx, cy = w / 2.0, h / 2.0
    # Cánh hoa: hình elip nghiêng, màu hồng phấn.
    rx, ry = size * 0.28, size * 0.46
    ang = math.radians(25)
    ca, sa = math.cos(ang), math.sin(ang)
    for y in range(h):
        for x in range(w):
            dx = x - cx
            dy = y - cy
            # xoay
            ux = dx * ca + dy * sa
            uy = -dx * sa + dy * ca
            d = (ux / rx) ** 2 + (uy / ry) ** 2
            i = (y * w + x) * 4
            if d <= 1.0:
                edge = 1.0 - max(0.0, d - 0.6) / 0.4  # feather mép
                a = int(max(0.0, min(1.0, edge)) * 235)
                # gradient hồng -> hồng nhạt
                t = (uy / ry + 1) / 2
                r = int(250 - 10 * t)
                g = int(190 + 25 * t)
                b = int(205 + 20 * t)
                px[i] = r; px[i+1] = g; px[i+2] = b; px[i+3] = a
    return w, h, px

def make_cloud(w=256, h=110):
    px = bytearray(w * h * 4)
    # Vài "bọt" tròn chồng nhau tạo mây trắng mềm.
    blobs = [(0.30, 0.62, 0.26), (0.5, 0.5, 0.34), (0.68, 0.62, 0.28), (0.42, 0.7, 0.22), (0.6, 0.72, 0.2)]
    for y in range(h):
        for x in range(w):
            fx, fy = x / w, y / h
            a = 0.0
            for bx, by, br in blobs:
                d = math.sqrt(((fx - bx) * (w / h)) ** 2 + (fy - by) ** 2)
                v = 1.0 - d / br
                if v > 0:
                    a = max(a, v)
            a = min(1.0, a)
            i = (y * w + x) * 4
            px[i] = 255; px[i+1] = 255; px[i+2] = 255
            px[i+3] = int(a * 170)
    return w, h, px

if __name__ == "__main__":
    out_dir = r"g:\project\bubu-dudu_game2d\assets\fx"
    os.makedirs(out_dir, exist_ok=True)
    w, h, px = make_petal(24)
    write_png(os.path.join(out_dir, "petal.png"), w, h, px)
    print("wrote petal.png", w, h)
    w, h, px = make_cloud()
    write_png(os.path.join(out_dir, "cloud.png"), w, h, px)
    print("wrote cloud.png", w, h)
