import struct, os

def dims(p):
    with open(p, "rb") as f:
        data = f.read()
    if data[:2] == b"\xff\xd8":
        i = 2
        n = len(data)
        while i < n:
            if data[i] != 0xFF:
                i += 1
                continue
            marker = data[i + 1]
            if marker in (0xC0, 0xC1, 0xC2, 0xC3):
                h = struct.unpack(">H", data[i + 5:i + 7])[0]
                w = struct.unpack(">H", data[i + 7:i + 9])[0]
                return (w, h)
            if i + 4 > n:
                break
            seglen = struct.unpack(">H", data[i + 2:i + 4])[0]
            i += 2 + seglen
        return None
    if data[:8] == b"\x89PNG\r\n\x1a\n":
        return struct.unpack(">II", data[16:24])
    return None

for name in ["thap.jpg", "gate.jpg"]:
    p = os.path.join(r"g:\project\bubu-dudu_game2d\assets", name)
    d = dims(p)
    sz = os.path.getsize(p)
    print("%s: %s  (%d KB)" % (name, d, sz // 1024))
