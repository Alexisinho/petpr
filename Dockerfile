# --- СТАДИЯ 1: Сборка (builder) ---
FROM python:3.12-slim AS builder

# Устанавливаем переменные окружения, чтобы Python не создавал .pyc файлы и не буферизировал логи
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Создаем виртуальное окружение. 
# Это позволит нам просто скопировать одну папку во второй этап.
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Устанавливаем зависимости
RUN pip install --no-cache-dir Flask==3.0.3


# --- СТАДИЯ 2: Финальный образ (runtime) ---
FROM python:3.12-slim

WORKDIR /app

# 1. Создаем пользователя (non-root)
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# 2. Копируем виртуальное окружение из билдера
COPY --from=builder /opt/venv /opt/venv

# 3. Копируем исходный код
COPY app.py .

# 4. Настраиваем PATH, чтобы Python видел библиотеки из скопированного venv
ENV PATH="/opt/venv/bin:$PATH"

# 5. Меняем владельца папки приложения (чтобы appuser мог работать, если нужно)
RUN chown -R appuser:appgroup /app

# 6. Переключаемся на пользователя
USER appuser

# Запускаем
CMD ["python", "app.py"]