#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

export GARMIN_EMAIL=$(jq -r '.garmin_email' "$CONFIG_PATH")
export GARMIN_PASSWORD=$(jq -r '.garmin_password' "$CONFIG_PATH")

MFA=$(jq -r '.garmin_mfa_code // empty' "$CONFIG_PATH")
if [ -n "$MFA" ]; then
  export GARMIN_MFA_CODE="$MFA"
fi

TOKENSTORE=/data/garminconnect
cd /app

if [ ! -f "$TOKENSTORE/oauth1_token.json" ] || [ ! -f "$TOKENSTORE/oauth2_token.json" ]; then
  echo "Geen (volledige) opgeslagen Garmin-tokens gevonden — map wissen en eerste login uitvoeren..."
  rm -rf "$TOKENSTORE"

  uv run python - <<'PYEOF'
import os
import sys
from garminconnect import Garmin

email = os.environ["GARMIN_EMAIL"]
password = os.environ["GARMIN_PASSWORD"]
tokenstore = "/data/garminconnect"
mfa_code = os.environ.get("GARMIN_MFA_CODE")

def prompt_mfa():
    if mfa_code:
        return mfa_code
    print("MFA-code vereist maar GARMIN_MFA_CODE niet ingesteld.", file=sys.stderr)
    sys.exit(1)

try:
    garmin = Garmin(email=email, password=password, prompt_mfa=prompt_mfa)
    garmin.login()
    garmin.garth.dump(tokenstore)
    print("Login gelukt, tokens opgeslagen in", tokenstore)
except Exception as e:
    print("Login mislukt:", e, file=sys.stderr)
    sys.exit(1)
PYEOF
fi

export GARMINTOKENS="$TOKENSTORE"
export GARMIN_MCP_TRANSPORT=streamable-http
export GARMIN_MCP_HOST=0.0.0.0
export GARMIN_MCP_PORT=8000

exec uv run garmin-mcp
