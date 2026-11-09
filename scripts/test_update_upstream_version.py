"""Unit tests for the pure helpers in update-upstream-version.py.

Run from the repository root: python3 -m unittest discover -s scripts
"""
import importlib.util
import sys
import tempfile
import types
import unittest
from pathlib import Path

try:
    import yaml  # noqa: F401
except ImportError:  # the helpers under test do not parse YAML
    sys.modules["yaml"] = types.ModuleType("yaml")

_spec = importlib.util.spec_from_file_location(
    "update_upstream_version", Path(__file__).with_name("update-upstream-version.py")
)
uuv = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(uuv)


class NormalizeVersion(unittest.TestCase):
    def test_strips_leading_v_before_a_digit(self):
        self.assertEqual(uuv.normalize_version("v1.2.3"), "1.2.3")

    def test_keeps_names_that_only_start_with_v(self):
        self.assertEqual(uuv.normalize_version("vault"), "vault")

    def test_maps_postgres_release_tags(self):
        self.assertEqual(uuv.normalize_version("REL_18_6"), "18.6")

    def test_maps_dashed_release_tags(self):
        self.assertEqual(uuv.normalize_version("REL-9_18"), "9.18")

    def test_leaves_plain_versions_alone(self):
        self.assertEqual(uuv.normalize_version("2026.10.7"), "2026.10.7")


class Prerelease(unittest.TestCase):
    def test_detects_prerelease_markers(self):
        for tag in ("1.2.0-rc1", "v2.0.0-beta.2", "3.0.0-alpha", "1.0.0-preview", "1.0.0-dev"):
            self.assertTrue(uuv.is_prerelease(tag), tag)

    def test_final_releases_are_not_prereleases(self):
        for tag in ("1.2.0", "v2.19.2", "2026-11-02", "REL_18_6"):
            self.assertFalse(uuv.is_prerelease(tag), tag)

    def test_words_that_contain_a_marker_are_not_prereleases(self):
        self.assertFalse(uuv.is_prerelease("1.0.0-devices"))


class VersionOrdering(unittest.TestCase):
    def test_numeric_not_lexical(self):
        self.assertGreater(uuv.version_key("1.10.0"), uuv.version_key("1.9.0"))
        self.assertGreater(uuv.version_key("18.10"), uuv.version_key("18.6"))

    def test_wrapper_revision_sorts_after_the_upstream_version(self):
        self.assertGreater(uuv.version_key("0.165.0-4"), uuv.version_key("0.165.0"))
        self.assertGreater(uuv.version_key("0.165.0-5"), uuv.version_key("0.165.0-4"))

    def test_equal_versions_compare_equal(self):
        self.assertEqual(uuv.version_key("v1.2.3"[1:]), uuv.version_key("1.2.3"))

    def test_numeric_parts_ignore_trailing_zeros_and_suffixes(self):
        self.assertEqual(uuv.numeric_parts("1.4.0"), [1, 4])
        self.assertEqual(uuv.numeric_parts("1.4.0-3"), [1, 4, 0, 3])
        self.assertEqual(uuv.numeric_parts("2026.10.7"), [2026, 10, 7])


class ConfigVersion(unittest.TestCase):
    def read(self, text):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "config.yaml"
            p.write_text(text, encoding="utf-8")
            return uuv.read_config_version(p)

    def test_quoted_and_unquoted(self):
        self.assertEqual(self.read('name: x\nversion: "1.4.0-3"\n'), "1.4.0-3")
        self.assertEqual(self.read("name: x\nversion: 15.6.2\n"), "15.6.2")

    def test_ignores_indented_version_keys(self):
        self.assertEqual(self.read("options:\n  version: 9\nversion: '2.0'\n"), "2.0")

    def test_missing_version_raises(self):
        with self.assertRaises(ValueError):
            self.read("name: x\n")


class ChangelogSections(unittest.TestCase):
    TEXT = (
        "# Changelog\n\n"
        "## [v1.5.0] - 2026-01-02\n\nNew thing.\n\n### Fixed\n\n- A bug.\n\n"
        "## 1.4.0\n\nOlder thing.\n"
    )

    def test_finds_the_section_for_a_version(self):
        section = uuv.changelog_section(self.TEXT, "1.5.0")
        self.assertIn("New thing.", section)
        self.assertIn("A bug.", section)
        self.assertNotIn("Older thing.", section)

    def test_missing_version_returns_empty(self):
        self.assertEqual(uuv.changelog_section(self.TEXT, "9.9.9"), "")


class InsertNoteBlock(unittest.TestCase):
    CHANGELOG = "# Changelog\n\n## 1.2.3\n\n- Upgrading from upstream version 1.2.2 -> 1.2.3\n\n## 1.2.2\n\n- Old.\n"

    def test_adds_notes_under_the_matching_version_only(self):
        out = uuv.insert_note_block(self.CHANGELOG, "1.2.3", "> Upstream notes")
        self.assertLess(out.index("> Upstream notes"), out.index("## 1.2.2"))

    def test_is_idempotent(self):
        once = uuv.insert_note_block(self.CHANGELOG, "1.2.3", "> Upstream notes")
        again = uuv.insert_note_block(once, "1.2.3", "> Upstream more")
        self.assertEqual(once, again)

    def test_unknown_version_changes_nothing(self):
        self.assertEqual(uuv.insert_note_block(self.CHANGELOG, "9.9.9", "> x"), self.CHANGELOG)


if __name__ == "__main__":
    unittest.main()
