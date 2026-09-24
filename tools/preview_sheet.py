"""Assemble a contact sheet: each animation as a horizontal strip, stacked,
on a mid-gray background so transparency/edges are visible. For visual review.
"""
import os
from PIL import Image, ImageDraw

ROOT = r"g:\project\bubu-dudu_game2d\assets\characters"
OUT = r"g:\project\bubu-dudu_game2d\tools\_debug\preview.png"

chars = {
    "mochi": ["walk", "run", "jump", "crouch", "lie", "attack", "shoot"],
    "panda": ["walk"],
}

rows = []  # (label, [frame images])
for char, anims in chars.items():
    for anim in anims:
        d = os.path.join(ROOT, char, anim)
        if not os.path.isdir(d):
            continue
        files = sorted(f for f in os.listdir(d) if f.endswith(".png"))
        imgs = [Image.open(os.path.join(d, f)).convert("RGBA") for f in files]
        rows.append(("%s/%s" % (char, anim), imgs))

cell_w = max(max((im.width for im in imgs), default=0) for _, imgs in rows) + 6
cell_h = max(max((im.height for im in imgs), default=0) for _, imgs in rows) + 6
max_cols = max(len(imgs) for _, imgs in rows)
label_w = 110

sheet_w = label_w + max_cols * cell_w
sheet_h = len(rows) * cell_h
sheet = Image.new("RGBA", (sheet_w, sheet_h), (110, 115, 125, 255))
draw = ImageDraw.Draw(sheet)

y = 0
for label, imgs in rows:
    draw.text((6, y + cell_h // 2 - 6), label, fill=(255, 255, 255))
    x = label_w
    for im in imgs:
        ox = x + (cell_w - im.width) // 2
        oy = y + (cell_h - im.height) // 2
        sheet.alpha_composite(im, (ox, oy))
        draw.rectangle([x, y, x + cell_w - 1, y + cell_h - 1], outline=(70, 74, 82))
        x += cell_w
    y += cell_h

sheet.save(OUT)
print("Wrote", OUT, sheet.size)
