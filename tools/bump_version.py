import sys

# The GitHub label passed as an argument: patch, minor, major, release
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
    parts = v.split(".")  # Split into ['0', '5', '0-draft']
    major = int(parts[0])
    minor = int(parts[1])

    # Handle patch number and suffix(if exist)
    if "-" in parts[2]:
        patch_str, suffix = parts[2].split("-", 1)  
        patch = int(patch_str)
        suffix = "-" + suffix  # Keep the dash in the suffix
    else:
        patch = int(parts[2])
        suffix = ""

    return major, minor, patch, suffix


def bump_version(major, minor, patch):
    """
    Increment the version based on LABEL:
    - patch: increment patch
    - minor: increment minor, reset patch
    - major: increment major, reset minor and patch
    """
    if LABEL == "patch":
        patch = patch + 1
    elif LABEL == "minor":
        minor = minor + 1
        patch = 0
    elif LABEL == "major":
        major = major + 1
        minor = 0
        patch = 0
    return major, minor, patch

def main():
    # Read current version
    old_version = read_version()
    
    # Parse current version
    major, minor, patch, suffix = parse_version(old_version)

    # If label is release, remove the "-draft" suffix
    if LABEL == "release":
        new_version = f"{major}.{minor}.{patch}" 
    else:
        # Otherwise, bump version according to label
        new_major, new_minor, new_patch = bump_version(major, minor, patch)
        new_version = f"{new_major}.{new_minor}.{new_patch}-draft"

    # Prevent race conditions by only writing if version changed
    if new_version != old_version:
        write_version(new_version)
        print(f"Version updated: {old_version} -> {new_version}")
    else:
        print(f"No version change needed. Current version: {old_version}")

if __name__ == "__main__":
    main()
