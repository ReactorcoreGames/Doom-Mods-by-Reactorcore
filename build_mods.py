#!/usr/bin/env python3
"""
Dynamic Build Script for ZDoom Mods
Creates .pk3 files from all mod folders (excludes folders starting with !)
"""

import os
import zipfile
from pathlib import Path


def zip_folder(folder_path, output_path):
    """Zip all contents of a folder."""
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                file_path = os.path.join(root, file)
                # Get the path relative to the folder being zipped
                arcname = os.path.relpath(file_path, folder_path)
                zipf.write(file_path, arcname)


def main():
    print("Building all ZDoom mods...")
    print()

    # Get the script's directory (workspace root)
    workspace_root = Path(__file__).parent

    # Find all directories in the workspace root
    folders = [f for f in workspace_root.iterdir()
               if f.is_dir() and not f.name.startswith('!')]

    if not folders:
        print("No mod folders found to build.")
        return

    total_count = len(folders)

    # Build each mod
    for index, folder in enumerate(folders, start=1):
        # Replace spaces with underscores for the output filename
        output_name = folder.name.replace(' ', '_') + '.pk3'
        output_path = workspace_root / output_name

        print(f"[{index}/{total_count}] Building {output_name}...")

        # Create the zip and rename to .pk3
        zip_folder(folder, output_path)

        print(f"      Done: {output_name}")

    print()
    print("=" * 76)
    print(f"Build complete! Built {total_count} mod(s)")
    print("=" * 76)
    print()
    print("You can now load these .pk3 files in GZDoom!")
    print()

    input("Press Enter to exit...")


if __name__ == "__main__":
    main()
