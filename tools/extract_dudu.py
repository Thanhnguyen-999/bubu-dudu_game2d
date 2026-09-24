"""Extract clean animation frames from dudu-sprite-sheet.png.

Source: 1024x1024 reference poster.
 - Brown bear "Mochi": top panel, gray-blue background.
 - Panda: bottom panel, near-white/checkerboard background.
 - Baked-in text labels; irregular grid of poses.

Pipeline:
 1. Split into two panels at the black divider band (~y 500-575).
 2. Color-key each panel's background -> transparent.
 3. Connected-component labeling to find pose blobs.
 4. Filter blobs by size/aspect to drop text labels.
 5. Assign blobs to animation groups by row bands (from the poster layout).
 6. Crop each blob, trim, place centered on a uniform canvas.
 7. Export per animation as individual frames AND a debug overlay.
"""
import os
from collections import deque
from PIL import Image, ImageDraw

SRC = r"g:\project\bubu-dudu_game2d\assets\dudu-sprite-sheet.png"
OUT = r"g:\project\bubu-dudu_game2d\assets\characters"
DEBUG = r"g:\project\bubu-dudu_game2d\tools\_debug"

img = Image.open(SRC).convert("RGB")
W, H = img.size
px = img.load()


def is_bg(rgb, panel):
    r, g, b = rgb
    if panel == "top":
        if abs(r - 210) < 24 and abs(g - 215) < 24 and abs(b - 220) < 26:
            return True
        if r < 14 and g < 14 and b < 14:
            return True
        return False
    else:
        if r > 196 and g > 200 and b > 204:
            return True
        if r < 14 and g < 14 and b < 14:
            return True
        return False


def build_mask(y0, y1, panel):
    h = y1 - y0
    mask = [[False] * W for _ in range(h)]
    for yy in range(h):
        y = y0 + yy
        row = mask[yy]
        for x in range(W):
            if not is_bg(px[x, y], panel):
                row[x] = True
    return mask, W, h


def components(mask, w, h, min_pixels):
    seen = [[False] * w for _ in range(h)]
    boxes = []
    for sy in range(h):
        for sx in range(w):
            if mask[sy][sx] and not seen[sy][sx]:
                q = deque([(sx, sy)])
                seen[sy][sx] = True
                minx = maxx = sx
                miny = maxy = sy
                count = 0
                while q:
                    cx, cy = q.popleft()
                    count += 1
                    if cx < minx: minx = cx
                    if cx > maxx: maxx = cx
                    if cy < miny: miny = cy
                    if cy > maxy: maxy = cy
                    for dx, dy in ((1,0),(-1,0),(0,1),(0,-1),(1,1),(1,-1),(-1,1),(-1,-1)):
                        nx, ny = cx+dx, cy+dy
                        if 0 <= nx < w and 0 <= ny < h and mask[ny][nx] and not seen[ny][nx]:
                            seen[ny][nx] = True
                            q.append((nx, ny))
                bw, bh = maxx-minx+1, maxy-miny+1
                # drop thin text labels: labels are wide-short or tiny
                if count >= min_pixels and bh >= 40 and bw >= 30:
                    boxes.append((minx, miny, maxx, maxy, count))
    return boxes


def is_label_pixel(rgb):
    """Labels are dark grayscale text (R~=G~=B, fairly dark).
    The bear art is either warm/brown or has colored/black outlines that
    are NOT neutral-gray-medium. We only strip medium-gray text pixels.
    """
    r, g, b = rgb
    mx, mn = max(r, g, b), min(r, g, b)
    # near-neutral (low saturation) AND not-too-bright -> treat as text
    if (mx - mn) <= 16 and 55 <= mx <= 195:
        return True
    return False


def is_fringe(rgb):
    """Light-gray/near-white low-saturation anti-alias fringe from the poster
    background. Bright and near-neutral. The bear's warm highlights are also
    bright but sit INSIDE the dark outline, so we only remove fringe that is
    reachable from the crop border via flood fill (see make_transparent)."""
    r, g, b = rgb
    mx, mn = max(r, g, b), min(r, g, b)
    return mx >= 196 and (mx - mn) <= 24


def make_transparent(box, y0, panel, clip_top=None, strip_labels=False):
    minx, miny, maxx, maxy, _ = box
    if clip_top is not None:
        # clip_top is absolute image y; skip rows above it
        local_clip = clip_top - y0 - miny
        if local_clip > 0:
            miny += local_clip
    bw, bh = maxx-minx+1, maxy-miny+1

    # 1) Classify pixels: keep = foreground candidate.
    keep = [[False] * bw for _ in range(bh)]
    rgb_at = [[(0, 0, 0)] * bw for _ in range(bh)]
    for yy in range(bh):
        y = y0 + miny + yy
        for xx in range(bw):
            x = minx + xx
            rgb = px[x, y]
            rgb_at[yy][xx] = rgb
            if is_bg(rgb, panel):
                continue
            if strip_labels and is_label_pixel(rgb):
                continue
            keep[yy][xx] = True

    # 2) Flood-fill "background-ish" from the border to erase the light fringe
    #    that hugs the bear's silhouette, without touching interior highlights
    #    (which are walled off by the bear's dark outline).
    bgish = [[False] * bw for _ in range(bh)]
    q = deque()
    for xx in range(bw):
        for yy in (0, bh - 1):
            q.append((xx, yy))
    for yy in range(bh):
        for xx in (0, bw - 1):
            q.append((xx, yy))
    while q:
        cx, cy = q.popleft()
        if cx < 0 or cy < 0 or cx >= bw or cy >= bh or bgish[cy][cx]:
            continue
        rgb = rgb_at[cy][cx]
        if not (is_bg(rgb, panel) or is_fringe(rgb) or (strip_labels and is_label_pixel(rgb))):
            continue
        bgish[cy][cx] = True
        q.append((cx + 1, cy)); q.append((cx - 1, cy))
        q.append((cx, cy + 1)); q.append((cx, cy - 1))

    out = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    op = out.load()
    for yy in range(bh):
        for xx in range(bw):
            if keep[yy][xx] and not bgish[yy][xx]:
                r, g, b = rgb_at[yy][xx]
                op[xx, yy] = (r, g, b, 255)
    return out


def debug_overlay(name, y0, y1, panel, boxes):
    os.makedirs(DEBUG, exist_ok=True)
    crop = img.crop((0, y0, W, y1)).convert("RGB")
    d = ImageDraw.Draw(crop)
    for i, b in enumerate(boxes):
        minx, miny, maxx, maxy, _ = b
        d.rectangle([minx, miny, maxx, maxy], outline=(255, 0, 0), width=2)
        d.text((minx + 2, miny + 2), str(i), fill=(255, 0, 0))
    crop.save(os.path.join(DEBUG, "overlay_%s.png" % name))


def process(name, y0, y1, panel, min_px):
    mask, w, h = build_mask(y0, y1, panel)
    boxes = components(mask, w, h, min_px)
    boxes.sort(key=lambda b: (b[1], b[0]))
    debug_overlay(name, y0, y1, panel, boxes)
    print("=== %s: %d blobs ===" % (name, len(boxes)))
    for i, b in enumerate(boxes):
        minx, miny, maxx, maxy, cnt = b
        print("  [%2d] x=%4d..%4d y=%4d..%4d w=%3d h=%3d" % (
            i, minx, maxx, miny + y0, maxy + y0, maxx-minx+1, maxy-miny+1))
    return boxes, mask


def trim(im):
    """Trim fully-transparent border of an RGBA image."""
    bbox = im.getbbox()
    return im.crop(bbox) if bbox else im


def export_group(char, anim, boxes, indices, y0, panel, canvas, clip_top=None):
    """Crop each blob (by index), trim, center on a uniform canvas, save."""
    dest = os.path.join(OUT, char, anim)
    os.makedirs(dest, exist_ok=True)
    cw, ch = canvas
    n = 0
    for order, idx in enumerate(indices):
        b = boxes[idx]
        # Labels sit above the FIRST frame of a labeled row only. Clip just it.
        this_clip = clip_top if (clip_top is not None and order == 0) else None
        cut = trim(make_transparent(b, y0, panel, clip_top=this_clip, strip_labels=True))
        frame = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        # center horizontally, align to bottom (feet on ground)
        ox = (cw - cut.width) // 2
        oy = ch - cut.height
        if ox < 0 or oy < 0:
            # scale down if a pose is larger than the canvas
            cut.thumbnail((cw, ch))
            ox = (cw - cut.width) // 2
            oy = ch - cut.height
        frame.alpha_composite(cut, (max(0, ox), max(0, oy)))
        frame.save(os.path.join(dest, "%02d.png" % order))
        n += 1
    print("  %s/%s : %d frames" % (char, anim, n))
    return n


# Animation -> blob indices (from verified debug overlay ordering).
BROWN_ANIMS = {
    "walk":   [0, 1, 2, 3, 4],
    "crouch": [5, 6, 7],
    "run":    [8, 9, 10, 11, 12],
    "lie":    [13, 14, 15],
    "attack": [16, 17, 18],
    "jump":   [19, 22, 20, 21],
    "shoot":  [23, 24, 25, 26],
}

# Panda: top walk row is fully clean (0-7); use it for idle+walk NPC loop.
PANDA_ANIMS = {
    "walk": [0, 1, 2, 3, 4, 5, 6, 7],
}


if __name__ == "__main__":
    bboxes, _ = process("brown", 0, 500, "top", 3000)
    pboxes, _ = process("panda", 576, 1024, "bottom", 1200)

    # Row top y (absolute) per brown animation to clip labels above the bears.
    # Clip the label band above the FIRST frame of each labeled row.
    BROWN_CLIP = {
        "walk": 73, "crouch": 95,
        "run": 196, "lie": 215,
        "attack": 300, "jump": 335,
        "shoot": 405,
    }
    print("\n--- Exporting Mochi (brown) frames ---")
    # Canvas sized to comfortably fit the tallest brown pose (~153px) + margin.
    for anim, idxs in BROWN_ANIMS.items():
        export_group("mochi", anim, bboxes, idxs, 0, "top", (140, 160),
                     clip_top=BROWN_CLIP.get(anim))

    print("\n--- Exporting Panda frames ---")
    for anim, idxs in PANDA_ANIMS.items():
        export_group("panda", anim, pboxes, idxs, 576, "bottom", (100, 120),
                     clip_top=581)

    print("\nDone. Frames under assets/characters/")
