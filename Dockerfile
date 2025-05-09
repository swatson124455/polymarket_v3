# Stage 1: build frontend
FROM node:18-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package.json ./
# If you have a yarn.lock, uncomment next line and include your lock file
# COPY frontend/yarn.lock ./
RUN yarn install
COPY frontend/public ./public
COPY frontend/src ./src
RUN yarn build

# Stage 2: python backend
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py ./
# Copy frontend build
COPY --from=frontend-build /app/frontend/build ./static
# Run Uvicorn on the port Render provides (default 8000)
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
