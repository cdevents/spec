import pytest
from semver import VersionInfo
from tools.spec_release import compute_next_version

# start release

def test_start_minor_release_from_stable():
    v = VersionInfo.parse("1.2.3")
    new = compute_next_version(v, "minor")
    assert new.major == 1
    assert new.minor == 3  # bump minor
    assert new.patch == 0

def test_start_major_release_from_stable():
    v = VersionInfo.parse("1.2.3")
    new = compute_next_version(v, "major")
    assert new.major == 2  # bump major
    assert new.minor == 0
    assert new.patch == 0

def test_start_release_invalid_action():
    v = VersionInfo.parse("1.2.3")
    with pytest.raises(SystemExit):
        compute_next_version(v, "invalid-action")

# patch release

def test_patch_release_from_stable():
    v = VersionInfo.parse("1.2.3")
    new = compute_next_version(v, "patch")
    assert str(new) == "1.2.4"

# set version

def test_set_version_valid():
    v = compute_next_version(VersionInfo.parse("0.0.0"), "set", "2.0.1")
    assert str(v) == "2.0.1"

def test_set_version_invalid():
    with pytest.raises(SystemExit):
        compute_next_version(VersionInfo.parse("0.0.0"), "set", "not-a-version")
