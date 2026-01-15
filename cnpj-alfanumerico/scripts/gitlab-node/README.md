# GitLab Repos Exporter

Uma aplicação Node.js simples que se conecta à API do GitLab para listar todos os repositórios e exportar os dados para um arquivo CSV.

## 🚀 Funcionalidades

- Conecta-se à API do GitLab usando token de autenticação
- Lista todos os repositórios que o usuário tem acesso
- Exporta os dados para um arquivo CSV com informações detalhadas
- Suporte a paginação automática para grandes quantidades de repositórios
- Configuração via variáveis de ambiente

## 📋 Pré-requisitos

- Node.js (versão 14 ou superior)
- Conta no GitLab com token de API

## 🛠️ Instalação

1. Clone ou baixe este repositório
2. Instale as dependências:
   ```bash
   npm install
   ```

3. Configure as variáveis de ambiente:
   ```bash
   cp env.example .env
   ```

4. Edite o arquivo `.env` com suas configurações:
   ```env
   GITLAB_URL=https://gitlab.com
   GITLAB_API_TOKEN=seu_token_aqui
   OUTPUT_FILE=repositorios_gitlab.csv
   ```

## 🔑 Como obter o token da API do GitLab

1. Acesse o GitLab e faça login
2. Vá em **Settings** > **Access Tokens**
3. Crie um novo token com as permissões:
   - `read_api` - Para acessar a API
   - `read_repository` - Para ler informações dos repositórios
4. Copie o token gerado e cole no arquivo `.env`

## 🚀 Como usar

Execute a aplicação com:

```bash
npm start
```

ou

```bash
node index.js
```

A aplicação irá:
1. Conectar-se à API do GitLab
2. Buscar todos os repositórios (com paginação automática)
3. Salvar os dados em um arquivo CSV

## 📊 Dados exportados

O arquivo CSV contém as seguintes colunas:

- **ID**: ID único do repositório
- **Nome**: Nome do repositório
- **Caminho**: Caminho completo do repositório
- **Descrição**: Descrição do projeto
- **URL**: URL do repositório no GitLab
- **Visibilidade**: Público, Privado ou Interno
- **Branch Padrão**: Branch principal do repositório
- **Data de Criação**: Quando o repositório foi criado
- **Última Atividade**: Data da última atividade
- **Estrelas**: Número de estrelas
- **Forks**: Número de forks
- **Issues Abertas**: Número de issues em aberto
- **Namespace**: Namespace/grupo do repositório
- **Arquivado**: Se o repositório está arquivado

## ⚙️ Configurações

### Variáveis de ambiente

| Variável | Descrição | Padrão |
|----------|-----------|---------|
| `GITLAB_URL` | URL base do GitLab | `https://gitlab.com` |
| `GITLAB_API_TOKEN` | Token de API do GitLab | **Obrigatório** |
| `OUTPUT_FILE` | Nome do arquivo CSV de saída | `repositorios_gitlab.csv` |

### Para GitLab self-hosted

Se você usa um GitLab self-hosted, configure a URL:

```env
GITLAB_URL=https://seu-gitlab.com
```

## 🔧 Dependências

- **axios**: Para fazer requisições HTTP à API do GitLab
- **csv-writer**: Para gerar arquivos CSV
- **dotenv**: Para carregar variáveis de ambiente

## 📝 Exemplo de uso

```javascript
const GitLabReposExporter = require('./index.js');

const exporter = new GitLabReposExporter();
exporter.executar();
```

## 🐛 Solução de problemas

### Erro de autenticação
- Verifique se o token da API está correto
- Confirme se o token tem as permissões necessárias

### Erro de conexão
- Verifique se a URL do GitLab está correta
- Confirme se você tem acesso à internet

### Arquivo CSV não é criado
- Verifique as permissões de escrita no diretório
- Confirme se o nome do arquivo está correto

## 📄 Licença

MIT
