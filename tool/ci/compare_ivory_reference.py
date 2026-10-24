"""Create a labeled review sheet from actual PNGs, never a simulated app render."""
import argparse
from pathlib import Path
from PIL import Image, ImageDraw

parser = argparse.ArgumentParser()
parser.add_argument('--reference', required=True)
parser.add_argument('--before', required=True)
parser.add_argument('--after', required=True)
parser.add_argument('--output', required=True)
args = parser.parse_args()
reference = Image.open(args.reference).convert('RGB')
# The approved attachment includes a phone frame and dark exterior. Crop only
# that exterior; keep the full illustrated content inside the phone.
sx, sy = reference.width / 1086, reference.height / 1448
reference = reference.crop(tuple(round(v * scale) for v, scale in
    zip((212, 40, 876, 1412), (sx, sy, sx, sy))))
images = [reference, Image.open(args.before).convert('RGB'), Image.open(args.after).convert('RGB')]
labels = ['APPROVED REFERENCE (phone exterior removed)', 'BEFORE — actual Android', 'AFTER — actual Android']
height, gutter, top = 1600, 24, 70
scaled = [im.resize((round(im.width * height / im.height), height), Image.Resampling.LANCZOS) for im in images]
canvas = Image.new('RGB', (sum(im.width for im in scaled) + gutter * 4, height + top + gutter), '#e8e3d7')
draw = ImageDraw.Draw(canvas)
x = gutter
for label, im in zip(labels, scaled):
    draw.text((x, 24), label, fill='#173c2e')
    canvas.paste(im, (x, top)); x += im.width + gutter
Path(args.output).parent.mkdir(parents=True, exist_ok=True)
canvas.save(args.output)
