#!/bin/bash

# Script para clonar repositórios a partir do arquivo repositorios.csv
# Uso: ./clone_repos.sh <pasta_destino>

# Verificar se o parâmetro foi fornecido
if [ $# -eq 0 ]; then
    echo "Erro: Pasta de destino não fornecida."
    echo "Uso: $0 <pasta_destino>"
    echo "Exemplo: $0 /caminho/para/repositorios"
    exit 1
fi

# Pasta de destino
DEST_DIR="$1"

# Caminho para o arquivo CSV
CSV_FILE="./csv/repositorios-clone.csv"
ERROR_CSV_FILE="./csv/repositorios_erro.csv"

# Verificar se o arquivo CSV existe
if [ ! -f "$CSV_FILE" ]; then
    echo "Erro: Arquivo $CSV_FILE não encontrado."
    exit 1
fi

# Configurar Git para permitir caminhos longos no Windows
echo "Configurando Git para permitir caminhos longos..."
git config --global core.longpaths true
if [ $? -eq 0 ]; then
    echo "✅ Configuração de longpaths ativada"
else
    echo "⚠️  Aviso: Não foi possível configurar longpaths (pode já estar configurado)"
fi
echo ""

# Criar/limpar arquivo CSV de erros
echo "URL" > "$ERROR_CSV_FILE"
echo "Arquivo de erros criado/limpo: $ERROR_CSV_FILE"

# Criar pasta de destino se não existir
if [ ! -d "$DEST_DIR" ]; then
    echo "Criando pasta de destino: $DEST_DIR"
    mkdir -p "$DEST_DIR"
fi

# Contador de repositórios processados
count=0
success=0
failed=0

echo "Iniciando clonagem dos repositórios..."
echo "Pasta de destino: $DEST_DIR"
echo "----------------------------------------"

# Ler o arquivo CSV linha por linha (pulando o cabeçalho)
while IFS=';' read -r url; do
    # Pular linhas vazias
    if [ -z "$url" ] || [ "$url" = "" ]; then
        continue
    fi
    
    count=$((count + 1))
    
    # Limpar a URL (remover espaços e quebras de linha)
    url=$(echo "$url" | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Adicionar .git à URL se não tiver
    if [[ "$url" != *.git ]]; then
        url="${url}.git"
    fi
    
    # Extrair o nome do repositório da URL
    repo_name=$(basename "$url" .git)
    
    # Caminho completo do repositório
    repo_path="$DEST_DIR/$repo_name"
    
    echo "[$count] Clonando: $repo_name"
    echo "URL: $url"
    echo "Destino: $repo_path"
    
    # Verificar se o repositório já existe
    if [ -d "$repo_path" ]; then
        echo "⚠️  Repositório já existe, pulando..."
        echo "----------------------------------------"
        continue
    fi
    
    # Clonar o repositório
    if git clone "$url" "$repo_path" 2>&1; then
        echo "✅ Repositório clonado com sucesso!"
        success=$((success + 1))
    else
        echo "❌ Erro ao clonar repositório"
        echo "$url" >> "$ERROR_CSV_FILE"
        failed=$((failed + 1))
    fi
    
    echo "----------------------------------------"
done < <(tail -n +2 "$CSV_FILE")

echo ""
echo "Resumo da operação:"
echo "Total de repositórios processados: $count"
echo "Clonados com sucesso: $success"
echo "Falhas: $failed"
echo ""
echo "Repositórios salvos em: $DEST_DIR"
if [ $failed -gt 0 ]; then
    echo "Repositórios com erro salvos em: $ERROR_CSV_FILE"
fi
