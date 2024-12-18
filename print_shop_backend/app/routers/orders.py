from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
import shutil
from pathlib import Path
from fastapi.responses import FileResponse

from app.database import get_db, create_order, get_order_by_id, get_all_orders, update_order_status, OrderStatus
from app.models.order import Order, PrintConfig

router = APIRouter(prefix="/orders", tags=["orders"])

UPLOAD_DIR = Path("shared_folder")
UPLOAD_DIR.mkdir(exist_ok=True)

@router.post("/", status_code=201)
async def create_new_order(
    document: UploadFile = File(...),
    config: PrintConfig = Depends(),
    db: Session = Depends(get_db)
):
    try:
        # Save uploaded file
        file_path = UPLOAD_DIR / document.filename
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(document.file, buffer)
        
        # Create order data
        order_data = {
            "document_name": document.filename,
            "status": OrderStatus.PENDING,
            "config": config.dict(),
            "created_at": datetime.now()
        }
        
        # Save to database
        order = create_order(db, order_data)
        
        # Return success response
        return {
            "id": order.id,
            "status": order.status,
            "document_name": order.document_name,
            "created_at": order.created_at.isoformat(),
            "message": "Order created successfully"
        }
        
    except Exception as e:
        # Cleanup on error
        if file_path.exists():
            file_path.unlink()
        raise HTTPException(
            status_code=500,
            detail=f"Failed to create order: {str(e)}"
        )

@router.get("/", response_model=List[Order])
async def list_all_orders(
    limit: int = 100,
    skip: int = 0,
    db: Session = Depends(get_db)
):
    """List all orders with pagination"""
    orders = get_all_orders(db, limit=limit, skip=skip)
    return [order.to_dict() for order in orders]

@router.get("/{order_id}")
async def get_order(
    order_id: str, 
    db: Session = Depends(get_db)
):
    """Get single order details"""
    order = get_order_by_id(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order.to_dict()

@router.put("/{order_id}/status")
async def update_order_status(
    order_id: str,
    status: OrderStatus,
    db: Session = Depends(get_db)
):
    """Update order processing status"""
    try:
        order = update_order_status(db, order_id, status)
        return order.to_dict()
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@router.delete("/{order_id}")
async def delete_order(order_id: str, db: Session = Depends(get_db)):
    """Delete order and its document"""
    order = get_order_by_id(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    file_path = UPLOAD_DIR / order.document_name
    if file_path.exists():
        file_path.unlink()
        
    if delete_order(db, order_id):
        return {"message": "Order deleted successfully"}
    raise HTTPException(status_code=500, detail="Failed to delete order")

@router.get("/{order_id}/document")
async def download_document(order_id: str, db: Session = Depends(get_db)):
    """Download order document"""
    order = get_order_by_id(db, order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    file_path = UPLOAD_DIR / order.document_name
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Document not found")
        
    return FileResponse(
        path=file_path,
        filename=order.document_name,
        media_type='application/octet-stream'
    )

@router.get("/pending")
async def get_pending_orders(db: Session = Depends(get_db)):
    """Get all pending orders"""
    orders = get_pending_orders(db)
    return [order.to_dict() for order in orders]

# Add health check endpoint
@router.get("/health")
async def health_check():
    """API health check"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "upload_dir": str(UPLOAD_DIR),
        "pending_orders": True
    }

@router.get("/stats")
async def get_order_stats(db: Session = Depends(get_db)):
    """Get order statistics"""
    total = db.query(OrderModel).count()
    pending = db.query(OrderModel).filter(OrderModel.status == OrderStatus.PENDING).count()
    processing = db.query(OrderModel).filter(OrderModel.status == OrderStatus.PROCESSING).count()
    completed = db.query(OrderModel).filter(OrderModel.status == OrderStatus.COMPLETED).count()
    failed = db.query(OrderModel).filter(OrderModel.status == OrderStatus.FAILED).count()
    
    return {
        "total_orders": total,
        "pending_orders": pending,
        "processing_orders": processing,
        "completed_orders": completed,
        "failed_orders": failed,
        "success_rate": (completed / total * 100) if total > 0 else 0
    }

@router.get("/system")
async def system_status():
    """Get system status"""
    return {
        "api_version": "1.0.0",
        "upload_dir_size": sum(f.stat().st_size for f in UPLOAD_DIR.glob('**/*') if f.is_file()),
        "upload_dir_files": len(list(UPLOAD_DIR.glob('*'))),
        "database_connected": True,
        "last_checked": datetime.now().isoformat()
    }

@router.post("/error")
async def log_error(error: dict):
    """Log system errors"""
    with open('error.log', 'a') as f:
        f.write(f"{datetime.now()}: {error.get('message', 'Unknown error')}\n")
    return {"message": "Error logged successfully"}

@router.get("/stats")
async def get_statistics(db: Session = Depends(get_db)):
    """Get system statistics"""
    return {
        "total_orders": db.query(OrderModel).count(),
        "pending_orders": db.query(OrderModel).filter(
            OrderModel.status == OrderStatus.PENDING
        ).count(),
        "upload_dir_size": sum(f.stat().st_size for f in UPLOAD_DIR.glob('**/*') if f.is_file()),
        "last_updated": datetime.now().isoformat()
    }

@router.on_event("startup")
async def startup_event():
    """Initialize required directories"""
    UPLOAD_DIR.mkdir(exist_ok=True)
    print(f"API Started - Upload directory: {UPLOAD_DIR}")