#!/bin/bash

# Сборка и запуск Docker контейнера

set -e  
echo "=== Сборка и запуск Docker контейнера ==="

# Проверяем Docker
if ! command -v docker &> /dev/null; then
    echo "Ошибка: Docker не установлен"
    echo "Установите Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Очищаем старые контейнеры
echo "Останавливаем существующие контейнеры..."
docker stop nginx-devops 2>/dev/null || true
docker rm nginx-devops 2>/dev/null || true

# Удаляем старый образ
echo "Удаляем существующий образ..."
docker rmi nginx-devops 2>/dev/null || true

# Собираем образ
echo "Собираем Docker образ..."
docker build -t nginx-devops .

# Запускаем контейнер
echo "Запускаем контейнер..."
docker run -d --name nginx-devops -p 8080:80 nginx-devops

# Ждем запуска
echo "Ждем запуска контейнера..."
sleep 3

# Проверяем статус
echo "Статус контейнера:"
docker ps | grep nginx-devops

# Показываем логи
echo "Логи контейнера:"
docker logs nginx-devops

# Тестируем
echo "Тестируем доступность..."
if curl -s http://localhost:8080 > /dev/null; then
    echo "Контейнер работает http://localhost:8080"
    echo "Содержимое страницы:"
    curl -s http://localhost:8080 | head -20
else
    echo "Ошибка: контейнер не отвечает"
    exit 1
fi

echo "=== Готово ==="
echo "Для остановки контейнера: docker stop nginx-devops"
echo "Для просмотра логов: docker logs nginx-devops" 