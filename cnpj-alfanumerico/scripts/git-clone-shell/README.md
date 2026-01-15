# Script de Clonagem de Repositórios

Este projeto contém scripts para clonar repositórios Git a partir de um arquivo CSV.

## Arquivos

- `repositorios.csv` - Arquivo CSV contendo informações dos repositórios
- `clone_repos.sh` - Script para Linux/Mac (Bash)
- `clone_repos.ps1` - Script para Windows (PowerShell)

## Estrutura do CSV

O arquivo `repositorios.csv` deve conter as seguintes colunas separadas por ponto e vírgula (`;`):
- ID
- Nome
- Caminho
- Descrição
- URL
- Visibilidade
- Branch Padrão
- Data de Criação
- Última Atividade
- Estrelas
- Forks
- Issues Abertas
- Namespace
- Arquivado

## Como usar

### No Windows (PowerShell)

```powershell
.\clone_repos.ps1 "C:\caminho\para\repositorios"
```

### No Linux/Mac (Bash)

```bash
./clone_repos.sh /caminho/para/repositorios
```

## Funcionalidades

- ✅ Lê o arquivo CSV automaticamente
- ✅ Cria a pasta de destino se não existir
- ✅ Verifica se o repositório já foi clonado (evita duplicatas)
- ✅ Mostra progresso em tempo real
- ✅ Exibe resumo final com estatísticas
- ✅ Tratamento de erros
- ✅ Suporte a repositórios GitLab e GitHub

## Exemplo de uso

```bash
# No Windows
.\clone_repos.ps1 "C:\meus-repositorios"

# No Linux/Mac
./clone_repos.sh /home/usuario/meus-repositorios
```

## Requisitos

- Git instalado e configurado
- PowerShell (Windows) ou Bash (Linux/Mac)
- Acesso aos repositórios (credenciais configuradas no Git)
