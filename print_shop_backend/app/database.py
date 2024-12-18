from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import Column, String, DateTime, JSON, Enum
import enum
from datetime import datetime

DATABASE_URL = "sqlite:///./print_shop.db"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class OrderStatus(str, enum.Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"

class OrderModel(Base):
    __tablename__ = "orders"

    id = Column(String, primary_key=True)
    document_name = Column(String, nullable=False)
    status = Column(Enum(OrderStatus), nullable=False)
    config = Column(JSON, nullable=False)
    created_at = Column(DateTime, nullable=False, default=datetime.now)

    def to_dict(self):
        return {
            "id": self.id,
            "document_name": self.document_name,
            "status": self.status,
            "config": self.config,
            "created_at": self.created_at.isoformat()
        }

def get_db():
    """Database session generator"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    """Initialize database tables"""
    Base.metadata.create_all(bind=engine)

def get_order_by_id(db, order_id: str):
    """Get order by ID"""
    return db.query(OrderModel).filter(OrderModel.id == order_id).first()

def create_order(db, order_data: dict):
    """Create new order"""
    db_order = OrderModel(**order_data)
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    return db_order

def update_order_status(db, order_id: str, status: OrderStatus):
    """Update order status"""
    order = get_order_by_id(db, order_id)
    if not order:
        raise ValueError(f"Order {order_id} not found")
    order.status = status
    db.commit()
    return order

def get_all_orders(db, limit: int = 100):
    """Get all orders with optional limit"""
    return db.query(OrderModel)\
        .order_by(OrderModel.created_at.desc())\
        .limit(limit)\
        .all()

def delete_order(db, order_id: str):
    """Delete order by ID"""
    order = get_order_by_id(db, order_id)
    if order:
        db.delete(order)
        db.commit()
        return True
    return False

def get_pending_orders(db):
    """Get all pending orders"""
    return db.query(OrderModel)\
        .filter(OrderModel.status == OrderStatus.PENDING)\
        .order_by(OrderModel.created_at)\
        .all()

# Initialize database on module import
init_db()