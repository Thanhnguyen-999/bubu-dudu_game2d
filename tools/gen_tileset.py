#!/usr/bin/env python3
"""Sinh tileset placeholder (PNG) không cần thư viện ngoài.

Tạo atlas 16x16 px mỗi tile, 4 tile trên 1 hàng:
  0: sàn đất (nâu)
  1: tường/đá (xám)
  2: sàn gỗ (nâu sáng)
  3: nền cỏ (xanh)
Xuất ra assets/tiles/placeholder_tileset.png
"""
import struct
import zlib
import os

TILE = 16
TILES = [
    (110, 78, 48),    # dirt
    (90, 94, 100),    # stone wall
    (150, 108, 62),   # wood floor
    (74, 124, 89),    # grass
]

def make_atlas():
    cols = len(TILES)
    width = TILE * cols
    height = TILE
    # mỗi pixel RGBA
    rows = []
    for y in range(height):
        row = bytearray()
        row.append(0)  # filter type 0
        for x in range(width):
            tile_index = x // TILE
            r, g, b = TILES[tile_index]
            # thêm chút viền tối để nhìn thấy ranh giới tile
            lx = x % TILE
            ly = y % TILE
            if lx == 0 or ly == 0:
                r = int(r * 0.8); g = int(g * 0.8); b = int(b * 0.8)
            row += bytes((r, g, b, 255))
        rows.append(bytes(row))
    raw = b"".join(rows)
    return width, height, raw

def png_chunk(tag, data):
    chunk = tag + data
    return struct.pack(">I", len(data)) + chunk + struct.pack(">I", zlib.crc32(chunk) & 0xffffffff)

def write_png(path, width, height, raw):
    sig = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)  # 8-bit RGBA
    idat = zlib.compress(raw, 9)
    with open(path, "wb") as f:
        f.write(sig)
        f.write(png_chunk(b"IHDR", ihdr))
        f.write(png_chunk(b"IDAT", idat))
        f.write(png_chunk(b"IEND", b""))

if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(here, "..", "assets", "tiles")
    os.makedirs(out_dir, exist_ok=True)
    w, h, raw = make_atlas()
    out = os.path.join(out_dir, "placeholder_tileset.png")
    write_png(out, w, h, raw)
    print("wrote", os.path.normpath(out), w, "x", h)
