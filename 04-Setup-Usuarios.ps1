<#
.SYNOPSIS
    Script para criar múltiplos usuários no Active Directory
    
.DESCRIPTION
    Este script cria usuários de forma automática com base em um array de dados
    Todos os usuários recebem senha padrão e são forçados a mudar na próximo logon
    
.EXAMPLE
    .\Setup-Usuarios.ps1
    
.AUTHOR
    Seu Nome
    
.DATE
    11/04/2026
    
.NOTES
    Requer permissões de administrador
    Requer Active Directory com OUs configuradas
#>

# Verificar se está como admin
$isAdmin = [System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Este script requer permissões de administrador!" -ForegroundColor Red
    exit 1
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  CRIAÇÃO DE USUÁRIOS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

try {
    # Obter domínio
    $dominio = Get-ADDomain -ErrorAction Stop
    $dn = $dominio.DistinguishedName
    
    Write-Host "✓ Domínio: $($dominio.Name)" -ForegroundColor Green
    Write-Host ""
    
    # Definir usuários a criar
    $usuarios = @(
        @{
            Name = "joao.silva"
            Primeiro = "João"
            Ultimo = "Silva"
            Email = "joao.silva@empresa.local"
            Depart = "TI"
            Cargo = "Analista de Sistemas"
        },
        @{
            Name = "maria.santos"
            Primeiro = "Maria"
            Ultimo = "Santos"
            Email = "maria.santos@empresa.local"
            Depart = "RH"
            Cargo = "Gerente de RH"
        },
        @{
            Name = "carlos.oliveira"
            Primeiro = "Carlos"
            Ultimo = "Oliveira"
            Email = "carlos.oliveira@empresa.local"
            Depart = "TI"
            Cargo = "Desenvolvedor"
        },
        @{
            Name = "ana.costa"
            Primeiro = "Ana"
            Ultimo = "Costa"
            Email = "ana.costa@empresa.local"
            Depart = "Financeiro"
            Cargo = "Analista Financeiro"
        },
        @{
            Name = "pedro.gomes"
            Primeiro = "Pedro"
            Ultimo = "Gomes"
            Email = "pedro.gomes@empresa.local"
            Depart = "TI"
            Cargo = "Suporte Técnico"
        },
        @{
            Name = "fernanda.rodrigues"
            Primeiro = "Fernanda"
            Ultimo = "Rodrigues"
            Email = "fernanda.rodrigues@empresa.local"
            Depart = "RH"
            Cargo = "Especialista em RH"
        }
    )
    
    # Senha padrão
    $senhapadrao = ConvertTo-SecureString "Senha@Inicial123!" -AsPlainText -Force
    
    Write-Host "Criando usuários..." -ForegroundColor Yellow
    Write-Host "Total: $($usuarios.Count)" -ForegroundColor White
    Write-Host ""
    
    $criados = 0
    $erros = 0
    
    # Criar cada usuário
    foreach ($user in $usuarios) {
        try {
            # Determinar OU baseado no departamento
            $ou = switch ($user.Depart) {
                "TI" { "OU=TI,OU=Usuarios,$dn" }
                "RH" { "OU=RH,OU=Usuarios,$dn" }
                "Financeiro" { "OU=Financeiro,OU=Usuarios,$dn" }
                "Diretoria" { "OU=Diretoria,OU=Usuarios,$dn" }
                default { "OU=Usuarios,$dn" }
            }
            
            # Verificar se usuário já existe
            $userExistente = Get-ADUser -Filter "samAccountName -eq '$($user.Name)'" -ErrorAction SilentlyContinue
            
            if ($userExistente) {
                Write-Host "⚠️  Usuário '$($user.Name)' já existe" -ForegroundColor Yellow
                continue
            }
            
            # Criar usuário
            New-ADUser `
                -Name $user.Name `
                -GivenName $user.Primeiro `
                -Surname $user.Ultimo `
                -UserPrincipalName "$($user.Name)@empresa.local" `
                -SamAccountName $user.Name `
                -EmailAddress $user.Email `
                -Department $user.Depart `
                -Title $user.Cargo `
                -AccountPassword $senhapadrao `
                -Enabled $true `
                -ChangePasswordAtLogon $true `
                -Path $ou `
                -ErrorAction Stop
            
            Write-Host "✓ $($user.Name) ($($user.Depart))" -ForegroundColor Green
            $criados++
        }
        catch {
            Write-Host "❌ Erro ao criar $($user.Name): $_" -ForegroundColor Red
            $erros++
        }
    }
    
    # Resumo
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Resumo:" -ForegroundColor Cyan
    Write-Host "  Criados: $criados" -ForegroundColor Green
    Write-Host "  Erros: $erros" -ForegroundColor $(if ($erros -eq 0) { "Green" } else { "Red" })
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    # Listar usuários criados
    Write-Host ""
    Write-Host "Usuários criados:" -ForegroundColor Cyan
    Get-ADUser -Filter * -Properties Department | Select-Object Name, UserPrincipalName, Department, Enabled | Format-Table -AutoSize
    
}
catch {
    Write-Host "❌ Erro: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✓ Script finalizado com sucesso!" -ForegroundColor Green
