# Docker образ с nginx и кастомной страницей
FROM nginx:stable

# Метаданные образа
LABEL maintainer="DevOps Test Task"
LABEL description="Nginx container with custom 'Hello from DevOps!' page"

# Копируем HTML страницу
COPY html/index.html /usr/share/nginx/html/index.html

# Копируем конфигурацию nginx
COPY nginx-config/nginx.conf /etc/nginx/nginx.conf

# Открываем порт 80
EXPOSE 80

# Проверяем конфигурацию
RUN nginx -t

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"] 