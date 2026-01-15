const fs = require('fs-extra');
const path = require('path');

class FileManager {
    constructor() {
        this.outputDir = 'documento_projetos';
    }

    /**
     * Cria o diretório de saída se não existir
     */
    async ensureOutputDirectory() {
        try {
            await fs.ensureDir(this.outputDir);
            console.log(`📁 Diretório de saída: ${path.resolve(this.outputDir)}`);
        } catch (error) {
            throw new Error(`Erro ao criar diretório de saída: ${error.message}`);
        }
    }

    /**
     * Salva o conteúdo de um documento em arquivo JSON
     * @param {string} repositoryName - Nome do repositório
     * @param {Object} documentData - Dados do documento
     * @returns {Promise<boolean>} True se salvou com sucesso
     */
    async saveDocument(repositoryName, documentData) {
        try {
            // Limpa o nome do repositório para usar como nome de arquivo
            const fileName = this.sanitizeFileName(repositoryName);
            const filePath = path.join(this.outputDir, `${fileName}.json`);
            
            // Prepara os dados para salvar
            const fileContent = {
                repository: repositoryName,
                timestamp: new Date().toISOString(),
                document: documentData.content || documentData,
                metadata: {
                    source: 'GitLab',
                    branch: documentData.branch || 'fix-cnpj-alfanumerico-plan',
                    filePath: documentData.filePath || '.cnpj_alfanumerico/projeto/projeto.json'
                }
            };

            await fs.writeJSON(filePath, fileContent, { spaces: 2 });
            console.log(`✅ Documento salvo: ${fileName}.json`);
            return true;

        } catch (error) {
            console.error(`❌ Erro ao salvar documento do repositório ${repositoryName}:`, error.message);
            return false;
        }
    }

    /**
     * Salva um arquivo de erro para repositórios que falharam
     * @param {string} repositoryName - Nome do repositório
     * @param {string} errorMessage - Mensagem de erro
     * @returns {Promise<boolean>} True se salvou com sucesso
     */
    async saveError(repositoryName, errorMessage) {
        try {
            const fileName = this.sanitizeFileName(repositoryName);
            const filePath = path.join(this.outputDir, `${fileName}_ERROR.json`);
            
            const errorContent = {
                repository: repositoryName,
                timestamp: new Date().toISOString(),
                error: errorMessage,
                status: 'failed'
            };

            await fs.writeJSON(filePath, errorContent, { spaces: 2 });
            console.log(`⚠️ Erro salvo: ${fileName}_ERROR.json`);
            return true;

        } catch (error) {
            console.error(`❌ Erro ao salvar arquivo de erro para ${repositoryName}:`, error.message);
            return false;
        }
    }

    /**
     * Limpa caracteres inválidos do nome do arquivo
     * @param {string} fileName - Nome original
     * @returns {string} Nome limpo
     */
    sanitizeFileName(fileName) {
        return fileName
            .replace(/[<>:"/\\|?*]/g, '_') // Substitui caracteres inválidos
            .replace(/\s+/g, '_') // Substitui espaços por underscore
            .toLowerCase();
    }

    /**
     * Lista todos os arquivos salvos no diretório de saída
     * @returns {Promise<Array<string>>} Lista de arquivos
     */
    async listSavedFiles() {
        try {
            const files = await fs.readdir(this.outputDir);
            const jsonFiles = files.filter(file => file.endsWith('.json'));
            return jsonFiles;
        } catch (error) {
            console.error('Erro ao listar arquivos salvos:', error.message);
            return [];
        }
    }

    /**
     * Gera um relatório de resumo da operação
     * @param {Object} results - Resultados da operação
     * @returns {Promise<boolean>} True se salvou com sucesso
     */
    async generateReport(results) {
        try {
            const reportPath = path.join(this.outputDir, 'relatorio_operacao.json');
            
            const report = {
                timestamp: new Date().toISOString(),
                totalRepositories: results.total,
                successful: results.successful,
                failed: results.failed,
                successRate: `${((results.successful / results.total) * 100).toFixed(2)}%`,
                details: results.details
            };

            await fs.writeJSON(reportPath, report, { spaces: 2 });
            console.log(`📊 Relatório gerado: relatorio_operacao.json`);
            return true;

        } catch (error) {
            console.error('Erro ao gerar relatório:', error.message);
            return false;
        }
    }
}

module.exports = FileManager;
