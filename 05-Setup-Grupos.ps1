<#
.SYNOPSIS
    Script para criar grupos de segurança no Active Directory
    
.DESCRIPTION
    Este script cria grupos de segurança por departamento e adiciona membros
    
.EXAMPLE
    .\Setup-Grupos.ps1
    
.NOTES
    Requer permissões de administrador
    Requer Active Directory com usuários configurados
#>

# Verificar se está como admin
$isAdmin = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Este script requer permissões de administrador!" -ForegroundColor Red
    exit 1
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  CRIAÇÃO DE GRUPOS DE SEGURANÇA" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

try {
    # Obter domínio
    $dominio = Get-ADDomain -ErrorAction Stop
    $dn = $dominio.DistinguishedName
    
    Write-Host "✓ Domínio: $($dominio.Name)" -ForegroundColor Green
    Write-Host ""
    
    # Definir grupos
    $grupos = @(
        @{ Nome = "GRP-TI"; Desc = "Grupo de Profissionais de TI" },
        @{ Nome = "GRP-RH"; Desc = "Grupo de Recursos Humanos" },
        @{ Nome = "GRP-Finance"; Desc = "Grupo de Financeiro" },
        @{ Nome = "GRP-Admin"; Desc = "Grupo de Administradores" },
        @{ Nome = "GRP-Diretoria"; Desc = "Grupo de Diretoria" },
        @{ Nome = "GRP-Usuarios"; Desc = "Grupo de Usuários Padrão" }
    )
    
    Write-Host "Criando grupos..." -ForegroundColor Yellow
    Write-Host ""
    
    # Criar grupos
    foreach ($grupo in $grupos) {
        try {
            # Verificar se já existe
            $grupoExistente = Get-ADGroup -Filter "Name -eq '$($grupo.Nome)'" -ErrorAction SilentlyContinue
            
            if ($grupoExistente) {
                Write-Host "⚠️  Grupo '$($grupo.Nome)' já existe" -ForegroundColor Yellow
            } else {
                New-ADGroup `
                    -Name $grupo.Nome `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Description $grupo.Desc `
                    -Path "OU=Grupos,$dn" `
                    -ErrorAction Stop
                
                Write-Host "✓ Grupo '$($grupo.Nome)' criado" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "❌ Erro ao criar grupo '$($grupo.Nome)': $_" -ForegroundColor Red
        }
    }
    
    # Adicionar membros aos grupos
    Write-Host ""
    Write-Host "Adicionando membros aos grupos..." -ForegroundColor Yellow
    Write-Host ""
    
    $atribuicoes = @(
        @{ Grupo = "GRP-TI"; Membros = @("joao.silva", "carlos.oliveira", "pedro.gomes") },
        @{ Grupo = "GRP-RH"; Membros = @("maria.santos", "fernanda.rodrigues") },
        @{ Grupo = "GRP-Finance"; Membros = @("ana.costa") },
        @{ Grupo = "GRP-Admin"; Membros = @("Administrator") },
        @{ Grupo = "GRP-Usuarios"; Membros = @("joao.silva", "maria.santos", "carlos.oliveira", "ana.costa", "pedro.gomes", "fernanda.rodrigues") }
    )
    
    foreach ($atrib in $atribuicoes) {
        try {
            Write-Host "  Grupo: $($atrib.Grupo)" -ForegroundColor Cyan
            
            foreach ($membro in $atrib.Membros) {
                try {
                    Add-ADGroupMember -Identity $atrib.Grupo -Members $membro -ErrorAction SilentlyContinue
                    Write-Host "    ✓ $membro adicionado" -ForegroundColor Green
                }
                catch {
                    Write-Host "    ❌ Erro ao adicionar $membro" -ForegroundColor Red
                }
            }
        }
        catch {
            Write-Host "  ❌ Erro ao processar grupo $($atrib.Grupo): $_" -ForegroundColor Red
        }
    }
    
    # Listar grupos
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Grupos criados:" -ForegroundColor Cyan
    Get-ADGroup -Filter * | Select-Object Name, GroupScope, GroupCategory | Format-Table -AutoSize
    
}
catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✓ Script finalizado com sucesso!" -ForegroundColor Green
