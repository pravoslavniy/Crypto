#!/bin/bash

set -e

# Этап 1: Установка Docker
echo "=== Этап 1: Установка Docker ==="
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; then
    echo "Не удалось загрузить ключ Docker."
    exit 1
fi

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
if ! sudo apt-get install -y docker-ce docker-ce-cli containerd.io; then
    echo "Не удалось установить Docker."
    exit 1
fi

if ! sudo docker --version; then
    echo "Проверка установки Docker не удалась."
    exit 1
fi

# Этап 2: Установка дополнительных библиотек
echo "=== Этап 2: Установка дополнительных библиотек ==="
sudo apt-get update
sudo apt-get install -y libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libsecret-1-0

# Этап 3: Загрузка пакета (с проверкой наличия)
echo "=== Этап 3: Загрузка пакета ==="
if [[ -f "openledger-node-1.0.0-linux.zip" || -f "openledger-node-1.0.0.deb" ]]; then
    echo "Файлы openledger-node-1.0.0-linux.zip или openledger-node-1.0.0.deb уже существуют. Пропускаем загрузку."
else
    wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip
fi

# Этап 4: Установка unzip и screen
echo "=== Этап 4: Установка unzip и screen ==="
sudo apt-get install -y unzip screen

# Этап 5: Распаковка архива
echo "=== Этап 5: Распаковка архива ==="
unzip -o openledger-node-1.0.0-linux.zip

# Этап 6: Установка пакета
echo "=== Этап 6: Установка пакета ==="
sudo dpkg -i openledger-node-1.0.0.deb || true

# Этап 7: Установка зависимостей для исправления проблем
echo "=== Этап 7: Установка зависимостей для исправления проблем ==="
sudo apt-get install -y -f

# Этап 8: Установка desktop-file-utils
echo "=== Этап 8: Установка desktop-file-utils ==="
sudo apt-get install -y desktop-file-utils

# Этап 9: Конфигурация пакетов
echo "=== Этап 9: Конфигурация пакетов ==="
sudo dpkg --configure -a

# Этап 10: Установка xfce4 и xrdp
echo "=== Этап 10: Установка xfce4 и xrdp ==="
sudo apt-get update
sudo apt-get install -y xfce4 xfce4-goodies xrdp

# Этап 11: Настройка xrdp
echo "=== Этап 11: Настройка xrdp ==="
echo '#!/bin/bash
startxfce4' | sudo tee /etc/xrdp/startwm.sh > /dev/null
sudo chmod +x /etc/xrdp/startwm.sh

# Этап 12: Установка xvfb и запуск
echo "=== Этап 12: Установка xvfb и запуск ==="
sudo apt-get install -y xvfb
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99

# Этап 13: Перезапуск xrdp
echo "=== Этап 13: Перезапуск xrdp ==="
sudo systemctl restart xrdp

echo "Установка завершена."

