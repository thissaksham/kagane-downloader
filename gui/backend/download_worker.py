"""
Download Worker - Background thread for downloading chapters using API
"""

import sys
from pathlib import Path
from PyQt6.QtCore import QThread, pyqtSignal

# Add parent directory to path to import src modules
ROOT_DIR = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT_DIR))

from config import get_config
from src.scraper import Series, Book
from src.scraper.api_downloader import APIChapterDownloader, download_chapter
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
        """Run the download in background thread (sequential, one browser for all chapters)"""
        config = get_config()

        try:
            download_dir = Path(config.download_directory)
            download_dir.mkdir(parents=True, exist_ok=True)

            downloader = APIChapterDownloader(
                download_dir=download_dir,
                max_concurrent_images=config.max_concurrent_images,
                max_retries=config.max_retries
            )

            results = []
            browser = None
            try:
                # Initialize browser once for all chapters to save startup and Cloudflare validation overhead
                try:
                    browser = BrowserManager()
                    driver = browser.init_browser(headless=config.headless_mode, enable_network_logs=True)
                except Exception as e:
                    self.error.emit(f"Failed to initialize browser: {e}")
                    return

                for idx, book in enumerate(self.chapters):
                    if self._stop_requested:
                        break

                    self.progress.emit(idx, len(self.chapters), f"Downloading Chapter {book.chapter_no}...")

                    try:
                        success, chapter_dir, pages = download_chapter(
                            driver, downloader, self.series, book, download_dir,
                            image_load_delay=config.image_load_delay
                        )
                    except Exception:
                        success, chapter_dir, pages = False, None, 0

                    results.append((book, success, chapter_dir, pages))
                    self.chapterComplete.emit(book.chapter_no, success)
            finally:
                # Close browser once at the end of all downloads
                if browser:
                    try:
                        browser.close_browser()
                    except Exception:
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

            success_count = sum(1 for _, success, _, _ in results if success)
            downloader.close()

            self.finished.emit(success_count, len(self.chapters))

        except Exception as e:
            self.error.emit(str(e))

    def stop(self):
        """Request stop; the loop exits after the current chapter finishes.

        Never terminate() this thread: that skips the finally block and
        leaks the Chrome/chromedriver processes.
        """
        self._stop_requested = True
