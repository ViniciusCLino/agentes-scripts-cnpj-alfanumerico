#!/bin/bash

# Script para copiar uma pasta para múltiplos repositórios git
# Uso: ./copy_folder_to_repos.sh <nome_da_pasta> <diretorio_dos_repositorios>
# Compatível com Git Bash no Windows

# Detectar se estamos no Git Bash
detect_git_bash() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$MSYSTEM" ]]; then
        return 0  # Estamos no Git Bash
    else
        return 1  # Não estamos no Git Bash
    fi
}

# Função para converter caminho para formato Unix (Git Bash)
convert_to_unix_path() {
    local path="$1"
    
    # Se estamos no Git Bash, converter caminhos Windows
    if detect_git_bash; then
        # Converter caminho Windows para Unix se necessário
        if [[ "$path" =~ ^[A-Za-z]: ]]; then
            # Caminho Windows (ex: C:\path\to\dir)
            local drive="${path:0:1,,}"
            local rest="${path:2:${#path}}"
            path="/$drive${rest//\\//}"
        fi
    fi
    
    # Normalizar barras
    path="${path//\\//}"
    echo "$path"
}

# Função para obter caminho absoluto
get_absolute_path() {
    local path="$1"
    if [[ "$path" = /* ]]; then
        # Já é absoluto
        echo "$path"
    else
        # Converter para absoluto
        echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    fi
}

# Verificar se os parâmetros foram fornecidos
if [ $# -ne 2 ]; then
    echo "Erro: Número incorreto de parâmetros"
    echo "Uso: $0 <nome_da_pasta> <diretorio_dos_repositorios>"
    echo "Exemplo: $0 minha_pasta /c/Users/usuario/repositorios"
    echo "Exemplo Windows: $0 minha_pasta C:/Users/usuario/repositorios"
    exit 1
fi

FOLDER_NAME="$1"
REPOS_DIR="$2"

# Converter caminhos para formato Unix e obter caminhos absolutos
FOLDER_NAME=$(convert_to_unix_path "$FOLDER_NAME")
REPOS_DIR=$(convert_to_unix_path "$REPOS_DIR")

FOLDER_NAME=$(get_absolute_path "$FOLDER_NAME")
REPOS_DIR=$(get_absolute_path "$REPOS_DIR")

# Exibir informações do ambiente
echo "Informações do ambiente:"
if detect_git_bash; then
    echo "  Ambiente: Git Bash (Windows)"
    echo "  OSTYPE: $OSTYPE"
    echo "  MSYSTEM: ${MSYSTEM:-não definido}"
else
    echo "  Ambiente: Unix/Linux"
    echo "  OSTYPE: $OSTYPE"
fi
echo ""

echo "Caminhos processados:"
echo "  Pasta origem: $FOLDER_NAME"
echo "  Diretório repositórios: $REPOS_DIR"
echo ""

# Verificar se o diretório dos repositórios existe
if [ ! -d "$REPOS_DIR" ]; then
    echo "Erro: Diretório '$REPOS_DIR' não existe"
    exit 1
fi

# Verificar se a pasta a ser copiada existe
if [ ! -d "$FOLDER_NAME" ]; then
    echo "Erro: Pasta '$FOLDER_NAME' não existe"
    exit 1
fi

echo "Iniciando cópia da pasta '$FOLDER_NAME' para repositórios em '$REPOS_DIR'"
echo "================================================"

# Listar conteúdo do diretório de repositórios para debug
echo "Conteúdo do diretório de repositórios:"
ls -la "$REPOS_DIR" 2>/dev/null || echo "  Erro ao listar diretório"
echo ""

# Contador para estatísticas
copied_count=0
skipped_count=0
error_count=0

# Obter nome da pasta para exibição
FOLDER_DISPLAY_NAME=$(basename "$FOLDER_NAME")

# Percorrer todos os diretórios no diretório dos repositórios
for repo_path in "$REPOS_DIR"/*; do
    # Verificar se é um diretório
    if [ -d "$repo_path" ]; then
        repo_name=$(basename "$repo_path")
        echo "Processando repositório: $repo_name"
        echo "  Caminho: $repo_path"
        
        # Verificar se o diretório não está vazio
        if [ ! "$(ls -A "$repo_path" 2>/dev/null)" ]; then
            echo "  ⚠️  Diretório vazio - PULANDO"
            ((skipped_count++))
            echo ""
            continue
        fi
        
        # Verificar se é um repositório git (múltiplas verificações)
        is_git_repo=false
        
        # Mostrar conteúdo do diretório para debug
        echo "  Conteúdo do diretório:"
        ls -la "$repo_path" 2>/dev/null | head -5 | sed 's/^/    /'
        
        # Verificar se existe pasta .git
        if [ -d "$repo_path/.git" ]; then
            is_git_repo=true
            echo "  📁 Pasta .git encontrada"
        # Verificar se é um worktree (arquivo .git ao invés de pasta)
        elif [ -f "$repo_path/.git" ]; then
            echo "  📄 Arquivo .git encontrado"
            # Verificar se o arquivo .git contém "gitdir:"
            if grep -q "gitdir:" "$repo_path/.git" 2>/dev/null; then
                is_git_repo=true
                echo "  📄 Arquivo .git é um worktree"
            fi
        else
            echo "  ❌ Nenhum arquivo/pasta .git encontrado"
        fi
        
        if [ "$is_git_repo" = true ]; then
            echo "  ✅ Repositório git detectado"
            
            # Verificar se a pasta já existe no repositório
            if [ -d "$repo_path/$FOLDER_DISPLAY_NAME" ]; then
                echo "  ⚠️  Pasta '$FOLDER_DISPLAY_NAME' já existe em $repo_name - PULANDO"
                ((skipped_count++))
            else
                # Copiar a pasta para o repositório
                echo "  📁 Copiando de: $FOLDER_NAME"
                echo "  📁 Copiando para: $repo_path/$FOLDER_DISPLAY_NAME"
                
                # Usar cp com opções específicas para Git Bash
                if detect_git_bash; then
                    # No Git Bash, usar cp com preservação de permissões
                    if cp -r --preserve=all "$FOLDER_NAME" "$repo_path/"; then
                        echo "  ✅ Pasta '$FOLDER_DISPLAY_NAME' copiada com sucesso para $repo_name"
                        ((copied_count++))
                    else
                        echo "  ❌ Erro ao copiar pasta para $repo_name"
                        ((error_count++))
                    fi
                else
                    # Em sistemas Unix/Linux
                    if cp -r "$FOLDER_NAME" "$repo_path/"; then
                        echo "  ✅ Pasta '$FOLDER_DISPLAY_NAME' copiada com sucesso para $repo_name"
                        ((copied_count++))
                    else
                        echo "  ❌ Erro ao copiar pasta para $repo_name"
                        ((error_count++))
                    fi
                fi
            fi
        else
            echo "  ⚠️  $repo_name não é um repositório git (pasta .git não encontrada) - PULANDO"
            ((skipped_count++))
        fi
        echo ""
    fi
done

echo "================================================"
echo "Resumo da operação:"
echo "  ✅ Pastas copiadas: $copied_count"
echo "  ⚠️  Repositórios pulados: $skipped_count"
echo "  ❌ Erros: $error_count"
echo "================================================"

if [ $error_count -gt 0 ]; then
    echo "Atenção: Houve $error_count erro(s) durante a operação"
    exit 1
else
    echo "Operação concluída com sucesso!"
    exit 0
fi
