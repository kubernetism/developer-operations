from fastapi import FastAPI

app = FastAPI(
    title="project_one API",
    version="0.1.0",
)


@app.get("/")
def home():
    return {
        "message": "Welcome to project_one Syed Safdar Ali Shah"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


def main():
    import uvicorn

    uvicorn.run(
        "project_one.main:app",
        host="127.0.0.1",
        port=8000,
        reload=True,
    )
