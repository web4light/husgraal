FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnat gprbuild \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN gprbuild -P husgraal.gpr || true

ENV PORT=8080
EXPOSE 8080
CMD ["uvicorn", "src.husgraal_server:app", "--host", "0.0.0.0", "--port", "8080"]
