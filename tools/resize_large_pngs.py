import os
import sys
from PIL import Image
from typing import List

def find_large_pngs(root_directory: str, max_width: int = 1024) -> List[str]:
    large_pngs = []
    for dirpath, _, filenames in os.walk(root_directory):
        for file in filenames:
            if file.lower().endswith(".png"):
                filepath = os.path.abspath(os.path.join(dirpath, file))
                with Image.open(filepath) as img:
                    if img.width > max_width:
                        large_pngs.append(filepath)
    return large_pngs

def resize_file(png_path: str, max_width: int = 1024) -> None:
    with Image.open(png_path) as img:
        if img.width > max_width:
            scale_ratio = max_width / img.width
            new_size = (max_width, int(img.height * scale_ratio))
            resized_img = img.resize(new_size, Image.LANCZOS)
            resized_img.save(png_path)

def resize_pngs(filepaths: List[str], max_width: int = 1024) -> None:
    for path in filepaths:
        if path.lower().endswith(".png"):
            resize_file(path, max_width)

def main():
    root_directory = os.getcwd() if len(sys.argv) < 2 else sys.argv[1]
    max_width = int(sys.argv[2]) if len(sys.argv) > 2 else 1024

    print(f"Are you sure you want to resize all .png images in '{os.path.abspath(root_directory)}' that are greater than {max_width} pixels to {max_width} pixels? [y/N]")
    confirmation = input().strip().lower()
    if confirmation != 'y':
        print("Operation cancelled.")
        sys.exit(0)

    large_pngs = find_large_pngs(root_directory, max_width)
    resize_pngs(large_pngs, max_width)
    print(f"Resized {len(large_pngs)} images to a max width of {max_width}.")

if __name__ == "__main__":
    main()
