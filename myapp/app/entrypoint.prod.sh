#!/bin/sh
echo "sleeping for 10 seconds......."
sleep 10;
cd /app/src/
echo "Running migrations"
alembic upgrade head
echo "Starting server"
cd /app/
uvicorn src.main:app --host 0.0.0.0 --port 8000