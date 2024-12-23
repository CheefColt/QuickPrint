from datetime import datetime
from pydantic import BaseModel
from enum import Enum
from typing import Optional

class PrintConfig(BaseModel):
    copies: int = 1
    color: bool = False
    double_sided: bool = False

class OrderStatus(str, Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"

class OrderCreate(BaseModel):
    filename: str
    config: PrintConfig

class Order(BaseModel):
    id: str
    filename: str
    status: OrderStatus = OrderStatus.PENDING
    config: PrintConfig
    timestamp: datetime = datetime.now()

    class Config:
        from_attributes = True