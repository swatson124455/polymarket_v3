# ─── Stage 1: Build the React frontend ─────────────────────────────────────────
FROM node:18-alpine AS frontend-build
WORKDIR /app/frontend

# Only package.json is needed—yarn will create its own lockfile if none exists
COPY frontend/package.json ./
RUN yarn install

COPY frontend/public ./public
COPY frontend/src    ./src
RUN yarn build

# ─── Stage 2: Build the FastAPI backend + bundle frontend ───────────────────────
FROM python:3.11-slim
WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py ./

# Pull in the built React app
COPY --from=frontend-build /app/frontend/build ./static

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]


# Start the app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
