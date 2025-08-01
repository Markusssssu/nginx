#!/bin/bash

# Скрипт для установки Docker в WSL и запуска проекта
echo "=== Установка Docker в WSL ==="

# Проверяем, что мы в WSL
if ! grep -q Microsoft /proc/version 2>/dev/null; then
    echo "Этот скрипт предназначен для запуска в WSL"
    exit 1
fi

# Обновляем систему
echo "Обновляем систему..."
sudo apt update && sudo apt upgrade -y

# Устанавливаем необходимые пакеты
echo "Устанавливаем необходимые пакеты..."
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Добавляем GPG ключ Docker
echo "Добавляем GPG ключ Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Добавляем репозиторий Docker
echo "Добавляем репозиторий Docker..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Обновляем и устанавливаем Docker
echo "Устанавливаем Docker..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Добавляем пользователя в группу docker
echo "Добавляем пользователя в группу docker..."
sudo usermod -aG docker $USER

# Запускаем Docker
echo "Запускаем Docker..."
sudo service docker start

echo "=== Docker установлен! ==="
echo "Перезапустите WSL или выполните: newgrp docker"
echo "Затем запустите: ./scripts/docker-build.sh" 