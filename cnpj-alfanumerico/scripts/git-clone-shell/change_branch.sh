#!/bin/bash

# Script para alterar branch em todos os repositórios Git de uma pasta
# Uso: ./change_branch.sh <pasta_repositorios> <nome_branch>

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir ajuda
show_help() {
    echo "Script para alterar branch em todos os repositórios Git de uma pasta"
    echo ""
    echo "Uso: $0 <pasta_repositorios> <nome_branch>"
    echo ""
    echo "Parâmetros:"
    echo "  pasta_repositorios  - Caminho para a pasta contendo os repositórios Git"
    echo "  nome_branch         - Nome da branch para alterar"
    echo ""
    echo "Exemplo:"
    echo "  $0 /caminho/para/repositorios develop"
    echo ""
    echo "Funcionalidades:"
    echo "  - Busca recursivamente por repositórios Git (.git)"
    echo "  - Verifica se a branch existe em cada repositório"
    echo "  - Pergunta se deve criar a branch caso não exista"
    echo "  - Aplica a mudança de branch em todos os repositórios"
}

# Verificar se os parâmetros foram fornecidos
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

if [ $# -ne 2 ]; then
    echo -e "${RED}Erro: Número incorreto de parâmetros.${NC}"
    echo ""
    show_help
    exit 1
fi

# Parâmetros
REPOS_DIR="$1"
BRANCH_NAME="$2"

# Verificar se a pasta existe
if [ ! -d "$REPOS_DIR" ]; then
    echo -e "${RED}Erro: Pasta '$REPOS_DIR' não encontrada.${NC}"
    exit 1
fi

# Verificar se a pasta não está vazia
if [ -z "$(ls -A "$REPOS_DIR" 2>/dev/null)" ]; then
    echo -e "${RED}Erro: Pasta '$REPOS_DIR' está vazia.${NC}"
    exit 1
fi

echo -e "${BLUE}=== Script de Mudança de Branch ===${NC}"
echo -e "${BLUE}Pasta de repositórios: ${NC}$REPOS_DIR"
echo -e "${BLUE}Branch alvo: ${NC}$BRANCH_NAME"
echo ""

# Contadores
total_repos=0
success_count=0
failed_count=0
skipped_count=0
created_branches=0

# Função para processar um repositório
process_repo() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")
    
    echo -e "${YELLOW}[$((total_repos + 1))] Processando: $repo_name${NC}"
    echo -e "${BLUE}Caminho: $repo_path${NC}"
    
    # Entrar no diretório do repositório
    cd "$repo_path" || {
        echo -e "${RED}❌ Erro: Não foi possível acessar o diretório${NC}"
        failed_count=$((failed_count + 1))
        return 1
    }
    
    # Verificar se é um repositório Git válido
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo -e "${RED}❌ Não é um repositório Git válido${NC}"
        failed_count=$((failed_count + 1))
        return 1
    fi
    
    # Verificar se há mudanças não commitadas
    if ! git diff-index --quiet HEAD --; then
        echo -e "${YELLOW}⚠️  Repositório possui mudanças não commitadas${NC}"
        echo -e "${YELLOW}   Pulando para evitar perda de dados...${NC}"
        skipped_count=$((skipped_count + 1))
        return 0
    fi
    
    # Verificar se a branch existe
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        echo -e "${GREEN}✅ Branch '$BRANCH_NAME' existe${NC}"
        
        # Verificar se já está na branch correta
        current_branch=$(git branch --show-current)
        if [ "$current_branch" = "$BRANCH_NAME" ]; then
            echo -e "${GREEN}✅ Já está na branch '$BRANCH_NAME'${NC}"
            success_count=$((success_count + 1))
        else
            # Fazer checkout para a branch
            if git checkout "$BRANCH_NAME" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Mudou para branch '$BRANCH_NAME'${NC}"
                success_count=$((success_count + 1))
            else
                echo -e "${RED}❌ Erro ao fazer checkout para '$BRANCH_NAME'${NC}"
                failed_count=$((failed_count + 1))
            fi
        fi
    else
        echo -e "${YELLOW}⚠️  Branch '$BRANCH_NAME' não existe${NC}"
        
        # Autorizar automaticamente a criação da branch (apenas na primeira vez)
        if [ $created_branches -eq 0 ]; then
            echo -e "${GREEN}Branch '$BRANCH_NAME' não existe - criando automaticamente${NC}"
            create_branch_global="yes"
        fi
        
        if [ "$create_branch_global" = "yes" ]; then
            # Criar a branch
            if git checkout -b "$BRANCH_NAME" >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Branch '$BRANCH_NAME' criada e ativada${NC}"
                success_count=$((success_count + 1))
                created_branches=$((created_branches + 1))
            else
                echo -e "${RED}❌ Erro ao criar branch '$BRANCH_NAME'${NC}"
                failed_count=$((failed_count + 1))
            fi
        else
            echo -e "${YELLOW}⚠️  Pulando repositório (branch não será criada)${NC}"
            skipped_count=$((skipped_count + 1))
        fi
    fi
    
    echo "----------------------------------------"
}

# Buscar todos os repositórios Git recursivamente
echo -e "${BLUE}Buscando repositórios Git...${NC}"
echo ""

# Normalizar o caminho de entrada para funcionar com find
REPOS_DIR_NORMALIZED=$(echo "$REPOS_DIR" | sed 's|\\|/|g' | sed 's|//|/|g' | sed 's|/$||')

# Encontrar todos os diretórios .git usando uma abordagem mais robusta
# Primeiro, vamos para o diretório e usar find com caminho relativo
original_dir=$(pwd)
cd "$REPOS_DIR_NORMALIZED" 2>/dev/null || {
    echo -e "${RED}Erro: Não foi possível acessar o diretório '$REPOS_DIR'${NC}"
    exit 1
}

git_dirs=$(find . -type d -name ".git" 2>/dev/null)

# Voltar ao diretório original
cd "$original_dir" 2>/dev/null

if [ -z "$git_dirs" ]; then
    echo -e "${RED}Nenhum repositório Git encontrado na pasta '$REPOS_DIR'${NC}"
    exit 1
fi

# Criar array para armazenar repositórios únicos
declare -a unique_repos=()

# Processar cada repositório e remover duplicatas
while IFS= read -r git_dir; do
    # Construir o caminho completo do repositório
    # git_dir agora é relativo ao diretório de repositórios
    repo_name=$(dirname "$git_dir" | sed 's|^\./||')
    repo_path="$REPOS_DIR_NORMALIZED/$repo_name"
    
    # Converter para caminho absoluto para garantir que funcione
    # Primeiro tentar com realpath, se não funcionar, usar uma abordagem manual
    if ! repo_path=$(realpath "$repo_path" 2>/dev/null); then
        # Se realpath não funcionar, construir o caminho absoluto manualmente
        if [[ "$repo_path" = /* ]]; then
            # Já é absoluto
            true
        else
            # É relativo, construir caminho absoluto
            repo_path="$(pwd)/$repo_path"
        fi
    fi
    
    # Verificar se o repositório já foi processado
    if [[ ! " ${unique_repos[@]} " =~ " ${repo_path} " ]]; then
        unique_repos+=("$repo_path")
    fi
done <<< "$git_dirs"

# Processar apenas repositórios únicos
for repo_path in "${unique_repos[@]}"; do
    total_repos=$((total_repos + 1))
    process_repo "$repo_path"
done

# Exibir resumo final
echo ""
echo -e "${BLUE}=== Resumo da Operação ===${NC}"
echo -e "${BLUE}Total de repositórios encontrados: ${NC}$total_repos"
echo -e "${GREEN}Sucessos: ${NC}$success_count"
echo -e "${RED}Falhas: ${NC}$failed_count"
echo -e "${YELLOW}Pulados: ${NC}$skipped_count"

if [ $created_branches -gt 0 ]; then
    echo -e "${GREEN}Branches criadas: ${NC}$created_branches"
fi

echo ""
if [ $failed_count -eq 0 ]; then
    echo -e "${GREEN}✅ Operação concluída com sucesso!${NC}"
else
    echo -e "${YELLOW}⚠️  Operação concluída com alguns erros.${NC}"
fi
