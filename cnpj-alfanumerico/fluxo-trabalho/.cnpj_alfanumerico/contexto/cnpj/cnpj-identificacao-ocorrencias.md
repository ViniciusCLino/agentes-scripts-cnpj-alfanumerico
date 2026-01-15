
# Guia para Identificação de Ocorrências de CNPJ em Sistemas

Este documento fornece um roteiro técnico para identificar onde o CNPJ é manipulado dentro de uma aplicação, com o objetivo de facilitar a adaptação ao novo modelo alfanumérico. É útil para equipes que trabalham com sistemas em diferentes linguagens de programação ou com nomes de variáveis internacionalizados.

---

## 🧭 Objetivo

Auxiliar na identificação de todos os pontos onde o CNPJ é referenciado em código-fonte, banco de dados, APIs e interfaces, independentemente do idioma ou convenção de nomenclatura utilizada.

---

## 📌 1. Estratégias de Identificação

### 1.1 Termos Comuns para Busca

Buscar por palavras-chave e variações nos nomes de variáveis, campos e arquivos. Exemplos:

- `cnpj`
- `CNPJ`
- `taxId`, `tax_id`
- `companyId`, `company_id`
- `corpNumber`, `corporate_id`
- `identificationNumber`, `businessNumber`
- `registrationNumber`

> 🔎 Recomenda-se usar buscas insensíveis a maiúsculas e minúsculas.

### 1.2 Extensões de Arquivos a Buscar

| Tipo de Arquivo | Extensões |
|------------------|-----------|
| Código-fonte     | `.ts`, `.js`, `.py`, `.java`, `.cs`, `.go`, `.rb` |
| SQL / Migrations | `.sql`, `.migration`, `.schema` |
| Front-end        | `.html`, `.vue`, `.tsx`, `.jsx` |
| Documentação     | `.md`, `.txt`, `.docx` |
| Configuração     | `.json`, `.yaml`, `.env`, `.xml` |

---

## 🔎 2. Exemplos de Expressões Regulares

Utilize expressões para localizar possíveis validações ou uso direto:

### CNPJ Numérico (formato antigo):
```regex
\b\d{14}\b
```

### CNPJ com pontuação:
```regex
\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}
```

### CNPJ Alfanumérico (formato novo):
```regex
\b[A-Z0-9]{12}\d{2}\b
```

---

## 🛠️ 3. Ferramentas Sugeridas

### CLI e editores
- `grep -rni "cnpj" ./`
- `ripgrep (rg)`: mais rápido e eficaz para projetos grandes
- Pesquisa em múltiplas linguagens com VSCode, JetBrains, Sublime Text

### SAST Tools
- Ferramentas como SonarQube ou Semgrep para rastrear padrões em código

---

## 📄 4. Checklist de Locais Comuns

| Local                      | Ação Recomendável |
|---------------------------|-------------------|
| Modelos / Entidades       | Verificar tipo de dado, validações, tamanho |
| Controllers / Serviços    | Identificar regras de negócio, máscaras e DV |
| Front-end / Formulários   | Máscara de input, validação regex, placeholder |
| Banco de Dados            | Tipos, índices, chaves estrangeiras |
| Integrações / APIs        | Esquemas de request/response, headers |
| Testes Automatizados      | Mocks, fixtures, asserts de validação |

---

## 🧩 5. Parâmetro de Entrada: Nome da Chave

Quando os sistemas usam nomes genéricos ou internacionalizados, solicite ou extraia do cliente uma **lista de aliases utilizados para o campo CNPJ**. Exemplo de entrada:

```json
{
  "aliases": ["cnpj", "taxId", "registrationNumber", "corpNumber"]
}
```

Utilize esses aliases como base para sua busca automatizada em código.

---

## ✅ 6. Conclusão

A identificação precisa das ocorrências de CNPJ é o primeiro passo essencial para adequar os sistemas ao novo formato alfanumérico. Esta auditoria técnica pode ser automatizada parcialmente, mas é recomendável revisão manual para os pontos críticos de negócio.

---

Se necessário, este guia pode ser integrado a ferramentas de CI/CD para análise contínua.
