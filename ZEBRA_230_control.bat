@echo off
title Controle do Painel - Impressoras Zebra
color 0B

:MENU
cls
echo =============================================================
echo   Controle do Painel - Impressoras Zebra (porta 9100)
echo =============================================================
echo.
echo  1) Desabilitar botao FEED (temporario ou permanente)
echo  2) Habilitar botao FEED (temporario ou permanente)
echo  3) Calibrar midia e despausar (~JC + ~PS)
echo  4) Sair
echo.

set /p escolha="Selecione uma opcao (1-4): "
if "%escolha%"=="1" goto DISABLE_FEED
if "%escolha%"=="2" goto ENABLE_FEED
if "%escolha%"=="3" goto CALIBRAR
if "%escolha%"=="4" goto SAIR
goto MENU

:: ============================================================
:ASK_IP
echo.
set /p IP="Digite o IP da impressora (ex: 192.168.1.100): "
if "%IP%"=="" (
    echo IP invalido.
    timeout /t 2 >nul
    goto MENU
)
goto :eof

:: ============================================================
:DISABLE_FEED
call :ASK_IP
echo.
set /p SAVE="Salvar permanentemente na NVRAM (S/N)? "
set "SAVE=%SAVE:~0,1%"
set "SAVE=%SAVE:"=%"
if /I "%SAVE%"=="S" (
    set "PAYLOAD=^XA`n^MPF`n^JUS`n^XZ"
) else (
    set "PAYLOAD=^XA`n^MPF`n^XZ"
)
echo Enviando comando para %IP% ...
powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -Command ^
"$ip='%IP%'; $payload='%PAYLOAD%'; try{$c=New-Object System.Net.Sockets.TcpClient;$c.Connect($ip,9100);$s=$c.GetStream();$w=New-Object System.IO.StreamWriter($s,[System.Text.Encoding]::ASCII);$w.NewLine='`n';$w.Write($payload);$w.Flush();Write-Host 'Comando enviado com sucesso para' $ip -ForegroundColor Green}catch{Write-Host 'Falha ao conectar/enviar para' $ip ':' $_.Exception.Message -ForegroundColor Red}finally{if($w){$w.Close()};if($s){$s.Close()};if($c){$c.Close()}}"
echo.
echo Verifique o botao FEED. Se salvou permanentemente, reinicie a impressora.
pause
goto MENU

:: ============================================================
:ENABLE_FEED
call :ASK_IP
echo.
set /p SAVE="Salvar permanentemente na NVRAM (S/N)? "
set "SAVE=%SAVE:~0,1%"
set "SAVE=%SAVE:"=%"
if /I "%SAVE%"=="S" (
    set "PAYLOAD=^XA`n^MPE`n^JUS`n^XZ"
) else (
    set "PAYLOAD=^XA`n^MPE`n^XZ"
)
echo Enviando comando para %IP% ...
powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -Command ^
"$ip='%IP%'; $payload='%PAYLOAD%'; try{$c=New-Object System.Net.Sockets.TcpClient;$c.Connect($ip,9100);$s=$c.GetStream();$w=New-Object System.IO.StreamWriter($s,[System.Text.Encoding]::ASCII);$w.NewLine='`n';$w.Write($payload);$w.Flush();Write-Host 'Comando enviado com sucesso para' $ip -ForegroundColor Green}catch{Write-Host 'Falha ao conectar/enviar para' $ip ':' $_.Exception.Message -ForegroundColor Red}finally{if($w){$w.Close()};if($s){$s.Close()};if($c){$c.Close()}}"
echo.
echo O botao FEED deve ter sido reabilitado.
pause
goto MENU

:: ============================================================
:CALIBRAR
call :ASK_IP
echo.
echo Enviando comando de calibracao (~JC) e despausar (~PS) para %IP% ...
powershell -ExecutionPolicy Bypass -NoLogo -NoProfile -Command ^
"$ip='%IP%'; $payload='~JC`n~PS`n'; try{$c=New-Object System.Net.Sockets.TcpClient;$c.Connect($ip,9100);$s=$c.GetStream();$w=New-Object System.IO.StreamWriter($s,[System.Text.Encoding]::ASCII);$w.NewLine='`n';$w.Write($payload);$w.Flush();Write-Host 'Comando de calibracao e despausar enviado com sucesso para' $ip -ForegroundColor Green;Write-Host 'A impressora deve executar a calibracao (2 piscadas do botao FEED e avancar midia).' -ForegroundColor Green}catch{Write-Host 'Erro ao enviar calibracao/despausar para' $ip ':' $_.Exception.Message -ForegroundColor Red}finally{if($w){$w.Close()};if($s){$s.Close()};if($c){$c.Close()}}"
echo.
echo Se nao ocorrer calibracao:
echo   - Verifique conectividade de rede (ping)
echo   - Impressora ligada e aceitando porta 9100
echo   - Midia e sensores livres de obstrucao
pause
goto MENU

:: ============================================================
:SAIR
echo.
echo Saindo...
timeout /t 1 >nul
exit
