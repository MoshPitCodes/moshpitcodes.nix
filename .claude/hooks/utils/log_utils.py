"""Logging utilities for Claude Code hooks."""

import json
import logging
import os
from datetime import datetime
from pathlib import Path
from typing import Any, Dict


def setup_logger(name: str, log_file: str = None) -> logging.Logger:
    """Set up a logger for hook scripts."""
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)

    if log_file:
        handler = logging.FileHandler(log_file)
        handler.setLevel(logging.DEBUG)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        logger.addHandler(handler)

    return logger


def log_to_jsonl(log_file: Path, data: Dict[str, Any]) -> None:
    """Append a JSON line to a log file."""
    try:
        # Ensure log directory exists
        log_file.parent.mkdir(parents=True, exist_ok=True)

        # Add timestamp if not present
        if 'timestamp' not in data:
            data['timestamp'] = datetime.now().isoformat()

        # Append to JSONL file
        with open(log_file, 'a') as f:
            f.write(json.dumps(data) + '\n')
    except Exception as e:
        # Don't fail the hook if logging fails
        pass
