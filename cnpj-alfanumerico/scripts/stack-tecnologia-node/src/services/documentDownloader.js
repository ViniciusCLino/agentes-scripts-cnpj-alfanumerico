const GitLabService = require('./gitlabService');
const FileManager = require('../utils/fileManager');

class DocumentDownloader {
    constructor(gitlabUrl, gitlabToken, targetBranch = 'fix-cnpj-alfanumerico-plan', createBranchIfNotExists = true) {
        this.gitlabService = new GitLabService(gitlabUrl, gitlabToken);
        this.fileManager = new FileManager();
        this.documentPath = '.cnpj_alfanumerico/projeto/projeto.json';
        this.branch = targetBranch;
        this.createBranchIfNotExists = createBranchIfNotExists;
        
        console.log(`🎯 Branch alvo: ${this.branch}`);
        console.log(`🔧 Criar branch se não existir: ${this.createBranchIfNotExists ? 'Sim' : 'Não'}`);
    }

    /**
     * Processa todos os repositórios da lista CSV
     * @param {Array<string>} repositories - Lista de nomes de repositórios
     * @returns {Promise<Object>} Resultado da operação
     */
    async processRepositories(repositories) {
        console.log(`🚀 Iniciando processamento de ${repositories.length} repositórios...`);
        
        // Cria o diretório de saída
        await this.fileManager.ensureOutputDirectory();

        const results = {
            total: repositories.length,
            successful: 0,
            failed: 0,
            details: []
        };

        // Processa cada repositório
        for (let i = 0; i < repositories.length; i++) {
            const repository = repositories[i];
            console.log(`\n📦 Processando ${i + 1}/${repositories.length}: ${repository}`);
            
            try {
                const result = await this.processRepository(repository);
                
                if (result.success) {
                    results.successful++;
                    results.details.push({
                        repository,
                        status: 'success',
                        message: 'Documento baixado com sucesso'
                    });
                } else {
                    results.failed++;
                    results.details.push({
                        repository,
                        status: 'failed',
                        message: result.error
                    });
                    
                    // Salva o erro em arquivo
                    await this.fileManager.saveError(repository, result.error);
                }

                // Pequena pausa entre requisições para não sobrecarregar o GitLab
                await this.delay(1000);

            } catch (error) {
                results.failed++;
                results.details.push({
                    repository,
                    status: 'error',
                    message: error.message
                });
                
                console.error(`❌ Erro inesperado ao processar ${repository}:`, error.message);
                await this.fileManager.saveError(repository, error.message);
            }
        }

        // Gera relatório final
        await this.fileManager.generateReport(results);
        
        console.log(`\n📊 Processamento concluído:`);
        console.log(`   ✅ Sucessos: ${results.successful}`);
        console.log(`   ❌ Falhas: ${results.failed}`);
        console.log(`   📈 Taxa de sucesso: ${((results.successful / results.total) * 100).toFixed(2)}%`);

        return results;
    }

    /**
     * Processa um único repositório
     * @param {string} repositoryName - Nome do repositório
     * @returns {Promise<Object>} Resultado do processamento
     */
    async processRepository(repositoryName) {
        try {
            // Primeiro, garante que a branch existe (cria se necessário)
            console.log(`🔧 Verificando branch '${this.branch}' no repositório ${repositoryName}...`);
            
            if (this.createBranchIfNotExists) {
                const branchExists = await this.gitlabService.ensureBranchExists(repositoryName, this.branch);
                
                if (!branchExists) {
                    return {
                        success: false,
                        error: `Não foi possível criar ou verificar a branch '${this.branch}'`
                    };
                }
            } else {
                // Apenas verifica se a branch existe, sem criar
                const projectId = await this.gitlabService.getProjectId(repositoryName);
                if (!projectId) {
                    return {
                        success: false,
                        error: `Projeto '${repositoryName}' não encontrado`
                    };
                }
                
                const branchExists = await this.gitlabService.branchExists(projectId, this.branch);
                if (!branchExists) {
                    return {
                        success: false,
                        error: `Branch '${this.branch}' não existe no repositório ${repositoryName}`
                    };
                }
            }

            // Busca o documento no GitLab
            console.log(`📄 Buscando documento na branch '${this.branch}'...`);
            const documentResult = await this.gitlabService.getFileContent(
                repositoryName,
                this.documentPath,
                this.branch
            );

            if (!documentResult.success) {
                return documentResult;
            }

            // Salva o documento localmente
            const saved = await this.fileManager.saveDocument(repositoryName, documentResult);
            
            if (!saved) {
                return {
                    success: false,
                    error: 'Falha ao salvar documento localmente'
                };
            }

            return {
                success: true,
                message: `Documento processado com sucesso na branch '${this.branch}'`
            };

        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Testa a conexão com o GitLab
     * @returns {Promise<boolean>} True se a conexão foi bem-sucedida
     */
    async testConnection() {
        return await this.gitlabService.testConnection();
    }

    /**
     * Pausa a execução por um tempo determinado
     * @param {number} ms - Milissegundos para pausar
     * @returns {Promise<void>}
     */
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

module.exports = DocumentDownloader;
