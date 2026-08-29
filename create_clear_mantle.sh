#!/bin/bash

SRC="$(cd "$(dirname "$0")" && pwd)"
DST="$SRC/mantle-clear"

if [ ! -f "$SRC/LICENSE" ]; then
    echo "[ERROR] Source repo not found at \"$SRC\""
    exit 1
fi

if [ -d "$DST" ]; then
    echo "Deleting old \"$DST\"..."
    rm -rf "$DST"
fi

echo "Creating \"$DST\"..."
mkdir -p "$DST"

echo "Copying LICENSE..."
cp "$SRC/LICENSE" "$DST/LICENSE"

echo "Copying README.md..."
if [ -f "$SRC/README.md" ]; then
    cp "$SRC/README.md" "$DST/README.md"
fi

echo "Copying sound..."
if [ -d "$SRC/sound" ]; then
    cp -r "$SRC/sound" "$DST/"
fi

echo "Copying materials..."
if [ -d "$SRC/materials" ]; then
    cp -r "$SRC/materials" "$DST/"
fi

echo "Copying lua..."
if [ -d "$SRC/lua" ]; then
    cp -r "$SRC/lua" "$DST/"
fi

echo
echo "Done. Clean mantle created at \"$DST\"."
echo
