#!/usr/bin/env python3
"""Convert an official GeoJSON FeatureCollection of admin regions into a
forward-only goose SQL migration that fills `regions.geom` via
`ST_GeomFromGeoJSON` (TZ D§1).

This script never touches the database — it only emits a `.sql` file that
the operator reviews and commits like any other migration. Every code it
references must already exist in `regions` (seeded by
`00027_regions_seed_data.sql`); an unknown code aborts the whole migration
at apply time via RAISE EXCEPTION, so a typo cannot silently import zero
rows.

Usage:
    python3 geojson_to_migration.py \
        --input pk.geojson --country PK \
        --out ../../db/migrations/00028_regions_official_pk.sql

See deploy/regions/README.md for where to obtain the source GeoJSON.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--input", required=True, help="Source GeoJSON FeatureCollection")
    p.add_argument("--country", required=True, help="ISO 3166-1 alpha-2, e.g. PK/UZ/US")
    p.add_argument("--out", required=True, help="Path of the goose migration to write")
    p.add_argument(
        "--code-field",
        default="code",
        help="GeoJSON feature property holding the region code (default: code)",
    )
    p.add_argument(
        "--make-valid",
        action="store_true",
        help="Wrap the geometry in ST_MakeValid() (source data sometimes has self-intersections)",
    )
    return p.parse_args()


def sql_escape(s: str) -> str:
    """Escape a string literal for embedding inside `-- +goose StatementBegin`
    blocks that use standard-conforming strings (no backslash escapes)."""
    return s.replace("'", "''")


def build_geom_expr(geometry: dict, make_valid: bool) -> str:
    geojson_literal = sql_escape(json.dumps(geometry, separators=(",", ":")))
    expr = f"ST_SetSRID(ST_GeomFromGeoJSON('{geojson_literal}'), 4326)"
    if make_valid:
        expr = f"ST_MakeValid({expr})"
    return f"ST_Multi({expr})"


def main() -> int:
    args = parse_args()
    data = json.loads(Path(args.input).read_text(encoding="utf-8"))
    features = data.get("features", [])
    if not features:
        print(f"error: {args.input} has no features", file=sys.stderr)
        return 1

    up_statements: list[str] = []
    down_statements: list[str] = []
    codes: list[str] = []

    for feat in features:
        props = feat.get("properties", {})
        code = props.get(args.code_field)
        geometry = feat.get("geometry")
        if not code:
            print(f"warning: skipping feature with no '{args.code_field}' property", file=sys.stderr)
            continue
        if not geometry:
            print(f"warning: skipping {code}, no geometry", file=sys.stderr)
            continue
        code_sql = sql_escape(str(code))
        geom_expr = build_geom_expr(geometry, args.make_valid)
        up_statements.append(
            "-- +goose StatementBegin\n"
            "DO $$\n"
            "BEGIN\n"
            f"  IF NOT EXISTS (SELECT 1 FROM regions WHERE code = '{code_sql}') THEN\n"
            f"    RAISE EXCEPTION 'regions: unknown code % (seed migration missing this row)', '{code_sql}';\n"
            "  END IF;\n"
            "  UPDATE regions SET\n"
            f"    geom = {geom_expr},\n"
            "    updated_at = now()\n"
            f"  WHERE code = '{code_sql}';\n"
            "END $$;\n"
            "-- +goose StatementEnd\n"
        )
        codes.append(code_sql)

    if not up_statements:
        print("error: nothing to import", file=sys.stderr)
        return 1

    for code_sql in codes:
        down_statements.append(
            "-- +goose StatementBegin\n"
            f"UPDATE regions SET geom = NULL, updated_at = now() WHERE code = '{code_sql}';\n"
            "-- +goose StatementEnd\n"
        )

    header = (
        "-- +goose Up\n"
        f"-- Rasmiy GeoJSON import: {args.country} hududlari geom ustunini to'ldiradi.\n"
        f"-- Manba: {Path(args.input).name} (deploy/regions/README.md ko'rsatmasiga muvofiq olingan).\n"
        "-- Generatsiya qilingan: deploy/regions/geojson_to_migration.py. Qo'lda tahrirlamang —\n"
        "-- xato topilsa manba GeoJSON'ni tuzatib qayta generatsiya qiling va YANGI migratsiya yarating.\n"
    )
    footer = "\n-- +goose Down\n" + "\n".join(down_statements)

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(header + "\n" + "\n".join(up_statements) + footer + "\n", encoding="utf-8")
    print(f"wrote {out_path} ({len(codes)} region(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
