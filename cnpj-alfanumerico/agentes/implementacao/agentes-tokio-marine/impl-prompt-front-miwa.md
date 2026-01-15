# Prompt de Implementação — CNPJ Alfanumérico (Versão Frontend)

Você é um **engenheiro de software frontend** atuando como **Engenheiro de Prompts para o Cursor**, responsável por ajustar aplicações **Web (Angular, React, Vue, etc.)** para suportar o **CNPJ alfanumérico** conforme IN RFB nº 2.119/2022 e IN RFB nº 2.229/2024.  

Seu objetivo é **analisar, atualizar e validar** todos os componentes, formulários, diretivas e utilitários que lidam com **máscaras, validação e exibição de CNPJ/CPF**, garantindo **retrocompatibilidade total**.  

Ao final, gere um **relatório técnico detalhado** (inventário completo) e salve em:
```
.cnpj_alfanumerico/documentos/implementacao.md
```

---

## 1) Contexto técnico e normativo

- **Comprimento fixo:** 14 caracteres.  
- **Estrutura:** 12 primeiros **alfanuméricos** (A–Z, 0–9) + 2 últimos **numéricos** (dígitos verificadores).  
- **Regex sem máscara:** `^[A-Z0-9]{12}\d{2}$`  
- **Regex com máscara:** `^[A-Z0-9]{2}\.[A-Z0-9]{3}\.[A-Z0-9]{3}/[A-Z0-9]{4}-\d{2}$`  
- **Máscara visual (frontend):** `XX.XXX.XXX/XXXX-##`  
  - `X` → alfanumérico (A–Z, 0–9)  
  - `#` → numérico (0–9)  
- **Retrocompatibilidade:** permitir também o CNPJ 100% numérico (`##.###.###/####-##`).  
- **Campos impactados:** formulários, componentes, máscaras, validações, pipes, form controls, e testes e2e/unitários.

---

## 2) Missão do agente (Frontend)

1. **Inventariar** todos os pontos do projeto onde há referência a CNPJ ou CPF (inputs, diretivas, validações, máscaras, regex, serviços, DTOs e testes).  
2. **Verificar se existe biblioteca de componentes UI** (ex: `t-input`, `t-card`, `t-gridrow`, etc.) no `package.json`:
   - Se existir, **preservar e manter** todos os componentes UI existentes (`t-input`, `t-card`, `t-gridrow`, etc.) no código.
   - Se não existir, **não adicionar** esses componentes e manter as classes HTML originais como estão.
3. **Instalar ou atualizar a biblioteca `ctpj-vue-components` para a versão 1.0.4** no projeto.  
4. **Verificar se a biblioteca `ctpj-vue-components` (versão 1.0.4) já suporta CNPJ alfanumérico**:
   - Se sim, atualizar o projeto para usar o utilitário de validação da biblioteca (`isValidCpfCnpj` do módulo `ctpj-vue-components/utils`).  
   - Se não, notificar que a biblioteca precisa ser atualizada primeiro para suportar CNPJ alfanumérico.  
5. **Verificar se existem componentes visuais da biblioteca `ctpj-vue-components` sendo utilizados** no projeto:
   - Se encontrar componentes visuais sendo utilizados, adicionar o import de `ctpj-vue-components` no `main.js` (se necessário para registro global dos componentes).
   - Se não encontrar componentes visuais sendo utilizados, **não adicionar** o import de `ctpj-vue-components` no `main.js`.
   - O utilitário `isValidCpfCnpj` deve ser importado diretamente nos componentes que precisarem, independentemente de haver import no `main.js`.  
6. **OBRIGATÓRIO: Atualizar máscaras dos inputs HTML existentes** para suportar CNPJ/CPF alfanuméricos:
   - CNPJ: alterar obrigatoriamente de `'##.###.###/####-##'` ou `'SS.SSS.SSS/SSSS-NN'` para `'XX.XXX.XXX/XXXX-##'`
   - CPF: alterar obrigatoriamente de `'###.###.###-##'` para `'XXX.XXX.XXX-XX'`
   - Manter os inputs originais do HTML (incluindo componentes `t-input` se existirem).  
7. **Substituir todas as validações inline** por chamadas ao utilitário `isValidCpfCnpj` da biblioteca (`ctpj-vue-components/utils`).  
8. **Remover utilitários locais de validação** de CNPJ/CPF, utilizando exclusivamente a biblioteca externa.  
9. **Atualizar testes unitários e e2e** com exemplos de ambos formatos (numérico e alfanumérico).  
10. **Gerar relatório técnico** com inventário das alterações, versão da biblioteca utilizada e pontos de integração.

---

## 3) Biblioteca de validação externa

O projeto deve utilizar a biblioteca externa **`ctpj-vue-components`** para validações de CNPJ/CPF. Os inputs HTML originais devem ser mantidos, apenas atualizando suas máscaras e validações.

### Utilitários disponíveis na biblioteca:
- **`isValidCpfCnpj`**: Função de validação exportada via `ctpj-vue-components/utils`

### Nota sobre CNPJ alfanumérico:
A máscara para CNPJ alfanumérico deve ser `'XX.XXX.XXX/XXXX-##'` onde:
- `X` → alfanumérico (A–Z, 0–9)
- `#` → numérico (0–9)

**Importante**: 
- **Os inputs HTML originais devem ser preservados** - apenas as máscaras e validações serão atualizadas.
- Como estamos usando principalmente o utilitário de validação (`isValidCpfCnpj`), importar `isValidCpfCnpj` diretamente nos componentes que precisarem.
- **Importar `ctpj-vue-components` no `main.js` somente quando necessário e tiver algum componente que o use** - verificar se existem componentes visuais da biblioteca `ctpj-vue-components` sendo utilizados no projeto (buscar por imports ou uso de componentes da biblioteca):
  - Se encontrar componentes visuais da biblioteca sendo utilizados, adicionar o import de `ctpj-vue-components` no `main.js` (se necessário para registro global dos componentes).
  - Se não encontrar componentes visuais sendo utilizados, **não adicionar** o import de `ctpj-vue-components` no `main.js`.
  - O utilitário `isValidCpfCnpj` deve ser importado diretamente nos componentes que precisarem, independentemente de haver import no `main.js`.
- Se a biblioteca `ctpj-vue-components` ainda não suporta CNPJ alfanumérico, será necessário atualizar a biblioteca primeiro antes de aplicar as mudanças no projeto. O agente deve verificar isso e informar no relatório.

---

## 4) Passos de implementação

### 4.1 Configuração inicial e análise
- Verificar se existe `package.json` no projeto.
- **Verificar se existe biblioteca de componentes UI** no `package.json` (buscar por dependências que possam fornecer componentes como `t-input`, `t-card`, `t-gridrow`, `t-gridcol`, `t-button`, etc.):
  - Se existir, identificar qual biblioteca fornece esses componentes (ex: `tokiomarine-ui`, `tm-ui-components`, etc.).
  - Se existir, **preservar todos os componentes UI** (`t-input`, `t-card`, `t-gridrow`, etc.) existentes no código.
  - Se não existir, **não adicionar** esses componentes e manter as classes HTML originais como estão.
- **Instalar ou atualizar a biblioteca `ctpj-vue-components` para a versão 1.0.4** no projeto.
- Verificar se a biblioteca `ctpj-vue-components` versão 1.0.4 está instalada no `package.json`.
- Verificar se a biblioteca versão 1.0.4 já suporta CNPJ alfanumérico (consultar documentação ou código fonte).
- **Verificar e remover imports não utilizados da biblioteca `ctpj-vue-components`**:
  - Buscar por `import CtpjVueComponents from 'ctpj-vue-components'` e remover se não estiver sendo utilizado.
  - Buscar por `import 'ctpj-vue-components/style.css'` e remover se não estiver sendo utilizado.
  - Como estamos usando principalmente o utilitário `isValidCpfCnpj`, esses imports não são necessários na maioria dos casos.
- **Verificar se existem componentes visuais da biblioteca `ctpj-vue-components` sendo utilizados** no projeto (buscar por imports ou uso de componentes da biblioteca):
  - Se encontrar componentes visuais da biblioteca sendo utilizados, adicionar o import de `ctpj-vue-components` no `main.js` (se necessário para registro global dos componentes).
  - Se não encontrar componentes visuais sendo utilizados, **não adicionar** o import de `ctpj-vue-components` no `main.js`.
  - O utilitário `isValidCpfCnpj` deve ser importado diretamente nos componentes que precisarem, independentemente de haver import no `main.js`.
- **Inventariar todos os pontos** onde há inputs, validações ou utilitários locais de CNPJ/CPF.

### 4.2 Atualização de máscaras nos inputs existentes
- **OBRIGATÓRIO: Atualizar máscaras dos inputs HTML existentes** para suportar CNPJ/CPF alfanuméricos, mantendo os inputs originais:
  - **Para CNPJ**: alterar máscara de `'##.###.###/####-##'` ou `'SS.SSS.SSS/SSSS-NN'` para `'XX.XXX.XXX/XXXX-##'` (obrigatório)
  - **Para CPF**: alterar máscara de `'###.###.###-##'` para `'XXX.XXX.XXX-XX'` (obrigatório)
  - Preservar todos os atributos e estrutura dos inputs originais
  - **Se existirem componentes `t-input`** (ou outros componentes UI), preservá-los e apenas atualizar a máscara
  - **Se não existirem componentes UI**, manter os inputs HTML originais com suas classes CSS
  - **Todas as máscaras antigas devem ser substituídas obrigatoriamente pelas novas máscaras**
- **Exemplo de atualização de máscara CNPJ com input HTML**:
  ```vue
  <!-- ANTES (máscaras antigas - OBRIGATÓRIO substituir) -->
  <input v-model="cnpj" :mask="'##.###.###/####-##'" />
  <!-- ou -->
  <input v-model="cnpj" :mask="'SS.SSS.SSS/SSSS-NN'" />
  
  <!-- DEPOIS (máscara nova obrigatória) -->
  <input v-model="cnpj" :mask="'XX.XXX.XXX/XXXX-##'" />
  ```
- **Exemplo de atualização de máscara CPF com input HTML**:
  ```vue
  <!-- ANTES (máscara antiga - OBRIGATÓRIO substituir) -->
  <input v-model="cpf" :mask="'###.###.###-##'" />
  
  <!-- DEPOIS (máscara nova obrigatória) -->
  <input v-model="cpf" :mask="'XXX.XXX.XXX-XX'" />
  ```
- **Exemplo de atualização de máscara CNPJ com componente t-input** (se a biblioteca UI existir):
  ```vue
  <!-- ANTES (máscaras antigas - OBRIGATÓRIO substituir) -->
  <t-input v-model="cnpj" :mask="'##.###.###/####-##'" />
  <!-- ou -->
  <t-input v-model="cnpj" :mask="'SS.SSS.SSS/SSSS-NN'" />
  
  <!-- DEPOIS (máscara nova obrigatória) -->
  <t-input v-model="cnpj" :mask="'XX.XXX.XXX/XXXX-##'" />
  ```
- **Exemplo de atualização de máscara CPF com componente t-input** (se a biblioteca UI existir):
  ```vue
  <!-- ANTES (máscara antiga - OBRIGATÓRIO substituir) -->
  <t-input v-model="cpf" :mask="'###.###.###-##'" />
  
  <!-- DEPOIS (máscara nova obrigatória) -->
  <t-input v-model="cpf" :mask="'XXX.XXX.XXX-XX'" />
  ```
- **Manter retrocompatibilidade**: A máscara `'XX.XXX.XXX/XXXX-##'` aceita tanto números quanto letras nos 12 primeiros caracteres, mantendo compatibilidade com CNPJs numéricos existentes.

### 4.3 Substituição de validações por utilitário da biblioteca
- **Substituir todas as validações inline** por chamadas ao utilitário `isValidCpfCnpj` da biblioteca:
  ```javascript
  // ANTES (validação local)
  import { isValidCpfCnpj } from '@/utils/cpfCnpjUtils';
  
  // DEPOIS (utilitário da biblioteca)
  import { isValidCpfCnpj } from 'ctpj-vue-components/utils';
  ```
- **Remover utilitários locais** de validação de CNPJ/CPF:
  - Deletar arquivos como `src/utils/cpfCnpjUtils.js` (se existirem)
  - Remover funções de validação inline de componentes
  - Substituir por importações da biblioteca externa
- **Exemplo de validação com utilitário da biblioteca**:
  ```javascript
  // Vue
  import { isValidCpfCnpj } from 'ctpj-vue-components/utils';
  
  const validateCnpj = (value) => {
    if (!value) return true;
    return isValidCpfCnpj(value);
  };

  // Com Yup/Zod
  import { isValidCpfCnpj } from 'ctpj-vue-components/utils';
  
  Yup.string().test('cnpj', 'CNPJ inválido', (value) => {
    return !value || isValidCpfCnpj(value);
  });
  ```

### 4.4 Verificação de suporte a CNPJ alfanumérico
- **Verificar se a biblioteca `ctpj-vue-components` versão 1.0.4 já suporta CNPJ alfanumérico**:
  - Se sim, a função `isValidCpfCnpj` deve validar CNPJs alfanuméricos corretamente
  - Se não, documentar no relatório que a biblioteca precisa ser atualizada primeiro
- **Atualizar máscaras nos inputs**:
  - A máscara do CNPJ deve ser `'XX.XXX.XXX/XXXX-##'` (suportado por bibliotecas como `maska`, `vue-the-mask`, etc.)
  - A função `isValidCpfCnpj` da biblioteca versão 1.0.4 deve validar CNPJs alfanuméricos
- **Nota**: Esta etapa pode requerer atualização da biblioteca `ctpj-vue-components` versão 1.0.4 antes de prosseguir, mas os inputs HTML originais devem ser mantidos.

### 4.5 Atualização dos testes
- **Atualizar testes unitários** dos componentes que utilizam validação:
  - Testar com `isValidCpfCnpj` da biblioteca `ctpj-vue-components/utils`
  - Inserir exemplos de CNPJs numéricos e alfanuméricos
  - Validar que os inputs HTML aceitam letras nos 12 primeiros caracteres através da máscara atualizada
  - Verificar que todas as validações passam pelo utilitário da biblioteca externa
- **Atualizar testes e2e**:
  - Testar digitação de CNPJs alfanuméricos nos inputs HTML existentes
  - Validar formatação automática da máscara `'XX.XXX.XXX/XXXX-##'`
  - Verificar submissão de dados com CNPJs alfanuméricos

### 4.6 Ajustes complementares
- Atualizar `README.md`, tooltips e mensagens de erro dos formulários.
- **Remover dependências locais** de validação de CNPJ/CPF.
- **Documentar o uso da biblioteca `ctpj-vue-components` para validações** em comentários de código e README.
- Verificar se há imports de utilitários locais que devem ser substituídos pela biblioteca externa.
- **Remover imports não utilizados da biblioteca `ctpj-vue-components`**:
  - Remover `import CtpjVueComponents from 'ctpj-vue-components'` se existir e não estiver sendo utilizado.
  - Remover `import 'ctpj-vue-components/style.css'` se existir e não estiver sendo utilizado.
  - Como estamos usando principalmente o utilitário `isValidCpfCnpj`, esses imports não são necessários na maioria dos casos.
- **Importar `ctpj-vue-components` no `main.js` somente quando necessário e tiver algum componente que o use** — verificar se existem componentes visuais da biblioteca `ctpj-vue-components` sendo utilizados no projeto (buscar por imports ou uso de componentes da biblioteca):
  - Se encontrar componentes visuais da biblioteca sendo utilizados, adicionar o import de `ctpj-vue-components` no `main.js` (se necessário para registro global dos componentes).
  - Se não encontrar componentes visuais sendo utilizados, **não adicionar** o import de `ctpj-vue-components` no `main.js`.
  - O utilitário `isValidCpfCnpj` deve ser importado diretamente nos componentes que precisarem, independentemente de haver import no `main.js`.
- **Importar `@Length` do Hibernate Validator apenas quando necessário** — se o projeto utilizar a anotação `@Length` do Hibernate Validator (geralmente em DTOs ou classes de validação backend), adicionar o import apenas nos arquivos onde a anotação for utilizada:
  ```java
  // Adicionar este import APENAS quando usar a anotação @Length
  import org.hibernate.validator.constraints.Length;
  
  // Exemplo de uso:
  @Length(min = 14, max = 14, message = "CNPJ deve ter 14 caracteres")
  private String cnpj;
  ```
  - **Não adicionar o import** se a anotação `@Length` não estiver sendo utilizada no arquivo.
- **Preservar estrutura HTML original** - apenas máscaras e validações são atualizadas.
- **Preservar componentes UI existentes** (`t-input`, `t-card`, `t-gridrow`, etc.) se a biblioteca UI estiver instalada, ou manter classes HTML originais se não estiver.

---

## 5) Estrutura do relatório (`implementacao.md`)

O relatório gerado deve conter:

1. **Resumo técnico do projeto**: framework (Angular, React, Vue), versão e bibliotecas detectadas.  
2. **Biblioteca de componentes UI**: verificar e documentar se existe biblioteca de componentes UI no projeto (ex: `t-input`, `t-card`, `t-gridrow`, etc.):
   - Se existir: documentar qual biblioteca e versão, e confirmar que os componentes UI foram preservados.
   - Se não existir: documentar que não foi encontrada e que as classes HTML originais foram mantidas.
3. **Biblioteca externa utilizada**: versão 1.0.4 de `ctpj-vue-components` instalada e se suporta CNPJ alfanumérico.  
4. **Inputs atualizados**: lista de inputs HTML ou componentes UI (`t-input`, etc.) que tiveram suas máscaras atualizadas para suportar CNPJ alfanumérico.  
5. **Utilitários substituídos**: lista de utilitários locais removidos e substituídos por `isValidCpfCnpj` de `ctpj-vue-components/utils`.  
6. **Máscaras utilizadas**: documentar as máscaras configuradas nos inputs:
   - CNPJ: `'XX.XXX.XXX/XXXX-##'` (obrigatória, substituindo `'##.###.###/####-##'` ou `'SS.SSS.SSS/SSSS-NN'`)
   - CPF: `'XXX.XXX.XXX-XX'` (obrigatória, substituindo `'###.###.###-##'`)  
7. **Pontos de integração**: lista de componentes/formulários que foram atualizados para utilizar validações da biblioteca externa.  
8. **Arquivos alterados** (lista detalhada): arquivos modificados e arquivos deletados (utilitários locais removidos).  
9. **Referências da biblioteca**: link para documentação ou repositório da `ctpj-vue-components`.  
10. **Casos de teste criados/ajustados**: testes atualizados para usar validações da biblioteca externa.  
11. **Notas sobre CNPJ alfanumérico**: se a biblioteca precisa ser atualizada para suportar CNPJ alfanumérico, documentar isso claramente.  
12. **Screenshots ou descrições** de formulários testados (quando aplicável).  

---

## 6) Regras complementares

- **Verificar biblioteca de componentes UI** — antes de fazer alterações, verificar se existe biblioteca de componentes UI no `package.json` (componentes como `t-input`, `t-card`, `t-gridrow`, etc.):
  - **Se existir**: preservar e manter todos os componentes UI existentes (`t-input`, `t-card`, `t-gridrow`, `t-gridcol`, `t-button`, etc.) no código.
  - **Se não existir**: não adicionar esses componentes e manter as classes HTML originais como estão.
- **Utilizar obrigatoriamente a biblioteca externa `ctpj-vue-components` para validações** — todas as validações de CNPJ/CPF devem usar `isValidCpfCnpj` de `ctpj-vue-components/utils`.  
- **Remover imports não utilizados da biblioteca** — remover `import CtpjVueComponents from 'ctpj-vue-components'` e `import 'ctpj-vue-components/style.css'` se existirem e não estiverem sendo utilizados, pois não estamos utilizando os componentes visuais da biblioteca na maioria dos casos, apenas o utilitário de validação.
- **Importar `ctpj-vue-components` no `main.js` somente quando necessário e tiver algum componente que o use** — verificar se existem componentes visuais da biblioteca `ctpj-vue-components` sendo utilizados no projeto:
  - Se encontrar componentes visuais da biblioteca sendo utilizados, adicionar o import de `ctpj-vue-components` no `main.js` (se necessário para registro global dos componentes).
  - Se não encontrar componentes visuais sendo utilizados, **não adicionar** o import de `ctpj-vue-components` no `main.js`.
  - O utilitário `isValidCpfCnpj` deve ser importado diretamente nos componentes que precisarem, independentemente de haver import no `main.js`.
- **Importar `@Length` apenas quando necessário** — adicionar `import org.hibernate.validator.constraints.Length;` apenas nos arquivos Java onde a anotação `@Length` for utilizada. Não adicionar o import se a anotação não estiver sendo usada.
- **Preservar inputs HTML originais e componentes UI** — não substituir inputs HTML ou componentes UI existentes por componentes da biblioteca `ctpj-vue-components`, apenas atualizar máscaras e validações.  
- **Não criar utilitários locais** — remover qualquer utilitário local de validação de CNPJ/CPF e usar `isValidCpfCnpj` de `ctpj-vue-components/utils`.  
- **OBRIGATÓRIO: Atualizar máscaras dos inputs existentes** — alterar obrigatoriamente:
  - Máscaras de CNPJ: de `'##.###.###/####-##'` ou `'SS.SSS.SSS/SSSS-NN'` para `'XX.XXX.XXX/XXXX-##'`
  - Máscaras de CPF: de `'###.###.###-##'` para `'XXX.XXX.XXX-XX'`
  - Aplicar nos inputs HTML originais ou componentes UI existentes.  
- **Preservar retrocompatibilidade** com CNPJs numéricos (a máscara `'XX.XXX.XXX/XXXX-##'` aceita números e letras).  
- **Não modificar APIs externas** — apenas camada de exibição e input.  
- **Não incluir alterações em banco de dados ou backend** neste escopo.  
- **Remover código duplicado** — deletar utilitários locais de validação que foram substituídos pela biblioteca.  
- **Usar regex case-insensitive (`/i`)** para garantir compatibilidade (a biblioteca deve implementar isso).  
- **Todos os commits devem refletir claramente as mudanças** — atualização de máscaras e substituição de validações locais por biblioteca externa.  
- **Centralizar toda lógica de validação** na biblioteca externa — não permitir validações inline ou utilitários locais duplicados.

---

## 7) Code Review final

1. **Revisar todas as alterações de input masks e validações.**  
2. **Comparar comportamento anterior e novo (numérico x alfanumérico).**  
3. **Executar os testes unitários e e2e completos.**  
4. **Verificar a documentação e comentários de código.**  
5. **Confirmar que a máscara visual está conforme o padrão oficial.**  
6. **Anexar evidências no relatório (`implementacao.md`).**

---

## 8) Critérios de aceite

- Foi verificado se existe biblioteca de componentes UI no projeto (`t-input`, `t-card`, `t-gridrow`, etc.):
  - Se existir, os componentes UI foram preservados e mantidos no código.
  - Se não existir, as classes HTML originais foram mantidas (nenhum componente UI foi adicionado).
- A biblioteca `ctpj-vue-components` versão 1.0.4 está instalada e sendo utilizada para validações no projeto.
- Foi verificado se existem componentes visuais da biblioteca `ctpj-vue-components` sendo utilizados no projeto:
  - Se encontrados componentes visuais sendo utilizados, o import de `ctpj-vue-components` foi adicionado no `main.js` (se necessário para registro global dos componentes).
  - Se não encontrados componentes visuais sendo utilizados, o import de `ctpj-vue-components` **não foi adicionado** no `main.js`.
- Imports não utilizados da biblioteca foram removidos (`import CtpjVueComponents from 'ctpj-vue-components'` e `import 'ctpj-vue-components/style.css'`), mantendo apenas os imports do utilitário `isValidCpfCnpj` nos componentes que precisam.
- O import `import org.hibernate.validator.constraints.Length;` foi adicionado apenas nos arquivos Java onde a anotação `@Length` é utilizada.
- Todos os inputs HTML ou componentes UI de CNPJ tiveram suas máscaras atualizadas obrigatoriamente para `'XX.XXX.XXX/XXXX-##'` (substituindo `'##.###.###/####-##'` ou `'SS.SSS.SSS/SSSS-NN'`).
- Todos os inputs HTML ou componentes UI de CPF tiveram suas máscaras atualizadas obrigatoriamente para `'XXX.XXX.XXX-XX'` (substituindo `'###.###.###-##'`).
- Os inputs originais ou componentes UI existentes foram preservados (apenas máscaras foram atualizadas).  
- Todas as validações utilizam o utilitário `isValidCpfCnpj` de `ctpj-vue-components/utils`.  
- Utilitários locais de validação de CNPJ/CPF foram removidos do projeto.  
- A biblioteca `ctpj-vue-components` versão 1.0.4 suporta CNPJ alfanumérico (ou foi documentado que precisa ser atualizada).  
- A máscara do CNPJ aceita letras (A–Z) nos 12 primeiros caracteres e números nos 2 últimos.  
- Todas as validações existentes foram refatoradas para utilizar a biblioteca externa, sem alterar funcionalidades.  
- Os inputs HTML originais ou componentes UI existentes foram preservados (apenas máscaras e validações foram atualizadas).  
- Todos os testes passam com CNPJs numéricos e alfanuméricos.  
- O relatório final foi gerado com inventário, versão da biblioteca e pontos de integração.

---

## 9) Exemplo prático (Vue + ctpj-vue-components)

### 9.1 Instalação e configuração
```bash
# Instalar a biblioteca na versão 1.0.4
npm install ctpj-vue-components@1.0.4 --registry http://repo-artifactory.tokiomarine.com.br/artifactory/api/npm/npm-virtual/
```

**Importante**: Como vamos utilizar **principalmente o utilitário de validação** (`isValidCpfCnpj`), **não é necessário** importar os componentes da biblioteca na maioria dos casos. 

**Verificar se existem componentes visuais da biblioteca sendo utilizados**:
- Buscar no projeto por imports ou uso de componentes visuais da biblioteca `ctpj-vue-components`.
- Se encontrar componentes visuais sendo utilizados, adicionar o import de `ctpj-vue-components` no `main.js` (se necessário para registro global dos componentes).
- Se não encontrar componentes visuais sendo utilizados, **não adicionar** o import de `ctpj-vue-components` no `main.js`.

**Remover imports não utilizados** (se existirem no projeto):
```javascript
// REMOVER estes imports se existirem e não estiverem sendo utilizados:
import CtpjVueComponents from 'ctpj-vue-components'
import 'ctpj-vue-components/style.css'
```

**Importar o utilitário diretamente nos componentes** onde for necessário:
```javascript
// Nos componentes Vue que precisam validar CNPJ/CPF
import { isValidCpfCnpj } from 'ctpj-vue-components/utils';
```

**Importar a biblioteca no main.js somente quando necessário**:
```javascript
// main.js
// Importar ctpj-vue-components APENAS se houver componentes visuais da biblioteca sendo utilizados
// Caso contrário, não adicionar o import aqui
// Apenas importar isValidCpfCnpj diretamente nos componentes que precisarem
```

**Nota**: O utilitário `isValidCpfCnpj` deve ser importado diretamente nos componentes que precisarem, independentemente de haver import no `main.js`. O import no `main.js` é necessário apenas se houver componentes visuais da biblioteca sendo utilizados.

### 9.2 Uso no componente Vue
```vue
<template>
  <!-- Exemplo 1: Input HTML original (se não houver biblioteca UI) -->
  <input 
    v-model="cnpj" 
    :mask="'XX.XXX.XXX/XXXX-##'"
    @blur="validateCnpj"
  />
  
  <!-- Exemplo 2: Componente t-input (se biblioteca UI existir) -->
  <!-- <t-input 
    v-model="cnpj" 
    :mask="'XX.XXX.XXX/XXXX-##'"
    @blur="validateCnpj"
  /> -->
  
  <span v-if="cnpjError" class="error">{{ cnpjError }}</span>
</template>

<script setup>
import { ref } from 'vue';
import { isValidCpfCnpj } from 'ctpj-vue-components/utils';

const cnpj = ref('');
const cnpjError = ref('');

const validateCnpj = () => {
  if (!cnpj.value) {
    cnpjError.value = '';
    return;
  }
  
  // Usar utilitário da biblioteca externa para validação
  if (!isValidCpfCnpj(cnpj.value)) {
    cnpjError.value = 'CNPJ inválido';
  } else {
    cnpjError.value = '';
  }
};

const onSubmit = () => {
  // Remover máscara antes de enviar (se necessário)
  const cnpjSemMascara = cnpj.value.replace(/[^A-Z0-9]/gi, '');
  // Enviar cnpjSemMascara para API
};
</script>
```

### 9.3 Exemplo com Yup/Zod
```javascript
import { isValidCpfCnpj } from 'ctpj-vue-components/utils';
import * as Yup from 'yup';

const schema = Yup.object().shape({
  cnpj: Yup.string()
    .test('cnpj', 'CNPJ inválido', (value) => {
      return !value || isValidCpfCnpj(value);
    })
});
```

**Referências:**  
- Biblioteca `ctpj-vue-components` (repositório interno Tokio Marine)
- Utilitário: `ctpj-vue-components/utils` → `isValidCpfCnpj`
- Máscara CNPJ alfanumérico: `'XX.XXX.XXX/XXXX-##'`

---

## 10) Nota sobre outros frameworks

Este prompt foi desenvolvido para projetos **Vue.js** que utilizam a biblioteca `ctpj-vue-components`.

Para projetos em **React** ou **Angular**:
- Verificar se existe uma biblioteca equivalente de componentes que suporte CNPJ alfanumérico
- Se não existir, considerar criar uma biblioteca compartilhada ou adaptar este prompt conforme necessário
- O princípio fundamental permanece: **não criar validações locais**, utilizar biblioteca externa quando disponível

**Importante**: Se o projeto não for Vue.js, adaptar este prompt para usar a biblioteca de componentes apropriada do framework, mantendo o princípio de utilizar biblioteca externa ao invés de criar validações locais.

---

## 11) Conclusão

Este prompt deve ser aplicado **apenas em projetos Frontend Vue.js que utilizam a biblioteca `ctpj-vue-components`**.  
A missão do agente é garantir que **a máscara e validação do CNPJ alfanumérico estejam de acordo com o padrão oficial** utilizando **exclusivamente a biblioteca externa para validações**, mantendo os inputs HTML originais do projeto.

**Princípios fundamentais:**
- **Verificar biblioteca de componentes UI**: Antes de fazer alterações, verificar se existe biblioteca de componentes UI no projeto:
  - Se existir: preservar e manter componentes UI (`t-input`, `t-card`, `t-gridrow`, etc.).
  - Se não existir: manter classes HTML originais (não adicionar componentes UI).
- **Biblioteca externa para validações**: Utilizar obrigatoriamente `ctpj-vue-components/utils` para validações de CNPJ/CPF.
- **Remover imports não utilizados**: Remover `import CtpjVueComponents from 'ctpj-vue-components'` e `import 'ctpj-vue-components/style.css'` se existirem e não estiverem sendo utilizados, pois não estamos utilizando os componentes visuais na maioria dos casos.
- **Importar `ctpj-vue-components` no `main.js` somente quando necessário e tiver algum componente que o use**: Verificar se existem componentes visuais da biblioteca `ctpj-vue-components` sendo utilizados no projeto:
  - Se encontrar componentes visuais sendo utilizados, adicionar o import de `ctpj-vue-components` no `main.js` (se necessário para registro global dos componentes).
  - Se não encontrar componentes visuais sendo utilizados, **não adicionar** o import de `ctpj-vue-components` no `main.js`.
  - O utilitário `isValidCpfCnpj` deve ser importado diretamente nos componentes que precisarem, independentemente de haver import no `main.js`.
- **Importar `@Length` apenas quando necessário**: Adicionar `import org.hibernate.validator.constraints.Length;` apenas nos arquivos Java onde a anotação `@Length` for utilizada. Não adicionar o import se a anotação não estiver sendo usada.
- **Preservar inputs HTML originais e componentes UI**: Não substituir inputs HTML ou componentes UI existentes por componentes da biblioteca `ctpj-vue-components`, apenas atualizar máscaras e validações.
- **Sem duplicação**: Não criar utilitários locais de validação - remover qualquer código duplicado.
- **Atualização obrigatória de máscaras**: Atualizar obrigatoriamente as máscaras dos inputs existentes (HTML ou componentes UI):
  - CNPJ: de `'##.###.###/####-##'` ou `'SS.SSS.SSS/SSSS-NN'` para `'XX.XXX.XXX/XXXX-##'`
  - CPF: de `'###.###.###-##'` para `'XXX.XXX.XXX-XX'`
- **Validação centralizada**: Usar `isValidCpfCnpj` de `ctpj-vue-components/utils` para todas as validações.
- **Preservação**: Não alterar funcionalidades existentes, apenas atualizar máscaras e refatorar validações para utilizar a biblioteca externa.

```diff
+ Verificar se existe biblioteca de componentes UI (t-input, t-card, t-gridrow, etc.)
+ Se existir: preservar componentes UI existentes
+ Se não existir: manter classes HTML originais (não adicionar componentes UI)
+ Verificar instalação da biblioteca ctpj-vue-components
+ Verificar suporte a CNPJ alfanumérico na biblioteca
+ Verificar se existem componentes visuais da biblioteca ctpj-vue-components sendo utilizados
+ Se encontrar componentes visuais: adicionar import de ctpj-vue-components no main.js (se necessário)
+ Se não encontrar componentes visuais: NÃO adicionar import de ctpj-vue-components no main.js
+ Remover imports não utilizados (CtpjVueComponents e style.css) se existirem
+ Adicionar import org.hibernate.validator.constraints.Length apenas quando usar @Length
+ OBRIGATÓRIO: Atualizar máscaras CNPJ de '##.###.###/####-##' ou 'SS.SSS.SSS/SSSS-NN' para 'XX.XXX.XXX/XXXX-##'
+ OBRIGATÓRIO: Atualizar máscaras CPF de '###.###.###-##' para 'XXX.XXX.XXX-XX'
+ Substituir validações locais por isValidCpfCnpj da biblioteca
+ Remover utilitários locais de validação duplicados
+ Preservar inputs HTML originais ou componentes UI (não substituir por componentes da biblioteca)
+ Atualizar testes para usar validações da biblioteca externa
+ Gerar relatório completo com inventário e versão da biblioteca
```
