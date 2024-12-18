from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pathlib import Path
import uvicorn

from app.routers import orders  # Updated import path
from app.database import init_db

# Create upload directory
UPLOAD_DIR = Path("shared_folder")
UPLOAD_DIR.mkdir(exist_ok=True)

app = FastAPI(title="Print Shop API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for uploaded documents
app.mount("/files", StaticFiles(directory=str(UPLOAD_DIR)), name="files")

# Include order routes
app.include_router(orders.router)

@app.on_event("startup")
async def startup():
    """Initialize database on startup"""
    init_db()
    print("Database initialized")

@app.get("/")
async def root():
    """API root endpoint"""
    return {
        "status": "active",
        "version": "1.0",
        "docs_url": "/docs",
        "upload_dir": str(UPLOAD_DIR)
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run(
        "main:app", 
        host="0.0.0.0", 
        port=8000, 
        reload=True,
        log_level="info"
    )