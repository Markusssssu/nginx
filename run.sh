#!/bin/bash

# DevOps Test Task - Мини версия
set -e

# Радужные цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Радужный текст
rainbow() {
    local text="$1"
    local colors=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$PURPLE" "$CYAN")
    local result=""
    for ((i=0; i<${#text}; i++)); do
        local color=${colors[$((i % ${#colors[@]}))]}
        result+="${color}${text:$i:1}${NC}"
    done
    echo -e "$result"
}

# Меню
show_menu() {
    echo -e "${BLUE}=== DevOps Test Task ===${NC}"
    echo ""
    rainbow "1. Полная установка"
    rainbow "2. Kubernetes"
    rainbow "3. Логи"
    rainbow "4. Статус"
    rainbow "0. Выход"
    echo ""
}

# Полная установка
install_all() {
    echo -e "${YELLOW}Устанавливаю все...${NC}"
    
    # Система
    sudo apt update && sudo apt upgrade -y
    
    # Nginx
    sudo apt install -y nginx
    sudo systemctl start nginx && sudo systemctl enable nginx
    
    # Docker
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER && sudo service docker start
    
    # Docker-compose
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Проект
    docker stop nginx-devops 2>/dev/null || true
    docker rm nginx-devops 2>/dev/null || true
    docker-compose down 2>/dev/null || true
    docker build -t nginx-devops .
    docker-compose up -d
    
    rainbow "Готово! Nginx: localhost, Docker: localhost:8080"
}

# Kubernetes
install_k8s() {
    echo -e "${YELLOW}Ставлю Kubernetes...${NC}"
    
    if command -v kubectl &> /dev/null; then
        rainbow "Kubernetes уже есть!"
        return 0
    fi
    
    # Docker если нет
    if ! command -v docker &> /dev/null; then
        install_all
    fi
    
    # Настройка
    sudo mkdir -p /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    sudo systemctl restart containerd
    
    sudo swapoff -a
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    
    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
    sudo modprobe overlay && sudo modprobe br_netfilter
    
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
    sudo sysctl --system
    
    # Установка
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt update && sudo apt install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    
    # Инициализация
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$(hostname -I | awk '{print $1}')
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    
    kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
    
    rainbow "Kubernetes готов!"
    kubectl get nodes
}

# Логи
show_logs() {
    echo -e "${YELLOW}Логи:${NC}"
    echo -e "${BLUE}Nginx:${NC}"
    sudo tail -5 /var/log/nginx/access.log 2>/dev/null || echo "Нет логов"
    echo -e "${BLUE}Docker:${NC}"
    docker logs nginx-devops 2>/dev/null || echo "Нет контейнера"
}

# Статус
check_status() {
    echo -e "${YELLOW}Статус:${NC}"
    echo -e "${BLUE}Nginx:${NC} $(systemctl is-active --quiet nginx && echo "OK" || echo "OFF")"
    echo -e "${BLUE}Docker:${NC} $(docker ps | grep nginx-devops && echo "OK" || echo "OFF")"
    echo -e "${BLUE}K8s:${NC} $(command -v kubectl &> /dev/null && kubectl get pods -l app=nginx-devops 2>/dev/null | grep Running && echo "OK" || echo "OFF")"
}

# Главный цикл
while true; do
    show_menu
    read -p "Выбор (0-4): " choice
    
    case $choice in
        1) install_all ;;
        2) install_k8s ;;
        3) show_logs ;;
        4) check_status ;;
        0) rainbow "Пока!"; exit 0 ;;
        *) echo -e "${RED}Неверно${NC}" ;;
    esac
    
    echo ""
    read -p "Enter для продолжения..."
    clear
done 