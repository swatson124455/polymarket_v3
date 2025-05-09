# 1) Build frontend
FROM node:18-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package.json ./
RUN yarn install
COPY frontend/public ./public
COPY frontend/src ./src
RUN yarn build

# 2) Install Python deps
FROM python:3.11-slim AS python-deps
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# 3) Final image
FROM python:3.11-slim
WORKDIR /app
COPY --from=python-deps /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY main.py ./
COPY --from=frontend-build /app/frontend/build ./static

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
