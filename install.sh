#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Get the parent directory (where both triton and jseo should be)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

print_info "Parent directory: $PARENT_DIR"

# Define paths
TRITON_DIR="$PARENT_DIR/triton"
JSEO_DIR="$PARENT_DIR/jseo"
JSEO_SOURCE="$JSEO_DIR/extra/jseo"
TRITON_EXTRA_DIR="$TRITON_DIR/python/triton/language/extra"
TRITON_JSEO_TARGET="$TRITON_EXTRA_DIR/jseo"

# Validate that triton directory exists
if [ ! -d "$TRITON_DIR" ]; then
    print_error "Triton directory not found at: $TRITON_DIR"
    print_error "Please ensure triton is cloned in the same parent directory as jseo"
    exit 1
fi

print_info "Found Triton directory: $TRITON_DIR"

# Validate that jseo source exists
if [ ! -d "$JSEO_SOURCE" ]; then
    print_error "JSEO source directory not found at: $JSEO_SOURCE"
    print_error "Expected structure: jseo/extra/jseo/"
    exit 1
fi

print_info "Found JSEO source directory: $JSEO_SOURCE"

# Check if extra directory exists in triton, create if not
if [ ! -d "$TRITON_EXTRA_DIR" ]; then
    print_warning "Extra directory doesn't exist in Triton"
    print_info "Creating: $TRITON_EXTRA_DIR"
    mkdir -p "$TRITON_EXTRA_DIR"
    
    # Create __init__.py to make it a Python package
    touch "$TRITON_EXTRA_DIR/__init__.py"
    print_info "Created __init__.py in extra directory"
fi

# Check if target already exists
if [ -d "$TRITON_JSEO_TARGET" ]; then
    print_warning "JSEO already exists in Triton at: $TRITON_JSEO_TARGET"
    read -p "Do you want to overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi
    print_info "Removing existing JSEO installation..."
    rm -rf "$TRITON_JSEO_TARGET"
fi

# Copy JSEO to Triton
print_info "Copying JSEO from:"
print_info "  Source: $JSEO_SOURCE"
print_info "  Target: $TRITON_JSEO_TARGET"

cp -r "$JSEO_SOURCE" "$TRITON_EXTRA_DIR/"

# Verify the copy was successful
if [ -d "$TRITON_JSEO_TARGET" ]; then
    print_info "✓ JSEO has been successfully installed to Triton"
    print_info "Location: $TRITON_JSEO_TARGET"
    
    # List installed files
    print_info "Installed files:"
    ls -la "$TRITON_JSEO_TARGET"
else
    print_error "✗ Installation failed - target directory not found"
    exit 1
fi

print_info "Installation complete!"