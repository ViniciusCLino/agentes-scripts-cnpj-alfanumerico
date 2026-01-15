# Script de Mudança de Branch

## Descrição
Script shell que altera a branch de todos os repositórios Git encontrados em uma pasta de forma recursiva.

## Uso
```bash
./change_branch.sh <pasta_repositorios> <nome_branch>
```

## Parâmetros
- `pasta_repositorios`: Caminho para a pasta contendo os repositórios Git
- `nome_branch`: Nome da branch para alterar

## Exemplos
```bash
# Alterar para branch 'develop' em todos os repositórios
./change_branch.sh /caminho/para/repositorios develop

# Alterar para branch 'feature/nova-funcionalidade'
./change_branch.sh ./meus-repos feature/nova-funcionalidade
```

## Funcionalidades

### ✅ Busca Recursiva
- Encontra automaticamente todos os repositórios Git (diretórios `.git`) na pasta especificada
- Processa subpastas recursivamente

### ✅ Validação de Branch
- Verifica se a branch existe em cada repositório
- Detecta se já está na branch correta

### ✅ Criação de Branch
- Pergunta se deve criar a branch caso não exista
- Aplica a decisão em todos os repositórios
- Cria a branch a partir da branch atual

### ✅ Proteção de Dados
- Verifica mudanças não commitadas
- Pula repositórios com alterações pendentes para evitar perda de dados

### ✅ Relatório Detalhado
- Mostra progresso em tempo real
- Exibe resumo final com estatísticas
- Cores para facilitar leitura

## Comportamento

1. **Validação**: Verifica se a pasta existe e contém repositórios
2. **Busca**: Encontra todos os repositórios Git recursivamente
3. **Processamento**: Para cada repositório:
   - Verifica se é um repositório Git válido
   - Checa mudanças não commitadas
   - Verifica existência da branch
   - Executa mudança de branch ou criação
4. **Relatório**: Exibe estatísticas finais

## Códigos de Saída
- `0`: Sucesso
- `1`: Erro (parâmetros inválidos, pasta não encontrada, etc.)

## Requisitos
- Bash shell
- Git instalado e configurado
- Acesso de escrita aos repositórios
