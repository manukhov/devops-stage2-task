# Архитектура

| Service | Description | URL |
|--------|-------------|-----|
| app | Тестовое FastAPI приложение | http://localhost:8000 |
| db | PostgreSQL | internal |
| prometheus | Сбор метрик | http://localhost:9090 |
| grafana | Визуализация метрик | http://localhost:3000 |

---

# Структура проекта

    .
    ├── .github/workflows/ci.yml
    ├── app/
    ├── grafana/
    │   ├── dashboards/
    │   └── provisioning/
    ├── prometheus/
    │   ├── prometheus.yml
    │   └── alerts.yml
    ├── scripts/
    │   ├── backup.sh
    │   └── restore.sh
    ├── docker-compose.yml
    ├── .env.example
    └── README.md

---

# Требования

- Docker
- Docker Compose
  
---
# Запуск

Сброка:

    docker compose up -d --build

Проверка контейнеров:

    docker compose ps

Остановить:

    docker compose down
    
---

# Проверка

## Проверка приложения

    curl http://localhost:8000/health

Ожидаемый ответ:

    {"status":"healthy"}

---

## Проверка записи в PostgreSQL

    curl http://localhost:8000/

Ожидаемый ответ:

    {"status":"ok"}

Каждый запрос к `/` создаёт запись в таблице `visits`.

---

## Проверка количества записей

    curl http://localhost:8000/visits

Пример:

    {"visits":7}

---

## Генерация нагрузки

    for i in {1..20}; do curl -s http://localhost:8000/ > /dev/null; done

---

## Проверка метрик

    curl http://localhost:8000/metrics | grep app_

Примеры метрик:

- `app_requests_total`
- `app_request_duration_seconds`

---

## Проверка Prometheus

Открыть:

    http://localhost:9090

Проверить targets:

    http://localhost:9090/targets

Ожидается, что target `app:8000` находится в состоянии `UP`.

---

## Проверка Grafana

Открыть:

    http://localhost:3000

Логин/пароль берутся из `.env`.

Ожидается:

- datasource Prometheus создаётся автоматически
- dashboard загружается автоматически
- после генерации нагрузки появляются графики

---

# Backup БД

Создать backup:

    ./scripts/backup.sh

После выполнения дамп появится в директории:

    backups/

Пример:

    backups/backup_20260413_190000.dump

---

# Restore БД

Восстановление из backup:

    ./scripts/restore.sh backups/backup_20260413_190000.dump

После restore данные будут восстановлены из указанного дампа.

---

# CI Pipeline

Pipeline выполняет:

- проверку docker compose конфигурации
- сборку контейнеров
- запуск проекта
- проверку health endpoint
- проверку PostgreSQL интеграции
- проверку metrics endpoint
- проверку Prometheus
- проверку Grafana

Workflow файл:

    .github/workflows/ci.yml

---

# Ограничения текущего решения

Текущее решение intentionally simplified и не является production-ready.

Ограничения:

- один экземпляр приложения
- один экземпляр PostgreSQL без репликации
- backup выполняется вручную
- restore выполняется вручную
- нет внешнего object storage
- нет TLS
- нет reverse proxy
- нет secret manager
- нет распределённого логирования
- нет autoscaling
- Grafana использует встроенную SQLite
- нет zero-downtime deployment стратегии

---

# Развитие

## Database

- PostgreSQL replication
- automatic failover
- managed PostgreSQL service
- PITR backups

## Security

- secrets manager (Vault / cloud secrets)
- TLS

## Observability

- Alertmanager
- централизованные логи
- tracing (OpenTelemetry)
- SLO / SLA monitoring

## CI/CD

- linting
- tests
- image scanning
- vulnerability checks
- deploy pipeline
- rollback strategy
