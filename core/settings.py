from typing import Literal
from pydantic import BaseModel


class Settings(BaseModel):
    mode: Literal["demo"] = "demo"
    log_level: str = "INFO"
