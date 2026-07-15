@echo off
REM ============================================
REM  Multimedia Explorer - Setup ^& Start Script
REM  For Windows (CMD / PowerShell)
REM ============================================

echo.
echo ========================================
echo   Multimedia Explorer - Setup Script
echo ========================================
echo.

REM ---- Step 1: Check if bun is installed ----
echo [1/4] Checking for bun...
where bun >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: bun is not installed.
    echo.
    echo Install bun first:
    echo   powershell -c "irm bun.sh/install.ps1 ^| iex"
    echo.
    echo Or visit: https://bun.sh
    exit /b 1
)
echo   OK bun found
echo.

REM ---- Step 2: Install dependencies ----
echo [2/4] Installing dependencies...
if exist "node_modules" (
    echo   OK Dependencies already installed
) else (
    echo   Running bun install...
    bun install
    if %ERRORLEVEL% NEQ 0 (
        echo   ERROR: bun install failed
        exit /b 1
    )
    echo   OK Dependencies installed successfully
)
echo.

REM ---- Step 3: Create .env file if missing ----
echo [3/4] Checking environment configuration...
if exist ".env" (
    echo   OK .env file already exists
) else (
    if exist ".env.example" (
        copy .env.example .env >nul
        echo   OK Created .env from .env.example
    ) else (
        type nul > .env
        echo   OK Created empty .env file
    )
)
echo.

REM ---- Step 4: Start dev server ----
echo [4/4] Starting development server...
echo   Server will start at http://localhost:3000
echo   Press Ctrl+C to stop
echo.

REM Kill any existing next dev processes to avoid lock conflicts
taskkill /F /IM "next" >nul 2>&1
del /q .next\dev\lock >nul 2>&1

REM Open browser after a short delay (in background)
start /b cmd /c "timeout /t 3 /nobreak >nul && start http://localhost:3000"

REM Start the dev server
bun run dev
