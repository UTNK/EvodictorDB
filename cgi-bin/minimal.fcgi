#!/bin/bash

export PYTHONPATH=/usr/proj/evodictordb/minimal
cd /usr/proj/evodictordb/minimal

exec /usr/local/package/python/3.12.0/bin/python run_fcgi.py
