# Prompt de Implementação — CNPJ Alfanumérico (para usar no Cursor)

Você é um **engenheiro de software** atuando como **Engenheiro de Prompts para o Cursor** com foco em **backend** e **aderência ao novo padrão do CNPJ alfanumérico** conforme IN RFB nº 2.119/2022 e IN RFB nº 2.229/2024. Seu objetivo é **analisar, atualizar e validar** todo o código-fonte do repositório para suportar o CNPJ alfanumérico **com retrocompatibilidade**. Ao final, gere um **relatório técnico detalhado** com todas as alterações executadas e salve em:
```
.cnpj_alfanumerico/documentos/implementacao.md
```

> **Atenção a escopo de identificação de campos CNPJ**  
> **Considere como *campos de CNPJ*** todos os atributos que contenham os seguintes nomes (case-insensitive, podendo estar em snake_case, camelCase, pascalCase, com prefixos/sufixos):  
> - `CPF`  
> - `NUMID`  
> - `CNPJ`  
> - `CGC`  
> - `NR_DOCTO`  
> - `NR_CPF_CNPJ`  
>
> **Não considere como campos de CNPJ** (lista de exclusão exata, case-insensitive):  
> - `idereg`, `idepol`, `idApolice`, `numoper`, `numcert`, `endosso`, `numenoso`, `nrApolice`, `apolice`, `numpol`, `chave`, `generica`

---

## 1) Contexto normativo e técnico (resumo para implementação)

- **Comprimento fixo:** 14 caracteres.  
- **Estrutura:** 12 primeiros **alfanuméricos** (A–Z, 0–9) + 2 últimos **numéricos** (dígitos verificadores).  
- **Regex base (sem máscara):**
  - **Novo/compatível:** `^[A-Z0-9]{12}\d{2}$`
- **Regex com máscara:** `^[A-Z0-9]{2}\.[A-Z0-9]{3}\.[A-Z0-9]{3}/[A-Z0-9]{4}-\d{2}$`
- **Máscara do input:** `SS.SSS.SSS/SSSS-NN` (S = alfanumérico, N = numérico).  
- **Retrocompatibilidade:** aceite CNPJ 100% numérico (14 dígitos) e o novo alfanumérico.  
- **Persistência:** não converter para `int/long`; **sempre** armazenar como `string`/`VARCHAR(14)`; não usar `parseInt/Number` em pipelines.  
- **DV (algoritmo compatível a bases A–Z, 0–9):** mapear caractere para `valor = ASCII(c) - 48` e aplicar pesos cíclicos. (Manter compatível com especificação vigente.)

---

## 2) Missão do agente (alta prioridade)

1. **Inventariar ocorrências** de CNPJ no repositório (código, SQL/migrations, DTOs, entidades/models, controllers, serviços, utilitários, validações, configurações, testes, documentação).  
2. **Classificar impacto** por criticidade (crítico, moderado, baixo).  
3. **Aplicar mudanças** para suportar alfanumérico com retrocompatibilidade.  
4. **Gerar e executar** scripts de migração de schema para `VARCHAR(14)` onde couber; preservar índices/constraints/chaves.  
5. **Atualizar validações** (regex + DV), máscaras, normalização, formatação e ordenação/consulta **ajustando o validador existente; criar novo somente se não houver**.  
6. **Adequar integrações** (APIs internas/externas) e contratos (OpenAPI/Swagger/JSON Schemas).  
7. **Criar/atualizar testes** unitários e de integração cobrindo antigo e novo formato.  
8. **Produzir relatório final** (`.cnpj_alfanumerico/documentos/implementacao.md`) com tudo que foi feito, arquivos alterados, trechos de código antes/depois, decisões e pendências.

---

## 3) Estratégia de varredura e identificação

### 3.1 Escopo de busca (extensões)
- **Código:** `.java`, `.kt`, `.cs`, `.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.go`, `.rb`  
- **Dados/DB:** `.sql`, `.migration`, `.schema`  
- **Front/UI:** `.html`, `.vue`, `.css`, `.scss`  
- **Config:** `.json`, `.yaml`, `.yml`, `.xml`, `.properties`, `.env`  
- **Docs:** `.md`, `.txt`

### 3.2 Padrões de busca (case-insensitive)
- Inclusão (aliases usuais): `cnpj`, `cpfcnpj`, `cpf_cnpj`, `taxid`, `tax_id`, `companyid`, `company_id`, `corpnumber`, `corporate_id`, `identificationnumber`, `businessnumber`, `registrationnumber`, `numid`, `cgc`, `nr_docto`, `nr_cpf_cnpj`.  
- **Whitelists (sempre considerar):** qualquer atributo contendo **CPF**, **NUMID**, **CNPJ**, **CGC**, **NR_DOCTO**, **NR_CPF_CNPJ** (mesmo com prefixos/sufixos).  
- **Blacklists (excluir):** `idereg`, `idepol`, `idApolice`, `numoper`, `numcert`, `endosso`, `numenoso`, `nrApolice`, `apolice`, `numpol`, `chave`, `generica` (combinações e variações exatas ignoradas).

### 3.3 Expressões úteis
- **Numérico antigo (legado):** `\b\d{14}\b`  
- **Novo compatível (sem máscara):** `\b[A-Z0-9]{12}\d{2}\b`  
- **Com máscara:** `\b[A-Z0-9]{2}\.[A-Z0-9]{3}\.[A-Z0-9]{3}/[A-Z0-9]{4}-\d{2}\b`

> Regras: buscas **insensíveis a maiúsculas/minúsculas** e reporte **com caminho do arquivo + número de linha**.

---

## 4) Mudanças obrigatórias por camada

### 4.1 Banco de Dados
- **Colunas** que armazenam CNPJ: alterar tipo para `VARCHAR(14)` (ou `CHAR(14)` se for padrão vigente), permitindo letras A–Z.  
- **Índices/constraints/PK/FK:** revisar e ajustar. Evitar funções de conversão numéricas; manter collation/case insensitive quando necessário.  
- **Migrations**: gerar scripts idempotentes (ex.: Oracle `VARCHAR2(14)`; Postgres `VARCHAR(14)`).  
- **Dados existentes:** não transformar valores; apenas adequar tipos. Se houver colunas separadas (`numid` + `dvid`), manter, mas tipar corretamente como `VARCHAR`/`CHAR`.

### 4.2 Backend / Validações
- **Tipagem:** substituir `Long/int` por `String` em *campos CNPJ* (incluindo `numid`) em **Entidades/Models/PK compostas**, **DTOs/Projections**, **Repositórios** (assinaturas e queries), **Serviços** e **Controllers**.  
- **Normalização:** permitir letras nos 12 primeiros caracteres; **não** aplicar limpeza que remova letras.  
- **Validação de formato:** `^[A-Z0-9]{12}\d{2}$` (aceitar também 14 dígitos).  
- **Cálculo de DV:** implementar utilitário `CnpjValidator` ou equivalente, com mapeamento `valor = ASCII(c) - 48` e pesos padrão cíclicos; cobrir primeiro e segundo dígitos.  
- **Formatação:** adicionar `SS.SSS.SSS/SSSS-NN`.  
- **Ordenação e filtros:** garantir comparações lexicográficas adequadas; não castar para número.

- **Existência de validador prévio:** Se já existir função/classe de validação, **ajuste-a** para suportar o CNPJ alfanumérico e retrocompatibilidade. **Caso não exista, não crie uma nova função**, apenas **registre a ausência no relatório final**. **Somente** crie `CnpjValidator` caso **não exista** qualquer validador aplicável.

### 4.3 Front-end / APIs / Contratos
- **Máscaras:** permitir letras nos 12 primeiros caracteres.  
- **Swagger/OpenAPI/JSON Schema:** atualizar para `type: string`, `maxLength: 14`, `pattern` compatível.  
- **Mensagens de erro:** adequar para citar alfanumérico e DV.  
- **Mocks e exemplos:** incluir amostras alfanuméricas e numéricas.

---

## 5) Passo a passo operacional (automação no Cursor)

1. **Scan do repositório**
   - Execute varredura global com os padrões acima.
   - Gere um inventário CSV/JSON com: arquivo, linha, *match*, contexto, severidade estimada (crítico/moderado/baixo) e tag (`entidade`, `dto`, `repo`, `controller`, `service`, `sql`, `util`, `test`, `doc`).  
   - Marque cada ocorrência como **incluída** (por whitelists) ou **excluída** (por blacklists).

2. **Refactors de tipagem**
   - Alterar `Long/int` → `String` nos *campos CNPJ* (ex.: `numid`) em **Entidades/PK/DTOs/Projections/Repos/Serviços**.  
   - Ajustar construtores, *equals/hashCode*, serialização e conversões.

3. **Atualização de Repositórios/Queries**
   - Revisar **queries nativas** e JPQL/Criteria para remover casts numéricos e aceitar `String`.  
   - Recriar índices conforme necessário.  
   - Onde existirem filtros por `numid`, adequar para comparação de strings.

4. **Utilitários de validação e máscara (ajustar existente; criar somente se ausente)**
   - **Se existir validador atual**, **ajuste-o** para suportar o novo padrão (regex + DV + máscara); **se não existir**, **não crie** uma nova função — apenas **sinalize essa ausência no relatório final**.
     - `isValid(String cnpj)` (aceita numérico e alfanumérico).  
     - `calcularDV(String base12)` (A–Z e 0–9).  
     - `formatar(String cnpj)` → `SS.SSS.SSS/SSSS-NN`.  
     - **Testes unitários** cobrindo casos válidos/ inválidos, bordas e retrocompatibilidade.

5. **APIs/Contratos**
   - Garantir que parâmetros **permaneçam String** e **não** sejam sanitizados para apenas dígitos.  
   - Atualizar **OpenAPI/Swagger** com `pattern` e exemplos.  
   - Verificar *serializers/deserializers* e validações customizadas (Bean Validation, class-validators, pipes).

6. **Migrations de DB**
   - Gerar scripts idempotentes para alterar tipos para `VARCHAR(14)` e recriar índices/constraints.  
   - Preparar *rollback plan* e *backup strategy*.  
   - Não transformar valores existentes.

7. **Testes**
   - **Unitários:** validação de formato, DV, formatação, normalização.  
   - **Integração:** endpoints com CNPJ alfanumérico/numérico; repositórios com consultas por `String`.  
   - **Aceitação:** fluxos críticos (emissão, consulta, busca por CNPJ, relatórios).

8. **Relatório final**
   - Criar `./.cnpj_alfanumerico/documentos/implementacao.md` com:
     - Resumo executivo e escopo.  
     - Tabela de arquivos alterados (caminho + breve descrição).  
     - Diffs relevantes (antes/depois).  
     - Scripts de migração.  
     - Estratégia de testes e evidências (logs/prints).  
     - Riscos e pendências.  
   - Incluir apêndice com inventário de ocorrências.


9. **Code Review Final**
   - **Revisar diffs** de todos os arquivos alterados (nomenclaturas, regex, normalização, remoção de casts numéricos, tipagens).
   - **Checagem estática** (linters/formatters) e **análise de impacto** em pontos críticos (métodos quentes, queries, índices, serialização).
   - **Pair-review automatizado**: comentar blocos suspeitos e sugerir correções (ex.: comparações numéricas vs. strings, toUpperCase sem normalizar máscara, uso indevido de `trim` que remove letras, etc.).
   - **Rode toda a suíte de testes** (unitários, integração, aceitação) e corrija regressões.
   - **Checklist de qualidade**: segurança de logs, exceptions claras, mensagens de validação atualizadas, Swagger refletindo mudanças.


---

## 6) Snippets de referência (adaptar à linguagem do projeto)

### 6.1 Regex e validação
```regex
# Novo compatível (sem máscara)
^[A-Z0-9]{12}\d{2}$

# Com máscara
^[A-Z0-9]{2}\.[A-Z0-9]{3}\.[A-Z0-9]{3}/[A-Z0-9]{4}-\d{2}$
```

### 6.2 Exemplo utilitário (pseudocódigo)
```pseudo
function mapChar(c):
  return ord(upper(c)) - 48  # A–Z e 0–9

function calcDV(base12): # retorna "NN"
  pesos1 = [5,4,3,2,9,8,7,6,5,4,3,2]
  soma1 = sum(mapChar(base12[i]) * pesos1[i] for i in 0..11)
  r1 = soma1 % 11
  dv1 = 0 if r1 < 2 else 11 - r1

  pesos2 = [6] + pesos1  # incluir dv1 na cauda ou recomputar conforme regra do projeto
  soma2 = sum(mapChar(base12[i]) * pesos2[i] for i in 0..11) + dv1 * 2
  r2 = soma2 % 11
  dv2 = 0 if r2 < 2 else 11 - r2

  return toString(dv1) + toString(dv2)
```

### 6.3 OpenAPI (exemplo)
```yaml
type: string
maxLength: 14
pattern: '^[A-Z0-9]{12}\d{2}$'
examples:
  - 'AB123456789012'
  - '12345678901234'
```

### 6.4 Testes (esboços)
```java
assertTrue(CnpjValidator.isValid("AB123456789012"));
assertTrue(CnpjValidator.isValid("12345678901234"));
assertFalse(CnpjValidator.isValid("AB12345678901"));     // 13 chars
assertFalse(CnpjValidator.isValid("AB12345678901Z"));    // DV não numérico
```

---

## 7) Regras de qualidade e segurança

- **Sem conversões numéricas** para CNPJ; **sem** `parseInt/Number`.  
- **Sem truncamento/padding automático** sem justificativa.  
- **Logs**: não vazar CNPJ em nível de produção; anonimizar quando possível.  
- **Perfomance**: revisar índices após mudar para string; avaliar *caches* se necessário.  
- **Backward compatibility**: suportar ambos os formatos; não quebrar integrações legadas.  

---

## 8) Entregáveis esperados

1. **Código atualizado** com suporte integral ao CNPJ alfanumérico.  
2. **Inventário de ocorrências** (CSV/JSON) anexado no apêndice do relatório.  
3. **Testes** unitários/integração/aceitação atualizados e passando.  
4. **Relatório final** salvo em `.cnpj_alfanumerico/documentos/implementacao.md` com:
   - Itens de escopo, decisões, riscos e próximos passos.
   - Tabelas de arquivos alterados e trechos antes/depois.
   - Evidências de execução (prints/logs/ids de commit).

---

## 9) Critérios de aceite

- Todas as validações e máscaras aceitam **A–Z e 0–9** nos 12 primeiros caracteres e **apenas dígitos** nos 2 últimos.  
- Nenhuma conversão numérica para CNPJ remanescente.  
- Consultas por CNPJ funcionam com `String` e mantêm desempenho aceitável com índices.  
- Testes (numérico e alfanumérico) cobrem caminhos críticos e passam.  
- Relatório final presente, completo e rastreável.

## 10) **Code Review Final**
   - **Revisar todos os arquivos atualizados**, comparando antes/depois.
   - **Executar linters e formatadores automáticos** para garantir padrão do projeto.
   - **Analisar potenciais regressões** em pontos críticos (validações, queries, serializações).
   - **Rodar novamente toda a suíte de testes** (unitários, integração e aceitação).
   - **Corrigir divergências** de tipagem, regex, conversões numéricas indevidas ou formatações incorretas.
   - **Aprovar apenas após dupla verificação** de que todas as mudanças seguem o padrão de qualidade e retrocompatibilidade.