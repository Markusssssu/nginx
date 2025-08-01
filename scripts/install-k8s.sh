#!/bin/bash

# Скрипт установки Kubernetes в Ubuntu
# Поддерживает: Ubuntu 20.04, 22.04

set -e

echo "=== Установка Kubernetes в Ubuntu ==="

# Проверяем систему
if ! command -v apt-get &> /dev/null; then
    echo "Ошибка: Этот скрипт предназначен для Ubuntu/Debian систем"
    exit 1
fi

# Обновляем систему
echo "1. Обновляем систему..."
sudo apt update && sudo apt upgrade -y

# Устанавливаем необходимые пакеты
echo "2. Устанавливаем необходимые пакеты..."
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Добавляем GPG ключ Docker
echo "3. Добавляем GPG ключ Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Добавляем репозиторий Docker
echo "4. Добавляем репозиторий Docker..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Обновляем список пакетов
sudo apt update

# Устанавливаем Docker
echo "5. Устанавливаем Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Добавляем пользователя в группу docker
echo "6. Добавляем пользователя в группу docker..."
sudo usermod -aG docker $USER

# Запускаем Docker
echo "7. Запускаем Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Настраиваем containerd
echo "8. Настраиваем containerd..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Отключаем swap
echo "9. Отключаем swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Загружаем модули ядра
echo "10. Загружаем модули ядра..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Настраиваем сетевые параметры
echo "11. Настраиваем сетевые параметры..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Добавляем GPG ключ Kubernetes
echo "12. Добавляем GPG ключ Kubernetes..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Добавляем репозиторий Kubernetes
echo "13. Добавляем репозиторий Kubernetes..."
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Обновляем список пакетов
sudo apt update

# Устанавливаем Kubernetes компоненты
echo "14. Устанавливаем Kubernetes компоненты..."
sudo apt install -y kubelet kubeadm kubectl

# Фиксируем версии пакетов
echo "15. Фиксируем версии пакетов..."
sudo apt-mark hold kubelet kubeadm kubectl

echo "=== Установка завершена! ==="
echo ""
echo "Для инициализации кластера выполните:"
echo "sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
echo ""
echo "Для подключения worker узлов выполните команду, которую выдаст kubeadm init"
echo ""
echo "Для установки сетевого плагина (например, Flannel):"
echo "kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"
echo ""
echo "ВАЖНО: Перезагрузите систему или перелогиньтесь для применения изменений группы docker" 