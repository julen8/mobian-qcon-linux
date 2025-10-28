#!/bin/sh

# This script lists all config options enabled (either y or m) in $1 and
# looks into debian.config, debian.arm64.config & mobian.config for those
# It then prints the results to the terminal, using colors for highlighting
# the state of each option in each file
#
# Usage: ./debian/config/check_config.sh <vendor>.config
# Example output:
#
# CONFIG_PANIC_ON_OOPS
#   [n] debian    [ ] debian.arm64    [y] mobian    [ ] sc7280

# Mandatory param, usually the vendor-specific config fragment
CONFIG="$1"

# Optional, useful for e.g. comparing with a defconfig based on a pmOS config
# Usage: ./debian/config/check_config.sh <vendor>.config /path/to/pmOS_defconfig
COMPARE_FILE=""
if [ -e "$2" ]; then
    COMPARE_FILE="$(realpath "$2")"
    echo "$COMPARE_FILE"
fi

IDENTIFIERS="$(grep -E '^CONFIG.*=(y|m)' ${CONFIG} | sed 's/=.*//g')"

CONFIG_DIR="$(dirname $(realpath "${CONFIG}"))"
OLDPATH="${PWD}"
if [ "${OLDPATH}" != "${CONFIG_DIR}" ]; then
    cd "${CONFIG_DIR}"
fi

CONFIG="$(basename "${CONFIG}")"

get_state() {
    ID="$1"
    FILE="$2"

    LINE="$(grep -E "${ID}( |=)" "${FILE}")"
    if [ "${CONFIG}" = "${FILE}" ]; then
        BOLD="01;"
    else
        BOLD=""
    fi

    if [ -z "$LINE" ]; then
        echo -n "\e[${BOLD}37m  [ ] ${FILE%.config}  "
    elif echo "$LINE" | grep -q "is not set"; then
        echo -n "\e[${BOLD}31m  [n] ${FILE%.config}  "
    elif echo "$LINE" | grep -q "=m"; then
        echo -n "\e[${BOLD}33m  [m] ${FILE%.config}  "
    else
        echo -n "\e[${BOLD}32m  [y] ${FILE%.config}  "
    fi
}

for id in ${IDENTIFIERS}; do
    echo "${id}"
    get_state "${id}" debian.config
    get_state "${id}" debian.arm64.config
    get_state "${id}" mobian.config
    get_state "${id}" "${CONFIG}"
    if [ "${COMPARE_FILE}" ]; then
        get_state "${id}" "${COMPARE_FILE}"
    fi
    echo "\e[00m"
done

if [ "${PWD}" != "${OLDPATH}" ]; then
    cd "${OLDPATH}"
fi
