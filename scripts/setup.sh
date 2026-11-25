#!/usr/bin/env bash

set -euo pipefail


# config setup

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"

OLS_CONFIG="$PROJECT_ROOT/ols.json"

# log helper methods, thanks GPT

info() {
    printf '\033[0;36m[INFO]\033[0m %s\n' "$1"
}

success() {
    printf '\033[0;32m[SUCCESS]\033[0m %s\n' "$1"
}

warning() {
    printf '\033[0;33m[WARNING]\033[0m %s\n' "$1"
}

error() {
    printf '\033[0;31m[ERROR]\033[0m %s\n' "$1" >&2
}

# json stuff, also thanks GPT

json_escape() {
    local value="$1"

    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\t'/\\t}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\n'/\\n}"

    printf '%s' "$value"
}


# Odin installation resolver
# tries to 
ODIN_PATH="${1:-}"

if [[ -z "$ODIN_PATH" ]] then
    ODIN_PATH="${ODIN_ROOT:-}"
fi

if [[ -z "$ODIN_PATH" ]] then
    ODIN_PATH="${ODIN_HOME:-}"
fi

if [[ -z "$ODIN_PATH" ]] then
    ODIN_PATH="$(command -v odin 2>/dev/null || true)"
fi

# fallback to manual user prompt

if [[ -z "$ODIN_PATH" ]]; then
    warning "Could not automatically locate Odin."

    read -r -p "Enter your Odin installation directory or executable: " ODIN_PATH
fi

if [[ -z "$ODIN_PATH" ]]; then
    error "No Odin installation path provided."
    exit 1
fi

if [[ "$ODIN_PATH" == "~" ]]; then
    ODIN_PATH="$HOME"
elif [[ "$ODIN_PATH" == "~/"* ]]; then
    ODIN_PATH="$HOME/${ODIN_PATH#~/}"
fi

# absolute path resolver

if [[ -d "$ODIN_PATH" ]]; then
    ODIN_ROOT="$(cd -- "$ODIN_PATH" && pwd -P)"
    ODIN_EXECUTABLE="$ODIN_ROOT/odin"

elif [[ -f "$ODIN_PATH" ]]; then
    ODIN_EXECUTABLE_DIR="$(cd -- "$(dirname -- "$ODIN_PATH")" && pwd -P)"

    ODIN_EXECUTABLE="$ODIN_EXECUTABLE_DIR/$(basename -- "$ODIN_PATH")"
    ODIN_ROOT="$ODIN_EXECUTABLE_DIR"

else
    error "The provided Odin path does not exist: $ODIN_PATH"
    exit 1
fi

# validate given installation 

if [[ ! -f "$ODIN_EXECUTABLE" ]]; then
    error "Odin executable not found: $ODIN_EXECUTABLE"
    exit 1
fi

if [[ ! -x "$ODIN_EXECUTABLE" ]]; then
    error "Odin executable is not executable: $ODIN_EXECUTABLE"
    exit 1
fi

if [[ ! -d "$ODIN_ROOT/core" ]]; then
    error "Odin core directory not found: $ODIN_ROOT/core"
    exit 1
fi

# check for existing ols.json file, asking the user to manually confirm overwriting in case they do special stuff with it

if [[ -f "$OLS_CONFIG" ]]; then
    warning "An ols.json configuration already exists."

    read -r -p "Do you want to overwrite it? [y/N] " RESPONSE

    case "$RESPONSE" in
        y|Y|yes|YES|Yes)
            ;;
        *)
            info "Setup cancelled. Existing configuration preserved."
            exit 0
            ;;
    esac
fi


# generate configuration for ols.json, not sure about the JSON string but it will do for now

JSON_ODIN_EXECUTABLE="$(json_escape "$ODIN_EXECUTABLE")"
JSON_ODIN_ROOT="$(json_escape "$ODIN_ROOT")"

TEMP_CONFIG="$(mktemp "$PROJECT_ROOT/.ols.json.XXXXXX")"

cleanup() {
    rm -f "$TEMP_CONFIG"
}

trap cleanup EXIT

cat > "$TEMP_CONFIG" <<EOF
{
    "\$schema": "https://raw.githubusercontent.com/DanielGavin/ols/master/misc/ols.schema.json",

    "odin_command": "$JSON_ODIN_EXECUTABLE",
    "odin_root_override": "$JSON_ODIN_ROOT",

    "enable_semantic_tokens": true,
    "enable_document_symbols": true,
    "enable_hover": true,
    "enable_snippets": true,
    "enable_format": true,

    "collections": [
        {
            "name": "src",
            "path": "src"
        }
    ],

    "profile": "default",
    "profiles": [
        {
            "name": "default",
            "checker_path": [
                "src"
            ]
        }
    ]
}
EOF

mv "$TEMP_CONFIG" "$OLS_CONFIG"

trap - EXIT


# generation is done here, just showing some information
success "OLS configuration generated successfully."

printf '\n'
info "Project root:       $PROJECT_ROOT"
info "Odin executable:    $ODIN_EXECUTABLE"
info "Odin root:          $ODIN_ROOT"
info "OLS configuration:  $OLS_CONFIG"

printf '\n'
success "You can now open the project in VS Code."