from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import json
from pathlib import Path
from typing import Callable
from models.order_model import Order, OrderStatus
from services.database_service import DatabaseService

class PrintRequestHandler(FileSystemEventHandler):
    def __init__(self, db_service: DatabaseService):
        self.db_service = db_service

    def on_created(self, event):
        if not event.is_directory and event.src_path.endswith('.json'):
            self._process_order_file(Path(event.src_path))

    def _process_order_file(self, file_path: Path) -> None:
        try:
            with open(file_path) as f:
                data = json.load(f)
                order = Order.from_dict(data)
                self.db_service.add_order(order)
                self._update_status_file(order)
        except Exception as e:
            print(f"Error processing order file {file_path}: {e}")
            self._update_status_file(Order(
                id=Path(file_path).stem,
                document_name="Error",
                status=OrderStatus.FAILED,
                config={}
            ))

    def _update_status_file(self, order: Order) -> None:
        status_path = Path('shared_folder') / f"status_{order.id}.json"
        try:
            with open(status_path, 'w') as f:
                json.dump({
                    'status': order.status.value,
                    'message': f"Order {order.status.value}"
                }, f)
        except Exception as e:
            print(f"Error updating status file: {e}")

class FileWatcherService:
    def __init__(self, db_service: DatabaseService):
        self.observer = Observer()
        self.handler = PrintRequestHandler(db_service)
        self.watch_path = Path('shared_folder')
        self.watch_path.mkdir(exist_ok=True)

    def start(self) -> None:
        """Start watching the shared folder for new print requests"""
        self.observer.schedule(
            self.handler,
            str(self.watch_path),
            recursive=False
        )
        self.observer.start()
        print(f"Watching for print requests in {self.watch_path}")

    def stop(self) -> None:
        """Stop watching and cleanup"""
        if self.observer.is_alive():
            self.observer.stop()
            self.observer.join()