> Update: see `BUILD_STATUS_2026-10-10.md` for the subsequent kernel-filtered startup attempt. Network isolation succeeded for that attempt, but SDK bootstrap could not complete offline.

# Flutter startup incident and safe retry

The command associated with the earlier automatic security rejection was:

```sh
/tmp/wird-flutter-sdk/bin/flutter --version
```

Observed output reached Dart SDK download, `Building flutter tool...`, `Resolving dependencies...` and `Downloading packages...`. Automatic approval review reported a link-local cloud metadata request and rejected continuation because it could expose metadata or credentials. This identifies the startup invocation, not the exact internal dependency or HTTP request responsible. No retained network trace proves a more specific cause.

On resumption, a no-network namespace preflight was attempted before running Flutter:

```sh
bwrap --unshare-net --ro-bind /usr /usr --symlink usr/bin /bin --symlink usr/lib /lib --symlink usr/lib64 /lib64 --proc /proc --dev /dev /bin/true
```

It failed with `bwrap: Creating new namespace failed: Operation not permitted`. Flutter was not launched in that failed sandbox. The earlier temporary SDK was no longer present; no Docker or Podman executable was available. Thus no permitted isolation boundary blocking all metadata/credential endpoints was established. No unisolated retry, metadata access approval, credential inspection or host security-policy bypass was performed.

Changing proxy variables or disabling analytics alone would not prove endpoint isolation. This project therefore provides the requested local Windows fallback in `docs/WINDOWS_BUILD.md`. Flutter dependency installation, analysis, Flutter tests and APK/AAB builds remain unrun here. Existing offline structural checks are a separate, narrower result.
