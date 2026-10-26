"""Regression cases from actual PR #10 Android accessibility captures."""
import unittest
import xml.etree.ElementTree as ET
from native_targets import content_bottom, usable_target

class NativeTargetsTest(unittest.TestCase):
    def test_observed_privacy_control_must_scroll_above_navigation(self):
        home = ET.fromstring('<node bounds="[796,2122][1051,2321]" content-desc="الرئيسية&#10;علامة التبويب 1 من 4"/>')
        limit = content_bottom([home], 2400)
        self.assertFalse(usable_target((87,2103,993,2109), limit))
        self.assertFalse(usable_target((87,2050,993,2120), limit))
        self.assertTrue(usable_target((87,1800,993,1926), limit))

    def test_small_phone_and_reader_without_shell(self):
        home = ET.fromstring('<node bounds="[470,950][620,1080]" text="الرئيسية"/>')
        self.assertTrue(usable_target((50,700,590,820), content_bottom([home],1136)))
        self.assertFalse(usable_target((50,900,590,960), content_bottom([home],1136)))
        self.assertTrue(usable_target((50,1600,1000,1750), content_bottom([],2400)))

if __name__ == '__main__':
    unittest.main()
