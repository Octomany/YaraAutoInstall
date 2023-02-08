#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
if [ "$USER" != "root" ]
then
    echo -e "${RED}[!] SVP lancer le script as root ou avec sudo"
    exit 2
fi
echo
echo "Bash script pour installer la dernière version de Yara automatiquement."
echo
echo -e "${CYAN}[NOTE]${NC} J'avais une erreur ${RED}'yara: error while loading shared libraries: libyara.so.9: cannot open shared object file: No such file or directory'${NC} lors de l'exécution de Yara après l'installation dans mon Security Onion. Il faut recréer le symlink pour que ça fonctionne. Le script devrait détecter si vous avez la même erreur et tenter une réparation automatique."
echo
echo " - Maxime Beauchamp"
echo
echo
echo -e "${RED}***********************************************************************************"
echo -e "ATTENTION : AVEZ-VOUS FAIT UN SNAPSHOT DE VOTRE VM AVANT DE LANCER L'INSTALLATION ?"
echo -e "***********************************************************************************${NC}"
echo
read -p "Appuyez sur une touche pour continuer..." </dev/tty
echo
echo -e "${GREEN}[+] Installation de automake, libtool, make, gc, pkg-config...${NC}"
echo
apt install automake libtool make gcc pkg-config
echo
echo -e "${GREEN}[+] Download de Yara 4.2.3...${NC}"
echo
cd /opt
wget https://github.com/VirusTotal/yara/archive/refs/tags/v4.2.3.tar.gz
tar -zxf ./v4.2.3.tar.gz
rm ./v4.2.3.tar.gz
cd yara-4.2.3
echo
echo -e "${GREEN}[+] Installation de Yara...${NC}"
echo
./bootstrap.sh
./configure
make
make install
echo
echo -e "${GREEN}[+] Installation de Yara complétée!${NC}"
echo
echo -e "Vérification de l'installation..."
echo
YaraOutput=`yara 2>&1`
if [ "${YaraOutput}" == "yara: error while loading shared libraries: libyara.so.9: cannot open shared object file: No such file or directory" ]
then
    echo -e "${RED}[!] Erreur d'exécution détectée : Tentative de réparation automatique..."
    echo
    echo -e "${RED}[-] Suppression du fichier /usr/local/bin/yara...${NC}"
    echo
    rm /usr/local/bin/yara
    echo -e "${GREEN}[+] Création du nouveau fichier yara...${NC}"
    echo
    ln -s /opt/yara-4.2.3/yara /usr/local/bin/yara
    echo -e "Réparation complétée... Vous pouvez lancer yara en tapant la commande ${GREEN}yara${NC}"
    read -p "Appuyez sur une touche pour continuer..." </dev/tty
fi
exit 0
