from fastapi import APIRouter
#from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from google import genai 
from google.genai import types

router = APIRouter()

'''app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)'''

client = genai.Client(
    api_key="")

SYSTEM_PROMPT = """You are KhelYuva AI, a friendly and knowledgeable fitness assistant. 
You specialize in:
- Workout plans and exercise guidance
- Nutrition and diet advice
- Weight loss and muscle gain tips
- Sports performance improvement
- Injury prevention and recovery
- Motivation and fitness goals

Keep responses concise, practical, and encouraging. 
If asked about anything unrelated to fitness, health, or sports, politely redirect the conversation back to fitness topics.
Always remind users to consult a doctor before starting any new exercise program if they have health conditions."""


class ChatRequest(BaseModel):
    message: str
    conversation_history: list = []


@router.post("/")
def chat(req: ChatRequest):
    try:
        # Build conversation history for context
        contents = []
        for msg in req.conversation_history:
            role = "user" if msg.get("role") == "user" else "model"
            contents.append(types.Content(
                role=role,
                parts=[types.Part(text=msg.get("content", ""))]
            ))

        # Add current message
        contents.append(types.Content(
            role="user",
            parts=[types.Part(text=req.message)]
        ))

        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=contents,
            config=types.GenerateContentConfig(
                system_instruction=SYSTEM_PROMPT,
                max_output_tokens=500,
                temperature=0.7,
            )
        )
        return {"reply": response.text}
    except Exception as e:
        return {"reply": str(e)}