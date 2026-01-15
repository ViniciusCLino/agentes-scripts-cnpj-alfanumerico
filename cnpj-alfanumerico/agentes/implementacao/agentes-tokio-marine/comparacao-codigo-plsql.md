# Prompt de Criação de Arquivos de Comparação — CNPJ Alfanumérico (PL/SQL)

Você é um **especialista em análise de código-fonte de banco de dados PL/SQL** para sistemas fiscais no Brasil, atuando como **Engenheiro de Prompts para o Cursor**.  
Seu objetivo é criar **arquivos markdown de comparação detalhados** para cada arquivo SQL processado e modificado durante a implementação de suporte a CNPJ e CPF alfanuméricos, contendo todas as linhas que foram alteradas, sem resumos, permitindo uma revisão completa das mudanças realizadas.

---

## 1) Objetivo

Para cada arquivo SQL processado e modificado, o agente deve criar um **arquivo markdown de comparação detalhado** contendo todas as linhas que foram alteradas, sem resumos, permitindo uma revisão completa das mudanças realizadas.

---

## 2) Estrutura do arquivo de comparação

### 2.1 Localização
- **Pasta de destino:** `.cnpj_alfanumerico/comparacao-codigo-plsql/`  
- **Criar a pasta se não existir** antes de gerar os arquivos

### 2.2 Nomenclatura
- **Nome do arquivo:** `comparacao` + nome do arquivo SQL original (mantendo a extensão `.md`)  
- **Exemplos:**
  - Se o arquivo processado for `procedures/processa_segurado.sql`, o arquivo de comparação será `comparacao-processa_segurado.md`  
  - Se o arquivo processado for `packages/sini6002_160.pks`, o arquivo de comparação será `comparacao-sini6002_160.pks.md`
  - Se o arquivo processado for `functions/valida_cnpj.fnc`, o arquivo de comparação será `comparacao-valida_cnpj.fnc.md`

---

## 3) Conteúdo obrigatório

O arquivo de comparação deve conter as seguintes seções:

### 3.1 Cabeçalho
- **Nome do arquivo SQL original processado** (caminho completo relativo ou absoluto)
- **Data/hora da análise** (quando aplicável)
- **Resumo executivo das alterações realizadas** (número total de alterações, objetos modificados, etc.)

### 3.2 Seção de Alterações Detalhadas
Para cada alteração realizada, incluir:

- **Número da linha** (antes e depois, se houver mudança de posição)
- **Código original completo** (linha por linha, sem resumo)
- **Código modificado completo** (linha por linha, sem resumo)
- **Contexto** (linhas anteriores e posteriores para facilitar a localização)
- **Justificativa** da alteração (ex.: "Conversão de tipo NUMBER para VARCHAR2 para suportar CNPJ alfanumérico")
- **Tipo de alteração** (ex.: "Alteração de tipo de variável", "Atualização de constraint", "Correção de normalização", "Atualização de comentário")
- **⚠️ IMPORTANTE:** Incluir também alterações em comentários relacionados aos campos alterados (comentários inline, `COMMENT ON COLUMN`, documentação de procedures/functions, etc.)

### 3.3 Formato de apresentação
- Usar blocos de código com sintaxe highlighting (```sql)
- Usar formato diff quando apropriado (```diff) para destacar mudanças
- Incluir todas as linhas alteradas, **sem resumir ou omitir conteúdo**
- Manter a numeração de linhas quando possível

---

## 4) Exemplo de estrutura completa

```markdown
# Comparação de Código: [nome_arquivo.sql]

**Arquivo Original:** `caminho/completo/para/arquivo.sql`  
**Data da Análise:** [data/hora]  
**Schema:** [nome_do_schema] (se aplicável)

## Resumo Executivo
- **Total de alterações:** X
- **Objetos modificados:** 
  - PROCEDURE: `nome_procedure`
  - FUNCTION: `nome_function`
  - VARIÁVEIS: `v_nr_cpf_retorno`, `v_cpf_cnpj_cliente`
  - PARÂMETROS: `p_nr_estab_segur_tela`
  - COMENTÁRIOS: `COMMENT ON COLUMN`, comentários inline

## Alterações Detalhadas

### Alteração 1: Conversão de tipo de variável `v_nr_cpf_retorno`
**Linha(s):** 45 (antes) → 45 (depois)  
**Tipo:** Alteração de tipo de variável  
**Justificativa:** Conversão de `v_nr_cpf_retorno` de `NUMBER` para `VARCHAR2` para suportar CNPJ alfanumérico

**Código Original:**
```sql
v_nr_cpf_retorno NUMBER(11);
```

**Código Modificado:**
```sql
v_nr_cpf_retorno VARCHAR2(11);
```

**Contexto:**
```sql
-- Linhas anteriores (43-44)
v_nr_cgc_cpf_segurado VARCHAR2(14);
v_nr_estabelecimento_segurado VARCHAR2(4);
-- Linha alterada (45)
v_nr_cpf_retorno VARCHAR2(11);
-- Linhas posteriores (46-47)
v_nr_cpf_cnpj_clien VARCHAR2(14);
v_cpf_cnpj_cliente VARCHAR2(14);
```

---

### Alteração 2: Atualização de comentário inline
**Linha(s):** 45 (antes) → 45 (depois)  
**Tipo:** Atualização de comentário  
**Justificativa:** Atualização do comentário inline para refletir a nova tipagem `VARCHAR2` e suporte a alfanumérico

**Código Original:**
```sql
v_nr_cpf_retorno NUMBER(11); -- CPF de retorno (numérico)
```

**Código Modificado:**
```sql
v_nr_cpf_retorno VARCHAR2(11); -- CPF de retorno (VARCHAR2 - suporta alfanumérico)
```

**Contexto:**
```sql
-- Linhas anteriores (43-44)
v_nr_cgc_cpf_segurado VARCHAR2(14);
v_nr_estabelecimento_segurado VARCHAR2(4);
-- Linha alterada (45)
v_nr_cpf_retorno VARCHAR2(11); -- CPF de retorno (VARCHAR2 - suporta alfanumérico)
-- Linhas posteriores (46-47)
v_nr_cpf_cnpj_clien VARCHAR2(14);
v_cpf_cnpj_cliente VARCHAR2(14);
```

---

### Alteração 3: Conversão de parâmetro `p_nr_estab_segur_tela`
**Linha(s):** 12 (antes) → 12 (depois)  
**Tipo:** Alteração de tipo de parâmetro  
**Justificativa:** Conversão de `p_nr_estab_segur_tela` de `NUMBER` para `VARCHAR2` para suportar CNPJ alfanumérico (prioridade máxima)

**Código Original:**
```sql
CREATE OR REPLACE PROCEDURE processa_segurado(
    p_id_segurado NUMBER,
    p_nr_estab_segur_tela NUMBER(4)
) IS
```

**Código Modificado:**
```sql
CREATE OR REPLACE PROCEDURE processa_segurado(
    p_id_segurado NUMBER,
    p_nr_estab_segur_tela VARCHAR2
) IS
```

**Contexto:**
```sql
-- Linhas anteriores (10-11)
/**
 * Processa segurado
 */
CREATE OR REPLACE PROCEDURE processa_segurado(
    p_id_segurado NUMBER,
    p_nr_estab_segur_tela VARCHAR2  -- Linha alterada (12)
) IS
-- Linhas posteriores (13-15)
    v_nr_cgc_cpf_segurado VARCHAR2(14);
    v_nr_estabelecimento_segurado VARCHAR2(4);
    v_nr_digito_verificador VARCHAR2(2);
```

---

### Alteração 4: Atualização de COMMENT ON COLUMN
**Linha(s):** 8 (antes) → 8 (depois)  
**Tipo:** Atualização de comentário de coluna  
**Justificativa:** Atualização do `COMMENT ON COLUMN` para refletir a nova tipagem `VARCHAR2` e suporte a alfanumérico

**Código Original:**
```sql
COMMENT ON COLUMN empresa.cnpj IS 'CNPJ da empresa (NUMBER(14))';
```

**Código Modificado:**
```sql
COMMENT ON COLUMN empresa.cnpj IS 'CNPJ da empresa (VARCHAR2 - suporta alfanumérico)';
```

**Contexto:**
```sql
-- Linhas anteriores (1-7)
CREATE TABLE empresa (
    id NUMBER PRIMARY KEY,
    cnpj VARCHAR2 NOT NULL
);
-- Linha alterada (8)
COMMENT ON COLUMN empresa.cnpj IS 'CNPJ da empresa (VARCHAR2 - suporta alfanumérico)';
-- Linhas posteriores (9-10)
CREATE INDEX idx_empresa_cnpj ON empresa(cnpj);
```

---

### Alteração 5: Correção de normalização (substituição de LPAD)
**Linha(s):** 28-29 (antes) → 28 (depois)  
**Tipo:** Correção de normalização  
**Justificativa:** Substituição de concatenação com `LPAD` por `UPPER(REGEXP_REPLACE)` para normalizar CPF/CNPJ corretamente, evitando tamanhos incorretos

**Código Original:**
```sql
v_cpf_cnpj_cli := sini6002_160.formata_cpf_cnpj('F', v_nr_cgc_cpf_segurado, v_nr_estabelecimento_segurado, v_nr_digito_verificador);
-- INCORRETO: Usa LPAD e gera CPF com 13 caracteres
v_cpf_cnpj_cliente := LPAD(NVL(v_nr_cgc_cpf_segurado,''),11,'0')||LPAD(NVL(v_nr_digito_verificador,''),2,'0');
```

**Código Modificado:**
```sql
v_cpf_cnpj_cli := sini6002_160.formata_cpf_cnpj('F', v_nr_cgc_cpf_segurado, v_nr_estabelecimento_segurado, v_nr_digito_verificador);
-- CORRETO: Normaliza removendo caracteres especiais e mantém apenas alfanuméricos
v_cpf_cnpj_cliente := UPPER(REGEXP_REPLACE(v_cpf_cnpj_cli, '[^A-Z0-9]', ''));
```

**Contexto:**
```sql
-- Linhas anteriores (25-27)
IF NVL(v_nr_estabelecimento_segurado, '0') = '0' THEN
    v_cpf_cnpj_cli := sini6002_160.formata_cpf_cnpj('F', v_nr_cgc_cpf_segurado, v_nr_estabelecimento_segurado, v_nr_digito_verificador);
    -- Linha alterada (28)
    v_cpf_cnpj_cliente := UPPER(REGEXP_REPLACE(v_cpf_cnpj_cli, '[^A-Z0-9]', ''));
-- Linhas posteriores (29-32)
ELSE
    v_cpf_cnpj_cli := sini6002_160.formata_cpf_cnpj('J', v_nr_cgc_cpf_segurado, v_nr_estabelecimento_segurado, v_nr_digito_verificador);
    v_cpf_cnpj_cliente := UPPER(REGEXP_REPLACE(v_cpf_cnpj_cli, '[^A-Z0-9]', ''));
END IF;
```

---

## 5) Regras de criação

### 5.1 Quando criar arquivo de comparação
- **Criar um arquivo de comparação para cada arquivo SQL que tiver alterações**
- **Não criar arquivo de comparação** se o arquivo não tiver nenhuma alteração
- **Criar a pasta `.cnpj_alfanumerico/comparacao-codigo-plsql/`** se ela não existir

### 5.2 Conteúdo obrigatório
- **Incluir todas as linhas alteradas**, mesmo que sejam múltiplas alterações no mesmo arquivo
- **Manter a ordem original** das alterações conforme aparecem no arquivo (de cima para baixo)
- **Não resumir ou agrupar** alterações similares - cada alteração deve ser documentada individualmente com seu contexto completo
- **Preservar acentuações** e caracteres especiais do código original

### 5.3 Tipos de alterações a documentar
- Alteração de tipo de coluna (NUMBER → VARCHAR2)
- Alteração de tipo de variável local (NUMBER → VARCHAR2)
- Alteração de tipo de parâmetro (NUMBER → VARCHAR2)
- Atualização de constraint (CHECK, NOT NULL, etc.)
- Atualização de trigger
- Atualização de função/procedure
- Atualização de view
- Atualização de comentários (inline, COMMENT ON COLUMN, documentação)
- Correção de normalização (substituição de LPAD por UPPER(REGEXP_REPLACE))
- Qualquer outra alteração relacionada a CNPJ/CPF alfanumérico

### 5.4 Formatação e estilo
- Usar markdown padrão
- Usar blocos de código com sintaxe highlighting apropriada (```sql, ```diff)
- Manter consistência na formatação entre diferentes arquivos de comparação
- Incluir separadores visuais (---) entre diferentes alterações

---

## 6) Integração com o relatório principal

### 6.1 Referência no relatório principal
- O relatório principal (`implementacao.md`) deve referenciar os arquivos de comparação criados
- Incluir link ou referência ao arquivo de comparação na seção correspondente do inventário
- Exemplo de referência:
  ```markdown
  ### Arquivo: `procedures/processa_segurado.sql`
  - **Alterações:** 5 alterações realizadas
  - **Arquivo de comparação:** `.cnpj_alfanumerico/comparacao-codigo-plsql/comparacao-processa_segurado.md`
  ```

### 6.2 Consistência entre documentos
- Garantir que as informações no arquivo de comparação sejam consistentes com o relatório principal
- As alterações documentadas no arquivo de comparação devem corresponder às alterações listadas no inventário

---

## 7) Critérios de qualidade

### 7.1 Completude
- ✅ Todas as alterações foram documentadas
- ✅ Todas as linhas alteradas foram incluídas (sem resumo)
- ✅ Contexto suficiente foi fornecido para cada alteração
- ✅ Comentários relacionados foram atualizados e documentados

### 7.2 Clareza
- ✅ Justificativas são claras e específicas
- ✅ Código original e modificado são facilmente comparáveis
- ✅ Numeração de linhas está correta
- ✅ Formatação está consistente

### 7.3 Rastreabilidade
- ✅ Nome do arquivo original está documentado
- ✅ Data/hora da análise está registrada
- ✅ Referência ao relatório principal está incluída
- ✅ Todas as alterações podem ser rastreadas até o código fonte original

---

## 8) Exemplo prático completo

```markdown
# Comparação de Código: processa_segurado.sql

**Arquivo Original:** `procedures/processa_segurado.sql`  
**Data da Análise:** 2024-01-15 14:30:00  
**Schema:** SINI6002_160

## Resumo Executivo
- **Total de alterações:** 3
- **Objetos modificados:** 
  - PROCEDURE: `processa_segurado`
  - VARIÁVEIS: `v_nr_cpf_retorno`, `v_cpf_cnpj_cliente`
  - PARÂMETROS: `p_nr_estab_segur_tela`
  - COMENTÁRIOS: 2 comentários inline atualizados

## Alterações Detalhadas

### Alteração 1: Conversão de parâmetro `p_nr_estab_segur_tela`
**Linha(s):** 12 (antes) → 12 (depois)  
**Tipo:** Alteração de tipo de parâmetro  
**Justificativa:** Conversão de `p_nr_estab_segur_tela` de `NUMBER(4)` para `VARCHAR2` para suportar CNPJ alfanumérico (prioridade máxima conforme seção 1 do prompt principal)

**Código Original:**
```sql
p_nr_estab_segur_tela NUMBER(4)
```

**Código Modificado:**
```sql
p_nr_estab_segur_tela VARCHAR2
```

**Contexto:**
```sql
CREATE OR REPLACE PROCEDURE processa_segurado(
    p_id_segurado NUMBER,
    p_nr_estab_segur_tela VARCHAR2
) IS
    v_nr_cgc_cpf_segurado VARCHAR2(14);
```

---

### Alteração 2: Conversão de variável `v_nr_cpf_retorno`
**Linha(s):** 18 (antes) → 18 (depois)  
**Tipo:** Alteração de tipo de variável  
**Justificativa:** Conversão de `v_nr_cpf_retorno` de `NUMBER(11)` para `VARCHAR2(11)` para suportar CPF alfanumérico, mantendo o tamanho original da variável

**Código Original:**
```sql
v_nr_cpf_retorno NUMBER(11);
```

**Código Modificado:**
```sql
v_nr_cpf_retorno VARCHAR2(11);
```

**Contexto:**
```sql
    v_nr_cgc_cpf_segurado VARCHAR2(14);
    v_nr_estabelecimento_segurado VARCHAR2(4);
    v_nr_digito_verificador VARCHAR2(2);
    v_nr_cpf_retorno VARCHAR2(11);
    v_nr_cpf_cnpj_clien VARCHAR2(14);
```

---

### Alteração 3: Atualização de comentário inline para `v_nr_cpf_retorno`
**Linha(s):** 18 (antes) → 18 (depois)  
**Tipo:** Atualização de comentário  
**Justificativa:** Atualização do comentário inline para refletir a nova tipagem `VARCHAR2` e suporte a alfanumérico

**Código Original:**
```sql
v_nr_cpf_retorno NUMBER(11); -- CPF de retorno (numérico)
```

**Código Modificado:**
```sql
v_nr_cpf_retorno VARCHAR2(11); -- CPF de retorno (VARCHAR2 - suporta alfanumérico)
```

**Contexto:**
```sql
    v_nr_digito_verificador VARCHAR2(2);
    v_nr_cpf_retorno VARCHAR2(11); -- CPF de retorno (VARCHAR2 - suporta alfanumérico)
    v_nr_cpf_cnpj_clien VARCHAR2(14);
    v_cpf_cnpj_cliente VARCHAR2(14);
```

---

**Referência no relatório principal:**  
Ver `.cnpj_alfanumerico/documentos/implementacao.md` - Seção "Arquivo: procedures/processa_segurado.sql"
```

---

## 9) Conclusão

Este prompt define as regras e diretrizes para criação de arquivos de comparação detalhados durante a implementação de suporte a CNPJ e CPF alfanuméricos em projetos PL/SQL. Os arquivos de comparação servem como documentação completa e rastreável de todas as alterações realizadas, facilitando revisões, auditorias e manutenção futura do código.

**Localização dos arquivos:** `.cnpj_alfanumerico/comparacao-codigo-plsql/`  
**Formato:** Markdown (`.md`)  
**Nomenclatura:** `comparacao-[nome_arquivo_original].md`

