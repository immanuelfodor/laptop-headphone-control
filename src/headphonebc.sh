#!/bin/sh

# Last logs of this script: 
#   journalctl -b -t headphonebc | tail -n 50
# Follow the logs in realtime:
#   journalctl -b -t headphonebc -f
# Available sound interfaces:
#   amixer -c 0 contents

# Could use '/usr/bin/amixer sset Master toggle' for simplicity but it blinks a LED on my keyboard and I don't like it :D
# + It doesn't work for systemd usage, doesn't reenable the sound output actually, needs manual adjustment to get sound
# Other options, @see: https://unix.stackexchange.com/questions/32206/set-volume-from-terminal
# Using a different scale, @see: https://bbs.archlinux.org/viewtopic.php?id=135348

# Useful commands for sound levels and devices debugging while running from systemd:
#   AMIX_LOG=$(/usr/bin/amixer scontents)  # simplified
#   write_log "scontents: ${AMIX_LOG}"
#   AMIX_LOG=$(/usr/bin/amixer scontrols)  # simplified
#   write_log "scontrols: ${AMIX_LOG}"
#   AMIX_LOG=$(/usr/bin/amixer -c 0 contents)  # show all settings, including min/max limits
#   write_log "c 0 contents: ${AMIX_LOG}"
#   AMIX_LOG=$(/usr/bin/amixer -c 0 controls)  # show numid, interface, and name of each control
#   write_log "c 0 controls: ${AMIX_LOG}"


# The PCM version mutes the sound output completely but the OS toggle doesn't reflect any change,
# which is annoying for me. If you think that's all right, you can set this to No for using PCM
IS_MASTER_USED=Yes  # Yes or No


HBC_CONFIG_DIR="${HOME}/.config/headphonebc"
HBC_SVOL_FILE="${HBC_CONFIG_DIR}/saved-volume"


write_log () {
    local message="${1}"
    /usr/bin/logger -t "headphonebc" "${message}"
    /bin/echo "${message}"
}

mute () {
    VOLUME=$(/usr/bin/amixer -M get Master | /usr/bin/grep -oE '[0-9]+%' | /usr/bin/head -n 1)
    write_log "Current volume level: ${VOLUME}, saving and muting volume..."
    /usr/bin/echo "${VOLUME}" > "${HBC_SVOL_FILE}"

    if [ "${IS_MASTER_USED}" = "Yes" ] ; then
        AMIX_LOG=$(/usr/bin/amixer -M set Master "0%")
    else
        AMIX_LOG=$(/usr/bin/amixer sset PCM -- "0%")
    fi

    write_log "${AMIX_LOG}"
}

unmute () {
    VOLUME=$(/usr/bin/cat "${HBC_SVOL_FILE}" | /usr/bin/head -n 1)
    write_log "Previous volume level: ${VOLUME}, restoring..."
    rm -f "${HBC_SVOL_FILE}"

    if [ "${IS_MASTER_USED}" = "Yes" ] ; then
        AMIX_LOG=$(/usr/bin/amixer -M set Master "${VOLUME}")
    else
        AMIX_LOG=$(/usr/bin/amixer sset PCM -- "100%")
    fi

    write_log "${AMIX_LOG}"
}


/usr/bin/mkdir -p "${HBC_CONFIG_DIR}"

if [ -f "${HBC_SVOL_FILE}" ]; then
    unmute
else
    mute
fi
