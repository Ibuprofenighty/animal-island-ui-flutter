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

R1 (root drawing ink #2A2A2A -> currentColor) is the only paint rule that held for every
authored asset. Interior fixed ink, host currentColor and recolouring were per-glyph review
decisions, so the importer never applies them: it measures upstream geometry on a raster
and records each unsettled element role in docs/icon-paint-roles.json import_v1_14.pending.
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
OLD_PIN = "edcc6ddb6aa62b8dcb80b7607a4df6a24fe32559"
PIN = "13103049a6ceee09797bb41d535bc84bb927158a"
PIN_TAG = "v1.14.0"
BASELINE = "ec05573efde4e454c67fbdf09a619d6984d30c0e"
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

    def num():
        nonlocal i
        v = float(tokens[i])
        i += 1
        return v

    while i < len(tokens):
        if re.fullmatch(r"[A-Za-z]", tokens[i]):
            cmd = tokens[i]
            i += 1
        if cmd not in "MLHVCQAZ":
            raise SystemExit(f"Unsupported path command {cmd}")
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
        elif cmd in "CQ":
            pts = [(num(), num()) for _ in range(3 if cmd == "C" else 2)]
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

class Element:
    """One drawable element in paint order with its resolved upstream paint."""

    def __init__(self, path, tag, attrib, matrix, inherited):
        self.path, self.tag, self.attrib = path, tag, attrib
        self.stroke_attr = attrib.get("stroke")
        self.stroke = self.stroke_attr if self.stroke_attr is not None else inherited["stroke"]
        self.fill = attrib.get("fill", inherited["fill"])
        width = float(attrib.get("stroke-width", inherited["stroke-width"]))
        scale = math.sqrt(abs(matrix[0] * matrix[3] - matrix[1] * matrix[2]))
        subs = [([apply(matrix, p) for p in pts], closed) for pts, closed in shape(tag, attrib)]
        self.fill_px = fill_mask(subs) if self.fill != "none" and tag != "line" else set()
        self.stroke_px = stroke_mask(subs, width * scale / 2) if self.stroke != "none" and width > 0 else set()
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
        if r["kind"] == "inherited" and exposed:
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


def carry(old_up: str, new_up: str, authored: str):
    """Carry authored per-attribute repairs onto upstream elements with unchanged geometry."""
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
    if len(o) != len(a) or any(x[1] != y[1] for x, y in zip(o, a)):
        dropped.append({"element": "*", "reason": "authored asset restructures the upstream elements "
                        "(local clip/use); its repair needs re-authoring on the new geometry"})
        return edits, kept, dropped, fresh
    for i, (path, _, oa) in enumerate(o):
        aa = a[i][2]
        for key in sorted(set(oa) | set(aa)):
            if oa.get(key) == aa.get(key):
                continue
            item = {"element": path, "attribute": key, "upstream": oa.get(key), "authored": aa.get(key)}
            if i not in match:
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
    return edits, kept, dropped, fresh


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
    if set(authored) - set(names) or set(authored) - set(upstream_names(OLD_PIN)):
        raise SystemExit("An authored glyph is missing upstream")
    outputs: dict[str, str] = {}
    record = {"kept": [], "carried": {}, "added": [], "pending": {}}
    for name in names:
        new_up = upstream_svg(PIN, name)
        if name not in authored:
            outputs[name] = root_to_current(new_up)
            record["added"].append(name)
            pending = pending_roles(new_up, None)
        else:
            old_up = upstream_svg(OLD_PIN, name)
            if old_up == new_up:
                outputs[name] = authored[name]
                record["kept"].append(name)
                continue
            edits, kept, dropped, fresh = carry(old_up, new_up, authored[name])
            outputs[name] = root_to_current(edit(new_up, edits))
            record["carried"][name] = {"upstream_changed_elements": sorted(fresh, key=natural),
                                       "repairs_carried": kept, "repairs_dropped": dropped}
            pending = pending_roles(edit(new_up, edits), None if dropped and not kept else fresh)
        if pending:
            record["pending"][name] = pending
    return names, outputs, record


def transformation(name: str, record: dict) -> str:
    text = "Root drawing ink #2A2A2A -> currentColor (rule R1, tool/import_icons.py)."
    if name in record["carried"]:
        c = record["carried"][name]
        text += (f" Authored per-element repairs from project baseline {BASELINE[:12]} carried onto unchanged "
                 f"upstream elements: {len(c['repairs_carried'])} carried, {len(c['repairs_dropped'])} dropped "
                 "where upstream changed the element or attribute. Other paint and all geometry are upstream bytes.")
    else:
        text += " Every other attribute and all geometry are the upstream bytes."
    if name in record["pending"]:
        text += " Unsettled element roles: docs/icon-paint-roles.json import_v1_14.pending."
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
    roles["import_v1_14"] = {
        "source": f"https://github.com/guokaigdg/naive-icons/tree/{PIN} ({PIN_TAG}, MIT)",
        "previous_pin": OLD_PIN,
        "authored_baseline": BASELINE,
        "importer": "tool/import_icons.py",
        "rules": {
            "R1": "Root drawing ink #2A2A2A -> currentColor. It held for all 163 authored assets and is the "
                  "only rule applied to new paint.",
            "carry": "Authored per-attribute repairs are re-applied to upstream elements whose tag and geometry "
                     "are unchanged, where upstream left the repaired attribute unchanged. A glyph-wide authored "
                     "substitution (every element with an explicit paint value got the same new value) is "
                     "re-applied to redrawn elements of that glyph with that value; those entries carry a "
                     "reason and need owner confirmation.",
            "superseded": "Where carried.<name>.repairs_dropped lists a repair, earlier sections of this file "
                          "describe the previous asset of that glyph, not the current one.",
            "not_mechanical": "Audit of the 163 authored assets against their pinned sources: 148 of 167 inherited "
                              "interior strokes became fixed #2A2A2A, 57 of 64 explicit host-reaching #2A2A2A "
                              "strokes became currentColor, 28 of 32 coloured host-reaching strokes became "
                              "currentColor, plus individual recolours and clip splits. These are per-glyph "
                              "review decisions; matching elements of new geometry are listed under pending "
                              "and keep upstream paint.",
            "measurement": f"Upstream geometry rasterised at {SCALE} samples per unit; up to {EXPOSURE} samples "
                           "of host exposure or own backing are edge noise.",
        },
        "counts": {"total": len(names), "kept": len(record["kept"]), "carried": len(record["carried"]),
                   "added": len(record["added"]), "with_pending": len(record["pending"])},
        "kept": record["kept"],
        "carried": record["carried"],
        "added": record["added"],
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
    print(json.dumps(roles["import_v1_14"]["counts"]))
    return 1 if args.check and changed else 0


if __name__ == "__main__":
    sys.exit(main())
