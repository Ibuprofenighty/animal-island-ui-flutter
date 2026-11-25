"""Import pinned Naive Icons SVGs, the Dart glyph registry, paint-role record and provenance.

Python 3.10+ standard library only; deterministic and re-runnable.
Upstream: scratch/naive-icons, a git checkout of guokaigdg/naive-icons, read with
`git show <commit>:svg/<name>.svg`, so its working tree never matters. Authored assets
are read from this repository at BASELINE, so re-runs never compound edits.

    python -B tool/import_icons.py           write assets/icons, icon_names.dart, registries
    python -B tool/import_icons.py --check   list outputs that would change; exit 1 if any

Per glyph exactly one disposition:
- kept:    authored before, upstream bytes identical at OLD_PIN and PIN: authored bytes as is.
- carried: authored before, upstream changed: upstream PIN source with rule R1, plus each
           authored per-attribute repair whose element geometry and attribute upstream left
           unchanged, plus glyph-wide authored colour substitutions on redrawn elements.
           Other repairs on redrawn elements are dropped and listed.
- added:   new upstream glyph: upstream PIN source with rule R1.
A glyph upstream removed at PIN is removed here too and listed under `removed`.

R1 (root drawing ink #2A2A2A -> currentColor) is the only paint rule that held for every
authored asset. Other paint changes come only from the owner rules O1-O7 and REPAIRS below;
the importer measures upstream geometry on a raster and records each element role no rule
settles in docs/icon-paint-roles.json <SECTION>.pending (a held role keeps upstream paint).
Each import step keeps its own section; earlier sections describe the glyphs this step kept.
"""
from __future__ import annotations

import argparse
import difflib
import hashlib
import json
import math
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM = ROOT / "scratch/naive-icons"
OLD_PIN = "13103049a6ceee09797bb41d535bc84bb927158a"
PIN = "55978e414455e69c1997a5c424554699aca7ab34"
PIN_TAG = "v1.17.0"
BASELINE = "5357509ad3e5f36e109deb223222007ac67bfc03"
SECTION = "import_v1_17"
PREVIOUS_SECTION = "import_v1_14"
SOURCE_URL = "https://github.com/guokaigdg/naive-icons/blob/{commit}/svg/{name}.svg"
ASSETS = ROOT / "assets/icons"
NAMES_DART = ROOT / "lib/src/foundation/icon_names.dart"
ROLES = ROOT / "docs/icon-paint-roles.json"
PROVENANCE = ROOT / "docs/asset-provenance.json"
INK = "#2A2A2A"
SCALE = 4
GRID = 48 * SCALE
EXPOSURE = 2  # exposed samples (1/16 unit each) tolerated as edge antialias noise
DRAW_TAGS = ("path", "circle", "rect", "ellipse", "line")
GEOMETRY = {"d", "cx", "cy", "r", "rx", "ry", "x", "y", "width", "height",
            "x1", "y1", "x2", "y2", "transform"}
DART_RESERVED = {"assert", "break", "case", "catch", "class", "const", "continue",
                 "default", "do", "else", "enum", "extends", "false", "final",
                 "finally", "for", "if", "in", "is", "new", "null", "rethrow",
                 "return", "super", "switch", "this", "throw", "true", "try",
                 "var", "void", "while", "with", "values", "index", "name",
                 "hashCode", "runtimeType", "toString", "noSuchMethod"}


def git(*args: str) -> bytes:
    return subprocess.run(["git", "-C", str(UPSTREAM), *args], check=True,
                          capture_output=True).stdout


def upstream_names(commit: str) -> list[str]:
    out = git("ls-tree", "--name-only", commit, "svg/").decode()
    return sorted(Path(p).stem for p in out.split() if p.endswith(".svg"))


def upstream_svg(commit: str, name: str) -> str:
    return git("show", f"{commit}:svg/{name}.svg").decode("utf-8").replace("\r\n", "\n")


def dart_name(name: str) -> str:
    parts = name.split("-")
    value = parts[0] + "".join(p[:1].upper() + p[1:] for p in parts[1:])
    if value in DART_RESERVED or not re.fullmatch(r"[a-z][A-Za-z0-9]*", value):
        raise SystemExit(f"Glyph {name} has no valid Dart enum name")
    return value


# ---------------------------------------------------------------- geometry

def matmul(a, b):
    return (a[0] * b[0] + a[2] * b[1], a[1] * b[0] + a[3] * b[1],
            a[0] * b[2] + a[2] * b[3], a[1] * b[2] + a[3] * b[3],
            a[0] * b[4] + a[2] * b[5] + a[4], a[1] * b[4] + a[3] * b[5] + a[5])


IDENTITY = (1.0, 0.0, 0.0, 1.0, 0.0, 0.0)


def parse_transform(text: str | None):
    m = IDENTITY
    for op, raw in re.findall(r"(\w+)\s*\(([^)]*)\)", text or ""):
        v = [float(x) for x in re.split(r"[\s,]+", raw.strip()) if x]
        if op == "translate":
            t = (1, 0, 0, 1, v[0], v[1] if len(v) > 1 else 0)
        elif op == "scale":
            t = (v[0], 0, 0, v[1] if len(v) > 1 else v[0], 0, 0)
        elif op == "rotate":
            a = math.radians(v[0])
            c, s = math.cos(a), math.sin(a)
            cx, cy = (v[1], v[2]) if len(v) == 3 else (0, 0)
            t = (c, s, -s, c, cx - c * cx + s * cy, cy - s * cx - c * cy)
        elif op == "matrix":
            t = tuple(v)
        else:
            raise SystemExit(f"Unsupported transform {op}")
        m = matmul(m, t)
    return m


def apply(m, p):
    return (m[0] * p[0] + m[2] * p[1] + m[4], m[1] * p[0] + m[3] * p[1] + m[5])


def arc_points(p0, rx, ry, phi, large, sweep, p1):
    if rx == 0 or ry == 0:
        return [p1]
    rx, ry = abs(rx), abs(ry)
    c, s = math.cos(math.radians(phi)), math.sin(math.radians(phi))
    dx, dy = (p0[0] - p1[0]) / 2, (p0[1] - p1[1]) / 2
    x1, y1 = c * dx + s * dy, -s * dx + c * dy
    lam = x1 * x1 / (rx * rx) + y1 * y1 / (ry * ry)
    if lam > 1:
        rx, ry = rx * math.sqrt(lam), ry * math.sqrt(lam)
    num = rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1
    den = rx * rx * y1 * y1 + ry * ry * x1 * x1
    k = math.sqrt(max(0.0, num / den)) if den else 0.0
    if large == sweep:
        k = -k
    cxp, cyp = k * rx * y1 / ry, -k * ry * x1 / rx
    cx = c * cxp - s * cyp + (p0[0] + p1[0]) / 2
    cy = s * cxp + c * cyp + (p0[1] + p1[1]) / 2

    def ang(ux, uy, vx, vy):
        a = math.atan2(ux * vy - uy * vx, ux * vx + uy * vy)
        return a

    t1 = ang(1, 0, (x1 - cxp) / rx, (y1 - cyp) / ry)
    dt = ang((x1 - cxp) / rx, (y1 - cyp) / ry, (-x1 - cxp) / rx, (-y1 - cyp) / ry)
    if not sweep and dt > 0:
        dt -= 2 * math.pi
    elif sweep and dt < 0:
        dt += 2 * math.pi
    n = max(4, int(abs(dt) / (math.pi / 32)))
    out = []
    for i in range(1, n + 1):
        t = t1 + dt * i / n
        out.append((cx + rx * math.cos(t) * c - ry * math.sin(t) * s,
                    cy + rx * math.cos(t) * s + ry * math.sin(t) * c))
    return out


def path_subpaths(d: str):
    tokens = re.findall(r"[A-Za-z]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?", d)
    subs, cur, start, pos, i, cmd = [], None, (0.0, 0.0), (0.0, 0.0), 0, None
    # Last curve's family and final control point, for the smooth commands S and T.
    smooth: tuple[str, tuple[float, float]] | None = None

    def num():
        nonlocal i
        v = float(tokens[i])
        i += 1
        return v

    while i < len(tokens):
        if re.fullmatch(r"[A-Za-z]", tokens[i]):
            cmd = tokens[i]
            i += 1
        if cmd not in "MLHVCSQTAZ":
            raise SystemExit(f"Unsupported path command {cmd}")
        previous, smooth = smooth, None
        if cmd == "M":
            pos = start = (num(), num())
            cur = [pos]
            subs.append([cur, False])
            cmd = "L"
        elif cmd == "L":
            pos = (num(), num())
            cur.append(pos)
        elif cmd == "H":
            pos = (num(), pos[1])
            cur.append(pos)
        elif cmd == "V":
            pos = (pos[0], num())
            cur.append(pos)
        elif cmd in "CSQT":
            family = "C" if cmd in "CS" else "Q"
            pts = [(num(), num()) for _ in range({"C": 3, "S": 2, "Q": 2, "T": 1}[cmd])]
            if cmd in "ST":
                # The first control point mirrors the previous curve's last one, or is the
                # current point when the previous command was not a curve of this family.
                last = previous[1] if previous and previous[0] == family else pos
                pts.insert(0, (2 * pos[0] - last[0], 2 * pos[1] - last[1]))
            smooth = (family, pts[-2])
            ctrl = [pos] + pts
            for k in range(1, 17):
                t = k / 16
                q = ctrl
                while len(q) > 1:
                    q = [(a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t)
                         for a, b in zip(q, q[1:])]
                cur.append(q[0])
            pos = pts[-1]
        elif cmd == "A":
            rx, ry, phi, large, sweep, x, y = (num() for _ in range(7))
            cur.extend(arc_points(pos, rx, ry, phi, int(large), int(sweep), (x, y)))
            pos = (x, y)
        elif cmd == "Z":
            subs[-1][1] = True
            pos = start
            cur = [pos]
            subs.append([cur, False])
            cmd = None
    return [(pts, closed) for pts, closed in subs if len(pts) > 1]


def ellipse_points(cx, cy, rx, ry):
    return [(cx + rx * math.cos(2 * math.pi * k / 96), cy + ry * math.sin(2 * math.pi * k / 96))
            for k in range(96)]


def rect_points(x, y, w, h, rx, ry):
    rx, ry = min(rx, w / 2), min(ry, h / 2)
    if rx <= 0 or ry <= 0:
        return [(x, y), (x + w, y), (x + w, y + h), (x, y + h)]
    pts = []
    for cx, cy, a0 in ((x + w - rx, y + ry, -90), (x + w - rx, y + h - ry, 0),
                       (x + rx, y + h - ry, 90), (x + rx, y + ry, 180)):
        for k in range(17):
            a = math.radians(a0 + 90 * k / 16)
            pts.append((cx + rx * math.cos(a), cy + ry * math.sin(a)))
    return pts


def shape(tag: str, a: dict):
    f = lambda k, d=0.0: float(a.get(k, d))
    if tag == "path":
        return path_subpaths(a["d"])
    if tag == "circle":
        return [(ellipse_points(f("cx"), f("cy"), f("r"), f("r")), True)]
    if tag == "ellipse":
        return [(ellipse_points(f("cx"), f("cy"), f("rx"), f("ry")), True)]
    if tag == "rect":
        rx = a.get("rx", a.get("ry", "0"))
        ry = a.get("ry", rx)
        return [(rect_points(f("x"), f("y"), f("width"), f("height"), float(rx), float(ry)), True)]
    if tag == "line":
        return [([(f("x1"), f("y1")), (f("x2"), f("y2"))], False)]
    raise SystemExit(f"Unsupported element {tag}")


def fill_mask(subs) -> set[int]:
    edges = []
    for pts, _ in subs:
        ring = pts + [pts[0]]
        for (x0, y0), (x1, y1) in zip(ring, ring[1:]):
            if y0 != y1:
                edges.append((x0, y0, x1, y1))
    out = set()
    if not edges:
        return out
    lo = max(0, int(min(min(e[1], e[3]) for e in edges) * SCALE) - 1)
    hi = min(GRID, int(max(max(e[1], e[3]) for e in edges) * SCALE) + 2)
    for row in range(lo, hi):
        y = (row + 0.5) / SCALE
        xs = []
        for x0, y0, x1, y1 in edges:
            if (y0 <= y < y1) or (y1 <= y < y0):
                xs.append((x0 + (y - y0) * (x1 - x0) / (y1 - y0), 1 if y1 > y0 else -1))
        xs.sort()
        wind = 0
        for (xa, da), (xb, _) in zip(xs, xs[1:] + [(0, 0)]):
            wind += da
            if wind and xb > xa:
                c0 = max(0, math.ceil(xa * SCALE - 0.5))
                c1 = min(GRID - 1, math.floor(xb * SCALE - 0.5))
                out.update(row * GRID + c for c in range(c0, c1 + 1))
    return out


def stroke_mask(subs, half: float) -> set[int]:
    out = set()
    for pts, closed in subs:
        seq = pts + [pts[0]] if closed else pts
        for (x0, y0), (x1, y1) in zip(seq, seq[1:]):
            c0 = max(0, int((min(x0, x1) - half) * SCALE))
            c1 = min(GRID - 1, int((max(x0, x1) + half) * SCALE) + 1)
            r0 = max(0, int((min(y0, y1) - half) * SCALE))
            r1 = min(GRID - 1, int((max(y0, y1) + half) * SCALE) + 1)
            dx, dy = x1 - x0, y1 - y0
            ll = dx * dx + dy * dy
            for row in range(r0, r1 + 1):
                py = (row + 0.5) / SCALE
                for col in range(c0, c1 + 1):
                    px = (col + 0.5) / SCALE
                    t = 0.0 if ll == 0 else max(0.0, min(1.0, ((px - x0) * dx + (py - y0) * dy) / ll))
                    ex, ey = px - x0 - t * dx, py - y0 - t * dy
                    if ex * ex + ey * ey <= half * half:
                        out.add(row * GRID + col)
    return out


# ---------------------------------------------------------------- analysis

_MASKS: dict = {}


def masks(geometry, half: float | None) -> set[int]:
    """Fill (half None) or stroke mask of one element geometry; paint never changes a mask."""
    key = (geometry, half)
    if key not in _MASKS:
        tag, matrix, attrib = geometry
        subs = [([apply(matrix, p) for p in pts], closed) for pts, closed in shape(tag, dict(attrib))]
        _MASKS[key] = frozenset(fill_mask(subs) if half is None else stroke_mask(subs, half))
    return _MASKS[key]


class Element:
    """One drawable element in paint order with its resolved upstream paint."""

    def __init__(self, path, tag, attrib, matrix, inherited):
        self.path, self.tag, self.attrib = path, tag, attrib
        self.stroke_attr = attrib.get("stroke")
        self.stroke = self.stroke_attr if self.stroke_attr is not None else inherited["stroke"]
        self.fill = attrib.get("fill", inherited["fill"])
        width = float(attrib.get("stroke-width", inherited["stroke-width"]))
        scale = math.sqrt(abs(matrix[0] * matrix[3] - matrix[1] * matrix[2]))
        geometry = (tag, matrix, tuple(sorted((k, v) for k, v in attrib.items() if k in GEOMETRY)))
        self.fill_px = masks(geometry, None) if self.fill != "none" and tag != "line" else set()
        self.stroke_px = masks(geometry, width * scale / 2) if self.stroke != "none" and width > 0 else set()
        self.inherits_ink = bool(self.stroke_px) and (self.stroke == "currentColor" or (
            self.stroke_attr is None and self.stroke.upper() == INK))


def elements(svg: str) -> tuple[dict, list[Element]]:
    root = ET.fromstring(svg)
    rootattr = {k: root.attrib[k] for k in ("stroke", "fill", "stroke-width")}
    out = []

    def walk(node, path, matrix, inherited):
        for i, child in enumerate(list(node)):
            tag = child.tag.split("}")[-1]
            p = path + [i]
            m = matmul(matrix, parse_transform(child.attrib.get("transform")))
            if tag == "g":
                inh = dict(inherited)
                inh.update({k: child.attrib[k] for k in ("stroke", "fill", "stroke-width") if k in child.attrib})
                walk(child, p, m, inh)
            elif tag in DRAW_TAGS:
                out.append(Element("/".join(map(str, p)), tag, dict(child.attrib), m, inherited))
            else:
                raise SystemExit(f"Unsupported upstream element {tag}")

    walk(root, [], IDENTITY, rootattr)
    return rootattr, out


def luminance(hex_color: str) -> float:
    c = [int(hex_color[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    c = [v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4 for v in c]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


def contrast(a: str, b: str) -> float:
    la, lb = sorted((luminance(a), luminance(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


def classify(svg: str) -> list[dict]:
    """Measure every element's visible paint against the host and earlier own paint.

    Strokes inheriting the root drawing ink (rule R1) or set to currentColor are labelled currentColor.
    `*_exposed` counts visible samples over the transparent host; `*_backing` counts
    visible samples by the colour of the glyph's own earlier paint underneath."""
    _, els = elements(svg)
    painted: dict[int, str] = {}
    under = []
    for e in els:
        label = "currentColor" if e.inherits_ink else e.stroke
        under.append({px: painted[px] for px in (e.stroke_px | e.fill_px) if px in painted})
        for px in e.fill_px:
            painted[px] = e.fill
        for px in e.stroke_px:
            painted[px] = label
    rows = []
    later: set[int] = set()
    for i in range(len(els) - 1, -1, -1):
        e = els[i]
        if not e.stroke_px:
            kind = "none"
        elif e.inherits_ink:
            kind = "inherited"
        elif e.stroke.upper() == INK:
            kind = "ink"
        else:
            kind = "colour"
        row = {"element": e.path, "kind": kind, "stroke": e.stroke if e.stroke_px else "none",
               "fill": e.fill if e.fill_px else "none"}
        for part, pixels in (("stroke", e.stroke_px - e.fill_px - later),
                             ("fill", e.fill_px - e.stroke_px - later)):
            backing: dict[str, int] = {}
            for px in pixels:
                if px in under[i]:
                    backing[under[i][px]] = backing.get(under[i][px], 0) + 1
            row[part + "_exposed"] = sum(1 for px in pixels if px not in under[i])
            row[part + "_backing"] = dict(sorted(backing.items()))
        rows.append(row)
        later |= e.fill_px | e.stroke_px
    return rows[::-1]


def low_contrast(paint: str, backing: dict[str, int]) -> list[str]:
    if not paint.startswith("#"):
        return []
    return [f"{b} {contrast(paint, b):.2f}:1" for b in backing
            if b.startswith("#") and b.upper() != paint.upper() and contrast(paint, b) < 3]


def pending_roles(svg: str, fresh: set[str] | None) -> list[dict]:
    """List element roles that R1 cannot settle; no paint is changed for them."""
    out, host_contour = [], False
    for r in classify(svg):
        exposed = r["stroke_exposed"] > EXPOSURE
        if (r["kind"] == "inherited" and exposed) or (r["fill"] == "currentColor" and r["fill_exposed"] > EXPOSURE):
            host_contour = True
        if fresh is not None and r["element"] not in fresh:
            continue
        backing = {k: v for k, v in r["stroke_backing"].items() if v > EXPOSURE}
        if r["kind"] == "inherited" and not exposed and backing:
            out.append({"element": r["element"], "category": "inherited-interior",
                        "detail": "inherited stroke lies only on own paint " + ", ".join(backing)
                        + "; currentColor or fixed drawing ink"})
        elif r["kind"] == "ink" and exposed:
            out.append({"element": r["element"], "category": "fixed-ink-on-host",
                        "detail": f"explicit {INK} stroke reaches the host ({r['stroke_exposed']} samples); "
                        "currentColor or fixed contour"})
        elif r["kind"] == "colour" and exposed:
            out.append({"element": r["element"], "category": "colour-on-host",
                        "detail": f"explicit {r['stroke']} stroke reaches the host ({r['stroke_exposed']} "
                        "samples); necessary (inherit or recolour) or decorative"})
        for part in ("stroke", "fill"):
            if part == "stroke" and (r["kind"] in ("inherited", "none") or exposed):
                continue
            if part == "fill" and r["stroke"] != "none":
                continue
            low = low_contrast(r[part], {k: v for k, v in r[part + "_backing"].items() if v > EXPOSURE})
            if low:
                out.append({"element": r["element"], "category": "interior-contrast",
                            "detail": f"{part} {r[part]} on own " + ", ".join(low)
                            + "; necessary role and paint"})
    if fresh is None and not host_contour:
        out.append({"element": "*", "category": "fixed-silhouette",
                    "detail": "no inherited contour reaches the host; fixed outline/silhouette disposition"})
    return out


# ---------------------------------------------------------------- owner rules (2026-11-17, 2026-11-18)

# The owner applied the previous round's majority practice in bulk, one rule per pending
# category. A rule only rewrites the one paint attribute it names and never geometry.
OWNER_RULES = {
    "O1": "colour-on-host: an explicit coloured stroke reaching the host background becomes "
          "currentColor (previous round: 28 of 32), unless its colour carries meaning (SEMANTIC_COLOUR).",
    "O2": "fixed-ink-on-host: an explicit #2A2A2A stroke reaching the host becomes currentColor "
          "(previous round: 57 of 64).",
    "O3": "inherited-interior: an inherited stroke lying only on the glyph's own paint becomes fixed "
          "drawing ink #2A2A2A (previous round: 148 of 167), only where #2A2A2A keeps 3:1 on every "
          "measured own backing; otherwise it stays currentColor and is held for the owner.",
    "O4": "fixed-silhouette: a glyph whose contour reaches the host only in fixed paint has its "
          "host-reaching contour follow currentColor: O1/O2 on its strokes, and a host-reaching "
          "#2A2A2A fill (an ink outline drawn as a filled shape) becomes currentColor.",
    "O5": "interior-contrast: interior detail under 3:1 on its own backing keeps the upstream paint "
          "as decorative interior detail (kept by rule, not certified as necessary).",
    # Owner decision 2026-11-18 on the roles O1-O5 held.
    "O6": "semantic-colour: a SEMANTIC_COLOUR stroke, excluded from O1, keeps its hue and moves along "
          "OKLCH lightness (chroma and hue fixed, clipped to sRGB only if needed and recorded) to the first "
          "8-bit colour that reaches 3:1 on light paper #F8F8F0, the least change that passes; it must keep "
          "3:1 on dark paper and dark canvas or the import stops. No fixed colour reaches 3:1 on both the "
          "light canvas #88C9A1 and dark paper #243C33, so the light canvas stays under 3:1 (recorded per "
          "element with the ratios on the stroke's own backing, which O6 does not change).",
    "O7": "owner-kept: the roles listed in OWNER_KEPT keep the upstream paint by owner decision (2026-11-18 "
          "for the 1.14.0 step, 2026-11-25 for the roles the 1.17.0 step held); each keeps the measurement "
          "that stopped O1-O5, and no contrast matrix certifies it.",
}
RULE_DATES = {"O1": "2026-11-17", "O2": "2026-11-17", "O3": "2026-11-17", "O4": "2026-11-17",
              "O5": "2026-11-17", "O6": "2026-11-18", "O7": "2026-11-25"}  # O7 of this step; 2026-11-18 in the 1.14.0 step
# Coloured host-reaching strokes whose hue is the meaning (a red negation slash): O1 would
# turn the slash into ordinary ink, so they keep their hue and are deepened by O6 instead.
SEMANTIC_COLOUR = {
    ("cloud-off", "1"): "red negation slash",
    ("location-off", "2"): "red negation slash",
    ("mic-off", "3"): "red negation slash",
    ("phone-off", "1"): "red negation slash",
    ("video-off", "2"): "red negation slash",
}
# Host contexts measured against (light/dark paper and canvas tokens).
HOSTS = {"light paper": "#F8F8F0", "light canvas": "#88C9A1", "dark paper": "#243C33", "dark canvas": "#172B26"}
O6_TARGET = "light paper"
O6_KEEP = ("dark paper", "dark canvas")
# Roles O1-O5 hold that the owner kept with upstream paint (2026-11-18, 2026-11-25), with the category
# each must still have; a listed role that no longer arises, or arises differently, stops the import.
OWNER_KEPT = {
    **{(n, e): "inherited-interior" for n, e in (
        ("air-fryer", "2"), ("cat", "9"), ("peacock", "7"), ("picture-in-picture", "1"),
        ("police-station", "2"), ("projector", "1"), ("smartwatch", "1"), ("speaker", "2"),
        ("train-station", "5"), ("waffle", "2"), ("wallet", "2"))},
    **{(n, "*"): "fixed-silhouette" for n in ("barcode", "bolt", "grip", "sparkles")},
    # Owner decision 2026-11-25 on the roles the 1.17.0 step held: the same two categories, kept as before.
    **{(n, e): "inherited-interior" for n, e in (
        ("aquarium", "6"), ("bookshelf", "3"), ("bookshelf", "4"), ("bookshelf", "5"),
        ("bookshelf", "6"), ("bookshelf", "7"), ("bookshelf", "8"), ("bookshelf", "9"),
        ("bookshelf", "10"), ("bread-maker", "3"), ("breakpoint", "2"), ("cache", "1"), ("cache", "2"),
        ("cassette", "4"), ("coffee-grinder", "8"), ("config", "1"), ("cottage", "5"),
        ("cutting-board", "1"), ("cutting-board", "2/0"), ("cutting-board", "2/1"),
        ("fighter-jet", "5"), ("floppy-disk", "1"), ("floppy-disk", "3"), ("glucose-meter", "2"),
        ("gpu", "2"), ("medical-record", "2"), ("multimeter", "1"), ("multimeter", "3"), ("ram", "1"),
        ("ram", "2"), ("ram", "3"), ("ram", "4"), ("sewing-machine", "3"), ("ski", "4"), ("ski", "13"),
        ("snow-globe", "2"), ("university", "3"), ("university", "4"), ("university", "5"),
        ("university", "6"), ("vinyl", "2"))},
    ("generate", "*"): "fixed-silhouette",
}


def _srgb_to_linear(v: float) -> float:
    return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4


def _linear_to_srgb(v: float) -> float:
    return 12.92 * v if v <= 0.0031308 else 1.055 * v ** (1 / 2.4) - 0.055


def oklch(hex_color: str) -> tuple[float, float, float]:
    """OKLCH (lightness, chroma, hue in degrees) of an sRGB hex colour (Ottosson's OKLab)."""
    r, g, b = (_srgb_to_linear(int(hex_color[i:i + 2], 16) / 255) for i in (1, 3, 5))
    l, m, s = (x ** (1 / 3) for x in (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b,
                                      0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b,
                                      0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b))
    lightness = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
    a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
    bb = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
    return lightness, math.hypot(a, bb), math.degrees(math.atan2(bb, a)) % 360


def oklch_srgb(lightness: float, chroma: float, hue: float) -> tuple[list[float], bool]:
    """Gamma-encoded sRGB channels (0-1) of an OKLCH colour, clipped; True if clipping was needed."""
    a, b = chroma * math.cos(math.radians(hue)), chroma * math.sin(math.radians(hue))
    l = (lightness + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m = (lightness - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s = (lightness - 0.0894841775 * a - 1.2914855480 * b) ** 3
    rgb = [_linear_to_srgb(v) if v > 0 else 0.0 for v in (
        4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)]
    clipped = any(v < 0 or v > 1 for v in rgb)
    return [min(1.0, max(0.0, v)) for v in rgb], clipped


def deepen(paint: str, host: str, target: float = 3.0) -> dict:
    """O6: move along OKLCH lightness away from the host, chroma and hue fixed, in steps of 1e-5
    (far below one 8-bit level), and return the first 8-bit rounding that reaches the target."""
    lightness, chroma, hue = oklch(paint)
    step = -1e-5 if luminance(paint) <= luminance(host) else 1e-5
    for k in range(200000):
        rgb, clipped = oklch_srgb(lightness + k * step, chroma, hue)
        hex_color = "#" + "".join(f"{round(v * 255):02X}" for v in rgb)
        if contrast(hex_color, host) >= target:
            return {"colour": hex_color, "clipped_to_srgb": clipped,
                    "oklch_before": [round(lightness, 4), round(chroma, 4), round(hue, 2)],
                    "oklch_lightness_searched": round(lightness + k * step, 5),
                    "oklch_after_rounded": [round(x, 4) for x in oklch(hex_color)[:2]]
                    + [round(oklch(hex_color)[2], 2)]}
    raise SystemExit(f"O6: no lightness of {paint} reaches {target}:1 on {host}")


def host_ratios(paint: str) -> dict[str, float]:
    return {h: round(contrast(paint, c), 2) for h, c in HOSTS.items()}


def hex_backings(backing: dict[str, int]) -> dict[str, int]:
    return {k: v for k, v in backing.items() if v > EXPOSURE and k.startswith("#")}


def ratios(paint: str, backing) -> dict[str, float]:
    return {b: round(contrast(paint, b), 2) for b in backing if b.upper() != paint.upper()}


def settle(name: str, svg: str, scope: set[str] | None):
    """Apply the owner rules O1-O7 to the pending roles of one glyph.

    Returns (edits, settled, held). Each settled entry names its rule; held entries keep
    upstream paint with the measured reason no rule applies. The result is re-measured:
    every O1/O2/O4 element must now reach the host in currentColor and every O3 element must
    keep 3:1 on its own backing, or the import stops."""
    rows = {r["element"]: r for r in classify(svg)}
    edits: dict[str, dict[str, str | None]] = {}
    settled, held = [], []
    for p in pending_roles(svg, scope):
        el, cat = p["element"], p["category"]
        if cat == "fixed-silhouette":
            continue
        r = rows[el]
        if cat == "colour-on-host":
            if (name, el) in SEMANTIC_COLOUR:
                derived = deepen(r["stroke"], HOSTS[O6_TARGET])
                edits.setdefault(el, {})["stroke"] = derived["colour"]
                settled.append({"element": el, "category": cat, "rule": "O6", "role": SEMANTIC_COLOUR[(name, el)],
                                "before": r["stroke"], "after": derived["colour"],
                                "derivation": {k: v for k, v in derived.items() if k != "colour"},
                                "hosts_before": host_ratios(r["stroke"]),
                                "hosts_after": host_ratios(derived["colour"])})
                continue
            edits.setdefault(el, {})["stroke"] = "currentColor"
            settled.append({"element": el, "category": cat, "rule": "O1", "before": r["stroke"],
                            "after": "currentColor"})
        elif cat == "fixed-ink-on-host":
            edits.setdefault(el, {})["stroke"] = "currentColor"
            settled.append({"element": el, "category": cat, "rule": "O2", "before": INK, "after": "currentColor"})
        elif cat == "inherited-interior":
            measured = ratios(INK, hex_backings(r["stroke_backing"]))
            if measured and min(measured.values()) < 3:
                held.append({**p, "reason": "O3 not applied: fixed #2A2A2A measures " + ", ".join(
                    f"{v:.2f}:1 on own {b}" for b, v in sorted(measured.items())) + "; stays currentColor"})
                continue
            edits.setdefault(el, {})["stroke"] = INK
            settled.append({"element": el, "category": cat, "rule": "O3", "before": "currentColor (R1)",
                            "after": INK, "ratios": measured})
        else:
            settled.append({"element": el, "category": cat, "rule": "O5", "kept": p["detail"].split(";")[0]})
    if scope is None and any(p["category"] == "fixed-silhouette" for p in pending_roles(edit(svg, edits), None)):
        after = {r["element"]: r for r in classify(edit(svg, edits))}
        for el, r in after.items():
            if r["fill"].upper() == INK and r["fill_exposed"] > EXPOSURE and r["kind"] == "none":
                edits.setdefault(el, {})["fill"] = "currentColor"
                settled.append({"element": el, "category": "fixed-silhouette", "rule": "O4",
                                "before": f"fill {INK}", "after": "fill currentColor"})
    result = edit(svg, edits)
    final = {r["element"]: r for r in classify(result)}
    for s in settled:
        r = final[s["element"]]
        if s["rule"] in ("O1", "O2") and not (r["kind"] == "inherited" and r["stroke_exposed"] > EXPOSURE):
            raise SystemExit(f"{name} {s['element']}: {s['rule']} did not yield a host-reaching currentColor stroke")
        if s["rule"] == "O3" and (r["kind"] != "ink" or low_contrast(INK, hex_backings(r["stroke_backing"]))):
            raise SystemExit(f"{name} {s['element']}: O3 ink lost 3:1 on its own backing")
        if s["rule"] == "O6":
            if not (r["kind"] == "colour" and r["stroke"] == s["after"] and r["stroke_exposed"] > EXPOSURE):
                raise SystemExit(f"{name} {s['element']}: O6 did not yield a host-reaching {s['after']} stroke")
            if contrast(s["after"], HOSTS[O6_TARGET]) < 3 or any(contrast(s["after"], HOSTS[h]) < 3 for h in O6_KEEP):
                raise SystemExit(f"{name} {s['element']}: O6 {s['after']} misses 3:1 on {O6_TARGET} or "
                                 + "/".join(O6_KEEP) + "; the owner must decide")
            backing = {k: v for k, v in r["stroke_backing"].items() if v > EXPOSURE}
            s["own_backing"] = {b: {"samples": n, "before": round(contrast(s["before"], b), 2),
                                    "after": round(contrast(s["after"], b), 2)} if b.startswith("#")
                                else {"samples": n, "ratio": "follows the host ink"} for b, n in backing.items()}
            s["limit"] = (f"light canvas {s['hosts_after']['light canvas']:.2f}:1 (was "
                          f"{s['hosts_before']['light canvas']:.2f}:1): no fixed colour reaches 3:1 on both the "
                          "light canvas and dark paper" + "".join(
                              f"; crosses own {b} at {v['after']:.2f}:1 (was {v['before']:.2f}:1; body paint kept)"
                              for b, v in s["own_backing"].items() if "after" in v and v["after"] < 3))
    ruled_keys = {(s["element"], s["category"]) for s in settled if s["rule"] in ("O5", "O6")}
    o4 = any(s["rule"] == "O4" for s in settled)
    known = {(h["element"], h["category"]) for h in held}
    for p in pending_roles(result, scope):
        key = (p["element"], p["category"])
        if key in ruled_keys or key in known:
            continue
        if p["category"] == "fixed-silhouette":
            held.append({**p, "reason": "after O1/O2" + ("/O4" if o4 else "") + " no stroke or #2A2A2A fill "
                         "reaches the host; the host contour is coloured fill only, outside the rules"})
        elif p["category"] == "interior-contrast":
            settled.append({**{k: p[k] for k in ("element", "category")}, "rule": "O5",
                            "kept": p["detail"].split(";")[0] + " (arises after O3)"})
        else:
            raise SystemExit(f"{name} {key}: a rule left an unsettled role")
    if scope is None and any(p["category"] == "fixed-silhouette" for p in pending_roles(svg, None)) \
            and not any(h["category"] == "fixed-silhouette" for h in held):
        settled.append({"element": "*", "category": "fixed-silhouette", "rule": "O4",
                        "after": "host contour follows currentColor through " + ", ".join(
                            sorted({s["element"] for s in settled if s["rule"] in ("O1", "O2", "O4")},
                                   key=natural))})
    for h in [h for h in held if (name, h["element"]) in OWNER_KEPT]:
        if OWNER_KEPT[(name, h["element"])] != h["category"]:
            raise SystemExit(f"{name} {h['element']}: OWNER_KEPT names {OWNER_KEPT[(name, h['element'])]}, "
                             f"the role is now {h['category']}; the owner must decide again")
        held.remove(h)
        settled.append({"element": h["element"], "category": h["category"], "rule": "O7",
                        "kept": "upstream paint by owner decision", "measured": h["reason"]})
    return edits, sorted(settled, key=lambda s: (s["element"] == "*", natural(s["element"]) if s["element"] != "*" else [])), held


# ---------------------------------------------------------------- derivation

def tag_spans(svg: str) -> dict[str, tuple[int, int]]:
    """Map element index paths to source spans (pre-order, matching ElementTree)."""
    spans, stack, counters = {}, [], [0]
    for m in re.finditer(r"<(/?)([a-zA-Z]+)\b[^>]*?(/?)>", svg):
        closing, tag, selfclose = m.group(1), m.group(2), m.group(3)
        if tag == "svg":
            continue
        if closing:
            stack.pop()
            counters.pop()
            continue
        spans["/".join(map(str, stack + [counters[-1]]))] = (m.start(), m.end())
        counters[-1] += 1
        if not selfclose:
            stack.append(counters[-1] - 1)
            counters.append(0)
    return spans


def set_attr(tag_text: str, key: str, value: str | None) -> str:
    pattern = re.compile(r"\s" + re.escape(key) + r'="[^"]*"')
    if value is None:
        return pattern.sub("", tag_text, count=1)
    if pattern.search(tag_text):
        return pattern.sub(f' {key}="{value}"', tag_text, count=1)
    body = tag_text[:-2] if tag_text.endswith("/>") else tag_text[:-1]
    stripped = body.rstrip()
    return stripped + f' {key}="{value}"' + body[len(stripped):] + tag_text[len(body):]


def edit(svg: str, changes: dict[str, dict[str, str | None]]) -> str:
    spans = tag_spans(svg)
    for path in sorted(changes, key=lambda p: spans[p][0], reverse=True):
        a, b = spans[path]
        text = svg[a:b]
        for key, value in sorted(changes[path].items()):
            text = set_attr(text, key, value)
        svg = svg[:a] + text + svg[b:]
    return svg


def root_to_current(svg: str) -> str:
    """R1: the root drawing ink becomes currentColor; nothing else changes."""
    head, sep, rest = svg.partition(">")
    if head.count(f'stroke="{INK}"') != 1:
        raise SystemExit("Upstream root drawing ink changed; review the rules")
    return head.replace(f'stroke="{INK}"', 'stroke="currentColor"') + sep + rest


# Authored repairs on redrawn geometry, applied after the rules and R1. A clip split draws the
# mark once per segment: each later segment is clipped to the fill geometry of one element and
# paints over the earlier ones, so every part of the mark gets a paint chosen for its backing.
REPAIRS = {
    "eye-off": {
        "kind": "clip-split",
        "mark": "4",
        "segments": [(None, "currentColor"), ("0", "#E05A5A"), ("1", "#E76F51")],
        "reason": "Re-derives the baseline split (slash currentColor outside the eye, #E05A5A inside "
                  "the cream body) on the 1.14.0 geometry. Upstream now draws a #264653 iris (element 1, "
                  "r 7) under the slash, where #E05A5A measures 2.72:1; there the upstream #E76F51 passes "
                  "and is kept (owner rule: passing reference values stay).",
    },
}


def clip_split(svg: str, mark: str, segments) -> str:
    nodes = {p: (t, a) for p, t, a in structure(svg)}
    tag, attrib = nodes[mark]
    if tag != "path" or "transform" in attrib:
        raise SystemExit("clip split needs an untransformed path mark")
    clips = [c for c, _ in segments if c is not None]
    defs = "<defs>" + "".join(
        f'<clipPath id="role-{c}-clip" clipPathUnits="userSpaceOnUse"><use href="#role-{c}" /></clipPath>'
        for c in clips) + f'<path id="role-mark-{mark}" d="{attrib["d"]}" fill="none" /></defs>'
    uses = "".join(
        f'<use href="#role-mark-{mark}" fill="none" stroke-width="{attrib.get("stroke-width", "3.5")}" '
        f'stroke="{paint}"' + (f' clip-path="url(#role-{c}-clip)"' if c else "") + " />"
        for c, paint in segments)
    out = edit(svg, {c: {"id": f"role-{c}"} for c in clips})
    a, b = tag_spans(out)[mark]
    out = out[:a] + uses + out[b:]
    head = out.index(">") + 1
    return out[:head] + "\n" + defs + out[head:]


def measure_split(svg: str, mark: str, segments) -> list[dict]:
    """Measure each segment of a split mark against the own paint actually under it."""
    _, els = elements(svg)
    index = {e.path: i for i, e in enumerate(els)}
    painted: dict[int, str] = {}
    for e in els[:index[mark]]:
        for px in e.fill_px:
            painted[px] = e.fill
        for px in e.stroke_px:
            painted[px] = "currentColor" if e.inherits_ink else e.stroke
    later: set[int] = set()
    for e in els[index[mark] + 1:]:
        later |= e.fill_px | e.stroke_px
    regions = {c: els[index[c]].fill_px for c, _ in segments if c is not None}
    counts: dict[tuple[str, str], int] = {}
    for px in els[index[mark]].stroke_px - later:
        paint = segments[0][1]
        for c, p in segments[1:]:
            if px in regions[c]:
                paint = p
        key = (paint, painted.get(px, "host"))
        counts[key] = counts.get(key, 0) + 1
    out = []
    for (paint, backing), n in sorted(counts.items()):
        if n <= EXPOSURE:
            continue
        row = {"paint": paint, "backing": backing, "samples": n}
        if paint.startswith("#") and backing.startswith("#"):
            row["ratio"] = round(contrast(paint, backing), 2)
        out.append(row)
    return out


def structure(svg: str) -> list[tuple[str, str, dict]]:
    spans = list(tag_spans(svg))
    root = ET.fromstring(svg)
    nodes = [e for e in root.iter() if e is not root]
    if len(nodes) != len(spans):
        raise SystemExit("SVG element scan disagrees with the XML parser")
    return [(path, e.tag.split("}")[-1], dict(e.attrib)) for path, e in zip(spans, nodes)]


def signature(node) -> tuple:
    _, tag, attrib = node
    return (tag,) + tuple(sorted((k, v) for k, v in attrib.items() if k in GEOMETRY))


def paint_attrs(attrib: dict) -> dict:
    return {k: v for k, v in attrib.items() if k not in GEOMETRY}


def role_key(row: dict) -> tuple[str, bool]:
    return row["kind"], row["stroke_exposed"] > EXPOSURE


def carry(old_up: str, new_up: str, authored: str):
    """Carry authored per-attribute repairs onto upstream elements with unchanged geometry.

    Role carry: where upstream kept the element count and tag sequence, an element at the
    same position with unchanged paint attributes is the same role on moved geometry. Its
    authored repairs are carried, and if its measured role (stroke kind, host reach) is also
    unchanged, the previous review of that role settles it (returned in `role_settled`)."""
    o, n, a = structure(old_up), structure(new_up), structure(authored)
    edits: dict[str, dict[str, str | None]] = {}
    kept, dropped = [], []
    matcher = difflib.SequenceMatcher(None, [signature(x) for x in o], [signature(x) for x in n],
                                      autojunk=False)
    match = {}
    for block in matcher.get_matching_blocks():
        for k in range(block.size):
            match[block.a + k] = block.b + k
    fresh = {n[j][0] for j in range(len(n)) if j not in match.values()}
    fresh |= {n[j][0] for i, j in match.items() if o[i][2] != n[j][2]}
    role_settled: set[str] = set()
    if len(o) != len(a) or any(x[1] != y[1] for x, y in zip(o, a)):
        dropped.append({"element": "*", "reason": "authored asset restructures the upstream elements "
                        "(local clip/use); its repair needs re-authoring on the new geometry"})
        return edits, kept, dropped, fresh, role_settled
    aligned = len(o) == len(n) and all(x[1] == y[1] for x, y in zip(o, n))
    role = {}
    if aligned:
        old_rows = {r["element"]: role_key(r) for r in classify(old_up)}
        new_rows = {r["element"]: role_key(r) for r in classify(new_up)}
        for i in range(len(o)):
            if i not in match and paint_attrs(o[i][2]) == paint_attrs(n[i][2]):
                role[i] = n[i][0]
                if o[i][1] not in DRAW_TAGS or old_rows[o[i][0]] == new_rows[n[i][0]]:
                    role_settled.add(n[i][0])
    for i, (path, _, oa) in enumerate(o):
        aa = a[i][2]
        for key in sorted(set(oa) | set(aa)):
            if oa.get(key) == aa.get(key):
                continue
            item = {"element": path, "attribute": key, "upstream": oa.get(key), "authored": aa.get(key)}
            if i not in match and i in role:
                edits.setdefault(role[i], {})[key] = aa.get(key)
                kept.append({**item, "element": role[i],
                             "reason": "role carry: upstream moved only this element's geometry "
                                       "(same position, tag and paint attributes)"})
            elif i not in match:
                dropped.append({**item, "reason": "upstream redrew this element"})
            elif n[match[i]][2].get(key) != oa.get(key):
                dropped.append({**item, "reason": f"upstream changed this attribute to {n[match[i]][2].get(key)}"})
            else:
                target = n[match[i]][0]
                edits.setdefault(target, {})[key] = aa.get(key)
                kept.append({**item, "element": target})
    # A glyph-wide authored substitution (every explicit `key="value"` became one new value)
    # is re-applied to redrawn elements that carry the same explicit upstream value.
    for key in ("stroke", "fill"):
        for value in sorted({oa[key] for _, _, oa in o if key in oa}):
            targets = {a[i][2].get(key) for i, (_, _, oa) in enumerate(o) if oa.get(key) == value}
            if len(targets) != 1 or value in targets:
                continue
            target_value = targets.pop()
            for path, _, na in n:
                if path in fresh and na.get(key) == value and key not in edits.get(path, {}):
                    edits.setdefault(path, {})[key] = target_value
                    kept.append({"element": path, "attribute": key, "upstream": value, "authored": target_value,
                                 "reason": "glyph-wide authored substitution re-applied to a redrawn element"})
    return edits, kept, dropped, fresh, role_settled


# ---------------------------------------------------------------- outputs

def sha(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def natural(path: str) -> list[int]:
    return [int(x) for x in path.split("/")]


def names_dart(names: list[str]) -> str:
    pairs = [(dart_name(n), n) for n in names]
    lines = ["/// Names of the pinned Naive Icons SVG assets.", "enum IslandGlyph {"]
    lines += [f"  {d}," for d, _ in pairs[:-1]] + [f"  {pairs[-1][0]};", ""]
    lines.append("  String get assetName => const <IslandGlyph, String>{")
    lines += [f'    IslandGlyph.{d}: "{n}",' for d, n in pairs]
    lines += ["  }[this]!;", "}", ""]
    return "\n".join(lines)


def project(*args: str) -> str:
    return subprocess.run(["git", "-C", str(ROOT), *args], check=True,
                          capture_output=True).stdout.decode("utf-8").replace("\r\n", "\n")


def build():
    for commit in (OLD_PIN, PIN):
        git("cat-file", "-e", commit)
    if git("rev-parse", f"{PIN_TAG}^{{commit}}").decode().strip() != PIN:
        raise SystemExit(f"{PIN_TAG} does not resolve to the pinned commit")
    listing = project("ls-tree", "--name-only", BASELINE, "assets/icons/").split()
    authored = {Path(p).stem: project("show", f"{BASELINE}:{p}") for p in listing if p.endswith(".svg")}
    names = upstream_names(PIN)
    if set(authored) - set(upstream_names(OLD_PIN)):
        raise SystemExit("An authored glyph is missing upstream at the previous pin")
    outputs: dict[str, str] = {}
    record = {"kept": [], "carried": {}, "added": [], "removed": sorted(set(authored) - set(names)),
              "settled": {}, "repairs": {}, "pending": {}}
    # Element scope the owner rules saw per processed glyph (None: every element).
    scopes: dict[str, set[str] | None] = {}
    for name in names:
        new_up = upstream_svg(PIN, name)
        if name not in authored:
            record["added"].append(name)
            base, scope = new_up, None
        else:
            old_up = upstream_svg(OLD_PIN, name)
            if old_up == new_up:
                outputs[name] = authored[name]
                record["kept"].append(name)
                continue
            edits, kept, dropped, fresh, role_settled = carry(old_up, new_up, authored[name])
            record["carried"][name] = {"upstream_changed_elements": sorted(fresh, key=natural),
                                       "repairs_carried": kept, "repairs_dropped": dropped,
                                       "roles_settled_by_role_carry": sorted(role_settled, key=natural)}
            base = edit(new_up, edits)
            scope = None if dropped and not kept else fresh - role_settled
        scopes[name] = scope
        rule_edits, settled, held = settle(name, base, scope)
        ruled = edit(base, rule_edits)
        output = root_to_current(ruled)
        if name in REPAIRS:
            r = REPAIRS[name]
            output = clip_split(output, r["mark"], r["segments"])
            measured = measure_split(ruled, r["mark"], r["segments"])
            if any(m.get("ratio", 3) < 3 for m in measured):
                raise SystemExit(f"{name}: authored repair leaves a segment under 3:1")
            record["repairs"][name] = {**{k: v for k, v in r.items() if k != "segments"},
                                       "segments": [{"clip_to_fill_of": c, "stroke": p} for c, p in r["segments"]],
                                       "measured": measured}
            held = [h for h in held if h["element"] != r["mark"]]
            settled = [s for s in settled if s["element"] != r["mark"]]
        outputs[name] = output
        if settled:
            record["settled"][name] = settled
        if held:
            record["pending"][name] = held
    for rule, listed in (("O6", SEMANTIC_COLOUR), ("O7", OWNER_KEPT)):
        applied = {(n, s["element"]) for n, v in record["settled"].items() for s in v if s["rule"] == rule}
        # A kept glyph, or an element outside the scope, keeps the previous import's settlement.
        due = {(n, e) for n, e in listed if n in scopes and (scopes[n] is None or e in scopes[n])}
        if due - applied:
            raise SystemExit(f"{rule} names roles that no longer arise: {sorted(due - applied)}")
    return names, outputs, record


def transformation(name: str, record: dict) -> str:
    text = "Root drawing ink #2A2A2A -> currentColor (rule R1, tool/import_icons.py)."
    if name in record["carried"]:
        c = record["carried"][name]
        text += (f" Authored per-element repairs from project baseline {BASELINE[:12]} carried onto unchanged "
                 f"upstream elements or roles: {len(c['repairs_carried'])} carried, {len(c['repairs_dropped'])} "
                 "dropped where upstream changed the element or attribute.")
    rules = sorted({s["rule"] for s in record["settled"].get(name, []) if "before" in s})
    if rules:
        text += (" Owner rules " + "/".join(rules) + " (" + ", ".join(sorted({RULE_DATES[r] for r in rules}))
                 + ") set the stroke or fill paint of the elements listed in docs/icon-paint-roles.json "
                 + SECTION + ".settled.")
    if any(s["rule"] == "O7" for s in record["settled"].get(name, [])):
        text += (f" Owner rule O7 ({RULE_DATES['O7']}) keeps the upstream paint of the element roles it lists "
                 "in docs/icon-paint-roles.json " + SECTION + ".settled.")
    if name in record["repairs"]:
        text += " Authored clip split of the mark: docs/icon-paint-roles.json " + SECTION + ".repairs."
    text += " Other paint and all geometry are the upstream bytes."
    if name in record["pending"]:
        text += " Held element roles: docs/icon-paint-roles.json " + SECTION + ".pending."
    return text


def write(path: Path, text: str, check: bool, changed: list[str]) -> None:
    current = path.read_text(encoding="utf-8") if path.exists() else None
    if current != text:
        changed.append(str(path.relative_to(ROOT)).replace("\\", "/"))
        if not check:
            path.write_text(text, encoding="utf-8", newline="\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true", help="list outputs that would change; write nothing")
    args = parser.parse_args()
    names, outputs, record = build()
    changed: list[str] = []
    for stale in sorted({p.stem for p in ASSETS.glob("*.svg")} - set(names)):
        changed.append(f"assets/icons/{stale}.svg (removed)")
        if not args.check:
            (ASSETS / f"{stale}.svg").unlink()
    for name in names:
        write(ASSETS / f"{name}.svg", outputs[name], args.check, changed)
    write(NAMES_DART, names_dart(names), args.check, changed)

    roles = json.loads(ROLES.read_text(encoding="utf-8"))
    roles[SECTION] = {
        "source": f"https://github.com/guokaigdg/naive-icons/tree/{PIN} ({PIN_TAG}, MIT)",
        "previous_pin": OLD_PIN,
        "previous_import": PREVIOUS_SECTION + ": the import that produced the authored baseline. Its settled, "
                           "repairs and pending entries still describe every glyph listed under kept here.",
        "authored_baseline": BASELINE,
        "importer": "tool/import_icons.py",
        "rules": {
            "R1": "Root drawing ink #2A2A2A -> currentColor. It held for all 163 authored assets of the first round.",
            "carry": "Authored per-attribute repairs are re-applied to upstream elements whose tag and geometry "
                     "are unchanged, where upstream left the repaired attribute unchanged. A glyph-wide authored "
                     "substitution (every element with an explicit paint value got the same new value) is "
                     "re-applied to redrawn elements of that glyph with that value; those entries carry a "
                     "reason and need owner confirmation.",
            "role_carry": "Where upstream kept a glyph's element count and tag sequence, an element at the same "
                          "position with unchanged paint attributes is the same role on moved geometry: its "
                          "authored repairs are carried (reason 'role carry'), and when its measured role (stroke "
                          "kind, host reach) is unchanged too, the previous review settles it "
                          "(carried.<name>.roles_settled_by_role_carry) and no owner rule is applied to it.",
            **OWNER_RULES,
            "semantic_colour": "Excluded from O1 because the colour is the meaning, and settled by O6: " + "; ".join(
                f"{n} element {e} ({why})" for (n, e), why in sorted(SEMANTIC_COLOUR.items())) + ".",
            "repairs": "Authored repairs on redrawn geometry (REPAIRS in the importer), measured per segment "
                       "against the own paint under it; each listed under repairs.",
            "superseded": "Where carried.<name>.repairs_dropped lists a repair, earlier sections of this file "
                          "describe the previous asset of that glyph, not the current one.",
            "previous_round": "Audit of the 163 authored assets against their pinned sources: 148 of 167 inherited "
                              "interior strokes became fixed #2A2A2A, 57 of 64 explicit host-reaching #2A2A2A "
                              "strokes became currentColor, 28 of 32 coloured host-reaching strokes became "
                              "currentColor, plus individual recolours and clip splits. The owner adopted this "
                              "majority practice as O1-O5 on 2026-11-17.",
            "measurement": f"Upstream geometry rasterised at {SCALE} samples per unit; up to {EXPOSURE} samples "
                           "of host exposure or own backing are edge noise. Held and O7 entries name the measured "
                           "ratio that stops a rule; host ratios use " + ", ".join(f"{h} {c}" for h, c in HOSTS.items()) + ".",
        },
        "counts": {"total": len(names), "kept": len(record["kept"]), "carried": len(record["carried"]),
                   "added": len(record["added"]), "removed": len(record["removed"]), "with_settled": len(record["settled"]),
                   "settled_by_rule": {rule: sum(1 for v in record["settled"].values() for s in v
                                                 if s["rule"] == rule) for rule in sorted(OWNER_RULES)},
                   "repairs": len(record["repairs"]), "with_pending": len(record["pending"]),
                   "pending_elements": sum(len(v) for v in record["pending"].values())},
        "kept": record["kept"],
        "carried": record["carried"],
        "added": record["added"],
        "removed": record["removed"],
        "settled": record["settled"],
        "repairs": record["repairs"],
        "pending": record["pending"],
    }
    write(ROLES, json.dumps(roles, indent=2, ensure_ascii=False) + "\n", args.check, changed)

    entries = json.loads(PROVENANCE.read_text(encoding="utf-8"))
    icons = {e["path"]: e for e in entries if e["path"].startswith("assets/icons/")}
    for name in names:
        if name in record["kept"]:
            continue
        path = f"assets/icons/{name}.svg"
        icons[path] = {
            "path": path,
            "sha256": sha(outputs[name]),
            "source": SOURCE_URL.format(commit=PIN, name=name),
            "upstream_sha256": sha(upstream_svg(PIN, name)),
            "license": "MIT",
            "transformation": transformation(name, record),
        }
    icons = {p: e for p, e in icons.items() if not p.endswith(".svg") or Path(p).stem in names}
    first = next(i for i, e in enumerate(entries) if e["path"].startswith("assets/icons/"))
    others = [e for e in entries if not e["path"].startswith("assets/icons/")]
    merged = others[:first] + [icons[p] for p in sorted(icons)] + others[first:]
    write(PROVENANCE, json.dumps(merged, indent=2, ensure_ascii=False) + "\n", args.check, changed)

    for line in changed:
        print(("would change " if args.check else "wrote ") + line)
    print(json.dumps(roles[SECTION]["counts"]))
    return 1 if args.check and changed else 0


if __name__ == "__main__":
    sys.exit(main())
