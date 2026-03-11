#!/bin/bash
# Wrapper around hypatia_build.sh for Fedora 43 (Python 3.12+)
# Uses python3.11 to work around waf's removed `imp` module

# Check python3.11 is available
if ! command -v python3.11 &> /dev/null; then
    echo "python3.11 not found. Install it with:"
    echo "  sudo dnf install -y python3.11"
    exit 1
fi

# Create a temporary python3 shim pointing to python3.11
SHIM_DIR=$(mktemp -d)
cat > "$SHIM_DIR/python3" << 'EOF'
#!/bin/bash
exec python3.11 "$@"
EOF
chmod +x "$SHIM_DIR/python3"

# Run the original build script with the shim first on PATH
PATH="$SHIM_DIR:$PATH" bash hypatia_build.sh "$@"
BUILD_EXIT=$?

# Clean up shim
rm -rf "$SHIM_DIR"

exit $BUILD_EXIT
