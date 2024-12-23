from pydantic import BaseModel
from datetime import datetime
from .print_config import PrintConfig

class Order(BaseModel):
    id: str
    filename: str
    config: PrintConfig
    status: str
    timestamp: datetime