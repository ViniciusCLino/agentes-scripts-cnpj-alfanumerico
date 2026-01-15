const fs = require('fs');
const csv = require('csv-parser');
const path = require('path');

/**
 * Lê um arquivo CSV e retorna uma lista de repositórios
 * @param {string} csvFilePath - Caminho para o arquivo CSV
 * @returns {Promise<Array<string>>} Lista de nomes de repositórios
 */
async function readRepositoriesFromCSV(csvFilePath) {
    return new Promise((resolve, reject) => {
        const repositories = [];
        
        if (!fs.existsSync(csvFilePath)) {
            reject(new Error(`Arquivo CSV não encontrado: ${csvFilePath}`));
            return;
        }

        fs.createReadStream(csvFilePath)
            .pipe(csv())
            .on('data', (row) => {
                // Assumindo que o CSV tem uma coluna chamada 'repository' ou 'repositorio'
                // Se não tiver, pega a primeira coluna
                const repoName = row.repository || row.repositorio || Object.values(row)[0];
                if (repoName && repoName.trim()) {
                    repositories.push(repoName.trim());
                }
            })
            .on('end', () => {
                console.log(`📋 ${repositories.length} repositórios encontrados no CSV`);
                resolve(repositories);
            })
            .on('error', (error) => {
                reject(new Error(`Erro ao ler CSV: ${error.message}`));
            });
    });
}

/**
 * Cria um arquivo CSV de exemplo se não existir
 * @param {string} csvFilePath - Caminho onde criar o arquivo de exemplo
 */
function createExampleCSV(csvFilePath) {
    const exampleContent = `repository
exemplo-repositorio-1
exemplo-repositorio-2
exemplo-repositorio-3`;
    
    fs.writeFileSync(csvFilePath, exampleContent, 'utf8');
    console.log(`📝 Arquivo CSV de exemplo criado: ${csvFilePath}`);
}

module.exports = {
    readRepositoriesFromCSV,
    createExampleCSV
};
