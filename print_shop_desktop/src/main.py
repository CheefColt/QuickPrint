import sys
import logging
from pathlib import Path
from PyQt6.QtWidgets import QApplication
from services.database_service import DatabaseService
from services.file_watcher_service import FileWatcherService
from services.print_service import PrintService
from ui.main_window import MainWindow

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler('print_shop.log'),
            logging.StreamHandler()
        ]
    )

def ensure_directories():
    Path('shared_folder').mkdir(exist_ok=True)
    Path('logs').mkdir(exist_ok=True)

def main():
    # Setup application
    setup_logging()
    ensure_directories()
    logger = logging.getLogger(__name__)
    
    try:
        # Initialize Qt application
        app = QApplication(sys.argv)
        
        # Initialize services
        logger.info("Initializing services...")
        db_service = DatabaseService()
        file_watcher = FileWatcherService(db_service)
        print_service = PrintService()
        
        # Create and show main window
        logger.info("Starting application UI...")
        window = MainWindow(db_service, print_service)
        window.show()
        
        # Start file watcher
        logger.info("Starting file watcher service...")
        file_watcher.start()
        
        # Run application
        return_code = app.exec()
        logger.info("Application closing normally...")
        return return_code
        
    except Exception as e:
        logger.error(f"Application error: {e}", exc_info=True)
        return 1
    finally:
        # Cleanup
        logger.info("Performing cleanup...")
        if 'file_watcher' in locals():
            file_watcher.stop()

if __name__ == "__main__":
    sys.exit(main())