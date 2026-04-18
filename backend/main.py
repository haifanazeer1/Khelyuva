from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import sys
import os

# ✅ allow access to diet_service
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(BASE_DIR)

from diet_service.model import recommend_diet

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"message": "Diet API running 🚀"}

@app.post("/api/diet")
def diet(data: dict):
    return recommend_diet(
        data["age"],
        data["weight"],
        data["height"],
        data["fitness_goal"],
        data["activity_level"]
    )