from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware 
# Import routers
from backend_upload.mainupl import router as upload_router
from backend_chatbot.main import router as chatbot_router

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # 👈 allow all for now
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# Include routers
app.include_router(upload_router, prefix="/upload")
app.include_router(chatbot_router, prefix="/chat")