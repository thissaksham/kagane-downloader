"""
Scraper Package - API client, data models, and chapter downloading

- KaganeScraper: High-level API scraper
- KaganeAPIClient: Low-level API client
- Series, Book, etc.: Data models from API
- APIChapterDownloader / download_chapter: Downloads chapter images
- BrowserManager: Browser automation for the reader page
"""

from .api_client import KaganeAPIClient, APIConfig
from .api_models import (
    Series, Book, Genre, Tag, AlternateTitle,
    Group, Uploader, SeriesCover, SeriesLink, SeriesStaff,
    parse_series, get_image_url, IMAGE_BASE_URL
)
from .api_scraper import KaganeScraper, fetch_series
from .api_downloader import (
    APIChapterDownloader,
    download_chapter,
    fetch_chapter_image_urls,
    get_reader_url,
)
from .browser import BrowserManager

__all__ = [
    "KaganeAPIClient",
    "APIConfig",
    "Series",
    "Book",
    "Genre",
    "Tag",
    "AlternateTitle",
    "Group",
    "Uploader",
    "SeriesCover",
    "SeriesLink",
    "SeriesStaff",
    "parse_series",
    "get_image_url",
    "IMAGE_BASE_URL",
    "KaganeScraper",
    "fetch_series",
    "APIChapterDownloader",
    "download_chapter",
    "fetch_chapter_image_urls",
    "get_reader_url",
    "BrowserManager",
]
