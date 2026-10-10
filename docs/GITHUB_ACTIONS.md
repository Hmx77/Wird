# GitHub automation

Target: private `Hmx77/Wird`, source at repository root (the directory containing `pubspec.yaml`). Do not upload only a ZIP to the repository: Actions needs the extracted source and `.github/workflows`.

`verify.yml` runs Android validation and a debug APK build on main pushes and pull requests. It is also manually dispatchable. The `build_ios` manual input additionally runs unsigned iOS validation on macOS. The APK is retained as `wird-debug-apk` for 14 days. Verification logs and the real generated dependency lockfile are separate artifacts even when a build fails. Commit a successfully resolved lockfile after review. No lockfile is invented here.

`release-android.yml` is manual only, uses the `android-release` environment and never publishes. Configure that environment with required reviewers before production use. It requires these existing user-managed secrets:

- `WIRD_KEYSTORE_BASE64`
- `WIRD_STORE_PASSWORD`
- `WIRD_KEY_PASSWORD`
- `WIRD_KEY_ALIAS`

The signing helper validates that all are present, writes private temporary files, correctly escapes Java properties, and never logs values. Gradle validates the actual keystore when signing. No keys are created by CI. Signing files are removed in an always-run cleanup step and excluded from artifact paths. Signed APK/AAB artifacts expire after seven days.

Hosted builds consume your GitHub Actions allowance. No paid plan, larger runner, budget increase or additional service has been configured. Metadata firewall setup fails closed, and Flutter runs with a clean environment without the Actions token. Workflows use `contents: read` and checkout has credential persistence disabled. Firewall scripts are for disposable GitHub-hosted runners, not personal machines.

Current status: workflows prepared and statically checked, not uploaded or run. Repository exists and is private, but connected API access to it is unavailable. See `BUILD_STATUS_2026-10-10.md` for the actual results; do not label CI working until a run succeeds.
