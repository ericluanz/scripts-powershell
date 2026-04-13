## 🏗️ scripts-powershell

Scripts e automações em PowerShell para gerenciamento de infraestrutura e Active Directory no dia a dia.

---

## 📂 Estrutura

scripts-powershell/  
│   ├── powershell/        # Automação e gerenciamento  
│   ├── domain/        # Domínio / Active Directory  
│   ├── users/         # Usuários  
│   ├── groups/        # Grupos  
│   ├── network/       # Rede / Ingresso no domínio  
│   ├── backup/        # Backup  
│   └── tests/         # Testes e diagnósticos  

---

## 🔧 Principais Funcionalidades

### ⚙️ Active Directory & Infraestrutura

- Configuração inicial de domínio (AD DS)  
- Criação e organização de OUs  
- Provisionamento de usuários em lote  
- Criação e gerenciamento de grupos  
- Ingresso automático de máquinas no domínio  
- Backup de usuários, grupos e membros do AD  
- Testes de conectividade (DNS, LDAP, SMB, RDP)  

---

## 🚀 Como utilizar

git clone https://github.com/ericluanz/scripts-powershell.git  
cd infra-scripts

Execute os scripts conforme a necessidade:

# Exemplo
.\powershell\users\04-Setup-Usuarios.ps1

> ⚠️ Execute o PowerShell como administrador quando necessário.

---

## 📋 Pré-requisitos

- Windows Server (para AD)  
- Windows 10/11 Pro (clientes)  
- PowerShell 5.0+  
- Permissões administrativas  
- Ambiente de domínio configurado  

---

## ⚠️ Aviso

Este repositório contém **scripts de uso interno**.

- Teste sempre em ambiente controlado  
- Revise antes de executar em produção  
- Adapte conforme sua infraestrutura  

---

## 🛠️ Boas práticas

- ✔️ Utilize ambiente de testes (LAB)  
- ✔️ Mantenha backups atualizados  
- ✔️ Revise permissões e credenciais  
- ✔️ Customize os scripts conforme o cenário  
