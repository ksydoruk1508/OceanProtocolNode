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
 ██████   ██████ ███████  █████  ███    ██     ██████  ██████   ██████  ████████  ██████   ██████  ██████  ██      
██    ██ ██      ██      ██   ██ ████   ██     ██   ██ ██   ██ ██    ██    ██    ██    ██ ██      ██    ██ ██      
██    ██ ██      █████   ███████ ██ ██  ██     ██████  ██████  ██    ██    ██    ██    ██ ██      ██    ██ ██      
██    ██ ██      ██      ██   ██ ██  ██ ██     ██      ██   ██ ██    ██    ██    ██    ██ ██      ██    ██ ██      
 ██████   ██████ ███████ ██   ██ ██   ████     ██      ██   ██  ██████     ██     ██████   ██████  ██████  ███████ 
                                                                                                                   
                                                                                                                   
                                    ███    ██  ██████  ██████  ███████                                             
                                    ████   ██ ██    ██ ██   ██ ██                                                  
                                    ██ ██  ██ ██    ██ ██   ██ █████                                               
                                    ██  ██ ██ ██    ██ ██   ██ ██                                                  
                                    ██   ████  ██████  ██████  ███████ 
                                    
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
    echo -e "${BLUE}Обновляем сервер...${NC}"
    sudo apt-get update -y && sudo apt upgrade -y && sudo apt-get install make screen build-essential unzip lz4 gcc git jq docker.io docker-compose -y

    echo -e "${BLUE}Создаем директорию для ноды...${NC}"
    mkdir ocean && cd ocean

    echo -e "${BLUE}Скачиваем и устанавливаем Ocean ноду...${NC}"
    curl -O https://raw.githubusercontent.com/oceanprotocol/ocean-node/main/scripts/ocean-node-quickstart.sh && chmod +x ocean-node-quickstart.sh && ./ocean-node-quickstart.sh

    echo -e "${BLUE}Запускаем Docker контейнеры...${NC}"
    docker-compose -f docker-compose.yml up -d

    echo -e "${GREEN}Нода успешно установлена и запущена!${NC}"
}

function restart_node {
    echo -e "${BLUE}Перезапускаем ocean-node и typesense контейнеры...${NC}"
    docker restart ocean-node
    docker restart typesense
    sleep 7
    echo -e "${BLUE}ocean-node и typesense контейнеры перезапущены.${NC}"
}

function view_logs {
    echo -e "${YELLOW}Просмотр логов (выход из логов CTRL+C)...${NC}"
    docker logs -f ocean-node --tail=50
}

function remove_node {
    echo -e "${BLUE}Удаляем Docker контейнеры и директорию...${NC}"
    if [ -d "ocean" ]; then
        cd ocean
        if [ -f "docker-compose.yml" ]; then
            docker-compose -f docker-compose.yml down --remove-orphans || echo -e "${RED}Ошибка при остановке Docker контейнеров.${NC}"
            docker rm ocean-node --force 2>/dev/null || echo -e "${RED}Контейнер ocean-node не найден.${NC}"
            docker rm typesense --force 2>/dev/null || echo -e "${RED}Контейнер typesense не найден.${NC}"
            docker volume rm ocean_typesense-data 2>/dev/null || echo -e "${RED}Том ocean_typesense-data не найден.${NC}"
            cd ..
            rm -rf ocean
            echo -e "${GREEN}Нода успешно удалена.${NC}"
        else
            echo -e "${RED}Файл docker-compose.yml не найден. Убедитесь, что вы в правильной директории.${NC}"
        fi
    else
        echo -e "${RED}Директория ocean не найдена.${NC}"
    fi
}

function main_menu {
    while true; do
        echo -e "${YELLOW}Выберите действие:${NC}"
        echo -e "${CYAN}1. Установка ноды${NC}"
        echo -e "${CYAN}2. Рестарт ноды${NC}"
        echo -e "${CYAN}3. Просмотр логов${NC}"
        echo -e "${CYAN}4. Удаление ноды${NC}"
        echo -e "${CYAN}5. Перейти к другим нодам${NC}"
        echo -e "${CYAN}6. Выход${NC}"
       
        echo -e "${YELLOW}Введите номер действия:${NC} "
        read choice
        case $choice in
            1) install_node ;;
            2) restart_node ;;
            3) view_logs ;;
            4) remove_node ;;
            5) wget -q -O Ultimative_Node_Installer.sh https://raw.githubusercontent.com/ksydoruk1508/Ultimative_Node_Installer/main/Ultimative_Node_Installer.sh && sudo chmod +x Ultimative_Node_Installer.sh && ./Ultimative_Node_Installer.sh
            ;;
            6) break ;;
            *) echo -e "${RED}Неверный выбор, попробуйте снова.${NC}" ;;
        esac
    done
}

main_menu
