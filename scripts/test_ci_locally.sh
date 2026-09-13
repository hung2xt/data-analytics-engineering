#!/bin/bash
# Test the CI dbt-build job locally against a throwaway database, without
# touching the real fox_dwh warehouse. Mirrors .github/workflows/ci.yml.
#
# Usage: run by hand, step by step (or `bash scripts/test_ci_locally.sh`).

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1. Create a throwaway database (owned by fox_dwh, separate from the real one)
psql -h 127.0.0.1 -p 5432 -U admin -d postgres \
  -c "drop database if exists ci_test_db;" \
  -c "create database ci_test_db owner fox_dwh;"

# 2. Load the same fixture data the GitHub Actions workflow loads
PGPASSWORD=fox_dwh psql -h 127.0.0.1 -p 5432 -U fox_dwh -d ci_test_db \
  -f "$PROJECT_DIR/ci/fixtures/enriched_orders_seed.sql"

DW_HOST=127.0.0.1 DW_PORT=5432 DW_USER=fox_dwh DW_PASSWORD=fox_dwh DW_DB=ci_test_db \
  python3 "$PROJECT_DIR/scripts/generate_policy_admin_source.py"

# 3. Run dbt build with DW_DB pointed at the throwaway database
cd "$PROJECT_DIR/dbt/fox_analytics"

export DBT_PROFILES_DIR="$PROJECT_DIR/dbt/fox_analytics"
export DW_HOST=127.0.0.1
export DW_PORT=5432
export DW_USER=fox_dwh
export DW_PASSWORD=fox_dwh
export DW_DB=ci_test_db
export DW_SCHEMA=analytical_engineer

dbt build

# 4. Cleanup — drops the throwaway database entirely, does NOT touch fox_dwh
psql -h 127.0.0.1 -p 5432 -U admin -d postgres -c "drop database if exists ci_test_db;"
