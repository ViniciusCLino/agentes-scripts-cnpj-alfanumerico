require('dotenv').config();
const path = require('path');
const { readRepositoriesFromCSV, createExampleCSV } = require('./utils/csvReader');
const DocumentDownloader = require('./services/documentDownloader');

class GitLabDocumentFetcher {
    constructor() {
        this.csvFilePath = 'repositorios.csv';
        this.gitlabUrl = process.env.GITLAB_BASE_URL || 'http://gitlab.tokiomarine.com.br';
        this.gitlabToken = process.env.GITLAB_TOKEN;
        this.targetBranch = process.env.TARGET_BRANCH || 'fix-cnpj-alfanumerico-plan';
        this.createBranchIfNotExists = process.env.CREATE_BRANCH !== 'false'; // Por padrão, cria a branch se não existir
    }

    /**
     * Executa o processo principal
     */
    async run() {
        console.log('🔧 GitLab Document Fetcher');
        console.log('========================\n');

        try {
            // Verifica se o token do GitLab foi fornecido
            if (!this.gitlabToken) {
                console.error('❌ Token do GitLab não encontrado!');
                console.log('💡 Configure a variável GITLAB_TOKEN no arquivo .env');
                console.log('💡 Você pode copiar o arquivo config.example.env para .env e configurar seu token');
                return;
            }

            // Verifica se o arquivo CSV existe, se não, cria um exemplo
            if (!await this.checkCSVFile()) {
                return;
            }

            // Lê os repositórios do CSV
            console.log(`📋 Lendo repositórios do arquivo: ${this.csvFilePath}`);
            const repositories = await readRepositoriesFromCSV(this.csvFilePath);
            
            if (repositories.length === 0) {
                console.log('⚠️ Nenhum repositório encontrado no CSV');
                return;
            }

            // Inicializa o downloader
            const downloader = new DocumentDownloader(this.gitlabUrl, this.gitlabToken, this.targetBranch, this.createBranchIfNotExists);
            
            // Testa a conexão com o GitLab
            console.log('🔗 Testando conexão com o GitLab...');
            const connectionOk = await downloader.testConnection();
            
            if (!connectionOk) {
                console.error('❌ Não foi possível conectar ao GitLab. Verifique suas credenciais.');
                return;
            }

            // Processa todos os repositórios
            const results = await downloader.processRepositories(repositories);
            
            console.log('\n🎉 Processo concluído com sucesso!');
            console.log(`📁 Documentos salvos na pasta: ${path.resolve('documento_projetos')}`);
            
            if (results.failed > 0) {
                console.log(`\n⚠️ ${results.failed} repositórios falharam. Verifique os arquivos *_ERROR.json para detalhes.`);
            }

        } catch (error) {
            console.error('❌ Erro durante a execução:', error.message);
            process.exit(1);
        }
    }

    /**
     * Verifica se o arquivo CSV existe, se não, cria um exemplo
     * @returns {Promise<boolean>} True se o arquivo existe ou foi criado
     */
    async checkCSVFile() {
        const fs = require('fs');
        
        if (!fs.existsSync(this.csvFilePath)) {
            console.log(`📝 Arquivo CSV não encontrado: ${this.csvFilePath}`);
            console.log('💡 Criando arquivo de exemplo...');
            
            createExampleCSV(this.csvFilePath);
            
            console.log(`✅ Arquivo de exemplo criado: ${this.csvFilePath}`);
            console.log('📝 Edite o arquivo com os nomes dos seus repositórios e execute novamente.');
            return false;
        }
        
        return true;
    }
}

// Executa o programa se for chamado diretamente
if (require.main === module) {
    const app = new GitLabDocumentFetcher();
    app.run().catch(error => {
        console.error('❌ Erro fatal:', error.message);
        process.exit(1);
    });
}

module.exports = GitLabDocumentFetcher;
