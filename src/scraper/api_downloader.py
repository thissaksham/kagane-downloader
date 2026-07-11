"""
API-based Chapter Downloader
Captures image URLs from the reader page and downloads them directly
"""

import json
import time
from curl_cffi import requests
from pathlib import Path
from typing import Callable, Optional
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass

from .api_models import Book, Series
from ..utils.sanitize import sanitize_filename


@dataclass
class DownloadResult:
    """Result of a chapter download"""
    book: Book
    success: bool
    chapter_dir: Path
    pages_downloaded: int
    error: Optional[str] = None


class APIChapterDownloader:
    """
    Downloads chapter images using captured network URLs.

    The approach:
    1. Open the reader page in a browser
    2. Capture the image URLs (sessionStorage token store, or network logs)
    3. Download images directly using requests
    """

    IMAGE_URL_PATTERN = "kstatic.to/api/v2/books/page/"

    sanitize_filename = staticmethod(sanitize_filename)

    def __init__(
        self,
        download_dir: Path,
        max_concurrent_images: int = 10,
        max_retries: int = 3,
        request_timeout: int = 30
    ):
        self.download_dir = download_dir
        self.max_concurrent_images = max_concurrent_images
        self.max_retries = max_retries
        self.request_timeout = request_timeout

        # Create a session for downloading
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Accept": "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
            "Referer": "https://kagane.to/"
        })

    def download_image(self, url: str, output_path: Path) -> bool:
        """Download a single image with retries"""
        for attempt in range(self.max_retries):
            try:
                response = self.session.get(url, timeout=self.request_timeout, stream=True, impersonate="chrome110")
                response.raise_for_status()

                # Determine file extension from content-type or URL
                content_type = response.headers.get('content-type', '')
                if 'webp' in content_type:
                    ext = '.webp'
                elif 'jpeg' in content_type or 'jpg' in content_type:
                    ext = '.jpg'
                elif 'png' in content_type:
                    ext = '.png'
                else:
                    # Try to get from URL
                    if '.webp' in url.lower():
                        ext = '.webp'
                    elif '.jpg' in url.lower() or '.jpeg' in url.lower():
                        ext = '.jpg'
                    elif '.png' in url.lower():
                        ext = '.png'
                    else:
                        ext = '.webp'  # Default to webp

                # Update path with correct extension
                final_path = output_path.with_suffix(ext)

                with open(final_path, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)

                return True

            except Exception:
                if attempt < self.max_retries - 1:
                    time.sleep(1)
                continue

        return False

    def download_from_urls(
        self,
        image_urls: list[str],
        output_dir: Path,
        progress_callback: Optional[Callable[[int, int], None]] = None,
        should_stop: Optional[Callable[[], bool]] = None
    ) -> int:
        """
        Download images from a list of URLs. Files are numbered by the
        order of the list, so callers must pass URLs in page order.

        Args:
            image_urls: List of image URLs to download
            output_dir: Directory to save images
            progress_callback: Optional callback(done, total); called from worker threads
            should_stop: Optional callback; when it returns True, pending downloads are cancelled

        Returns:
            Number of successfully downloaded images
        """
        output_dir.mkdir(parents=True, exist_ok=True)
        total = len(image_urls)
        downloaded = 0

        with ThreadPoolExecutor(max_workers=self.max_concurrent_images) as executor:
            futures = {}

            for idx, url in enumerate(image_urls, 1):
                output_path = output_dir / f"{idx:03d}"
                future = executor.submit(self.download_image, url, output_path)
                futures[future] = idx

            for future in as_completed(futures):
                if should_stop and should_stop():
                    for f in futures:
                        f.cancel()
                    break
                if future.result():
                    downloaded += 1
                    if progress_callback:
                        progress_callback(downloaded, total)

        return downloaded

    def close(self):
        """Close the session"""
        self.session.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()


def get_reader_url(series_id: str, book_id: str) -> str:
    """Generate the reader URL for a book"""
    return f"https://kagane.to/series/{series_id}/reader/{book_id}"


# Reader preferences that make the page preload every image (helps the fallback path)
_PRELOAD_PREFS_JS = """
    try {
        const key = 'kagane-user-preferences';
        const prefs = JSON.parse(localStorage.getItem(key) || '{}');
        prefs.preloadPagesEnabled = true;
        prefs.preloadMode = 'all';
        prefs.preloadPageCount = 100;
        prefs.readerPrefetchCount = 50;
        prefs.readerPrefetchDistance = 50;
        localStorage.setItem(key, JSON.stringify(prefs));
    } catch (e) {}
"""


def fetch_chapter_image_urls(
    driver,
    series_id: str,
    book_id: str,
    page_count: int = 0,
    image_load_delay: int = 30,
    log: Optional[Callable[[str], None]] = None,
    should_stop: Optional[Callable[[], bool]] = None
) -> list[str]:
    """
    Open the reader page and return the chapter's image URLs in page order.

    Fast path: read the DRM token store the reader writes to sessionStorage
    (waits up to 30s to accommodate the Turnstile check). Fallback: scroll
    the reader to trigger lazy loading and scrape Chrome's network logs.
    """
    stop = should_stop or (lambda: False)
    driver.get(get_reader_url(series_id, book_id))

    try:
        driver.execute_script(_PRELOAD_PREFS_JS)
    except Exception:
        pass

    deadline = time.time() + 30
    while time.time() < deadline:
        if stop():
            return []
        try:
            tokens_json = driver.execute_script("return sessionStorage.getItem('kagane_drm_tokens');")
            if tokens_json:
                book_data = json.loads(tokens_json).get(f"{series_id}:{book_id}")
                if book_data:
                    token = book_data["token"]
                    cache_url = book_data.get("cacheUrl", "https://kstatic.to")
                    pages = sorted(book_data["pages"], key=lambda p: p["page_no"])
                    return [
                        f"{cache_url}/api/v2/books/page/{book_id}/{p['page_id']}.{p['ext']}?token={token}"
                        for p in pages
                    ]
        except Exception:
            pass
        time.sleep(0.5)

    if log:
        log("sessionStorage empty, falling back to scroll capture")

    # Scroll every page container to force the image requests
    try:
        count = driver.execute_script("return document.querySelectorAll('.page-container').length;") or page_count
        for page_num in range(1, count + 1):
            if stop():
                return []
            driver.execute_script(
                "const el = document.querySelector('.page-container[data-page=\"' + arguments[0] + '\"]'); if (el) el.scrollIntoView({behavior: 'instant', block: 'center'});",
                page_num
            )
            time.sleep(0.15)
    except Exception:
        pass

    slept = 0.0
    while slept < image_load_delay:
        if stop():
            return []
        time.sleep(0.5)
        slept += 0.5

    # ponytail: request order tracks the scroll order above but is not guaranteed
    # page order; only the sessionStorage path is. Good enough as a last resort.
    image_urls = []
    for entry in driver.get_log("performance"):
        try:
            message = json.loads(entry["message"])["message"]
            if message["method"] == "Network.requestWillBeSent":
                url = message["params"]["request"]["url"]
                if APIChapterDownloader.IMAGE_URL_PATTERN in url and url not in image_urls:
                    image_urls.append(url)
        except (json.JSONDecodeError, KeyError):
            continue
    return image_urls


def download_chapter(
    driver,
    downloader: APIChapterDownloader,
    series: Series,
    book: Book,
    download_dir: Path,
    image_load_delay: int = 30,
    log: Optional[Callable[[str], None]] = None,
    should_stop: Optional[Callable[[], bool]] = None,
    page_progress: Optional[Callable[[int, int], None]] = None
) -> tuple[bool, Path, int]:
    """
    Download one chapter into <download_dir>/<series>/<chapter>/.

    Returns (success, chapter_dir, pages_downloaded).
    """
    safe_title = sanitize_filename(series.title, max_length=50)
    safe_chapter = sanitize_filename(f"Chapter_{book.chapter_no}_{book.title}", max_length=80)
    chapter_dir = download_dir / safe_title / safe_chapter
    chapter_dir.mkdir(parents=True, exist_ok=True)

    image_urls = fetch_chapter_image_urls(
        driver,
        series.series_id,
        book.book_id,
        page_count=book.page_count or 0,
        image_load_delay=image_load_delay,
        log=log,
        should_stop=should_stop
    )
    if not image_urls or (should_stop and should_stop()):
        return False, chapter_dir, 0

    pages = downloader.download_from_urls(
        image_urls, chapter_dir,
        progress_callback=page_progress,
        should_stop=should_stop
    )
    return pages > 0, chapter_dir, pages
