from pathlib import Path
from fastapi import FastAPI

app = FastAPI()

# Secret injected by Secrets Store CSI driver
_SECRET_PATH = Path("/mnt/secrets/postgres-password")
DB_HOST = __import__("os").getenv("DB_HOST", "localhost")


def _db_password() -> str:
    if _SECRET_PATH.exists():
        return _SECRET_PATH.read_text().strip()
    return "not-mounted"


@app.get("/healthz")
def healthz():
    return {"status": "ok", "db_host": DB_HOST}


@app.get("/api/healthz")
def api_healthz():
    return {"status": "ok"}


@app.get("/api/items")
def items():
    return {"items": ["item-1", "item-2", "item-3"], "db_host": DB_HOST}
