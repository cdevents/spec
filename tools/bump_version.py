import sys

# The GitHub label passed as an argument: patch, minor, major
LABEL = sys.argv[1]  

# The file that stores the current version
VERSION_FILE = "version.txt"

def read_version():
    """Read the current version from version.txt"""
    with open(VERSION_FILE, "r") as f:
        return f.read().strip()

def write_version(version):
    """Write the new version back to version.txt"""
    with open(VERSION_FILE, "w") as f:
        f.write(version + "\n")

def parse_version(v):
    """
    Parse a version string like "0.5.0-draft" into parts:
    major, minor, patch, and optional suffix (e.g., "-draft").
    """
    # Remove suffix if present
    v = v.split("-", 1)[0]

    parts = v.split(".")  # Split into ['0', '5', '0']

    major = int(parts[0])
    minor = int(parts[1])
    patch = int(parts[2])

    return major, minor, patch


def bump_version(major, minor, patch):
    """
    Increment the version based on LABEL:
    - patch: increment patch
    - minor: increment minor, reset patch
    - major: increment major, reset minor and patch
    """
    new_major = major
    new_minor = minor
    new_patch = patch

    if LABEL == "patch":
        new_patch = patch + 1
    elif LABEL == "minor":
        new_minor = minor + 1
        new_patch = 0
    elif LABEL == "major":
        new_major = major + 1
        new_minor = 0
        new_patch = 0
    else:
        raise ValueError(f"Invalid Label: {LABEL}")
    return new_major, new_minor, new_patch

def main():
    # Read current version
    old_version = read_version()
    
    # Parse current version
    major, minor, patch = parse_version(old_version)

    new_major, new_minor, new_patch = bump_version(major, minor, patch)
    new_version = f"{new_major}.{new_minor}.{new_patch}"

    # Prevent race conditions by only writing if version changed
    if new_version != old_version:
        write_version(new_version)
        print(f"Version updated: {old_version} -> {new_version}")
    else:
        print(f"No version change needed. Current version: {old_version}")

if __name__ == "__main__":
    main()
