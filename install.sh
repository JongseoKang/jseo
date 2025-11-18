# assumption: /triton and /jseo in the same directory
#!/bin/bash
TRITON_DIR=$(dirname "$(readlink -f "$0")")/triton
JSEO_DIR=$(dirname "$(readlink -f "$0")")/jseo

# copy jseo/extra/jseo/ to triton/python/triton/language/extra/jseo/
mkdir -p "$TRITON_DIR/python/triton/language/extra"
cp -r "$JSEO_DIR/extra/jseo" "$TRITON_DIR/python/triton/language/extra/"

echo "JSEO has been installed to Triton successfully."
