"""
CBZ archive creation with ComicInfo.xml metadata
"""

import zipfile
from pathlib import Path
from typing import Optional
from xml.etree import ElementTree as ET

from src.scraper.api_models import Series, Book


def generate_comic_info_api(
    series: Series,
    book: Book,
    page_count: int
) -> str:
    """
    Generate ComicInfo.xml content for a chapter (API models).
    
    Args:
        series: Series information
        book: Book/chapter information
        page_count: Number of pages in the chapter
        
    Returns:
        XML string for ComicInfo.xml
    """
    root = ET.Element("ComicInfo")
    root.set("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
    root.set("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
    
    # Title
    ET.SubElement(root, "Title").text = book.title or f"Chapter {book.chapter_no}"
    
    # Series
    ET.SubElement(root, "Series").text = series.title
    
    # Number (chapter number)
    if book.chapter_no:
        ET.SubElement(root, "Number").text = book.chapter_no
    
    # Summary/Description
    if series.description:
        ET.SubElement(root, "Summary").text = series.description
    
    # Genre
    if series.genres:
        genre_names = [g.genre_name for g in series.genres if not g.is_spoiler]
        ET.SubElement(root, "Genre").text = ", ".join(genre_names)
    
    # Page count
    ET.SubElement(root, "PageCount").text = str(page_count)
    
    # Web (reader URL)
    reader_url = f"https://kagane.to/series/{series.series_id}/reader/{book.book_id}"
    ET.SubElement(root, "Web").text = reader_url
    
    # Manga reading direction
    ET.SubElement(root, "Manga").text = "Yes"
    
    # Status
    if series.publication_status:
        status_map = {
            "Ongoing": "Ongoing",
            "Ended": "Ended",
            "Hiatus": "Hiatus"
        }
        ET.SubElement(root, "Series.Status").text = status_map.get(series.publication_status, series.publication_status)
    
    # AgeRating for adult content
    if series.content_rating and series.content_rating.lower() not in ["safe", ""]:
        ET.SubElement(root, "AgeRating").text = "Adults Only 18+"
    
    # Generate XML string with declaration
    xml_str = '<?xml version="1.0" encoding="utf-8"?>\n'
    xml_str += ET.tostring(root, encoding='unicode')
    
    return xml_str


def create_cbz(
    image_dir: Path,
    output_path: Optional[Path] = None,
    series: Optional[Series] = None,
    book: Optional[Book] = None,
    delete_images: bool = False
) -> Path:
    """
    Create a CBZ archive from images in a directory.

    Args:
        image_dir: Directory containing images
        output_path: Path for the output CBZ (default: same dir with .cbz extension)
        series: Optional Series for ComicInfo.xml generation
        book: Optional Book for ComicInfo.xml generation
        delete_images: Whether to delete source images after CBZ creation

    Returns:
        Path to the created CBZ file
    """
    if output_path is None:
        output_path = image_dir.parent / f"{image_dir.name}.cbz"
    
    # Get all image files sorted
    image_extensions = {'.png', '.jpg', '.jpeg', '.webp', '.gif'}
    images = sorted(
        [f for f in image_dir.iterdir() if f.is_file() and f.suffix.lower() in image_extensions],
        key=lambda p: p.stem
    )
    
    if not images:
        raise ValueError(f"No images found in {image_dir}")
    
    # Create CBZ (which is just a zip file)
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as cbz:
        # Add ComicInfo.xml if we have metadata
        if series and book:
            comic_info = generate_comic_info_api(series, book, len(images))
            cbz.writestr("ComicInfo.xml", comic_info.encode('utf-8'))
        
        # Add images
        for img_path in images:
            # Add with just the filename (flat structure)
            cbz.write(img_path, img_path.name)
    
    # Delete original images if requested
    if delete_images:
        for img_path in images:
            try:
                img_path.unlink()
            except Exception:
                pass
        
        # Try to remove the directory if empty
        try:
            image_dir.rmdir()
        except Exception:
            pass
    
    return output_path
