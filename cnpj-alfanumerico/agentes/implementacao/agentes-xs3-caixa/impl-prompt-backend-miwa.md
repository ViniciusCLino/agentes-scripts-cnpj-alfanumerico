# Prompt de Implementação — CNPJ Alfanumérico (Versão v2.1 — Regras Refinadas e Busca Aprimorada)

Você é um **engenheiro de software** atuando como **Engenheiro de Prompts para o Cursor**, especializado em **APIs, serviços Backend e Workers de Fila**.  
Seu objetivo é **analisar, atualizar e validar** todo o código-fonte do repositório para suportar o **CNPJ e CPF alfanuméricos** **com retrocompatibilidade**, seguindo as regras descritas abaixo.  
Ao final, gere um **relatório técnico detalhado (inventário completo)** com todas as alterações realizadas no projeto e salve em:
```
.cnpj_alfanumerico/documentos/implementacao.md
```

> **Importante:** Este prompt **não deve ser aplicado em projetos de Front-end, UI, bancos de dados ou pipelines de dados.**  
> Ele é destinado **exclusivamente** a projetos de **API, Backend e Workers de Fila.**

---

## 🔍 Melhorias na Versão 2.1

### Problema Identificado
Na versão anterior, alguns componentes não foram encontrados durante a busca porque:
1. **Subpacotes não cobertos:** Arquivos em pacotes como `handler.devolucao.cadastro.impl`, `mapper.backoffice`, `externo.servicos.reaproveitamento`, `externo.servicos.ssc`, `servicos.externos.service` não estavam sendo buscados adequadamente.
2. **Busca por pacotes incompleta:** Os padrões de busca não incluíam buscas abrangentes por todos os subpacotes.
3. **Checklist incompleto:** Alguns componentes conhecidos não estavam listados no checklist obrigatório.
4. **Busca por @Length incompleta:** A busca por `@Length` não estava percorrendo todos os arquivos Java em todos os diretórios, deixando alguns componentes sem verificação.

### Soluções Implementadas
1. **Adicionados componentes ao checklist obrigatório:**
   - `AproveitamentoDadosRequest.java` (em `externo.servicos.reaproveitamento`)
   - `SolicitacaoCotacaoResponse.java` (em `externo.servicos.ssc`)
   - `CadastroFormaDevolucaoCreditoEmConta.java` (em `handler.devolucao.cadastro.impl`)
   - `ResseguradoraService.java` (em `servicos.externos.service`)
   - `DadosGeraisCotacaoService.java` (em `service.cotacao`)
   - `ApoliceAcselCupMapper.java` (em `mapper.backoffice`)

2. **Padrões de busca aprimorados:**
   - Adicionados padrões para buscar em TODOS os subpacotes: `package.*service|package.*mapper|package.*dto|package.*externo|package.*handler|package.*impl|package.*backoffice`
   - Adicionada busca por anotações: `@Service|@Mapper|@Component` seguida de verificação de uso de CNPJ/CPF
   - Adicionada busca final abrangente por todos os arquivos Java com campos `Long` ou `BigInteger` relacionados a CNPJ/CPF

3. **Nova categoria no checklist:**
   - Adicionada Seção 4.5.9 para "Handlers e Implementações Específicas"

4. **Validação cruzada aprimorada:**
   - Fase 10 agora inclui busca final abrangente por todos os pacotes e subpacotes
   - Code Review Final inclui verificação obrigatória de subpacotes específicos

5. **Busca abrangente por @Length (NOVO):**
   - Adicionada Fase 3.1 específica para busca exaustiva de `@Length` em TODOS os arquivos Java
   - Busca recursiva obrigatória usando grep/ripgrep em todos os diretórios e subdiretórios
   - Verificação de imports em todos os arquivos encontrados
   - Validação cruzada na Fase 10 e no Code Review Final para garantir que nenhum arquivo foi perdido
   - Documentação obrigatória de todos os arquivos com `@Length` no relatório final

---

## 0) Regras para Tratamento de CNPJ Alfanumérico

### 0.1 Regras Gerais

#### 1. Ausência de Validação
**Caso não for feita a inclusão de nenhuma validação tanto para testes quanto para implementação de negócio, não deveremos incluir na aplicação nenhuma classe utilitária para validação de CNPJ alfanumérico.**

#### 2. Validação Padrão (Preferencial)
**Se houver alteração em regras de negócio ou classe de teste que necessite da validação de CNPJ, devemos dar preferência a utilizar o validador fornecido pela equipe de arquitetura da TokioMarine para validar o número do CNPJ com 14 posições. O validador utiliza a classe `DocumentValidator` com o método `isValidCPForCNPJ()`.**

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
> - `cd_cpf_indcd_venda_pn`, `codigoCPFIndicadorVendaParceiroNegocio` (MANTER como Long - não é documento de identificação, é código de indicador)

---

## 2) Contexto normativo e técnico (resumo)

- **Comprimento fixo:** 14 caracteres.  
- **Estrutura:** 12 primeiros **alfanuméricos** (A–Z, 0–9) + 2 últimos **numéricos** (dígitos verificadores).  
- **Regex base (sem máscara):** `^[A-Z0-9]{12}\\d{2}$`  
- **Retrocompatibilidade:** aceitar tanto CNPJ/CPF numérico (14 dígitos) quanto alfanumérico.  
- **Persistência:** não converter para `int/long`; **sempre armazenar como `String`**; não usar `parseInt/Number`.  

---

## 3) Missão do agente (escopo API, Backend e Workers de Fila)

1. **Inventariar ocorrências** de CNPJ/CPF no repositório seguindo **TODAS as 10 fases da Seção 4.3** (incluindo a Fase 3.1 para busca abrangente de @Length) (código, DTOs, entidades/models, controllers, serviços, workers, validações, utilitários, mappers, integrações externas, serviços de print, testes, documentação).  
2. **Validar contra checklist obrigatório** da Seção 4.5 para garantir que todos os componentes conhecidos sejam identificados.  
3. **Classificar impacto** por criticidade (crítico, moderado, baixo) para cada componente identificado.  
4. **Aplicar mudanças** para suportar alfanumérico com retrocompatibilidade em **TODOS os componentes identificados**.  
5. **Atualizar validações** (regex + DV), máscaras, normalização, formatação e ordenação/consulta **somente quando houver necessidade** e **seguindo o Fluxo de Decisão (Seção 0)**.  
6. **Adequar integrações** (APIs internas/externas) e contratos (OpenAPI/Swagger/JSON Schemas) identificados nas fases 6, 7 e 8.  
7. **Atualizar utilitários** identificados na fase 3 para suportar CNPJ alfanumérico.  
8. **Atualizar mappers** identificados na fase 4 para trabalhar com String em vez de Long/BigInteger.  
9. **Atualizar serviços** identificados nas fases 5, 8 e 9 para remover conversões perigosas.  
10. **Criar/atualizar testes** conforme o tipo de alteração aplicada (detalhado na seção 7).  
11. **Verificar e atualizar dependências no pom.xml** conforme a Seção 5.4 (apenas atualizar versões de dependências existentes).  
12. **Verificar e corrigir imports de @Length:** Buscar todos os usos de `@Length` no projeto e garantir que todos tenham o import correto: `import org.hibernate.validator.constraints.Length;`
13. **Gerar arquivo de componentes pendentes** (`.cnpj_alfanumerico/documentos/componentes-pendentes.md`) **automaticamente** se houver componentes do checklist não encontrados.  
14. **Gerar relatório inventário completo** (`.cnpj_alfanumerico/documentos/implementacao.md`) listando **TODOS** os arquivos modificados, suas alterações e justificativas, incluindo componentes das 10 fases, verificação do pom.xml e correções de imports de `@Length`.

---

## 4) Estratégia de varredura e identificação abrangente

### 4.1 Escopo de busca (extensões)
- **Código:** `.java`, `.kt`, `.cs`, `.ts`, `.tsx`, `.js`, `.py`  
- **Config:** `.json`, `.yaml`, `.yml`, `.properties`, `.env`  
- **Docs:** `.md`, `.txt`

### 4.2 Padrões de busca (case-insensitive)
- Inclusão: `cnpj`, `cpf`, `numid`, `cgc`, `nr_docto`, `nr_cpf_cnpj`  
- Exclusão: `idereg`, `idepol`, `idApolice`, `numoper`, `numcert`, `endosso`, `numpol`, `chave`, `generica`

### 4.3 Busca abrangente de componentes Java (OBRIGATÓRIO)

O agente **DEVE** realizar **múltiplas buscas complementares** em sequência para garantir identificação completa de todos os componentes:

#### 4.3.1 Fase 1: Busca por declarações de campos e propriedades
```java
// Buscar TODAS as declarações de campos CNPJ/CPF
- Padrão: `private.*Long.*cnpj|private.*Long.*cpf|private.*BigInteger.*cnpj|private.*BigInteger.*cpf`
- Padrão: `@Column.*cnpj|@Column.*cpf|@JsonProperty.*cnpj|@JsonProperty.*cpf`
- Padrão: `numeroCNPJCPF|numeroCPFCNPJ|cpfCnpj|nrCnpjCpf|nrCpfCnpj|numeroCpfCnpj|numeroCpfCnpjSegurado` (case-insensitive)
- Padrão: `getNumeroCNPJCPF|setNumeroCNPJCPF|getNumeroCPFCNPJ|setNumeroCPFCNPJ` (getters/setters)
- Padrão: Busca abrangente por TODOS os arquivos Java usando grep/ripgrep: `private.*Long.*[Cc][Nn][Pp][Jj]|private.*BigInteger.*[Cc][Nn][Pp][Jj]|private.*Long.*[Cc][Pp][Ff]|private.*BigInteger.*[Cc][Pp][Ff]`
- Padrão: Buscar em TODOS os pacotes, incluindo subpacotes: usar busca recursiva por estrutura de diretórios
- Padrão: Buscar por nomes de variáveis específicos: `numeroCpfCnpjSegurado|nrCnpjCpfSgrdo|cpfCnpjSegurado` (variações de nomenclatura)
```

#### 4.3.2 Fase 2: Busca por conversões e transformações (CRÍTICO)
```java
// Buscar TODAS as conversões que podem falhar com CNPJ alfanumérico
- Padrão: `Long\.valueOf.*cnpj|Long\.valueOf.*cpf|Long\.valueOf.*numeroCNPJCPF|Long\.valueOf.*numeroCPFCNPJ`
- Padrão: `Long\.valueOf.*numeroCNPJCPFSegurado|Long\.valueOf.*numeroCNPJCPFTitular`
- Padrão: `Long\.parseLong.*cnpj|Long\.parseLong.*cpf|Long\.parseLong.*numeroCNPJCPF`
- Padrão: `BigInteger\.valueOf.*cnpj|BigInteger\.valueOf.*cpf|BigInteger\.valueOf.*numeroCPF`
- Padrão: `BigInteger\.valueOf.*numeroCPFPortal|BigInteger\.valueOf.*numeroCPFCNPJ`
- Padrão: `\.longValue\(\)|\.intValue\(\)` (quando aplicado a campos CNPJ/CPF)
- Padrão: `\.toString\(\)` (quando aplicado a campos CNPJ/CPF que são BigInteger/Long)
- Padrão: `String\.format.*%0.*d.*cnpj|String\.format.*%0.*d.*cpf` (formatação numérica)
- Padrão: `String\.format.*%014d|String\.format.*%011d` (com campos CNPJ/CPF no contexto)
- Padrão: `StringUtils\.leftPad.*cnpj|StringUtils\.leftPad.*cpf` (com padding numérico)
```

#### 4.3.3 Fase 3: Busca por utilitários de validação e formatação (CRÍTICO)
```java
// Buscar TODOS os usos de utilitários que podem precisar atualização
- Padrão: `CnpjCpfUtil|validaCNPJ|validaCPF|formataCNPJ|formataCPF|cleanCNPJ|cleanCPF`
- Padrão: `ValidatorCNPJ|ValidatorCPF|DocumentoUtil|StringUtil.*cnpj|StringUtil.*cpf`
- Padrão: `@Pattern.*cnpj|@Pattern.*cpf|@AssertTrue.*cnpj|@AssertTrue.*cpf`
- Padrão: `getCpfCnpjAsString|getRaizCnpj|getDigitoCnpj|getEstabelecimentoCnpj`
- Padrão: `createCnpj|createCpf|imprimeCNPJ|imprimeCnpjSemRaiz`
```

#### 4.3.3.1 Fase 3.1: Busca ABRANGENTE por @Length em TODOS os arquivos Java (OBRIGATÓRIO)
```java
// OBRIGATÓRIO: Buscar TODOS os usos de @Length em TODOS os arquivos Java do projeto
// Esta busca deve ser realizada de forma independente e exaustiva

// Busca 1: Buscar por uso direto da anotação @Length
- Padrão: `@Length` (buscar literalmente em TODOS os arquivos .java, sem filtros)
- Escopo: TODOS os diretórios, TODOS os pacotes, TODOS os subpacotes
- Método: Usar grep/ripgrep recursivo em TODOS os arquivos .java: `grep -r "@Length" --include="*.java" .`

// Busca 2: Buscar por imports relacionados a Length
- Padrão: `import.*Length` (buscar TODOS os imports que contenham "Length")
- Padrão: `import org.hibernate.validator.constraints.Length`
- Padrão: `import javax.validation.constraints.Length`
- Padrão: `import jakarta.validation.constraints.Length`
- Padrão: `import.*constraints.*Length`
- Escopo: TODOS os arquivos .java em TODOS os diretórios

// Busca 3: Buscar por uso de @Length em contexto de campos CNPJ/CPF
- Padrão: `@Length.*cnpj|@Length.*cpf|@Length.*numeroCNPJCPF|@Length.*numeroCPFCNPJ`
- Padrão: `@Length.*numeroCpfCnpj|@Length.*nrCnpjCpf|@Length.*nrCpfCnpj`
- Escopo: TODOS os arquivos .java

// Busca 4: Buscar por uso de @Length em qualquer campo (não apenas CNPJ/CPF)
- Padrão: `@Length\(` (buscar @Length seguido de parêntese)
- Padrão: `@Length\s*\(` (buscar @Length com espaços opcionais antes do parêntese)
- Escopo: TODOS os arquivos .java em TODOS os diretórios e subdiretórios

// Busca 5: Buscar por classes que podem usar @Length (entidades, DTOs, models)
- Padrão: `@Entity|@Table|class.*DTO|class.*Request|class.*Response|class.*Model`
- Ação: Para cada classe encontrada, verificar se contém @Length
- Escopo: TODOS os pacotes e subpacotes

// Busca 6: Busca recursiva por estrutura de diretórios
- Método: Listar TODOS os diretórios que contêm arquivos .java
- Ação: Para cada diretório, buscar @Length recursivamente
- Escopo: Incluir diretórios: src/main/java, src/test/java, e qualquer outro diretório com .java

// Validação obrigatória:
1. Listar TODOS os arquivos .java que contêm @Length
2. Para cada arquivo encontrado:
   - Verificar se possui import correto: `import org.hibernate.validator.constraints.Length;`
   - Se não tiver import ou tiver import incorreto, corrigir
   - Verificar se @Length está sendo usado em campos CNPJ/CPF
   - Se estiver em campo CNPJ/CPF, garantir que max = 14 (ou conforme necessário)
3. Gerar lista completa de arquivos com @Length para documentação no relatório final
```

#### 4.3.4 Fase 4: Busca por mappers e conversores (CRÍTICO)
```java
// Buscar TODOS os mappers que fazem conversões de tipo
- Padrão: `@Mapper|@Mapping.*cnpj|@Mapping.*cpf|MapStruct`
- Padrão: `@Named.*cnpj|@Named.*cpf|qualifiedByName.*cnpj|qualifiedByName.*cpf`
- Padrão: `convert.*cnpj|convert.*cpf|map.*cnpj|map.*cpf` (métodos de conversão)
- Padrão: `cnpjCpfAsString|cnpjCpfFromCotacao|convertCpfStringToBigDecimal`
- Padrão: `Mapper.*cnpj|Mapper.*cpf` (classes mapper)
- Padrão: `ApoliceAcsel.*Mapper|Acsel.*Mapper` (buscar mappers específicos do backoffice)
- Padrão: `package.*mapper|package.*backoffice` (buscar em TODOS os pacotes de mappers, incluindo subpacotes)
- Padrão: `class.*Mapper` (buscar todas as classes com "Mapper" no nome e verificar uso de CNPJ/CPF)
```

#### 4.3.5 Fase 5: Busca por serviços e repositórios (CRÍTICO)
```java
// Buscar TODOS os métodos de serviço e repositório que usam CNPJ/CPF
- Padrão: `findBy.*cnpj|findBy.*cpf|findAllBy.*cnpj|findAllBy.*cpf|findOneBy.*cnpj`
- Padrão: `findAllBy.*numeroCNPJCPFSegurado|findBy.*numeroCPFCNPJ`
- Padrão: `Repository.*cnpj|Repository.*cpf|Service.*cnpj|Service.*cpf`
- Padrão: `CrivoService|BasePrintService|CotacaoCrivoService|KmeService`
- Padrão: `EndossoDadosCadastraisService|SolicitacaoCotacaoService|RepresentanteService`
- Padrão: `ClienteService|AproveitamentoDadosService|DadosGeraisCotacaoService`
- Padrão: `ResseguradoraService` (em `servicos.externos.service`)
- Padrão: `validar.*cnpj|validar.*cpf|consultar.*cnpj|consultar.*cpf|verificar.*cnpj|verificar.*cpf`
- Padrão: `getCrivo.*cnpj|getCrivo.*cpf|mapControladoraRequest` (métodos específicos)
- Padrão: `validarDadosControladora|verificarCrivo` (métodos que recebem CNPJ/CPF como parâmetro)
- Padrão: `getCpfCnpjFormatado|formataCpfCnpj|preencheCpfCnpj` (métodos de formatação)
- Padrão: `package.*service|package.*servicos` (buscar em TODOS os pacotes de serviços, incluindo subpacotes)
- Padrão: `@Service` (buscar todas as classes anotadas com @Service e verificar uso de CNPJ/CPF)
```

#### 4.3.6 Fase 6: Busca por DTOs e contratos de API (CRÍTICO)
```java
// Buscar TODOS os DTOs externos e internos
- Padrão: `class.*DTO|interface.*Request|interface.*Response` (com campos CNPJ/CPF)
- Padrão: `SolicitacaoCotacaoInterfaceRequest|SolicitacaoCotacaoResponse|DiretrizCulturaBlaze|ControladoraRequest|ControladoraResponse`
- Padrão: `AproveitamentoDadosRequest` (em `externo.servicos.reaproveitamento`)
- Padrão: `@Schema.*cnpj|@Schema.*cpf|@ApiModelProperty.*cnpj` (OpenAPI/Swagger)
- Padrão: `setNrCnpjCpfSgrdo|setNumeroCNPJCPFSegurado|setCpfCnpjSegurado|setNumeroCpfCnpjSegurado`
- Padrão: `getNrCnpjCpfSgrdo|getNumeroCNPJCPFSegurado|getCpfCnpjSegurado|getNumeroCpfCnpjSegurado`
- Padrão: `package.*dto|package.*externo|package.*reaproveitamento` (buscar em TODOS os pacotes de DTOs)
- Padrão: `private.*Long.*[Cc][Nn][Pp][Jj]|private.*Long.*[Cc][Pp][Ff]` (buscar campos Long em todas as classes)
```

#### 4.3.7 Fase 7: Busca por controllers e endpoints
```java
// Buscar TODOS os endpoints que recebem CNPJ/CPF
- Padrão: `@GetMapping|@PostMapping|@PutMapping|@RequestMapping` (com parâmetros CNPJ/CPF)
- Padrão: `@RequestParam.*cnpj|@RequestParam.*cpf|@PathVariable.*cnpj|@PathVariable.*cpf`
- Padrão: `@RequestBody.*cnpj|@RequestBody.*cpf`
- Padrão: `Controller.*cnpj|Controller.*cpf` (classes controller)
```

#### 4.3.8 Fase 8: Busca por integrações externas (CRÍTICO)
```java
// Buscar TODAS as integrações externas
- Padrão: `Client.*cnpj|Client.*cpf|Service.*cnpj|Service.*cpf` (integrações)
- Padrão: `FeignClient|RestTemplate.*cnpj|WebClient.*cnpj` (chamadas HTTP)
- Padrão: `externo.*cnpj|externo.*cpf|integracao.*cnpj` (pacotes de integração)
- Padrão: `BlazeService|ControladoraService|SolicitacaoCotacaoService` (serviços externos)
- Padrão: `chamaBlaze|chamarDiretrizCulturaBlaze|validarDadosControladora` (métodos de integração)
- Padrão: `createDiretrizCulturaBlazeResquest|getDiretrizCulturaBlazeRequestFromCotacao`
- Padrão: `SolicitacaoCotacaoInterfaceRequest|DiretrizCulturaBlaze|SeguradoRequest`
- Padrão: `ControladoraRequest|ControladoraResponse|AproveitamentoDadosRequest`
- Padrão: `setNrCnpjCpfSgrdo|setNumeroCNPJCPFSegurado|getNrCnpjCpfSgrdo`
```

#### 4.3.9 Fase 9: Busca por serviços de print e formatação
```java
// Buscar TODOS os serviços que formatam CNPJ/CPF para impressão
- Padrão: `PrintService|formataCPFString|formataCNPJString|getCpfCnpjFormatado`
- Padrão: `BasePrintService|PropostaPrintService|CotacaoPrintService|TermoSubvencaoPrintService`
- Padrão: `gerarLinhaTexto.*cnpj|gerarLinhaTexto.*cpf` (formatação em relatórios)
- Padrão: `package.*print|package.*service.*print` (buscar em TODOS os pacotes de serviços de print)
- Padrão: `class.*PrintService` (buscar todas as classes com "PrintService" no nome)
```

#### 4.3.10 Fase 10: Busca por métodos que recebem Long/BigInteger como parâmetro
```java
// Buscar TODOS os métodos que recebem CNPJ/CPF como Long/BigInteger
- Padrão: `methodName.*Long.*numeroCpfCnpj|methodName.*BigInteger.*numeroCpfCnpj`
- Padrão: `validarDadosControladora.*Long|verificarCrivo.*Long|mapControladoraRequest.*Long`
- Padrão: `getCpfCnpjAsString.*Long|createCnpj.*Long|createCpf.*Long`
```

### 4.4 Ordem de execução obrigatória das buscas

O agente **DEVE** executar as buscas na seguinte ordem e **validar cada fase antes de prosseguir**:

1. **Fase 1 - Identificação de campos:**
   - Buscar todas as declarações de campos CNPJ/CPF em entidades, DTOs e models
   - Classificar por tipo (Long, BigInteger, String)
   - **Validar:** Lista completa de campos encontrados

2. **Fase 2 - Identificação de conversões:**
   - Buscar todas as conversões de String para Long/BigInteger
   - Buscar todas as conversões de Long/BigInteger para String
   - Identificar pontos de falha com CNPJ alfanumérico
   - **Validar:** Nenhuma conversão perigosa foi perdida

3. **Fase 3 - Identificação de utilitários:**
   - Buscar todas as classes utilitárias de validação e formatação
   - Verificar métodos que fazem parsing ou conversão
   - **Validar:** Todos os utilitários foram identificados

3.1. **Fase 3.1 - Busca ABRANGENTE por @Length (OBRIGATÓRIO):**
   - **OBRIGATÓRIO:** Realizar busca recursiva por `@Length` em TODOS os arquivos .java do projeto
   - Usar grep/ripgrep para buscar literalmente `@Length` em todos os diretórios
   - Buscar todos os imports relacionados a `Length` (hibernate, javax, jakarta)
   - Para cada arquivo encontrado com `@Length`:
     - Verificar se possui import correto: `import org.hibernate.validator.constraints.Length;`
     - Corrigir imports incorretos ou ausentes
     - Verificar se está em campos CNPJ/CPF e ajustar max conforme necessário
   - Gerar lista completa de todos os arquivos com `@Length` para documentação
   - **Validar:** Todos os arquivos Java foram verificados e todos os imports de `@Length` estão corretos

4. **Fase 4 - Identificação de mappers:**
   - Buscar todos os mappers (MapStruct, manual, etc.)
   - Verificar métodos de conversão entre tipos
   - **Validar:** Todos os mappers foram identificados

5. **Fase 5 - Identificação de serviços:**
   - Buscar métodos de serviço que processam CNPJ/CPF
   - Verificar repositórios e queries
   - **Validar:** Todos os serviços foram identificados

6. **Fase 6 - Identificação de contratos:**
   - Buscar DTOs de entrada/saída de APIs
   - Verificar documentação OpenAPI/Swagger
   - **Validar:** Todos os contratos foram identificados

7. **Fase 7 - Identificação de controllers:**
   - Buscar endpoints que recebem CNPJ/CPF
   - Verificar parâmetros e body de requisições
   - **Validar:** Todos os controllers foram identificados

8. **Fase 8 - Identificação de integrações:**
   - Buscar clientes e serviços externos
   - Verificar chamadas HTTP e contratos externos
   - **Validar:** Todas as integrações foram identificadas

9. **Fase 9 - Identificação de serviços de print:**
   - Buscar serviços que formatam para impressão
   - Verificar formatação de CNPJ/CPF em relatórios
   - **Validar:** Todos os serviços de print foram identificados

10. **Fase 10 - Validação cruzada final:**
    - Comparar resultados de todas as fases com o checklist da Seção 4.5
    - Identificar componentes que podem ter sido perdidos
    - Verificar dependências entre componentes
    - **Validar:** Nenhum componente crítico foi perdido
    - **OBRIGATÓRIO:** Realizar busca final abrangente por TODOS os arquivos Java usando:
      - Busca por padrões de campos: `private.*Long.*[Cc][Nn][Pp][Jj]|private.*BigInteger.*[Cc][Nn][Pp][Jj]|private.*Long.*[Cc][Pp][Ff]|private.*BigInteger.*[Cc][Pp][Ff]`
      - Busca por pacotes completos: `package.*service|package.*mapper|package.*dto|package.*externo|package.*handler|package.*impl|package.*backoffice|package.*reaproveitamento|package.*ssc`
      - Busca por anotações: `@Service|@Mapper|@Component` seguida de verificação de uso de CNPJ/CPF
      - Busca por conversões: `Long\.valueOf|Long\.parseLong|BigInteger\.valueOf` em contexto de CNPJ/CPF
      - Busca por classes específicas: `ApoliceAcsel.*Mapper|DadosGerais.*Service|Resseguradora.*Service|CadastroFormaDevolucao.*`
    - **OBRIGATÓRIO - Busca Final por @Length:**
      - Realizar busca recursiva final por `@Length` em TODOS os arquivos .java do projeto
      - Usar grep/ripgrep: buscar literalmente `@Length` em todos os diretórios e subdiretórios
      - Verificar TODOS os arquivos encontrados para garantir que:
        - Possuem import correto: `import org.hibernate.validator.constraints.Length;`
        - Imports incorretos foram corrigidos
        - Campos CNPJ/CPF com @Length têm max = 14 (ou conforme necessário)
      - Comparar com a lista gerada na Fase 3.1 para garantir que nenhum arquivo foi perdido
      - Se encontrar novos arquivos com @Length não identificados na Fase 3.1, corrigir e documentar
    - **OBRIGATÓRIO:** Se algum componente do checklist não foi encontrado, gerar arquivo `.cnpj_alfanumerico/documentos/componentes-pendentes.md`
    - **OBRIGATÓRIO:** Realizar busca final usando todos os padrões da Seção 4.5 antes de finalizar

### 4.5 Checklist de Componentes Conhecidos (OBRIGATÓRIO)

O agente **DEVE** verificar a presença dos seguintes tipos de componentes em cada fase. Se algum componente não for encontrado, **DEVE** realizar buscas adicionais e documentar em `.cnpj_alfanumerico/documentos/componentes-pendentes.md`.

#### 4.5.1 Entidades Oracle (Fase 1)
**Componentes que DEVEM ser encontrados:**
- `Cotacao.java` - campo `numeroCNPJCPFSegurado`, `numeroCNPJCPFTitularDebito`
- `ItemCotacao.java` - campo `numeroCNPJCPFSegurado`
- `ItemCossegurado.java` - campo `numeroCPFCNPJ`
- `ItemBeneficiario.java` - campo `numeroCPFCNPJ`
- `ItemPiloto.java` - campo `numeroCNPJCPFPiloto`
- `Representante.java` - campo `numeroCNPJCPF`
- `LogProcessamentoCotacao.java` - campo `numeroCPFCNPJ`
- `ContaCorrenteGlobal.java` - campo `numeroCPFPortal` (NOTA: `codigoCPFIndicadorVendaParceiroNegocio` / `cd_cpf_indcd_venda_pn` deve MANTER-SE como Long)
- `ResponsavelEmpresa.java` - campo `numeroCpf`
- `Segurado.java` - campo `numeroCpfCnpj`

**Padrões de busca adicionais:**
```java
// Buscar por nomes específicos de entidades
- Padrão: `class.*Cotacao|class.*ItemCotacao|class.*ItemCossegurado|class.*ItemBeneficiario`
- Padrão: `class.*ItemPiloto|class.*Representante|class.*LogProcessamento|class.*ContaCorrente`
- Padrão: `class.*ResponsavelEmpresa|class.*Segurado`
- Padrão: `@Entity.*Cotacao|@Entity.*ItemCotacao|@Table.*COTAC|@Table.*ITEM`
```

#### 4.5.2 Entidades MongoDB (Fase 1)
**Componentes que DEVEM ser encontrados:**
- `ItemPilotoApolice.java` - campo `numeroCNPJCPFPiloto`
- `ItemCosseguradoApolice.java` - campo `numeroCPFCNPJ`
- `ItemBeneficiarioApolice.java` - campo `numeroCpfCnpj`
- `ItemApolice.java` - campo `numeroCNPJCPFSegurado`
- `Apolice.java` - campo `numeroCNPJCPFSegurado`
- `DadosOriginaisApolice.java` - campo `numeroCNPJCPFSegurado`

**Padrões de busca adicionais:**
```java
// Buscar por pacotes MongoDB
- Padrão: `domain.*mongo|domain.*formalizacao|domain.*apolice`
- Padrão: `class.*Apolice|class.*ItemApolice|class.*ItemPilotoApolice`
- Padrão: `class.*ItemCosseguradoApolice|class.*ItemBeneficiarioApolice`
```

#### 4.5.3 DTOs Internos (Fase 6)
**Componentes que DEVEM ser encontrados:**
- `ItemApoliceDTO.java` - campo `numeroCNPJCPFSegurado`
- `ApoliceDTO.java` - campo `numeroCNPJCPFSegurado`
- `ItemCosseguradoApoliceDTO.java` - campo `numeroCPFCNPJ`
- `ItemBeneficiarioApoliceDTO.java` - campo `numeroCpfCnpj`
- `EndossoAlteracaoAgroDTO.java` - campo `numeroCNPJCPFSegurado`
- `ClienteDadosPagamento.java` - campo `numeroCNPJCPFTitularContaCorrenteDebito`
- `EndossoDadosCadastraisDTO.java` - campo `numeroCNPJCPFSegurado`

**Padrões de busca adicionais:**
```java
// Buscar por padrões de DTOs
- Padrão: `class.*DTO|class.*Request|class.*Response` (com campos CNPJ/CPF)
- Padrão: `dto.*endosso|dto.*cotacao|dto.*apolice`
- Padrão: `ItemApoliceDTO|ApoliceDTO|ItemCosseguradoApoliceDTO|ItemBeneficiarioApoliceDTO`
- Padrão: `package.*dto|package.*endosso|package.*cotacao` (buscar em todos os pacotes de DTOs)
```

#### 4.5.4 Serviços (Fase 5)
**Componentes que DEVEM ser encontrados:**
- `CrivoService.java` - métodos que usam `BigInteger` para CNPJ/CPF
- `BasePrintService.java` - método `getCpfCnpjFormatado`
- `CotacaoCrivoService.java` - uso de `.toString()` em CNPJ/CPF
- `KmeService.java` - conversão de `numeroCPFPortal` para `BigInteger`
- `EndossoDadosCadastraisService.java` - conversões `Long.valueOf`
- `SolicitacaoCotacaoService.java` - conversões `Long.valueOf`
- `RepresentanteService.java` - conversões `Long.parseLong`
- `ClienteService.java` - formatação com `String.format("%014d")`
- `AproveitamentoDadosService.java` - uso de CNPJ/CPF
- `DadosGeraisCotacaoService.java` - métodos que usam CNPJ/CPF
- `ResseguradoraService.java` - métodos que usam CNPJ/CPF (em `servicos.externos.service`)

**Padrões de busca adicionais:**
```java
// Buscar por métodos específicos de serviços
- Padrão: `getCpfCnpjFormatado|formataCpfCnpj|preencheCpfCnpj`
- Padrão: `validarDadosControladora|verificarCrivo|getCrivo`
- Padrão: `Service.*Crivo|Service.*Print|Service.*Cotacao|Service.*Endosso`
- Padrão: `class.*Service.*cnpj|class.*Service.*cpf` (buscar todas as classes Service)
- Padrão: `package.*service|package.*servicos` (buscar em todos os pacotes de serviços)
- Padrão: `@Service.*cnpj|@Service.*cpf` (buscar anotações Service com campos CNPJ/CPF)
- Padrão: `DadosGerais.*Service|Resseguradora.*Service` (buscar serviços específicos)
```

#### 4.5.5 Mappers (Fase 4)
**Componentes que DEVEM ser encontrados:**
- `DadosViewMapper.java` - conversões `Long.valueOf`, `StringUtils.leftPad`
- `CotacaoDTOMapper.java` - método `cnpjCpfAsString` que recebe `Long`
- `CotacaoSeguradoDTOMapper.java` - método `cnpjCpfAsString` que recebe `Long`
- `EndossoCancelamentoMapper.java` - método `cnpjCpfAsString` que recebe `Long`
- `ApoliceAcselClienteMapper.java` - método `getCpfCnpj` que retorna `Long`
- `ApoliceAcselItemCotacaoMapper.java` - mapeamento de `nrCpfCnpj`
- `ApoliceAcselCupMapper.java` - mapeamento de CNPJ/CPF (em `mapper.backoffice`)
- `ClienteMapper.java` - mapeamento de `nrCpf`, `nrCnpj`
- `CotacaoBlazeMapper.java` - mapeamento de `numeroCNPJCPFSegurado`

**Padrões de busca adicionais:**
```java
// Buscar por anotações MapStruct
- Padrão: `@Mapper|@Mapping.*numeroCNPJCPF|@Mapping.*numeroCPFCNPJ`
- Padrão: `@Named.*cnpjCpfAsString|qualifiedByName.*cnpjCpfAsString`
- Padrão: `Mapper.*DTO|Mapper.*Blaze|Mapper.*Cliente|Mapper.*Endosso`
- Padrão: `class.*Mapper.*cnpj|class.*Mapper.*cpf` (buscar todas as classes Mapper)
- Padrão: `package.*mapper|package.*backoffice` (buscar em todos os pacotes de mappers)
- Padrão: `ApoliceAcsel.*Mapper|Acsel.*Mapper` (buscar mappers específicos do backoffice)
```

#### 4.5.6 Repositórios (Fase 5)
**Componentes que DEVEM ser encontrados:**
- `AproveitamentoDadosRepository.java` - métodos `findAllBy.*numeroCNPJCPFSegurado`
- `ItemCosseguradoRepository.java` - método `findBy.*numeroCPFCNPJ`

**Padrões de busca adicionais:**
```java
// Buscar por métodos de repositório
- Padrão: `Repository.*cnpj|Repository.*cpf|findBy.*cnpj|findBy.*cpf`
- Padrão: `findAllBy.*numeroCNPJCPF|findBy.*numeroCPFCNPJ`
```

#### 4.5.7 Integrações Externas (Fase 8)
**Componentes que DEVEM ser encontrados:**
- `BlazeService.java` - método `createDiretrizCulturaBlazeResquest` com `Long.valueOf`
- `SolicitacaoCotacaoInterfaceRequest.java` - campo `nrCnpjCpfSgrdo` como `Long`
- `SolicitacaoCotacaoResponse.java` - campo `nrCnpjCpfSgrdo` como `Long` (em `externo.servicos.ssc`)
- `SeguradoRequest.java` - campo `numeroCNPJCPFSegurado` como `Long`
- `AproveitamentoDadosRequest.java` - campo `numeroCpfCnpjSegurado` (em `externo.servicos.reaproveitamento`)
- `DiretrizCulturaBlaze.java` - campo `numeroCNPJCPFSegurado` (verificar tipo)
- `ControladoraRequest.java` - métodos que recebem `Long` para CNPJ/CPF
- `ControladoraResponse.java` - campos relacionados a CNPJ/CPF

**Padrões de busca adicionais:**
```java
// Buscar por DTOs externos
- Padrão: `externo.*servicos|servicos.*externos|dto.*externo`
- Padrão: `SolicitacaoCotacaoInterfaceRequest|DiretrizCulturaBlaze|ControladoraRequest`
- Padrão: `SeguradoRequest|BlazeService|ControladoraService`
- Padrão: `SolicitacaoCotacaoResponse|AproveitamentoDadosRequest` (buscar DTOs de resposta e request)
- Padrão: `package.*externo|package.*reaproveitamento|package.*ssc` (buscar em todos os pacotes externos)
- Padrão: `class.*Request.*cnpj|class.*Response.*cnpj|class.*Request.*cpf|class.*Response.*cpf`
```

#### 4.5.8 Utilitários (Fase 3)
**Componentes que DEVEM ser encontrados:**
- `CnpjCpfUtil.java` - métodos `validaCNPJ`, `validaCPF`, `formataCNPJ`, `formataCPF`, `cleanCNPJ`, `cleanCPF`
- `StringUtil2.java` - método `preencheCpfCnpjComZerosAEsquerda` que recebe `Long`
- `BasePrintService.java` - métodos de formatação de CNPJ/CPF para impressão
- `CrivoService.java` - métodos que formatam CNPJ/CPF

**Padrões de busca adicionais:**
```java
// Buscar por classes utilitárias
- Padrão: `CnpjCpfUtil|StringUtil.*cnpj|StringUtil.*cpf|DocumentoUtil`
- Padrão: `validaCNPJ|validaCPF|formataCNPJ|formataCPF|cleanCNPJ|cleanCPF`
- Padrão: `preencheCpfCnpj|getCpfCnpjAsString|getRaizCnpj|getDigitoCnpj`
- Padrão: `PrintService|BasePrintService|formataCPFString|formataCNPJString`
- Padrão: `package.*util|package.*infra.*util` (buscar em todos os pacotes de utilitários)
```

#### 4.5.9 Handlers e Implementações Específicas (Fase 5)
**Componentes que DEVEM ser encontrados:**
- `CadastroFormaDevolucaoCreditoEmConta.java` - métodos que usam CNPJ/CPF (em `handler.devolucao.cadastro.impl`)

**Padrões de busca adicionais:**
```java
// Buscar por handlers e implementações
- Padrão: `handler.*cnpj|handler.*cpf|impl.*cnpj|impl.*cpf`
- Padrão: `CadastroFormaDevolucao.*|FormaDevolucao.*`
- Padrão: `package.*handler|package.*impl` (buscar em todos os pacotes de handlers)
- Padrão: `class.*Handler.*cnpj|class.*Impl.*cnpj` (buscar classes Handler e Impl)
```

### 4.6 Validação de completude obrigatória

Após cada fase, o agente **DEVE**:
1. Gerar um resumo dos componentes encontrados
2. **Comparar com o checklist da Seção 4.5** correspondente à fase
3. **Se algum componente do checklist não for encontrado:**
   - Realizar buscas adicionais usando os padrões específicos da Seção 4.5
   - Se ainda não encontrar, documentar em `.cnpj_alfanumerico/documentos/componentes-pendentes.md` com:
     - Nome do componente esperado
     - Fase em que deveria ser encontrado
     - Padrões de busca utilizados
     - Razão provável da não identificação (se conhecida)
4. **Gerar arquivo de pendências automaticamente:**
   - **SEMPRE gerar o arquivo**, mesmo que não haja componentes pendentes (para documentar que tudo foi encontrado)
   - Caminho: `.cnpj_alfanumerico/documentos/componentes-pendentes.md`
   - Formato obrigatório:
     ```markdown
     # Componentes Pendentes - CNPJ Alfanumérico
     
     ## Data: [DATA_ATUAL]
     
     ## Status da Validação
     - ✅ Todas as fases executadas: [SIM/NÃO]
     - ✅ Checklist validado: [SIM/NÃO]
     - Total de componentes do checklist: [NÚMERO]
     - Componentes encontrados: [NÚMERO]
     - Componentes pendentes: [NÚMERO]
     
     ### Fase [NÚMERO] - [NOME_DA_FASE]
     
     #### Componentes Não Encontrados:
     - **Componente:** [Nome do componente]
     - **Tipo:** [Entidade/DTO/Serviço/Mapper/etc]
     - **Fase esperada:** [Número da fase]
     - **Padrões de busca utilizados:** [Lista de padrões]
     - **Buscas adicionais realizadas:** [SIM/NÃO - detalhar]
     - **Ação recomendada:** [Busca manual / Verificação adicional / Componente não existe no projeto / etc]
     - **Criticidade:** [CRÍTICO/MODERADO/BAIXO]
     
     ### Resumo Final
     - Total de componentes pendentes: [NÚMERO]
     - Componentes críticos pendentes: [NÚMERO]
     - Componentes moderados pendentes: [NÚMERO]
     - Componentes de baixa criticidade pendentes: [NÚMERO]
     
     ## Observações
     [Qualquer observação relevante sobre componentes não encontrados ou validações realizadas]
     ```
5. **Validar cruzamento entre fases:** Verificar se componentes encontrados em uma fase aparecem em outras fases relacionadas
6. **Registrar no arquivo de pendências:** Mesmo que todos os componentes sejam encontrados, registrar no arquivo que a validação foi concluída com sucesso

---

## 5) Mudanças obrigatórias

### 5.1 Tipagem
- Alterar **tipos numéricos (`int`, `long`, `number`) → `String`** em todos os campos identificados como **CNPJ ou CPF**.  
- Atualizar construtores, DTOs, mapeamentos e serializações.
- **EXCEÇÃO OBRIGATÓRIA:** O campo `cd_cpf_indcd_venda_pn` / `codigoCPFIndicadorVendaParceiroNegocio` **DEVE permanecer como Long** nas classes `ContaCorrenteGlobal` e `SolicitacaoCotacao`. Este campo é um código de indicador de venda, não um documento de identificação pessoal.

### 5.2 Backend / Validações
- **Validação:** obedecer as regras da Seção 0.  
  - Se necessário, usar `DocumentValidator.isValidCPForCNPJ(cnpj)` (preferencial).  
  - Para casos específicos, usar `CnpjAlfaNumericoUtils`.  
  - **Se não houver necessidade de validação**, **não criar** nenhum validador.  
- **Normalização:** permitir letras nos 12 primeiros caracteres.  
- **Máscaras:** garantir que as máscaras permitam caracteres A–Z e 0–9.
- **Anotação @Length (OBRIGATÓRIO):** 
  - **Sempre que encontrar uso de `@Length` no projeto**, verificar e garantir que o import correto seja utilizado: `import org.hibernate.validator.constraints.Length;`
  - **Se encontrar imports incorretos ou ausentes de `@Length`**, corrigir para: `import org.hibernate.validator.constraints.Length;`
  - **Se `@Length` estiver sendo usado em campos CNPJ/CPF**, garantir que o comprimento máximo seja 14 caracteres (ou conforme necessário para o campo específico).
  - **Documentar no relatório final** todos os arquivos onde `@Length` foi verificado e/ou corrigido.  

### 5.3 APIs / Contratos
- Atualizar contratos de entrada/saída (`OpenAPI`, `Swagger`, `JSON Schemas`) para `type: string`.  
- Garantir retrocompatibilidade com integrações legadas.  

### 5.4 Verificação de Dependências no pom.xml (OBRIGATÓRIO)

O agente **DEVE** verificar o arquivo `pom.xml` do projeto e garantir que as seguintes dependências estejam nas versões especificadas, **apenas se já existirem no arquivo**. Se uma dependência não existir no `pom.xml`, **não deve ser adicionada**.

**Bibliotecas e versões obrigatórias (se presentes):**

| ArtifactId | Versão Obrigatória |
|------------|-------------------|
| `ctpj-corporate-utils` | **NÃO ALTERAR** - manter a dependência existente (não remover, não substituir) |
| `psr-dto` | `0.0.20-SNAPSHOT` |
| `plt-kme-blaze-dto` | `1.0.1-SNAPSHOT` |
| `ctpj-rc-domain` | `1.0.2-SNAPSHOT` |
| `ctpj-mensageria-domain` | `1.0.1-SNAPSHOT` |
| `ctpj-escritural-domain` | `1.2.1-SNAPSHOT` |
| `ctpj-equipamentos-domain` | `0.0.2-SNAPSHOT` |
| `ctpj-empresarial-domain` | `1.0.1-SNAPSHOT` |
| `ctpj-componentes-domain` | `1.0.18-SNAPSHOT` |
| `ctpj-blaze-rdfazenda-dto` | `2.0.5-SNAPSHOT` |
| `ctpj-blaze-rc-dto` | `1.0.9-SNAPSHOT` |
| `ctpj-blaze-dto` | `3.8.1-SNAPSHOT` |
| `ctpj-blaze-calculo-escritural-dto` | `0.0.10-SNAPSHOT` |
| `ctpj-blaze-agrosafra-dto` | `1.0.11-SNAPSHOT` |
| `ctpj-agro-safra-dto` | `2.1.2-SNAPSHOT` |
| `cliente-dto` | `4.0.1-SNAPSHOT` |
| `custom-openam-starter` | `0.0.12-SNAPSHOT.JAVA17` (Java 17), `0.0.12-SNAPSHOT.JAVA11` (Java 11) ou `0.1.1-SNAPSHOT` (Java 1.8) |

**Procedimento obrigatório:**

1. **Ler o arquivo `pom.xml`** na raiz do projeto.
2. **Verificar a versão do Java no `pom.xml`:**
   - Buscar a propriedade `maven.compiler.source` ou `java.version` ou a tag `<maven.compiler.source>` ou `<java.version>`.
   - Identificar se o projeto usa **Java 17** ou **Java 1.8**.
   - **Se não conseguir identificar a versão do Java:** Verificar a propriedade `java.version` no `pom.xml` ou em arquivos de propriedades do projeto.
3. **Para cada biblioteca da tabela acima:**
   - Buscar a dependência no `pom.xml` pelo `artifactId`.
   - **Se a dependência existir:**
     - **Para `custom-openam-starter` (caso especial):**
       - **Se o projeto usar Java 17:** Verificar se a versão é `0.0.12-SNAPSHOT.JAVA17`. Se estiver incorreta, atualizar.
       - **Se o projeto usar Java 11:** Verificar se a versão é `0.0.12-SNAPSHOT.JAVA11`. Se estiver incorreta, atualizar.
       - **Se o projeto usar Java 1.8:** Verificar se a versão é `0.1.1-SNAPSHOT`. Se estiver incorreta, atualizar.
     - **Para as demais dependências:**
       - Verificar se a versão está correta conforme a tabela.
       - **Se a versão estiver incorreta:** Atualizar para a versão obrigatória especificada na tabela.
       - **Se a versão estiver correta:** Não fazer alterações.
   - **Se a dependência não existir:** Não fazer nada (não adicionar a dependência).
4. **Documentar no relatório final (`implementacao.md`):**
   - Listar todas as dependências encontradas e suas versões (antes e depois, se alteradas).
   - Listar dependências que não foram encontradas (para referência).
   - Indicar a versão do Java identificada no projeto.
   - Para `custom-openam-starter`, indicar qual versão foi aplicada baseada na versão do Java.
   - Indicar se houve alterações no `pom.xml` ou não.

**Exemplo de verificação:**

```xml
<!-- Exemplo 1: Dependência comum -->
<!-- Se encontrar no pom.xml: -->
<dependency>
    <groupId>br.com.tokiomarine</groupId>
    <artifactId>ctpj-blaze-dto</artifactId>
    <version>3.7.0-SNAPSHOT</version> <!-- Versão incorreta -->
</dependency>

<!-- Deve ser atualizado para: -->
<dependency>
    <groupId>br.com.tokiomarine</groupId>
    <artifactId>ctpj-blaze-dto</artifactId>
    <version>3.8.1-SNAPSHOT</version> <!-- Versão obrigatória -->
</dependency>

<!-- Exemplo 2: custom-openam-starter com Java 17 -->
<!-- Se encontrar no pom.xml com Java 17: -->
<dependency>
    <groupId>br.com.tokiomarine</groupId>
    <artifactId>custom-openam-starter</artifactId>
    <version>0.0.11-SNAPSHOT</version> <!-- Versão incorreta -->
</dependency>

<!-- Deve ser atualizado para: -->
<dependency>
    <groupId>br.com.tokiomarine</groupId>
    <artifactId>custom-openam-starter</artifactId>
    <version>0.0.12-SNAPSHOT.JAVA17</version> <!-- Versão obrigatória para Java 17 -->
</dependency>

<!-- Exemplo 3: custom-openam-starter com Java 1.8 -->
<!-- Se encontrar no pom.xml com Java 1.8: -->
<dependency>
    <groupId>br.com.tokiomarine</groupId>
    <artifactId>custom-openam-starter</artifactId>
    <version>0.1.0-SNAPSHOT</version> <!-- Versão incorreta -->
</dependency>

<!-- Deve ser atualizado para: -->
<dependency>
    <groupId>br.com.tokiomarine</groupId>
    <artifactId>custom-openam-starter</artifactId>
    <version>0.1.1-SNAPSHOT</version> <!-- Versão obrigatória para Java 1.8 -->
</dependency>
```

**Importante:**
- Esta verificação **não adiciona** dependências que não existem no projeto.
- Esta verificação **apenas atualiza versões** de dependências que já existem.
- Para `custom-openam-starter`, a versão correta **depende da versão do Java** do projeto:
  - **Java 17:** usar versão `0.0.12-SNAPSHOT.JAVA17`
  - **Java 1.8:** usar versão `0.1.1-SNAPSHOT`
- O agente **DEVE** identificar a versão do Java no `pom.xml` antes de atualizar `custom-openam-starter`.
- Se o arquivo `pom.xml` não existir ou não for um projeto Maven, esta etapa deve ser ignorada e documentada no relatório.

**Sobre a dependência `ctpj-corporate-utils`:**

A dependência `ctpj-corporate-utils` **NÃO DEVE ser removida nem substituída**. Ela deve permanecer como está no projeto.

A biblioteca `cnpj-alphanumeric-validator-legacy` deve ser **ADICIONADA** ao projeto **apenas se ainda não existir**, sem remover outras dependências:

```xml
<!-- ADICIONAR esta dependência (se não existir): -->
<dependency>
    <groupId>br.com.tokiomarine.arquitetura</groupId>
    <artifactId>cnpj-alphanumeric-validator-legacy</artifactId>
    <version>1.0.0</version>
</dependency>
```

**Procedimento:**
1. Verificar se a dependência `cnpj-alphanumeric-validator-legacy` já existe no `pom.xml`
2. Se **não existir**, adicionar a dependência conforme exemplo acima
3. **NÃO remover** a dependência `ctpj-corporate-utils` (mantê-la intacta)
4. Documentar a adição no relatório final

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

**ANTES DE FINALIZAR, O AGENTE DEVE:**

0. **Validar checklist completo:** Comparar todos os componentes encontrados com o checklist da Seção 4.5
   - Para cada categoria (4.5.1 a 4.5.9), verificar se todos os componentes foram encontrados
   - Se algum componente não foi encontrado, realizar buscas adicionais usando os padrões específicos
   - **OBRIGATÓRIO:** Realizar busca abrangente por pacotes completos usando padrões como `package.*service`, `package.*mapper`, `package.*dto`, `package.*externo`, `package.*handler`
   - **OBRIGATÓRIO:** Buscar todas as classes anotadas com `@Service`, `@Mapper`, `@Component` e verificar uso de CNPJ/CPF
   - **OBRIGATÓRIO:** Gerar ou atualizar o arquivo `.cnpj_alfanumerico/documentos/componentes-pendentes.md` com o resultado da validação

1. **Validar completude:** Verificar se todas as 10 fases da Seção 4.3 foram executadas e validadas.  
2. **Revisar todos os arquivos alterados** em cada categoria:
   - Entidades e DTOs (Fase 1)
   - Conversões removidas (Fase 2)
   - Utilitários atualizados (Fase 3)
   - Mappers corrigidos (Fase 4)
   - Serviços e repositórios (Fase 5)
   - Contratos de API (Fase 6)
   - Controllers (Fase 7)
   - Integrações externas (Fase 8)
   - Serviços de print (Fase 9)
   - Validação cruzada (Fase 10)
3. **Verificar atualização do pom.xml:** Confirmar que as dependências listadas na Seção 5.4 foram verificadas e atualizadas (se existirem no arquivo).  
4. **Verificar e corrigir imports de @Length (OBRIGATÓRIO):** 
   - **OBRIGATÓRIO:** Realizar busca recursiva final por `@Length` em TODOS os arquivos .java do projeto
   - Usar grep/ripgrep para buscar literalmente `@Length` em todos os diretórios e subdiretórios, sem exceções
   - Listar TODOS os arquivos .java que contêm `@Length`, independente do pacote ou diretório
   - Para cada arquivo encontrado:
     - Ler o arquivo completo
     - Verificar se possui import correto: `import org.hibernate.validator.constraints.Length;`
     - Verificar se há imports incorretos (javax.validation, jakarta.validation, ou outros)
     - Se encontrar imports incorretos ou ausentes, corrigir automaticamente
     - Verificar se `@Length` está sendo usado em campos CNPJ/CPF
     - Se estiver em campo CNPJ/CPF, garantir que max = 14 (ou conforme necessário para o campo)
   - Gerar lista completa e definitiva de TODOS os arquivos com `@Length`:
     - Caminho completo do arquivo
     - Status do import (correto/corrigido/ausente)
     - Se está em campo CNPJ/CPF
     - Ação realizada (nenhuma/corrigido import/ajustado max)
   - Comparar com as listas geradas nas Fases 3.1 e 10 para garantir completude
   - Se encontrar arquivos não identificados anteriormente, corrigir e atualizar documentação
   - **Documentar no relatório final (`implementacao.md`):**
     - Lista completa de TODOS os arquivos onde `@Length` foi encontrado
     - Para cada arquivo: status do import, correções realizadas, campos CNPJ/CPF afetados
     - Total de arquivos verificados
     - Total de arquivos corrigidos
5. **Executar linters e formatadores automáticos** em todos os arquivos modificados.  
6. **Revisar potenciais regressões** em validações e contratos.  
7. **Verificar componentes pendentes** documentados em `.cnpj_alfanumerico/documentos/componentes-pendentes.md`.
   - **Se o arquivo existir e contiver componentes pendentes:** Realizar buscas adicionais e tentar identificar os componentes faltantes
   - **Se componentes ainda não forem encontrados:** Documentar razão e ação recomendada no arquivo de pendências  
8. **Rodar a suíte de testes completa**.  
9. **Garantir conformidade** com as regras de compatibilidade e retrocompatibilidade.  
10. **Validar que nenhum componente crítico foi perdido** comparando com a lista de componentes conhecidos da Seção 4.5.
   - **OBRIGATÓRIO:** Verificar cada categoria do checklist (4.5.1 a 4.5.9)
   - **OBRIGATÓRIO:** Realizar busca final por todos os arquivos Java que contenham campos `Long` ou `BigInteger` relacionados a CNPJ/CPF usando grep/ripgrep
   - **OBRIGATÓRIO:** Verificar arquivos em subpacotes que podem não ter sido cobertos pelas buscas iniciais (ex: `handler.*`, `impl.*`, `backoffice.*`, `reaproveitamento.*`)
   - **OBRIGATÓRIO:** Se algum componente crítico não foi encontrado, documentar em `componentes-pendentes.md` e realizar buscas adicionais  

---

## 9) Critérios de Aceite

- ✅ **Completude:** Todas as 10 fases da Seção 4.3 foram executadas e validadas.  
- ✅ **Campos:** Todos os campos de CNPJ e CPF aceitam **A–Z e 0–9** nos 12 primeiros caracteres e **apenas dígitos** nos 2 últimos.  
- ✅ **Conversões:** Nenhum código tenta converter esses valores para numérico (Long.valueOf, Long.parseLong, BigInteger.valueOf removidos).  
- ✅ **Utilitários:** Todos os utilitários de validação e formatação foram atualizados para suportar alfanumérico.  
- ✅ **Mappers:** Todos os mappers foram atualizados para trabalhar com String.  
- ✅ **Serviços:** Todos os serviços foram atualizados para remover conversões perigosas.  
- ✅ **Contratos:** Contratos de API (OpenAPI/Swagger) foram ajustados para type: string.  
- ✅ **Integrações:** Integrações externas foram verificadas e ajustadas quando possível.  
- ✅ **Print Services:** Serviços de print foram atualizados para formatar CNPJ alfanumérico corretamente.  
- ✅ **Documentação:** O relatório final contém o **inventário completo** de todas as 10 fases e análise de testes.  
- ✅ **Componentes Pendentes:** Componentes que não puderam ser alterados foram documentados em `componentes-pendentes.md`.  
- ✅ **Banco de Dados:** Nenhum trecho de código afeta banco de dados ou migrations.
- ✅ **Checklist Validado:** Todos os componentes da Seção 4.5 (incluindo 4.5.1 a 4.5.9) foram verificados e encontrados, ou documentados como pendentes.
- ✅ **Arquivo de Pendências:** O arquivo `.cnpj_alfanumerico/documentos/componentes-pendentes.md` foi **SEMPRE gerado** (mesmo que vazio ou indicando que todos os componentes foram encontrados) com todas as informações necessárias sobre a validação do checklist.
- ✅ **Dependências pom.xml:** O arquivo `pom.xml` foi verificado e todas as dependências listadas na Seção 5.4 que existem no arquivo foram atualizadas para as versões obrigatórias. A versão do Java foi identificada e, para `custom-openam-starter`, a versão correta foi aplicada baseada na versão do Java (Java 17: `0.0.12-SNAPSHOT.JAVA17`, Java 11: `0.0.12-SNAPSHOT.JAVA11`, Java 1.8: `0.1.1-SNAPSHOT`). Dependências que não existem no arquivo não foram adicionadas.
- ✅ **Anotação @Length:** Todos os usos de `@Length` no projeto foram verificados e garantem o import correto: `import org.hibernate.validator.constraints.Length;`. Todos os imports incorretos ou ausentes foram corrigidos e documentados no relatório final.  

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

A arquitetura de sistemas da Tokio definiu a biblioteca `cnpj-alphanumeric-validator-legacy` com a classe `DocumentValidator` e método `isValidCPForCNPJ()` para a validação de CNPJ/CPF alfanumérico.

### Importar a Biblioteca

Para incluir a biblioteca na aplicação, adicione a seguinte dependência no `pom.xml`:

```xml
<dependency>
    <groupId>br.com.tokiomarine.arquitetura</groupId>
    <artifactId>cnpj-alphanumeric-validator-legacy</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Importar a Classe

Para usar o validador, importe a classe:

```java
import br.com.tokiomarine.arquitetura.cnpjalphanumeric.core.DocumentValidator;
```

### Fazer a Chamada do Método

Para validação do CNPJ/CPF alfanumérico, utilize:

```java
DocumentValidator.isValidCPForCNPJ(cnpjAlfanumerico)
```

## Fluxo de Decisão

```mermaid
flowchart TD
    A[Necessidade de Validação de CNPJ] --> B{Validação Necessária?}
    B -->|Não| C[Não incluir classe utilitária]
    B -->|Sim| D{Validação simples de 14 posições?}
    D -->|Sim| E[Usar DocumentValidator.isValidCPForCNPJ()]
    D -->|Não| F{Validações específicas necessárias?}
    F -->|Sim| G[Usar CnpjAlfaNumericoUtils.java]
    F -->|Não| H[Usar CnpjValidoEnum.java para testes]
```

## Exemplos de Uso

### Validação Simples (Recomendada)
```java
// Para validação básica de CNPJ/CPF alfanumérico
import br.com.tokiomarine.arquitetura.cnpjalphanumeric.core.DocumentValidator;

boolean isValid = DocumentValidator.isValidCPForCNPJ("5IFC7KIZPIQX16");
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
