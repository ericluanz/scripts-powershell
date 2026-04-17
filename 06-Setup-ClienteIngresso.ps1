<#
.SYNOPSIS
    Script para ingressar máquina cliente no domínio
    
.DESCRIPTION
    Este script configura DNS e ingresa a máquina cliente no domínio corporativo
    Requer reboot após execução
    
.PARAMETER DomainName
    Nome do domínio (padrão: empresa.local)
    
.PARAMETER DomainServer
    IP do servidor de domínio (padrão: 10.0.0.10)
    
.EXAMPLE
    .\Setup-ClienteIngresso.ps1
    
.NOTES
    Requer permissões de administrador
    Máquina será reiniciada
#>

[CmdletBinding()]
param(
    [string]$DomainName = "empresa.local",
    [string]$DomainServer = "10.0.0.10"
)

# Verificar se está como admin
$isAdmin = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Este script requer permissões de administrador!" -ForegroundColor Red
    exit 1
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  INGRESSO NO DOMÍNIO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

try {
    # Exibir informações
    Write-Host "Informações:" -ForegroundColor Yellow
    Write-Host "  Domínio: $DomainName" -ForegroundColor White
    Write-Host "  Servidor AD: $DomainServer" -ForegroundColor White
    Write-Host ""
    
    # Configurar DNS
    Write-Host "Configurando DNS..." -ForegroundColor Yellow
    
    # Obter adaptador de rede ativo
    $adapter = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -First 1
    
    if (-not $adapter) {
        Write-Host "❌ Nenhum adaptador de rede ativo encontrado!" -ForegroundColor Red
        exit 1
    }
    
    $interfaceIndex = $adapter.IfIndex
    Write-Host "✓ Adaptador: $($adapter.Name)" -ForegroundColor Green
    
    # Configurar DNS
    Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses $DomainServer -ErrorAction Stop
    Write-Host "✓ DNS configurado para: $DomainServer" -ForegroundColor Green
    
    # Testar conectividade
    Write-Host ""
    Write-Host "Testando conectividade com servidor de domínio..." -ForegroundColor Yellow
    
    if (Test-Connection -ComputerName $DomainServer -Count 2 -ErrorAction SilentlyContinue) {
        Write-Host "✓ Servidor alcançável" -ForegroundColor Green
    } else {
        Write-Host "❌ Não foi possível alcançar o servidor" -ForegroundColor Red
        Write-Host "⚠️  Verifique a configuração de rede e tente novamente" -ForegroundColor Yellow
        exit 1
    }
    
    # Pedir credenciais do domínio
    Write-Host ""
    Write-Host "Credenciais necessárias:" -ForegroundColor Yellow
    $credenciais = Get-Credential -Message "Digite as credenciais de administrador do domínio"
    
    if (-not $credenciais) {
        Write-Host "❌ Credenciais não fornecidas" -ForegroundColor Red
        exit 1
    }
    
    # Ingressar no domínio
    Write-Host ""
    Write-Host "Ingressando no domínio..." -ForegroundColor Yellow
    
    Add-Computer -DomainName $DomainName -Credential $credenciais -Force -ErrorAction Stop
    
    Write-Host "✓ Máquina ingressada com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️  A máquina será REINICIADA!" -ForegroundColor Yellow
    Write-Host ""
    
    # Confirmar reboot
    $reboot = Read-Host "Deseja reiniciar agora? (S/N)"
    
    if ($reboot -eq "S" -or $reboot -eq "s") {
        Write-Host "Reiniciando..." -ForegroundColor Yellow
        Restart-Computer -Force
    } else {
        Write-Host "⚠️  Reinicie manualmente para aplicar as mudanças" -ForegroundColor Yellow
    }
    
}
catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
    exit 1
}
