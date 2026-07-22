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

  echo "=== OMGEVINGSVARIABELEN DIAGNOSE ==="
  echo "HOME=$HOME"
  echo "GARMINTOKENS=$GARMINTOKENS"
  echo "===================================="

  uv run python - <<'PYEOF'
import os
import sys
import traceback

print("HOME env:", os.environ.get("HOME"), file=sys.stderr)
print("GARMINTOKENS env:", os.environ.get("GARMINTOKENS"), file=sys.stderr)

from garminconnect import Garmin

email = os.environ["GARMIN_EMAIL"]
password = os.environ["GARMIN_PASSWORD"]

try:
    garmin = Garmin(email=email, password=password)
    garmin.login()
    print("Login gelukt")
except Exception:
    print("=== VOLLEDIGE TRACEBACK ===", file=sys.stderr)
    traceback.print_exc()
    print("=== EINDE TRACEBACK ===", file=sys.stderr)
    sys.exit(1)
PYEOF
fi

export GARMINTOKENS="$TOKENSTORE"
exec uv run garmin-mcp
