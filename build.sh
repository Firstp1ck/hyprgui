#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function for logging
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then
    error "Please run this script with sudo"
fi

# Check if rust/rustup is installed
if ! command -v rustc &> /dev/null; then
    log "Rust is not installed. Installing Rust..."
    if ! sudo pacman -S --noconfirm --needed rustup; then
        error "Failed to install rustup"
    fi
    log "Rust installation completed"
else
    log "Rust is already installed"
fi

# Check if cargo is available
if ! command -v cargo &> /dev/null; then
    error "Cargo is not installed. Please install Rust toolchain properly"
fi

# Initialize Build
log "Starting build process..."
if ! cargo build --release; then
    error "Build failed"
fi

# Copy binary to /usr/bin
log "Copying binary to /usr/bin..."
if ! cp target/release/hyprgui /usr/bin/; then
    error "Failed to copy binary to /usr/bin"
fi

log "Build completed successfully!"
