from fastapi import FastAPI
from model import recommend_diet
from fastapi.middleware.cors import CORSMiddleware
app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
@app.post("/recommend")
def recommend(data: dict):

    foods = recommend_diet(
        data["age"],
        data["weight"],
        data["height"],
        data["fitness_goal"],
        data["activity_level"]
    )

    return foods

