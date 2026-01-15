# Scripts para Copiar Pasta para Múltiplos Repositórios Git

Este diretório contém scripts para copiar uma pasta para múltiplos repositórios git, verificando se a pasta já existe antes de copiar.

## Scripts Disponíveis

### 1. `copy_folder_to_repos.sh` (Linux/macOS/Git Bash)
Script shell para sistemas Unix-like.

### 2. `copy_folder_to_repos.ps1` (Windows PowerShell)
Script PowerShell para Windows.

## Como Usar

### Linux/macOS/Git Bash
```bash
./copy_folder_to_repos.sh <nome_da_pasta> <diretorio_dos_repositorios>
```

### Windows PowerShell
```powershell
.\copy_folder_to_repos.ps1 <nome_da_pasta> <diretorio_dos_repositorios>
```

## Parâmetros

- **nome_da_pasta**: Nome da pasta que será copiada (deve existir no diretório atual)
- **diretorio_dos_repositorios**: Caminho para o diretório que contém todos os repositórios git

## Exemplos

### Exemplo 1: Copiar pasta "config" para repositórios
```bash
# Linux/macOS
./copy_folder_to_repos.sh config /home/usuario/repositorios

# Windows
.\copy_folder_to_repos.ps1 config C:\repositorios
```

### Exemplo 2: Copiar pasta "docs" para repositórios
```bash
# Linux/macOS
./copy_folder_to_repos.sh docs /var/git/repos

# Windows
.\copy_folder_to_repos.ps1 docs D:\git\repos
```

## Funcionamento

1. **Validação**: O script verifica se os parâmetros foram fornecidos e se os diretórios existem
2. **Verificação de Repositórios**: Percorre todos os diretórios no diretório especificado
3. **Validação Git**: Verifica se cada diretório é um repositório git (presença da pasta `.git`)
4. **Verificação de Existência**: Verifica se a pasta já existe no repositório
5. **Cópia**: Se a pasta não existir, copia a pasta para o repositório
6. **Relatório**: Exibe um resumo da operação com estatísticas

## Saída do Script

O script exibe:
- ✅ Pastas copiadas com sucesso
- ⚠️ Repositórios pulados (pasta já existe ou não é um repositório git)
- ❌ Erros durante a operação
- Resumo final com contadores

## Tratamento de Erros

- **Parâmetros inválidos**: Script para com código de erro 1
- **Diretórios inexistentes**: Script para com código de erro 1
- **Erros de cópia**: Script continua processando outros repositórios
- **Resumo de erros**: Ao final, se houver erros, o script retorna código 1

## Requisitos

- **Shell Script**: Bash (disponível no Git Bash no Windows)
- **PowerShell**: PowerShell 5.0 ou superior
- **Permissões**: Permissão de leitura na pasta origem e escrita nos repositórios de destino

