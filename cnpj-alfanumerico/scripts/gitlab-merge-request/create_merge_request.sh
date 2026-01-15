#!/bin/bash

# Script para criar merge request no GitLab usando glab CLI
# Uso: ./create_merge_request.sh <caminho_do_diretorio>

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir mensagens coloridas
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Função para exibir ajuda
show_help() {
    echo "Uso: $0 <caminho_do_diretorio>"
    echo ""
    echo "Este script cria um merge request no GitLab usando glab CLI"
    echo "Branch de origem: fix-cnpj-alfanumerico-impl"
    echo "Branch de destino: fix-cnpj-alfanumerico-qa"
    echo ""
    echo "Exemplo:"
    echo "  $0 /caminho/para/projeto"
    echo "  $0 ."
}

# Verificar se o glab está instalado
check_glab() {
    if ! command -v glab &> /dev/null; then
        print_error "glab CLI não está instalado ou não está no PATH"
        print_info "Para instalar o glab, visite: https://github.com/profclems/glab"
        exit 1
    fi
    print_success "glab CLI encontrado"
}

# Verificar se o diretório é um repositório Git
check_git_repo() {
    local dir_path="$1"
    
    if [ ! -d "$dir_path" ]; then
        print_error "Diretório '$dir_path' não existe"
        exit 1
    fi
    
    cd "$dir_path" || {
        print_error "Não foi possível acessar o diretório '$dir_path'"
        exit 1
    }
    
    if [ ! -d ".git" ]; then
        print_error "O diretório '$dir_path' não é um repositório Git"
        exit 1
    fi
    
    print_success "Repositório Git válido encontrado em '$dir_path'"
}

# Verificar se o usuário está autenticado no glab
check_glab_auth() {
    if ! glab auth status &> /dev/null; then
        print_error "Você não está autenticado no glab"
        print_info "Execute 'glab auth login' para autenticar"
        exit 1
    fi
    print_success "Usuário autenticado no glab"
}

# Verificar se as branches existem
check_branches() {
    local source_branch="fix-cnpj-alfanumerico-impl"
    local target_branch="fix-cnpj-alfanumerico-qa"
    
    # Verificar remote
    if ! git remote show origin &> /dev/null; then
        print_error "Remote 'origin' não configurado"
        print_info "Configure o remote com: git remote add origin <url_do_repositorio>"
        exit 1
    fi
    print_success "Remote 'origin' configurado"
    
    # Verificar se a branch de origem existe
    if ! git show-ref --verify --quiet refs/heads/"$source_branch"; then
        print_error "Branch de origem '$source_branch' não existe localmente"
        print_info "Branches disponíveis:"
        git branch --list | sed 's/^/  /'
        exit 1
    fi
    
    # Verificar se a branch de destino existe (local ou remota)
    if ! git show-ref --verify --quiet refs/heads/"$target_branch" && ! git show-ref --verify --quiet refs/remotes/origin/"$target_branch"; then
        print_error "Branch de destino '$target_branch' não existe"
        print_info "Branches disponíveis:"
        git branch -a | sed 's/^/  /'
        exit 1
    fi
    
    print_success "Branches '$source_branch' e '$target_branch' encontradas"
    
    # Verificar se a branch de origem foi enviada para o remoto
    if ! git show-ref --verify --quiet refs/remotes/origin/"$source_branch"; then
        print_warning "Branch de origem não foi enviada para o remoto"
        print_info "Enviando branch para o remoto..."
        if ! git push -u origin "$source_branch"; then
            print_error "Falha ao enviar branch para o remoto"
            exit 1
        fi
        print_success "Branch enviada para o remoto"
    fi
}

# Criar o merge request
create_merge_request() {
    local source_branch="fix-cnpj-alfanumerico-impl"
    local target_branch="fix-cnpj-alfanumerico-qa"
    
    print_info "Criando merge request..."
    print_info "Branch de origem: $source_branch"
    print_info "Branch de destino: $target_branch"
    
    # Criar o MR usando glab
    if glab mr create --source-branch "$source_branch" --target-branch "$target_branch" --title "Implementações dos ajustes do projeto CNPJ Alfanumérico" --description "Merge request para implementação das correções do CNPJ alfanumérico"; then
        print_success "Merge request criado com sucesso!"
        print_info "Você pode visualizar o MR no GitLab ou usar 'glab mr list' para listar os MRs"
    else
        print_error "Falha ao criar o merge request"
        print_info "Tente criar manualmente: glab mr create -s $source_branch -t $target_branch"
        exit 1
    fi
}

# Função principal
main() {
    # Verificar se o caminho foi fornecido
    if [ $# -eq 0 ]; then
        print_error "Caminho do diretório não fornecido"
        show_help
        exit 1
    fi
    
    # Verificar se é uma solicitação de ajuda
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        exit 0
    fi
    
    local project_path="$1"
    
    print_info "Iniciando criação de merge request..."
    print_info "Diretório do projeto: $project_path"
    
    # Executar verificações
    check_glab
    check_git_repo "$project_path"
    check_glab_auth
    check_branches
    
    # Criar o merge request
    create_merge_request
    
    print_success "Processo concluído com sucesso!"
}

# Executar função principal com todos os argumentos
main "$@"
