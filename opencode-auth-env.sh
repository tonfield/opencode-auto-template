#!/usr/bin/env bash

# Load custom OpenCode provider keys from OpenCode's own auth store.
# Source this file from your shell rc if you want env-backed custom providers
# (for example Kilo/OpenRouter-backed reviewer models) to resolve automatically.
# The env mappings are loaded from custom-providers.json in the installed
# OpenCode config directory.

opencode_has_python3() {
  command -v python3 >/dev/null 2>&1
}

opencode_auth_api_key() {
  if ! opencode_has_python3; then
    printf '\n'
    return 0
  fi

  python3 - "$1" <<'PY'
import json
import sys
from pathlib import Path

provider_id = sys.argv[1]
path = Path.home() / '.local' / 'share' / 'opencode' / 'auth.json'
try:
    print(json.loads(path.read_text()).get(provider_id, {}).get('key', ''))
except Exception:
    print('')
PY
}

opencode_export_auth_env() {
  local env_name="$1"
  local provider_id="$2"
  local current_value=""

  current_value="$(printenv "$env_name" 2>/dev/null || true)"

  if [[ -z "$current_value" ]] && [[ -f "$HOME/.local/share/opencode/auth.json" ]]; then
    export "$env_name=$(opencode_auth_api_key "$provider_id")"
  fi
}

opencode_export_registered_auth_envs() {
  local registry_path="${OPENCODE_GLOBAL_DIR:-$HOME/.config/opencode}/custom-providers.json"
  local env_name=""
  local provider_id=""

  if [[ ! -f "$registry_path" ]]; then
    return 0
  fi

  if ! opencode_has_python3; then
    return 0
  fi

  while IFS=$'\t' read -r env_name provider_id; do
    if [[ -n "$env_name" ]] && [[ -n "$provider_id" ]]; then
      opencode_export_auth_env "$env_name" "$provider_id"
    fi
  done < <(
    python3 - "$registry_path" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
try:
    data = json.loads(path.read_text())
except Exception:
    raise SystemExit(0)

for provider in data.get("providers", []):
    env_name = provider.get("envVar")
    provider_id = provider.get("authStoreKey") or provider.get("providerId")
    if env_name and provider_id:
        print(f"{env_name}\t{provider_id}")
PY
  )
}

opencode_omlx_api_key() {
  if ! opencode_has_python3; then
    printf '\n'
    return 0
  fi

  python3 <<'PY'
import json
from pathlib import Path

path = Path.home() / '.omlx' / 'settings.json'
try:
    print(json.loads(path.read_text()).get('auth', {}).get('api_key', ''))
except Exception:
    print('')
PY
}

opencode_export_omlx_env() {
  local current_value=""
  local key=""

  current_value="$(printenv OMLX_API_KEY 2>/dev/null || true)"
  if [[ -n "$current_value" ]]; then
    return 0
  fi

  key="$(opencode_omlx_api_key)"
  if [[ -n "$key" ]]; then
    export OMLX_API_KEY="$key"
  fi
}

opencode_export_morph_env() {
  local current_value=""
  local key=""

  current_value="$(printenv MORPH_API_KEY 2>/dev/null || true)"
  if [[ -n "$current_value" ]]; then
    return 0
  fi

  if ! command -v security >/dev/null 2>&1; then
    return 0
  fi

  key="$(security find-generic-password -a "$USER" -s "morphllm-api-key" -w 2>/dev/null || true)"
  if [[ -n "$key" ]]; then
    export MORPH_API_KEY="$key"
  fi
}

opencode_export_registered_auth_envs
opencode_export_omlx_env
opencode_export_morph_env

# Morph Fast Apply / WarpGrep
# On macOS, the API key can be stored in Keychain item:
# service=morphllm-api-key, account=$USER. Existing MORPH_API_KEY env vars win.
export MORPH_EDIT=true
export MORPH_WARPGREP=true
export MORPH_WARPGREP_GITHUB=true
export MORPH_COMPACT=false
