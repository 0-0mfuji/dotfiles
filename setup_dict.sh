#!/bin/bash
# setup_dict.sh - Medical Dictionary Setup Script

cd $(dirname "$0")
DICT_DIR="dict"
CUSTOM_DICT="$DICT_DIR/custom_medical_dict.txt"
GOOGLE_OUT="$DICT_DIR/google_ime_medical.txt"
MACOS_OUT="$DICT_DIR/macos_ime_medical.plist"

main() {
    echo "Starting Medical Dictionary Setup..."
    
    # OS Check
    if [ "$(uname)" = "Darwin" ]; then
        macos
    elif [ "$(uname)" = "Linux" ]; then
        linux
    fi

    generate_dicts
    
    echo "Setup complete."
    if [ "$(uname)" = "Darwin" ]; then
        open_import_guis
    fi
}

generate_dicts() {
    echo "Merging and generating dictionaries..."
    
    # Ensure dict directory exists
    mkdir -p "$DICT_DIR"

    # Temporary merge file
    TMP_MERGED=$(mktemp)
    
    # 1. Load custom dictionary (Skip comments and empty lines)
    if [ -f "$CUSTOM_DICT" ]; then
        grep -v '^#' "$CUSTOM_DICT" | grep '[^\s]' >> "$TMP_MERGED"
    fi
    
    # 2. Load any other .txt files in dict/ (e.g., DMiME-1.1.txt)
    # Using nullglob to avoid errors if no .txt files exist
    shopt -s nullglob
    for f in "$DICT_DIR"/*.txt; do
        filename=$(basename "$f")
        if [ "$filename" != "custom_medical_dict.txt" ] && [ "$filename" != "$(basename "$GOOGLE_OUT")" ]; then
            echo "Found additional dictionary: $f"
            grep -v '^#' "$f" | grep '[^\s]' >> "$TMP_MERGED"
        fi
    done
    shopt -u nullglob

    if [ ! -s "$TMP_MERGED" ]; then
        echo "No dictionary entries found."
        echo "Please add words to $CUSTOM_DICT or place DMiME-1.1.txt in $DICT_DIR/"
        rm "$TMP_MERGED"
        return
    fi

    # 3. Generate Google Japanese Input (TSV) - Unique sort
    sort -u "$TMP_MERGED" > "$GOOGLE_OUT"
    echo "Generated: $GOOGLE_OUT"

    # 4. Generate macOS Standard IME (.plist)
    echo "Generating: $MACOS_OUT"
    cat <<EOF > "$MACOS_OUT"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
EOF

    awk -F'\t' '{
        reading=$1; word=$2;
        # Simple XML escaping for common characters
        gsub(/&/, "\&amp;", reading); gsub(/</, "\&lt;", reading); gsub(/>/, "\&gt;", reading);
        gsub(/&/, "\&amp;", word); gsub(/</, "\&lt;", word); gsub(/>/, "\&gt;", word);
        gsub(/"/, "\&quot;", word);
        printf "    <dict>\n        <key>phrase</key>\n        <string>%s</string>\n        <key>shortcut</key>\n        <string>%s</string>\n    </dict>\n", word, reading;
    }' "$GOOGLE_OUT" >> "$MACOS_OUT"

    echo "</array></plist>" >> "$MACOS_OUT"

    rm "$TMP_MERGED"
}

macos() {
    echo "Running on macOS..."
}

linux() {
    echo "Running on Linux..."
}

open_import_guis() {
    echo ""
    echo "--------------------------------------------------"
    echo "Opening Dictionary Tools..."
    echo "Please import the generated files manually:"
    echo "1. Google Japanese Input: Drag & Drop '$GOOGLE_OUT'"
    echo "2. macOS Standard IME: Drag & Drop '$MACOS_OUT' into the Text Replacements list"
    echo "--------------------------------------------------"
    echo ""

    # Open Google Japanese Input Dictionary Tool
    DICT_TOOL="/Library/Input Methods/GoogleJapaneseInput.app/Contents/Resources/GoogleJapaneseInputDictionaryTool.app"
    if [ -d "$DICT_TOOL" ]; then
        echo "Opening Google Japanese Input Dictionary Tool..."
        open -a "$DICT_TOOL"
    fi
    
    # Open the dictionary directory in Finder
    echo "Opening directory '$DICT_DIR' in Finder..."
    open "$DICT_DIR"
    
    # Open macOS Text Replacements settings
    echo "Opening macOS System Settings (Text Replacements)..."
    open "x-apple.systempreferences:com.apple.Keyboard-Settings.extension?TextReplacements"
}

main
