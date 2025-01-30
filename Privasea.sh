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

function install_node {
    echo -e "${BLUE}Обновляем сервер и устанавливаем необходимые пакеты...${NC}"
    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo -e "${GREEN}Docker установлен успешно!${NC}"
    
    echo -e "${BLUE}Скачиваем образ ноды Privasea...${NC}"
    docker pull privasea/acceleration-node-beta:latest
    
    echo -e "${BLUE}Создаем каталог и переходим в него...${NC}"
    mkdir -p ~/privasea/config && cd ~/privasea
    
    echo -e "${YELLOW}Получаем файлы хранилища...${NC}"
    docker run --rm -it -v "$HOME/privasea/config:/app/config" privasea/acceleration-node-beta:latest ./node-calc new_keystore
    
    echo -e "${YELLOW}Введите пароль для хранения ключей (скопируйте заранее и вставьте):${NC}"
    read -s KEYSTORE_PASSWORD
    
    echo -e "${BLUE}Скопируйте node address и node filename, затем нажмите ENTER...${NC}"
    read
    
    echo -e "${YELLOW}Экспортируйте ключ из root/privasea/config/walletkeystore, затем нажмите ENTER...${NC}"
    read
    
    echo -e "${YELLOW}Импортируйте JSON-файл в Metamask/Rabby, затем нажмите ENTER...${NC}"
    read
    
    echo -e "${YELLOW}Открываем каталог config...${NC}"
    cd ~/privasea/config
    ls
    
    echo -e "${YELLOW}Скопируйте UTC_СТРОКА, затем нажмите ENTER...${NC}"
    read
    
    echo -e "${BLUE}Перемещаем файл... Введите UTC_СТРОКА:${NC}"
    read UTC_STRING
    mv "$HOME/privasea/config/$UTC_STRING" "$HOME/privasea/config/wallet_keystore"
    
    echo -e "${YELLOW}Запросите тестовые токены на https://faucet.quicknode.com/arbitrum/sepolia, затем нажмите ENTER...${NC}"
    read
    
    echo -e "${YELLOW}Настройте ноду на https://deepsea-beta.privasea.ai/privanetixNode, затем нажмите ENTER...${NC}"
    read
    
    echo -e "${BLUE}Запускаем ноду...${NC}"
    docker run -d --name privanetix-node -v "$HOME/privasea/config:/app/config" -e KEYSTORE_PASSWORD=$KEYSTORE_PASSWORD privasea/acceleration-node-beta:latest
    echo -e "${GREEN}Нода успешно установлена и запущена!${NC}"
}

function view_logs {
    echo -e "${YELLOW}Просмотр логов ноды (CTRL+C для выхода)...${NC}"
    docker logs -f privanetix-node --tail=50
}

function remove_node {
    echo -e "${BLUE}Останавливаем и удаляем ноду...${NC}"
    docker stop privanetix-node && docker rm privanetix-node
    rm -rf ~/privasea
    echo -e "${GREEN}Нода удалена!${NC}"
}

function main_menu {
    while true; do
        echo -e "${YELLOW}Выберите действие:${NC}"
        echo -e "${CYAN}1. Установка ноды${NC}"
        echo -e "${CYAN}2. Просмотр логов${NC}"
        echo -e "${CYAN}3. Удаление ноды${NC}"
        echo -e "${CYAN}4. Выход${NC}"
        
        read choice
        case $choice in
            1) install_node ;;
            2) view_logs ;;
            3) remove_node ;;
            4) break ;;
            *) echo -e "${RED}Неверный выбор, попробуйте снова.${NC}" ;;
        esac
    done
}

main_menu
