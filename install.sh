#!/usr/bin/env bash

# Exit on error
set -e

REPO="attestation-service-demo"
APP="bky-as"
VERSION="v0.1.0-beta.3"

# let the user know a step was successful
function passCheck() {
    echo "✅ $1"
}

# let the user know that we failed with an error
function exitWithErr() {
    echo "❌ ==> $1
       Could not continue.
       For feature requests or support please email info@blocky.rocks." >&2
    exit 1
}

function getOS() {
    case "$OSTYPE" in
        linux*)   echo "linux" ;;
        darwin*)  echo "darwin" ;;
        *)        exitWithErr "Unsupported OS" ;;
    esac
}

function getArch() {
    case "$(uname -m)" in
        x86_64)             echo "amd64" ;;
        arm64 | aarch64)    echo "arm64" ;;
        *)                  exitWithErr "Unsupported architecture" ;;
    esac
}

# check that the os arch combo that the person is installing is supported
function verifySupport() {
    local os=$1
    local arch=$2

    local supported=(linux-amd64 darwin-amd64 darwin-arm64)
    local current="$os-$arch"

    for i in "${supported[@]}"; do
        if [ "$i" == "$current" ]; then
            passCheck "Your platform is supported: $current"
            return 0
        fi
    done

    printf -v msg \
        'Your platform (%s) is unsupported. Supported platforms are:\n%s' \
        "${current}" \
        "$(printf '       - %s\n' ${supported[@]})"
    exitWithErr "$msg"
}

function verifyCurl() {
    if command -v "curl" > /dev/null; then
        passCheck "You have curl installed: $(which curl)"
    else
        exitWithErr "You do not have curl installed."
    fi
}

function downloadCLI() {
    local os=$1
    local arch=$2

    local base="https://github.com/blocky/${REPO}/releases/download"
    local artifact="${APP}_${os}_${arch}"
    local url="${base}/${VERSION}/${artifact}"

    if ! curl --silent --location --fail "${url}" -o "${APP}"; then
        exitWithErr " CLI download failed"
    fi
    chmod +x "${APP}"
}

function downloadConfig() {
    local base="https://github.com/blocky/${REPO}/releases/download"
    local artifact="config.toml"
    local url="${base}/${VERSION}/${artifact}"

    if ! curl --silent --location --fail "${url}" -o "${artifact}"; then
        exitWithErr "Config download failed"
    fi
}

function verifyCLI() {
    if ./${APP} --help > /dev/null 2>&1; then
        passCheck "SUCCESS! You have downloaded the ${APP} CLI"
    else
        exitWithErr "install failed"
    fi
}

function nextSteps() {
    cat << EOF
    To get started, check out the getting started guide and documentation at
    https://github.com/blocky/${REPO}
EOF
}


function main() {
    local os=$(getOS)
    local arch=$(getArch)

    verifySupport "$os" "$arch"
    verifyCurl
    downloadCLI "$os" "$arch"
    downloadConfig
    verifyCLI
    nextSteps
}

main
