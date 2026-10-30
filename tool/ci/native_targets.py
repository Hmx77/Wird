"""Visible native hit regions shared by the ADB smoke checks."""
import re
import unicodedata

def _normal(value):
    return ''.join(c for c in unicodedata.normalize('NFD', value)
                   if unicodedata.category(c) != 'Mn')

def content_bottom(nodes, height):
    edges = []
    for node in nodes:
        labels = [node.get(key, '').splitlines() for key in ('text', 'content-desc')]
        if not any(lines and _normal(lines[0]).strip() == _normal('الرئيسية') for lines in labels):
            continue
        bounds = list(map(int, re.findall(r'-?\d+', node.get('bounds', ''))))
        if len(bounds) == 4 and bounds[1] > height * .5:
            edges.append(bounds[1])
    return min(edges) - 24 if edges else height * .89

def usable_target(bounds, limit):
    x1, y1, x2, y2 = bounds
    # uiautomator reports clipped bounds: a 6px strip is not a usable target.
    return x2 > x1 and y1 >= 0 and y2 - y1 >= 32 and y2 <= limit
