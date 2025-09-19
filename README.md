

настройка nginx, CI/CD пайплайн, Docker контейнеризацию и Kubernetes deployment.

## Структура проекта

- `run.sh` - **Главный скрипт** для автоматической установки и управления проектом
- `.gitlab-ci.yml` - GitLab CI/CD пайплайн для тестирования nginx
- `Dockerfile` - Docker образ с nginx и кастомной страницей
- `deployment.yaml` - Kubernetes deployment для nginx
- `docker-compose.yml` - Docker Compose конфигурация
- `nginx-config/` - конфигурационные файлы nginx
- `html/` - HTML файлы для веб-страницы

## Задания

### 1. Подготовка тестового окружения
- Установка и настройка nginx на Ubuntu 20.04+
- Настройка systemd-сервиса для автозапуска nginx

### 2. GitLab CI/CD пайплайн
- Простой `.gitlab-ci.yml` с этапом тестирования nginx

### 3. Docker контейнеризация
- Dockerfile для создания образа nginx с кастомной страницей

### 4. Kubernetes deployment
- Простой deployment.yaml для запуска nginx в Kubernetes

## Ответы на вопросы

### 1. Чем отличается apt update от apt upgrade?

**apt update:**
- Обновляет список доступных пакетов из репозиториев
- Скачивает информацию о новых версиях пакетов
- НЕ устанавливает новые версии пакетов
- Команда: `sudo apt update`

**apt upgrade:**
- Устанавливает новые версии уже установленных пакетов
- Требует предварительного выполнения `apt update`
- Может удалять пакеты, если это необходимо для обновления
- Команда: `sudo apt upgrade`

### 2. Как проверить, слушает ли сервис нужный порт?

**Основные команды:**

```bash
# Проверка всех открытых портов
netstat -tulpn

# Проверка конкретного порта (например, 80)
netstat -tulpn | grep :80

# Использование ss (более современная альтернатива netstat)
ss -tulpn

# Проверка с помощью lsof
lsof -i :80

# Проверка с помощью nmap
nmap localhost -p 80

# Проверка статуса конкретного сервиса
systemctl status nginx
```

### 3. Какие команды использовать для диагностики сетевых проблем?

**Основные команды для диагностики:**

```bash
# Проверка подключения к интернету
ping google.com

# Проверка DNS резолвинга
nslookup google.com
dig google.com

# Проверка маршрута до хоста
traceroute google.com
mtr google.com

# Проверка сетевых интерфейсов
ip addr show
ifconfig

# Проверка маршрутов
ip route show
route -n

# Проверка активных соединений
netstat -tulpn
ss -tulpn

# Проверка файрвола
iptables -L
ufw status

# Проверка логов
journalctl -u nginx
tail -f /var/log/nginx/error.log
```

## Быстрый запуск

### Автоматическая установка (рекомендуется)
```bash
# Делаем скрипт исполняемым
chmod +x run.sh

# Запускаем автоматическую установку
./run.sh
```

Выберите опцию **1** для автоматической установки всего проекта.

### Меню run.sh

Скрипт `run.sh` предоставляет интерактивное меню с следующими опциями:

- **1. Автоматическая установка и запуск** - Устанавливает все компоненты и запускает проект
- **2. Установить nginx локально** - Устанавливает nginx на систему
- **3. Установить Docker** - Устанавливает Docker
- **4. Запустить Docker контейнер** - Собирает и запускает Docker образ
- **5. Запустить с docker-compose** - Запускает проект через Docker Compose
- **6. Установить и настроить Kubernetes** - Устанавливает Kubernetes кластер
- **7. Развернуть в Kubernetes** - Развертывает приложение в K8s
- **8. Проверить статус всех сервисов** - Показывает статус всех компонентов
- **9. Остановить все сервисы** - Останавливает все запущенные сервисы
- **10. Очистить все** - Удаляет все контейнеры и настройки
- **11. Показать логи** - Отображает логи сервисов

### Ручная установка

#### Локальная установка nginx
```bash
# Установка nginx
sudo apt update
sudo apt install nginx

# Запуск и включение автозапуска
sudo systemctl start nginx
sudo systemctl enable nginx

# Проверка статуса
sudo systemctl status nginx
```

#### Запуск Docker контейнера
```bash
# Сборка образа
docker build -t nginx-devops .

# Запуск контейнера
docker run -d -p 8080:80 nginx-devops

# Проверка
curl localhost:8080
```

#### Запуск в Kubernetes
```bash
# Применение deployment
kubectl apply -f deployment.yaml

# Проверка статуса
kubectl get pods
kubectl get services
``` 
