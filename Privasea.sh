#!/bin/bash

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Нет цвета (сброс цвета)

# Проверка наличия curl и установка, если не установлен
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi
sleep 1

echo -e "${GREEN}"
cat << "EOF"
██████  ██████  ██ ██    ██  █████  ███████ ███████  █████      ███    ██  ██████  ██████  ███████ 
██   ██ ██   ██ ██ ██    ██ ██   ██ ██      ██      ██   ██     ████   ██ ██    ██ ██   ██ ██      
██████  ██████  ██ ██    ██ ███████ ███████ █████   ███████     ██ ██  ██ ██    ██ ██   ██ █████   
██      ██   ██ ██  ██  ██  ██   ██      ██ ██      ██   ██     ██  ██ ██ ██    ██ ██   ██ ██      
██      ██   ██ ██   ████   ██   ██ ███████ ███████ ██   ██     ██   ████  ██████  ██████  ███████

________________________________________________________________________________________________________________________________________


███████  ██████  ██████      ██   ██ ███████ ███████ ██████      ██ ████████     ████████ ██████   █████  ██████  ██ ███    ██  ██████  
██      ██    ██ ██   ██     ██  ██  ██      ██      ██   ██     ██    ██           ██    ██   ██ ██   ██ ██   ██ ██ ████   ██ ██       
█████   ██    ██ ██████      █████   █████   █████   ██████      ██    ██           ██    ██████  ███████ ██   ██ ██ ██ ██  ██ ██   ███ 
██      ██    ██ ██   ██     ██  ██  ██      ██      ██          ██    ██           ██    ██   ██ ██   ██ ██   ██ ██ ██  ██ ██ ██    ██ 
██       ██████  ██   ██     ██   ██ ███████ ███████ ██          ██    ██           ██    ██   ██ ██   ██ ██████  ██ ██   ████  ██████  
                                                                                                                                         
                                                                                                                                         
 ██  ██████  ██       █████  ███    ██ ██████   █████  ███    ██ ████████ ███████                                                         
██  ██        ██     ██   ██ ████   ██ ██   ██ ██   ██ ████   ██    ██    ██                                                             
██  ██        ██     ███████ ██ ██  ██ ██   ██ ███████ ██ ██  ██    ██    █████                                                          
██  ██        ██     ██   ██ ██  ██ ██ ██   ██ ██   ██ ██  ██ ██    ██    ██                                                             
 ██  ██████  ██      ██   ██ ██   ████ ██████  ██   ██ ██   ████    ██    ███████

Donate: 0x0004230c13c3890F34Bb9C9683b91f539E809000
EOF
echo -e "${NC}"

# Обновляем систему и устанавливаем необходимые пакеты
echo -e "${BLUE}Обновляем систему и устанавливаем пакеты...${NC}"
sudo apt update -y && sudo apt upgrade -y
sudo apt-get install -y ca-certificates curl gnupg

# Устанавливаем Docker
echo -e "${BLUE}Устанавливаем Docker...${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y && sudo apt upgrade -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker --version

# Загружаем Docker-образ ноды
echo -e "${BLUE}Загружаем Docker-образ Privasea...${NC}"
docker pull privasea/acceleration-node-beta:latest

# Создаем каталог для ноды
mkdir -p ~/privasea/config && cd ~/privasea

echo -e "${YELLOW}Создаем файл хранилища... Введите пароль дважды!${NC}"
docker run --rm -it -v "$HOME/privasea/config:/app/config" privasea/acceleration-node-beta:latest ./node-calc new_keystore

echo -e "${CYAN}Скопируйте node address и node filename и скачайте config файл.${NC}"

echo -e "${YELLOW}Введите имя файла (начинается с UTC): ${NC}"
read NODE_FILENAME
mv "$HOME/privasea/config/$NODE_FILENAME" "$HOME/privasea/config/wallet_keystore"

echo -e "${YELLOW}Введите пароль от хранилища (тот, что вводили ранее): ${NC}"
read -s KEYSTORE_PASSWORD

# Запуск ноды
echo -e "${BLUE}Запускаем ноду...${NC}"
docker run -d --name privanetix-node -v "$HOME/privasea/config:/app/config" -e KEYSTORE_PASSWORD=$KEYSTORE_PASSWORD privasea/acceleration-node-beta:latest

# Меню управления
while true; do
    echo -e "${YELLOW}Выберите действие:${NC}"
    echo -e "${CYAN}1. Установка ноды${NC}"
    echo -e "${CYAN}2. Рестарт ноды${NC}"
    echo -e "${CYAN}3. Просмотр логов${NC}"
    echo -e "${CYAN}4. Изменить порт${NC}"
    echo -e "${CYAN}5. Удаление ноды${NC}"
    echo -e "${CYAN}6. Перейти к другим нодам${NC}"
    echo -e "${CYAN}7. Выход${NC}"
    read -p "Введите номер действия: " choice
    case $choice in
        1) echo -e "${GREEN}Нода уже установлена.${NC}" ;;
        2) echo -e "${BLUE}Перезапускаем ноду...${NC}"; docker restart privanetix-node ;;
        3) echo -e "${CYAN}Просмотр логов...${NC}"; docker logs -f privanetix-node ;;
        4) echo -e "${RED}Изменение порта пока не реализовано.${NC}" ;;
        5) echo -e "${RED}Удаляем ноду...${NC}"; docker stop privanetix-node && docker rm privanetix-node && rm -rf ~/privasea ;;
        6) echo -e "${BLUE}Переход к другим нодам...${NC}" ;;
        7) echo -e "${GREEN}Выход.${NC}"; break ;;
        *) echo -e "${RED}Неверный выбор, попробуйте снова.${NC}" ;;
    esac
done
