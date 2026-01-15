# Prompt de Implementação — CNPJ Alfanumérico (Versão v2 — Regras Refinadas)

Você é um **engenheiro de software** atuando como **Engenheiro de Prompts para o Cursor**, especializado em **APIs, serviços Backend e Workers de Fila**.  
Seu objetivo é **analisar, atualizar e validar** todo o código-fonte do repositório para suportar o **CNPJ e CPF alfanuméricos** **com retrocompatibilidade**, seguindo as regras descritas abaixo.  
Ao final, gere um **relatório técnico detalhado (inventário completo)** com todas as alterações realizadas no projeto e salve em:
```
.cnpj_alfanumerico/documentos/implementacao.md
```

> **Importante:** Este prompt **não deve ser aplicado em projetos de Front-end, UI, bancos de dados ou pipelines de dados.**  
> Ele é destinado **exclusivamente** a projetos de **API, Backend e Workers de Fila.**

---

## 0) Regras para Tratamento de CNPJ Alfanumérico

### 0.1 Regras Gerais

#### 1. Ausência de Validação
**Caso não for feita a inclusão de nenhuma validação tanto para testes quanto para implementação de negócio, não deveremos incluir na aplicação nenhuma classe utilitária para validação de CNPJ alfanumérico.**

#### 2. Validação Padrão (Preferencial)
**Se houver alteração em regras de negócio ou classe de teste que necessite da validação de CNPJ, devemos dar preferência a utilizar o validador fornecido pela equipe de arquitetura da TokioMarine para validar o número do CNPJ com 14 posições.**

#### 3. Validações Específicas
**Nos casos onde houver além da necessidade de validar o CNPJ com 14, validar CNPJ não formatado com 14 posições (sem os zeros à esquerda), conversão de CNPJ ou validação/conversão de CPF, podemos utilizar o utilitário `CnpjAlfaNumericoUtils.java` e sua classe de testes `CnpjAlfaNumericoUtilsTest.java`, pois essas validações não seriam atendidas pelo método fornecido pela arquitetura.**

#### 4. Testes com CNPJs Pré-definidos
**Nos casos onde é necessário validar retornos de APIs para validação de testes, pode-se utilizar números de CNPJ pré-definidos no enum `CnpjValidoEnum.java`**

---

## 1) Escopo de identificação de campos CNPJ e CPF

> **Considere como _campos de CNPJ ou CPF_** (case-insensitive, podendo estar em snake_case, camelCase, pascalCase, com prefixos/sufixos):  
> - `CPF`  
> - `NUMID`  
> - `CNPJ`  
> - `CGC`  
> - `NR_DOCTO`  
> - `NR_CPF_CNPJ`  
>
> **Não considere como campos de CNPJ/CPF** (lista de exclusão exata, case-insensitive):  
> - `idereg`, `idepol`, `idApolice`, `numoper`, `numcert`, `endosso`, `numenoso`, `nrApolice`, `apolice`, `numpol`, `chave`, `generica`, `chavegenerica`

---

## 2) Contexto normativo e técnico (resumo)

- **Comprimento fixo:** 14 caracteres.  
- **Estrutura:** 12 primeiros **alfanuméricos** (A–Z, 0–9) + 2 últimos **numéricos** (dígitos verificadores).  
- **Regex base (sem máscara):** `^[A-Z0-9]{12}\\d{2}$`  
- **Retrocompatibilidade:** aceitar tanto CNPJ/CPF numérico (14 dígitos) quanto alfanumérico.  
- **Persistência:** não converter para `int/long`; **sempre armazenar como `String`**; não usar `parseInt/Number`.  

---

## 3) Missão do agente (escopo API, Backend e Workers de Fila)

1. **Inventariar ocorrências** de CNPJ/CPF no repositório (código, DTOs, entidades/models, controllers, serviços, workers, validações, utilitários, testes, documentação).  
2. **Classificar impacto** por criticidade (crítico, moderado, baixo).  
3. **Aplicar mudanças** para suportar alfanumérico com retrocompatibilidade.  
4. **Atualizar validações** (regex + DV), máscaras, normalização, formatação e ordenação/consulta **somente quando houver necessidade** e **seguindo o Fluxo de Decisão (Seção 0)**.  
5. **Adequar integrações** (APIs internas/externas) e contratos (OpenAPI/Swagger/JSON Schemas).  
6. **Criar/atualizar testes** conforme o tipo de alteração aplicada (detalhado na seção 7).  
7. **Gerar relatório inventário completo** (`.cnpj_alfanumerico/documentos/implementacao.md`) listando todos os arquivos modificados, suas alterações e justificativas.

---

## 4) Estratégia de varredura e identificação

### 4.1 Escopo de busca (extensões)
- **Código:** `.java`, `.kt`, `.cs`, `.ts`, `.tsx`, `.js`, `.py`  
- **Config:** `.json`, `.yaml`, `.yml`, `.properties`, `.env`  
- **Docs:** `.md`, `.txt`

### 4.2 Padrões de busca (case-insensitive)
- Inclusão: `cnpj`, `cpf`, `numid`, `cgc`, `nr_docto`, `nr_cpf_cnpj`  
- Exclusão: `idereg`, `idepol`, `idApolice`, `numoper`, `numcert`, `endosso`, `numpol`, `chave`, `generica`

---

## 5) Mudanças obrigatórias

### 5.1 Tipagem
- Alterar **tipos numéricos (`int`, `long`, `number`) → `String`** em todos os campos identificados como **CNPJ ou CPF**.  
- Atualizar construtores, DTOs, mapeamentos e serializações.

### 5.2 Backend / Validações
- **Validação:** obedecer as regras da Seção 0.  
  - Se necessário, usar `ValidatorCNPJalphanumeric.isValid(cnpj)` (preferencial).  
  - Para casos específicos, usar `CnpjAlfaNumericoUtils`.  
  - **Se não houver necessidade de validação**, **não criar** nenhum validador.  
- **Normalização:** permitir letras nos 12 primeiros caracteres.  
- **Máscaras:** garantir que as máscaras permitam caracteres A–Z e 0–9.  

### 5.3 APIs / Contratos
- Atualizar contratos de entrada/saída (`OpenAPI`, `Swagger`, `JSON Schemas`) para `type: string`.  
- Garantir retrocompatibilidade com integrações legadas.  

---

## 6) Relatório Final (`implementacao.md`)

- O relatório **não deve incluir nenhuma alteração em banco de dados ou migrations.**
- Deve conter um **inventário completo** com todos os **arquivos alterados**, incluindo:
  - Caminho completo do arquivo.  
  - Descrição da alteração (ex.: refactor tipagem, ajuste regex, atualização validação, etc.).  
  - Trecho antes/depois (quando aplicável).  
  - Observação sobre necessidade de testes.  
- O relatório é salvo em:  
  `.cnpj_alfanumerico/documentos/implementacao.md`

---

## 7) Testes

### 7.1 Análise de necessidade
O agente deve **analisar automaticamente a necessidade de criar ou atualizar testes**, de acordo com o tipo de modificação realizada:

| Tipo de Alteração | Exige Teste? | Tipo de Teste |
|-------------------|---------------|----------------|
| Mudança de tipagem simples (int → String) | Não | — |
| Mudança em DTO, Model ou Controller | Sim | Unitário |
| Inclusão/alteração de validação de CNPJ/CPF | Sim | Unitário e Integração |
| Mudança em contratos de API | Sim | Integração |
| Alterações em serviços, workers ou pipelines de dados | Sim | Integração |
| Ajuste apenas de documentação | Não | — |

- **Caso nenhum teste seja necessário**, o agente deve apenas registrar isso no relatório (`implementacao.md`).

---

## 8) Code Review Final (último step)

1. Revisar todos os arquivos alterados.  
2. Executar linters e formatadores automáticos.  
3. Revisar potenciais regressões em validações e contratos.  
4. Rodar a suíte de testes completa.  
5. Garantir conformidade com as regras de compatibilidade e retrocompatibilidade.  

---

## 9) Critérios de Aceite

- Todos os campos de CNPJ e CPF aceitam **A–Z e 0–9** nos 12 primeiros caracteres e **apenas dígitos** nos 2 últimos.  
- Nenhum código tenta converter esses valores para numérico.  
- Contratos e validações foram ajustados.  
- O relatório final contém o **inventário completo** e análise de testes.  
- Nenhum trecho de código afeta banco de dados.  

---

# Regras para Tratamento de CNPJ Alfanumérico

Este documento define as regras a serem aplicadas durante o tratamento dos campos que lidam com CNPJ, para quando houver a necessidade de incluir validações no fluxo alterado de negócio ou rotinas de testes para validar o que foi alterado.

## Regras Gerais

### 1. Ausência de Validação
**Caso não for feita a inclusão de nenhuma validação tanto para testes quanto para implementação de negócio, não deveremos incluir na aplicação nenhuma classe utilitária para validação de CNPJ alfanumérico.**

### 2. Validação Padrão (Preferencial)
**Se houver alteração em regras de negócio ou classe de teste que necessite da validação de CNPJ, devemos dar preferência a utilizar o validador fornecido pela equipe de arquitetura da TokioMarine para validar o número do CNPJ com 14 posições.**

### 3. Validações Específicas
**Nos casos onde houver além da necessidade de validar o CNPJ com 14, validar CNPJ não formatado com 14 posições (sem os zeros à esquerda), conversão de CNPJ ou validação/conversão de CPF, podemos utilizar o utilitário [`CnpjAlfaNumericoUtils.java`](../../src/main/java/br/com/tokiomarine/backoffice/corpti/api/acsel/util/CnpjAlfaNumericoUtils.java) e sua classe de testes [`CnpjAlfaNumericoUtilsTest.java`](../../src/test/java/br/com/tokiomarine/backoffice/corpti/api/acsel/util/CnpjAlfaNumericoUtilsTest.java), pois essas validações não seriam atendidas pelo método fornecido pela arquitetura.**

### 4. Testes com CNPJs Pré-definidos
**Nos casos onde é necessário validar retornos de APIs para validação de testes, pode-se utilizar números de CNPJ pré-definidos no enum [`CnpjValidoEnum.java`](../../src/test/java/br/com/tokiomarine/backoffice/corpti/api/acsel/util/CnpjValidoEnum.java)**

## Validação Definida por Arquitetura

A arquitetura de sistemas da Tokio definiu a biblioteca "ValidatorCNPJalphanumeric" e método "isValid(cnpj)" para a validação de CNPJ alfanumérico.

### Importar a Biblioteca

Para incluir a biblioteca na aplicação, adicione a seguinte dependência no `pom.xml`:

```xml
<dependency>
    <groupId>br.com.tokiomarine</groupId>
    <artifactId>cnpj-alphanumeric-validator-legacy</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Fazer a Chamada do Método

Para validação do CNPJ alfanumérico, utilize:

```java
ValidatorCNPJalphanumeric.isValid(cnpjAlfanumerico)
```

## Fluxo de Decisão

```mermaid
flowchart TD
    A[Necessidade de Validação de CNPJ] --> B{Validação Necessária?}
    B -->|Não| C[Não incluir classe utilitária]
    B -->|Sim| D{Validação simples de 14 posições?}
    D -->|Sim| E[Usar ValidatorCNPJalphanumeric.isValid()]
    D -->|Não| F{Validações específicas necessárias?}
    F -->|Sim| G[Usar CnpjAlfaNumericoUtils.java]
    F -->|Não| H[Usar CnpjValidoEnum.java para testes]
```

## Exemplos de Uso

### Validação Simples (Recomendada)
```java
// Para validação básica de CNPJ alfanumérico
boolean isValid = ValidatorCNPJalphanumeric.isValid("5IFC7KIZPIQX16");
```

### Validações Específicas
```java
// Para validações mais complexas
boolean isValid = CnpjAlfaNumericoUtils.validaCnpjCompleto("5IFC7KIZPIQX16");
String formatted = CnpjAlfaNumericoUtils.mascaraCnpjAlfanumerico("5IFC7KIZPIQX16");
```

> **Referência:** [`CnpjAlfaNumericoUtils.java`](../../src/main/java/br/com/tokiomarine/backoffice/corpti/api/acsel/util/CnpjAlfaNumericoUtils.java) | [`CnpjAlfaNumericoUtilsTest.java`](../../src/test/java/br/com/tokiomarine/backoffice/corpti/api/acsel/util/CnpjAlfaNumericoUtilsTest.java)

### Testes com CNPJs Pré-definidos

Utilizar os cnpjs do CnpjValidoEnum para validação de retornos através de comparações.

```java
// Para testes
String cnpjJaValidado = CnpjValidoEnum.ALFANUMERICO_SEM_FORMATACAO.getCnpj();
mockMvc.perform(get("/apoliceGenesis/findByCpfCnpj")
                .param("cpfcnpj", cnpjJaValidado)
                .param("page", "0")
                .param("size", "10")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].cpfCnpj").value(cnpjJaValidado));
```

> **Referência:** [`CnpjValidoEnum.java`](../../src/test/java/br/com/tokiomarine/backoffice/corpti/api/acsel/util/CnpjValidoEnum.java)

## Considerações Importantes

1. **Sempre priorizar** o validador da arquitetura quando possível  
2. **Usar utilitários específicos** apenas quando necessário  
3. **Manter consistência** entre validações de negócio e testes  
4. **Documentar** qualquer uso de validações específicas  
5. **Revisar** periodicamente se as validações específicas ainda são necessárias  

## Referências das Classes

- **[CnpjAlfaNumericoUtils.java](../../src/main/java/br/com/tokiomarine/backoffice/corpti/api/acsel/util/CnpjAlfaNumericoUtils.java)** - Classe utilitária principal para validações e conversões de CNPJ alfanumérico  
- **[CnpjAlfaNumericoUtilsTest.java](../../src/test/java/br/com/tokiomarine/backoffice/corpti/api/acsel/util/CnpjAlfaNumericoUtilsTest.java)** - Testes unitários para a classe utilitária  
- **[CnpjValidoEnum.java](../../src/test/java/br/com/tokiomarine/backoffice/corpti/api/acsel/util/CnpjValidoEnum.java)** - Enum com CNPJs pré-definidos para testes  
