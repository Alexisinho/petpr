FROM python:3.12-slim

WORKDIR /app
COPY app.py .

RUN pip install --no-cache-dir Flask==3.0.3

CMD ["python", "app.py"]