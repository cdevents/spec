#!/usr/bin/env python3

import sys
from pathlib import Path
from semver import VersionInfo

VERSION_FILE = Path("version.txt")

SCHEMA_DIRS = ["schemas", "custom"]
CONFORMANCE_DIRS = ["conformance", "custom"]
DOC_FILES = ["cloudevents-binding.md", "spec.md", "links.md"]
README_FILE = "README.md"

# Utilities

def read_version() -> VersionInfo:
    if not VERSION_FILE.exists():
        sys.exit(f"{VERSION_FILE} not found")
    try:
        return VersionInfo.parse(VERSION_FILE.read_text().strip())
    except ValueError as e:
        sys.exit(f"Invalid version: {e}")

def write_version(version: VersionInfo):
    VERSION_FILE.write_text(f"{version}\n")

def replace_all(files, old: str, new: str):
    for f in files:
        p = Path(f)
        if p.exists():
            p.write_text(p.read_text().replace(old, new))

def find_files(dirs, suffix=".json"):
    return [
        f for d in dirs if Path(d).exists()
        for f in Path(d).rglob(f"*{suffix}")
    ]

# Version transitions

def compute_next_version(old: VersionInfo, action: str, value=None) -> VersionInfo:
    """
    Compute next version based on the action:
    - major: bump major, reset minor & patch
    - minor: bump minor, reset patch
    - patch: bump patch
    - set: set to exact version
    """
    if action == "set":
        try:
            return VersionInfo.parse(value)
        except ValueError as e:
            sys.exit(f"Invalid version: {e}")

    if action == "major":
        return old.bump_major()
    if action == "minor":
        return old.bump_minor()
    if action == "patch":
        return old.bump_patch()

    sys.exit(f"Unknown action: {action}")

# Repository updates

def update_repository(old: VersionInfo, new: VersionInfo):
    old_v, new_v = str(old), str(new)

    # Update schema references
    replace_all(
        find_files(SCHEMA_DIRS),
        f"https://cdevents.dev/{old_v}/schema/",
        f"https://cdevents.dev/{new_v}/schema/",
    )

    # Update conformance files
    replace_all(
        find_files(CONFORMANCE_DIRS),
        f'"version": "{old_v}"',
        f'"version": "{new_v}"',
    )

    # Update documentation files
    replace_all(
        DOC_FILES,
        f'"version": "{old_v}"',
        f'"version": "{new_v}"',
    )

    # Update README
    replace_all([README_FILE], f"v{old_v}", f"v{new_v}")

# CLI

def parse_action():
    """
    Get release action from command-line arguments.
    Usage:
        python release.py major
        python release.py minor
        python release.py patch
        python release.py set=X.Y.Z
    """
    if len(sys.argv) < 2:
        sys.exit("Usage: release.py <major|minor|patch|set=X.Y.Z>")

    arg = sys.argv[1].lower()

    if arg in ("major", "minor", "patch"):
        return arg, None

    if arg.startswith("set="):
        return "set", arg.split("=", 1)[1]

    sys.exit(f"Unknown action: {arg}")

# Main

def main():
    action, value = parse_action()
    old = read_version()
    new = compute_next_version(old, action, value)
    update_repository(old, new)
    write_version(new)
    print(f"Version updated: {old} -> {new}")

if __name__ == "__main__":
    main()
