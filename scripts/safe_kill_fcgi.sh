#!/bin/bash

# Usage: You just run this script (`$ /usr/proj/evodictordb/sh/safe_kill_fcgi.sh`). 
#        It will kill the existing FastCGI process and restart it.

# === Configuration (change as needed) ===

APP_NAME_LIST="EvodictorDB TaxoniumPhylomap minimal"

for APP_NAME in $APP_NAME_LIST; do

    #APP_NAME="TaxoniumPhylomap"
    PROJ_DIR="/usr/proj/evodictordb"
    FCGI_SCRIPT="$PROJ_DIR/cgi-bin/${APP_NAME}.fcgi"
    FCGI_PY="run_fcgi.py"
    LOG_FILE="/tmp/${APP_NAME}_fcgi_restart.log"

    # === Begin log ===
    echo "==== $(date): Restarting FastCGI for ${APP_NAME} ====" >> "$LOG_FILE"

    # === Find and kill existing FastCGI process ===
    PIDS=$(ps aux | grep w3evo | grep "$FCGI_PY" | grep -v grep | awk '{print $2}')

    if [ -z "$PIDS" ]; then
        echo "[INFO] No running $FCGI_PY processes found." >> "$LOG_FILE"
    else
        echo "[INFO] Killing the following PIDs: $PIDS" >> "$LOG_FILE"
        for pid in $PIDS; do
            kill -9 "$pid" && echo "[OK] Killed PID $pid" >> "$LOG_FILE"
        done
    fi

    # === Trigger restart by invoking the FastCGI script ===
    #echo "[INFO] Triggering restart via $FCGI_SCRIPT" >> "$LOG_FILE"
    #"$FCGI_SCRIPT"
    #echo "[DONE] Restart attempted." >> "$LOG_FILE"

done