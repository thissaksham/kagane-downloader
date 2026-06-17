"""
Download Worker - Background thread for downloading chapters using API
"""

import sys
import json
import time
from pathlib import Path
from PyQt6.QtCore import QThread, pyqtSignal

# Add parent directory to path to import src modules
ROOT_DIR = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT_DIR))

from config import get_config
from src.scraper import Series, Book
from src.scraper.api_downloader import APIChapterDownloader, get_reader_url
from src.scraper.browser import BrowserManager
from src.converter import create_pdf, create_cbz


class DownloadWorker(QThread):
    """Background worker for downloading chapters using API (sequential)"""
    
    # Signals
    progress = pyqtSignal(int, int, str)  # current, total, message
    chapterComplete = pyqtSignal(str, bool)  # chapter_number, success
    finished = pyqtSignal(int, int)  # success_count, total_count
    error = pyqtSignal(str)
    
    def __init__(self, series: Series, chapters: list[Book], parent=None):
        super().__init__(parent)
        self.series = series
        self.chapters = chapters
        self._stop_requested = False
    
    def run(self):
        """Run the download in background thread (sequential with browser restart per chapter)"""
        config = get_config()
        success_count = 0
        
        try:
            # Create download directory
            download_dir = Path(config.download_directory)
            download_dir.mkdir(parents=True, exist_ok=True)
            
            # Create downloader
            downloader = APIChapterDownloader(
                download_dir=download_dir,
                max_concurrent_images=config.max_concurrent_images,
                max_retries=config.max_retries
            )
            
            results = []
            
            browser = None
            driver = None
            try:
                # Initialize browser once for all chapters to save startup and Cloudflare validation overhead
                try:
                    browser = BrowserManager()
                    browser.init_browser(headless=config.headless_mode, enable_network_logs=True)
                    driver = browser.get_driver()
                except Exception as e:
                    self.error.emit(f"Failed to initialize browser: {e}")
                    return
                
                # Process chapters sequentially
                for idx, book in enumerate(self.chapters):
                    if self._stop_requested:
                        break
                    
                    self.progress.emit(idx, len(self.chapters), f"Loading Chapter {book.chapter_no}...")
                    
                    # Create chapter directory
                    safe_title = downloader.sanitize_filename(self.series.title, max_length=50)
                    safe_chapter = downloader.sanitize_filename(f"Chapter_{book.chapter_no}_{book.title}", max_length=80)
                    chapter_dir = download_dir / safe_title / safe_chapter
                    chapter_dir.mkdir(parents=True, exist_ok=True)
                    
                    try:
                        # Navigate directly to reader page
                        reader_url = get_reader_url(self.series.series_id, book.book_id)
                        driver.get(reader_url)
                        
                        # Set localStorage preferences directly on reader page for preloading (for subsequent pages / fallback)
                        try:
                            driver.execute_script("""
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
                            """)
                        except Exception:
                            pass

                        image_urls = []
                        
                        # Try to extract URLs directly from sessionStorage (extremely fast and ordered)
                        start_time = time.time()
                        while time.time() - start_time < 30:  # 30 seconds max wait to accommodate Turnstile bypass
                            try:
                                tokens_json = driver.execute_script("return sessionStorage.getItem('kagane_drm_tokens');")
                                if tokens_json:
                                    tokens_data = json.loads(tokens_json)
                                    key = f"{self.series.series_id}:{book.book_id}"
                                    if key in tokens_data:
                                        book_data = tokens_data[key]
                                        token = book_data["token"]
                                        cache_url = book_data.get("cacheUrl", "https://kstatic.to")
                                        pages = book_data["pages"]
                                        
                                        # Construct all URLs directly in proper order
                                        for p in sorted(pages, key=lambda x: x["page_no"]):
                                            page_id = p["page_id"]
                                            ext = p["ext"]
                                            url = f"{cache_url}/api/v2/books/page/{book.book_id}/{page_id}.{ext}?token={token}"
                                            image_urls.append(url)
                                        break
                            except Exception:
                                pass
                            time.sleep(0.5)
                        
                        # Fallback to scrolling and network logs if sessionStorage is unavailable
                        if not image_urls:
                            # Scroll loop to trigger lazy loading
                            try:
                                page_count = driver.execute_script("return document.querySelectorAll('.page-container').length;") or book.page_count
                                for page_num in range(1, page_count + 1):
                                    driver.execute_script(
                                        "const el = document.querySelector('.page-container[data-page=\"' + arguments[0] + '\"]'); if (el) el.scrollIntoView({behavior: 'instant', block: 'center'});",
                                        page_num
                                    )
                                    time.sleep(0.15)  # slightly slower to ensure requests trigger
                            except Exception:
                                pass
                                
                            time.sleep(config.image_load_delay)
                            
                            logs = driver.get_log("performance")
                            for entry in logs:
                                try:
                                    log = json.loads(entry["message"])["message"]
                                    if log["method"] == "Network.requestWillBeSent":
                                        url = log["params"]["request"]["url"]
                                        if "kstatic.to/api/v2/books/page/" in url:
                                            if url not in image_urls:
                                                image_urls.append(url)
                                except (json.JSONDecodeError, KeyError):
                                    continue
                        
                        if not image_urls:
                            results.append((book, False, chapter_dir, 0))
                            self.chapterComplete.emit(book.chapter_no, False)
                            continue
                        
                        self.progress.emit(idx, len(self.chapters), f"Ch.{book.chapter_no}: Downloading {len(image_urls)} images...")
                        
                        # Download images
                        pages_downloaded = downloader.download_from_urls(image_urls, chapter_dir)
                        
                        success = pages_downloaded > 0
                        results.append((book, success, chapter_dir, pages_downloaded))
                        self.chapterComplete.emit(book.chapter_no, success)
                        
                    except Exception as e:
                        results.append((book, False, chapter_dir, 0))
                        self.chapterComplete.emit(book.chapter_no, False)
            finally:
                # Close browser once at the end of all downloads
                if browser:
                    try:
                        browser.close_browser()
                    except:
                        pass
            
            # Convert files if needed
            if config.download_format in ("pdf", "cbz") and not self._stop_requested:
                self.progress.emit(len(self.chapters), len(self.chapters), f"Converting to {config.download_format.upper()}...")
                for book, success, chapter_dir, _ in results:
                    if self._stop_requested:
                        break
                    if success and chapter_dir and chapter_dir.exists():
                        try:
                            if config.download_format == "pdf":
                                create_pdf(chapter_dir, delete_images=not config.keep_images)
                            elif config.download_format == "cbz":
                                create_cbz(chapter_dir, series=self.series, book=book, delete_images=not config.keep_images)
                        except Exception:
                            pass  # Conversion error, continue
            
            # Count successes
            for _, success, _, _ in results:
                if success:
                    success_count += 1
            
            downloader.close()
            
            self.finished.emit(success_count, len(self.chapters))
            
        except Exception as e:
            self.error.emit(str(e))
    
    def stop(self):
        """Request stop"""
        self._stop_requested = True
        self.terminate()
