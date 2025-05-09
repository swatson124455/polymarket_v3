# ─── Stage 1: Build the React frontend ─────────────────────────────────────────
FROM node:18-alpine AS frontend-build
WORKDIR /app/frontend

# Copy only the lock‑files first to cache installs
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy rest and build
COPY frontend/public ./public
COPY frontend/src    ./src
RUN yarn build

# ─── Stage 2: Build the FastAPI backend + bundle frontend ───────────────────────
FROM python:3.11-slim
WORKDIR /app

# Copy in dependencies and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy in backend code
COPY main.py .

# Copy built frontend into a static directory
COPY --from=frontend-build /app/frontend/build ./static

# Expose the port your FastAPI app listens on
EXPOSE 8000

# Start the app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
