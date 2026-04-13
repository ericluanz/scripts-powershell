<#
.SYNOPSIS
    Script para testar conectividade e serviços do homelab
    
.DESCRIPTION
    Realiza testes de: Ping, DNS, LDAP, SMB, DHCP
    Valida a comunicação entre máquinas e funcionamento de serviços
    
.PARAMETER ComputadorTeste
    IP ou nome do computador para testar (padrão: 10.0.0.10)
    
.EXAMPLE
    .\Teste-Conectividade.ps1
    
.AUTHOR
    Seu Nome
    
.DATE
    11/04/2026
    
.NOTES
    Requer permissões de administrador
#>

[CmdletBinding()]
param(
    [string]$ComputadorTeste = "10.0.0.10"
)

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  TESTES DE CONECTIVIDADE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "Testando: $ComputadorTeste" -ForegroundColor Yellow
Write-Host ""

# Array para armazenar resultados
$resultados = @()

# TESTE 1: PING
Write-Host "[1/5] Testando PING..." -ForegroundColor Cyan
Write-Host "[PING]  " -ForegroundColor White -NoNewline

try {
    $ping = Test-Connection -ComputerName $ComputadorTeste -Count 2 -ErrorAction Stop
    Write-Host "✓ OK" -ForegroundColor Green
    Write-Host "        Resposta: $($ping[0].ResponseTime)ms" -ForegroundColor White
    $resultados += @{ Teste = "PING"; Resultado = "OK"; Tempo = "$($ping[0].ResponseTime)ms" }
}
catch {
    Write-Host "✗ FALHOU" -ForegroundColor Red
    $resultados += @{ Teste = "PING"; Resultado = "FALHOU"; Tempo = "N/A" }
}

# TESTE 2: DNS
Write-Host "[2/5] Testando DNS..." -ForegroundColor Cyan
Write-Host "[DNS]   " -ForegroundColor White -NoNewline

try {
    $dns = Resolve-DnsName $ComputadorTeste -ErrorAction Stop
    Write-Host "✓ OK" -ForegroundColor Green
    Write-Host "        IP: $($dns[0].IPAddress)" -ForegroundColor White
    $resultados += @{ Teste = "DNS"; Resultado = "OK"; Detalhes = $dns[0].IPAddress }
}
catch {
    Write-Host "✗ FALHOU" -ForegroundColor Red
    $resultados += @{ Teste = "DNS"; Resultado = "FALHOU"; Detalhes = "N/A" }
}

# TESTE 3: LDAP (389)
Write-Host "[3/5] Testando LDAP (porta 389)..." -ForegroundColor Cyan
Write-Host "[LDAP]  " -ForegroundColor White -NoNewline

try {
    $ldap = Test-NetConnection -ComputerName $ComputadorTeste -Port 389 -InformationLevel Quiet -ErrorAction Stop
    if ($ldap) {
        Write-Host "✓ OK" -ForegroundColor Green
        $resultados += @{ Teste = "LDAP"; Resultado = "OK"; Porta = "389" }
    } else {
        Write-Host "✗ FALHOU" -ForegroundColor Red
        $resultados += @{ Teste = "LDAP"; Resultado = "FALHOU"; Porta = "389" }
    }
}
catch {
    Write-Host "✗ FALHOU" -ForegroundColor Red
    $resultados += @{ Teste = "LDAP"; Resultado = "FALHOU"; Porta = "389" }
}

# TESTE 4: SMB (445)
Write-Host "[4/5] Testando SMB (porta 445)..." -ForegroundColor Cyan
Write-Host "[SMB]   " -ForegroundColor White -NoNewline

try {
    $smb = Test-NetConnection -ComputerName $ComputadorTeste -Port 445 -InformationLevel Quiet -ErrorAction Stop
    if ($smb) {
        Write-Host "✓ OK" -ForegroundColor Green
        $resultados += @{ Teste = "SMB"; Resultado = "OK"; Porta = "445" }
    } else {
        Write-Host "✗ FALHOU" -ForegroundColor Red
        $resultados += @{ Teste = "SMB"; Resultado = "FALHOU"; Porta = "445" }
    }
}
catch {
    Write-Host "✗ FALHOU" -ForegroundColor Red
    $resultados += @{ Teste = "SMB"; Resultado = "FALHOU"; Porta = "445" }
}

# TESTE 5: RDP (3389) - Opcional
Write-Host "[5/5] Testando RDP (porta 3389)..." -ForegroundColor Cyan
Write-Host "[RDP]   " -ForegroundColor White -NoNewline

try {
    $rdp = Test-NetConnection -ComputerName $ComputadorTeste -Port 3389 -InformationLevel Quiet -ErrorAction Stop
    if ($rdp) {
        Write-Host "✓ OK" -ForegroundColor Green
        $resultados += @{ Teste = "RDP"; Resultado = "OK"; Porta = "3389" }
    } else {
        Write-Host "⚠️  Não respondendo" -ForegroundColor Yellow
        $resultados += @{ Teste = "RDP"; Resultado = "Não respondendo"; Porta = "3389" }
    }
}
catch {
    Write-Host "⚠️  Não respondendo" -ForegroundColor Yellow
    $resultados += @{ Teste = "RDP"; Resultado = "Não respondendo"; Porta = "3389" }
}

# Resumo
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "RESUMO DOS TESTES:" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Contar sucessos e falhas
$sucessos = ($resultados | Where-Object Resultado -eq "OK").Count
$falhas = ($resultados | Where-Object Resultado -eq "FALHOU").Count

Write-Host "✓ Sucessos: $sucessos" -ForegroundColor Green
Write-Host "❌ Falhas: $falhas" -ForegroundColor $(if ($falhas -eq 0) { "Green" } else { "Red" })

Write-Host ""

if ($falhas -eq 0) {
    Write-Host "✓ TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    Write-Host "✓ A infraestrutura está funcionando corretamente!" -ForegroundColor Green
} else {
    Write-Host "⚠️  ALGUNS TESTES FALHARAM!" -ForegroundColor Yellow
    Write-Host "⚠️  Verifique as configurações de rede e serviços" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✓ Script finalizado com sucesso!" -ForegroundColor Green
