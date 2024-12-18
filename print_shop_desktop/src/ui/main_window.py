from PyQt6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QTableWidget, 
    QTableWidgetItem, QPushButton, QHBoxLayout
)
from PyQt6.QtCore import Qt, QTimer
from services.database_service import DatabaseService
from models.order_model import OrderStatus
from services.print_service import PrintService

class MainWindow(QMainWindow):
    def __init__(self, db_service: DatabaseService, print_service: PrintService):
        super().__init__()
        self.db_service = db_service
        self.print_service = print_service
        self.setWindowTitle("Print Shop Manager")
        self.setGeometry(100, 100, 1200, 800)
        
        # Create central widget and layout
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)
        
        # Create controls
        self._create_controls(layout)
        
        # Create orders table
        self.orders_table = QTableWidget()
        self._setup_table()
        layout.addWidget(self.orders_table)
        
        # Setup refresh timer
        self.refresh_timer = QTimer()
        self.refresh_timer.timeout.connect(self.refresh_orders)
        self.refresh_timer.start(5000)  # Refresh every 5 seconds
        
        # Initial load
        self.refresh_orders()

    def _create_controls(self, layout: QVBoxLayout):
        controls = QHBoxLayout()
        
        refresh_btn = QPushButton("Refresh")
        refresh_btn.clicked.connect(self.refresh_orders)
        controls.addWidget(refresh_btn)
        
        process_btn = QPushButton("Process Selected")
        process_btn.clicked.connect(self._process_selected)
        controls.addWidget(process_btn)
        
        layout.addLayout(controls)

    def _setup_table(self):
        headers = ["ID", "Document", "Status", "Configuration", "Created At"]
        self.orders_table.setColumnCount(len(headers))
        self.orders_table.setHorizontalHeaderLabels(headers)
        self.orders_table.setColumnWidth(0, 100)
        self.orders_table.setColumnWidth(1, 300)
        self.orders_table.setColumnWidth(2, 100)
        self.orders_table.setColumnWidth(3, 400)
        self.orders_table.setColumnWidth(4, 200)
        self.orders_table.setSelectionBehavior(QTableWidget.SelectionBehavior.SelectRows)
        self.orders_table.setSelectionMode(QTableWidget.SelectionMode.SingleSelection)

    def refresh_orders(self):
        orders = self.db_service.get_all_orders()
        self.orders_table.setRowCount(len(orders))
        
        for row, order in enumerate(orders):
            self._update_row(row, order)

    def _update_row(self, row: int, order):
        self.orders_table.setItem(row, 0, QTableWidgetItem(order.id))
        self.orders_table.setItem(row, 1, QTableWidgetItem(order.document_name))
        status_item = QTableWidgetItem(order.status.value)
        status_item.setBackground(self._get_status_color(order.status))
        self.orders_table.setItem(row, 2, status_item)
        self.orders_table.setItem(row, 3, QTableWidgetItem(str(order.config.to_dict())))
        self.orders_table.setItem(row, 4, QTableWidgetItem(order.created_at.isoformat()))

    def _get_status_color(self, status: OrderStatus):
        colors = {
            OrderStatus.PENDING: Qt.GlobalColor.yellow,
            OrderStatus.PROCESSING: Qt.GlobalColor.blue,
            OrderStatus.COMPLETED: Qt.GlobalColor.green,
            OrderStatus.FAILED: Qt.GlobalColor.red
        }
        return colors.get(status, Qt.GlobalColor.white)

    def _process_selected(self):
        current_row = self.orders_table.currentRow()
        if current_row >= 0:
            order_id = self.orders_table.item(current_row, 0).text()
            order = self.db_service.get_order(order_id)
            if order and order.status == OrderStatus.PENDING:
                if self.print_service.process_print_job(order):
                    self.db_service.update_order_status(order_id, OrderStatus.PROCESSING)
                else:
                    self.db_service.update_order_status(order_id, OrderStatus.FAILED)
                self.refresh_orders()