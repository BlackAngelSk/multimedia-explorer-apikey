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
echo [1/5] Checking for bun...
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
echo [2/5] Installing dependencies...
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

REM ---- Step 3: Auto-update from GitHub ----
echo [3/5] Checking for updates from GitHub...
set REPO_URL=https://github.com/BlackAngelSk/multimedia-explorer-apikey.git
if exist ".git" (
    git fetch origin >nul 2>&1
    for /f "tokens=*" %%a in ('git rev-parse HEAD') do set LOCAL=%%a
    for /f "tokens=*" %%a in ('git rev-parse origin/main 2^>nul') do set REMOTE=%%a
    if defined REMOTE (
        if not "%LOCAL%"=="%REMOTE%" (
            echo   New updates available. Pulling...
            git stash >nul 2>&1
            git pull origin main --quiet >nul 2>&1
            if %ERRORLEVEL% EQU 0 (
                echo   OK Updated to latest version
                echo   Running bun install after update...
                bun install >nul 2>&1
                echo   OK Dependencies updated
                git stash pop >nul 2>&1
            ) else (
                echo   ERROR Could not pull updates (merge conflict?)
                echo   Continuing with local version
                git stash pop >nul 2>&1
            )
        ) else (
            echo   OK Already up to date
        )
    ) else (
        echo   Could not check remote. Continuing with local version.
    )
) else (
    echo   WARNING: Not a git repository - skipping update
)
echo.

REM ---- Step 4: Create .env file if missing ----
echo [4/5] Checking environment configuration...
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

REM ---- Step 5: Start dev server ----
echo [5/5] Starting development server...
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
