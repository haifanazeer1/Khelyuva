'''from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
import tempfile

import sys
import os

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(BASE_DIR)
from diet_service.model import recommend_diet
from upload_video_analysis.video_analysis import analyze_video

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------- 🥗 DIET ----------------
@app.post("/api/diet")
def diet(data: dict):
    return recommend_diet(
        data["age"],
        data["weight"],
        data["height"],
        data["fitness_goal"],
        data["activity_level"]
    )

# ---------------- 🎥 VIDEO ----------------
@app.post("/api/video")
async def video(file: UploadFile = File(...)):
    with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as temp:
        temp.write(await file.read())
        path = temp.name

    cap = cv2.VideoCapture(path)

    angles = []

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        # ⚡ SIMPLE LOGIC (replace later with your model)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        angles.append(np.mean(gray))  # placeholder

    cap.release()

    if not angles:
        return {"result": "No frames processed"}

    return {
        "frames": len(angles),
        "analysis": "Video processed successfully"
    }

# ---------------- HEALTH ----------------
@app.get("/")
def home():
    return {"message": "Diet + Video API running 🚀"} '''