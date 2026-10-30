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
# The old 51-item catalog remains field-for-field guarded by
# test/content_expansion_test.dart against baseline-catalog.json.
# The new, separately labeled review entries are never claimed Sahih.
review_source = (ROOT / 'lib/reference_review.dart').read_text(encoding='utf-8')
require((ROOT / 'lib/content.dart').read_text(encoding='utf-8').startswith("part 'reference_review.dart';"), 'Reference catalog not linked')
require(review_source.count('reviewOnly: true') == 15, 'Expected fifteen visibly graded reference-only passages')
require(review_source.count('authenticity: ') == 15, 'Missing explicit grading')
require(review_source.count('referenceScreens: [') == 15, 'Missing reference order')
require(hashlib.sha256((ROOT / 'lib/quran_text.dart').read_bytes()).hexdigest() == audit['quranFileSHA256'], 'Quran text changed since source review')
entries = audit['entries']
require(len(entries) == len({e['id'] for e in entries}), 'Duplicate entry IDs')
for entry in entries:
    require(entry['reviewed'] and any(entry['sourceUrl'].startswith('https://' + host + '/') for host in ['sunnah.com', 'dorar.net', 'tanzil.net']), 'Unreviewed item')
    require(entry['isQuran'] or 'صحيح' in entry['source'], 'No explicit Sahih evidence')
screen_map = json.loads((ROOT / 'docs/reference-screen-map.json').read_text())
screens = screen_map['screens']
for section, target in [('morning',25),('evening',23),('sleep',18)]:
    section_screens = [s['screen'] for s in screens if s['section']==section]
    require(sorted(section_screens)==list(range(1,target+1)), 'Missing or duplicate reference screen')
    require([e['referenceScreens'][0] for e in entries if e['section']==section and e['referenceScreens']] == sorted(e['referenceScreens'][0] for e in entries if e['section']==section and e['referenceScreens']), 'Reference order changed')
for screen in screens:
    require(all(id in {e['id'] for e in entries} for id in screen['entryIds']), 'Unknown mapped entry')
    if screen['decision']=='pending': require(not screen['entryIds'], 'Pending material exposed')
require(not any(e['id'] in {p['id'] for p in screen_map['pendingCandidates']} for e in entries), 'Review queue reached reading corpus')
quran_source = json.loads((ROOT / 'docs/quran-source.json').read_text())
require(len([k for k in quran_source['verses'] if k.startswith('67:')])==30, 'Incomplete Mulk')
for entry in entries:
    if entry['isQuran']:
        require(entry['quranSourceUrl']=='https://tanzil.net' and 'Tanzil Project' in entry['source'], 'Quran attribution missing')
require({e['section'] for e in entries} == {'morning', 'evening', 'sleep'}, 'Missing section')
main = (ROOT / 'lib/main.dart').read_text(encoding='utf-8')
require(len(re.findall(r"WirdPalette\(\s*'", main)) == 2, 'Exactly two premium theme palettes required')
require('int themeIndex = 0' in main, 'Wrong default theme')
require(hashlib.sha256((ROOT / 'assets/brand/wird_logo.png').read_bytes()).hexdigest() == audit['logoSHA256'], 'Brand source changed')
brand = json.loads((ROOT / 'docs/branding-source.json').read_text())
require(hashlib.sha256((ROOT / brand['file']).read_bytes()).hexdigest() == brand['sha256'], 'New owner artwork changed')
for file in ROOT.rglob('*.xml'):
    ET.parse(file)
for file in ROOT.rglob('*.plist'):
    plistlib.loads(file.read_bytes())
widget_info = plistlib.loads((ROOT / 'ios/WirdWidget/Info.plist').read_bytes())
require(bool(widget_info.get('CFBundleName')), 'Widget bundle name missing')
app_version = re.search(r'^version: (.+)$', (ROOT / 'pubspec.yaml').read_text(), re.M).group(1).split('+')
require(widget_info['CFBundleShortVersionString'] == app_version[0] and widget_info['CFBundleVersion'] == app_version[1], 'Widget version must match app version')
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
print(f'PASS: {len(entries)} source-checked entries, 2 premium themes, exact logo, XML/plists, icon sizes, audio rights gate, widget configuration and signing policy.')
print('Not tested here: Flutter compilation, platform runtime, physical-device delivery or store acceptance.')
