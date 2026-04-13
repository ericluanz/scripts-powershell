<#
.SYNOPSIS
    Script para criar Unidades Organizacionais no Active Directory
    
.DESCRIPTION
    Este script cria as OUs principais da estrutura: Usuarios, Grupos, Computadores
    e sub-OUs por departamento (TI, RH, Financeiro, Diretoria)
    
.EXAMPLE
    .\Setup-OUs.ps1
    
.AUTHOR
    Seu Nome
    
.DATE
    11/04/2026
    
.NOTES
    Requer permissões de administrador
    Requer Active Directory instalado
#>

# Verificar se está como admin
$isAdmin = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Este script requer permissões de administrador!" -ForegroundColor Red
    exit 1
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  CRIAÇÃO DE UNIDADES ORGANIZACIONAIS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

try {
    # Obter informações do domínio
    Write-Host "Obtendo informações do domínio..." -ForegroundColor Yellow
    $dominio = Get-ADDomain -ErrorAction Stop
    $dn = $dominio.DistinguishedName
    
    Write-Host "✓ Domínio: $($dominio.Name)" -ForegroundColor Green
    Write-Host "✓ DN: $dn" -ForegroundColor Green
    Write-Host ""
    
    # OUs principais
    $ousPrincipais = @("Usuarios", "Grupos", "Computadores")
    
    Write-Host "Criando OUs principais..." -ForegroundColor Yellow
    foreach ($ou in $ousPrincipais) {
        try {
            # Verificar se já existe
            $ouExistente = Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $dn -ErrorAction SilentlyContinue
            
            if ($ouExistente) {
                Write-Host "⚠️  OU '$ou' já existe" -ForegroundColor Yellow
            } else {
                New-ADOrganizationalUnit -Name $ou -Path $dn -ErrorAction Stop
                Write-Host "✓ OU '$ou' criada" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "❌ Erro ao criar OU '$ou': $_" -ForegroundColor Red
        }
    }
    
    # OUs por departamento
    $ousDepartamentos = @("TI", "RH", "Financeiro", "Diretoria")
    
    Write-Host ""
    Write-Host "Criando OUs por departamento..." -ForegroundColor Yellow
    foreach ($depart in $ousDepartamentos) {
        try {
            # Verificar se já existe
            $ouExistente = Get-ADOrganizationalUnit -Filter "Name -eq '$depart'" -SearchBase "OU=Usuarios,$dn" -ErrorAction SilentlyContinue
            
            if ($ouExistente) {
                Write-Host "⚠️  OU '$depart' já existe" -ForegroundColor Yellow
            } else {
                New-ADOrganizationalUnit -Name $depart -Path "OU=Usuarios,$dn" -ErrorAction Stop
                Write-Host "✓ OU '$depart' criada" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "❌ Erro ao criar OU '$depart': $_" -ForegroundColor Red
        }
    }
    
    # Listar OUs criadas
    Write-Host ""
    Write-Host "Estrutura de OUs criada:" -ForegroundColor Cyan
    Get-ADOrganizationalUnit -Filter * -SearchBase $dn | Select-Object Name, DistinguishedName | Format-Table -AutoSize
    
    Write-Host ""
    Write-Host "✓ OUs criadas com sucesso!" -ForegroundColor Green
    
}
catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✓ Script finalizado com sucesso!" -ForegroundColor Green
