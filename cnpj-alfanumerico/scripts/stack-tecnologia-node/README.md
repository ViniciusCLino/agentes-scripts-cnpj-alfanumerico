# GitLab Document Fetcher

Aplicação Node.js simples para buscar documentos de projetos no GitLab e salvá-los localmente.

## 🚀 Funcionalidades

- Conecta no GitLab via API
- Lê lista de repositórios de um arquivo CSV
- Busca documentos específicos de cada repositório
- Salva os documentos na pasta `documento_projetos`
- Gera relatórios de operação

## 📋 Pré-requisitos

- Node.js (versão 14 ou superior)
- Token de acesso do GitLab
- Lista de repositórios em arquivo CSV

## 🛠️ Instalação

1. Clone ou baixe o projeto
2. Instale as dependências:
```bash
npm install
```

3. Configure as variáveis de ambiente:
```bash
# Copie o arquivo de exemplo
copy config.example.env .env

# Edite o arquivo .env com suas credenciais
GITLAB_TOKEN=seu_token_do_gitlab_aqui
GITLAB_BASE_URL=http://gitlab.tokiomarine.com.br

# Configurações de Branch (opcional)
TARGET_BRANCH=fix-cnpj-alfanumerico-plan
CREATE_BRANCH=true
```

## 📁 Estrutura do Projeto

```
├── src/
│   ├── index.js                    # Script principal
│   ├── services/
│   │   ├── gitlabService.js        # Cliente GitLab API
│   │   └── documentDownloader.js   # Orquestrador principal
│   └── utils/
│       ├── csvReader.js            # Leitor de arquivos CSV
│       └── fileManager.js          # Gerenciador de arquivos
├── documento_projetos/             # Pasta de saída (criada automaticamente)
├── repositorios.csv                # Lista de repositórios (criado automaticamente)
└── package.json
```

## 🎯 Como Usar

1. **Prepare a lista de repositórios:**
   - Edite o arquivo `repositorios.csv` com os nomes dos repositórios
   - Formato: uma coluna chamada `repository` com o nome de cada repositório

2. **Execute a aplicação:**
```bash
npm start
```

3. **Verifique os resultados:**
   - Documentos salvos: pasta `documento_projetos/`
   - Relatório de operação: `documento_projetos/relatorio_operacao.json`
   - Erros (se houver): arquivos `*_ERROR.json`

## 📊 Formato do CSV

O arquivo CSV deve ter o seguinte formato:

```csv
repository
nome-do-repositorio-1
nome-do-repositorio-2
nome-do-repositorio-3
```

## 🔧 Configuração

### Token do GitLab

1. Acesse seu GitLab
2. Vá em **User Settings** > **Access Tokens**
3. Crie um token com escopo `read_api`
4. Configure no arquivo `.env`

### Caminho do Documento

Por padrão, a aplicação busca o arquivo:
```
.cnpj_alfanumerico/projeto/projeto.json
```

No branch:
```
fix-cnpj-alfanumerico-plan
```

### Gerenciamento de Branches

A aplicação agora pode:

1. **Verificar se a branch existe** antes de buscar documentos
2. **Criar a branch automaticamente** se não existir (baseada em `main` ou `master`)
3. **Configurar o comportamento** via variáveis de ambiente:
   - `TARGET_BRANCH`: Nome da branch alvo (padrão: `fix-cnpj-alfanumerico-plan`)
   - `CREATE_BRANCH`: Se deve criar a branch se não existir (padrão: `true`)

## 📝 Exemplo de Uso

```bash
# Instalar dependências
npm install

# Configurar variáveis de ambiente
copy config.example.env .env
# Editar .env com seu token

# Executar aplicação
npm start
```

## 🔍 Logs e Relatórios

A aplicação gera:
- Logs detalhados no console
- Relatório JSON com estatísticas
- Arquivos de erro para repositórios que falharam
- Arquivos JSON com os documentos baixados

## ⚠️ Limitações

- Requer token de acesso ao GitLab
- Processa repositórios sequencialmente (com pausa de 1s entre requisições)
- Busca apenas no branch específico configurado
- Arquivos de saída são sempre em formato JSON

## 🐛 Solução de Problemas

### Erro de Conexão
- Verifique se o token está correto
- Confirme se a URL do GitLab está acessível

### Repositório Não Encontrado
- Verifique se o nome do repositório está correto no CSV
- Confirme se o repositório existe no GitLab

### Arquivo Não Encontrado
- Verifique se o arquivo existe no branch especificado
- Confirme o caminho do arquivo no repositório
