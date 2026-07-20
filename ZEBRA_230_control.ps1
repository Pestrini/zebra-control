# printer_panel_control.ps1
Clear-Host
Write-Host "============================================================="
Write-Host "  Controle do Painel - Impressoras Zebra (porta 9100)"
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

do {
    Clear-Host
    Write-Host "=== MENU PRINCIPAL ===" -ForegroundColor Cyan
    Write-Host "1) Desabilitar botão FEED (temporário ou permanente)"
    Write-Host "2) Habilitar botão FEED (temporário ou permanente)"
    Write-Host "3) Calibrar mídia (usuário comum)"
    Write-Host "4) Sair"
    Write-Host ""

    $choice = Read-Host "Selecione uma opção (1-4)"

    switch ($choice) {
        "1" {
            $acao = "Desabilitar botão FEED (^MPF)"
            $commandCore = "^MPF"
        }
        "2" {
            $acao = "Habilitar botão FEED (^MPE)"
            $commandCore = "^MPE"
        }
        "3" {
            $acao = "Calibrar mídia (~JC)"
            $commandCore = "~JC"
        }
        "4" {
            Write-Host "`nSaindo..." -ForegroundColor Yellow
            break
        }
        default {
            Write-Host "`nOpção inválida. Tente novamente." -ForegroundColor Red
            Start-Sleep -Seconds 1.5
            continue
        }
    }

    if ($choice -eq "4") { break }

    $ip = Read-Host "`nDigite o IP da impressora (ex: 192.168.1.100)"
    if ([string]::IsNullOrWhiteSpace($ip)) {
        Write-Host "IP inválido. Retornando ao menu..." -ForegroundColor Red
        Start-Sleep -Seconds 1.5
        continue
    }

    if (-not ($ip -match '^\d{1,3}(\.\d{1,3}){3}$')) {
        Write-Host "Formato de IP suspeito. Deseja continuar? (S/N)"
        $confirma = Read-Host
        if ($confirma.Trim().ToUpper() -ne "S") { continue }
    }

    if ($choice -in "1","2") {
        $saveAns = Read-Host "Salvar permanentemente na NVRAM? (S/N)"
        $saveAns = $saveAns.Trim().ToUpper()
        $doSave = ($saveAns -eq "S" -or $saveAns -eq "Y")

        if ($doSave) {
            $payload = "^XA`n$commandCore`n^JUS`n^XZ"
        } else {
            $payload = "^XA`n$commandCore`n^XZ"
        }

        Write-Host "`nEnviando [$acao] para ${ip}..." -ForegroundColor Yellow
        $client = $null; $stream = $null; $writer = $null
        try {
            $client = New-Object System.Net.Sockets.TcpClient
            $client.Connect($ip, 9100)
            $stream = $client.GetStream()
            $writer = New-Object System.IO.StreamWriter($stream, [System.Text.Encoding]::ASCII)
            $writer.NewLine = "`n"
            $writer.Write($payload)
            $writer.Flush()
            Write-Host "Comando enviado com sucesso para ${ip}." -ForegroundColor Green
        } catch {
            Write-Host "Falha ao conectar/enviar para ${ip}: $($_.Exception.Message)" -ForegroundColor Red
        } finally {
            if ($writer) { $writer.Close() }
            if ($stream)  { $stream.Close()  }
            if ($client)  { $client.Close()  }
        }

        Write-Host ""
        Write-Host "Verificação recomendada:" -ForegroundColor Yellow
        Write-Host "  - Teste o botão FEED conforme a opção escolhida."
        Write-Host "  - Se salvou permanentemente, desligue e ligue a impressora e teste novamente."
    }
    elseif ($choice -eq "3") {
    $payload = "~JC`n~PS`n"  # calibra e já despausa
    Write-Host "`nEnviando comando de calibração (~JC) e despausar (~PS) para ${ip}..." -ForegroundColor Yellow

    $client = $null; $stream = $null; $writer = $null
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $client.Connect($ip, 9100)
        $stream = $client.GetStream()
        $writer = New-Object System.IO.StreamWriter($stream, [System.Text.Encoding]::ASCII)
        $writer.NewLine = "`n"
        $writer.Write($payload)
        $writer.Flush()
        Write-Host "Comando de calibração e despausar enviado com sucesso para ${ip}." -ForegroundColor Green
        Write-Host "A impressora deve executar a calibração (2 piscadas do botão FEED e avanço de mídia)." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao enviar calibração/despausar para ${ip}: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        if ($writer) { $writer.Close() }
        if ($stream)  { $stream.Close()  }
        if ($client)  { $client.Close()  }
    }

    Write-Host ""
    Write-Host "Se não ocorrer calibração, verifique:" -ForegroundColor Yellow
    Write-Host "  - Conectividade de rede (ping)"
    Write-Host "  - Impressora ligada e aceitando porta 9100"
    Write-Host "  - Mídia e sensores livres de obstrução"
}


    Write-Host ""
    Write-Host "Pressione ENTER para voltar ao menu..." -ForegroundColor Cyan
    [void][System.Console]::ReadLine()
}
while ($true)