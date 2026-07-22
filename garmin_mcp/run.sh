#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

export GARMIN_EMAIL=$(jq -r '.garmin_email' "$CONFIG_PATH")
export GARMIN_PASSWORD=$(jq -r '.garmin_password' "$CONFIG_PATH")

MFA=$(jq -r '.garmin_mfa_code // empty' "$CONFIG_PATH")
if [ -n "$MFA" ]; then
  export GARMIN_MFA_CODE="$MFA"
  export GARMIN_MFA_WAIT_SECONDS=180
fi

export GARMIN_MCP_TRANSPORT=streamable-http
export GARMIN_MCP_HOST=0.0.0.0
export GARMIN_MCP_PORT=8000
export GARMINTOKENS=/data/garminconnect

mkdir -p "$GARMINTOKENS"

cd /app
exec uv run garmin-mcp
