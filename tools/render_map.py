"""Render a scene's TileMapLayers to a PNG, outside Godot.

A quick way to look at a floor plan while designing it: composites every
TileMapLayer in scene order, then (optionally) overlays the Collision layer,
the Openings layer, the RoomZones, the room labels, and every placed prop
(chore spots, mess props, desk, bed, doors).

Usage:
    python tools/render_map.py                          # ranch_interior -> map.png
    python tools/render_map.py -o out.png --scale 3
    python tools/render_map.py --no-overlay             # just the art
    python tools/render_map.py --grid                   # tile grid + coordinates

Needs Pillow.
"""

import argparse
import base64
import os
import re
import struct

from PIL import Image, ImageDraw, ImageFont

DEFAULT_SCENE = "scenes/world/ranch_interior.tscn"
TILE = 16
REC = "<hhHHHH"                 # cell_x, cell_y, source_id, atlas_x, atlas_y, alternative
REC_SIZE = struct.calcsize(REC)

# Layers that are data, not art: drawn as overlays instead of composited.
DATA_LAYERS = {"Collision", "Openings"}

PROP_COLORS = {                 # by instanced scene file name
    "chore_spot": (255, 200, 0),
    "mess_prop": (255, 120, 60),
    "desk": (80, 200, 255),
    "bed": (200, 120, 255),
    "door": (80, 255, 120),
    "player": (255, 255, 255),
}
ZONE_COLORS = [(90, 170, 255), (255, 120, 200), (120, 255, 160), (255, 220, 90),
               (190, 140, 255), (90, 230, 230), (255, 160, 90)]

RE_VEC = r'Vector2\(([-\d.e]+), ([-\d.e]+)\)'


def res_path(root, res):
    return os.path.join(root, res.replace("res://", "").replace("/", os.sep))


def decode(b64):
    body = base64.b64decode(b64)[2:]
    return [struct.unpack(REC, body[i:i + REC_SIZE]) for i in range(0, len(body), REC_SIZE)]


def node_blocks(src):
    """Yield (header_attrs, body) for each [node ...] block."""
    heads = list(re.finditer(r'(?m)^\[node ([^\]]*)\]$', src))
    for i, h in enumerate(heads):
        end = heads[i + 1].start() if i + 1 < len(heads) else len(src)
        yield dict(re.findall(r'(\w+)=("[^"]*"|\S+)', h.group(1))), src[h.end():end]


def unq(v):
    return v.strip('"') if v else v


def vec(body, prop):
    m = re.search(r'(?m)^%s = %s' % (prop, RE_VEC), body)
    return (float(m.group(1)), float(m.group(2))) if m else (0.0, 0.0)


def load_tileset(root, tres_res):
    text = open(res_path(root, tres_res), encoding="utf-8").read()
    ext = {m.group(2): m.group(1) for m in re.finditer(
        r'\[ext_resource type="Texture2D"[^\]]*path="([^"]+)" id="([^"]+)"\]', text)}
    sub_tex = {}
    for m in re.finditer(r'\[sub_resource type="TileSetAtlasSource" id="([^"]+)"\]\ntexture = ExtResource\("([^"]+)"\)', text):
        sub_tex[m.group(1)] = ext[m.group(2)]
    sources = {}
    for m in re.finditer(r'sources/(\d+) = SubResource\("([^"]+)"\)', text):
        sources[int(m.group(1))] = Image.open(res_path(root, sub_tex[m.group(2)])).convert("RGBA")
    return sources


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("scene", nargs="?", default=DEFAULT_SCENE)
    ap.add_argument("-o", "--out", default="map.png")
    ap.add_argument("--scale", type=int, default=2)
    ap.add_argument("--no-overlay", action="store_true")
    ap.add_argument("--grid", action="store_true")
    args = ap.parse_args()

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    scene = args.scene if os.path.isabs(args.scene) else os.path.join(root, args.scene)
    src = open(scene, encoding="utf-8").read()

    ext = {m.group(2): m.group(1) for m in re.finditer(
        r'\[ext_resource type="[^"]+"[^\]]*path="([^"]+)" id="([^"]+)"\]', src)}
    rect_sizes = {m.group(1): (float(m.group(2)), float(m.group(3))) for m in re.finditer(
        r'\[sub_resource type="RectangleShape2D" id="([^"]+)"\]\nsize = ' + RE_VEC, src)}

    layers, data_layers, labels, props, zones = [], {}, [], [], []
    zone_info = {}                      # "RoomZones/Name" -> (position, room_id)
    tilesets = {}
    for attrs, body in node_blocks(src):
        name = unq(attrs.get("name"))
        typ = unq(attrs.get("type"))
        parent = unq(attrs.get("parent", ""))
        if typ == "TileMapLayer":
            ts = re.search(r'tile_set = ExtResource\("([^"]+)"\)', body)
            data = re.search(r'tile_map_data = PackedByteArray\("([^"]*)"\)', body)
            cells = decode(data.group(1)) if data else []
            if name in DATA_LAYERS:
                data_layers[name] = cells
            elif ts and cells:
                tres = ext[ts.group(1)]
                tilesets.setdefault(tres, None)
                layers.append((tres, cells))
        elif typ == "Label":
            l = re.search(r'offset_left = ([-\d.]+)', body)
            t = re.search(r'offset_top = ([-\d.]+)', body)
            text = re.search(r'text = "([^"]*)"', body)
            labels.append((float(l.group(1)) if l else 0.0, float(t.group(1)) if t else 0.0,
                           text.group(1) if text else name))
        elif typ == "Area2D" and (parent == "RoomZones" or parent.endswith("/RoomZones")):
            rid = re.search(r'room_id = &"([^"]+)"', body)
            zone_info[parent + "/" + name] = (vec(body, "position"), rid.group(1) if rid else name)
        elif typ == "CollisionShape2D" and parent in zone_info:
            shp = re.search(r'shape = SubResource\("([^"]+)"\)', body)
            if shp and shp.group(1) in rect_sizes:
                (zx, zy), rid = zone_info[parent]
                cx, cy = vec(body, "position")
                w, h = rect_sizes[shp.group(1)]
                zones.append((rid, (zx + cx - w / 2, zy + cy - h / 2, zx + cx + w / 2, zy + cy + h / 2)))
        elif "instance" in attrs:
            inst = re.search(r'ExtResource\("([^"]+)"\)', attrs["instance"]).group(1)
            kind = os.path.splitext(os.path.basename(ext.get(inst, inst)))[0]
            if re.search(r'(?m)^position = ', body):
                px, py = vec(body, "position")
                if parent == "World/Mess" or parent.startswith("World/Mess/"):
                    pass            # mess props sit directly under World/Mess
                tag = name
                chore = re.search(r'only_chore = &"([^"]+)"', body)
                room = re.search(r'(?m)^room = &"([^"]+)"', body)
                thr = re.search(r'threshold = (\d+)', body)
                meas = re.search(r'measure = (\d+)', body)
                if chore:
                    tag += " -> " + chore.group(1)
                if room:
                    tag += " [" + room.group(1) + "]"
                if kind == "mess_prop":
                    m_name = "grime" if meas and meas.group(1) == "0" else "clutter"
                    tag += " (%s>=%s)" % (m_name, thr.group(1) if thr else "1")
                props.append((tag, kind, px, py))

    for tres in tilesets:
        tilesets[tres] = load_tileset(root, tres)

    all_cells = [c for _, cells in layers for c in cells]
    minx = min(c[0] for c in all_cells); maxx = max(c[0] for c in all_cells)
    miny = min(c[1] for c in all_cells); maxy = max(c[1] for c in all_cells)
    w, h = (maxx - minx + 1) * TILE, (maxy - miny + 1) * TILE
    ox, oy = -minx * TILE, -miny * TILE

    img = Image.new("RGBA", (w, h), (20, 20, 24, 255))
    for tres, cells in layers:
        srcs = tilesets[tres]
        for cx, cy, sid, ax, ay, _alt in cells:
            atlas = srcs.get(sid)
            if atlas is None:
                continue
            tile = atlas.crop((ax * TILE, ay * TILE, ax * TILE + TILE, ay * TILE + TILE))
            img.alpha_composite(tile, (cx * TILE + ox, cy * TILE + oy))

    s = args.scale
    img = img.resize((w * s, h * s), Image.NEAREST)
    font = ImageFont.load_default()

    if not args.no_overlay:
        over = Image.new("RGBA", img.size, (0, 0, 0, 0))
        d = ImageDraw.Draw(over)

        def cell_box(cx, cy):
            x0, y0 = (cx * TILE + ox) * s, (cy * TILE + oy) * s
            return (x0, y0, x0 + TILE * s - 1, y0 + TILE * s - 1)

        for cx, cy, *_ in data_layers.get("Collision", []):
            d.rectangle(cell_box(cx, cy), fill=(255, 0, 0, 70), outline=(255, 60, 60, 160))
        for cx, cy, *_ in data_layers.get("Openings", []):
            d.rectangle(cell_box(cx, cy), fill=(0, 255, 90, 110), outline=(0, 255, 90, 255), width=2)

        zone_ids = sorted({z for z, _ in zones})
        for zid, (x0, y0, x1, y1) in zones:
            col = ZONE_COLORS[zone_ids.index(zid) % len(ZONE_COLORS)]
            box = ((x0 + ox) * s, (y0 + oy) * s, (x1 + ox) * s - 1, (y1 + oy) * s - 1)
            d.rectangle(box, fill=col + (22,), outline=col + (220,), width=2)
            d.text((box[0] + 4, box[3] - 14), "zone: " + zid, fill=col + (255,), font=font)

        if args.grid:
            for gx in range(minx, maxx + 2):
                X = (gx * TILE + ox) * s
                d.line((X, 0, X, img.height), fill=(255, 255, 255, 30))
                if gx <= maxx:
                    d.text((X + 2, 2), str(gx), fill=(255, 255, 255, 160), font=font)
            for gy in range(miny, maxy + 2):
                Y = (gy * TILE + oy) * s
                d.line((0, Y, img.width, Y), fill=(255, 255, 255, 30))
                if gy <= maxy:
                    d.text((2, Y + 2), str(gy), fill=(255, 255, 255, 160), font=font)

        for lx, ly, text in labels:
            X, Y = (lx + ox) * s, (ly + oy) * s
            d.rectangle((X - 2, Y - 2, X + len(text) * 6 + 2, Y + 11), fill=(0, 0, 0, 170))
            d.text((X, Y), text, fill=(255, 255, 160, 255), font=font)

        for tag, kind, px, py in props:
            col = PROP_COLORS.get(kind, (255, 255, 255))
            X, Y = (px + ox) * s, (py + oy) * s
            r = 4 if kind == "mess_prop" else 6
            d.ellipse((X - r, Y - r, X + r, Y + r), fill=col + (230,), outline=(0, 0, 0, 255))
            if kind != "mess_prop":
                d.rectangle((X + 8, Y - 6, X + 10 + len(tag) * 6, Y + 6), fill=(0, 0, 0, 180))
                d.text((X + 9, Y - 5), tag, fill=col + (255,), font=font)
        img = Image.alpha_composite(img, over)

    out = args.out if os.path.isabs(args.out) else os.path.join(os.getcwd(), args.out)
    img.save(out)
    print(f"wrote {out}  ({maxx - minx + 1}x{maxy - miny + 1} tiles, cells x {minx}..{maxx}, y {miny}..{maxy})")


if __name__ == "__main__":
    main()
