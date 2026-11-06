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

# Oude tokens van de vorige Garmin-bibliotheek opruimen;
# de nieuwe versie maakt zelf nieuwe tokens aan bij de eerste login
if [ -f "$TOKENSTORE/oauth1_token.json" ] || [ -f "$TOKENSTORE/oauth2_token.json" ]; then
  echo "Oude Garmin-tokens gevonden — verwijderen..."
  rm -f "$TOKENSTORE/oauth1_token.json" "$TOKENSTORE/oauth2_token.json"
fi
mkdir -p "$TOKENSTORE"

cd /app

export GARMINTOKENS="$TOKENSTORE"
export GARMIN_MCP_TRANSPORT=streamable-http
export GARMIN_MCP_HOST=0.0.0.0
export GARMIN_MCP_PORT=8000

exec uv run garmin-mcp
