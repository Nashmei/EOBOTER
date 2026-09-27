import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

class AuditLog:
    def __init__(self, path: str = "logs/audit.jsonl") -> None:
        self.path = Path(path)

    def write(self, event: str, payload: dict[str, Any]) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        row = {"ts": datetime.now(timezone.utc).isoformat(), "event": event, "payload": payload}
        with self.path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(row, ensure_ascii=False) + "\n")
