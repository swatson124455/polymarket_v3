from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

app = FastAPI()

# Serve React static build
app.mount("/", StaticFiles(directory="static", html=True), name="frontend")

@app.get("/health")
def health():
    return {"status": "ok"}

class BacktestResult(BaseModel):
    roi: float
    max_drawdown: float
    win_rate: float
    sharpe_ratio: float

@app.get("/backtest", response_model=BacktestResult)
def backtest():
    return BacktestResult(roi=0.12, max_drawdown=0.05, win_rate=0.54, sharpe_ratio=1.2)
