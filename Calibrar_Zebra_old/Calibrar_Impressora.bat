@echo off
:: ---------------------------------------------------------------
:: Calibrar Impressora Zebra - Executável direto para usuários
:: ---------------------------------------------------------------

:: Caminho do script PowerShell (ajuste se estiver em outro local)
set "SCRIPT_PATH=%~dp0calibrar_impressora.ps1"

:: Verifica se o PowerShell existe
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ERRO: PowerShell não encontrado neste computador.
    pause
    exit /b
)

:: Executa o script em modo bypass (sem precisar clicar com botão direito)
powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -File "%SCRIPT_PATH%"