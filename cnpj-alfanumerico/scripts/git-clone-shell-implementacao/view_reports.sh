#!/bin/bash

# Script para visualizar relatórios de comparação de forma organizada
# Mostra um resumo de todos os repositórios processados

OUTPUT_DIR="comparison_reports"

echo "================================================"
echo "RELATÓRIOS DE COMPARAÇÃO DE BRANCHES"
echo "================================================"
echo ""

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "❌ Diretório de relatórios não encontrado: $OUTPUT_DIR"
    echo "Execute primeiro o script compare_branches.sh"
    exit 1
fi

# Conta quantos relatórios existem
report_count=$(find "$OUTPUT_DIR" -name "*_comparison.txt" | wc -l)
echo "📊 Total de relatórios encontrados: $report_count"
echo ""

if [ $report_count -eq 0 ]; then
    echo "❌ Nenhum relatório encontrado"
    exit 1
fi

# Lista todos os relatórios disponíveis
echo "📋 Relatórios disponíveis:"
echo "----------------------------------------"
for report in "$OUTPUT_DIR"/*_comparison.txt; do
    if [ -f "$report" ]; then
        repo_name=$(basename "$report" _comparison.txt)
        echo "  📄 $repo_name"
    fi
done
echo ""

# Pergunta qual relatório visualizar
echo "Digite o nome do repositório para visualizar o relatório (ou 'all' para todos):"
read -r choice

if [ "$choice" = "all" ]; then
    echo ""
    echo "================================================"
    echo "TODOS OS RELATÓRIOS"
    echo "================================================"
    echo ""
    
    for report in "$OUTPUT_DIR"/*_comparison.txt; do
        if [ -f "$report" ]; then
            echo ""
            echo "================================================"
            echo "RELATÓRIO: $(basename "$report")"
            echo "================================================"
            cat "$report"
            echo ""
            echo "================================================"
            echo ""
        fi
    done
else
    report_file="$OUTPUT_DIR/${choice}_comparison.txt"
    if [ -f "$report_file" ]; then
        echo ""
        echo "================================================"
        echo "RELATÓRIO: $choice"
        echo "================================================"
        cat "$report_file"
        echo ""
        echo "================================================"
    else
        echo "❌ Relatório não encontrado: $choice"
        echo "Relatórios disponíveis:"
        for report in "$OUTPUT_DIR"/*_comparison.txt; do
            if [ -f "$report" ]; then
                echo "  - $(basename "$report" _comparison.txt)"
            fi
        done
    fi
fi

echo ""
echo "✅ Visualização concluída!"
echo ""
echo "Para visualizar um relatório específico:"
echo "  cat $OUTPUT_DIR/<nome_do_repositorio>_comparison.txt"
echo ""
echo "Para visualizar todos os relatórios:"
echo "  cat $OUTPUT_DIR/*_comparison.txt"
