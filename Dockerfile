# ===== STAGE 1: builder — собираем wheels для всех зависимостей =====
FROM python:3.12-alpine AS builder

# Обновим pip и подготовим тулчейн только на время сборки
RUN apk add --no-cache --virtual .build-deps \
      gcc musl-dev linux-headers python3-dev \
   && python -m pip install --upgrade pip wheel

WORKDIR /wheels
# Сначала зависимости (лучше кэшируется)
COPY requirements.txt .
# Собираем колёса всех зависимостей (включая psutil)
RUN pip wheel --no-cache-dir -r requirements.txt

# Затем добавим ваш код (не обязателен на этапе wheels, но пусть будет для полноты)
WORKDIR /src
COPY src/ ./src

# ===== STAGE 2: runtime — чистый рантайм без компилятора =====
FROM python:3.12-alpine

# (опционально) ускоряем pip и уменьшаем слой
ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    SERVER_PORT=8080

WORKDIR /app

# Копируем wheels из билдера и ставим их оффлайн — без компиляции
COPY --from=builder /wheels /wheels
COPY requirements.txt .
RUN pip install --no-index --find-links /wheels -r requirements.txt \
 && rm -rf /wheels

# Кладём исходники
COPY src/ ./src

EXPOSE 8080
ENTRYPOINT ["python", "src/main.py"]
