# Stage 1: Build React frontend
FROM node:18-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package.json ./
RUN yarn install --frozen-lockfile
COPY frontend/src ./src
RUN yarn build

# Stage 2: Install Python deps
FROM python:3.11-slim AS python-deps
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Stage 3: Final image
FROM python:3.11-slim
WORKDIR /app

# Copy Python packages
COPY --from=python-deps /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
# Copy backend code
COPY main.py requirements.txt ./
# Copy built frontend
COPY --from=frontend-build /app/frontend/build ./static

# Expose HTTP port
EXPOSE 80

# Environment defaults
ENV SUBGRAPH_URL=https://api.thegraph.com/subgraphs/name/polymarket/polymarket-v2
ENV CORS_ORIGINS="*"

# Start API and static server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
