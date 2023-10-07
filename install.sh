#!/bin/bash
set -eo pipefail

######## VARIABLES #########
DOCKER_GIT_API="https://raw.githubusercontent.com/NicoDevelopp/docker/"
DOCKER_GIT_BRANCH="main"
DIALOG_HEIGHT=20
DIALOG_WIDTH=70
DIALOG_WIDTH_LARGE=90
DIALOG_TITLE="Installation / mise à jour d'un projet Symfony avec Docker"
IS_INSTALL=true
DOCKER_MIN_VERSION=23.0.0
TMP_PROJECT="/tmp/tmp-project"
DOCKER_COMPOSE="docker compose"
DOCKER_CONT="${DOCKER_COMPOSE} exec php"
SYMFONY_CONSOLE="php bin/console"
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
SYMFONY_VERSION="7.0.*"
# REPOSITORY
export CURRENT_UID
export CURRENT_GID


# Permet de vérifier qu'une commande est disponible sur le système
function isCommand() {
    local CHECK_COMMAND="$1"
    if ! command -v "${CHECK_COMMAND}" &> /dev/null; then
        echo "${RED}▸ L'utilitaire ${CHECK_COMMAND} n'est pas installé sur votre système. Veuillez l'installer avant.${RESET}"
        return 1;
    fi
}



# Couleurs
COL_NC='\e[0m'
COL_LIGHT_GREEN='\e[1;32m'
COL_LIGHT_RED='\e[1;31m'
TICK="[${COL_LIGHT_GREEN}✓${COL_NC}]"
INFO="[i]"
OVER="\\r\\033[K"

dialogs() {
    dialog  --clear \
            --title "${DIALOG_TITLE}" \
            --backtitle "Bienvenue" \
            --no-button "Annuler" \
            --yes-button "Continuer" \
            --yesno "\n\nConfiguration de l'environnement pour Symfony" \
            "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}"
    SELECTION=$(dialog  --clear \
                        --title "${DIALOG_TITLE}" \
                        --backtitle "Installation ou mise à jour" \
                        --ok-label "Continuer" \
                        --menu "Selectionner une option" "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}" 0 \
                        1 "Environnement seul" \
                        2 "Environnement avec Symfony" \
                        3 "Environnement avec une application existante" \
                        4 "Relancer environnement" \
                3>&1 1>&2 2>&3)

    case "$SELECTION" in
        1) dialogsFor1 
        ;;
        2) dialogsFor2
        ;;
        3) dialogsFor3
        ;;
        4) dialogsFor4
        ;;
    esac
}

dialogConfProject(){
    VALUES=$(dialog --clear \
                        --title "${DIALOG_TITLE}" \
                        --backtitle "Configuration du projet" \
                        --ok-label "Continuer" \
                        --form "Entrer les valeurs" "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}" 0 \
                        "Nom du projet:"          1 1 "app"           1 25 50 30 \
                        "Dossier de destination:" 2 1 "${HOME}/dev"   2 25 50 30 \
                3>&1 1>&2 2>&3)

    APP_NAME=$(echo "$VALUES" | sed -n 1p)
    PROJECT_INSTALL_DIR="$(echo "$VALUES" | sed -n 2p)/${APP_NAME}"
    ENV_FILE="${PROJECT_INSTALL_DIR}/.env.docker"
}

dialogConfBDD(){
    VALUES=$(dialog --clear \
                        --title "${DIALOG_TITLE}" \
                        --backtitle "Configuration de la BDD" \
                        --ok-label "Continuer" \
                        --form "Entrer les valeurs" "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}" 0 \
                        "Nom:"                    1 1 "dbname"           1 25 25 30 \
                        "Utilisateur:"            2 1 "dbuser"         2 25 25 30 \
                        "Mot de passe:"           3 1 "dbpasswd"          3 25 25 30 \
                        "Port:"                   4 1 "3306"         4 25 25 5 \
                3>&1 1>&2 2>&3)
    DB_DATABASE=$(echo "$VALUES" | sed -n 1p)
    DB_USER=$(echo "$VALUES" | sed -n 2p)
    DB_PASSWORD=$(echo "$VALUES" | sed -n 3p)
    DB_PORT=$(echo "$VALUES" | sed -n 4p)
}

dialogConfSymfony(){
    SYMFONY_VERSION=$(dialog --clear \
                                --title "${DIALOG_TITLE}" \
                                --backtitle "Configuration de Symfony" \
                                --radiolist "Sélectionner une version de Symfony" "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}" 0 \
                                "7.0.*"  "Version 7" on \
                                "6.4.*"  "Version 6.4" off \
                                "5.4.*"  "Version 5.4" off \
                            3>&1 1>&2 2>&3)
}

dialogConfPHP(){
    if [ ${SYMFONY_VERSION} = "7.0.*" ] ; then
        PHP_VERSION=$(dialog --clear \
                        --title "${DIALOG_TITLE}" \
                        --backtitle "Configuration de PHP" \
                        --radiolist "Sélectionner une version de PHP" "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}" 0 \
                        "8.3"  "Version 8.3" on \
                        "8.2"  "Version 8.2" off \
                    3>&1 1>&2 2>&3)
    else
        PHP_VERSION=$(dialog --clear \
                        --title "${DIALOG_TITLE}" \
                        --backtitle "Configuration de PHP" \
                        --radiolist "Sélectionner une version de PHP" "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}" 0 \
                        "8.3"  "Version 8.3" on \
                        "8.2"  "Version 8.2" off \
                        "8.1"  "Version 8.1" off \
                    3>&1 1>&2 2>&3)
    fi
}

dialogConfNode(){
    NODE_VERSION=$(dialog --clear \
                            --title "${DIALOG_TITLE}" \
                            --backtitle "Configuration de Node" \
                            --radiolist "Sélectionner une version de Node" "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}" 0 \
                            "20"  "Version 20" on \
                            "21"  "Version 21" off \
                        3>&1 1>&2 2>&3)
}

dialogConfNetwork(){
    VALUES=$(dialog --clear \
                        --title "${DIALOG_TITLE}" \
                        --backtitle "Configuration du réseau" \
                        --ok-label "Continuer" \
                        --form "Entrer les valeurs" "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}" 0 \
                        "Port HTTP :"              1 1 "8080"          1 25 50 30 \
                        "Port du Xdebug :"         2 1 "9003"          2 25 50 5 \
                        "Port de PHPMyAdmin :"     3 1 "9080"          3 25 50 5 \
                        "Port de SMTP :"           4 1 "1025"          4 25 50 5 \
                        "Port du Webmail :"        5 1 "8025"          5 25 50 5 \
                        "Port du PHPFPM :"         6 1 "9000"          6 25 50 5 \
                3>&1 1>&2 2>&3)

    HTTP_PORT=$(echo "$VALUES" | sed -n 1p)
    XDEBUG_PORT=$(echo "$VALUES" | sed -n 2p)
    PMA_PORT=$(echo "$VALUES" | sed -n 3p)
    SMTP_PORT=$(echo "$VALUES" | sed -n 4p)
    WEBMAIL_PORT=$(echo "$VALUES" | sed -n 5p)
    PHPFPM_PORT=$(echo "$VALUES" | sed -n 6p)
}

dialogConfNotEmpty(){
    if [ -d "${PROJECT_INSTALL_DIR}" ] ; then
        dialog --clear \
                --title "${DIALOG_TITLE}" \
                --backtitle "Répertoire de destination non vide" \
                --no-button "Annuler" \
                --yes-button "Continuer" \
                --yesno "\\n\\nLe répertoire du projet "${PROJECT_INSTALL_DIR}" n'est pas vide\\nVoulez-vous continuer ?" \
                "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}"
    fi
}

dialogsFor1() {
    dialogConfProject
    dialogConfBDD
    dialogConfPHP
    dialogConfNode
    dialogConfNetwork
    dialogConfNotEmpty
}

dialogsFor2() {
    dialogConfProject
    dialogConfBDD
    dialogConfSymfony
    dialogConfPHP
    dialogConfNode
    dialogConfNetwork
    dialogConfNotEmpty
}

dialogsFor3() {
    dialogConfProject
    dialogConfBDD
    dialogConfPHP
    dialogConfNode
    dialogConfNetwork
}

dialogsFor4(){
    dialogConfProject
}

finalDialog() {
    dialog --clear \
           --title "${DIALOG_TITLE}" \
           --backtitle "Fin d'installation" \
           --msgbox "Le projet est installé / mis à jour avec succès."  "${DIALOG_HEIGHT}" "${DIALOG_WIDTH}"
}
isCommand() {
    # Checks to see if the given command (passed as a string argument) exists on the system.
    # The function returns 0 (success) if the command exists, and 1 if it doesn't.
    local CHECK_COMMAND="$1"

    command -v "${CHECK_COMMAND}" >/dev/null 2>&1
}
versionLte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}
versionLt() {
    [ "$1" = "$2" ] && return 1 || versionLte $1 $2
}
# Récupération des fichiers
downloadFiles() {
    local STR="Récupération des fichiers vers ${PROJECT_INSTALL_DIR}"
    printf "  %b %s..." "${INFO}" "${STR}"

    cd "${LOCAL_REPO_PROJECT}"
    install -o "${USER}" --mode=755 --directory "${PROJECT_INSTALL_DIR}/public"
    curl --silent --output "${PROJECT_INSTALL_DIR}/compose.yaml" --remote-name "${DOCKER_GIT_API}${DOCKER_GIT_BRANCH}/compose.yaml"
    curl --silent --output "${PROJECT_INSTALL_DIR}/.env.docker" --remote-name "${DOCKER_GIT_API}${DOCKER_GIT_BRANCH}/.env.docker"
    curl --silent --output "${PROJECT_INSTALL_DIR}/Makefile" --remote-name "${DOCKER_GIT_API}${DOCKER_GIT_BRANCH}/Makefile"
    chmod 755 "${PROJECT_INSTALL_DIR}/.env.docker"
    chmod 755 "${PROJECT_INSTALL_DIR}/compose.yaml"
    chmod 755 "${PROJECT_INSTALL_DIR}/Makefile"
    printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${STR}"
}
#Configure le projet
configureProject() {
    local STR="Configuration du projet ${PROJECT_INSTALL_DIR}"
    printf "  %b %s..." "${INFO}" "${STR}"
    
    if [ ${SELECTION} != 4 ] ; then
        #Replace APP
        sed -i -E "s/(APP_NAME=).*/\1${APP_NAME}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        sed -i -E "s/(PHP_VERSION=).*/\1${PHP_VERSION}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        sed -i -E "s/(NODE_VERSION=).*/\1${NODE_VERSION}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        #Replace DATABASE
        sed -i -E "s/(DB_PORT=).*/\1${DB_PORT}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        sed -i -E "s/(DB_DATABASE=).*/\1${DB_DATABASE}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        sed -i -E "s/(DB_USER=).*/\1${DB_USER}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        sed -i -E "s/(DB_PASSWORD=).*/\1${DB_PASSWORD}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        #Replace NETWORK
        sed -i -E "s/(HTTP_PORT=).*/\1${HTTP_PORT}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        sed -i -E "s/(XDEBUG_PORT=).*/\1${XDEBUG_PORT}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        sed -i -E "s/(PMA_PORT=).*/\1${PMA_PORT}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        sed -i -E "s/(SMTP_PORT=).*/\1${SMTP_PORT}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        sed -i -E "s/(WEBMAIL_PORT=).*/\1${WEBMAIL_PORT}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
        sed -i -E "s/(PHPFPM_PORT=).*/\1${PHPFPM_PORT}/g" "${PROJECT_INSTALL_DIR}/.env.docker"
    fi

    if [ ! -f "${PROJECT_INSTALL_DIR}/.gitignore" ]; then
        touch "${PROJECT_INSTALL_DIR}/.gitignore"
    fi

    if ! grep -q "###> docker ###" "${PROJECT_INSTALL_DIR}/.gitignore"; then
        cat >> "${PROJECT_INSTALL_DIR}/.gitignore" <<ADD
###> docker ###
.env.docker
###< docker ###
ADD
    fi
    printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${STR}"
}

exportEnv() {
    if [[ -f "$ENV_FILE" ]]; then
        isCommand envsubst
        export $(echo $(grep -v '^#' $ENV_FILE | xargs -d '\n') | envsubst)
    fi
}
#Creation du projet
createProject() {
    local STR="Création du projet ${PROJECT_INSTALL_DIR}"

    printf "  %b %s..." "${INFO}" "${STR}"
    cd ${PROJECT_INSTALL_DIR}
    echo "▸ Création du nouveau projet"
    ${DOCKER_COMPOSE} rm --force --volumes --stop
    ${DOCKER_COMPOSE} up --detach
    printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${STR}"
}

installSymfony(){
    local STR="Installation de Symfony ${PROJECT_INSTALL_DIR}"

    printf "  %b %s..." "${INFO}" "${STR}"
    cd ${PROJECT_INSTALL_DIR}
    ${DOCKER_CONT} rm -fr ${TMP_PROJECT}
    ${DOCKER_CONT} composer create-project symfony/skeleton:"${SYMFONY_VERSION}" "${TMP_PROJECT}" --no-interaction
    ${DOCKER_CONT} rsync --archive --remove-source-files --update --compress "${TMP_PROJECT}/" /var/www/html/
    ${DOCKER_CONT} rm -fr ${TMP_PROJECT}
    ${DOCKER_CONT} setfacl -dR -m u:"${CURRENT_UID}":rwX -m u:${CURRENT_UID}:rwX var
    ${DOCKER_CONT} setfacl -dR -m u:"${CURRENT_UID}":rwX -m u:${CURRENT_UID}:rwX public
    printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${STR}"
}

#Démarrage du projet
startProject() {
    local STR="Démarrage du projet ${PROJECT_INSTALL_DIR}"

    printf "  %b %s..." "${INFO}" "${STR}"
    cd ${PROJECT_INSTALL_DIR}
    echo "▸ Démarrage du projet"
    ${DOCKER_COMPOSE} down
    ${DOCKER_COMPOSE} up --detach
    ${DOCKER_CONT} composer install
    ${DOCKER_CONT} chown -R ${CURRENT_UID}:${CURRENT_GID} .
    ${DOCKER_CONT} setfacl -dR -m u:"${CURRENT_UID}":rwX -m u:${CURRENT_UID}:rwX var
    ${DOCKER_CONT} setfacl -dR -m u:"${CURRENT_UID}":rwX -m u:${CURRENT_UID}:rwX public
    ${DOCKER_CONT} bin/console assets:install public/ --symlink --relative
    printf "%b  %b %s\\n" "${OVER}" "${TICK}" "${STR}"
}

#Vérifie Github
checkGithub() {
    STATUS=$(curl --head --silent "${DOCKER_GIT_API}${DOCKER_GIT_BRANCH}/compose.yaml" | head -n 1)
    if grep -q "200" <<< "$STATUS"; then
        return 0
    else
        return 1
    fi
}

#Vérifie la version de docker
checkDockerVersion() {
    DOCKER_VERSION=$(docker version --format '{{.Server.Version}}')
    if versionLte "$DOCKER_MIN_VERSION" $DOCKER_VERSION; then
        return 0
    else
        return 1
    fi
}

createEnvironnement() {
    downloadFiles
    configureProject
    exportEnv
    createProject
}

createEnvironnementWithSymfony() {
    downloadFiles
    configureProject
    exportEnv
    createProject
    installSymfony
}

createEnvironnementWithApp() {
    downloadFiles
    configureProject
    exportEnv
    startProject
}

rebootEnvironnement() {
    exportEnv
    startProject
}

main() {
    local STR="Dialog check"
    printf "\\n"
    if isCommand dialog ; then
        printf "  %b %s\\n" "${TICK}" "${STR}"
    else
        printf "  %b %s\\n" "${INFO}" "${STR}"
        printf "  %b %bL'utilitaire dialog n'est pas installé%b\\n" "${INFO}" "${COL_LIGHT_RED}" "${COL_NC}"
        printf "      Veuillez l'installer avant - sudo apt install dialog par exemple\\n"
        exit 2
    fi

    local STR="Make check"
    printf "\\n"
    if isCommand make ; then
        printf "  %b %s\\n" "${TICK}" "${STR}"
    else
        printf "  %b %s\\n" "${INFO}" "${STR}"
        printf "  %b %bL'utilitaire make n'est pas installé%b\\n" "${INFO}" "${COL_LIGHT_RED}" "${COL_NC}"
        printf "      Veuillez l'installer avant - sudo apt install make par exemple\\n"
        exit 2
    fi

    STR="Github check"
    if ! checkGithub ; then
        printf "  %b %s\\n" "${INFO}" "${STR}"
        printf "  %b %bLe Github n'est pas accessible.%b\\n" "${INFO}" "${COL_LIGHT_RED}" "${COL_NC}"
        exit 2
    fi

    STR="Docker check"
    if isCommand docker ; then
        printf "  %b %s\\n" "${TICK}" "${STR}"
    else
        printf "  %b %s\\n" "${INFO}" "${STR}"
        printf "  %b %bDocker n'est pas installé ou n'est pas lancé%b\\n" "${INFO}" "${COL_LIGHT_RED}" "${COL_NC}"
        printf "      Vérifier l'installation de docker et relancer l'installateur\\n"
        exit 2
    fi
    STR="Docker version check"
    if checkDockerVersion ; then
        printf "  %b %s\\n" "${TICK}" "${STR}"
    else
        printf "  %b %s\\n" "${INFO}" "${STR}"
        printf "  %b %bLa version de docker installée ne répond pas aux pré-requis minimun%b\\n" "${INFO}" "${COL_LIGHT_RED}" "${COL_NC}"
        printf "      Veuiller mettre à jour docker au moins en version $DOCKER_MIN_VERSION et relancer l'installateur\\n"
        exit 2
    fi
    dialogs
    case "$SELECTION" in
        1) createEnvironnement
        ;;
        2) createEnvironnementWithSymfony
        ;;
        3) createEnvironnementWithApp
        ;;
        4) rebootEnvironnement
        ;;
    esac

    finalDialog
    printf "  %b %b%s Terminé! %b\\n" "${TICK}" "${COL_LIGHT_GREEN}" "${COL_NC}"
}
main "$@"
