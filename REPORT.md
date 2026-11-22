# Отчёт о проверках

## Стабильныӥ каунтер

Проверяем, что каунтер не сбрасывается после пересоздания контеӥнеров.

Команды:
```bash
curl http://localhost:9090/ #7
docker compose down
docker compose up --detach --wait
curl http://localhost:9090/
```

**Значение до:** "count": 7
**Значение после:** "count": 7

Каунтер сохранился - благодаря docker volume и aof.


## Отключение Redis

Команды:
```bash
docker compose stop redis
curl -i http://localhost:9090/healthz
curl -i http://localhost:9090/readyz
curl -i -X POST http://localhost:9090/increment
```

Результаты:
```
HTTP/1.0 200 OK
{"status": "alive"}

HTTP/1.0 503 Service Unavailable
{"error": "storage_unavailable"}

HTTP/1.0 503 Service Unavailable
{"error": "storage_unavailable"}
```

Python продолжает работать, но без Redis к каунтеру не подступиться.


## Подключение(восстановление) Redis
Покажем, что вернув Redis, мы без перезапуска Python имеем вновь доступ к каунтеру.

Команды:
```bash
docker compose start redis
docker compose ps
curl -i http://localhost:9090/readyz
curl http://localhost:9090/
curl -X POST http://localhost:9090/increment
```

Результаты:
```
HTTP/1.0 200 OK

{"status": "ready", "storage": "redis"}

"count": 7

"count": 8
```


## Запуск без compose и логи

В самом начале дз я использовал Dockerfile с SQLite и сохранил логи: 

```
➜  cat logs.txt
   1 │ 2026-11-22 08:15:26,740 listening port=8000
     │ storage=sqlite
   2 │ 2026-11-22 08:15:31,658 http 192.168.65.1
     │  "GET / HTTP/1.1" 200 -
   3 │ 2026-11-22 08:16:13,326 http 192.168.65.1
     │  "GET / HTTP/1.1" 200 -
   4 │ 2026-11-22 08:17:12,374 http 192.168.65.1
     │  "POST /increment HTTP/1.1" 200 -
...
```

Видим storage=sqlite и успешную работу каунтера.
