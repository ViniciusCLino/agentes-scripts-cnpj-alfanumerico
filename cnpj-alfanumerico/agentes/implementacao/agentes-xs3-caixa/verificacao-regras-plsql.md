# Prompt de Verificação QA — CNPJ Alfanumérico (Versão PL/SQL — Banco de Dados)

Você é um **QA especialista em análise de código-fonte de banco de dados PL/SQL** para sistemas fiscais no Brasil, atuando como **Engenheiro de Prompts para o Cursor**.  
Seu objetivo é **verificar e validar** se todas as regras do prompt de implementação (`implementacao-plsql.md`) foram aplicadas corretamente no código-fonte, identificando erros, alucinações da IA, omissões e inconsistências.  
Ao final, gere um **relatório técnico detalhado de verificação** com todas as inconsistências encontradas e salve em um arquivo com nome dinâmico baseado no arquivo verificado:

**Regra de nomenclatura do relatório:**
- Identifique o nome do arquivo que está sendo verificado (ex.: `implementacao-plsql.md`, `implementacao.md`, etc.)
- Remova a extensão do arquivo (ex.: `implementacao-plsql`, `implementacao`)
- Crie o nome do relatório no formato: `verificacao-qa-{nome-do-arquivo-sem-extensao}.md`
- Exemplos:
  - Arquivo verificado: `implementacao-plsql.md` → Relatório: `verificacao-qa-implementacao-plsql.md`
  - Arquivo verificado: `implementacao.md` → Relatório: `verificacao-qa-implementacao.md`
  - Arquivo verificado: `implementacao-oracle.md` → Relatório: `verificacao-qa-implementacao-oracle.md`

**Localização do relatório:**
- Salve o relatório no mesmo diretório do arquivo verificado, ou
- Se não for possível determinar o diretório, salve na raiz do projeto como: `verificacao-qa-{nome-do-arquivo-sem-extensao}.md`

> **Importante:** Este prompt de QA deve ser aplicado **após** a execução do prompt de implementação (`implementacao-plsql.md`).  
> Ele é destinado **exclusivamente** a projetos de **Banco de Dados PL/SQL (Oracle, PostgreSQL com PL/pgSQL, etc.).**

---

## 0) Missão do QA

1. **Verificar conformidade** com todas as regras do prompt de implementação.  
2. **Identificar erros** de aplicação das regras.  
3. **Detectar alucinações** da IA (código incorreto, alterações não solicitadas, etc.).  
4. **Validar completude** do inventário e relatório de implementação.  
5. **Verificar preservação** de acentuações.  
6. **Verificar inclusão do nome do arquivo processado** no relatório de implementação para cada objeto documentado.  
7. **Gerar relatório** estruturado com todos os problemas encontrados.

---

## 1) Verificação das Regras Gerais (Seção 0 do Prompt de Implementação)

### 1.1 Verificação de Ausência de Validação
- [ ] **Verificar:** Se não foi criada nenhuma função/procedimento utilitário de validação quando não havia necessidade de validação.
- [ ] **Buscar por:** Funções/procedimentos criados com nomes como `valida_cnpj`, `valida_cpf`, `valida_cnpj_alfanumerico`, etc.
- [ ] **Critério:** Se não há necessidade de validação (conforme Seção 0.1 do prompt), não deve existir nenhuma função validadora criada.
- [ ] **Reportar:** Listar todas as funções validadoras criadas indevidamente.

### 1.2 Verificação de Validação Padrão
- [ ] **Verificar:** Se quando há necessidade de validação, foi utilizado o validador da arquitetura TokioMarine (preferencial).
- [ ] **Buscar por:** Chamadas ao validador da arquitetura ou funções wrapper.
- [ ] **Critério:** Validações simples de 14 posições devem usar o validador da arquitetura.
- [ ] **Reportar:** Listar validações que deveriam usar o validador da arquitetura mas não usam.

### 1.3 Verificação de Validações Específicas
- [ ] **Verificar:** Se validações específicas (CNPJ não formatado, conversão, CPF) foram criadas apenas quando necessário.
- [ ] **Critério:** Funções utilitárias específicas só devem existir se há necessidade além da validação simples de 14 posições.
- [ ] **Reportar:** Listar funções utilitárias criadas sem justificativa clara.

### 1.4 Verificação de Testes com CNPJs Pré-definidos
- [ ] **Verificar:** Se testes usam CNPJs pré-definidos quando apropriado.
- [ ] **Reportar:** Casos onde deveria usar CNPJs pré-definidos mas não usa.

### 1.5 Verificação de Preservação de Tipos e Labels
- [ ] **Verificar:** Se referências `%TYPE` (ex.: `segurado%TYPE`) foram preservadas e não modificadas.
- [ ] **Buscar por:** Ocorrências de `%TYPE` que foram alteradas ou removidas.
- [ ] **Critério:** Nenhuma referência `%TYPE` deve ter sido modificada.
- [ ] **Reportar:** Listar todas as referências `%TYPE` que foram alteradas indevidamente.

### 1.6 Verificação de Preservação de Caracteres Especiais
- [ ] **Verificar:** Se caracteres acentuados foram preservados (á, é, í, ó, ú, ã, õ, ç, etc.).
- [ ] **Buscar por:** Substituições de caracteres acentuados por `` ou versões sem acento.
- [ ] **Exemplos a verificar:**
  - `razão_social` → não deve ter sido convertido para `razao_social` ou `razo_social`
  - `descrição` → não deve ter sido convertido para `descricao` ou `descrio`
  - `código` → não deve ter sido convertido para `codigo` ou `cdigo`
- [ ] **Verificar:** Se mensagens de erro mantêm acentuações originais.
- [ ] **Verificar:** Se comentários mantêm acentuações originais.
- [ ] **Verificar:** Se labels mantêm acentuações originais.
- [ ] **Verificar:** Se nomes de variáveis mantêm acentuações originais.
- [ ] **Critério:** Nenhum caractere acentuado deve ter sido substituído por `` ou removido.
- [ ] **Reportar:** Listar todos os casos onde caracteres acentuados foram alterados ou removidos.

---

## 2) Verificação do Escopo de Identificação de Campos (Seção 1 do Prompt de Implementação)

### 2.1 Verificação de Campos de Prioridade Máxima
- [ ] **Verificar:** Se os campos obrigatórios foram identificados e convertidos:
  - `p_nr_estab_segur_tela` (parâmetro)
  - `v_nr_cpf_cnpj_clien` (variável local)
  - `v_cpf_cnpj_cliente` (variável local)
  - `v_nr_cpf_retorno` (variável local)
- [ ] **Buscar por:** Ocorrências desses campos no código.
- [ ] **Critério:** Todos esses campos devem ter sido identificados e convertidos para `VARCHAR2` se eram `NUMBER`.
- [ ] **Reportar:** Listar campos de prioridade máxima que não foram identificados ou convertidos.

### 2.2 Verificação de Campos com Palavras-Chave Principais
- [ ] **Verificar:** Se campos contendo as palavras-chave foram identificados:
  - `CPF`, `CNPJ`, `CGC`, `NUMID`, `NR_DOCTO`, `NR_CPF_CNPJ`, `NR_ESTAB`, `RN_DIGITO`
- [ ] **Buscar por:** Ocorrências dessas palavras-chave no código (case-insensitive).
- [ ] **Critério:** Todos os campos identificados devem ter sido convertidos para `VARCHAR2` se eram `NUMBER`.
- [ ] **Reportar:** Listar campos com palavras-chave principais que não foram identificados ou convertidos.

### 2.3 Verificação de Campos com ESTAB e DIGITO (Prioridade Alta)
- [ ] **Verificar:** Se campos contendo `ESTAB` ou `DIGITO` foram identificados contextualmente.
- [ ] **Buscar por:** Campos como `ESTAB`, `DIGITO`, `ESTABELECIMENTO`, `DIGITO_VERIFICADOR`, `DV`, `NR_ESTAB`, `CD_ESTAB`, `COD_ESTAB`, `RN_DIGITO`, `NR_DIGITO`, `DIGITO_CNPJ`, `ESTAB_CNPJ`, etc.
- [ ] **Critério:** Campos relacionados a CNPJ/CPF devem ter sido identificados e convertidos.
- [ ] **Verificar:** Se a validação contextual foi feita (não confundir com estabelecimento comercial genérico).
- [ ] **Reportar:** Listar campos com `ESTAB` ou `DIGITO` que não foram identificados ou que foram identificados incorretamente.

### 2.4 Verificação de Variáveis Locais e Parâmetros (Prioridade Máxima)
- [ ] **Verificar:** Se **TODAS** as variáveis locais (`v_`) e parâmetros (`p_`) contendo `CPF`, `CNPJ`, `CGC`, `NUMID`, `NR_DOCTO` ou `NR_CPF_CNPJ` foram identificadas e convertidas.
- [ ] **Buscar por:** Variáveis e parâmetros com essas palavras-chave em **qualquer parte do nome**, incluindo sufixos como `_retorno`, `_busca`, `_formatado`, `_validado`, `_temporario`, `_auxiliar`, `_cliente`, `_segurado`.
- [ ] **Exemplos obrigatórios a verificar:**
  - `v_nr_cpf_retorno`
  - `v_cpf_busca`
  - `v_cnpj_formatado`
  - `v_cgc_validado`
  - `v_nr_cpf_temporario`
  - `v_cpf_auxiliar`
  - `p_cnpj_entrada`
  - `p_cpf_saida`
  - `v_nr_cgc_cpf_segurado`
  - `v_nr_estabelecimento_segurado`
  - `v_nr_digito_verificador`
  - `v_nr_cpf_cnpj_clien`
  - `v_cpf_cnpj_cliente`
  - `p_nr_estab_segur_tela`
- [ ] **Critério:** **TODAS** as variáveis e parâmetros que contenham essas palavras-chave devem ter sido convertidas de `NUMBER` para `VARCHAR2`.
- [ ] **Reportar:** Listar todas as variáveis e parâmetros que deveriam ter sido convertidas mas não foram.

### 2.5 Verificação de Campos Excluídos (CRÍTICO - Não Devem Ser Alterados)
- [ ] **Verificar:** Se campos da lista de exclusão não foram alterados:
  - `idereg`, `idepol`, `idApolice`, `numoper`, `numcert`, `endosso`, `numenoso`, `nrApolice`, `apolice`, `numpol`, `chave`, `generica`, `chavegenerica`
  - `NR_CPF_CNPJ_PRESTADORA`, `NR_CPF_CNPJ_PRESTADORA_TMS`, `p_cd_cpf_cnpj_prestadora`
  - Campos relacionados a cores: `cor`, `COR`, `nr_cor`, `cd_cor`, `cod_cor`, `cor_veiculo`, `cor_automovel`, `cor_carro`
- [ ] **Buscar por:** Ocorrências desses campos no código para verificar se foram alterados indevidamente.
- [ ] **Verificar especificamente:**
  - Se tipos de dados desses campos foram alterados de `NUMBER` para `VARCHAR2` (não devem ter sido alterados).
  - Se constraints desses campos foram modificadas (não devem ter sido alteradas).
  - Se triggers que processam esses campos foram alterados (não devem ter sido alterados).
  - Se procedures/functions que recebem esses campos como parâmetros tiveram os tipos alterados (não devem ter sido alterados).
  - Se variáveis locais relacionadas a esses campos foram convertidas (não devem ter sido convertidas).
- [ ] **Critério:** Nenhum campo da lista de exclusão deve ter sido alterado, mesmo que contenha palavras-chave como `CPF`, `CNPJ`, `CGC` no nome.
- [ ] **Reportar:** Listar todos os campos da lista de exclusão que foram alterados indevidamente, incluindo:
  - Nome do campo
  - Tipo de alteração (tipo de dados, constraint, trigger, parâmetro, variável local)
  - Arquivo e linha onde ocorreu a alteração
  - Código antes e depois da alteração (se disponível)

### 2.6 Verificação de Campos com Palavras-Chave mas Não Relacionados a CNPJ/CPF
- [ ] **Verificar:** Se campos que contêm palavras-chave (`CPF`, `CNPJ`, `CGC`, `ESTAB`, `DIGITO`) mas não estão relacionados a CNPJ/CPF foram identificados corretamente e **não foram alterados**.
- [ ] **Buscar por:** Campos que podem conter essas palavras-chave mas têm contexto diferente:
  - Campos de estabelecimento comercial genérico (não relacionado a CNPJ)
  - Campos de dígito verificador de outros documentos (não CNPJ/CPF)
  - Campos que usam `ESTAB` ou `DIGITO` em contexto não fiscal
- [ ] **Critério:** Campos que contêm palavras-chave mas não estão relacionados a CNPJ/CPF não devem ter sido alterados.
- [ ] **Reportar:** Listar campos que contêm palavras-chave mas foram alterados indevidamente por não estarem relacionados a CNPJ/CPF.

---

## 3) Verificação de Casos que NÃO Devem Ter Alterações

### 3.1 Verificação de Ausência de Alterações em Campos Não Relacionados
- [ ] **Verificar:** Se campos que não estão relacionados a CNPJ/CPF não foram alterados.
- [ ] **Critério:** Apenas campos explicitamente relacionados a CNPJ/CPF devem ter sido alterados.
- [ ] **Reportar:** Listar campos não relacionados que foram alterados indevidamente.

### 3.2 Verificação de Preservação de Referências %TYPE
- [ ] **Verificar:** Se referências `%TYPE` (ex.: `segurado%TYPE`, `empresa%TYPE`) foram preservadas e não foram substituídas por tipos explícitos.
- [ ] **Buscar por:** Ocorrências de `%TYPE` que foram alteradas para tipos explícitos como `VARCHAR2`, `NUMBER`, etc.
- [ ] **Critério:** Nenhuma referência `%TYPE` deve ter sido modificada ou substituída por tipo explícito.
- [ ] **Reportar:** Listar todas as referências `%TYPE` que foram alteradas indevidamente.

### 3.3 Verificação de Ausência de Funções Validadoras Desnecessárias
- [ ] **Verificar:** Se não foram criadas funções/procedimentos de validação quando não havia necessidade (conforme Seção 0.1 do prompt de implementação).
- [ ] **Buscar por:** Funções/procedimentos criados com nomes como:
  - `valida_cnpj`, `valida_cpf`, `valida_cnpj_alfanumerico`
  - `valida_documento`, `valida_cgc_cpf`
  - Qualquer função de validação criada sem justificativa clara
- [ ] **Critério:** Se não há necessidade de validação, não deve existir nenhuma função validadora criada.
- [ ] **Reportar:** Listar todas as funções validadoras criadas indevidamente, incluindo:
  - Nome da função/procedimento
  - Arquivo e localização
  - Justificativa para remoção (se não há necessidade de validação)

### 3.4 Verificação de Preservação de Código Não Relacionado
- [ ] **Verificar:** Se código não relacionado a CNPJ/CPF foi preservado sem alterações.
- [ ] **Buscar por:** Alterações em:
  - Procedures/functions que não processam CNPJ/CPF
  - Triggers que não validam CNPJ/CPF
  - Views que não exibem CNPJ/CPF
  - Constraints que não validam CNPJ/CPF
- [ ] **Critério:** Código não relacionado a CNPJ/CPF não deve ter sido alterado.
- [ ] **Reportar:** Listar alterações em código não relacionado a CNPJ/CPF.

### 3.5 Verificação de Preservação de Lógica de Negócio Existente
- [ ] **Verificar:** Se a lógica de negócio existente foi preservada, alterando apenas tipos de dados e validações relacionadas a CNPJ/CPF.
- [ ] **Critério:** A lógica de negócio não relacionada a CNPJ/CPF não deve ter sido alterada.
- [ ] **Reportar:** Listar alterações na lógica de negócio que não estão relacionadas a CNPJ/CPF.

### 3.6 Verificação de Preservação de Comentários e Documentação
- [ ] **Verificar:** Se comentários e documentação foram preservados, alterando apenas quando necessário para refletir mudanças em CNPJ/CPF.
- [ ] **Critério:** Comentários e documentação não relacionados a CNPJ/CPF não devem ter sido alterados.
- [ ] **Reportar:** Listar alterações indevidas em comentários e documentação.

---

## 4) Verificação do Contexto Normativo e Técnico (Seção 2 do Prompt de Implementação)

### 3.1 Verificação de Comprimento e Estrutura
- [ ] **Verificar:** Se o código reconhece que CNPJ tem 14 caracteres (12 alfanuméricos + 2 numéricos).
- [ ] **Verificar:** Se o código reconhece que CPF tem 11 caracteres (9 alfanuméricos + 2 numéricos).
- [ ] **Reportar:** Casos onde o código não respeita o comprimento correto.

### 3.2 Verificação de Regex
- [ ] **Verificar:** Se constraints e validações usam o regex correto: `^[A-Z0-9]{12}\d{2}$` para CNPJ.
- [ ] **Buscar por:** Ocorrências de regex antigo `^\d{14}$` que não foram atualizadas.
- [ ] **Critério:** Todas as validações devem usar o regex alfanumérico com flag case-insensitive (`'i'`).
- [ ] **Reportar:** Listar todas as validações que ainda usam regex numérico.

### 3.3 Verificação de Retrocompatibilidade
- [ ] **Verificar:** Se o código aceita tanto CNPJ/CPF numérico quanto alfanumérico.
- [ ] **Reportar:** Casos onde a retrocompatibilidade não foi garantida.

### 3.4 Verificação de Persistência
- [ ] **Verificar:** Se nenhum código tenta converter CNPJ/CPF para `NUMBER` usando `TO_NUMBER` ou `CAST`.
- [ ] **Buscar por:** Ocorrências de `TO_NUMBER`, `CAST(...AS NUMBER)`, conversões numéricas.
- [ ] **Critério:** Nenhuma conversão numérica deve existir para campos de CNPJ/CPF.
- [ ] **Reportar:** Listar todas as conversões numéricas indevidas.

### 3.5 Verificação de Tipagem de Dados
- [ ] **Verificar:** Se colunas de tabela usam `VARCHAR2` **sem especificar tamanho** (ex.: `VARCHAR2` e não `VARCHAR2(14)`).
- [ ] **Verificar:** Se parâmetros de procedures/functions usam `VARCHAR2` **sem especificar tamanho** (ex.: `p_cnpj VARCHAR2` e não `p_cnpj VARCHAR2(14)`).
- [ ] **Verificar:** Se variáveis locais **mantêm o tamanho original** se já existia (ex.: `v_cnpj VARCHAR2(14)` mantém o tamanho).
- [ ] **Critério:** 
  - Colunas: `VARCHAR2` sem tamanho
  - Parâmetros: `VARCHAR2` sem tamanho
  - Variáveis locais: `VARCHAR2` mantendo tamanho original se existia
- [ ] **Reportar:** Listar todos os casos onde a tipagem não segue as regras corretas.

---

## 5) Verificação da Estratégia de Varredura (Seção 4 do Prompt de Implementação)

### 4.1 Verificação de Escopo de Busca
- [ ] **Verificar:** Se foram buscados arquivos com extensões corretas:
  - `.sql`, `.pkb`, `.pks`, `.prc`, `.fnc`, `.trg`
  - Arquivos de configuração: `.properties`, `.env`
  - Documentação: `.md`, `.txt`
- [ ] **Reportar:** Extensões de arquivo que não foram buscadas.

### 4.2 Verificação de Objetos de Banco
- [ ] **Verificar:** Se foram verificados todos os tipos de objetos:
  - Tabelas (colunas, tipos, constraints)
  - Índices (simples, compostos, únicos)
  - Triggers (BEFORE INSERT, BEFORE UPDATE, AFTER INSERT, AFTER UPDATE, BEFORE DELETE)
  - Procedures e Functions (parâmetros, variáveis locais, validações)
  - Packages (especificações e corpos)
  - Views (colunas calculadas, filtros, joins)
  - Sequences (se houver)
  - Synonyms (se houver)
- [ ] **Reportar:** Tipos de objetos que não foram verificados.

---

## 6) Verificação das Mudanças Obrigatórias (Seção 5 do Prompt de Implementação)

### 5.1 Verificação de Tipagem de Dados
- [ ] **Verificar:** Se todas as colunas de CNPJ/CPF foram alteradas de `NUMBER`/`INTEGER`/`BIGINT` para `VARCHAR2` ou `CHAR`.
- [ ] **Verificar:** Se colunas de tabela usam `VARCHAR2` **sem tamanho**.
- [ ] **Verificar:** Se parâmetros usam `VARCHAR2` **sem tamanho**.
- [ ] **Verificar:** Se variáveis locais **mantêm o tamanho original**.
- [ ] **Verificar:** Se referências `%TYPE` foram preservadas.
- [ ] **Reportar:** Listar todos os casos onde a tipagem não foi aplicada corretamente.

### 5.2 Verificação de Constraints
- [ ] **Verificar:** Se constraints `CHECK` foram atualizadas para permitir alfanuméricos:
  - Regex antigo: `^\d{14}$`
  - Regex novo: `^[A-Z0-9]{12}\d{2}$` com flag `'i'`
- [ ] **Verificar:** Se constraints `NOT NULL` foram mantidas.
- [ ] **Verificar:** Se constraints `UNIQUE` foram mantidas.
- [ ] **Verificar:** Se `FOREIGN KEY` foram atualizadas se necessário.
- [ ] **Reportar:** Listar todas as constraints que não foram atualizadas corretamente.

### 5.3 Verificação de Triggers
- [ ] **Verificar:** Se triggers `BEFORE INSERT/UPDATE` foram atualizados para validar formato alfanumérico.
- [ ] **Verificar:** Se triggers `AFTER INSERT/UPDATE` foram ajustados se necessário.
- [ ] **Verificar:** Se triggers não convertem CNPJ para número.
- [ ] **Reportar:** Listar todos os triggers que não foram atualizados corretamente.

### 5.4 Verificação de Procedures e Functions
- [ ] **Verificar:** Se validações seguem o Fluxo de Decisão (Seção 0).
- [ ] **Verificar:** Se funções de normalização permitem letras nos 12 primeiros caracteres.
- [ ] **Verificar:** Se funções de formatação suportam alfanuméricos.
- [ ] **Verificar:** Se parâmetros foram atualizados para `VARCHAR2` **sem tamanho**.
- [ ] **Verificar:** Se variáveis locais foram atualizadas mantendo tamanho original.
- [ ] **Verificar:** Se **TODAS** as variáveis locais e parâmetros contendo `CPF`, `CNPJ`, `CGC`, `NUMID`, `NR_DOCTO` ou `NR_CPF_CNPJ` foram convertidas.
- [ ] **Reportar:** Listar todas as procedures/functions que não foram atualizadas corretamente.

### 5.5 Verificação Crítica de Normalização (LPAD)
- [ ] **Verificar:** Se **NÃO há uso de `LPAD` para concatenar partes de CPF/CNPJ** que geram tamanhos incorretos.
- [ ] **Buscar por:** Padrões problemáticos:
  - `LPAD(...v_nr_cgc_cpf_segurado...) || LPAD(...v_nr_estabelecimento_segurado...) || LPAD(...v_nr_digito_verificador...)`
  - `LPAD(...v_nr_cgc_cpf_segurado...) || LPAD(...v_nr_digito_verificador...)`
- [ ] **Verificar:** Se quando existe variável formatada (ex.: `v_cpf_cnpj_cli`), foi usado `UPPER(REGEXP_REPLACE(v_cpf_cnpj_cli, '[^A-Z0-9]', ''))` para normalizar.
- [ ] **Verificar:** Se CPF tem 11 caracteres e CNPJ tem 14 caracteres após normalização.
- [ ] **Critério:** Não deve haver uso de `LPAD` para concatenar partes. Deve usar `UPPER(REGEXP_REPLACE)` quando há variável formatada.
- [ ] **Reportar:** Listar todos os casos onde `LPAD` foi usado incorretamente para concatenar partes de CPF/CNPJ.

### 5.6 Verificação de Views
- [ ] **Verificar:** Se views que fazem conversões de tipo (`TO_NUMBER`, `TO_CHAR`) foram atualizadas.
- [ ] **Verificar:** Se colunas calculadas que processam CNPJ/CPF foram ajustadas.
- [ ] **Verificar:** Se filtros (`WHERE`) que usam CNPJ/CPF foram atualizados.
- [ ] **Reportar:** Listar todas as views que não foram atualizadas corretamente.

### 5.7 Verificação de Índices
- [ ] **Verificar:** Se índices simples foram mantidos (funcionam com VARCHAR2).
- [ ] **Verificar:** Se índices compostos foram verificados.
- [ ] **Verificar:** Se índices funcionais foram atualizados se usavam funções de conversão.
- [ ] **Reportar:** Listar índices que precisam de ajuste mas não foram atualizados.

---

## 7) Verificação do Relatório Final (Seção 6 do Prompt de Implementação)

### 6.1 Verificação de Completude do Inventário
- [ ] **Verificar:** Se o relatório `implementacao.md` contém inventário completo de todos os objetos alterados.
- [ ] **Verificar:** Se cada objeto listado contém:
  - **Nome do arquivo processado:** O nome completo do arquivo (com caminho relativo ou absoluto) que está sendo analisado/executado.
  - Tipo de objeto (TABELA, CONSTRAINT, TRIGGER, PROCEDURE, FUNCTION, PACKAGE, VIEW, ÍNDICE, etc.)
  - Nome do objeto e schema (se aplicável)
  - Descrição da alteração
  - Script SQL antes/depois (quando aplicável)
  - Impacto em dados existentes
  - Observação sobre necessidade de testes
- [ ] **Reportar:** Objetos alterados que não estão no inventário ou que não incluem o nome do arquivo processado.

### 6.2 Verificação de Consistência
- [ ] **Verificar:** Se o relatório está consistente com as alterações no código.
- [ ] **Verificar:** Se todos os objetos listados no relatório realmente existem no código.
- [ ] **Reportar:** Inconsistências entre relatório e código.

---

## 8) Verificação de Testes (Seção 7 do Prompt de Implementação)

### 7.1 Verificação de Necessidade de Testes
- [ ] **Verificar:** Se testes foram criados conforme a tabela de necessidade:
  - Mudança de tipo de coluna → Teste de Integração (migração)
  - Mudança em CONSTRAINT → Teste de Integração
  - Inclusão/alteração de TRIGGER → Teste de Integração
  - Inclusão/alteração de validação em FUNCTION/PROCEDURE → Teste Unitário e Integração
  - Mudança em VIEW → Teste de Integração
  - Alterações em PACKAGE → Teste Unitário e Integração
  - Ajuste apenas de comentários → Não exige teste
- [ ] **Reportar:** Alterações que deveriam ter testes mas não têm.

### 7.2 Verificação de Scripts de Teste
- [ ] **Verificar:** Se scripts de teste validam:
  - Inserção de CNPJs numéricos e alfanuméricos
  - Validação de constraints
  - Execução de triggers
  - Chamadas de procedures/funções com ambos os formatos
  - Retrocompatibilidade com dados existentes
- [ ] **Reportar:** Testes que deveriam existir mas não existem.

---

## 9) Verificação do Code Review Final (Seção 8 do Prompt de Implementação)

### 8.1 Verificação de Sintaxe
- [ ] **Verificar:** Se todos os scripts SQL/PL/SQL têm sintaxe válida.
- [ ] **Reportar:** Erros de sintaxe encontrados.

### 8.2 Verificação de Preservação de Acentuações
- [ ] **Verificar:** Se nenhum caractere acentuado foi substituído por `` ou removido.  
- [ ] **Verificar:** Se comentários mantêm acentuações originais.  
- [ ] **Verificar:** Se mensagens de erro mantêm acentuações originais.  
- [ ] **Verificar:** Se labels mantêm acentuações originais.  
- [ ] **Verificar:** Se strings literais mantêm acentuações originais.  
- [ ] **Reportar:** Todos os casos onde acentuações não foram preservadas.

### 8.3 Verificação Crítica de Variáveis
- [ ] **Verificar:** Se **TODAS** as variáveis locais e parâmetros contendo `CPF`, `CNPJ`, `CGC`, `NUMID`, `NR_DOCTO` ou `NR_CPF_CNPJ` foram identificadas e convertidas.
- [ ] **Verificar:** Se variáveis com sufixos como `_retorno`, `_busca`, `_formatado` foram incluídas.
- [ ] **Exemplos obrigatórios:** `v_nr_cpf_retorno`, `v_cpf_busca`, `v_cnpj_formatado`, `p_cpf_entrada`
- [ ] **Reportar:** Variáveis que deveriam ter sido convertidas mas não foram.

### 8.4 Verificação Crítica de Normalização
- [ ] **Verificar:** Se **NÃO há uso de `LPAD` para concatenar partes de CPF/CNPJ**.
- [ ] **Verificar:** Se quando há variável formatada, foi usado `UPPER(REGEXP_REPLACE)`.
- [ ] **Verificar:** Se CPF tem 11 caracteres e CNPJ tem 14 caracteres após normalização.
- [ ] **Reportar:** Casos onde normalização está incorreta.

### 8.5 Verificação de Regressões
- [ ] **Verificar:** Se não há regressões em constraints, triggers e validações.
- [ ] **Reportar:** Regressões identificadas.

### 8.6 Verificação de Performance
- [ ] **Verificar:** Se impacto em performance (índices, queries) foi considerado.
- [ ] **Reportar:** Problemas de performance identificados.

### 8.7 Verificação de Retrocompatibilidade
- [ ] **Verificar:** Se conformidade com regras de compatibilidade e retrocompatibilidade foi garantida.
- [ ] **Reportar:** Problemas de compatibilidade identificados.

### 8.8 Verificação de Conversões Numéricas
- [ ] **Verificar:** Se não há conversões numéricas indevidas (`TO_NUMBER`, `CAST`, etc.).
- [ ] **Reportar:** Conversões numéricas indevidas encontradas.

---

## 10) Verificação dos Critérios de Aceite (Seção 9 do Prompt de Implementação)

### 9.1 Verificação de Aceitação de Formato
- [ ] **Verificar:** Se todos os campos de CNPJ e CPF aceitam **A–Z e 0–9** nos 12 primeiros caracteres e **apenas dígitos** nos 2 últimos.
- [ ] **Reportar:** Campos que não aceitam o formato correto.

### 9.2 Verificação de Conversões Numéricas
- [ ] **Verificar:** Se nenhum código tenta converter valores para numérico (`TO_NUMBER`, `CAST`, etc.).
- [ ] **Reportar:** Conversões numéricas encontradas.

### 9.3 Verificação Crítica de Variáveis
- [ ] **Verificar:** Se **TODAS** as variáveis locais e parâmetros contendo `CPF`, `CNPJ`, `CGC`, `NUMID`, `NR_DOCTO` ou `NR_CPF_CNPJ` foram convertidas.
- [ ] **Reportar:** Variáveis não convertidas.

### 9.4 Verificação Crítica de Normalização
- [ ] **Verificar:** Se **NÃO há uso de `LPAD` para concatenar partes**.
- [ ] **Verificar:** Se foi usado `UPPER(REGEXP_REPLACE)` quando há variável formatada.
- [ ] **Verificar:** Se CPF tem 11 caracteres e CNPJ tem 14 caracteres.
- [ ] **Reportar:** Problemas de normalização.

### 9.5 Verificação de Preservação de Acentuações
- [ ] **Verificar:** Se nenhum caractere acentuado foi substituído por `` ou removido.  
- [ ] **Reportar:** Problemas de preservação de acentuações.

### 9.6 Verificação de Constraints e Validações
- [ ] **Verificar:** Se constraints e validações foram ajustadas.
- [ ] **Reportar:** Constraints/validações não ajustadas.

### 9.7 Verificação de Triggers
- [ ] **Verificar:** Se triggers funcionam corretamente com ambos os formatos.
- [ ] **Reportar:** Triggers com problemas.

### 9.8 Verificação de Relatório
- [ ] **Verificar:** Se o relatório final contém inventário completo e análise de testes.
- [ ] **Reportar:** Problemas no relatório.

### 9.9 Verificação de Scripts de Migração
- [ ] **Verificar:** Se scripts de migração foram criados quando necessário.
- [ ] **Reportar:** Casos onde migração é necessária mas não foi criada.

---

## 11) Verificação de Alucinações da IA

### 10.1 Verificação de Código Fictício
- [ ] **Verificar:** Se não foi criado código que não existe no projeto original.
- [ ] **Verificar:** Se não foram criadas funções/procedimentos que não foram solicitados.
- [ ] **Reportar:** Código fictício criado pela IA.

### 10.2 Verificação de Alterações Não Solicitadas
- [ ] **Verificar:** Se não foram feitas alterações em código não relacionado a CNPJ/CPF.
- [ ] **Verificar:** Se não foram alterados campos da lista de exclusão.
- [ ] **Reportar:** Alterações não solicitadas.

### 10.3 Verificação de Inconsistências Lógicas
- [ ] **Verificar:** Se a lógica do código está consistente.
- [ ] **Verificar:** Se não há contradições entre diferentes partes do código.
- [ ] **Reportar:** Inconsistências lógicas encontradas.

### 10.4 Verificação de Completude
- [ ] **Verificar:** Se todas as alterações necessárias foram feitas.
- [ ] **Verificar:** Se não há objetos que deveriam ter sido alterados mas não foram.
- [ ] **Reportar:** Omissões identificadas.

---

## 12) Estratégia de Verificação

### 12.1 Busca Sistemática
1. **Buscar por padrões numéricos:** `NUMBER`, `INTEGER`, `BIGINT` em campos de CNPJ/CPF.
2. **Buscar por conversões numéricas:** `TO_NUMBER`, `CAST(...AS NUMBER)`.
3. **Buscar por regex antigo:** `^\d{14}$`, `^\d{11}$`.
4. **Buscar por LPAD problemático:** `LPAD(...) || LPAD(...)` com variáveis de CNPJ/CPF.
5. **Buscar por variáveis não convertidas:** Variáveis `v_` e parâmetros `p_` com `CPF`, `CNPJ`, `CGC`, etc. ainda como `NUMBER`.
6. **Buscar por caracteres acentuados alterados:** Comparar versões antes/depois.
7. **Buscar por campos da lista de exclusão alterados:** Verificar se campos como `idereg`, `idepol`, `NR_CPF_CNPJ_PRESTADORA`, `cor`, etc. foram alterados indevidamente.
8. **Buscar por referências %TYPE alteradas:** Verificar se referências `%TYPE` foram substituídas por tipos explícitos.
9. **Buscar por funções validadoras criadas indevidamente:** Verificar se funções de validação foram criadas quando não havia necessidade.

### 12.2 Validação Contextual
- Verificar contexto de cada alteração para garantir que faz sentido.
- Verificar se campos com `ESTAB` ou `DIGITO` estão realmente relacionados a CNPJ/CPF.
- Verificar se campos da lista de exclusão não foram alterados.
- Verificar se campos que contêm palavras-chave (`CPF`, `CNPJ`, `CGC`, `ESTAB`, `DIGITO`) mas não estão relacionados a CNPJ/CPF foram identificados corretamente e não foram alterados.
- Verificar se referências `%TYPE` foram preservadas.
- Verificar se funções validadoras foram criadas apenas quando necessário.

### 12.3 Comparação com Relatório
- Comparar o relatório `implementacao.md` com as alterações reais no código.
- Verificar se todos os objetos listados no relatório existem no código.
- Verificar se todos os objetos alterados estão no relatório.
- **Verificar se o relatório inclui o nome do arquivo processado** para cada objeto documentado.
- Verificar se o relatório menciona que campos da lista de exclusão não foram alterados.
- Verificar se o relatório menciona que referências `%TYPE` foram preservadas.

---

## 13) Relatório Final de Verificação

O relatório deve ser salvo com nome dinâmico baseado no arquivo verificado:

**Regra de nomenclatura:**
- Identifique o nome do arquivo que está sendo verificado (ex.: `implementacao-plsql.md`)
- Remova a extensão do arquivo (ex.: `implementacao-plsql`)
- Crie o nome do relatório: `verificacao-qa-{nome-do-arquivo-sem-extensao}.md`
- Exemplo: Se o arquivo verificado é `implementacao-plsql.md`, o relatório será `verificacao-qa-implementacao-plsql.md`

**Localização:**
- Salve o relatório no mesmo diretório do arquivo verificado, ou
- Se não for possível determinar o diretório, salve na raiz do projeto

### 12.1 Estrutura do Relatório

```markdown
# Relatório de Verificação QA — CNPJ Alfanumérico

## Informações do Processamento
- **Arquivo verificado:** [nome do arquivo que está sendo verificado]
- **Arquivo de implementação analisado:** [nome do arquivo de implementação, se aplicável]
- **Data/Hora da verificação:** [data e hora]

## Resumo Executivo
- Total de problemas encontrados: X
- Problemas críticos: X
- Problemas moderados: X
- Problemas baixos: X

## 1. Regras Gerais
### 1.1 Ausência de Validação
- [Status] OK / ERRO
- [Detalhes] Lista de problemas encontrados

### 1.2 Validação Padrão
- [Status] OK / ERRO
- [Detalhes] Lista de problemas encontrados

[... continuar para todas as seções ...]

## 2. Escopo de Identificação
[...]

## 3. Casos que NÃO Devem Ter Alterações
[...]

## 4. Contexto Normativo
[...]

## 5. Estratégia de Varredura
[...]

## 6. Mudanças Obrigatórias
[...]

## 7. Relatório Final
[...]

## 8. Testes
[...]

## 9. Code Review
[...]

## 10. Critérios de Aceite
[...]

## 11. Alucinações da IA
[...]

## 11. Recomendações
- Lista de ações corretivas recomendadas
- Priorização (Crítico, Moderado, Baixo)

## 12. Conclusão
- Status geral: APROVADO / REPROVADO / APROVADO COM RESSALVAS
- Próximos passos
```

### 12.2 Classificação de Problemas

- **CRÍTICO:** Problemas que impedem o funcionamento correto ou violam regras obrigatórias.
- **MODERADO:** Problemas que podem causar problemas em casos específicos.
- **BAIXO:** Problemas menores, melhorias sugeridas.

### 12.3 Formato de Problemas

Para cada problema encontrado, incluir:
- **Tipo:** CRÍTICO / MODERADO / BAIXO
- **Seção:** Seção do prompt de implementação relacionada
- **Arquivo processado:** Nome do arquivo que está sendo analisado/executado (com caminho relativo ou absoluto)
- **Arquivo:** Caminho do arquivo onde o problema foi encontrado
- **Linha:** Número da linha (se aplicável)
- **Descrição:** Descrição detalhada do problema
- **Código Antes:** Código antes da alteração (se disponível)
- **Código Depois:** Código após alteração (se disponível)
- **Código Esperado:** Código que deveria estar (se aplicável)
- **Recomendação:** Ação recomendada para correção

---

## 14) Critérios de Aprovação

O código será **APROVADO** se:
- ✅ Todos os campos de CNPJ/CPF foram identificados e convertidos corretamente.
- ✅ Todas as variáveis locais e parâmetros contendo `CPF`, `CNPJ`, `CGC`, etc. foram convertidas.
- ✅ Não há uso de `LPAD` para concatenar partes de CPF/CNPJ.
- ✅ Todas as constraints foram atualizadas para aceitar alfanuméricos.
- ✅ Nenhum caractere acentuado foi alterado ou removido.
- ✅ Não há conversões numéricas indevidas.
- ✅ O relatório de implementação está completo e consistente.
- ✅ Testes foram criados conforme necessário.
- ✅ **Campos da lista de exclusão não foram alterados** (idereg, idepol, NR_CPF_CNPJ_PRESTADORA, cor, etc.).
- ✅ **Referências `%TYPE` foram preservadas** e não foram substituídas por tipos explícitos.
- ✅ **Funções validadoras não foram criadas** quando não havia necessidade de validação.
- ✅ **Código não relacionado a CNPJ/CPF foi preservado** sem alterações.

O código será **REPROVADO** se:
- ❌ Há campos de CNPJ/CPF que não foram identificados ou convertidos.
- ❌ Há variáveis locais ou parâmetros contendo `CPF`, `CNPJ`, etc. que não foram convertidas.
- ❌ Há uso de `LPAD` para concatenar partes de CPF/CNPJ.
- ❌ Há conversões numéricas indevidas.
- ❌ Há caracteres acentuados que foram alterados ou removidos.
- ❌ O relatório de implementação está incompleto ou inconsistente.
- ❌ **Campos da lista de exclusão foram alterados** indevidamente.
- ❌ **Referências `%TYPE` foram alteradas** ou substituídas por tipos explícitos.
- ❌ **Funções validadoras foram criadas** quando não havia necessidade de validação.
- ❌ **Código não relacionado a CNPJ/CPF foi alterado** indevidamente.

---

## 15) Conclusão

Este prompt de QA deve ser aplicado **após** a execução do prompt de implementação (`implementacao-plsql.md`).  
A missão do QA é garantir que **todas as regras foram aplicadas corretamente** e identificar **erros, alucinações e omissões** da IA.

```diff
+ Verificar todas as regras do prompt de implementação
+ Identificar erros e alucinações da IA
+ Validar completude do inventário
+ Verificar preservação de acentuações
+ Verificar conversões de tipos
+ Verificar normalização (LPAD vs UPPER(REGEXP_REPLACE))
+ Verificar variáveis e parâmetros não convertidos
+ Verificar que campos da lista de exclusão NÃO foram alterados
+ Verificar que referências %TYPE foram preservadas
+ Verificar que funções validadoras não foram criadas desnecessariamente
+ Verificar que código não relacionado foi preservado
+ Gerar relatório completo de verificação
```

