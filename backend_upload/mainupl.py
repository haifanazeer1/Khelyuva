from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import cv2
import mediapipe as mp
import numpy as np
import tempfile
import os

app = FastAPI(title="Fitness Video Analyzer API")

# ✅ CORS — allows your Flutter app to talk to this backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with your app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

mp_pose = mp.solutions.pose


# ─────────────────────────────────────────────
# 🔧 Helper: angle between 3 landmark points
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
# 🔧 Helper: generate feedback from angles
# ─────────────────────────────────────────────
def generate_feedback(avg_knee_angle: float, avg_hip_angle: float, avg_shoulder_angle: float) -> dict:
    issues = []
    tips = []

    # Knee analysis
    if avg_knee_angle < 70:
        issues.append("Knees are bending too much")
        tips.append("Try not to squat too deep — keep knees at around 90°")
    elif avg_knee_angle > 160:
        issues.append("Knees are barely bending")
        tips.append("Bend your knees more to engage your leg muscles properly")
    else:
        issues.append("Knee form looks good ✅")

    # Hip analysis
    if avg_hip_angle < 60:
        issues.append("Hips are dropping too low")
        tips.append("Keep your hips neutral, avoid excessive forward lean")
    elif avg_hip_angle > 150:
        issues.append("Hips are too upright / not hinging enough")
        tips.append("Hinge at the hips slightly for better balance and power")
    else:
        issues.append("Hip alignment looks good ✅")

    # Shoulder analysis
    if avg_shoulder_angle < 60:
        issues.append("Shoulders are hunching forward")
        tips.append("Pull your shoulders back and keep chest open")
    elif avg_shoulder_angle > 150:
        issues.append("Shoulders are leaning too far back")
        tips.append("Bring your upper body slightly forward for better posture")
    else:
        issues.append("Shoulder posture looks good ✅")

    # Overall score (simple heuristic)
    good_count = sum(1 for i in issues if "✅" in i)
    if good_count == 3:
        overall = "Excellent form! Keep it up 💪"
    elif good_count == 2:
        overall = "Good form with minor adjustments needed"
    elif good_count == 1:
        overall = "Fair form — focus on the tips below"
    else:
        overall = "Needs improvement — review all tips carefully"

    return {
        "overall": overall,
        "issues": issues,
        "tips": tips,
    }


# ─────────────────────────────────────────────
# 📌 Health check endpoint
# ─────────────────────────────────────────────
@app.get("/")
def root():
    return {"status": "Fitness Analyzer API is running"}


# ─────────────────────────────────────────────
# 🎥 Main endpoint: analyze uploaded video
# ─────────────────────────────────────────────
@app.post("/analyze-video")
async def analyze_video(file: UploadFile = File(...)):

    # ── Validate file type ──────────────────────
    allowed_types = ["video/mp4", "video/quicktime",
                     "video/x-msvideo", "video/webm"]
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type '{file.content_type}'. Please upload an MP4, MOV, AVI, or WEBM video."
        )

    # ── Save uploaded video to temp file ────────
    suffix = os.path.splitext(file.filename)[-1] or ".mp4"
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp:
        temp.write(await file.read())
        temp_path = temp.name

    # ── Process video with MediaPipe ────────────
    cap = cv2.VideoCapture(temp_path)

    if not cap.isOpened():
        os.unlink(temp_path)
        raise HTTPException(
            status_code=422, detail="Could not open video file. It may be corrupted.")

    knee_angles = []
    hip_angles = []
    shoulder_angles = []
    frame_count = 0

    with mp_pose.Pose(
        static_image_mode=False,
        model_complexity=1,
        min_detection_confidence=0.5,
        min_tracking_confidence=0.5
    ) as pose:

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break

            frame_count += 1

            # Skip every other frame for speed (optional)
            if frame_count % 2 != 0:
                continue

            image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = pose.process(image)

            if results.pose_landmarks:
                lm = results.pose_landmarks.landmark

                def get_point(landmark):
                    return [lm[landmark.value].x, lm[landmark.value].y]

                # ── Knee angle (hip → knee → ankle) ──
                hip = get_point(mp_pose.PoseLandmark.LEFT_HIP)
                knee = get_point(mp_pose.PoseLandmark.LEFT_KNEE)
                ankle = get_point(mp_pose.PoseLandmark.LEFT_ANKLE)
                knee_angles.append(calculate_angle(hip, knee, ankle))

                # ── Hip angle (shoulder → hip → knee) ──
                shoulder = get_point(mp_pose.PoseLandmark.LEFT_SHOULDER)
                hip_angles.append(calculate_angle(shoulder, hip, knee))

                # ── Shoulder angle (ear → shoulder → hip) ──
                ear = get_point(mp_pose.PoseLandmark.LEFT_EAR)
                shoulder_angles.append(calculate_angle(ear, shoulder, hip))

    cap.release()
    os.unlink(temp_path)  # Clean up temp file

    # ── Guard: no pose detected ──────────────────
    if not knee_angles:
        raise HTTPException(
            status_code=422,
            detail="No human pose detected in the video. Make sure the person is clearly visible."
        )

    # ── Compute averages ─────────────────────────
    avg_knee = float(np.mean(knee_angles))
    avg_hip = float(np.mean(hip_angles))
    avg_shoulder = float(np.mean(shoulder_angles))

    feedback = generate_feedback(avg_knee, avg_hip, avg_shoulder)

    return {
        "frames_analyzed": len(knee_angles),
        "angles": {
            "average_knee_angle":     round(avg_knee, 2),
            "average_hip_angle":      round(avg_hip, 2),
            "average_shoulder_angle": round(avg_shoulder, 2),
        },
        "feedback": feedback,
    }
