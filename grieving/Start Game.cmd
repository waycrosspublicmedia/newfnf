@echo off
cd /d "%~dp0"
echo Open http://localhost:8000/ in your browser.
echo Keep this window open while playing.
python serve-local.py
pause
