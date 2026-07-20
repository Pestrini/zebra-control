@echo off
:: ---------------------------------------------------------------
:: Calibrar Impressora Zebra - Execução direta (sem pedir IP)
:: ---------------------------------------------------------------

:: Defina o IP fixo da impressora aqui:
set "PRINTER_IP=10.133.3.14"

echo Calibrando impressora Zebra no IP %PRINTER_IP% ...
powershell -ExecutionPolicy Bypass -NoLogo -NoProfile ^
    -Command "$ip='%PRINTER_IP%'; $nl=[Environment]::NewLine; $payload='~JC' + $nl + '~PS' + $nl; try{$client=New-Object System.Net.Sockets.TcpClient; $client.Connect($ip,9100); $stream=$client.GetStream(); $writer=New-Object System.IO.StreamWriter($stream,[System.Text.Encoding]::ASCII); $writer.NewLine='`n'; $writer.Write($payload); $writer.Flush(); Write-Host 'Comando de calibração (e retomada) enviado com sucesso para' $ip -ForegroundColor Green} catch {Write-Host 'Falha ao conectar/enviar para' $ip ':' $_.Exception.Message -ForegroundColor Red} finally {if($writer){$writer.Close()}; if($stream){$stream.Close()}; if($client){$client.Close()}}; Write-Host 'Observe a impressora: 2 piscadas e avanço de mídia indicam calibração concluída.' -ForegroundColor Yellow; Read-Host 'Pressione ENTER para sair.'"