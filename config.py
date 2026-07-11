"""
Configuration management for Kagane Downloader
"""

import json
from dataclasses import dataclass, asdict, fields
from pathlib import Path
from typing import Literal


CONFIG_FILE = Path("config.json")


@dataclass
class Config:
    """Application configuration settings"""

    # Download format: images, pdf, cbz
    download_format: Literal["images", "pdf", "cbz"] = "cbz"

    # Keep original images after PDF/CBZ conversion
    keep_images: bool = False

    # Max concurrent image downloads per chapter
    max_concurrent_images: int = 10

    # Max chapters to display in the CLI (0 = show all)
    max_display_chapters: int = 0

    # Download directory path
    download_directory: str = "downloads"

    # Enable/disable logging
    enable_logs: bool = False

    # Seconds to wait for pages to load (fallback capture path only)
    image_load_delay: int = 60

    # Max retries for failed image downloads
    max_retries: int = 5

    # Run browser in headless mode (hidden) or visible.
    # Off by default: Cloudflare's Turnstile check does not clear in headless
    # Chrome, which makes every download come back empty.
    headless_mode: bool = False

    # Use legacy headless mode (--headless) instead of new (--headless=new)
    use_legacy_headless: bool = False

    def save(self) -> None:
        """Save configuration to file"""
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(asdict(self), f, indent=2)

    @classmethod
    def load(cls) -> "Config":
        """Load configuration from file, or create default if not exists"""
        if not CONFIG_FILE.exists():
            return cls()
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
            # Ignore unknown keys so configs from older versions still load
            known = {f.name for f in fields(cls)}
            config = cls(**{k: v for k, v in data.items() if k in known})
            # Clamp values that would break downloads (e.g. 0 thread pool workers)
            config.max_concurrent_images = max(1, int(config.max_concurrent_images))
            config.max_retries = max(1, int(config.max_retries))
            config.image_load_delay = max(1, int(config.image_load_delay))
            return config
        except (json.JSONDecodeError, TypeError, ValueError):
            # Fall back to defaults if the file is corrupted
            return cls()


def get_config() -> Config:
    """Get the current configuration"""
    return Config.load()


def save_config(config: Config) -> None:
    """Save the configuration"""
    config.save()
