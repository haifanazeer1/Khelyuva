from fastapi import APIRouter, File, UploadFile, HTTPException
#app = FastAPI(title="Fitness Video Analyzer API")
router=APIRouter()
@router.get("/")
def home():
    return {"message": "API is running"}
#from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
import tempfile
import os
import urllib.request

import mediapipe as mp
from mediapipe.tasks import python as mp_python
from mediapipe.tasks.python import vision as mp_vision
from mediapipe.tasks.python.vision import PoseLandmarkerOptions, RunningMode



'''app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)'''

# ── Download pose model if not present ──────────────
MODEL_PATH = "pose_landmarker_full.task"
MODEL_URL = "https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_full/float16/latest/pose_landmarker_full.task"

if not os.path.exists(MODEL_PATH):
    print("Downloading pose model...")
    urllib.request.urlretrieve(MODEL_URL, MODEL_PATH)
    print("Model downloaded.")


# ─────────────────────────────────────────────
# 🔧 Helper: angle between 3 points
# ─────────────────────────────────────────────
def calculate_angle(a, b, c):
    a = np.array(a)
    b = np.array(b)
    c = np.array(c)
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - \
        np.arctan2(a[1] - b[1], a[0] - b[0])
    angle = np.abs(radians * 180.0 / np.pi)
    if angle > 180:
        angle = 360 - angle
    return angle


# ─────────────────────────────────────────────
# 🔧 Helper: generate feedback
# ─────────────────────────────────────────────
def generate_feedback(avg_knee_angle, avg_hip_angle, avg_shoulder_angle):
    issues = []
    tips = []

    if avg_knee_angle < 70:
        issues.append("Knees are bending too much")
        tips.append("Try not to squat too deep — keep knees at around 90°")
    elif avg_knee_angle > 160:
        issues.append("Knees are barely bending")
        tips.append("Bend your knees more to engage your leg muscles properly")
    else:
        issues.append("Knee form looks good ✅")

    if avg_hip_angle < 60:
        issues.append("Hips are dropping too low")
        tips.append("Keep your hips neutral, avoid excessive forward lean")
    elif avg_hip_angle > 150:
        issues.append("Hips are too upright / not hinging enough")
        tips.append("Hinge at the hips slightly for better balance and power")
    else:
        issues.append("Hip alignment looks good ✅")

    if avg_shoulder_angle < 60:
        issues.append("Shoulders are hunching forward")
        tips.append("Pull your shoulders back and keep chest open")
    elif avg_shoulder_angle > 150:
        issues.append("Shoulders are leaning too far back")
        tips.append("Bring your upper body slightly forward for better posture")
    else:
        issues.append("Shoulder posture looks good ✅")

    good_count = sum(1 for i in issues if "✅" in i)
    if good_count == 3:
        overall = "Excellent form! Keep it up 💪"
    elif good_count == 2:
        overall = "Good form with minor adjustments needed"
    elif good_count == 1:
        overall = "Fair form — focus on the tips below"
    else:
        overall = "Needs improvement — review all tips carefully"

    return {"overall": overall, "issues": issues, "tips": tips}


# ─────────────────────────────────────────────
# Landmark indices for PoseLandmarker
# ─────────────────────────────────────────────
LEFT_EAR = 7
LEFT_SHOULDER = 11
LEFT_HIP = 23
LEFT_KNEE = 25
LEFT_ANKLE = 27


@router.get("/")
def root():
    return {"status": "Fitness Analyzer API is running"}


@router.post("/analyze-video")
async def analyze_video(file: UploadFile = File(...)):

    allowed_types = ["video/mp4", "video/quicktime",
                     "video/x-msvideo", "video/webm",
                     "application/octet-stream"]
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type '{file.content_type}'. Please upload an MP4, MOV, AVI, or WEBM video."
        )

    suffix = os.path.splitext(file.filename)[-1] or ".mp4"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp:
        temp.write(await file.read())
        temp_path = temp.name

    cap = cv2.VideoCapture(temp_path)
    if not cap.isOpened():
        os.unlink(temp_path)
        raise HTTPException(
            status_code=422, detail="Could not open video file.")

    knee_angles = []
    hip_angles = []
    shoulder_angles = []
    frame_count = 0

    base_options = mp_python.BaseOptions(model_asset_path=MODEL_PATH)
    options = PoseLandmarkerOptions(
        base_options=base_options,
        running_mode=RunningMode.VIDEO,
        num_poses=1,
        min_pose_detection_confidence=0.5,
        min_pose_presence_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    with mp_vision.PoseLandmarker.create_from_options(options) as landmarker:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            frame_count += 1
            if frame_count % 2 != 0:
                continue

            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=np.ascontiguousarray(rgb))
            timestamp_ms = int(cap.get(cv2.CAP_PROP_POS_MSEC))
            try:
                result = landmarker.detect_for_video(mp_image, timestamp_ms)
            except Exception as e:
                print("DETECTION ERROR:", e)
                continue

            if not result.pose_landmarks:
                continue

            lm = result.pose_landmarks[0]

            def get_point(idx):
                return [lm[idx].x, lm[idx].y]

            try:
                hip = get_point(LEFT_HIP)
                knee = get_point(LEFT_KNEE)
                ankle = get_point(LEFT_ANKLE)
                knee_angles.append(calculate_angle(hip, knee, ankle))

                shoulder = get_point(LEFT_SHOULDER)
                hip_angles.append(calculate_angle(shoulder, hip, knee))

                ear = get_point(LEFT_EAR)
                shoulder_angles.append(calculate_angle(ear, shoulder, hip))
            except Exception:
                continue

    cap.release()
    os.unlink(temp_path)

    if not knee_angles:
        raise HTTPException(
            status_code=422,
            detail="No human pose detected in the video. Make sure the person is clearly visible."
        )

    avg_knee = float(np.mean(knee_angles))
    avg_hip = float(np.mean(hip_angles))
    avg_shoulder = float(np.mean(shoulder_angles))

    feedback = generate_feedback(avg_knee, avg_hip, avg_shoulder)

    return {
        "frames_analyzed": len(knee_angles),
        "angles": {
            "average_knee_angle": round(avg_knee, 2),
            "average_hip_angle": round(avg_hip, 2),
            "average_shoulder_angle": round(avg_shoulder, 2),
        },
        "feedback": feedback,
    }
