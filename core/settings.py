import os
from typing import Literal
from pydantic import BaseModel,Field
class Settings(BaseModel):
    mode: Literal["demo"]="demo"
    log_level: str="INFO"
    default_expiry_seconds: int=Field(default=60,ge=5,le=3600)
    default_payout: float=Field(default=.80,ge=0,le=1)
    @classmethod
    def from_env(cls):
        return cls(log_level=os.getenv("EOBOTER_LOG_LEVEL","INFO"),default_expiry_seconds=int(os.getenv("EOBOTER_EXPIRY_SECONDS","60")),default_payout=float(os.getenv("EOBOTER_PAYOUT","0.80")))
