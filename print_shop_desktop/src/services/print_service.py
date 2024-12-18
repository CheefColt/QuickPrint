import os
import logging
from pathlib import Path
from datetime import datetime
from models.order_model import Order, OrderStatus

class PrintService:
    def __init__(self):
        self.default_printer = "Microsoft Print to PDF"
        self.logger = logging.getLogger(__name__)
        
    def get_available_printers(self):
        return ["Microsoft Print to PDF"]
        
    def process_print_job(self, order: Order) -> bool:
        try:
            file_path = Path('shared_folder') / order.document_name
            if not file_path.exists():
                self.logger.error(f"File not found: {file_path}")
                return False
                
            # Simulate print job processing
            self.logger.info(f"Processing print job: {order.document_name}")
            self.logger.info(f"Config: {order.config}")
            self.logger.info(f"Using printer: {self.default_printer}")
            
            # Simulate successful print
            with open('print.log', 'a') as log:
                log.write(f"{datetime.now()}: Printed {order.document_name}\n")
            
            return True
            
        except Exception as e:
            self.logger.error(f"Print error: {e}")
            return False

if __name__ == "__main__":
    import sys
    from models.order_model import OrderConfig

    order = Order(document_name="example.pdf", config=OrderConfig())
    print_service = PrintService()
    print_service.process_print_job(order)