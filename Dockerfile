# 1. Базовый образ
FROM python:3.12-alpine

# 2. Установим рабочую директорию
WORKDIR /app

# 3. Копируем файл с зависимостями
COPY requirements.txt .

# 4. Устанавливаем зависимости
RUN pip install --no-cache-dir -r requirements.txt

# 5. Копируем исходный код приложения
COPY src/ ./src

# 6. Открываем порт 8080
EXPOSE 8080

# 7. Определяем переменные окружения (по желанию)
ENV SERVER_PORT=8080

# 8. Запуск приложения
ENTRYPOINT ["python", "src/main.py"]
