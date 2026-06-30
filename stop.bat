@echo off

echo Stopping llama-server...
taskkill /FI "WINDOWTITLE eq llama-server" /F >nul 2>&1

echo Stopping Caddy...
taskkill /FI "WINDOWTITLE eq caddy" /F >nul 2>&1

echo Stopping ngrok...
taskkill /FI "WINDOWTITLE eq ngrok" /F >nul 2>&1

echo Done.

pause