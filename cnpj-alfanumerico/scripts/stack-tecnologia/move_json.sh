#!/bin/bash

BASE_DIR="/c/projetos/cnpj_alfanumerico/gits"
DEST_DIR="/c/projetos/cnpj_alfanumerico/stack-tecnologica"

mkdir -p "$DEST_DIR"

# Função para verificar se um diretório é um repositório Git
is_git_repo() {
    [ -d "$1/.git" ]
}

# Função para obter o nome do projeto Git
get_project_name() {
    local git_dir="$1"
    # Tenta obter o nome do repositório remoto
    local remote_name=$(cd "$git_dir" && git remote get-url origin 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//')
    if [ -n "$remote_name" ]; then
        echo "$remote_name"
    else
        # Se não conseguir do remote, usa o nome da pasta
        basename "$git_dir"
    fi
}

# Função para percorrer diretórios recursivamente
find_git_repos() {
    local current_dir="$1"
    local relative_path="$2"
    
    # Verifica se o diretório atual é um repositório Git
    if is_git_repo "$current_dir"; then
        local project_name=$(get_project_name "$current_dir")
        local source_file="$current_dir/.cnpj_alfanumerico/projeto/projeto.json"
        
        if [ -f "$source_file" ]; then
            # Cria o caminho de destino mantendo a hierarquia
            local dest_path="$DEST_DIR"
            if [ -n "$relative_path" ]; then
                dest_path="$DEST_DIR/$relative_path"
                mkdir -p "$dest_path"
            fi
            
            local dest_file="$dest_path/${project_name}.json"
            
            # Verifica se já existe um arquivo com o mesmo nome
            if [ -f "$dest_file" ]; then
                echo "AVISO: Arquivo $dest_file já existe. Pulando..."
                return
            fi
            
            # Copia o arquivo
            cp "$source_file" "$dest_file"
            echo "Copiado: $source_file -> $dest_file"
        else
            echo "INFO: Arquivo projeto.json não encontrado em $current_dir/.cnpj_alfanumerico/projeto/"
        fi
        return
    fi
    
    # Se não é um repositório Git, percorre subdiretórios
    for subdir in "$current_dir"/*; do
        if [ -d "$subdir" ]; then
            local subdir_name=$(basename "$subdir")
            local new_relative_path=""
            
            # Constrói o caminho relativo
            if [ -n "$relative_path" ]; then
                new_relative_path="$relative_path/$subdir_name"
            else
                new_relative_path="$subdir_name"
            fi
            
            find_git_repos "$subdir" "$new_relative_path"
        fi
    done
}

# Inicia a busca recursiva
echo "Iniciando busca recursiva por repositórios Git em: $BASE_DIR"
find_git_repos "$BASE_DIR" ""
echo "Processo concluído!"
