#!/bin/bash

# Скрипт инициализации Kubernetes кластера
# Выполнять ПОСЛЕ установки Kubernetes

set -e

echo "=== Инициализация Kubernetes кластера ==="

# Проверяем, что Docker запущен
if ! systemctl is-active --quiet docker; then
    echo "Ошибка: Docker не запущен"
    exit 1
fi

# Проверяем, что swap отключен
if swapon --show | grep -q .; then
    echo "Предупреждение: Swap включен. Рекомендуется отключить для Kubernetes"
    echo "Выполните: sudo swapoff -a"
fi

# Инициализируем кластер
echo "1. Инициализируем Kubernetes кластер..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$(hostname -I | awk '{print $1}')

# Создаем директорию для конфигурации
echo "2. Настраиваем kubectl для пользователя..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Устанавливаем сетевой плагин (Flannel)
echo "3. Устанавливаем сетевой плагин Flannel..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Ждем, пока все поды запустятся
echo "4. Ждем запуска системных подов..."
kubectl get pods --all-namespaces

echo ""
echo "=== Кластер инициализирован! ==="
echo ""
echo "Для проверки статуса кластера:"
echo "kubectl get nodes"
echo ""
echo "Для подключения worker узлов используйте команду:"
echo "sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>"
echo ""
echo "Для получения токена для подключения worker узлов:"
echo "sudo kubeadm token create --print-join-command" 