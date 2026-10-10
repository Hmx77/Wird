import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wird/content.dart';
import 'package:wird/services/audio_library.dart';

class MemoryBundle extends CachingAssetBundle {
  MemoryBundle(this.files);
  final Map<String, List<int>> files;
  @override
  Future<ByteData> load(String key) async {
    final bytes = files[key];
    if (bytes == null) throw StateError('Missing test asset');
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Test bytes are deliberately not an audio recording and are never played.
  final bytes = utf8.encode('policy test fixture');
  final valid = <String, dynamic>{
    'entryId': entries.first.id,
    'approved': true,
    'arabicReviewed': true,
    'asset': 'assets/audio/test.bin',
    'permissionFile': 'assets/audio/proof.txt',
    'reciter': 'Test fixture',
    'license': 'Test only',
    'sha256': sha256.convert(bytes).toString(),
  };
  Future<AudioLibrary> load(
    List<Map<String, dynamic>> tracks, {
    String proof = 'Test-only evidence',
  }) async {
    final library = AudioLibrary(
      bundle: MemoryBundle({
        'assets/audio/manifest.json': utf8.encode(
          jsonEncode({'tracks': tracks}),
        ),
        'assets/audio/test.bin': bytes,
        'assets/audio/proof.txt': utf8.encode(proof),
      }),
    );
    await library.load();
    return library;
  }

  test(
    'rights evidence, Arabic review, path, known entry and hash are required',
    () async {
      expect((await load([valid])).tracks, hasLength(1));
      for (final invalid in [
        {...valid, 'approved': false},
        {...valid, 'arabicReviewed': false},
        {...valid, 'sha256': 'wrong'},
        {...valid, 'asset': 'https://example.com/audio'},
        {...valid, 'entryId': 'unknown'},
        {...valid, 'permissionFile': 'assets/audio/../private'},
      ]) {
        expect((await load([invalid])).tracks, isEmpty);
      }
      expect((await load([valid], proof: ' ')).tracks, isEmpty);
      expect((await load([valid, valid])).tracks, isEmpty);
    },
  );
}
