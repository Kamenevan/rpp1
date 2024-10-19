#!/bin/bash

DB_NAME="laba2"
DB_USER="postgres"
DB_PORT=5432

#Путь к директории (SQL-скрипты миграций)
MIGRATIONS_DIR="/c/Users/student/RPP_laba2/scripts"

#Функция для выполнения SQL-файлов
run_sql() {
    PASSWORD="postgres" /c/Program\ Files/PostgreSQL/16/bin/psql.exe -U "$DB_USER" -d "$DB_NAME" -p "$DB_PORT" -f "$1"
}

#для выполнения SQL-запросов
run_sql_c() {
    PASSWORD="postgres" /c/Program\ Files/PostgreSQL/16/bin/psql.exe -U "$DB_USER" -d "$DB_NAME" -p "$DB_PORT" -t -c "$1"
}

#таблицы для хранения информации о применённых миграциях
run_sql_c "CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) UNIQUE NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"

#Получение списка всех выполненных миграций
applied_migrations=($(run_sql_c "SELECT migration_name FROM migrations;"))

#Перебираем все SQL-файлы из директории миграций
for sql_file in "$MIGRATIONS_PATH"/*.sql; do
    migration_name=$(basename "$sql_file" .sql)

#Проверяем, была ли уже применена миграция
    if [[ ! " ${applied_migrations[@]} " =~ " ${migration_name} " ]]; then
        echo "Применение миграции: $migration_name"

#Выполняем SQL-скрипт миграции
        run_sql "$sql_file"

#Сохраняем информацию о примененной миграции
        escaped_migration_name=$(printf "%q" "$migration_name")
        run_sql_c "INSERT INTO migrations (migration_name) VALUES ('$escaped_migration_name');"
    fi
done

