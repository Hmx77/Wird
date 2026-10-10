#!/usr/bin/env python3
"""Offline structural checks. Not a replacement for Flutter/device testing."""
import hashlib
import json
from pathlib import Path
import plistlib
import re
import struct
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

def require(condition, message):
    if not condition:
        raise SystemExit('FAIL: ' + message)

audit = json.loads((ROOT / 'docs/content-audit.json').read_text(encoding='utf-8'))
require(hashlib.sha256((ROOT / 'lib/content.dart').read_bytes()).hexdigest() == audit['contentFileSHA256'], 'Corpus changed since source review')
entries = audit['entries']
require(len(entries) == len({e['id'] for e in entries}), 'Duplicate entry IDs')
for entry in entries:
    require(entry['reviewed'] and entry['sourceUrl'].startswith('https://sunnah.com/'), 'Unreviewed item')
require({e['section'] for e in entries} == {'morning', 'evening', 'sleep'}, 'Missing section')
main = (ROOT / 'lib/main.dart').read_text(encoding='utf-8')
require(len(re.findall(r"WirdPalette\(\s*'", main)) == 10, 'Ten theme palettes required')
require('int themeIndex = 8' in main, 'Wrong default theme')
require(hashlib.sha256((ROOT / 'assets/brand/wird_logo.png').read_bytes()).hexdigest() == audit['logoSHA256'], 'Brand source changed')
for file in ROOT.rglob('*.xml'):
    ET.parse(file)
for file in ROOT.rglob('*.plist'):
    plistlib.loads(file.read_bytes())
for file in ROOT.rglob('*.entitlements'):
    plistlib.loads(file.read_bytes())
for file in ROOT.rglob('*.storyboard'):
    ET.parse(file)
icons = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
for icon in json.loads((icons / 'Contents.json').read_text(encoding='utf-8'))['images']:
    data = (icons / icon['filename']).read_bytes()
    dimension = round(float(icon['size'].split('x')[0]) * float(icon['scale'][:-1]))
    require(struct.unpack('>II', data[16:24]) == (dimension, dimension), 'Wrong iOS icon size')
require((ROOT / 'android/app/src/main/res/raw/keep.xml').is_file(), 'Notification icon retention missing')
require("Locale('en')" in main and "Locale(store.languageCode)" in main, 'English locale missing')
manifest = json.loads((ROOT / 'assets/audio/manifest.json').read_text(encoding='utf-8'))
require(len(manifest['tracks']) == len({t['entryId'] for t in manifest['tracks']}), 'Duplicate audio entry')
for track in manifest['tracks']:
    require(track.get('approved') and track.get('arabicReviewed'), 'Audio not approved')
    for field in ['asset', 'permissionFile']:
        value = track[field]
        require(value.startswith('assets/audio/') and '..' not in value, 'Unsafe audio path')
        require((ROOT / value).is_file(), 'Missing audio asset or permission evidence')
    require((ROOT / track['permissionFile']).read_text(encoding='utf-8').strip(), 'Empty audio rights evidence')
    require(hashlib.sha256((ROOT / track['asset']).read_bytes()).hexdigest() == track['sha256'], 'Audio hash mismatch')
    require(track.get('license') and track.get('reciter'), 'Missing attribution')
    require(track['entryId'] in {e['id'] for e in entries}, 'Unknown audio entry')
project = (ROOT / 'ios/Runner.xcodeproj/project.pbxproj').read_text(encoding='utf-8')
require('WirdWidget.appex' in project and 'Embed App Extensions' in project, 'Widget target missing')
require(project.count('CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;') == 3, 'Runner entitlement configuration missing')
require(project.count('CODE_SIGN_ENTITLEMENTS = WirdWidget/WirdWidget.entitlements;') == 3, 'Widget entitlement configuration missing')
require('{{' not in project, 'Unrendered project template')
android = (ROOT / 'android/app/src/main/AndroidManifest.xml').read_text(encoding='utf-8')
require('WirdWidgetProvider' in android and 'ScheduledNotificationBootReceiver' in android, 'Native receiver missing')
require('android:allowBackup="false"' in android, 'Android backup policy missing')
require('getByName("debug")' not in (ROOT / 'android/app/build.gradle.kts').read_text(encoding='utf-8'), 'Release uses debug signing')
require((ROOT / 'android/gradle/wrapper/gradle-wrapper.jar').read_bytes().startswith(b'PK'), 'Missing Gradle wrapper')
print(f'PASS: {len(entries)} source-checked entries, 10 themes, exact logo, XML/plists, icon sizes, audio rights gate, widget configuration and signing policy.')
print('Not tested here: Flutter compilation, platform runtime, physical-device delivery or store acceptance.')
