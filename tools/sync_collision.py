"""Regenerate a scene's Collision TileMapLayer from its Walls layer.

The tileset deliberately carries no per-tile collision: with ~15,000 tiles in the
Interiors atlas alone, painting collision tile-by-tile is unmaintainable. Instead
a single collision brush (source 7 of ranch_interior.tres, from
tilesets/atlases/collision_brush.png) holds the collision polygons, and an
invisible "Collision" layer is painted with it.

That keeps "what it looks like" and "what blocks you" independent - redecorate
freely, then re-run this to bring collision back in step.

    Collision = (Walls + Furniture) - Openings

Walls and Furniture block wherever they have a tile. Decor never does. The
"Openings" layer (invisible, tinted green, painted with any tile) marks cells
you can walk through anyway: doorways drawn as wall tiles, thin wall ends, the
top half of a tall lamp. Paint those once and they survive every re-sync.

Usage:
    python tools/sync_collision.py                       # ranch_interior.tscn
    python tools/sync_collision.py world/foo/foo.tscn
    python tools/sync_collision.py --from Walls world/foo/foo.tscn

Close the scene in Godot first, or the editor may write over the result.
"""

import argparse
import base64
import os
import re
import struct
import sys

DEFAULT_SCENE = "world/ranch_interior/ranch_interior.tscn"
COLLISION_LAYER = "Collision"
OPENINGS_LAYER = "Openings"
BRUSH_SOURCE_ID = 7
BRUSH_ATLAS = (0, 0)          # the full-block tile

# Tiles that look like walls but you walk through. Arched entryways (source 4)
# are the doorways themselves - their jambs get painted by hand.
OPEN_SOURCE_IDS = {4}

REC = "<hhHHHH"               # cell_x, cell_y, source_id, atlas_x, atlas_y, alternative
REC_SIZE = struct.calcsize(REC)


def decode(b64):
    body = base64.b64decode(b64)[2:]
    return [struct.unpack(REC, body[i:i + REC_SIZE]) for i in range(0, len(body), REC_SIZE)]


def encode(cells):
    out = b"\x00\x00"
    for c in cells:
        out += struct.pack(REC, *c)
    return base64.b64encode(out).decode()


def layer_block(src, name):
    """Return (start, end) of the [node name="<name>" ...] block, or None."""
    m = re.search(r'(?m)^\[node name="%s"[^\]]*\]$' % re.escape(name), src)
    if not m:
        return None
    nxt = re.search(r'(?m)^\[node ', src[m.end():])
    return m.start(), (m.end() + nxt.start()) if nxt else len(src)


def read_cells(src, name):
    span = layer_block(src, name)
    if span is None:
        return None
    block = src[span[0]:span[1]]
    m = re.search(r'tile_map_data = PackedByteArray\("([^"]*)"\)', block)
    return decode(m.group(1)) if m else []


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("scene", nargs="?", default=DEFAULT_SCENE)
    ap.add_argument("--from", dest="sources", default="Walls,Furniture",
                    help="comma-separated layer names to derive collision from")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    path = args.scene if os.path.isabs(args.scene) else os.path.join(root, args.scene)
    if not os.path.exists(path):
        sys.exit("no such scene: %s" % path)

    src = open(path, encoding="utf-8").read()

    solid, skipped = {}, 0
    for name in [s.strip() for s in args.sources.split(",") if s.strip()]:
        cells = read_cells(src, name)
        if cells is None:
            print("  %-12s (no such layer, skipped)" % name)
            continue
        for c in cells:
            if c[2] in OPEN_SOURCE_IDS:
                skipped += 1
                continue
            solid[(c[0], c[1])] = True
        print("  %-12s %d cells" % (name, len(cells)))

    openings = read_cells(src, OPENINGS_LAYER) or []
    opened = 0
    for c in openings:
        if solid.pop((c[0], c[1]), None):
            opened += 1
    print("  %-12s %d cells (%d opened)" % (OPENINGS_LAYER, len(openings), opened))

    out_cells = [(x, y, BRUSH_SOURCE_ID, BRUSH_ATLAS[0], BRUSH_ATLAS[1], 0)
                 for (x, y) in sorted(solid)]
    data = encode(out_cells)

    span = layer_block(src, COLLISION_LAYER)
    if span is None:
        sys.exit('scene has no "%s" layer - add one (invisible, parent ".") first'
                 % COLLISION_LAYER)

    block = src[span[0]:span[1]]
    if "tile_map_data" in block:
        new_block = re.sub(r'tile_map_data = PackedByteArray\("[^"]*"\)',
                           'tile_map_data = PackedByteArray("%s")' % data, block, count=1)
    else:
        lines = block.rstrip("\n").split("\n")
        lines.insert(1, 'tile_map_data = PackedByteArray("%s")' % data)
        new_block = "\n".join(lines) + "\n\n"

    print("  -> %d solid cells, %d walk-through cells skipped" % (len(out_cells), skipped))

    if args.dry_run:
        print("  (dry run, nothing written)")
        return

    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(src[:span[0]] + new_block + src[span[1]:])
    print("  wrote %s" % os.path.relpath(path, root))


if __name__ == "__main__":
    main()
