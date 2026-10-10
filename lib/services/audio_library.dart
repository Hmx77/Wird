import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import '../content.dart';

class LicensedTrack {
  LicensedTrack(
    this.asset,
    this.reciter,
    this.license,
    this.permission,
    this.digest,
  );
  final String asset, reciter, license, permission, digest;
}

class AudioLibrary {
  AudioLibrary({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;
  static final instance = AudioLibrary();
  final Map<String, LicensedTrack> tracks = {};
  Future<void> load() async {
    try {
      await _load();
    } catch (_) {
      tracks.clear();
    }
  }

  Future<void> _load() async {
    tracks.clear();
    final manifest =
        jsonDecode(await _bundle.loadString('assets/audio/manifest.json'))
            as Map<String, dynamic>;
    for (final raw in (manifest['tracks'] as List<dynamic>)) {
      final t = raw as Map<String, dynamic>;
      // Every shipped track needs written rights evidence AND Arabic review.
      if (t['approved'] != true || t['arabicReviewed'] != true) continue;
      final fields = [
        'entryId',
        'asset',
        'reciter',
        'license',
        'permissionFile',
        'sha256',
      ];
      if (fields.any(
        (key) => t[key] is! String || (t[key] as String).trim().isEmpty,
      ))
        continue;
      if (!entries.any((e) => e.id == t['entryId'])) continue;
      if (tracks.containsKey(t['entryId']))
        throw StateError('Duplicate recording');
      final asset = t['asset'] as String;
      final permission = t['permissionFile'] as String;
      if (!asset.startsWith('assets/audio/') ||
          asset.contains('..') ||
          !permission.startsWith('assets/audio/') ||
          permission.contains('..'))
        continue;
      try {
        final proof = await _bundle.loadString(permission);
        if (proof.trim().isEmpty) continue;
        final data = await _bundle.load(asset);
        if (sha256
                .convert(
                  data.buffer.asUint8List(
                    data.offsetInBytes,
                    data.lengthInBytes,
                  ),
                )
                .toString() !=
            t['sha256'])
          continue;
        tracks[t['entryId'] as String] = LicensedTrack(
          asset,
          t['reciter'] as String,
          t['license'] as String,
          permission,
          t['sha256'] as String,
        );
      } catch (_) {
        /* Missing evidence or recording: fail closed. */
      }
    }
  }
}
