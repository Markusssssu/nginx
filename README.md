# Тестовое задание: Junior DevOps / Системный администратор (Linux)

Этот репозиторий содержит выполнение тестового задания по DevOps, включающее настройку nginx, CI/CD пайплайн, Docker контейнеризацию и Kubernetes deployment.

## Структура проекта

- `.gitlab-ci.yml` - GitLab CI/CD пайплайн для тестирования nginx
- `Dockerfile` - Docker образ с nginx и кастомной страницей
- `deployment.yaml` - Kubernetes deployment для nginx
- `nginx-config/` - конфигурационные файлы nginx
- `scripts/` - скрипты для автоматизации

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

## Запуск проекта

### Локальная установка nginx
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

### Запуск Docker контейнера
```bash
# Сборка образа
docker build -t nginx-devops .

# Запуск контейнера
docker run -d -p 8080:80 nginx-devops

# Проверка
curl localhost:8080
```

### Запуск в Kubernetes
```bash
# Применение deployment
kubectl apply -f deployment.yaml

# Проверка статуса
kubectl get pods
kubectl get services
``` 