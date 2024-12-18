from dataclasses import dataclass
from datetime import datetime
import json
from typing import Dict, Any
from enum import Enum

class OrderStatus(Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"

@dataclass
class PrintConfig:
    paper_size: str
    is_color: bool
    is_duplex: bool
    copies: int
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'paper_size': self.paper_size,
            'is_color': self.is_color,
            'is_duplex': self.is_duplex,
            'copies': self.copies
        }
    
    @staticmethod
    def from_dict(data: Dict[str, Any]) -> 'PrintConfig':
        return PrintConfig(
            paper_size=data.get('paper_size', 'A4'),
            is_color=data.get('is_color', False),
            is_duplex=data.get('is_duplex', False),
            copies=data.get('copies', 1)
        )

@dataclass
class Order:
    id: str
    document_name: str
    status: OrderStatus
    config: PrintConfig
    created_at: datetime = datetime.now()

    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'document_name': self.document_name,
            'status': self.status.value,
            'config': self.config.to_dict(),
            'created_at': self.created_at.isoformat()
        }

    @staticmethod
    def from_dict(data: Dict[str, Any]) -> 'Order':
        return Order(
            id=data['id'],
            document_name=data['document_name'],
            status=OrderStatus(data['status']),
            config=PrintConfig.from_dict(data['config']),
            created_at=datetime.fromisoformat(data['created_at'])
        )