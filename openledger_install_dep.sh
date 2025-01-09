#!/bin/bash

set -e

# Этап 1: Установка Docker
sudo apt remove -y docker docker-engine docker.io containerd runc
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo docker --version

# Этап 2: Дополнительные библиотеки
sudo apt update
sudo apt install -y libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libsecret-1-0

# Этап 3: Загрузка пакета
wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip

# Этап 4: Установка unzip и screen
sudo apt install -y unzip screen

# Этап 5: Распаковка архива
unzip openledger-node-1.0.0-linux.zip

# Этап 6: Установка пакета
sudo dpkg -i openledger-node-1.0.0.deb || true

# Этап 7: Установка зависимостей для исправления проблем
sudo apt-get install -y -f

# Этап 8: Установка desktop-file-utils
sudo apt-get install -y desktop-file-utils

# Этап 9: Конфигурация пакетов
sudo dpkg --configure -a

# Этап 10: Установка xfce4 и xrdp
sudo apt update
sudo apt install -y xfce4 xfce4-goodies xrdp

# Этап 11: Настройка xrdp
echo '#!/bin/bash
startxfce4' | sudo tee /etc/xrdp/startwm.sh > /dev/null
sudo chmod +x /etc/xrdp/startwm.sh

# Этап 12: Установка xvfb и запуск
sudo apt install -y xvfb
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99

# Этап 13: Перезапуск xrdp
sudo systemctl restart xrdp

echo "Установка завершена."

