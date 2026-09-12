# dbops-project
Проектная работа дисциплины DBOps

### Запросы, выполненные для подготовки базы данных store
```sql
CREATE DATABASE store;
CREATE USER nikita WITH PASSWORD '***';
GRANT ALL PRIVILEGES ON DATABASE store TO nikita;
ALTER DATABASE store OWNER TO nikita;
\c store
GRANT USAGE, CREATE ON SCHEMA public TO nikita;
ALTER SCHEMA public OWNER TO nikita;
```
