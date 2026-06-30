@echo off
title AI Server

echo ============================================
echo Starting llama.cpp server...
echo ============================================

start "" llama-server -m models\models--Qwen--Qwen2.5-Coder-7B-Instruct-GGUF\snapshots\13fb94bfda8c8cf22497dc57b78f391a9acb426a\qwen2.5-coder-7b-instruct-q4_k_m-00001-of-00002.gguf --host 127.0.0.1 --port 8080 -c 4096 -t 8

echo Waiting for llama.cpp to start...
timeout /t 5 /nobreak >nul

echo ======================================
echo Starting Caddy...
echo ======================================

start "caddy" /MIN "%~dp0bin\caddy.exe" run --config "%~dp0configs\Caddyfile"

timeout /t 3 /nobreak >nul

echo.
echo ======================================
echo Starting ngrok...
echo ======================================

start "ngrok" "%~dp0bin\ngrok.exe" start --all --config "%~dp0configs\ngrok.yml"

echo.
echo ======================================
echo Server Started
echo.
echo llama.cpp : http://127.0.0.1:8080
echo Caddy     : http://127.0.0.1:8081
echo ngrok     : Public HTTPS
echo ======================================

pause