<#
.SYNOPSIS
    Script para fazer backup dos dados de Active Directory
    
.DESCRIPTION
    Este script exporta usuários, grupos e membros para arquivos CSV
    Os backups são salvos com timestamp em C:\Backups\
    
.PARAMETER BackupPath
    Caminho onde os backups serão salvos (padrão: C:\Backups)
    
.EXAMPLE
    .\Backup-AD.ps1
    
.NOTES
    Requer permissões de administrador
    Cria a pasta de backup se não existir
#>

[CmdletBinding()]
param(
    [string]$BackupPath = "C:\Backups"
)

# Verificar se está como admin
$isAdmin = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Este script requer permissões de administrador!" -ForegroundColor Red
    exit 1
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  BACKUP DO ACTIVE DIRECTORY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

try {
    # Criar pasta se não existir
    if (-not (Test-Path $BackupPath)) {
        Write-Host "Criando pasta de backup..." -ForegroundColor Yellow
        New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
    }
    
    Write-Host "✓ Pasta de backup: $BackupPath" -ForegroundColor Green
    
    # Gerar timestamp
    $data = Get-Date -Format "yyyy-MM-dd_HHmm"
    
    Write-Host ""
    Write-Host "Realizando backup..." -ForegroundColor Yellow
    Write-Host "  Timestamp: $data" -ForegroundColor White
    Write-Host ""
    
    # Backup de usuários
    Write-Host "Exportando usuários..." -ForegroundColor Yellow
    $usuarios = Get-ADUser -Filter * -Properties * | Select-Object Name, UserPrincipalName, EmailAddress, Department, Title, Enabled, Created
    $usuarios | Export-Csv -Path "$BackupPath\Usuarios_$data.csv" -Encoding UTF8 -NoTypeInformation -ErrorAction Stop
    Write-Host "✓ Usuários exportados: $($usuarios.Count)" -ForegroundColor Green
    
    # Backup de grupos
    Write-Host "Exportando grupos..." -ForegroundColor Yellow
    $grupos = Get-ADGroup -Filter * -Properties * | Select-Object Name, GroupScope, GroupCategory, Description, Created
    $grupos | Export-Csv -Path "$BackupPath\Grupos_$data.csv" -Encoding UTF8 -NoTypeInformation -ErrorAction Stop
    Write-Host "✓ Grupos exportados: $($grupos.Count)" -ForegroundColor Green
    
    # Backup de membros
    Write-Host "Exportando membros dos grupos..." -ForegroundColor Yellow
    $membros = @()
    
    foreach ($grupo in $grupos) {
        try {
            $membrosGrupo = Get-ADGroupMember -Identity $grupo.Name -ErrorAction SilentlyContinue
            
            foreach ($membro in $membrosGrupo) {
                $membros += [PSCustomObject]@{
                    Grupo = $grupo.Name
                    Membro = $membro.Name
                    TipoMembro = $membro.ObjectClass
                }
            }
        }
        catch {
            # Ignorar erros de grupos vazios
        }
    }
    
    if ($membros.Count -gt 0) {
        $membros | Export-Csv -Path "$BackupPath\Membros_$data.csv" -Encoding UTF8 -NoTypeInformation -ErrorAction Stop
        Write-Host "✓ Membros exportados: $($membros.Count)" -ForegroundColor Green
    }
    
    # Listar arquivos criados
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Arquivos de backup criados:" -ForegroundColor Cyan
    Get-ChildItem "$BackupPath\*$data*" | Format-Table Name, @{Label="Tamanho";Expression={"{0:N2} KB" -f ($_.Length/1KB)}}, CreationTime -AutoSize
    
    Write-Host ""
    Write-Host "✓ Backup realizado com sucesso!" -ForegroundColor Green
    Write-Host "✓ Caminho: $BackupPath" -ForegroundColor Green
    
}
catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✓ Script finalizado com sucesso!" -ForegroundColor Green
