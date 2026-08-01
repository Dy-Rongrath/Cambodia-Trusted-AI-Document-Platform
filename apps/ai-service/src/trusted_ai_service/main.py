from typing import Any, Dict
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(
    title="Cambodia Trusted AI Service",
    description="Health and AI service skeleton",
    version="0.1.0",
)


class HealthResponse(BaseModel):
    status: str
    service: str


@app.get("/health", response_model=HealthResponse)
def get_health() -> Dict[str, Any]:
    return {"status": "ok", "service": "ai-service"}
