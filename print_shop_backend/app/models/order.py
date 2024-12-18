from pydantic import BaseModel
from datetime import datetime
from typing import Dict, Any
from enum import Enum

class OrderStatus(str, Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"

class PrintConfig(BaseModel):
    paper_size: str
    is_color: bool
    is_duplex: bool
    copies: int

class Order(BaseModel):
    id: str
    document_name: str
    status: OrderStatus
    config: PrintConfig
    created_at: datetime = datetime.now()