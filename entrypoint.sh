#!/usr/bin/env bash

set -e

CFG_DIR="/app/ComfyUI/user/default/ComfyUI-Manager"
CFG_FILE="$CFG_DIR/config.ini"
DB_DIR="$CFG_DIR"
DB_PATH="${DB_DIR}/manager.db"
SQLITE_URL="sqlite:////${DB_PATH}"

mkdir -p "$CFG_DIR"

if [ ! -f "$CFG_FILE" ]; then
  echo "↳ Creating ComfyUI-Manager config.ini (uv OFF, no file logging, DB cache)"
  cat > "$CFG_FILE" <<EOF
[default]
use_uv = False
file_logging = False
db_mode = cache
database_url = ${SQLITE_URL}
EOF
else
  echo "↳ Updating ComfyUI-Manager config.ini (uv OFF, no file logging, DB cache)"
  # use_uv = False
  grep -q '^use_uv' "$CFG_FILE" \
    && sed -i 's/^use_uv.*/use_uv = False/' "$CFG_FILE" \
    || printf '\nuse_uv = False\n' >> "$CFG_FILE"

  # file_logging = False (and drop any existing log_path line)
  grep -q '^file_logging' "$CFG_FILE" \
    && sed -i 's/^file_logging.*/file_logging = False/' "$CFG_FILE" \
    || printf '\nfile_logging = False\n' >> "$CFG_FILE"
  sed -i '/^log_path[[:space:]=]/d' "$CFG_FILE" || true

  # db_mode = cache (prevents file DB usage)
  grep -q '^db_mode' "$CFG_FILE" \
    && sed -i 's/^db_mode.*/db_mode = cache/' "$CFG_FILE" \
    || printf '\ndb_mode = cache\n' >> "$CFG_FILE"

  # Provide a safe DB URL anyway (future-proof if Manager flips off cache)
  grep -q '^database_url' "$CFG_FILE" \
    && sed -i "s|^database_url.*|database_url = ${SQLITE_URL}|" "$CFG_FILE" \
    || printf "database_url = ${SQLITE_URL}\n" >> "$CFG_FILE"
fi

# Add WD14 models directory
cd custom_nodes/comfyui-wd14-tagger
rm -rf models
ln -s /app/ComfyUI/models/comfyui-wd14-tagger models

echo "↳ Launching ComfyUI"
exec "$@"
