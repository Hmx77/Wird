#!/usr/bin/env bash
set -euo pipefail
wird_baseline_sha=210009a5fac64df097385375c3628d8ad3a7b2cb
wird_baseline_dir="${RUNNER_TEMP:?}/wird-upgrade-baseline"
wird_review_root="$PWD"
git worktree add --detach "$wird_baseline_dir" "$wird_baseline_sha"
mkdir -p "$wird_review_root/build/upgrade-baseline"
(
  cd "$wird_baseline_dir"
  flutter pub get
  flutter build apk --debug
)
cp "$wird_baseline_dir/build/app/outputs/flutter-apk/app-debug.apk" "$wird_review_root/build/upgrade-baseline/app-debug.apk"
printf '%s\n' "$wird_baseline_sha" > "$wird_review_root/build/upgrade-baseline/source-commit.txt"
sha256sum "$wird_review_root/build/upgrade-baseline/app-debug.apk" > "$wird_review_root/build/upgrade-baseline/apk-sha256.txt"
git worktree remove --force "$wird_baseline_dir"
