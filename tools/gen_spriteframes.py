"""Generate Godot 4 SpriteFrames .tres files for Mochi and Panda from the
extracted per-frame PNGs under assets/characters/<char>/<anim>/NN.png.

References textures by res:// path via ext_resource (no uid needed; Godot
backfills uids on first load). This avoids needing a headless import pass.
"""
import os

ROOT = r"g:\project\bubu-dudu_game2d"
CHARS_DIR = os.path.join(ROOT, "assets", "characters")
OUT_DIR = os.path.join(ROOT, "data", "characters")

# animation -> (fps, loop)
MOCHI_ANIMS = {
    "idle":   ("walk", 6, True),    # reuse walk frames slow as idle
    "walk":   ("walk", 10, True),
    "run":    ("run", 14, True),
    "jump":   ("jump", 10, False),
    "crouch": ("crouch", 8, True),
    "lie":    ("lie", 6, True),
    "attack": ("attack", 14, False),
    "shoot":  ("shoot", 14, False),
}

PANDA_ANIMS = {
    "idle": ("walk", 5, True),
    "walk": ("walk", 9, True),
}


def list_frames(char, folder):
    d = os.path.join(CHARS_DIR, char, folder)
    if not os.path.isdir(d):
        return []
    files = sorted(f for f in os.listdir(d) if f.endswith(".png"))
    return ["res://assets/characters/%s/%s/%s" % (char, folder, f) for f in files]


def build_tres(char, anims):
    # Collect unique source folders -> ext_resource ids
    # Each frame PNG is a separate ext_resource.
    ext_lines = []
    frame_paths = {}  # path -> id
    next_id = 1

    # Gather all paths in a stable order
    ordered_paths = []
    anim_frames = {}
    for anim, (folder, fps, loop) in anims.items():
        paths = list_frames(char, folder)
        anim_frames[anim] = (paths, fps, loop)
        for p in paths:
            if p not in frame_paths:
                frame_paths[p] = next_id
                ordered_paths.append(p)
                next_id += 1

    load_steps = len(ordered_paths) + 1
    lines = []
    lines.append('[gd_resource type="SpriteFrames" load_steps=%d format=3]' % load_steps)
    lines.append("")
    for p in ordered_paths:
        rid = frame_paths[p]
        lines.append('[ext_resource type="Texture2D" path="%s" id="%d"]' % (p, rid))
    lines.append("")
    lines.append("[resource]")
    lines.append("animations = [")
    for anim, (paths, fps, loop) in anim_frames.items():
        if not paths:
            continue
        lines.append("{")
        lines.append('"frames": [')
        for p in paths:
            rid = frame_paths[p]
            lines.append('{')
            lines.append('"duration": 1.0,')
            lines.append('"texture": ExtResource("%d")' % rid)
            lines.append('}, ')
        lines.append("],")
        lines.append('"loop": %s,' % ("true" if loop else "false"))
        lines.append('"name": &"%s",' % anim)
        lines.append('"speed": %s' % float(fps))
        lines.append("}, ")
    lines.append("]")
    lines.append("")
    return "\n".join(lines)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for char, anims in (("mochi", MOCHI_ANIMS), ("panda", PANDA_ANIMS)):
        tres = build_tres(char, anims)
        out = os.path.join(OUT_DIR, "%s_frames.tres" % char)
        with open(out, "w", encoding="utf-8") as f:
            f.write(tres)
        print("Wrote", out)


if __name__ == "__main__":
    main()
