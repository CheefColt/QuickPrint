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

class OrderBase(BaseModel):
    filename: str
    status: OrderStatus = OrderStatus.PENDING
    config: PrintConfig

    class Config:
        from_attributes = True

class OrderCreate(OrderBase):
    pass

class Order(OrderBase):
    id: str
    timestamp: datetime = datetime.now()