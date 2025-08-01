#!/bin/bash

# Скрипт для настройки WSL и установки nginx
echo "=== Настройка WSL для DevOps тестового задания ==="

# Проверяем, что мы в WSL
if ! grep -q Microsoft /proc/version 2>/dev/null; then
    echo "Этот скрипт предназначен для запуска в WSL"
    echo "Запустите его в WSL терминале"
    exit 1
fi

echo "Обнаружен WSL. Начинаем настройку..."

# Обновляем систему
echo "Обновляем систему..."
sudo apt update && sudo apt upgrade -y

# Устанавливаем необходимые пакеты
echo "Устанавливаем необходимые пакеты..."
sudo apt install -y curl wget git

# Устанавливаем nginx
echo "Устанавливаем nginx..."
sudo apt install -y nginx

# Запускаем nginx
echo "Запускаем nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Проверяем статус
echo "Проверяем статус nginx..."
sudo systemctl status nginx

# Показываем версию
echo "Версия nginx:"
nginx -v

# Проверяем порт
echo "Проверяем, что nginx слушает порт 80..."
sudo netstat -tulpn | grep :80 || sudo ss -tulpn | grep :80

echo "=== Настройка завершена! ==="
echo "Nginx доступен по адресу: http://localhost"
echo "Для проверки используйте: curl localhost" 