#!/bin/bash

LOG="/tmp/taxonium_fcgi.log"
exec >> "$LOG" 2>&1

echo "=== $(date): TaxoniumPhylomap CGI started ==="
export PYTHONPATH=/usr/proj/evodictordb/TaxoniumPhylomap
cd /usr/proj/evodictordb/TaxoniumPhylomap
echo "Launching run_fcgi.py..."

exec /usr/local/package/python/3.12.0/bin/python run_fcgi.py
