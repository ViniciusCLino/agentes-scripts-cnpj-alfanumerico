const axios = require('axios');

class GitLabService {
    constructor(baseUrl, token) {
        this.baseUrl = baseUrl;
        this.token = token;
        this.api = axios.create({
            baseURL: `${baseUrl}/api/v4`,
            headers: {
                'PRIVATE-TOKEN': token,
                'Content-Type': 'application/json'
            },
            timeout: 30000 // 30 segundos
        });
    }


    /**
     * Busca o conteúdo de um arquivo específico no GitLab
     * @param {string} repositoryName - Nome do repositório
     * @param {string} filePath - Caminho do arquivo no repositório
     * @param {string} branch - Branch do repositório (padrão: 'fix-cnpj-alfanumerico-plan')
     * @returns {Promise<Object>} Conteúdo do arquivo
     */
    async getFileContent(repositoryName, filePath, branch = 'fix-cnpj-alfanumerico-plan') {
        try {
            // Primeiro, busca o ID do projeto pelo nome
            const projectId = await this.getProjectId(repositoryName);
            
            if (!projectId) {
                throw new Error(`Projeto '${repositoryName}' não encontrado`);
            }

            // Busca o arquivo
            const response = await this.api.get(
                `/projects/${projectId}/repository/files/${encodeURIComponent(filePath)}/raw`,
                {
                    params: { ref: branch }
                }
            );

            return {
                success: true,
                content: response.data,
                repository: repositoryName,
                filePath: filePath,
                branch: branch
            };

        } catch (error) {
            console.error(`❌ Erro ao buscar arquivo ${filePath} do repositório ${repositoryName}:`, error.message);
            
            return {
                success: false,
                error: error.message,
                repository: repositoryName,
                filePath: filePath,
                branch: branch
            };
        }
    }

    /**
     * Busca o ID do projeto pelo nome
     * @param {string} repositoryName - Nome do repositório
     * @returns {Promise<string|null>} ID do projeto ou null se não encontrado
     */
    async getProjectId(repositoryName) {
        try {
            // Busca projetos que correspondam ao nome
            const response = await this.api.get('/projects', {
                params: {
                    search: repositoryName,
                    search_namespaces: true,
                    per_page: 100
                }
            });
            const projects = response.data;

            // Procura por correspondência exata do nome
            const exactMatch = projects.find(project => 
                project.name === repositoryName || 
                project.path === repositoryName ||
                project.path_with_namespace.includes(repositoryName)
            );

            if (exactMatch) {
                return exactMatch.id.toString();
            }

            // Se não encontrou correspondência exata, tenta com namespace completo
            const namespacePath = `gestao-de-apolices/cosseguro/java/${repositoryName}`;
            const namespaceMatch = projects.find(project => 
                project.path_with_namespace === namespacePath
            );

            return namespaceMatch ? namespaceMatch.id.toString() : null;

        } catch (error) {
            console.error(`❌ Erro ao buscar ID do projeto ${repositoryName}:`, error.message);
            return null;
        }
    }

    /**
     * Lista todas as branches de um projeto
     * @param {string} projectId - ID do projeto
     * @returns {Promise<Array>} Lista de branches
     */
    async getBranches(projectId) {
        try {
            const response = await this.api.get(`/projects/${projectId}/repository/branches`);
            return response.data;
        } catch (error) {
            console.error(`❌ Erro ao listar branches do projeto ${projectId}:`, error.message);
            return [];
        }
    }

    /**
     * Verifica se uma branch existe no projeto
     * @param {string} projectId - ID do projeto
     * @param {string} branchName - Nome da branch
     * @returns {Promise<boolean>} True se a branch existe
     */
    async branchExists(projectId, branchName) {
        try {
            const branches = await this.getBranches(projectId);
            return branches.some(branch => branch.name === branchName);
        } catch (error) {
            console.error(`❌ Erro ao verificar branch ${branchName}:`, error.message);
            return false;
        }
    }

    /**
     * Cria uma nova branch a partir de uma branch base
     * @param {string} projectId - ID do projeto
     * @param {string} branchName - Nome da nova branch
     * @param {string} baseBranch - Branch base (padrão: 'main' ou 'master')
     * @returns {Promise<boolean>} True se a branch foi criada com sucesso
     */
    async createBranch(projectId, branchName, baseBranch = 'main') {
        try {
            // Primeiro tenta 'main', se não existir, tenta 'master'
            const branches = await this.getBranches(projectId);
            const mainBranch = branches.find(b => b.name === 'main') || branches.find(b => b.name === 'master');
            
            if (!mainBranch) {
                throw new Error('Não foi possível encontrar branch base (main ou master)');
            }

            const response = await this.api.post(`/projects/${projectId}/repository/branches`, {
                branch: branchName,
                ref: mainBranch.name
            });

            console.log(`✅ Branch '${branchName}' criada com sucesso no projeto ${projectId}`);
            return true;

        } catch (error) {
            if (error.response && error.response.status === 409) {
                console.log(`ℹ️ Branch '${branchName}' já existe no projeto ${projectId}`);
                return true;
            }
            console.error(`❌ Erro ao criar branch '${branchName}':`, error.message);
            return false;
        }
    }

    /**
     * Garante que a branch existe no projeto, criando se necessário
     * @param {string} repositoryName - Nome do repositório
     * @param {string} branchName - Nome da branch
     * @returns {Promise<boolean>} True se a branch existe ou foi criada
     */
    async ensureBranchExists(repositoryName, branchName = 'fix-cnpj-alfanumerico-plan') {
        try {
            const projectId = await this.getProjectId(repositoryName);
            
            if (!projectId) {
                throw new Error(`Projeto '${repositoryName}' não encontrado`);
            }

            // Verifica se a branch já existe
            const exists = await this.branchExists(projectId, branchName);
            
            if (exists) {
                console.log(`✅ Branch '${branchName}' já existe no repositório ${repositoryName}`);
                return true;
            }

            // Cria a branch se não existir
            console.log(`🔧 Criando branch '${branchName}' no repositório ${repositoryName}...`);
            return await this.createBranch(projectId, branchName);

        } catch (error) {
            console.error(`❌ Erro ao garantir branch no repositório ${repositoryName}:`, error.message);
            return false;
        }
    }

    /**
     * Testa a conexão com o GitLab
     * @returns {Promise<boolean>} True se a conexão foi bem-sucedida
     */
    async testConnection() {
        try {
            const response = await this.api.get('/user');
            console.log(`✅ Conectado ao GitLab como: ${response.data.name}`);
            return true;
        } catch (error) {
            console.error('❌ Erro ao conectar no GitLab:', error.message);
            return false;
        }
    }
}

module.exports = GitLabService;