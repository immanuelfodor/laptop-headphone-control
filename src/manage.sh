#!/bin/sh

CLI_OPTION="${1}"
CURRENT_DIR="$(dirname $(realpath -s ${0}))"

HBC_INSTALL_DIR="/usr/local/bin"
HBC_CONFIG_DIR="${HOME}/.config/headphonebc"
HBC_SERVICE_DIR="/usr/lib/systemd/system"
HBC_SERVICE_NAME="headphonebc@${USER}.service"


install () {
    mkdir -p "${HBC_CONFIG_DIR}"
    sudo mkdir -p "${HBC_INSTALL_DIR}"
    sudo cp -f "${CURRENT_DIR}/headphonebc.sh" "${HBC_INSTALL_DIR}/"
    sudo cp -f "${CURRENT_DIR}/headphonebc@.service" "${HBC_SERVICE_DIR}/"

    sudo systemctl daemon-reload
    enable
}

enable () {
    sudo systemctl enable "${HBC_SERVICE_NAME}"
    sudo systemctl start  "${HBC_SERVICE_NAME}"
    sleep 2
    status
}

status () {
    sudo systemctl status "${HBC_SERVICE_NAME}"
}

disable () {
    sudo systemctl stop    "${HBC_SERVICE_NAME}"
    sudo systemctl disable "${HBC_SERVICE_NAME}"
}

remove () {
    disable

    sudo rm -f  "${HBC_SERVICE_DIR}/headphonebc@.service"
    sudo rm -f  "${HBC_INSTALL_DIR}/headphonebc.sh"
    rm -rf "${HBC_CONFIG_DIR}"

    sudo systemctl daemon-reload
}


case $CLI_OPTION in
    install|remove|enable|disable|status)
            $CLI_OPTION
        ;;
    *)
            echo 'Usage: ./manage.sh OPTION'
            echo 'OPTION: (install|remove|enable|disable|status)'
        ;;
esac
