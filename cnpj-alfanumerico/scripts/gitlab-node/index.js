const axios = require('axios');
const createCsvWriter = require('csv-writer').createObjectCsvWriter;
require('dotenv').config();

/**
 * GitLab Repositories Exporter
 * Compatível com GitLab Community Edition 9.5.5 (API v3)
 * 
 * Principais adaptações para API v3:
 * - URL: /api/v3/projects (em vez de /api/v4/projects)
 * - Autenticação: PRIVATE-TOKEN (em vez de Authorization: Bearer)
 * - Removido parâmetro 'simple' (não disponível na API v3)
 * - Fallback para propriedades que podem ter nomes diferentes na API v3
 */

class GitLabReposExporter {
    constructor() {
        this.gitlabUrl = process.env.GITLAB_URL || 'https://gitlab.com';
        this.apiToken = process.env.GITLAB_API_TOKEN;
        this.outputFile = process.env.OUTPUT_FILE || 'repositorios_gitlab.csv';
        
        if (!this.apiToken) {
            throw new Error('GITLAB_API_TOKEN é obrigatório. Configure a variável de ambiente.');
        }
    }

    async listarRepositorios() {
        try {
            console.log('🔍 Buscando repositórios do GitLab...');
            
            const repositorios = [];
            let pagina = 1;
            let temMaisPaginas = true;

            while (temMaisPaginas) {
                console.log(`📄 Processando página ${pagina}...`);
                
                const response = await axios.get(`${this.gitlabUrl}/api/v3/projects`, {
                    headers: {
                        'PRIVATE-TOKEN': this.apiToken,
                        'Content-Type': 'application/json'
                    },
                    params: {
                        page: pagina,
                        per_page: 100, // Máximo permitido pela API
                        membership: true, // Apenas repositórios que o usuário tem acesso
                        order_by: 'last_activity_at',
                        sort: 'desc'
                    }
                });

                const reposDaPagina = response.data;
                
                if (reposDaPagina.length === 0) {
                    temMaisPaginas = false;
                } else {
                    repositorios.push(...reposDaPagina);
                    pagina++;
                }

                // Pequena pausa para não sobrecarregar a API
                await new Promise(resolve => setTimeout(resolve, 100));
            }

            console.log(`✅ Total de repositórios encontrados: ${repositorios.length}`);
            return repositorios;

        } catch (error) {
            console.error('❌ Erro ao buscar repositórios:', error.message);
            if (error.response) {
                console.error('Status:', error.response.status);
                console.error('Dados:', error.response.data);
            }
            throw error;
        }
    }

    async salvarCSV(repositorios) {
        try {
            console.log('💾 Salvando repositórios em arquivo CSV...');

            const csvWriter = createCsvWriter({
                path: this.outputFile,
                fieldDelimiter: ';', // Usar ponto e vírgula como separador
                header: [
                    { id: 'id', title: 'ID' },
                    { id: 'name', title: 'Nome' },
                    { id: 'path', title: 'Caminho' },
                    { id: 'description', title: 'Descrição' },
                    { id: 'web_url', title: 'URL' },
                    { id: 'visibility', title: 'Visibilidade' },
                    { id: 'default_branch', title: 'Branch Padrão' },
                    { id: 'created_at', title: 'Data de Criação' },
                    { id: 'last_activity_at', title: 'Última Atividade' },
                    { id: 'star_count', title: 'Estrelas' },
                    { id: 'forks_count', title: 'Forks' },
                    { id: 'open_issues_count', title: 'Issues Abertas' },
                    { id: 'namespace', title: 'Namespace' },
                    { id: 'archived', title: 'Arquivado' }
                ]
            });

            // Preparar dados para o CSV (compatível com API v3)
            const dadosCSV = repositorios.map(repo => ({
                id: repo.id,
                name: repo.name || '',
                path: repo.path || '',
                description: repo.description || '',
                web_url: repo.web_url || '',
                visibility: repo.visibility || repo.public ? 'public' : 'private', // Fallback para API v3
                default_branch: repo.default_branch || '',
                created_at: repo.created_at ? new Date(repo.created_at).toLocaleString('pt-BR') : '',
                last_activity_at: repo.last_activity_at ? new Date(repo.last_activity_at).toLocaleString('pt-BR') : '',
                star_count: repo.star_count || 0,
                forks_count: repo.forks_count || 0,
                open_issues_count: repo.open_issues_count || 0,
                namespace: repo.namespace ? (repo.namespace.full_path || repo.namespace.path) : '',
                archived: repo.archived ? 'Sim' : 'Não'
            }));

            await csvWriter.writeRecords(dadosCSV);
            console.log(`✅ Arquivo CSV salvo com sucesso: ${this.outputFile}`);
            console.log(`📊 Total de registros salvos: ${dadosCSV.length}`);

        } catch (error) {
            console.error('❌ Erro ao salvar arquivo CSV:', error.message);
            throw error;
        }
    }

    async executar() {
        try {
            console.log('🚀 Iniciando exportação de repositórios do GitLab...');
            console.log(`🔗 URL do GitLab: ${this.gitlabUrl}`);
            console.log(`📁 Arquivo de saída: ${this.outputFile}`);
            console.log('');

            const repositorios = await this.listarRepositorios();
            await this.salvarCSV(repositorios);

            console.log('');
            console.log('🎉 Exportação concluída com sucesso!');

        } catch (error) {
            console.error('💥 Falha na exportação:', error.message);
            process.exit(1);
        }
    }
}

// Executar a aplicação
if (require.main === module) {
    const exporter = new GitLabReposExporter();
    exporter.executar();
}

module.exports = GitLabReposExporter;
