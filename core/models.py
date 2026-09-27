from datetime import datetime, timezone
from enum import Enum
from pydantic import BaseModel, Field


class Direction(str, Enum):
    UP = "up"
    DOWN = "down"


class Signal(BaseModel):
    asset: str = Field(min_length=1, max_length=40)
    direction: Direction
    confidence: float = Field(ge=0.0, le=1.0)
    expiry_seconds: int = Field(ge=5, le=3600)
    reason: str = Field(default="", max_length=500)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class TradeRequest(BaseModel):
    asset: str
    direction: Direction
    stake: float = Field(gt=0)
    expiry_seconds: int = Field(ge=5, le=3600)
    expected_payout: float = Field(ge=0.0, le=1.0)


class TradeResult(BaseModel):
    accepted: bool
    trade_id: str | None = None
    reason: str = ""
