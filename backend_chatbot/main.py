from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from google import genai
from google.genai import types

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

client = genai.Client(api_key="API KEY REMOVED BEFORE SHARING")

SYSTEM_PROMPT = "You are KhelYuva AI, a friendly and knowledgeable fitness assistant."


class ChatRequest(BaseModel):
    message: str
    conversation_history: list = []


@app.post("/chat")
def chat(req: ChatRequest):
    try:
        contents = []
        for msg in req.conversation_history:
            role = "user" if msg.get("role") == "user" else "model"
            contents.append(types.Content(role=role, parts=[
                            types.Part(text=msg.get("content", ""))]))
        contents.append(types.Content(role="user", parts=[
                        types.Part(text=req.message)]))
        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=contents,
            config=types.GenerateContentConfig(
                max_output_tokens=500, temperature=0.7)
        )
        return {"reply": response.text}
    except Exception as e:
        return {"reply": str(e)}
