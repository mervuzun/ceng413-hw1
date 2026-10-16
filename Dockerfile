# Pinned base image: exact version, small "slim" variant
FROM python:3.12.15-slim

WORKDIR /app

# Dependencies first so this layer is cached when only code changes
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Application code last (changes most often)
COPY . .

# Unprivileged user + data folder it can write to
RUN useradd --create-home --uid 10001 appuser \
    && mkdir -p /data \
    && chown appuser:appuser /data
USER appuser

# Configuration via environment variables (overridable with -e)
ENV DATA_DIR=/data \
    APP_GREETING=Hello \
    APP_VERSION=1.0.0

EXPOSE 8000

# Bonus: Docker checks /health periodically
HEALTHCHECK --interval=30s --timeout=3s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]