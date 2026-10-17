"""Inspect every 100 ms of the real recording; do not accept long flat startup.

Input is ffmpeg's RGB24 32x72 frames. This catches regressions which a successful
home launch or one screenshot cannot. Heuristics complement human frame review.
"""
import json
import math
from pathlib import Path

root = Path('verification/device')
raw = (root / 'startup-rgb.raw').read_bytes()
size = 32 * 72 * 3
assert raw and len(raw) % size == 0, 'Incomplete recording frame data'
reference = (root / 'startup-reference.raw').read_bytes()
assert len(reference) == size, 'Missing cinematic reference frame'
reference_pixels = [tuple(reference[p:p+3]) for p in range(32*6*3, 32*66*3, 3)]
reference_light = [sum(p)/3 for p in reference_pixels]
reference_mean = sum(reference_light)/len(reference_light)
reference_delta = [v-reference_mean for v in reference_light]
reference_energy = sum(v*v for v in reference_delta)
timeline = []
longest = current = 0
cinematic = 0
for index in range(len(raw) // size):
    frame = raw[index * size:(index + 1) * size]
    pixels = [tuple(frame[p:p + 3]) for p in range(32 * 6 * 3, 32 * 66 * 3, 3)]
    light = [(r + g + b) / 3 for r, g, b in pixels]
    mean = sum(light) / len(light)
    deviation = math.sqrt(sum((x - mean) ** 2 for x in light) / len(light))
    warm = sum(r > b + 20 and r > 65 and g > b + 8 for r, g, b in pixels) / len(pixels)
    flat = deviation < 2
    delta = [v-mean for v in light]
    energy = sum(v*v for v in delta)
    correlation = (sum(a*b for a,b in zip(delta,reference_delta)) /
                   math.sqrt(energy*reference_energy)) if energy > 0 else 0
    scene = correlation > .65 and warm > .08
    timeline.append({'seconds': index / 10, 'deviation': round(deviation, 2),
                     'warmFraction': round(warm, 4), 'sceneCorrelation': round(correlation, 3), 'flat': flat, 'sceneCandidate': scene})
    # The first two seconds include the launcher and its OS tap animation.
    if index >= 20:
        current = current + 1 if flat else 0
        longest = max(longest, current)
        cinematic += int(scene)
report = {'longestFlatSecondsAfter2s': longest / 10,
          'cinematicCandidateFramesAfter2s': cinematic, 'frames': timeline}
(root / 'startup-timeline.json').write_text(json.dumps(report, indent=2))
assert longest <= 8, f'Flat startup interval remains: {longest / 10:.1f}s'
assert cinematic >= 2, 'No sustained cinematic scene detected after launcher tap'
print(f'PASS: startup frame guard; longest flat interval {longest / 10:.1f}s; '
      f'{cinematic} cinematic candidate frames. Human visual review still required.')
