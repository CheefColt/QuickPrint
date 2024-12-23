import requests
from typing import Dict, List
import logging

class ApiService:
    def __init__(self):
        self.base_url = "http://192.168.0.100:8000"
        self.session = requests.Session()
        self.logger = logging.getLogger(__name__)

    def test_connection(self) -> bool:
        try:
            response = self.session.get(f"{self.base_url}/health")
            return response.status_code == 200
        except Exception as e:
            self.logger.error(f"Connection error: {e}")
            return False

    def get_orders(self) -> List[Dict]:
        try:
            response = self.session.get(f"{self.base_url}/orders")
            if response.status_code == 200:
                return response.json()
            raise Exception(f"Failed to get orders: {response.text}")
        except Exception as e:
            self.logger.error(f"Error getting orders: {e}")
            return []

    def update_order_status(self, order_id: str, status: str) -> bool:
        try:
            response = self.session.patch(
                f"{self.base_url}/orders/{order_id}",
                json={"status": status}
            )
            return response.status_code == 200
        except Exception as e:
            self.logger.error(f"Error updating order status: {e}")
            return False