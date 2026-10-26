FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HF_HOME=/home/app/.cache/huggingface

RUN useradd --create-home --uid 10001 app \
    && mkdir -p /home/app/.cache/huggingface \
    && chown -R app:app /home/app

WORKDIR /app

# Instal·la la versió CPU de PyTorch per a no incloure les llibreries CUDA al contenidor.
RUN pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu 'torch>=2.0.0'
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY server.py ./server.py
COPY filtro_xatbot.py ./filtro_xatbot.py
USER app
EXPOSE 8001
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8001"]
