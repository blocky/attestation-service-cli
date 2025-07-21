#!/usr/bin/env bash

# Exit on error
set -e

AS_REPO="attestation-service-cli"
AS_APP="bky-as"
AS_VERSION="v0.1.0-beta.1"

C_REPO="compiler"
C_APP="bky-c"
C_VERSION="v0.1.0-beta.2"

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

function downloadASCLI() {
    local os=$1
    local arch=$2

    local base="https://github.com/blocky/${AS_REPO}/releases/download"
    local artifact="${AS_APP}_${os}_${arch}"
    local url="${base}/${AS_VERSION}/${artifact}"

    if ! curl --silent --location --fail --show-error "${url}" -o "${AS_APP}"; then
        exitWithErr " CLI download failed"
    fi
    chmod +x "${AS_APP}"
}

function downloadCCLI() {
    local os=$1
    local arch=$2

    local base="https://github.com/blocky/${C_REPO}/releases/download"
    local artifact="${C_APP}_${C_VERSION}_${os}_${arch}"
    local url="${base}/${C_VERSION}/${artifact}"

    if ! curl --silent --location --fail --show-error "${url}" -o "${C_APP}"; then
        exitWithErr " CLI download failed"
    fi
    chmod +x "${AS_APP}"
}

function downloadConfig() {
    local base="https://github.com/blocky/${AS_REPO}/releases/download"
    local artifact="config.toml"
    local url="${base}/${AS_VERSION}/${artifact}"

    if ! curl --silent --location --fail --show-error "${url}" -o "${artifact}"; then
        exitWithErr "Config download failed"
    fi
}

function verifyCLI() {
  local app=$1
    if ./${AS_APP} --help > /dev/null 2>&1; then
        passCheck "SUCCESS! You have downloaded the ${AS_APP} CLI"
    else
        exitWithErr "install failed"
    fi
}

function nextSteps() {
    cat << EOF
    To get started, check out the getting started guide and documentation at
    https://blocky-docs.redocly.app
EOF
}


function main() {
    local os=$(getOS)
    local arch=$(getArch)

    verifySupport "$os" "$arch"
    verifyCurl
    downloadASCLI "$os" "$arch"
    downloadConfig
    verifyCLI "$AS_APP"
    downloadCCLI "$os" "$arch"
    verifyCLI "$C_APP"
    nextSteps
}

main
