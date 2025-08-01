#!/bin/bash

# Установка nginx на Ubuntu/Debian

set -e  

echo "=== Установка и настройка nginx ==="

# Проверяем систему
if ! command -v apt-get &> /dev/null; then
    echo "Ошибка: Этот скрипт предназначен для Ubuntu/Debian систем"
    exit 1
fi

# Обновляем пакеты
echo "Обновляем список пакетов..."
sudo apt update

# Устанавливаем nginx
echo "Устанавливаем nginx..."
sudo apt install -y nginx

# Запускаем nginx
echo "Запускаем nginx..."
sudo systemctl start nginx

# Включаем автозапуск
echo "Включаем автозапуск nginx..."
sudo systemctl enable nginx

# Проверяем статус
echo "Проверяем статус nginx..."
sudo systemctl status nginx

# Показываем версию
echo "Версия nginx:"
nginx -v

# Проверяем конфигурацию
echo "Проверяем конфигурацию nginx..."
sudo nginx -t

# Проверяем порт
echo "Проверяем, что nginx слушает порт 80..."
sudo netstat -tulpn | grep :80 || sudo ss -tulpn | grep :80

echo "=== Установка завершена успешно ==="
echo "Nginx доступен по адресу: http://localhost"
echo "Для проверки используйте: curl localhost" 