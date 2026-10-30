"""Emit bounded previews of actual emulator captures for remote visual review.

Full-resolution originals remain in wird-android-device-review. These JPEG
derivatives allow inspection through job logs when a local workspace is absent.
"""
import base64
import os
from pathlib import Path
import shutil
import subprocess

root = Path("verification/device")
ffmpeg = shutil.which("ffmpeg")
if not ffmpeg:
    candidates = list((Path(os.environ["RUNNER_TEMP"]) / "wird-ffmpeg" /
                       "imageio_ffmpeg" / "binaries").glob("ffmpeg-linux*"))
    if candidates:
        ffmpeg = str(candidates[0])
if not ffmpeg:
    raise RuntimeError("FFmpeg missing; cannot prepare native review previews")
names = ["android-appearance-expect-failure.png",
         "android-appearance-target-failure.png"]
for mode in ("ivory", "midnight"):
    for kind in ("hasan", "daif", "quran-disputed"):
        for suffix in ("", "-text200", "-text200-continuation"):
            names.append(f"android-reference-{mode}-{kind}{suffix}.png")
for name in names:
    source = root / name
    if not source.is_file():
        continue
    data = subprocess.check_output([
        ffmpeg, "-hide_banner", "-loglevel", "error", "-i", str(source),
        "-vf", "scale=900:-1", "-frames:v", "1", "-q:v", "3",
        "-c:v", "mjpeg", "-f", "image2pipe", "-"
    ], timeout=30)
    print("WIRD_NATIVE_PREVIEW " + name + " " +
          base64.b64encode(data).decode("ascii"), flush=True)
