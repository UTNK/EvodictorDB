#!/bin/bash

export PYTHONPATH=/usr/proj/evodictordb/flask_app
cd /usr/proj/evodictordb/flask_app

exec /usr/local/package/python/3.12.0/bin/python run_fcgi.py
