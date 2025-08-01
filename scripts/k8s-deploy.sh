#!/bin/bash

# Развертывание nginx в Kubernetes

set -e  

echo "=== Развертывание в Kubernetes ==="

# Проверяем kubectl
if ! command -v kubectl &> /dev/null; then
    echo "Ошибка: kubectl не установлен"
    echo "Установите kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Проверяем кластер
echo "Проверяем подключение к кластеру..."
if ! kubectl cluster-info &> /dev/null; then
    echo "Ошибка: Не удается подключиться к Kubernetes кластеру"
    echo "Убедитесь, что кластер запущен и kubectl настроен"
    exit 1
fi

# Удаляем старые ресурсы
echo "Удаляем существующие ресурсы..."
kubectl delete -f deployment.yaml 2>/dev/null || true

# Ждем удаления
sleep 5

# Применяем deployment
echo "Применяем deployment..."
kubectl apply -f deployment.yaml

# Ждем запуска подов
echo "Ждем запуска подов..."
kubectl wait --for=condition=ready pod -l app=nginx-devops --timeout=60s

# Показываем статус
echo "Статус deployment:"
kubectl get deployment nginx-devops

echo "Статус подов:"
kubectl get pods -l app=nginx-devops

echo "Статус сервиса:"
kubectl get service nginx-devops-service

# Получаем имя пода
POD_NAME=$(kubectl get pods -l app=nginx-devops -o jsonpath='{.items[0].metadata.name}')
echo "Имя пода: $POD_NAME"

# Показываем логи
echo "Логи пода:"
kubectl logs $POD_NAME

# Тестируем доступность
echo "Проверяем доступность пода..."
kubectl port-forward $POD_NAME 8080:80 &
PF_PID=$!

# Ждем запуска port-forward
sleep 3

# Проверяем
if curl -s http://localhost:8080 > /dev/null; then
    echo "Pod работает! Доступен через port-forward: http://localhost:8080"
else
    echo "Ошибка: pod не отвечает"
fi

# Останавливаем port-forward
kill $PF_PID 2>/dev/null || true

echo "=== Развертывание завершено! ==="
echo "Для просмотра логов: kubectl logs -f $POD_NAME"
echo "Для удаления: kubectl delete -f deployment.yaml" 