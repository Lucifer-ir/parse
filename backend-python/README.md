# Parse Python API (FastAPI)

Development foundation: Python 3.11+, SQLite for local/dev, optional MySQL later. This service is independent from the PHP scaffold.

## Run
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --host 0.0.0.0 --port 8000

Swagger: /docs ; Health: /health

Implemented endpoints: registration/login, bearer identity/logout, source upload (text files), AI source question generation (Pasta OpenAI-compatible chat completions), basic question records, notification token registration placeholder.
Configure API URL and key in .env. AI secrets are server-only. SQLite is for initial dev; production should use MySQL/PostgreSQL, rate limiting, migrations, backups, HTTPS, RBAC and review.
