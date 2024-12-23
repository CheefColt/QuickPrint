from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import logging
from datetime import datetime
import json
import uuid

from app.schemas.models import Order, OrderStatus, PrintConfig

app = FastAPI()

# Setup logging
logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Create upload directory
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

@app.post("/orders", status_code=201)
async def create_order(file: UploadFile, config: str = Form(...)):
    try:
        logger.info(f"Receiving order for: {file.filename}")
        config_data = json.loads(config)
        logger.info(f"Config: {config_data}")
        
        # Save file
        file_path = UPLOAD_DIR / file.filename
        with file_path.open("wb") as buffer:
            content = await file.read()
            buffer.write(content)
            
        # Save order metadata
        order_data = {
            "id": str(uuid.uuid4()),
            "filename": file.filename,
            "config": config_data,
            "status": "pending",
            "timestamp": datetime.now().isoformat()
        }
        
        order_file = UPLOAD_DIR / f"{order_data['id']}.json"
        with open(order_file, 'w') as f:
            json.dump(order_data, f)
            
        logger.info(f"Order created: {order_data['id']}")
        return {"status": "success", "order_id": order_data['id']}
        
    except Exception as e:
        logger.error(f"Error creating order: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/orders")
async def get_orders():
    try:
        logger.debug("Fetching orders")
        orders = []
        for order_file in UPLOAD_DIR.glob("*.json"):
            with open(order_file) as f:
                order_data = json.load(f)
                orders.append(order_data)
        logger.debug(f"Found {len(orders)} orders")
        return orders
    except Exception as e:
        logger.error(f"Error fetching orders: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "ok"}