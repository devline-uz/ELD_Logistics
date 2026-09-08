#!/usr/bin/env bash
# M44 — `hos_engine` sof Dart paket: `flutter` bog'liqligi (to'g'ridan-to'g'ri
# yoki tranzitiv) bo'lmasligi kerak. CI `hos-parity` job'i shu skriptni chaqiradi.
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

if grep -qE '^\s*(flutter|flutter_test|flutter_lints|sky_engine)\s*:' pubspec.yaml; then
  echo "STOP: pubspec.yaml da flutter bog'liqligi bor (M44)." >&2
  exit 1
fi

json="$(dart pub deps --json)"
if printf '%s' "$json" | grep -qE '"name"\s*:\s*"(flutter|flutter_test|flutter_lints|sky_engine)"'; then
  echo "STOP: dart pub deps --json da flutter paketi bor (M44)." >&2
  exit 1
fi

if grep -rnE "dart:(ui|io|html|isolate)|DateTime\.now\(\)|Random\(" lib/ | grep -vE ':\s*(//|\*)'; then
  echo "STOP: lib/ da taqiqlangan API (M44)." >&2
  exit 1
fi

echo "M44 OK: sof Dart, flutter yo'q."
