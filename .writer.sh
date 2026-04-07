#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Writer Tool v4.0 - GOD MODE Edition
#  Editor + Notes + Templates + Text Utils + Projects
#  + Git + Clipboard + AI + Markdown + Archives + Search
#  + Data + Password + Logs + Encrypt + HTTP + SQLite
#  + Cron + Backup + Env + SSH + Docker + Docs + Bench
# ═══════════════════════════════════════════════════════

NOTES_DIR="$HOME/notes"
SNIPPETS_DIR="$HOME/.writer_snippets"
SECRETS_DIR="$HOME/.writer_secrets"
BACKUP_DIR="$HOME/.writer_backups"
mkdir -p "$NOTES_DIR" "$SNIPPETS_DIR" "$SECRETS_DIR" "$BACKUP_DIR"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m'
BOLD='\033[1m'; RESET='\033[0m'

usage() {
    cat << 'EOFUSAGE'

  ╔══════════════════════════════════════════════════════╗
  ║         ✍️  WRITER TOOL v4.0  GOD MODE               ║
  ╚══════════════════════════════════════════════════════╝

  Usage: writer <command> [options]

  📝 Editoren         📋 Notizen          ⚡ Templates (25+)
  edit | vim          note | list | read   template <typ> [name]
                      del | search | export| py bash js ts html css
                      import               md c cpp java go rs
                                           php rb react vue api
  🏗️  Projekte (10+)   📄 Datei-Manager     docker make gitignore
  project <typ>       write | append       env func class
  python|node|web     copy | rename | del
  go|rust|c|flask     tree | diff | stat   🔄 Batch
  fastapi|cli|lib     touch                batch-rename | batch-chmod

  🔧 Text-Utils       📝 Markdown         🤖 AI Assistant
  wc | replace        md-toc | md-links   ai-write | ai-improve
  regex | upper/lower md-check | md-html  ai-explain | ai-summarize
  title | trim/dedup  md-stats            ai-complete
  preview | head/tail

  🔍 Search           📦 Snippets         🗜️  Archive
  find-name           snippet save/load   archive-create
  find-content        snippet list/del    archive-extract | list
  find-type | find-recent

  🔀 Git              📋 Clipboard        🔐 Passwords
  git-init | status   clipboard-copy      passwd-gen [length]
  git-add | commit    clipboard-paste     passwd-list
  git-log | branch    passwd-show | del

  📊 Data Format      📋 Log Analyzer     🔒 Encryption
  data-json2yaml      log-analyze <file>  encrypt <file> [key]
  data-yaml2json      log-errors <file>  decrypt <file> [key]
  data-json2csv       log-stats <file>
  data-csv2json
  data-xml2json       🌐 HTTP/API        🗄️  SQLite
  data-yaml2toml      http-get <url>      db-create <file>
  data-toml2yaml      http-post <url> <j> db-query <db> <sql>
  data-pretty <type>  http-api <url>      db-tables <db>
                      http-status <url>   db-dump <db>

  ⏰ Cron Manager     💾 Backup           🔧 Environment
  cron-add <cmd>      backup-create <dir> env-set <k> <v>
  cron-list           backup-restore      env-get <key>
  cron-del <nr>       backup-list         env-list | env-del

  🔑 SSH Manager      🐳 Docker Helper   📚 Doc Generator
  ssh-keygen          docker-status       docs-gen <file>
  ssh-add <host>      docker-logs <cont>  docs-python <dir>
  ssh-list            docker-ps

  📡 Network          ⚡ Benchmark        🎨 Color Themes
  net-scan [range]    bench-cpu           theme-set <name>
  net-port <port>     bench-disk          theme-list
  net-speed           bench-mem

  help                Alle Befehle       version
EOFUSAGE
}

# ═══════════════════════════════════════════════════════
# EDITOR
# ═══════════════════════════════════════════════════════
edit_file() { [ -z "$1" ] && { echo "Usage: writer edit <file>"; return 1; }; mkdir -p "$(dirname "$1")" 2>/dev/null; nano "$1"; }
vim_file() { [ -z "$1" ] && { echo "Usage: writer vim <file>"; return 1; }; mkdir -p "$(dirname "$1")" 2>/dev/null; vim "$1"; }

# ═══════════════════════════════════════════════════════
# NOTES
# ═══════════════════════════════════════════════════════
create_note() {
    local title="${1:-note_$(date +%Y%m%d_%H%M%S)}"
    local ts=$(date +%Y%m%d_%H%M%S)
    local filename="$NOTES_DIR/${ts}_${title// /_}.md"
    echo -e "${CYAN}Neue Notiz: ${BOLD}${title}${RESET} (Ctrl+D speichern)"
    { echo "# ${title}"; echo ""; echo "Erstellt: $(date)"; echo ""; cat; } > "$filename"
    echo -e "${GREEN}Gespeichert: $filename ($(wc -w < "$filename") Woerter)${RESET}"
}

list_notes() {
    echo -e "${CYAN}Notizen:${RESET}"
    local count=0
    find "$NOTES_DIR" -maxdepth 1 -type f \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | sort | while IFS= read -r f; do
        count=$((count + 1))
        echo -e "  ${GREEN}[$count]${RESET} ${YELLOW}$(basename "$f")${RESET} ($(du -h "$f"|cut -f1))"
    done
}

read_note() {
    [ -z "$1" ] && { echo "Usage: writer read <nr>"; return 1; }
    local files=$(find "$NOTES_DIR" -maxdepth 1 -type f \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | sort)
    local target=$(echo "$files" | sed -n "${1}p")
    [ -n "$target" ] && less -R "$target" || echo -e "${RED}Nicht gefunden.${RESET}"
}

delete_note() {
    [ -z "$1" ] && { echo "Usage: writer del <nr>"; return 1; }
    local files=$(find "$NOTES_DIR" -maxdepth 1 -type f \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | sort)
    local target=$(echo "$files" | sed -n "${1}p")
    [ -n "$target" ] && rm -iv "$target"
}

search_notes() {
    [ -z "$1" ] && { echo "Usage: writer search <text>"; return 1; }
    grep -rl "$1" "$NOTES_DIR" 2>/dev/null | while IFS= read -r f; do
        echo -e "${GREEN}$(basename "$f")${RESET}"
        grep -n "$1" "$f" | head -3
    done
}

export_note() {
    [ -z "$1" ] && { echo "Usage: writer export <nr>"; return 1; }
    local files=$(find "$NOTES_DIR" -maxdepth 1 -type f \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | sort)
    local target=$(echo "$files" | sed -n "${1}p")
    [ -n "$target" ] && { cp "$target" "$HOME/note_export_$(date +%s).md"; echo -e "${GREEN}Exportiert.${RESET}"; }
}

import_note() {
    [ -z "$1" ] && { echo "Usage: writer import <file>"; return 1; }
    [ -f "$1" ] && { cp "$1" "$NOTES_DIR/"; echo -e "${GREEN}Importiert: $(basename "$1")${RESET}"; }
}

# ═══════════════════════════════════════════════════════
# TEMPLATES
# ═══════════════════════════════════════════════════════
generate_template() {
    local type="$1" name="${2:-my_$(date +%s)}" outfile=""
    case "$type" in
        py|python) outfile="${name}.py"; printf '#!/usr/bin/env python3\n"""\nDescription: \nAuthor: \nDate: \n"""\n\nimport sys\n\n\ndef main():\n    print("Hello, World!")\n    return 0\n\n\nif __name__ == "__main__":\n    sys.exit(main())\n' > "$outfile" ;;
        bash|sh) outfile="${name}.sh"; printf '#!/bin/bash\nset -euo pipefail\n\nmain() {\n    echo "Hello, World!"\n}\n\nmain "$@"\n' > "$outfile"; chmod +x "$outfile" ;;
        js|javascript|node) outfile="${name}.js"; printf 'const main = async () => {\n    console.log("Hello, World!");\n};\n\nmain().catch(console.error);\n' > "$outfile" ;;
        ts|typescript) outfile="${name}.ts"; printf 'const main = async (): Promise<void> => {\n    console.log("Hello, World!");\n};\n\nmain().catch(console.error);\n' > "$outfile" ;;
        html|web) outfile="${name}.html"; printf '<!DOCTYPE html>\n<html lang="de">\n<head>\n    <meta charset="UTF-8">\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n    <title>%s</title>\n</head>\n<body>\n    <h1>Hello, World!</h1>\n</body>\n</html>\n' "$name" > "$outfile" ;;
        css) outfile="${name}.css"; printf ':root { --primary: #3b82f6; --bg: #f8fafc; }\n* { margin: 0; padding: 0; box-sizing: border-box; }\nbody { font-family: system-ui, sans-serif; background: var(--bg); }\n' > "$outfile" ;;
        md|markdown|doc) outfile="${name}.md"; printf '# %s\n\n> Beschreibung\n\n## Inhalt\n\n...\n' "$name" > "$outfile" ;;
        c) outfile="${name}.c"; printf '#include <stdio.h>\n\nint main() {\n    printf("Hello!\\n");\n    return 0;\n}\n' > "$outfile" ;;
        cpp) outfile="${name}.cpp"; printf '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Hello!" << endl;\n    return 0;\n}\n' > "$outfile" ;;
        java) outfile="${name}.java"; printf 'public class %s {\n    public static void main(String[] args) {\n        System.out.println("Hello!");\n    }\n}\n' "$name" > "$outfile" ;;
        go|golang) outfile="${name}.go"; printf 'package main\n\nimport "fmt"\n\nfunc main() {\n    fmt.Println("Hello!")\n}\n' > "$outfile" ;;
        rs|rust) outfile="${name}.rs"; printf 'fn main() {\n    println!("Hello!");\n}\n' > "$outfile" ;;
        php) outfile="${name}.php"; printf '<?php\n\necho "Hello!" . PHP_EOL;\n' > "$outfile" ;;
        rb|ruby) outfile="${name}.rb"; printf '#!/usr/bin/env ruby\nputs "Hello!"\n' > "$outfile" ;;
        react) outfile="${name}.jsx"; printf 'import React, { useState } from "react";\n\nexport default function %s() {\n    return <div>%s</div>;\n}\n' "$name" "$name" > "$outfile" ;;
        vue) outfile="${name}.vue"; printf '<template>\n  <div><h1>{{ title }}</h1></div>\n</template>\n\n<script>\nexport default { data() { return { title: "%s" }; } };\n</script>\n' "$name" > "$outfile" ;;
        api) outfile="api_${name}.py"; printf 'from fastapi import FastAPI\n\napp = FastAPI()\n\n@app.get("/")\nasync def root():\n    return {"message": "Hello!"}\n' > "$outfile" ;;
        docker) outfile="Dockerfile"; printf 'FROM python:3.12-slim\nWORKDIR /app\nCOPY . .\nCMD ["python", "main.py"]\n' > "$outfile" ;;
        dockercompose|compose) outfile="docker-compose.yml"; printf 'version: "3.8"\nservices:\n  app:\n    build: .\n    ports:\n      - "8000:8000"\n' > "$outfile" ;;
        make) outfile="Makefile"; printf '.PHONY: all clean\n\nall:\n\t@echo "Building..."\n\nclean:\n\t@echo "Cleaning..."\n' > "$outfile" ;;
        gitignore) outfile=".gitignore"; printf 'node_modules/\n__pycache__/\n*.pyc\n.env\ndist/\nbuild/\n.DS_Store\n' > "$outfile" ;;
        env) outfile=".env"; printf 'APP_NAME=%s\nAPP_ENV=development\nAPP_PORT=8000\nDB_HOST=localhost\n' "$name" > "$outfile" ;;
        func) outfile="${name}.py"; printf 'def %s(param: str) -> str:\n    """Beschreibung."""\n    return param\n\n\nif __name__ == "__main__":\n    print(%s("test"))\n' "$name" "$name" > "$outfile" ;;
        class) outfile="${name}.py"; printf 'class %s:\n    def __init__(self, name: str):\n        self.name = name\n\n    def __str__(self):\n        return f"%s({self.name})"\n' "$name" "$name" > "$outfile" ;;
        *) echo -e "${RED}Typ: ${type} unbekannt${RESET}"; return 1 ;;
    esac
    echo -e "${GREEN}Erstellt: ${BOLD}$outfile${RESET}"
}

# ═══════════════════════════════════════════════════════
# PROJECTS
# ═══════════════════════════════════════════════════════
create_project() {
    local type="$1" name="${2:-my_project}"
    mkdir -p "$name" && cd "$name" || return 1
    case "$type" in
        python)
            mkdir -p "$name" tests
            touch "$name/__init__.py"
            printf '[project]\nname = "%s"\nversion = "0.1.0"\n' "$name" > pyproject.toml
            printf 'import sys\n\ndef main():\n    print("Hello!")\n    return 0\n\nif __name__ == "__main__":\n    sys.exit(main())\n' > main.py
            printf 'def test_main():\n    assert True\n' > tests/test_main.py
            printf 'pytest\n' > requirements.txt
            printf '# %s\n\npip install -r requirements.txt\npython main.py\n' "$name" > README.md
            printf '__pycache__/\n*.pyc\n.venv/\n' > .gitignore
            ;;
        node|npm)
            mkdir -p src tests
            printf '{\n  "name": "%s",\n  "version": "1.0.0",\n  "main": "src/index.js",\n  "scripts": {\n    "start": "node src/index.js",\n    "test": "echo ok"\n  }\n}\n' "$name" > package.json
            printf 'console.log("Hello!");\n' > src/index.js
            ;;
        web)
            mkdir -p css js
            printf '<!DOCTYPE html>\n<html><head><meta charset="UTF-8"><title>%s</title><link rel="stylesheet" href="css/style.css"></head>\n<body><h1>%s</h1><script src="js/app.js"></script></body></html>\n' "$name" "$name" > index.html
            printf 'body { font-family: system-ui; max-width: 800px; margin: 2rem auto; }\n' > css/style.css
            printf 'console.log("Loaded");\n' > js/app.js
            ;;
        go)
            printf 'module %s\n\ngo 1.22\n' "$name" > go.mod
            printf 'package main\n\nimport "fmt"\n\nfunc main() {\n    fmt.Println("Hello!")\n}\n' > main.go
            ;;
        rust)
            mkdir -p src
            printf '[package]\nname = "%s"\nversion = "0.1.0"\nedition = "2021"\n' "$name" > Cargo.toml
            printf 'fn main() {\n    println!("Hello!");\n}\n' > src/main.rs
            ;;
        c)
            mkdir -p src
            printf '#include <stdio.h>\nint main() { printf("Hello!\\n"); return 0; }\n' > src/main.c
            printf 'CC=gcc\nCFLAGS=-Wall\n\nall:\n\t$(CC) $(CFLAGS) src/main.c -o %s\n' "$name" > Makefile
            ;;
        flask)
            mkdir -p "$name" templates static
            touch "$name/__init__.py"
            printf 'from flask import Flask\napp = Flask(__name__)\n\n@app.route("/")\ndef index():\n    return "Hello!"\n\nif __name__ == "__main__":\n    app.run(debug=True)\n' > app.py
            printf 'Flask\n' > requirements.txt
            ;;
        fastapi)
            mkdir -p "$name"
            touch "$name/__init__.py"
            printf 'from fastapi import FastAPI\napp = FastAPI()\n\n@app.get("/")\nasync def root():\n    return {"message": "Hello!"}\n' > main.py
            printf 'fastapi\nuvicorn\n' > requirements.txt
            ;;
        cli)
            mkdir -p src commands
            printf '#!/usr/bin/env python3\nimport argparse\n\ndef main():\n    parser = argparse.ArgumentParser(description="%s")\n    parser.add_argument("command", help="Command to run")\n    args = parser.parse_args()\n    print(f"Running: {args.command}")\n\nif __name__ == "__main__":\n    main()\n' "$name" > main.py
            chmod +x main.py
            printf 'click\n' > requirements.txt
            ;;
        lib)
            mkdir -p src tests
            touch src/__init__.py
            printf '[project]\nname = "%s"\nversion = "0.1.0"\ndescription = "A Python library"\n' "$name" > pyproject.toml
            printf '# %s\n\n## Install\npip install .\n\n## Usage\nimport %s\n' "$name" "$name" > README.md
            ;;
        *) echo -e "${RED}Typ: ${type} unbekannt${RESET}"; return 1 ;;
    esac
    echo -e "${GREEN}Projekt erstellt: ${BOLD}$PWD${RESET}"
    ls -1
}

# ═══════════════════════════════════════════════════════
# FILE MANAGER
# ═══════════════════════════════════════════════════════
write_file_interactive() {
    [ -z "$1" ] && { echo "Usage: writer write <file>"; return 1; }
    mkdir -p "$(dirname "$1")" 2>/dev/null
    echo -e "${YELLOW}Text eingeben (Ctrl+D):${RESET}"
    cat > "$1"; echo -e "${GREEN}Gespeichert: $1${RESET}"
}

append_file() {
    [ -z "$1" ] && { echo "Usage: writer append <file>"; return 1; }
    [ ! -f "$1" ] && { echo "Nicht gefunden."; return 1; }
    echo -e "${YELLOW}Text (Ctrl+D):${RESET}"; cat >> "$1"; echo -e "${GREEN}Angehaengt.${RESET}"
}

copy_file() { [ -z "$1" ] || [ -z "$2" ] && { echo "Usage: writer copy <src> <dst>"; return 1; }; cp -v "$1" "$2"; }
rename_file() { [ -z "$1" ] || [ -z "$2" ] && { echo "Usage: writer rename <old> <new>"; return 1; }; mv -v "$1" "$2"; }
delete_file() { [ -z "$1" ] && { echo "Usage: writer delete <file>"; return 1; }; rm -iv "$1"; }

show_tree() {
    local dir="${1:-.}"
    echo -e "${CYAN}📂 $dir${RESET}"
    if command -v tree &>/dev/null; then
        tree -a -C -L 3 --dirsfirst "$dir" 2>/dev/null
    else
        find "$dir" -maxdepth 3 2>/dev/null | sort | while IFS= read -r f; do
            local base=$(basename "$f")
            [ -d "$f" ] && echo -e "${BLUE}[DIR]  $base/${RESET}" || echo "       $base"
        done
    fi
}

diff_files() { [ -z "$1" ] || [ -z "$2" ] && { echo "Usage: writer diff <a> <b>"; return 1; }; diff --color=auto -u "$1" "$2" 2>/dev/null || true; }

file_stat() {
    [ -z "$1" ] && { echo "Usage: writer stat <file>"; return 1; }
    [ ! -e "$1" ] && { echo "Nicht gefunden."; return 1; }
    stat "$1" 2>/dev/null
    echo "Zeilen: $(wc -l < "$1") | Woerter: $(wc -w < "$1") | Bytes: $(wc -c < "$1")"
}

touch_file() { [ -z "$1" ] && { echo "Usage: writer touch <file>"; return 1; }; mkdir -p "$(dirname "$1")" 2>/dev/null; touch "$1"; echo -e "${GREEN}Erstellt: $1${RESET}"; }

# ═══════════════════════════════════════════════════════
# TEXT UTILS
# ═══════════════════════════════════════════════════════
text_wc() {
    [ -z "$1" ] || [ ! -f "$1" ] && { echo "Usage: writer wc <file>"; return 1; }
    echo -e "${CYAN}Statistik: $(basename "$1")${RESET}"
    echo "────────────────────────────────"
    echo "Zeilen:  $(wc -l < "$1")"
    echo "Woerter: $(wc -w < "$1")"
    echo "Zeichen: $(wc -c < "$1")"
    echo "Groesse: $(du -h "$1" | cut -f1)"
    echo ""
    echo "Top 10 Woerter:"
    tr -s '[:space:]' '\n' < "$1" | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -10 | while read cnt word; do
        printf "  %-20s %s\n" "$word" "$cnt"
    done
}

text_replace() {
    [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] && { echo "Usage: writer replace <file> <search> <replace>"; return 1; }
    local count=$(grep -c "$2" "$1" 2>/dev/null || echo 0)
    sed -i "s/${2}/${3}/g" "$1"
    echo -e "${GREEN}$count Ersetzungen${RESET}"
}

text_regex() {
    local file="$1" pattern="$2" replace="${3:-}"
    [ -z "$file" ] || [ -z "$pattern" ] && { echo "Usage: writer regex <file> <pattern> [replace]"; return 1; }
    [ ! -f "$file" ] && { echo "Nicht gefunden."; return 1; }
    if [ -n "$replace" ]; then
        local count
        count=$(grep -cP "$pattern" "$file" 2>/dev/null) || count=0
        perl -pi -e "s|${pattern}|${replace}|g" "$file" 2>/dev/null
        echo -e "${GREEN}$count Ersetzungen (regex)${RESET}"
    else
        grep -nP "$pattern" "$file" 2>/dev/null | head -20
    fi
}

text_upper() { [ -z "$1" ] && { echo "Usage: writer upper <file>"; return 1; }; tr '[:lower:]' '[:upper:]' < "$1" > "${1}.tmp" && mv "${1}.tmp" "$1"; echo "Konvertiert."; }
text_lower() { [ -z "$1" ] && { echo "Usage: writer lower <file>"; return 1; }; tr '[:upper:]' '[:lower:]' < "$1" > "${1}.tmp" && mv "${1}.tmp" "$1"; echo "Konvertiert."; }
text_title() { [ -z "$1" ] && { echo "Usage: writer title <file>"; return 1; }; sed 's/.*/\L&/; s/[a-z]*/\u&/g' "$1" > "${1}.tmp" && mv "${1}.tmp" "$1"; echo "Konvertiert."; }
text_trim() { [ -z "$1" ] && { echo "Usage: writer trim <file>"; return 1; }; sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$1" > "${1}.tmp" && mv "${1}.tmp" "$1"; echo "Trimmed."; }
text_dedup() { [ -z "$1" ] && { echo "Usage: writer dedup <file>"; return 1; }; sort -u "$1" > "${1}.tmp" && mv "${1}.tmp" "$1"; echo "Duplikate entfernt."; }
text_sort() { [ -z "$1" ] && { echo "Usage: writer sort <file>"; return 1; }; sort -f "$1" > "${1}.tmp" && mv "${1}.tmp" "$1"; echo "Sortiert."; }

text_preview() {
    [ -z "$1" ] || [ ! -f "$1" ] && { echo "Usage: writer preview <file>"; return 1; }
    if command -v bat &>/dev/null; then bat --paging=never "$1"
    elif command -v pygmentize &>/dev/null; then pygmentize -g "$1"
    else cat -n "$1" | head -50; fi
}

text_head() { [ -z "$1" ] && { echo "Usage: writer head <file>"; return 1; }; head -n 20 "$1" | cat -n; }
text_tail() { [ -z "$1" ] && { echo "Usage: writer tail <file>"; return 1; }; tail -n 20 "$1" | cat -n; }

# ═══════════════════════════════════════════════════════
# MARKDOWN UTILS
# ═══════════════════════════════════════════════════════
md_toc() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer md-toc <file>"; return 1; }
    echo -e "${CYAN}Inhaltsverzeichnis: $(basename "$file")${RESET}"
    echo "────────────────────────────────"
    grep -E '^#{1,6} ' "$file" 2>/dev/null | while IFS= read -r line; do
        local level=$(echo "$line" | grep -oE '^#{1,6}' | wc -c)
        level=$((level - 1))
        local title=$(echo "$line" | sed 's/^#* //')
        local indent=""
        for i in $(seq 1 $((level - 1))); do indent+="  "; done
        local slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
        echo -e "  ${indent}- [${title}](#${slug})"
    done
}

md_links() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer md-links <file>"; return 1; }
    echo -e "${CYAN}Links in $(basename "$file"):${RESET}"
    grep -oE '\[([^\]]+)\]\(([^)]+)\)' "$file" 2>/dev/null | while IFS= read -r link; do
        local text=$(echo "$link" | sed 's/\[\(.*\)\](.*/\1/')
        local url=$(echo "$link" | sed 's/.*](\(.*\))/\1/')
        echo -e "  ${GREEN}$text${RESET} -> ${YELLOW}$url${RESET}"
    done
}

md_check() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer md-check <file>"; return 1; }
    echo -e "${CYAN}Markdown Check: $(basename "$file")${RESET}"
    echo "────────────────────────────────"
    local headings links images code_blocks lists
    headings=$(grep -cE '^#{1,6} ' "$file" 2>/dev/null) || headings=0
    links=$(grep -cE '\[.+\]\(.+\)' "$file" 2>/dev/null) || links=0
    images=$(grep -cE '!\[.+\]\(.+\)' "$file" 2>/dev/null) || images=0
    code_blocks=$(grep -cF '```' "$file" 2>/dev/null) || code_blocks=0
    lists=$(grep -cE '^[[:space:]]*[-*] ' "$file" 2>/dev/null) || lists=0
    local code_block_count=$((code_blocks / 2))
    echo "  Ueberschriften: $headings"
    echo "  Links:          $links"
    echo "  Bilder:         $images"
    echo "  Code-Bloecke:   $code_block_count"
    echo "  Listen:         $lists"
    echo "  Zeilen:         $(wc -l < "$file")"
    # Check for broken local links
    grep -oE '\[([^\]]+)\]\(([^)#][^)]*)\)' "$file" 2>/dev/null | sed 's/.*](\(.*\))/\1/' | while IFS= read -r url; do
        case "$url" in
            http*|https*|mailto:*) ;; # external, skip
            *) [ ! -e "$url" ] && echo -e "  ${RED}⚠ Broken link: $url${RESET}" ;;
        esac
    done
}

md_to_html() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer md-html <file>"; return 1; }
    local outfile="${file%.md}.html"
    if command -v pandoc &>/dev/null; then
        pandoc "$file" -o "$outfile" && echo -e "${GREEN}Konvertiert: $outfile${RESET}"
    else
        # Simple conversion
        {
            echo '<!DOCTYPE html><html><head><meta charset="UTF-8"><style>'
            echo 'body { font-family: system-ui; max-width: 800px; margin: 2rem auto; line-height: 1.6; }'
            echo 'code { background: #f0f0f0; padding: 2px 6px; border-radius: 3px; }'
            echo 'pre { background: #f0f0f0; padding: 1rem; border-radius: 5px; overflow-x: auto; }'
            echo 'blockquote { border-left: 3px solid #3b82f6; padding-left: 1rem; color: #666; }'
            echo '</style></head><body>'
            sed -E 's/^# (.*)/<h1>\1<\/h1>/; s/^## (.*)/<h2>\1<\/h2>/; s/^### (.*)/<h3>\1<\/h3>/; s/^\*\*(.*)\*\*/<strong>\1<\/strong>/; s/^\*(.*)\*/<em>\1<\/em>/; s/^- (.*)/<li>\1<\/li>/; s/`([^`]+)`/<code>\1<\/code>/;' "$file"
            echo '</body></html>'
        } > "$outfile"
        echo -e "${GREEN}Konvertiert: $outfile${RESET}"
    fi
}

md_stats() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer md-stats <file>"; return 1; }
    echo -e "${CYAN}Markdown Stats: $(basename "$file")${RESET}"
    echo "────────────────────────────────"
    echo "  Zeilen:          $(wc -l < "$file")"
    echo "  Woerter:         $(wc -w < "$file")"
    echo "  Zeichen:         $(wc -c < "$file")"
    echo "  Ueberschriften:  $(grep -cE '^#{1,6} ' "$file" 2>/dev/null || echo 0)"
    echo "  Absaetze:        $(grep -cE '^[^#].+' "$file" 2>/dev/null || echo 0)"
    echo "  Code-Zeilen:     $(grep -cE '^```|^\s{4}' "$file" 2>/dev/null || echo 0)"
    echo "  Leere Zeilen:    $(grep -cE '^\s*$' "$file" 2>/dev/null || echo 0)"
}

# ═══════════════════════════════════════════════════════
# AI ASSISTANT
# ═══════════════════════════════════════════════════════
ai_write() {
    local prompt="$1" file="${2:-}"
    [ -z "$prompt" ] && { echo "Usage: writer ai-write <prompt> [file]"; return 1; }
    echo -e "${CYAN}🤖 AI schreibt...${RESET}"
    if command -v qwen &>/dev/null; then
        if [ -n "$file" ]; then
            qwen -p "$prompt" > "$file" 2>/dev/null
        else
            qwen -p "$prompt" 2>/dev/null
        fi
    elif command -v gemini &>/dev/null; then
        if [ -n "$file" ]; then
            gemini -p "$prompt" > "$file" 2>/dev/null
        else
            gemini -p "$prompt" 2>/dev/null
        fi
    else
        echo -e "${RED}Kein AI-Tool gefunden. Installiere qwen oder gemini.${RESET}"
        return 1
    fi
    [ -n "$file" ] && echo -e "${GREEN}Gespeichert: $file${RESET}"
}

ai_improve() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer ai-improve <file>"; return 1; }
    echo -e "${CYAN}🤖 Verbessere ${BOLD}$file${RESET}"
    local content=$(cat "$file")
    local prompt="Improve this code/text. Fix errors, optimize, add comments. Return only the improved version:\n\n${content}"
    if command -v qwen &>/dev/null; then
        qwen -p "$prompt" > "${file}.improved" 2>/dev/null && echo -e "${GREEN}Gespeichert: ${file}.improved${RESET}"
    elif command -v gemini &>/dev/null; then
        gemini -p "$prompt" > "${file}.improved" 2>/dev/null && echo -e "${GREEN}Gespeichert: ${file}.improved${RESET}"
    else
        echo -e "${RED}Kein AI-Tool gefunden.${RESET}"; return 1
    fi
}

ai_explain() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer ai-explain <file>"; return 1; }
    echo -e "${CYAN}🤖 Erklaere ${BOLD}$file${RESET}"
    local content=$(cat "$file")
    local prompt="Explain what this code/text does in simple terms:\n\n${content}"
    if command -v qwen &>/dev/null; then
        qwen -p "$prompt" 2>/dev/null
    elif command -v gemini &>/dev/null; then
        gemini -p "$prompt" 2>/dev/null
    else
        echo -e "${RED}Kein AI-Tool gefunden.${RESET}"; return 1
    fi
}

ai_summarize() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer ai-summarize <file>"; return 1; }
    echo -e "${CYAN}🤖 Zusammenfassung ${BOLD}$file${RESET}"
    local content=$(head -2000 "$file")
    local prompt="Summarize this text in 3-5 bullet points:\n\n${content}"
    if command -v qwen &>/dev/null; then
        qwen -p "$prompt" 2>/dev/null
    elif command -v gemini &>/dev/null; then
        gemini -p "$prompt" 2>/dev/null
    else
        echo -e "${RED}Kein AI-Tool gefunden.${RESET}"; return 1
    fi
}

ai_complete() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer ai-complete <file>"; return 1; }
    echo -e "${CYAN}🤐 Vervollstaendige ${BOLD}$file${RESET}"
    local content=$(cat "$file")
    local prompt="Complete this code/text. Continue from where it ends. Return only the completion:\n\n${content}"
    if command -v qwen &>/dev/null; then
        qwen -p "$prompt" >> "$file" 2>/dev/null && echo -e "${GREEN}Vervollstaendigt: $file${RESET}"
    elif command -v gemini &>/dev/null; then
        gemini -p "$prompt" >> "$file" 2>/dev/null && echo -e "${GREEN}Vervollstaendigt: $file${RESET}"
    else
        echo -e "${RED}Kein AI-Tool gefunden.${RESET}"; return 1
    fi
}

# ═══════════════════════════════════════════════════════
# ADVANCED SEARCH
# ═══════════════════════════════════════════════════════
find_name() {
    local pattern="$1" dir="${2:-.}"
    [ -z "$pattern" ] && { echo "Usage: writer find-name <pattern> [dir]"; return 1; }
    find "$dir" -iname "*${pattern}*" 2>/dev/null | head -30
}

find_content() {
    local text="$1" dir="${2:-.}"
    [ -z "$text" ] && { echo "Usage: writer find-content <text> [dir]"; return 1; }
    grep -rl "$text" "$dir" 2>/dev/null | head -30 | while IFS= read -r f; do
        echo -e "${GREEN}$f${RESET}"
        grep -n "$text" "$f" | head -2 | sed 's/^/    /'
    done
}

find_type() {
    local ext="$1" dir="${2:-.}"
    [ -z "$ext" ] && { echo "Usage: writer find-type <ext> [dir]"; return 1; }
    find "$dir" -name "*.${ext}" -type f 2>/dev/null | head -50
}

find_recent() {
    local count="${1:-10}"
    find . -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -n "$count" | while read ts file; do
        local date=$(date -d "@${ts%.*}" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "?")
        echo -e "  ${YELLOW}$date${RESET}  $file"
    done
}

# ═══════════════════════════════════════════════════════
# SNIPPETS
# ═══════════════════════════════════════════════════════
snippet_save() {
    [ -z "$1" ] && { echo "Usage: writer snippet save <name>"; return 1; }
    echo -e "${YELLOW}Snippet-Inhalt (Ctrl+D):${RESET}"
    cat > "$SNIPPETS_DIR/${1}.snip"
    echo -e "${GREEN}Snippet gespeichert: $1${RESET}"
}

snippet_load() {
    [ -z "$1" ] && { echo "Usage: writer snippet load <name>"; return 1; }
    local file="$SNIPPETS_DIR/${1}.snip"
    [ -f "$file" ] && cat "$file" || echo -e "${RED}Nicht gefunden.${RESET}"
}

snippet_list() {
    echo -e "${CYAN}Snippets:${RESET}"
    for f in "$SNIPPETS_DIR"/*.snip; do
        [ -f "$f" ] && echo -e "  ${GREEN}•${RESET} ${YELLOW}$(basename "$f" .snip)${RESET} ($(du -h "$f"|cut -f1))"
    done
}

snippet_delete() {
    [ -z "$1" ] && { echo "Usage: writer snippet delete <name>"; return 1; }
    rm -iv "$SNIPPETS_DIR/${1}.snip" && echo -e "${GREEN}Geloscht.${RESET}"
}

# ═══════════════════════════════════════════════════════
# ARCHIVE
# ═══════════════════════════════════════════════════════
archive_create() {
    [ -z "$1" ] || [ -z "$2" ] && { echo "Usage: writer archive-create <name.tar.gz> <files...>"; return 1; }
    local name="$1"; shift
    tar czf "$name" "$@" && echo -e "${GREEN}Archiv: $name${RESET}"
}

archive_extract() {
    [ -z "$1" ] && { echo "Usage: writer archive-extract <file> [dest]"; return 1; }
    local file="$1" dest="${2:-.}"
    case "$file" in
        *.tar.gz|*.tgz) tar xzf "$file" -C "$dest" ;;
        *.tar.bz2) tar xjf "$file" -C "$dest" ;;
        *.tar) tar xf "$file" -C "$dest" ;;
        *.zip) unzip "$file" -d "$dest" ;;
        *) echo "Unbekanntes Format."; return 1 ;;
    esac
    echo -e "${GREEN}Extrahiert nach $dest${RESET}"
}

archive_list() {
    [ -z "$1" ] && { echo "Usage: writer archive-list <file>"; return 1; }
    local file="$1"
    case "$file" in
        *.tar.gz|*.tgz) tar tzf "$file" ;;
        *.tar.bz2) tar tjf "$file" ;;
        *.tar) tar tf "$file" ;;
        *.zip) unzip -l "$file" ;;
        *) echo "Unbekanntes Format."; return 1 ;;
    esac
}

# ═══════════════════════════════════════════════════════
# GIT
# ═══════════════════════════════════════════════════════
git_init() { git init && echo -e "${GREEN}Repo initialisiert.${RESET}"; }
git_status() { git status --short; }
git_add() { git add "${1:-.}" && echo -e "${GREEN}Hinzugefuegt.${RESET}"; }
git_commit() {
    local msg="${1:-$(echo -n 'Nachricht: '; read m; echo $m)}"
    [ -z "$msg" ] && { echo "Keine Nachricht."; return 1; }
    git commit -m "$msg" && echo -e "${GREEN}Commited.${RESET}"
}
git_log() { git log --oneline -n "${1:-10}"; }
git_branch() {
    [ -z "$1" ] && { git branch -a; return; }
    git checkout -b "$1" && echo -e "${GREEN}Branch: $1${RESET}"
}
git_push() { git push "${1:-origin}" "${2:-main}"; }
git_pull() { git pull "${1:-origin}" "${2:-main}"; }
git_diff() { git diff --stat; }

# ═══════════════════════════════════════════════════════
# CLIPBOARD
# ═══════════════════════════════════════════════════════
clipboard_copy() {
    [ -z "$1" ] && { echo "Usage: writer clipboard-copy <file>"; return 1; }
    [ ! -f "$1" ] && { echo "Nicht gefunden."; return 1; }
    if command -v termux-clipboard-set &>/dev/null; then
        termux-clipboard-set < "$1" && echo -e "${GREEN}Kopiert: $1${RESET}"
    else
        cat "$1"
        echo -e "${YELLOW}termux-api nicht installiert.${RESET}"
    fi
}

clipboard_paste() {
    local file="${1:--}"
    if command -v termux-clipboard-get &>/dev/null; then
        if [ "$file" = "-" ]; then termux-clipboard-get
        else termux-clipboard-get > "$file" && echo -e "${GREEN}Eingefuegt: $file${RESET}"; fi
    else
        echo -e "${YELLOW}Text eingeben (Ctrl+D):${RESET}"
        if [ "$file" = "-" ]; then cat; else cat > "$file"; echo -e "${GREEN}Gespeichert: $file${RESET}"; fi
    fi
}

# ═══════════════════════════════════════════════════════
# BATCH
# ═══════════════════════════════════════════════════════
batch_rename() {
    local dir="$1" prefix="$2" ext="${3:-txt}"
    [ -z "$dir" ] || [ -z "$prefix" ] && { echo "Usage: writer batch-rename <dir> <prefix> [ext]"; return 1; }
    local i=0
    for f in "$dir"/*; do
        [ -f "$f" ] || continue
        i=$((i + 1))
        local new="$dir/${prefix}_$(printf '%03d' $i).${ext}"
        mv "$f" "$new" && echo "  $f -> $new"
    done
    echo -e "${GREEN}$i Dateien umbenannt.${RESET}"
}

batch_chmod() {
    [ -z "$1" ] && { echo "Usage: writer batch-chmod <mode> <files...>"; return 1; }
    local mode="$1"; shift
    chmod "$mode" "$@" && echo -e "${GREEN}Berechtigungen gesetzt.${RESET}"
}

# ═══════════════════════════════════════════════════════
# PASSWORDS
# ═══════════════════════════════════════════════════════
passwd_gen() {
    local len="${1:-32}"
    if command -v openssl &>/dev/null; then
        openssl rand -base64 "$len" 2>/dev/null | tr -d '\n' | head -c "$len"
    else
        tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' < /dev/urandom 2>/dev/null | head -c "$len"
    fi
    echo ""
}

passwd_save() {
    local name="$1"
    [ -z "$name" ] && { echo "Usage: writer passwd-save <name>"; return 1; }
    local pass=$(passwd_gen 32)
    echo "$pass" > "$SECRETS_DIR/${name}.pass"
    chmod 600 "$SECRETS_DIR/${name}.pass"
    echo -e "${GREEN}Passwort gespeichert: $name${RESET}"
    echo -e "${YELLOW}$pass${RESET}"
}

passwd_list() {
    echo -e "${CYAN}Passwoerter:${RESET}"
    local i=0
    for f in "$SECRETS_DIR"/*.pass; do
        [ -f "$f" ] || continue
        i=$((i + 1))
        echo -e "  ${GREEN}[$i]${RESET} ${YELLOW}$(basename "$f" .pass)${RESET}"
    done
    [ $i -eq 0 ] && echo "  Keine Passwoerter."
}

passwd_show() {
    local name="$1"
    [ -z "$name" ] && { echo "Usage: writer passwd-show <name>"; return 1; }
    local file="$SECRETS_DIR/${name}.pass"
    [ -f "$file" ] && cat "$file" || echo -e "${RED}Nicht gefunden.${RESET}"
}

passwd_delete() {
    local name="$1"
    [ -z "$name" ] && { echo "Usage: writer passwd-del <name>"; return 1; }
    rm -iv "$SECRETS_DIR/${name}.pass" && echo -e "${GREEN}Geloscht.${RESET}"
}

# ═══════════════════════════════════════════════════════
# DATA FORMAT CONVERSION
# ═══════════════════════════════════════════════════════
data_json2yaml() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer data-json2yaml <file>"; return 1; }
    if command -v python3 &>/dev/null; then
        python3 -c "import json,yaml; json.dump(yaml.safe_load(open('$file')), open('${file%.json}.yaml','w'), indent=2)" 2>/dev/null
        echo -e "${GREEN}Konvertiert: ${file%.json}.yaml${RESET}"
    else
        echo "python3 required."
    fi
}

data_yaml2json() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer data-yaml2json <file>"; return 1; }
    if command -v python3 &>/dev/null; then
        python3 -c "import json,yaml; yaml_data=yaml.safe_load(open('$file')); json.dump(yaml_data, open('${file%.yaml}.json','w'), indent=2)" 2>/dev/null
        echo -e "${GREEN}Konvertiert: ${file%.yaml}.json${RESET}"
    else
        echo "python3 required."
    fi
}

data_json2csv() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer data-json2csv <file>"; return 1; }
    if command -v python3 &>/dev/null; then
        python3 -c "
import json,csv
data=json.load(open('$file'))
if isinstance(data,list) and data:
    with open('${file%.json}.csv','w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=data[0].keys())
        w.writeheader(); w.writerows(data)
    print('Konvertiert.')
else:
    print('JSON muss Liste von Objekten sein.')
" 2>/dev/null
    fi
}

data_csv2json() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer data-csv2json <file>"; return 1; }
    if command -v python3 &>/dev/null; then
        python3 -c "
import json,csv
with open('$file') as f:
    data=list(csv.DictReader(f))
json.dump(data, open('${file%.csv}.json','w'), indent=2)
print('Konvertiert.')
" 2>/dev/null
    fi
}

data_xml2json() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer data-xml2json <file>"; return 1; }
    if command -v python3 &>/dev/null; then
        python3 -c "
import json
try:
    import xmltodict
    with open('$file') as f: data=xmltodict.parse(f.read())
    json.dump(data, open('${file%.xml}.json','w'), indent=2)
    print('Konvertiert.')
except ImportError:
    print('pip install xmltodict')
" 2>/dev/null
    fi
}

data_yaml2toml() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer data-yaml2toml <file>"; return 1; }
    if command -v python3 &>/dev/null; then
        python3 -c "
import yaml
try:
    import tomli_w as tomlw
except ImportError:
    try:
        import tomlkit as tomlw
    except ImportError:
        print('pip install tomli-w'); exit()
data=yaml.safe_load(open('$file'))
with open('${file%.yaml}.toml','w') as f: tomlw.dump(data, f)
print('Konvertiert.')
" 2>/dev/null
    fi
}

data_toml2yaml() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer data-toml2yaml <file>"; return 1; }
    if command -v python3 &>/dev/null; then
        python3 -c "
import yaml
try:
    import tomllib
except ImportError:
    print('Python 3.11+ required for tomllib'); exit()
data=tomllib.load(open('$file','rb'))
yaml.dump(data, open('${file%.toml}.yaml','w'), default_flow_style=False)
print('Konvertiert.')
" 2>/dev/null
    fi
}

data_pretty() {
    local type="$1" file="$2"
    [ -z "$type" ] || [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer data-pretty <json|yaml> <file>"; return 1; }
    if command -v python3 &>/dev/null; then
        case "$type" in
            json) python3 -c "import json; print(json.dumps(json.load(open('$file')), indent=2))" 2>/dev/null ;;
            yaml) python3 -c "import yaml; print(yaml.dump(yaml.safe_load(open('$file')), default_flow_style=False))" 2>/dev/null ;;
            *) echo "Typ: $type nicht unterstuetzt." ;;
        esac
    fi
}

# ═══════════════════════════════════════════════════════
# LOG ANALYZER
# ═══════════════════════════════════════════════════════
log_analyze() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer log-analyze <file>"; return 1; }
    echo -e "${CYAN}Log Analyse: $(basename "$file")${RESET}"
    echo "────────────────────────────────"
    echo "Zeilen:        $(wc -l < "$file")"
    echo "Groesse:       $(du -h "$file" | cut -f1)"
    echo "ERROR:         $(grep -ci 'error' "$file" 2>/dev/null || echo 0)"
    echo "WARNING:       $(grep -ci 'warn' "$file" 2>/dev/null || echo 0)"
    echo "INFO:          $(grep -ci 'info' "$file" 2>/dev/null || echo 0)"
    echo "DEBUG:         $(grep -ci 'debug' "$file" 2>/dev/null || echo 0)"
    echo "CRITICAL:      $(grep -ci 'critical\|fatal\|panic' "$file" 2>/dev/null || echo 0)"
    echo ""
    echo "Top 5 Fehler:"
    grep -i 'error' "$file" 2>/dev/null | sort | uniq -c | sort -rn | head -5 | while read count line; do
        echo -e "  ${RED}[$count]${RESET} ${YELLOW}${line:0:80}${RESET}"
    done
}

log_errors() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer log-errors <file>"; return 1; }
    echo -e "${RED}Fehler in $(basename "$file"):${RESET}"
    grep -in 'error\|exception\|traceback\|fatal' "$file" 2>/dev/null | head -30 | while IFS= read -r line; do
        echo -e "  ${RED}$line${RESET}"
    done
}

log_stats() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer log-stats <file>"; return 1; }
    echo -e "${CYAN}Log Stats: $(basename "$file")${RESET}"
    echo "────────────────────────────────"
    local total=$(wc -l < "$file")
    local errors=$(grep -ci 'error' "$file" 2>/dev/null || echo 0)
    local error_rate=0
    [ "$total" -gt 0 ] && error_rate=$((errors * 100 / total))
    echo "Total Lines:   $total"
    echo "Errors:        $errors (${error_rate}%)"
    echo "First Entry:   $(head -1 "$file" | cut -c1-80)"
    echo "Last Entry:    $(tail -1 "$file" | cut -c1-80)"
    echo "Time Range:    $(head -1 "$file" | grep -oE '^[0-9-]+ [0-9:]+' 2>/dev/null || echo 'N/A')"
}

# ═══════════════════════════════════════════════════════
# ENCRYPTION
# ═══════════════════════════════════════════════════════
file_encrypt() {
    local file="$1" key="${2:-writer_default_key}"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer encrypt <file> [key]"; return 1; }
    if command -v openssl &>/dev/null; then
        openssl enc -aes-256-cbc -salt -pbkdf2 -in "$file" -out "${file}.enc" -pass "pass:$key" 2>/dev/null
        echo -e "${GREEN}verschluesselt: ${file}.enc${RESET}"
    else
        echo "openssl required."
    fi
}

file_decrypt() {
    local file="$1" key="${2:-writer_default_key}"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer decrypt <file> [key]"; return 1; }
    if command -v openssl &>/dev/null; then
        openssl enc -aes-256-cbc -d -pbkdf2 -in "$file" -out "${file%.enc}" -pass "pass:$key" 2>/dev/null
        echo -e "${GREEN}Entschluesselt: ${file%.enc}${RESET}"
    else
        echo "openssl required."
    fi
}

# ═══════════════════════════════════════════════════════
# HTTP/API
# ═══════════════════════════════════════════════════════
http_get() {
    local url="$1"
    [ -z "$url" ] && { echo "Usage: writer http-get <url>"; return 1; }
    if command -v curl &>/dev/null; then
        curl -sL "$url"
    elif command -v wget &>/dev/null; then
        wget -qO- "$url"
    else
        echo "curl oder wget required."
    fi
}

http_post() {
    local url="$1" data="$2"
    [ -z "$url" ] || [ -z "$data" ] && { echo "Usage: writer http-post <url> '<json>'"; return 1; }
    curl -sL -X POST -H "Content-Type: application/json" -d "$data" "$url"
}

http_api() {
    local url="$1"
    [ -z "$url" ] && { echo "Usage: writer http-api <url>"; return 1; }
    if command -v curl &>/dev/null; then
        curl -sL "$url" | python3 -m json.tool 2>/dev/null || curl -sL "$url"
    fi
}

http_status() {
    local url="$1"
    [ -z "$url" ] && { echo "Usage: writer http-status <url>"; return 1; }
    curl -sL -o /dev/null -w "HTTP Code: %{http_code}\nZeit: %{time_total}s\nGroesse: %{size_download} bytes\n" "$url" 2>/dev/null
}

# ═══════════════════════════════════════════════════════
# SQLite
# ═══════════════════════════════════════════════════════
db_create() {
    local db="$1"
    [ -z "$db" ] && { echo "Usage: writer db-create <file.db>"; return 1; }
    if command -v sqlite3 &>/dev/null; then
        sqlite3 "$db" "CREATE TABLE IF NOT EXISTS info (key TEXT, value TEXT);"
        echo -e "${GREEN}DB erstellt: $db${RESET}"
    else
        echo "sqlite3 required."
    fi
}

db_query() {
    local db="$1" sql="$2"
    [ -z "$db" ] || [ -z "$sql" ] && { echo "Usage: writer db-query <db> '<sql>'"; return 1; }
    if command -v sqlite3 &>/dev/null; then
        sqlite3 -header -column "$db" "$sql"
    else
        echo "sqlite3 required."
    fi
}

db_tables() {
    local db="$1"
    [ -z "$db" ] && { echo "Usage: writer db-tables <db>"; return 1; }
    if command -v sqlite3 &>/dev/null; then
        sqlite3 "$db" ".tables"
    else
        echo "sqlite3 required."
    fi
}

db_dump() {
    local db="$1"
    [ -z "$db" ] && { echo "Usage: writer db-dump <db>"; return 1; }
    if command -v sqlite3 &>/dev/null; then
        sqlite3 "$db" ".dump"
    else
        echo "sqlite3 required."
    fi
}

# ═══════════════════════════════════════════════════════
# CRON
# ═══════════════════════════════════════════════════════
cron_add() {
    local cmd="$1"
    [ -z "$cmd" ] && { echo "Usage: writer cron-add '<command>'"; return 1; }
    (crontab -l 2>/dev/null; echo "$cmd") | crontab -
    echo -e "${GREEN}Cron-Job hinzugefuegt.${RESET}"
}

cron_list_func() {
    echo -e "${CYAN}Cron Jobs:${RESET}"
    crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$' | nl -w2 -s'. ' || echo "  Keine Jobs."
}

cron_del() {
    local num="$1"
    [ -z "$num" ] && { echo "Usage: writer cron-del <nr>"; return 1; }
    local jobs=$(crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$')
    local to_del=$(echo "$jobs" | sed -n "${num}p")
    if [ -n "$to_del" ]; then
        crontab -l 2>/dev/null | grep -vF "$to_del" | crontab -
        echo -e "${GREEN}Geloscht: $to_del${RESET}"
    else
        echo -e "${RED}Nicht gefunden.${RESET}"
    fi
}

# ═══════════════════════════════════════════════════════
# BACKUP
# ═══════════════════════════════════════════════════════
backup_create() {
    local dir="${1:-.}"
    [ -z "$dir" ] && { echo "Usage: writer backup-create <dir>"; return 1; }
    local ts=$(date +%Y%m%d_%H%M%S)
    local name=$(basename "$dir" | tr -cd '[:alnum:]')
    local archive="$BACKUP_DIR/${name}_${ts}.tar.gz"
    tar czf "$archive" -C "$(dirname "$dir")" "$name" 2>/dev/null
    echo -e "${GREEN}Backup: $archive ($(du -h "$archive" | cut -f1))${RESET}"
}

backup_restore() {
    local num="$1"
    [ -z "$num" ] && { echo "Usage: writer backup-restore <nr>"; return 1; }
    local file=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | sed -n "${num}p")
    [ -n "$file" ] && { tar xzf "$file" -C "$HOME" && echo -e "${GREEN}Wiederhergestellt: $file${RESET}"; } || echo -e "${RED}Nicht gefunden.${RESET}"
}

backup_list() {
    echo -e "${CYAN}Backups:${RESET}"
    local i=0
    ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | while IFS= read -r f; do
        i=$((i + 1))
        echo -e "  ${GREEN}[$i]${RESET} ${YELLOW}$(basename "$f")${RESET} ($(du -h "$f"|cut -f1))"
    done
}

# ═══════════════════════════════════════════════════════
# ENVIRONMENT
# ═══════════════════════════════════════════════════════
ENV_FILE="$HOME/.writer_env"
[ -f "$ENV_FILE" ] || touch "$ENV_FILE"

env_set() {
    local key="$1" val="$2"
    [ -z "$key" ] || [ -z "$val" ] && { echo "Usage: writer env-set <key> <value>"; return 1; }
    grep -q "^${key}=" "$ENV_FILE" 2>/dev/null && sed -i "s|^${key}=.*|${key}=${val}|" "$ENV_FILE" || echo "${key}=${val}" >> "$ENV_FILE"
    export "$key"="$val"
    echo -e "${GREEN}Gesetzt: $key=$val${RESET}"
}

env_get() {
    local key="$1"
    [ -z "$key" ] && { echo "Usage: writer env-get <key>"; return 1; }
    grep "^${key}=" "$ENV_FILE" 2>/dev/null | cut -d= -f2- || echo -e "${RED}Nicht gefunden.${RESET}"
}

env_list() {
    echo -e "${CYAN}Environment Variablen:${RESET}"
    [ -s "$ENV_FILE" ] && cat "$ENV_FILE" | nl -w2 -s'. ' || echo "  Keine."
}

env_del() {
    local key="$1"
    [ -z "$key" ] && { echo "Usage: writer env-del <key>"; return 1; }
    sed -i "/^${key}=/d" "$ENV_FILE" && echo -e "${GREEN}Geloscht: $key${RESET}"
}

# ═══════════════════════════════════════════════════════
# SSH
# ═══════════════════════════════════════════════════════
ssh_keygen_func() {
    local email="${1:-user@device}"
    echo -e "${CYAN}SSH Key wird erstellt...${RESET}"
    ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N ""
    echo -e "${GREEN}SSH Key erstellt.${RESET}"
}

ssh_add_func() {
    local host="$1" user="${2:-$(whoami)"
    [ -z "$host" ] && { echo "Usage: writer ssh-add <host> [user]"; return 1; }
    local config_file="$HOME/.ssh/config"
    mkdir -p "$HOME/.ssh"
    cat >> "$config_file" << EOF

Host $host
    HostName $host
    User $user
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
EOF
    echo -e "${GREEN}SSH Config fuer $host hinzugefuegt.${RESET}"
}

ssh_list() {
    echo -e "${CYAN}SSH Hosts:${RESET}"
    grep "^Host " "$HOME/.ssh/config" 2>/dev/null | awk '{print "  " $2}' || echo "  Keine."
}

# ═══════════════════════════════════════════════════════
# DOCKER
# ═══════════════════════════════════════════════════════
docker_ps() { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker nicht verfuegbar."; }
docker_status() { docker info 2>/dev/null | grep -E 'Server Version|Containers|Running|Paused' || echo "Docker nicht verfuegbar."; }
docker_logs() { [ -z "$1" ] && { echo "Usage: writer docker-logs <container>"; return 1; }; docker logs --tail 50 "$1" 2>/dev/null || echo "Nicht gefunden."; }

# ═══════════════════════════════════════════════════════
# DOC GENERATOR
# ═══════════════════════════════════════════════════════
docs_gen() {
    local file="$1"
    [ -z "$file" ] || [ ! -f "$file" ] && { echo "Usage: writer docs-gen <file>"; return 1; }
    local outfile="${file%.*}_docs.md"
    {
        echo "# Documentation: $(basename "$file")"
        echo ""
        echo "## Datei-Info"
        echo "- Typ: $(file "$file" 2>/dev/null | cut -d: -f2)"
        echo "- Groesse: $(du -h "$file" | cut -f1)"
        echo "- Zeilen: $(wc -l < "$file")"
        echo ""
        echo "## Inhalt"
        echo '```'"$(echo "$file" | sed 's/.*\.//')"
        cat "$file"
        echo '```'
    } > "$outfile"
    echo -e "${GREEN}Dokumentation: $outfile${RESET}"
}

docs_python() {
    local dir="$1"
    [ -z "$dir" ] && { echo "Usage: writer docs-python <dir>"; return 1; }
    [ ! -d "$dir" ] && { echo "Verzeichnis nicht gefunden."; return 1; }
    local outfile="$dir/docs.md"
    {
        echo "# Python Projekt: $(basename "$dir")"
        echo ""
        echo "## Module"
        find "$dir" -name "*.py" -type f | while IFS= read -r f; do
            echo "### $(basename "$f")"
            grep -E '^(def |class |"""|# )' "$f" 2>/dev/null | head -10 | while IFS= read -r line; do
                echo "- $line"
            done
            echo ""
        done
    } > "$outfile"
    echo -e "${GREEN}Dokumentation: $outfile${RESET}"
}

# ═══════════════════════════════════════════════════════
# NETWORK
# ═══════════════════════════════════════════════════════
net_scan() {
    local range="${1:-192.168.1.}"
    echo -e "${CYAN}Scanne ${range}*...${RESET}"
    for i in $(seq 1 20); do
        (ping -c 1 -W 1 "${range}${i}" &>/dev/null && echo -e "  ${GREEN}● ${range}${i} - ONLINE${RESET}" || echo -e "  ${RED}○ ${range}${i}${RESET}") &
    done
    wait
}

net_port() {
    local port="$1"
    [ -z "$port" ] && { echo "Usage: writer net-port <port>"; return 1; }
    if command -v ss &>/dev/null; then
        ss -tlnp 2>/dev/null | grep ":$port" || echo "Port $port nicht belegt."
    elif command -v netstat &>/dev/null; then
        netstat -tlnp 2>/dev/null | grep ":$port" || echo "Port $port nicht belegt."
    fi
}

net_speed() {
    echo -e "${CYAN}Speed Test...${RESET}"
    if command -v curl &>/dev/null; then
        local start=$(date +%s%N)
        curl -sL -o /dev/null "https://speed.cloudflare.com/__down?bytes=1000000" 2>/dev/null
        local end=$(date +%s%N)
        local elapsed=$(( (end - start) / 1000000 ))
        if [ "$elapsed" -gt 0 ]; then
            local speed=$(( 1000 * 8 / elapsed ))
            echo -e "Download: ~${speed} Mbps (1MB Test)"
        else
            echo "Zu schnell zum messen."
        fi
    else
        echo "curl required."
    fi
}

# ═══════════════════════════════════════════════════════
# BENCHMARK
# ═══════════════════════════════════════════════════════
bench_cpu() {
    echo -e "${CYAN}CPU Benchmark...${RESET}"
    local start=$(date +%s%N)
    for i in $(seq 1 1000000); do : ; done
    local end=$(date +%s%N)
    local elapsed=$(( (end - start) / 1000000 ))
    echo "1M Iterationen: ${elapsed}ms"
}

bench_disk() {
    echo -e "${CYAN}Disk Benchmark...${RESET}"
    dd if=/dev/zero of=/tmp/bench_test bs=1M count=100 2>&1 | tail -1
    rm -f /tmp/bench_test
}

bench_mem() {
    echo -e "${CYAN}Memory Info:${RESET}"
    free -h 2>/dev/null || cat /proc/meminfo 2>/dev/null | head -5
}

# ═══════════════════════════════════════════════════════
# COLOR THEMES
# ═══════════════════════════════════════════════════════
THEME_FILE="$HOME/.writer_theme"

theme_list() {
    echo -e "${CYAN}Verfuegbare Themes:${RESET}"
    echo "  1. default    - Standard Farben"
    echo "  2. monokai    - Dunkle Farben"
    echo "  3. solarized  - Blau/Gruen"
    echo "  4. dracula    - Purple/Pink"
    echo "  5. nord       - Arctic Blue"
}

theme_set() {
    local name="$1"
    [ -z "$name" ] && { echo "Usage: writer theme-set <name>"; return 1; }
    case "$name" in
        default) RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m' ;;
        monokai) RED='\033[0;91m'; GREEN='\033[0;92m'; YELLOW='\033[0;93m'; BLUE='\033[0;94m'; MAGENTA='\033[0;95m'; CYAN='\033[0;96m' ;;
        solarized) RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m' ;;
        dracula) RED='\033[1;91m'; GREEN='\033[1;92m'; YELLOW='\033[1;93m'; BLUE='\033[1;94m'; MAGENTA='\033[1;95m'; CYAN='\033[1;96m' ;;
        nord) RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; CYAN='\033[0;36m' ;;
        *) echo "Theme unbekannt." ;;
    esac
    echo "$name" > "$THEME_FILE"
    echo -e "${GREEN}Theme gesetzt: $name${RESET}"
}

# ═══════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════
cmd="${1:-help}"; shift 2>/dev/null

case "$cmd" in
    edit|nano) edit_file "$@" ;;
    vim) vim_file "$@" ;;
    note|n) create_note "$@" ;;
    list|ls|l) list_notes ;;
    read|cat|r) read_note "$@" ;;
    del|rm|d) delete_note "$@" ;;
    search|grep) search_notes "$@" ;;
    export) export_note "$@" ;;
    import) import_note "$@" ;;
    template|t) generate_template "$@" ;;
    project) create_project "$@" ;;
    write|w) write_file_interactive "$@" ;;
    append|a) append_file "$@" ;;
    copy|cp) copy_file "$@" ;;
    rename|mv) rename_file "$@" ;;
    delete) delete_file "$@" ;;
    tree) show_tree "$@" ;;
    diff) diff_files "$@" ;;
    stat) file_stat "$@" ;;
    touch) touch_file "$@" ;;
    wc) text_wc "$@" ;;
    replace) text_replace "$@" ;;
    regex) text_regex "$@" ;;
    upper) text_upper "$@" ;;
    lower) text_lower "$@" ;;
    title) text_title "$@" ;;
    trim) text_trim "$@" ;;
    dedup) text_dedup "$@" ;;
    sort|sortf) text_sort "$@" ;;
    preview) text_preview "$@" ;;
    head|h) text_head "$@" ;;
    tail) text_tail "$@" ;;
    md-toc) md_toc "$@" ;;
    md-links) md_links "$@" ;;
    md-check) md_check "$@" ;;
    md-html) md_to_html "$@" ;;
    md-stats) md_stats "$@" ;;
    ai-write) ai_write "$@" ;;
    ai-improve) ai_improve "$@" ;;
    ai-explain) ai_explain "$@" ;;
    ai-summarize) ai_summarize "$@" ;;
    ai-complete) ai_complete "$@" ;;
    find-name) find_name "$@" ;;
    find-content) find_content "$@" ;;
    find-type) find_type "$@" ;;
    find-recent) find_recent "$@" ;;
    snippet)
        sub="${1:-}"; shift 2>/dev/null
        case "$sub" in
            save|s) snippet_save "$@" ;;
            load|l) snippet_load "$@" ;;
            list|ls) snippet_list ;;
            delete|del) snippet_delete "$@" ;;
            *) echo "snippet save|load|list|delete" ;;
        esac ;;
    archive-create) archive_create "$@" ;;
    archive-extract) archive_extract "$@" ;;
    archive-list) archive_list "$@" ;;
    git-init) git_init ;;
    git-status) git_status ;;
    git-add) git_add "$@" ;;
    git-commit) git_commit "$@" ;;
    git-log) git_log "$@" ;;
    git-branch) git_branch "$@" ;;
    git-push) git_push "$@" ;;
    git-pull) git_pull "$@" ;;
    git-diff) git_diff ;;
    clipboard-copy) clipboard_copy "$@" ;;
    clipboard-paste) clipboard_paste "$@" ;;
    batch-rename) batch_rename "$@" ;;
    batch-chmod) batch_chmod "$@" ;;

    # Passwords
    passwd-gen) passwd_gen "$@" ;;
    passwd-save) passwd_save "$@" ;;
    passwd-list) passwd_list ;;
    passwd-show) passwd_show "$@" ;;
    passwd-del) passwd_delete "$@" ;;

    # Data Conversion
    data-json2yaml) data_json2yaml "$@" ;;
    data-yaml2json) data_yaml2json "$@" ;;
    data-json2csv) data_json2csv "$@" ;;
    data-csv2json) data_csv2json "$@" ;;
    data-xml2json) data_xml2json "$@" ;;
    data-yaml2toml) data_yaml2toml "$@" ;;
    data-toml2yaml) data_toml2yaml "$@" ;;
    data-pretty) data_pretty "$@" ;;

    # Log Analyzer
    log-analyze) log_analyze "$@" ;;
    log-errors) log_errors "$@" ;;
    log-stats) log_stats "$@" ;;

    # Encryption
    encrypt) file_encrypt "$@" ;;
    decrypt) file_decrypt "$@" ;;

    # HTTP/API
    http-get) http_get "$@" ;;
    http-post) http_post "$@" ;;
    http-api) http_api "$@" ;;
    http-status) http_status "$@" ;;

    # SQLite
    db-create) db_create "$@" ;;
    db-query) db_query "$@" ;;
    db-tables) db_tables "$@" ;;
    db-dump) db_dump "$@" ;;

    # Cron
    cron-add) cron_add "$@" ;;
    cron-list) cron_list_func ;;
    cron-del) cron_del "$@" ;;

    # Backup
    backup-create) backup_create "$@" ;;
    backup-restore) backup_restore "$@" ;;
    backup-list) backup_list ;;

    # Environment
    env-set) env_set "$@" ;;
    env-get) env_get "$@" ;;
    env-list) env_list ;;
    env-del) env_del "$@" ;;

    # SSH
    ssh-keygen) ssh_keygen_func "$@" ;;
    ssh-add) ssh_add_func "$@" ;;
    ssh-list) ssh_list ;;

    # Docker
    docker-ps) docker_ps ;;
    docker-status) docker_status ;;
    docker-logs) docker_logs "$@" ;;

    # Docs
    docs-gen) docs_gen "$@" ;;
    docs-python) docs_python "$@" ;;

    # Network
    net-scan) net_scan "$@" ;;
    net-port) net_port "$@" ;;
    net-speed) net_speed ;;

    # Benchmark
    bench-cpu) bench_cpu ;;
    bench-disk) bench_disk ;;
    bench-mem) bench_mem ;;

    # Themes
    theme-set) theme_set "$@" ;;
    theme-list) theme_list ;;

    help|h|*) usage ;;
esac
