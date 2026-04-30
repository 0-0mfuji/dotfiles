#!/bin/bash

cd $(dirname "$0")
DICT_DIR="dict"
CUSTOM_DICT="$DICT_DIR/custom_medical_dict.txt"
GOOGLE_OUT="$DICT_DIR/google_ime_medical.txt"
MACOS_OUT="$DICT_DIR/macos_ime_medical.plist"
MS_OUT="$DICT_DIR/ms_ime_medical.txt"

main() {
    echo "Starting Medical Dictionary Setup..."
    
    # OS Check
    if [ "$(uname)" = "Darwin" ]; then
        macos
    elif [ "$(uname)" = "Linux" ]; then
        linux
    elif [[ "$(uname)" == MINGW* ]] || [[ "$(uname)" == MSYS* ]] || [[ "$(uname)" == CYGWIN* ]]; then
        windows
    fi

    generate_dicts
    
    echo "Setup complete."
    if [ "$(uname)" = "Darwin" ]; then
        open_import_guis_macos
    elif [[ "$(uname)" == MINGW* ]] || [[ "$(uname)" == MSYS* ]] || [[ "$(uname)" == CYGWIN* ]]; then
        open_import_guis_windows
    fi
}

generate_dicts() {
    echo "Merging and generating dictionaries..."
    
    # Ensure dict directory exists
    mkdir -p "$DICT_DIR"

    # Temporary files
    TMP_MERGED=$(mktemp)
    TMP_PYTHON_SCRIPT=$(mktemp).py
    
    # 1. Load custom dictionary (Skip comments and empty lines)
    if [ -f "$CUSTOM_DICT" ]; then
        echo "Loading custom dictionary: $CUSTOM_DICT"
        grep -v '^#' "$CUSTOM_DICT" | tr -d '\r' | awk -F'\t' 'NF>=2 {print $1 "\t" $2}' >> "$TMP_MERGED"
    fi
    
    # 2. Load DMiME-1.1 (if exists in subdirectories)
    DMIME_FILE=$(find "$DICT_DIR" -name "DMiME-1.1.txt" | head -n 1)
    if [ -n "$DMIME_FILE" ]; then
        echo "Found DMiME: $DMIME_FILE"
        grep -v '^#' "$DMIME_FILE" | tr -d '\r' | awk -F'\t' 'NF>=2 {print $1 "\t" $2}' >> "$TMP_MERGED"
    fi

    # 3. Load MANBYO Dictionary (.xlsx) using Vanilla Python
    MANBYO_XLSX=$(find "$DICT_DIR" -name "MANBYO_*.xlsx" | head -n 1)
    if [ -n "$MANBYO_XLSX" ]; then
        echo "Found MANBYO XLSX: $MANBYO_XLSX"
        echo "Parsing XLSX with Vanilla Python..."
        
        cat << 'EOF' > "$TMP_PYTHON_SCRIPT"
import zipfile
import xml.etree.ElementTree as ET
import sys

def parse_xlsx(xlsx_path):
    try:
        with zipfile.ZipFile(xlsx_path, 'r') as z:
            shared_strings = []
            if 'xl/sharedStrings.xml' in z.namelist():
                root = ET.fromstring(z.read('xl/sharedStrings.xml'))
                for si in root.findall('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}si'):
                    text_parts = []
                    for t in si.iter('{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t'):
                        if t.text: text_parts.append(t.text)
                    shared_strings.append("".join(text_parts))
            
            root = ET.fromstring(z.read('xl/worksheets/sheet1.xml'))
            ns = {'ns': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
            
            for row in root.findall('.//ns:row', ns):
                cols = {}
                for cell in row.findall('ns:c', ns):
                    r_attr = cell.get('r')
                    if not r_attr: continue
                    col_letter = "".join([c for c in r_attr if c.isalpha()])
                    t_attr = cell.get('t')
                    v_elem = cell.find('ns:v', ns)
                    val = ""
                    if v_elem is not None and v_elem.text:
                        if t_attr == 's':
                            idx = int(v_elem.text)
                            val = shared_strings[idx] if idx < len(shared_strings) else ""
                        else:
                            val = v_elem.text
                    cols[col_letter] = val
                
                if 'A' in cols and 'E' in cols:
                    word, composite = cols['A'], cols['E']
                    if composite and ';' in composite:
                        yomi = composite.split(';')[0]
                        # Filter out headers, empty values, and 'nan' junk
                        if yomi and word and yomi != "しゅつげんけい" and yomi.lower() != "nan" and word.lower() != "nan":
                            print(f"{yomi}\t{word}")
    except Exception as e:
        print(f"Error parsing XLSX: {e}", file=sys.stderr)

if __name__ == "__main__":
    parse_xlsx(sys.argv[1])
EOF
        python3 "$TMP_PYTHON_SCRIPT" "$MANBYO_XLSX" >> "$TMP_MERGED"
    fi

    if [ ! -s "$TMP_MERGED" ]; then
        echo "No dictionary entries found."
        rm "$TMP_MERGED" "$TMP_PYTHON_SCRIPT" 2>/dev/null
        return
    fi

    # 4. Duplicate Check
    echo "Checking for duplicates..."
    TMP_DUPS=$(mktemp)
    LC_ALL=C sort "$TMP_MERGED" | uniq -d > "$TMP_DUPS"
    if [ -s "$TMP_DUPS" ]; then
        echo "--------------------------------------------------"
        echo "NOTICE: Duplicate entries found (will be merged):"
        cat "$TMP_DUPS"
        echo "--------------------------------------------------"
    else
        echo "No duplicates found."
    fi

    # 5. Generate Google Japanese Input (TSV) - Unique sort
    # Adding POS "名詞" (Noun) for better compatibility with Google IME
    LC_ALL=C sort -u "$TMP_MERGED" | awk -F'\t' '{print $1 "\t" $2 "\t名詞"}' > "$GOOGLE_OUT"
    echo "Generated: $GOOGLE_OUT"

    # 6. Generate macOS Standard IME (.plist)
    echo "Generating: $MACOS_OUT"
    cat << 'EOF' > "$TMP_PYTHON_SCRIPT"
import sys
import xml.sax.saxutils as saxutils

in_file = sys.argv[1]
out_file = sys.argv[2]

with open(out_file, 'w', encoding='utf-8') as f_out:
    f_out.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    f_out.write('<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n')
    f_out.write('<plist version="1.0">\n')
    f_out.write('<array>\n')
    
    with open(in_file, 'r', encoding='utf-8', errors='ignore') as f_in:
        for line in f_in:
            parts = line.strip('\n').split('\t')
            if len(parts) >= 2:
                # Remove control characters and escape for XML
                yomi = "".join(ch for ch in parts[0] if ord(ch) >= 32)
                word = "".join(ch for ch in parts[1] if ord(ch) >= 32)
                
                yomi_esc = saxutils.escape(yomi, {'"': "&quot;", "'": "&apos;"})
                word_esc = saxutils.escape(word, {'"': "&quot;", "'": "&apos;"})
                
                f_out.write('    <dict>\n')
                f_out.write('        <key>phrase</key>\n')
                f_out.write(f'        <string>{word_esc}</string>\n')
                f_out.write('        <key>shortcut</key>\n')
                f_out.write(f'        <string>{yomi_esc}</string>\n')
                f_out.write('    </dict>\n')
    
    f_out.write('</array></plist>\n')
EOF
    python3 "$TMP_PYTHON_SCRIPT" "$GOOGLE_OUT" "$MACOS_OUT"

    # 7. Generate Microsoft IME (UTF-16 LE with BOM)
    echo "Generating: $MS_OUT"
    cat << 'EOF' > "$TMP_PYTHON_SCRIPT"
import sys

in_file = sys.argv[1]
out_file = sys.argv[2]

# Microsoft IME requires UTF-16 LE with BOM and CRLF
with open(in_file, 'r', encoding='utf-8') as f_in:
    content = f_in.read()
    with open(out_file, 'w', encoding='utf-16', newline='\r\n') as f_out:
        f_out.write(content)
EOF
    python3 "$TMP_PYTHON_SCRIPT" "$GOOGLE_OUT" "$MS_OUT"

    rm "$TMP_MERGED" "$TMP_PYTHON_SCRIPT" "$TMP_DUPS" 2>/dev/null
}

macos() {
    echo "Running on macOS..."
}

linux() {
    echo "Running on Linux..."
}

windows() {
    echo "Running on Windows..."
}

open_import_guis_macos() {
    echo ""
    echo "--------------------------------------------------"
    echo "Opening Dictionary Tools (macOS)..."
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

open_import_guis_windows() {
    echo ""
    echo "--------------------------------------------------"
    echo "Opening Dictionary Folder (Windows)..."
    echo "Please import the generated files manually:"
    echo "1. Google Japanese Input: Import '$GOOGLE_OUT'"
    echo "2. Microsoft IME: Import '$MS_OUT'"
    echo "   (User Dictionary Tool -> Tools -> Register from Text File)"
    echo "--------------------------------------------------"
    echo ""

    # Open the dictionary directory in Explorer
    if command -v explorer.exe >/dev/null; then
        echo "Opening directory '$DICT_DIR' in Explorer..."
        explorer.exe "$(cygpath -w "$DICT_DIR" 2>/dev/null || echo "$DICT_DIR")"
    fi
}

main
