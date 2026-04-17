<#
.SYNOPSIS
    Script para instalar e configurar Active Directory Domain Services
    
.DESCRIPTION
    Este script instala o AD Domain Services, cria uma floresta e domínio corporativo.
    Requer reboot após execução.
    
.PARAMETER DomainName
    Nome do domínio a ser criado padrão: empresa.local (mas pode alterar)
    
.EXAMPLE
    .\Setup-ActiveDirectory.ps1    
.NOTES
    Requer permissões de administrador
    Máquina será reiniciada após conclusão
#>

[CmdletBinding()]
param(
    [string]$DomainName = "empresa.local"
)

# Verificar se está como admin
$isAdmin = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Este script requer permissões de administrador!" -ForegroundColor Red
    exit 1
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  INSTALAÇÃO DO ACTIVE DIRECTORY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

try {
    # Verificar se AD já está instalado
    Write-Host "Verificando se AD já está instalado..." -ForegroundColor Yellow
    $adds = Get-WindowsFeature AD-Domain-Services -ErrorAction Stop
    
    if ($adds.Installed) {
        Write-Host "✓ Active Directory já está instalado!" -ForegroundColor Green
        
        $floresta = Get-ADForest -ErrorAction SilentlyContinue
        if ($floresta) {
            Write-Host "✓ Floresta encontrada: $($floresta.Name)" -ForegroundColor Green
            exit 0
        }
    }
    
    # Instalar AD Domain Services
    Write-Host ""
    Write-Host "Instalando AD Domain Services..." -ForegroundColor Yellow
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools -SkipNonRemovalTools -ErrorAction Stop
    
    # Importar módulo ADDSDeployment
    Write-Host "Importando módulos necessários..." -ForegroundColor Yellow
    Import-Module ADDSDeployment -ErrorAction Stop
    
    # Obter senha do modo seguro
    Write-Host ""
    Write-Host "Configurando nova floresta..." -ForegroundColor Yellow
    Write-Host "Domínio: $DomainName" -ForegroundColor White
    Write-Host ""
    
    $senhaSegura = Read-Host "Digite a senha do Modo Seguro" -AsSecureString
    
    Write-Host ""
    Write-Host "⚠️  A máquina será REINICIADA após a conclusão!" -ForegroundColor Yellow
    Write-Host ""
    
    $confirmacao = Read-Host "Deseja continuar? (S/N)"
    if ($confirmacao -ne "S" -and $confirmacao -ne "s") {
        Write-Host "Operação cancelada." -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host ""
    Write-Host "Instalando e configurando..." -ForegroundColor Yellow
    
    # Instalar AD Forest
    Install-ADDSForest `
        -DomainName $DomainName `
        -SafeModeAdministratorPassword $senhaSegura `
        -InstallDns:$true `
        -NoRebootOnCompletion:$false `
        -Force `
        -ErrorAction Stop
    
    Write-Host ""
    Write-Host "✓ Active Directory instalado com sucesso!" -ForegroundColor Green
    Write-Host "✓ A máquina será reiniciada agora..." -ForegroundColor Green
    
}
catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
    exit 1
}
