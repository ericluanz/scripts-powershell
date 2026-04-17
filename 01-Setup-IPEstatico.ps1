<#
.SYNOPSIS
    Script para configurar IP estático no servidor Windows
    
.DESCRIPTION
    Este script configura um endereço IP estático, gateway padrão e servidores DNS
    em uma interface de rede específica no Windows Server 2022.
    
.PARAMETER InterfaceIndex
    O índice da interface de rede a ser configurada
    
.PARAMETER IPAddress
    Endereço IP a ser configurado (padrão: 10.0.0.10)
    
.PARAMETER PrefixLength
    Máscara de rede em notação CIDR (padrão: 24 = 255.255.255.0)
    
.PARAMETER DefaultGateway
    Gateway padrão (padrão: 10.0.0.1)
    
.PARAMETER DNSServers
    Servidores DNS (padrão: 10.0.0.10)
    
.EXAMPLE
    .\Setup-IPEstatico.ps1
    
.NOTES
    Requer permissões de administrador
#>

[CmdletBinding()]
param(
    [int]$InterfaceIndex = -1,
    [string]$IPAddress = "10.0.0.10",
    [int]$PrefixLength = 24,
    [string]$DefaultGateway = "10.0.0.1",
    [string[]]$DNSServers = @("10.0.0.10")
)

# Verificar se está como admin
$isAdmin = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Este script requer permissões de administrador!" -ForegroundColor Red
    exit 1
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  CONFIGURAÇÃO DE IP ESTÁTICO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

try {
    # Listar adaptadores disponíveis
    Write-Host "Adaptadores de rede disponíveis:" -ForegroundColor Yellow
    $adapters = Get-NetAdapter | Where-Object Status -eq "Up"
    
    if ($adapters.Count -eq 0) {
        Write-Host "❌ Nenhum adaptador ativo encontrado!" -ForegroundColor Red
        exit 1
    }
    
    foreach ($adapter in $adapters) {
        Write-Host "  - $($adapter.Name) (Índice: $($adapter.IfIndex)) - $($adapter.InterfaceDescription)" -ForegroundColor White
    }
    Write-Host ""
    
    # Usar o primeiro adaptador se não especificado
    if ($InterfaceIndex -eq -1) {
        $InterfaceIndex = $adapters[0].IfIndex
        Write-Host "Usando adaptador padrão: $($adapters[0].Name)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Configurando..." -ForegroundColor Yellow
    Write-Host "  IP: $IPAddress/$PrefixLength" -ForegroundColor White
    Write-Host "  Gateway: $DefaultGateway" -ForegroundColor White
    Write-Host "  DNS: $($DNSServers -join ', ')" -ForegroundColor White
    Write-Host ""
    
    # Remover configurações anteriores
    Write-Host "Removendo configurações anteriores..." -ForegroundColor Yellow
    Remove-NetIPAddress -InterfaceIndex $InterfaceIndex -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceIndex $InterfaceIndex -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
    
    # Configurar novo IP
    Write-Host "Configurando novo IP..." -ForegroundColor Yellow
    New-NetIPAddress -InterfaceIndex $InterfaceIndex -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway -ErrorAction Stop
    
    # Configurar DNS
    Write-Host "Configurando DNS..." -ForegroundColor Yellow
    Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses $DNSServers -ErrorAction Stop
    
    Write-Host ""
    Write-Host "✓ IP estático configurado com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Configuração final:" -ForegroundColor Cyan
    Get-NetIPAddress -InterfaceIndex $InterfaceIndex -AddressFamily IPv4 | Format-Table
    Get-DnsClientServerAddress -InterfaceIndex $InterfaceIndex | Format-Table
    
}
catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✓ Script finalizado com sucesso!" -ForegroundColor Green
