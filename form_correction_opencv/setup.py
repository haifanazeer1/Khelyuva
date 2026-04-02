from flask import Flask, Response, request
from flask_cors import CORS
import cv2
import PoseModule as pm
import time
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from io import BytesIO
import base64

app = Flask(__name__)
CORS(app)

# 🔥 GLOBAL STATE FOR FLUTTER
current_data = {
    "reps": 0,
    "feedback": "Starting..."
}

check = False
start = 0
stop = 0
err_top = []
err_bottom = []
l1 = []
l2 = []

@app.route("/")
def index():
    return "Backend Running ✅"


# 🔥 GENERIC CAMERA STREAM
def generate_frames(process_frame):
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("❌ Camera not accessible")
        while True:
            blank = np.zeros((600, 800, 3), dtype=np.uint8)
            cv2.putText(blank, "Camera not accessible", (100, 300),
                        cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)

            ret, buffer = cv2.imencode('.jpg', blank)
            frame_bytes = buffer.tobytes()

            yield (b'--frame\r\n'
                b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

    while True:
        success, frame = cap.read()
        if not success:
            print("❌ Failed to read frame")
            break

        frame = cv2.resize(frame, (800, 600))

        # Apply exercise logic
        frame = process_frame(frame)

        ret, buffer = cv2.imencode('.jpg', frame)
        frame_bytes = buffer.tobytes()

        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

    cap.release()


# ✅ PUSHUPS
def pushup_logic():
    detector = pm.poseDetector()
    count = 0
    direction = 0

    def process(frame):
        nonlocal count, direction

        frame = detector.findPose(frame, False)
        lmList = detector.findPosition(frame, False)

        if len(lmList) != 0:
            angle = detector.findAngle(frame, 12, 14, 16)

            # Count reps
            if angle <= 70 and direction == 0:
                count += 0.5
                direction = 1

            if angle >= 165 and direction == 1:
                count += 0.5
                direction = 0

            # 🔥 UPDATE STATUS
            current_data["reps"] = int(count)

            if angle < 70:
                current_data["feedback"] = "Go lower"
            elif angle > 165:
                current_data["feedback"] = "Good form"
            else:
                current_data["feedback"] = "Keep going"

            # Draw on frame
            cv2.putText(frame, f"Reps: {int(count)}", (50, 100),
                        cv2.FONT_HERSHEY_PLAIN, 3, (255, 255, 255), 3)

        return frame

    return process


# ✅ BICEP CURL
def bicep_logic():
    detector = pm.poseDetector()
    count = 0
    direction = 0

    def process(frame):
        nonlocal count, direction

        frame = detector.findPose(frame, False)
        lmList = detector.findPosition(frame, False)

        if len(lmList) != 0:
            angle = detector.findAngle(frame, 11, 13, 15)

            if angle <= 40 and direction == 0:
                count += 0.5
                direction = 1

            if angle >= 170 and direction == 1:
                count += 0.5
                direction = 0

            # 🔥 UPDATE STATUS
            current_data["reps"] = int(count)

            if angle < 40:
                current_data["feedback"] = "Lift higher"
            elif angle > 160:
                current_data["feedback"] = "Lower slowly"
            else:
                current_data["feedback"] = "Good form"

            cv2.putText(frame, f"Reps: {int(count)}", (50, 100),
                        cv2.FONT_HERSHEY_PLAIN, 3, (255, 255, 255), 3)

        return frame

    return process


# ✅ PLANK
def plank_logic():
    detector = pm.poseDetector()

    def process(frame):
        frame = detector.findPose(frame, False)
        lmList = detector.findPosition(frame, False)

        if len(lmList) != 0:
            angle = detector.findAngle(frame, 11, 23, 25)

            status = "Good Form" if 140 <= angle <= 170 else "Fix Posture"

            # 🔥 UPDATE STATUS
            current_data["reps"] = 0
            current_data["feedback"] = status

            cv2.putText(frame, status, (50, 100),
                        cv2.FONT_HERSHEY_PLAIN, 3,
                        (0, 255, 0) if status == "Good Form" else (0, 0, 255), 3)

        return frame

    return process


# ✅ VIDEO ROUTE
@app.route("/video_feed")
def video_feed():
    key = request.args.get("key")

    if key == "Pushups":
        return Response(generate_frames(pushup_logic()),
                        mimetype='multipart/x-mixed-replace; boundary=frame')

    elif key == "Left Bicep Curl":
        return Response(generate_frames(bicep_logic()),
                        mimetype='multipart/x-mixed-replace; boundary=frame')

    elif key == "Plank":
        return Response(generate_frames(plank_logic()),
                        mimetype='multipart/x-mixed-replace; boundary=frame')

    return "Invalid Exercise ❌"


# ✅ REAL-TIME STATUS FOR FLUTTER
@app.route("/status")
def status():
    return current_data


# ✅ RESULTS (GRAPH)
@app.route("/results")
def results():
    img = BytesIO()
    plt.plot([1, 2, 3], [3, 2, 5])
    plt.title("Workout Result")
    plt.savefig(img, format='png')
    plt.close()
    img.seek(0)
    return base64.b64encode(img.getvalue()).decode('utf8')


# ✅ RUN SERVER
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True, threaded=True)