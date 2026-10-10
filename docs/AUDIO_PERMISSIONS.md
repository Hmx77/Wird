# Audio admission and rights

No recordings were supplied with licensing or written permission. The shipped manifest is intentionally empty. Playback UI shows an honest unavailable message until an approved track exists; there are no network recordings or synthetic substitutes.

The implemented player supports local asset playback, pause, replay and seeking. It stops/pauses when the reader is left or the app backgrounds. Background media playback is not claimed.

For each future recording put its audio and permission evidence under `assets/audio/` and register:

```json
{
  "entryId": "morning_sayyid",
  "asset": "assets/audio/morning_sayyid.m4a",
  "reciter": "Actual credited reciter",
  "license": "Actual license name or written permission",
  "permissionFile": "assets/audio/morning_sayyid_permission.txt",
  "sha256": "SHA256_OF_THE_RECORDING",
  "approved": true,
  "arabicReviewed": true
}
```

`approved` must reflect an actual review of redistribution/offline bundling rights, platform use, commercial use where applicable, attribution and any modification limits. Preserve the permission grant and its date. `arabicReviewed` must reflect an actual pronunciation and exact-text review of that specific recording. The loader verifies required fields, local paths, permission file presence and matching audio hash. Those checks cannot establish rights on their own.

Never mark an entry approved merely because a recording is publicly playable on a website. No permissions were requested from others during this work.
