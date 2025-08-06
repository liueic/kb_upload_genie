# --- 前端阶段 ---
FROM node:24-alpine AS frontend-builder

WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build && rm -rf node_modules

# --- 后端运行阶段 ---
FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    libffi-dev \
    libssl-dev \
    nginx \
    supervisor \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt ./
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --timeout=300 -r requirements.txt

COPY backend/ ./
COPY --from=frontend-builder /app/frontend/dist /var/www/html
COPY nginx-unified.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN useradd --create-home --shell /bin/bash app && \
    mkdir -p /app/uploads /app/logs /var/log/nginx /var/log/supervisor && \
    chmod 755 /app/uploads /app/logs && \
    chown -R www-data:www-data /var/www/html /var/log/nginx && \
    chown -R app:app /app/uploads /app/logs /app

HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]