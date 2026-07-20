# calibrar_impressora.ps1
# Script simples para enviar comando de calibração (~JC) para impressora Zebra via porta 9100.
# Pode ser executado por usuário comum (não precisa ser admin na maioria dos ambientes).

Clear-Host
Write-Host "Calibração de mídia - Impressora Zebra" -ForegroundColor Cyan
Write-Host "--------------------------------------------------"

# Ler IP
$ip = Read-Host "Digite o IP da impressora (ex: 192.168.1.100)"
if ([string]::IsNullOrWhiteSpace($ip)) {
    Write-Host "IP inválido. Saindo..." -ForegroundColor Red
    exit 1
}

# (opcional) validação simples
if (-not ($ip -match '^\d{1,3}(\.\d{1,3}){3}$')) {
    Write-Host "Formato de IP aparentemente inválido. Deseja continuar mesmo assim? (S/N)"
    $c = Read-Host
    if ($c.Trim().ToUpper() -ne "S") {
        Write-Host "Abortando." -ForegroundColor Yellow
        exit 1
    }
}

# Monta comando de calibração
$command = "~JC"   # comando ZPL para calibração do sensor de mídia
# adiciona quebra de linha para garantir entrega adequada
$payload = "${command}`n"

Write-Host ""
Write-Host "Enviando comando de calibração para $ip: $command" -ForegroundColor Yellow

$client = $null
$stream = $null
$writer = $null
try {
    $client = New-Object System.Net.Sockets.TcpClient
    $client.Connect($ip, 9100)
    $stream = $client.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream, [System.Text.Encoding]::ASCII)
    $writer.NewLine = "`n"
    $writer.Write($payload)
    $writer.Flush()

    Write-Host ""
    Write-Host "Comando enviado com sucesso para $ip." -ForegroundColor Green
    Write-Host "A impressora deve iniciar a calibração (observe aproximadamente 2 piscadas do botão FEED e movimentação do rolo)." -ForegroundColor Green
    Write-Host ""
    Write-Host "Se a impressora não reagir:" -ForegroundColor Yellow
    Write-Host "  - Verifique conectividade de rede (ping)." 
    Write-Host "  - Verifique se a impressora está ligada e configurada para aceitar dados na porta 9100."
    Write-Host "  - Verifique se a impressora não está com erro de falta de mídia ou cobertura do sensor."
}
catch {
    Write-Host ""
    Write-Host "Falha ao conectar/enviar para ${ip}: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Verifique rede/IP e tente novamente." -ForegroundColor Red
}
finally {
    if ($writer) { $writer.Close() }
    if ($stream)  { $stream.Close()  }
    if ($client)  { $client.Close() }
}

Write-Host ""
Write-Host "Pressione ENTER para sair..." -ForegroundColor Cyan
[void][System.Console]::ReadLine()