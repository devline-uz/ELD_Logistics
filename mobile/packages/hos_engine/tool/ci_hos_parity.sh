#!/usr/bin/env bash
# CI job `hos-parity` ning Dart yarmi (M44, M173, M174, M175).
# Go yarmi: `go test ./internal/hos` — AYNAN shu vektor faylida.
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

echo "==> 1/5 golden vektor hash (M174)"
tool/sync_vectors.sh

echo "==> 2/5 sof Dart tekshiruvi (M44)"
tool/check_no_flutter.sh

echo "==> 3/5 dart analyze"
dart analyze --fatal-infos

echo "==> 4/5 dart format"
dart format --line-length=100 --set-exit-if-changed .

echo "==> 5/5 dart test (35/35 golden vektor — P5)"
dart test

echo "hos-parity (Dart) OK"
