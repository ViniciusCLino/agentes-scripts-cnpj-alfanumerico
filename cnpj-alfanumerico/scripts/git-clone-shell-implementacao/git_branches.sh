#!/bin/bash

# Script para criar e configurar branches do Git
# Recebe um diretório como parâmetro e executa os comandos Git em cada repositório encontrado

# Verifica se foi fornecido um diretório como parâmetro
if [ $# -eq 0 ]; then
    echo "Erro: Forneça o caminho do diretório como parâmetro"
    echo "Uso: ./git_branches.sh <caminho_do_diretorio>"
    exit 1
fi

DIRECTORY_PATH="$1"

# Verifica se o diretório existe
if [ ! -d "$DIRECTORY_PATH" ]; then
    echo "Erro: O diretório '$DIRECTORY_PATH' não existe"
    exit 1
fi

echo "Executando comandos Git no diretório: $DIRECTORY_PATH"
echo "================================================"

# Percorre cada pasta dentro do diretório
for repo_dir in "$DIRECTORY_PATH"/*; do
    # Verifica se é um diretório
    if [ -d "$repo_dir" ]; then
        repo_name=$(basename "$repo_dir")
        echo ""
        echo "Processando repositório: $repo_name"
        echo "Caminho: $repo_dir"
        echo "----------------------------------------"
        
        # Entra no diretório do repositório
        cd "$repo_dir" || continue
        
        # Verifica se é um repositório Git
        if [ -d ".git" ]; then
            echo "✓ Repositório Git encontrado"
            
            # Checkout da branch fix-cnpj-alfanumerico-plan
            echo "1. Fazendo checkout da branch fix-cnpj-alfanumerico-plan..."
            git checkout fix-cnpj-alfanumerico-plan
            
            # Criar e fazer checkout da branch fix-cnpj-alfanumerico-qa
            echo "2. Criando e fazendo checkout da branch fix-cnpj-alfanumerico-qa..."
            git checkout -b fix-cnpj-alfanumerico-qa
            
            # Push da branch fix-cnpj-alfanumerico-qa
            echo "3. Fazendo push da branch fix-cnpj-alfanumerico-qa..."
            git push --set-upstream origin fix-cnpj-alfanumerico-qa
            
            # Criar e fazer checkout da branch fix-cnpj-alfanumerico-impl
            echo "4. Criando e fazendo checkout da branch fix-cnpj-alfanumerico-impl..."
            git checkout -b fix-cnpj-alfanumerico-impl
            
            # Push da branch fix-cnpj-alfanumerico-impl
            echo "5. Fazendo push da branch fix-cnpj-alfanumerico-impl..."
            git push --set-upstream origin fix-cnpj-alfanumerico-impl
            
            echo "✓ Branches criadas com sucesso em $repo_name"
        else
            echo "✗ Não é um repositório Git (pasta .git não encontrada)"
        fi
        
        # Volta para o diretório original
        cd - > /dev/null
    fi
done

echo ""
echo "================================================"
echo "Script executado com sucesso!"
echo "Branches criadas em todos os repositórios Git encontrados:"
echo "- fix-cnpj-alfanumerico-qa"
echo "- fix-cnpj-alfanumerico-impl"
