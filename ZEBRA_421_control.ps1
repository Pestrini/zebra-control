# printer_panel_control.ps1
Clear-Host
Write-Host "============================================================="
Write-Host "  Controle do Painel - Impressoras Zebra (porta 9100)"
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

function Enviar-ZPL {
    param(
        [string]$ip,
        [string]$zpl,
        [bool]$salvar
    )

    if ($salvar) {
        $zpl = "^XA`n$zpl`n^JUS`n^XZ"
    } else {
        $zpl = "^XA`n$zpl`n^XZ"
    }

    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $client.Connect($ip, 9100)
        $stream = $client.GetStream()
        $writer = New-Object System.IO.StreamWriter($stream, [System.Text.Encoding]::ASCII)
        $writer.NewLine = "`n"
        $writer.Write($zpl)
        $writer.Flush()
        Write-Host "`nComando enviado com sucesso para $ip." -ForegroundColor Green
    }
    catch {
        Write-Host "Falha ao conectar/enviar para ${ip}: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        if ($writer) { $writer.Close() }
        if ($stream) { $stream.Close() }
        if ($client) { $client.Close() }
    }
}

do {
    Clear-Host
    Write-Host "=== MENU PRINCIPAL ===" -ForegroundColor Cyan
    Write-Host "1) Desabilitar botão FEED"
    Write-Host "2) Habilitar botão FEED"
    Write-Host "3) Bloquear reset de fábrica (3ª piscada do botão FEED)"
    Write-Host "4) Habilitar novamente reset de fábrica"
    Write-Host "5) Sair"
    Write-Host ""

    $choice = Read-Host "Selecione uma opção (1-5)"

    switch ($choice) {
        "1" {
            $acao = "Desabilitar botão FEED (^MPF)"
            $zplMode = "^MPF"
        }
        "2" {
            $acao = "Habilitar botão FEED (^MPE)"
            $zplMode = "^MPE"
        }
        "3" {
            $acao = "Bloquear Reset de Fábrica (^MPD)"
            $zplMode = "^MPD"
        }
        "4" {
            $acao = "Habilitar Reset de Fábrica (^MPE)"
            $zplMode = "^MPE"
        }
        "5" {
            Write-Host "`nSaindo..." -ForegroundColor Yellow
            break
        }
        default {
            Write-Host "`nOpção inválida. Tente novamente." -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }
    }

    if ($choice -eq "5") { break }

    Write-Host "`nAção selecionada: $acao" -ForegroundColor Cyan
    $ip = Read-Host "Digite o IP da impressora (ex: 192.168.1.100)"

    if ([string]::IsNullOrWhiteSpace($ip)) {
        Write-Host "IP inválido. Retornando ao menu..." -ForegroundColor Red
        Start-Sleep -Seconds 2
        continue
    }

    if (-not ($ip -match '^\d{1,3}(\.\d{1,3}){3}$')) {
        Write-Host "Formato de IP suspeito. Deseja continuar? (S/N)"
        $confirma = Read-Host
        if ($confirma.Trim().ToUpper() -ne "S") { continue }
    }

    $saveAns = Read-Host "Salvar permanentemente na NVRAM? (S/N)"
    $saveAns = $saveAns.Trim().ToUpper()
    $doSave = ($saveAns -eq "S" -or $saveAns -eq "Y")

    Enviar-ZPL -ip $ip -zpl $zplMode -salvar $doSave

    Write-Host ""
    Write-Host "Verificação recomendada:" -ForegroundColor Yellow
    Write-Host "  - Teste o botão FEED conforme a opção escolhida."
    Write-Host "  - Se bloqueou reset, segure até a 3ª piscada: o reset deve estar desativado."
    Write-Host "  - Se habilitou, o reset voltará a funcionar normalmente."
    Write-Host "  - Desligue e ligue a impressora se salvou na NVRAM."
    Write-Host ""
    Write-Host "Para confirmar o estado, envie '~WC' para imprimir a etiqueta de configuração."
    Write-Host ""
    $voltar = Read-Host "Pressione ENTER para voltar ao menu..."
}
while ($true)