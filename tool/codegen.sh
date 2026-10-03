#!/bin/sh
# Regenerates the API client from the backend's OpenAPI spec, the way `orval` does for the
# web app: fetch the spec, wipe the previous client, generate a new one.
#
#   tool/codegen.sh [spec-url]
set -eu
cd "$(dirname "$0")/.."

url="${1:-http://localhost:3000/swagger/v2-json}"
# The Flutter SDK's own dart: another one earlier on PATH may be too old for this project.
dart="$(dirname "$(command -v flutter)")/dart"
out=lib/core/network/generated
spec="$(mktemp)"
trap 'rm -f "$spec"' EXIT

# Fetch first: if the API is down, the current client stays untouched.
curl -fsS "$url" -o "$spec"

# swagger_parser only adds and overwrites files, so the DTOs of removed endpoints would
# linger. Everything in $out is generated: never put hand-written files there.
rm -rf "$out"
"$dart" run swagger_parser --schema_path "$spec" --output_directory "$out"
"$dart" run build_runner build
