from PyQt5.QtWidgets import QMainWindow, QTableWidget, QTableWidgetItem
from PyQt5.QtCore import QTimer
from services.api_service import ApiService

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.api_service = ApiService()
        self.setup_ui()
        self.setup_timer()

    def setup_ui(self):
        self.setWindowTitle("Print Shop Desktop")
        self.setGeometry(100, 100, 800, 600)
        
        self.orders_table = QTableWidget(self)
        self.orders_table.setColumnCount(5)
        self.orders_table.setHorizontalHeaderLabels([
            "Order ID", "Filename", "Status", "Copies", "Color"
        ])
        self.setCentralWidget(self.orders_table)

    def setup_timer(self):
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_orders)
        self.timer.start(5000)  # Update every 5 seconds

    def update_orders(self):
        orders = self.api_service.get_orders()
        self.orders_table.setRowCount(len(orders))
        
        for row, order in enumerate(orders):
            self.orders_table.setItem(row, 0, QTableWidgetItem(order['id']))
            self.orders_table.setItem(row, 1, QTableWidgetItem(order['filename']))
            self.orders_table.setItem(row, 2, QTableWidgetItem(order['status']))
            self.orders_table.setItem(row, 3, QTableWidgetItem(str(order['config']['copies'])))
            self.orders_table.setItem(row, 4, QTableWidgetItem(str(order['config']['color'])))