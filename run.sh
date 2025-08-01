#!/bin/bash

# Главный скрипт для DevOps тестового задания
# Управляет всеми аспектами проекта

set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для показа меню
show_menu() {
    echo -e "${BLUE}=== DevOps Test Task - Главное меню ===${NC}"
    echo ""
    echo -e "${GREEN}1.${NC} Установить nginx локально"
    echo -e "${GREEN}2.${NC} Установить Docker"
    echo -e "${GREEN}3.${NC} Запустить Docker контейнер"
    echo -e "${GREEN}4.${NC} Запустить с docker-compose"
    echo -e "${GREEN}5.${NC} Развернуть в Kubernetes"
    echo -e "${GREEN}6.${NC} Проверить статус всех сервисов"
    echo -e "${GREEN}7.${NC} Остановить все сервисы"
    echo -e "${GREEN}8.${NC} Очистить все (Docker + nginx)"
    echo -e "${GREEN}9.${NC} Показать логи"
    echo -e "${GREEN}0.${NC} Выход"
    echo ""
}

# Функция для установки nginx
install_nginx() {
    echo -e "${YELLOW}Устанавливаем nginx...${NC}"
    
    # Проверяем систему
    if ! command -v apt-get &> /dev/null; then
        echo -e "${RED}Ошибка: Этот скрипт предназначен для Ubuntu/Debian систем${NC}"
        return 1
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
    sudo systemctl enable nginx

    # Проверяем статус
    echo "Проверяем статус nginx..."
    sudo systemctl status nginx

    echo -e "${GREEN}Nginx установлен и запущен!${NC}"
    echo "Доступен по адресу: http://localhost"
}

# Функция для установки Docker
install_docker() {
    echo -e "${YELLOW}Устанавливаем Docker...${NC}"
    
    # Проверяем систему
    if ! command -v apt-get &> /dev/null; then
        echo -e "${RED}Ошибка: Этот скрипт предназначен для Ubuntu/Debian систем${NC}"
        return 1
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

    echo -e "${GREEN}Docker установлен!${NC}"
    echo "Перезапустите WSL или выполните: newgrp docker"
}

# Функция для запуска Docker контейнера
run_docker() {
    echo -e "${YELLOW}Запускаем Docker контейнер...${NC}"
    
    # Проверяем Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Ошибка: Docker не установлен. Сначала установите Docker (опция 2)${NC}"
        return 1
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

    # Тестируем
    echo "Тестируем доступность..."
    if curl -s http://localhost:8080 > /dev/null; then
        echo -e "${GREEN}Контейнер работает! Доступен по адресу: http://localhost:8080${NC}"
    else
        echo -e "${RED}Ошибка: контейнер не отвечает${NC}"
    fi
}

# Функция для запуска docker-compose
run_compose() {
    echo -e "${YELLOW}Запускаем с docker-compose...${NC}"
    
    # Проверяем docker-compose
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}Ошибка: docker-compose не установлен${NC}"
        return 1
    fi

    # Запускаем
    docker-compose up -d

    # Ждем запуска
    sleep 3

    # Проверяем
    if curl -s http://localhost:8080 > /dev/null; then
        echo -e "${GREEN}Docker Compose запущен! Доступен по адресу: http://localhost:8080${NC}"
    else
        echo -e "${RED}Ошибка: сервис не отвечает${NC}"
    fi
}

# Функция для развертывания в Kubernetes
deploy_k8s() {
    echo -e "${YELLOW}Развертываем в Kubernetes...${NC}"
    
    # Проверяем kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}Ошибка: kubectl не установлен${NC}"
        return 1
    fi

    # Проверяем кластер
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}Ошибка: Не удается подключиться к Kubernetes кластеру${NC}"
        return 1
    fi

    # Применяем deployment
    kubectl apply -f deployment.yaml

    # Ждем запуска
    kubectl wait --for=condition=ready pod -l app=nginx-devops --timeout=60s

    echo -e "${GREEN}Kubernetes deployment применен!${NC}"
    kubectl get pods -l app=nginx-devops
}

# Функция для проверки статуса
check_status() {
    echo -e "${YELLOW}Проверяем статус всех сервисов...${NC}"
    
    echo -e "${BLUE}=== Nginx ===${NC}"
    if systemctl is-active --quiet nginx; then
        echo -e "${GREEN}Nginx: Активен${NC}"
        curl -s localhost > /dev/null && echo "Доступен по адресу: http://localhost" || echo "Не отвечает"
    else
        echo -e "${RED}Nginx: Не активен${NC}"
    fi

    echo -e "${BLUE}=== Docker ===${NC}"
    if command -v docker &> /dev/null; then
        if docker ps | grep -q nginx-devops; then
            echo -e "${GREEN}Docker контейнер: Запущен${NC}"
            curl -s localhost:8080 > /dev/null && echo "Доступен по адресу: http://localhost:8080" || echo "Не отвечает"
        else
            echo -e "${YELLOW}Docker контейнер: Не запущен${NC}"
        fi
    else
        echo -e "${RED}Docker: Не установлен${NC}"
    fi

    echo -e "${BLUE}=== Kubernetes ===${NC}"
    if command -v kubectl &> /dev/null; then
        if kubectl get pods -l app=nginx-devops 2>/dev/null | grep -q Running; then
            echo -e "${GREEN}Kubernetes pods: Запущены${NC}"
        else
            echo -e "${YELLOW}Kubernetes pods: Не запущены${NC}"
        fi
    else
        echo -e "${RED}Kubernetes: Не установлен${NC}"
    fi
}

# Функция для остановки всех сервисов
stop_all() {
    echo -e "${YELLOW}Останавливаем все сервисы...${NC}"
    
    # Останавливаем nginx
    sudo systemctl stop nginx 2>/dev/null || true
    
    # Останавливаем Docker контейнеры
    docker stop nginx-devops 2>/dev/null || true
    docker-compose down 2>/dev/null || true
    
    # Удаляем из Kubernetes
    kubectl delete -f deployment.yaml 2>/dev/null || true
    
    echo -e "${GREEN}Все сервисы остановлены!${NC}"
}

# Функция для очистки
clean_all() {
    echo -e "${YELLOW}Очищаем все...${NC}"
    
    # Останавливаем nginx
    sudo systemctl stop nginx 2>/dev/null || true
    sudo systemctl disable nginx 2>/dev/null || true
    
    # Очищаем Docker
    docker stop $(docker ps -aq) 2>/dev/null || true
    docker rm $(docker ps -aq) 2>/dev/null || true
    docker rmi nginx-devops 2>/dev/null || true
    docker system prune -f
    
    echo -e "${GREEN}Все очищено!${NC}"
}

# Функция для показа логов
show_logs() {
    echo -e "${YELLOW}Показываем логи...${NC}"
    
    echo -e "${BLUE}=== Nginx логи ===${NC}"
    sudo tail -10 /var/log/nginx/access.log 2>/dev/null || echo "Логи nginx недоступны"
    
    echo -e "${BLUE}=== Docker логи ===${NC}"
    docker logs nginx-devops 2>/dev/null || echo "Docker контейнер не найден"
}

# Главный цикл
while true; do
    show_menu
    read -p "Выберите опцию (0-9): " choice
    
    case $choice in
        1) install_nginx ;;
        2) install_docker ;;
        3) run_docker ;;
        4) run_compose ;;
        5) deploy_k8s ;;
        6) check_status ;;
        7) stop_all ;;
        8) clean_all ;;
        9) show_logs ;;
        0) echo -e "${GREEN}До свидания!${NC}"; exit 0 ;;
        *) echo -e "${RED}Неверный выбор. Попробуйте снова.${NC}" ;;
    esac
    
    echo ""
    read -p "Нажмите Enter для продолжения..."
    clear
done 