import sqlite3
from typing import List, Optional
from pathlib import Path
from models.order_model import Order, OrderStatus
import json

class DatabaseService:
    def __init__(self, db_path: str = "printshop.db"):
        self.db_path = Path(db_path)
        self._init_db()

    def _init_db(self) -> None:
        with sqlite3.connect(self.db_path) as conn:
            conn.execute('''
                CREATE TABLE IF NOT EXISTS orders (
                    id TEXT PRIMARY KEY,
                    document_name TEXT NOT NULL,
                    status TEXT NOT NULL,
                    config TEXT NOT NULL,
                    created_at TIMESTAMP NOT NULL
                )
            ''')

    def add_order(self, order: Order) -> bool:
        try:
            with sqlite3.connect(self.db_path) as conn:
                conn.execute('''
                    INSERT INTO orders (id, document_name, status, config, created_at)
                    VALUES (?, ?, ?, ?, ?)
                ''', (
                    order.id,
                    order.document_name,
                    order.status.value,
                    json.dumps(order.config.to_dict()),
                    order.created_at.isoformat()
                ))
                return True
        except sqlite3.Error as e:
            print(f"Error adding order: {e}")
            return False

    def get_order(self, order_id: str) -> Optional[Order]:
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.execute(
                    'SELECT * FROM orders WHERE id = ?', 
                    (order_id,)
                )
                row = cursor.fetchone()
                if row:
                    return Order.from_dict({
                        'id': row[0],
                        'document_name': row[1],
                        'status': row[2],
                        'config': json.loads(row[3]),
                        'created_at': row[4]
                    })
                return None
        except sqlite3.Error as e:
            print(f"Error retrieving order: {e}")
            return None

    def update_order_status(self, order_id: str, status: OrderStatus) -> bool:
        try:
            with sqlite3.connect(self.db_path) as conn:
                conn.execute(
                    'UPDATE orders SET status = ? WHERE id = ?',
                    (status.value, order_id)
                )
                return True
        except sqlite3.Error as e:
            print(f"Error updating order status: {e}")
            return False

    def get_all_orders(self) -> List[Order]:
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.execute('SELECT * FROM orders ORDER BY created_at DESC')
                return [Order.from_dict({
                    'id': row[0],
                    'document_name': row[1],
                    'status': row[2],
                    'config': json.loads(row[3]),
                    'created_at': row[4]
                }) for row in cursor.fetchall()]
        except sqlite3.Error as e:
            print(f"Error retrieving orders: {e}")
            return []