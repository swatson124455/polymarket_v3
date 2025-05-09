# ── Stage 1: build React ─────────────────────────────────────────────
FROM node:18-alpine AS frontend
WORKDIR /app/frontend
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install --frozen-lockfile
COPY frontend/public ./public
COPY frontend/src    ./src
RUN yarn build

# ── Stage 2: install Python deps ────────────────────────────────────
FROM python:3.11-slim AS python-deps
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Stage 3: assemble final image ──────────────────────────────────
FROM python:3.11-slim
WORKDIR /app

# copy Python packages
COPY --from=python-deps /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# your FastAPI entrypoint
COPY main.py     .
# static React build
COPY --from=frontend /app/frontend/build ./static

# expose the port Render will inject
EXPOSE 8000

# start Uvicorn, binding 0.0.0.0:$PORT
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} --proxy-headers"]