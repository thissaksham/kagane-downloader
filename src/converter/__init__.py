"""
Converter Package - PDF and CBZ generation
"""

from pathlib import Path

from .pdf import create_pdf
from .cbz import create_cbz


def convert_chapter(chapter_dir: Path, download_format: str, series=None, book=None, keep_images: bool = False):
    """Convert a downloaded chapter folder to the configured format (no-op for images)."""
    if download_format == "pdf":
        create_pdf(chapter_dir, delete_images=not keep_images)
    elif download_format == "cbz":
        create_cbz(chapter_dir, series=series, book=book, delete_images=not keep_images)


__all__ = ["create_pdf", "create_cbz", "convert_chapter"]
