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
- **Máscara visual (frontend):** `SS.SSS.SSS/SSSS-NN`  
  - `S` → alfanumérico (A–Z, 0–9)  
  - `N` → numérico (0–9)  
- **Retrocompatibilidade:** permitir também o CNPJ 100% numérico (`##.###.###/####-##`).  
- **Campos impactados:** formulários, componentes, máscaras, validações, pipes, form controls, e testes e2e/unitários.

### 1.1) Problema crítico: Digitação manual de letras

**FEEDBACK DO CLIENTE:** "Nos campos de CNPJ não consigo digitar manualmente os caracteres alfanuméricos, somente numéricos."

**PROBLEMA:** O usuário precisa conseguir **digitar letras manualmente** (pressionando teclas A-Z no teclado) nos campos de CNPJ, mas atualmente apenas números são aceitos.

**REQUISITO OBRIGATÓRIO:** 
- O usuário **DEVE conseguir digitar letras (A-Z) manualmente** nos 12 primeiros caracteres do CNPJ.
- As letras **DEVEM aparecer IMEDIATAMENTE** no campo conforme são digitadas.
- As letras **NÃO DEVEM ser bloqueadas, filtradas ou substituídas por zeros/números**.
- A digitação manual de letras **DEVE funcionar em tempo real**, não apenas no paste.

**CAUSAS COMUNS:**
- Máscara configurada apenas para números (`00.000.000/0000-00`).
- Atributo HTML `type="number"` bloqueando letras.
- Handlers de eventos que filtram/bloqueiam letras.
- Biblioteca de máscara que não aceita letras na digitação manual.

**SOLUÇÃO:** Ver seção 4.2 (Ajuste da máscara) e 4.6 (Implementação de handler de digitação manual).

---

## 2) Missão do agente (Frontend)

1. **Inventariar** todos os pontos do projeto onde há referência a CNPJ ou CPF (inputs, diretivas, validações, máscaras, regex, serviços, DTOs e testes).  
2. **Identificar a biblioteca de máscaras** utilizada no projeto (ex.: `ngx-mask`, `react-input-mask`, `cleave.js`, `imask.js`, `vanilla-masker`, etc.).  
3. **Analisar a documentação oficial da biblioteca** para entender como configurar ou estender máscaras personalizadas.  
4. **Ajustar a máscara do CNPJ** para suportar o padrão alfanumérico (`SS.SSS.SSS/SSSS-NN`) conforme o formato da biblioteca.  
5. **PRIORIDADE MÁXIMA: Garantir que a máscara aceite letras na DIGITAÇÃO MANUAL** — o usuário DEVE conseguir digitar letras (A-Z) nos 12 primeiros caracteres do CNPJ em tempo real, sem que sejam bloqueadas, filtradas ou substituídas por zeros/números. **Testar manualmente digitando letras caractere por caractere e verificar que aparecem imediatamente no campo.**  
6. **Atualizar validações** (regex e pipes) garantindo compatibilidade com CNPJs alfanuméricos e numéricos.  
7. **Implementar validação de clipboard/paste** para bloquear colagem de valores inválidos e **preservar letras** em valores válidos (não substituir por zeros).  
8. **CRÍTICO: Testar colagem de CNPJ alfanumérico** — verificar que letras são preservadas (ex.: colar `7O.L55.2C2/2646-00` deve resultar em `7O.L55.2C2/2646-00`, não em `70.055.202/2646-00`).  
9. **Atualizar testes unitários e e2e** com exemplos de ambos formatos, testes de digitação de letras e casos de paste válido/inválido.  
10. **Gerar relatório técnico** com inventário das alterações, bibliotecas envolvidas e links da documentação consultada.

---

## 2.1) Escopo de identificação de campos CNPJ e CPF

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

## 3) Identificação de bibliotecas de máscara

O agente deve **detectar automaticamente** qual biblioteca de máscara está sendo usada no projeto, verificando dependências no `package.json`:

### Exemplos de bibliotecas a considerar:
| Biblioteca | Padrão de Máscara | Documentação |
|-------------|-------------------|---------------|
| **ngx-mask** | `'00.000.000/0000-00'` → alfanumérico: `'SS.SSS.SSS/SSSS-NN'` | https://www.npmjs.com/package/ngx-mask |
| **react-input-mask** | `'99.999.999/9999-99'` → alfanumérico: `'AA.AAA.AAA/AAAA-NN'` | https://github.com/sanniassin/react-input-mask |
| **imask.js** | `{ mask: '00.000.000/0000-00' }` → `{ mask: 'SS.SSS.SSS/SSSS-NN' }` | https://imask.js.org/ |
| **cleave.js** | `blocks: [2,3,3,4,2]` → com regex `[A-Z0-9]` | https://nosir.github.io/cleave.js/ |
| **vanilla-masker** | `'99.999.999/9999-99'` → `'SS.SSS.SSS/SSSS-NN'` | https://github.com/BankFacil/vanilla-masker |

---

## 4) Passos de implementação

### 4.1 Análise inicial
- Ler o arquivo `package.json` e identificar a biblioteca de máscara.
- Acessar a documentação oficial (site, README, ou npm).
- Verificar como definir **máscaras customizadas** e **regex personalizados**.
- Anotar o formato nativo da máscara para CNPJ e ajustá-lo para alfanumérico.

### 4.2 Ajuste da máscara
- **PRIORIDADE MÁXIMA:** Converter o padrão numérico `##.###.###/####-##` para alfanumérico `SS.SSS.SSS/SSSS-NN` respeitando o formato aceito pela biblioteca detectada.  
- **CRÍTICO: Garantir que a máscara permita DIGITAÇÃO MANUAL de letras em tempo real:**
  - **Verificar e remover qualquer filtro que bloqueie letras na digitação:**
    - Verificar que a configuração da máscara não está filtrando caracteres alfabéticos durante a digitação.
    - Verificar que não há handlers de `keydown`, `keypress` ou `input` que bloqueiem letras.
    - Verificar que não há regex ou validação que rejeite letras durante a digitação (apenas na submissão final).
  - **Verificar atributos HTML que bloqueiam letras:**
    - **REMOVER** `type="number"` se existir — usar `type="text"` ou `type="tel"`.
    - **REMOVER** `pattern="[0-9]*"` ou qualquer pattern que restrinja a números.
    - **REMOVER** `inputmode="numeric"` se estiver bloqueando letras.
    - **GARANTIR** que o input aceite qualquer caractere alfanumérico durante a digitação.
  - **Implementar handler de digitação manual (se necessário):**
    - Se a biblioteca de máscara não aceitar letras nativamente, criar handler customizado de `keydown`/`keypress`/`input` que:
      - **PERMITA** letras (A-Z, a-z) nos 12 primeiros caracteres.
      - **PERMITA** números (0-9) em todas as posições.
      - **BLOQUEIE** apenas caracteres especiais inválidos (exceto os da máscara: `.`, `/`, `-`).
      - **CONVERTA** letras minúsculas para maiúsculas automaticamente.
      - **APLIQUE** a máscara preservando as letras digitadas.
  - **Teste manual obrigatório:**
    - Abrir o formulário no navegador.
    - Clicar no campo CNPJ.
    - **Digitar manualmente caractere por caractere:** `7` → `O` → `.` → `L` → `5` → `5` → etc.
    - **VERIFICAR que cada letra aparece IMEDIATAMENTE no campo** conforme é digitada.
    - **VERIFICAR que letras NÃO são substituídas por zeros ou números.**
    - Se letras não aparecerem ou forem substituídas, a implementação está INCORRETA e precisa ser corrigida.
- **Problemas comuns a evitar:**
  - **NÃO usar máscaras numéricas** (`00.000.000/0000-00`, `99.999.999/9999-99`) que filtram letras durante a digitação.
  - **NÃO permitir que a biblioteca substitua letras por zeros** — se isso ocorrer, criar handler customizado que preserve as letras.
  - **NÃO usar `input type="number"`** ou atributos que restrinjam a entrada a números apenas.
  - **NÃO bloquear letras em handlers de eventos** — apenas validar no momento da submissão.
- Caso a biblioteca não aceite caracteres alfabéticos nativamente:
  - Adicionar expressão regular customizada (se disponível).
  - Ou criar diretiva/component customizado baseado no padrão existente.
  - **Se necessário, desabilitar a máscara padrão e criar uma solução customizada** que aceite alfanuméricos na digitação manual.
  - **Implementar handler de `input` ou `keydown` que intercepte a digitação ANTES da biblioteca processar e permita letras.**

### 4.3 Ajuste de validação
- Atualizar **validações de formulário** (`Validators.pattern`, `Yup`, `Zod`, etc.) para aceitar letras nos 12 primeiros caracteres:
  ```typescript
  Validators.pattern(/^[A-Z0-9]{12}\d{2}$/i)
  ```
- Para inputs mascarados, garantir que o valor submetido seja limpo (`unmask`/`rawValue`) sem perder as letras.
- Atualizar também **pipes, formatadores e máscaras visuais**.

### 4.3.1 Validação de clipboard/paste (OBRIGATÓRIO)
- **Implementar handler de evento `paste`** em todos os campos de CNPJ e CPF para validar o conteúdo antes de aceitar a colagem.
- **CRÍTICO: Preservar letras no paste — NÃO substituir por zeros:**
  - O handler de paste **DEVE preservar todas as letras** do valor colado.
  - **NÃO permitir que a biblioteca de máscara substitua letras por zeros** — se isso ocorrer, interceptar o paste antes da biblioteca processar.
  - Validar o valor colado **antes** de aplicar a máscara, e se válido, aplicar manualmente preservando as letras.
- **Regra de validação de paste para CNPJ:**
  - O valor colado deve ser **alfanumérico conforme padrão** (CNPJ alfanumérico: `^[A-Z0-9]{12}\d{2}$` ou com máscara `^[A-Z0-9]{2}\.[A-Z0-9]{3}\.[A-Z0-9]{3}/[A-Z0-9]{4}-\d{2}$`).
  - **Aceitar também CNPJ numérico** para retrocompatibilidade (`^\d{14}$` ou `^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$`).
  - **Bloquear qualquer valor que contenha caracteres especiais inválidos** (ex.: `@`, `#`, `$`, `%`, `&`, `*`, `(`, `)`, `-` fora da posição correta, espaços, etc.).
  - **Bloquear valores que misturem letras e números de forma inválida** (ex.: letras nos 2 últimos dígitos verificadores).
- **Regra de validação de paste para CPF:**
  - O valor colado deve ser **exclusivamente numérico** (CPF: `^\d{11}$` ou com máscara `^\d{3}\.\d{3}\.\d{3}-\d{2}$`).
  - **Nota:** CPF permanece 100% numérico (não há padrão alfanumérico para CPF conforme as INs mencionadas).
  - **Bloquear qualquer valor que contenha caracteres especiais inválidos ou letras.**
- **Comportamento esperado:**
  - Se o valor colado for válido (numérico ou alfanumérico conforme padrão), aplicar a máscara **preservando todas as letras**.
  - Se o valor colado for inválido, **prevenir o evento de paste** (`event.preventDefault()`) e **exibir mensagem de erro** ao usuário (ex.: "Valor inválido. O CNPJ deve seguir o padrão alfanumérico: 12 caracteres alfanuméricos + 2 dígitos numéricos.").
- **Implementação técnica:**
  - Criar diretiva/componente que intercepte o evento `paste` ou `onPaste` **ANTES** da biblioteca de máscara processar.
  - Limpar o valor colado (remover máscara, espaços, caracteres especiais) antes de validar, **mas preservar letras**.
  - Validar o valor limpo contra os padrões aceitos.
  - Se válido, aplicar o valor diretamente no formControl/state **sem passar pela máscara padrão** (ou usando método que preserve letras).
  - **Testar especificamente:** colar `7O.L55.2C2/2646-00` deve resultar em `7O.L55.2C2/2646-00`, **NÃO** em `70.055.202/2646-00`.
- **Exemplo de regex para validação de paste:**
  ```typescript
  // Validação para CNPJ (sem máscara)
  const cnpjPattern = /^[A-Z0-9]{12}\d{2}$/i;
  
  // Validação para CNPJ numérico (retrocompatibilidade)
  const cnpjNumericPattern = /^\d{14}$/;
  
  // Validação combinada para CNPJ (aceita ambos)
  const isValidCnpj = (value: string): boolean => {
    const cleaned = value.replace(/[^\w]/g, '').toUpperCase();
    return cnpjPattern.test(cleaned) || cnpjNumericPattern.test(cleaned);
  };
  
  // Validação para CPF (apenas numérico)
  const cpfPattern = /^\d{11}$/;
  
  const isValidCpf = (value: string): boolean => {
    const cleaned = value.replace(/[^\d]/g, '');
    return cpfPattern.test(cleaned);
  };
  ```

### 4.4 Atualização dos testes
- Atualizar testes unitários e e2e:
  - Inserir exemplos de CNPJs numéricos e alfanuméricos.
  - Validar máscaras, digitação, formatação e submissão de dados.
  - **CRÍTICO: Testar digitação de letras:**
    - Testar digitação manual de letras (ex.: digitar `7O.L55.2C2/2646-00` caractere por caractere).
    - Verificar que as letras são aceitas e exibidas corretamente, **não substituídas por zeros ou números**.
    - Testar digitação de letras maiúsculas e minúsculas (devem ser convertidas para maiúsculas).
    - Testar digitação de letras em todas as posições dos 12 primeiros caracteres.
  - Garantir que as letras A–Z sejam aceitas nos 12 primeiros caracteres.
  - **Testar validação de paste:**
    - Testar colagem de CNPJ numérico válido (deve aceitar e preservar números).
    - Testar colagem de CNPJ alfanumérico válido (ex.: `7O.L55.2C2/2646-00`) — **deve aceitar e preservar todas as letras, não substituir por zeros**.
    - Testar colagem de valores inválidos (deve bloquear):
      - Valores com caracteres especiais (`12.345.678/0001-90@`, `12.345.678/0001-90#`).
      - Valores com espaços (`12.345.678/0001-90 `).
      - Valores com letras nos dígitos verificadores (`AB1234567890AB`).
      - Valores com formato incorreto (`ABC123DEF456GH78`).
      - Valores vazios ou apenas caracteres especiais.
    - **Teste específico:** Colar `7O.L55.2C2/2646-00` deve resultar exatamente em `7O.L55.2C2/2646-00`, não em `70.055.202/2646-00`.

### 4.5 Ajustes complementares
- Atualizar `README.md`, tooltips e mensagens de erro dos formulários.
- Verificar se há **pipes de formatação** e **diretivas de input** específicas para CNPJ/CPF e ajustar regex e máscaras.

### 4.6 Implementação de handler de digitação manual (OBRIGATÓRIO se a biblioteca não aceitar letras)

Se a biblioteca de máscara não aceitar letras nativamente na digitação manual, é **OBRIGATÓRIO** implementar um handler customizado que permita a digitação de letras em tempo real.

**Implementação base (adaptar conforme o framework):**

```typescript
// Handler de digitação manual para CNPJ (Angular exemplo)
onCnpjKeyDown(event: KeyboardEvent): void {
  const key = event.key;
  const input = event.target as HTMLInputElement;
  const currentValue = input.value.replace(/[^\w]/g, ''); // Remove máscara temporariamente
  const cursorPosition = input.selectionStart || 0;
  
  // Permitir teclas de controle
  if (['Backspace', 'Delete', 'Tab', 'ArrowLeft', 'ArrowRight', 'Home', 'End', 'Enter'].includes(key)) {
    return;
  }
  
  // Permitir Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X
  if (event.ctrlKey && ['a', 'c', 'v', 'x'].includes(key.toLowerCase())) {
    return;
  }
  
  // Permitir letras (A-Z, a-z) nos 12 primeiros caracteres
  if (/^[A-Za-z]$/.test(key) && currentValue.length < 12) {
    // Converter para maiúscula e permitir
    const upperKey = key.toUpperCase();
    // Aplicar manualmente se necessário
    return;
  }
  
  // Permitir números em todas as posições
  if (/^[0-9]$/.test(key)) {
    return;
  }
  
  // Bloquear outros caracteres
  event.preventDefault();
}

// Handler de input para aplicar máscara preservando letras (Angular exemplo)
onCnpjInput(event: Event): void {
  const input = event.target as HTMLInputElement;
  let value = input.value.replace(/[^\w]/g, '').toUpperCase(); // Remove máscara e converte para maiúscula
  
  // Limitar a 14 caracteres
  if (value.length > 14) {
    value = value.slice(0, 14);
  }
  
  // Aplicar máscara preservando letras
  if (value.length > 0) {
    let masked = '';
    if (value.length > 0) masked += value.slice(0, Math.min(2, value.length));
    if (value.length > 2) masked += '.' + value.slice(2, Math.min(5, value.length));
    if (value.length > 5) masked += '.' + value.slice(5, Math.min(8, value.length));
    if (value.length > 8) masked += '/' + value.slice(8, Math.min(12, value.length));
    if (value.length > 12) masked += '-' + value.slice(12, Math.min(14, value.length));
    
    input.value = masked;
    // Atualizar formControl se necessário
    this.form.get('cnpj')?.setValue(masked, { emitEvent: false });
  }
}
```

**No template (Angular exemplo):**
```html
<input 
  type="text"
  formControlName="cnpj"
  (keydown)="onCnpjKeyDown($event)"
  (input)="onCnpjInput($event)"
  (paste)="onCnpjPaste($event)"
  placeholder="SS.SSS.SSS/SSSS-NN"
/>
```

**Importante:**
- O handler de `keydown` deve **PERMITIR** letras, não bloqueá-las.
- O handler de `input` deve **PRESERVAR** letras ao aplicar a máscara.
- **NÃO** usar handlers que filtrem letras antes de chegar ao input.
- **TESTAR** digitando letras manualmente para garantir que funcionam.

### 4.7 Problemas comuns e soluções

#### Problema 1: Máscara não aceita letras na DIGITAÇÃO MANUAL (PRIORIDADE MÁXIMA)
**Sintoma:** Ao tentar digitar letras manualmente (pressionando teclas do teclado), elas não aparecem no campo ou são substituídas por zeros/números. O usuário só consegue digitar números.  
**Causa comum:** 
- Máscara configurada apenas para números (ex.: `00.000.000/0000-00`, `99.999.999/9999-99`).
- Atributo HTML `type="number"` ou `inputmode="numeric"` bloqueando letras.
- Handler de eventos (`keydown`, `keypress`, `input`) que filtra/bloqueia letras.
- Biblioteca de máscara que processa a entrada ANTES de permitir letras.

**Solução passo a passo:**
1. **Verificar e corrigir a configuração da máscara:**
   - Alterar de padrão numérico (`00.000.000/0000-00`) para alfanumérico (`SS.SSS.SSS/SSSS-NN` ou equivalente da biblioteca).
   - Consultar a documentação da biblioteca para o formato correto de máscara alfanumérica.
   
2. **Verificar e remover atributos HTML restritivos:**
   - **REMOVER** `type="number"` → usar `type="text"` ou `type="tel"`.
   - **REMOVER** `pattern="[0-9]*"` ou qualquer pattern numérico.
   - **REMOVER** `inputmode="numeric"` se estiver bloqueando letras.
   - **GARANTIR** que o input aceite texto alfanumérico.

3. **Verificar e ajustar handlers de eventos:**
   - Procurar por handlers de `keydown`, `keypress`, `keyup` ou `input` que possam estar bloqueando letras.
   - Se encontrar, modificar para **PERMITIR** letras (A-Z) nos 12 primeiros caracteres.
   - Exemplo de handler que PERMITE letras:
     ```typescript
     onKeyDown(event: KeyboardEvent): void {
       const key = event.key;
       const input = event.target as HTMLInputElement;
       const cursorPosition = input.selectionStart || 0;
       const currentValue = input.value.replace(/[^\w]/g, '');
       
       // Permitir teclas de controle (Backspace, Delete, Tab, etc.)
       if (['Backspace', 'Delete', 'Tab', 'ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(key)) {
         return;
       }
       
       // Permitir letras (A-Z) nos 12 primeiros caracteres
       if (/^[A-Za-z]$/.test(key) && currentValue.length < 12) {
         return; // Permitir a digitação
       }
       
       // Permitir números em todas as posições
       if (/^[0-9]$/.test(key)) {
         return; // Permitir a digitação
       }
       
       // Bloquear outros caracteres
       event.preventDefault();
     }
     ```

4. **Se a biblioteca não suporta alfanuméricos nativamente:**
   - Criar handler customizado de `keydown`/`input` que intercepte a digitação **ANTES** da biblioteca processar.
   - Aplicar a máscara manualmente preservando as letras.
   - Considerar desabilitar a máscara padrão da biblioteca e implementar uma solução customizada.

5. **Teste de validação:**
   - Abrir o formulário no navegador.
   - Clicar no campo CNPJ.
   - **Digitar manualmente:** `7` → `O` → `L` → `5` → `5` → etc.
   - **VERIFICAR que cada letra aparece IMEDIATAMENTE** no campo.
   - Se letras não aparecerem, repetir os passos acima até funcionar.

#### Problema 2: Letras são substituídas por zeros ao colar
**Sintoma:** Ao colar `7O.L55.2C2/2646-00`, o resultado é `70.055.202/2646-00` (letras viram zeros).  
**Causa comum:** A biblioteca de máscara processa o paste antes do handler customizado e filtra caracteres não numéricos.  
**Solução:**
- Interceptar o evento `paste` **antes** da biblioteca processar (usar `capture: true` ou `useCapture: true`).
- No handler de paste, validar e aplicar o valor diretamente no formControl/state, **sem passar pela máscara padrão**.
- Aplicar a máscara manualmente preservando as letras.
- Exemplo: Se usar `ngx-mask`, pode ser necessário usar `[showMaskTyped]="false"` e aplicar máscara manualmente.

#### Problema 3: Biblioteca não suporta caracteres alfanuméricos
**Sintoma:** A biblioteca detectada não possui suporte nativo para máscaras alfanuméricas.  
**Causa comum:** Biblioteca antiga ou focada apenas em números.  
**Solução:**
- Consultar documentação da biblioteca para extensões ou plugins.
- Criar diretiva/componente customizado que aceite alfanuméricos.
- Considerar migrar para biblioteca que suporte alfanuméricos (ex.: `imask.js` com configuração customizada).
- Implementar máscara manual usando regex e eventos de input.

#### Problema 4: Validação rejeita CNPJ alfanumérico válido
**Sintoma:** CNPJ alfanumérico válido (ex.: `7O.L55.2C2/2646-00`) é rejeitado pela validação.  
**Causa comum:** Regex de validação ainda restrita a números apenas.  
**Solução:**
- Atualizar regex de validação para aceitar alfanuméricos: `/^[A-Z0-9]{12}\d{2}$/i`.
- Verificar validações em múltiplos pontos (formControl, pipe, serviço, etc.).
- Garantir que validações sejam case-insensitive (`/i` no regex).

#### Checklist de verificação pós-implementação:
- [ ] **PRIORIDADE MÁXIMA: Digitação manual de letras funciona?**
  - [ ] Abrir o formulário no navegador.
  - [ ] Clicar no campo CNPJ.
  - [ ] **Digitar manualmente caractere por caractere:** `7` → `O` → `.` → `L` → `5` → `5` → `.` → `2` → `C` → `2` → `/` → `2` → `6` → `4` → `6` → `-` → `0` → `0`
  - [ ] **VERIFICAR que cada letra (`O`, `L`, `C`) aparece IMEDIATAMENTE no campo** conforme é digitada.
  - [ ] **VERIFICAR que letras NÃO são substituídas por zeros ou números.**
  - [ ] Se letras não aparecerem ou forem substituídas, a implementação está INCORRETA.
- [ ] Colar `7O.L55.2C2/2646-00` — letras são preservadas (não viram zeros)?
- [ ] Colar `70.055.202/2646-00` (numérico) — funciona normalmente?
- [ ] Tentar colar valor inválido (ex.: `7O.L55.2C2/2646-00@`) — é bloqueado?
- [ ] Validação do formulário aceita CNPJ alfanumérico válido?
- [ ] Validação do formulário aceita CNPJ numérico (retrocompatibilidade)?
- [ ] Verificar que não há `type="number"` ou `inputmode="numeric"` bloqueando letras?
- [ ] Verificar que handlers de eventos permitem letras na digitação?

---

## 5) Estrutura do relatório (`implementacao.md`)

O relatório gerado deve conter:

1. **Resumo técnico do projeto**: framework (Angular, React, Vue), versão e bibliotecas detectadas.  
2. **Biblioteca de máscara identificada** (nome + versão).  
3. **Trecho da configuração original e ajustada da máscara**.  
4. **Regex e máscaras aplicadas (antes/depois)**.  
5. **Implementação de validação de paste/clipboard** (código, handlers, mensagens de erro).  
6. **Evidências de testes de digitação de letras** — screenshots ou descrição testando digitação manual de `7O.L55.2C2/2646-00` caractere por caractere.  
7. **Evidências de testes de colagem de CNPJ alfanumérico** — screenshots ou descrição testando colagem de `7O.L55.2C2/2646-00` e verificando que letras são preservadas (não substituídas por zeros).  
8. **Arquivos alterados** (lista detalhada).  
9. **Referências da documentação oficial** da biblioteca.  
10. **Casos de teste criados/ajustados** (incluindo testes de digitação de letras, paste válido e inválido).  
11. **Screenshots ou descrições** de formulários testados (quando aplicável).  

---

## 6) Regras complementares

- **PRIORIDADE MÁXIMA: Garantir que letras sejam aceitas na DIGITAÇÃO MANUAL** — o usuário DEVE conseguir digitar letras (A-Z) nos 12 primeiros caracteres do CNPJ pressionando teclas do teclado. As letras DEVEM aparecer IMEDIATAMENTE no campo, não serem bloqueadas, filtradas ou substituídas por zeros/números. Se a biblioteca de máscara não aceitar letras nativamente, implementar handler customizado que permita digitação manual de letras.
- **CRÍTICO: Garantir que letras sejam preservadas no paste** — ao colar um CNPJ alfanumérico, todas as letras devem ser preservadas, não substituídas por zeros. O handler de paste deve interceptar antes da biblioteca de máscara processar.
- **OBRIGATÓRIO: Verificar e remover atributos HTML que bloqueiam letras** — não usar `type="number"`, `inputmode="numeric"`, `pattern="[0-9]*"` ou similares que impeçam digitação manual de letras.
- **OBRIGATÓRIO: Verificar handlers de eventos** — garantir que handlers de `keydown`, `keypress`, `input` não bloqueiem ou filtrem letras durante a digitação manual.
- **OBRIGATÓRIO: Implementar validação de paste/clipboard** — bloquear colagem de valores que não sejam exclusivamente numéricos (somente no CPF) ou alfanuméricos (No CNPJ e CPF) conforme o padrão oficial. Valores inválidos devem ser rejeitados com mensagem de erro clara ao usuário.
- **Não criar utilitários JavaScript duplicados** se já houver uma biblioteca central de máscaras.  
- **Preservar retrocompatibilidade** com CNPJs numéricos (máscara `##.###.###/####-##`).  
- **Não modificar APIs externas** — apenas camada de exibição e input.  
- **Não incluir alterações em banco de dados ou backend** neste escopo.  
- **Evitar duplicidade de diretivas** — ajuste diretivas existentes.  
- **Usar regex case-insensitive (`/i`)** para garantir compatibilidade.  
- **Todos os commits devem refletir claramente as mudanças de máscara e validação.**

---

## 7) Code Review final

1. **Revisar todas as alterações de input masks e validações.**  
2. **Comparar comportamento anterior e novo (numérico x alfanumérico).**  
3. **PRIORIDADE MÁXIMA: Testar manualmente a DIGITAÇÃO MANUAL de letras:**
   - Abrir o formulário no navegador.
   - Clicar no campo CNPJ.
   - **Digitar manualmente caractere por caractere:** `7` → `O` → `.` → `L` → `5` → `5` → `.` → `2` → `C` → `2` → `/` → `2` → `6` → `4` → `6` → `-` → `0` → `0`
   - **VERIFICAR que cada letra (`O`, `L`, `C`) aparece IMEDIATAMENTE no campo** conforme é digitada.
   - **VERIFICAR que letras NÃO são substituídas por zeros ou números.**
   - **VERIFICAR que letras NÃO são bloqueadas ou ignoradas.**
   - Se letras não aparecerem durante a digitação manual, a implementação está INCORRETA e precisa ser corrigida.
4. **CRÍTICO: Testar manualmente a colagem de CNPJ alfanumérico** — colar `7O.L55.2C2/2646-00` e verificar que todas as letras são preservadas, não substituídas por zeros.  
5. **Verificar que não há atributos HTML bloqueando letras:**
   - Verificar que não há `type="number"` no input.
   - Verificar que não há `inputmode="numeric"` bloqueando letras.
   - Verificar que não há `pattern="[0-9]*"` ou similar.
6. **Verificar que handlers de eventos permitem letras:**
   - Revisar handlers de `keydown`, `keypress`, `input`.
   - Garantir que permitem letras (A-Z) nos 12 primeiros caracteres.
7. **Testar manualmente a validação de paste** com valores válidos e inválidos.  
8. **Executar os testes unitários e e2e completos** (incluindo testes de digitação manual de letras e paste).  
9. **Verificar a documentação e comentários de código.**  
10. **Confirmar que a máscara visual está conforme o padrão oficial.**  
11. **Anexar evidências no relatório (`implementacao.md`)** incluindo screenshots ou vídeos dos testes de digitação manual e colagem de letras.

---

## 8) Critérios de aceite

- **PRIORIDADE MÁXIMA / CRÍTICO:** A máscara do CNPJ aceita letras (A–Z) nos 12 primeiros caracteres e números nos 2 últimos **durante a DIGITAÇÃO MANUAL** (pressionando teclas do teclado). O usuário DEVE conseguir digitar letras em tempo real, sem que sejam bloqueadas, filtradas ou substituídas.  
- **PRIORIDADE MÁXIMA / CRÍTICO:** Ao digitar letras manualmente (pressionando teclas A-Z no teclado), elas são exibidas **IMEDIATAMENTE** no campo, **não são substituídas por zeros ou números**, e **não são bloqueadas ou ignoradas**.  
- **CRÍTICO:** Ao colar um CNPJ alfanumérico (ex.: `7O.L55.2C2/2646-00`), todas as letras são preservadas, **não são substituídas por zeros**.  
- A biblioteca de máscara foi configurada conforme sua documentação oficial para aceitar caracteres alfanuméricos **na digitação manual**, ou foi implementada solução customizada que permite digitação de letras.  
- **Verificação obrigatória:** Não há atributos HTML (`type="number"`, `inputmode="numeric"`, `pattern="[0-9]*"`) que bloqueiem letras na digitação.  
- **Verificação obrigatória:** Não há handlers de eventos (`keydown`, `keypress`, `input`) que bloqueiem ou filtrem letras durante a digitação manual.  
- Validações regex foram atualizadas.  
- **Validação de paste/clipboard foi implementada** — valores inválidos são bloqueados e exibem mensagem de erro, valores válidos preservam letras.  
- Todos os testes passam com CNPJs numéricos e alfanuméricos, incluindo testes de digitação manual de letras e paste válido/inválido.  
- **Teste manual obrigatório:** 
  - **Digitar `7O.L55.2C2/2646-00` caractere por caractere** (pressionando cada tecla manualmente) — **cada letra deve aparecer IMEDIATAMENTE no campo**.
  - **Colar o mesmo valor** — deve resultar em `7O.L55.2C2/2646-00` (letras preservadas).
  - Se letras não aparecerem durante a digitação manual, o critério NÃO foi atendido.  
- O relatório final foi gerado com inventário e referências da documentação da biblioteca.

---

## 9) Exemplo prático (Angular + ngx-mask)

```typescript
// Antes
<input mask="00.000.000/0000-00" formControlName="cnpj" />

// Depois - OPCÃO 1: Se ngx-mask suportar máscara alfanumérica nativamente
<input 
  type="text"
  mask="SS.SSS.SSS/SSSS-NN" 
  formControlName="cnpj"
  (keydown)="onCnpjKeyDown($event)"
  (paste)="onCnpjPaste($event)" 
/>

// Depois - OPCÃO 2: Se ngx-mask NÃO suportar, desabilitar e usar handler customizado
<input 
  type="text"
  [mask]="null"
  formControlName="cnpj"
  (keydown)="onCnpjKeyDown($event)"
  (input)="onCnpjInput($event)"
  (paste)="onCnpjPaste($event)"
  placeholder="SS.SSS.SSS/SSSS-NN"
/>

// Validação
Validators.pattern(/^[A-Z0-9]{12}\d{2}$/i)

// Handler de digitação manual (OBRIGATÓRIO para permitir letras)
onCnpjKeyDown(event: KeyboardEvent): void {
  const key = event.key;
  const input = event.target as HTMLInputElement;
  const currentValue = input.value.replace(/[^\w]/g, ''); // Remove máscara
  
  // Permitir teclas de controle
  if (['Backspace', 'Delete', 'Tab', 'ArrowLeft', 'ArrowRight', 'Home', 'End', 'Enter'].includes(key)) {
    return;
  }
  
  // Permitir Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X
  if (event.ctrlKey && ['a', 'c', 'v', 'x'].includes(key.toLowerCase())) {
    return;
  }
  
  // CRÍTICO: Permitir letras (A-Z, a-z) nos 12 primeiros caracteres
  if (/^[A-Za-z]$/.test(key) && currentValue.length < 12) {
    return; // PERMITIR a digitação da letra
  }
  
  // Permitir números em todas as posições
  if (/^[0-9]$/.test(key)) {
    return; // PERMITIR a digitação do número
  }
  
  // Bloquear outros caracteres
  event.preventDefault();
}

// Handler de input para aplicar máscara preservando letras (se não usar ngx-mask)
onCnpjInput(event: Event): void {
  const input = event.target as HTMLInputElement;
  let value = input.value.replace(/[^\w]/g, '').toUpperCase(); // Remove máscara e converte para maiúscula
  
  // Limitar a 14 caracteres
  if (value.length > 14) {
    value = value.slice(0, 14);
  }
  
  // Aplicar máscara preservando letras
  if (value.length > 0) {
    let masked = '';
    if (value.length > 0) masked += value.slice(0, Math.min(2, value.length));
    if (value.length > 2) masked += '.' + value.slice(2, Math.min(5, value.length));
    if (value.length > 5) masked += '.' + value.slice(5, Math.min(8, value.length));
    if (value.length > 8) masked += '/' + value.slice(8, Math.min(12, value.length));
    if (value.length > 12) masked += '-' + value.slice(12, Math.min(14, value.length));
    
    input.value = masked;
    this.form.get('cnpj')?.setValue(masked, { emitEvent: false });
  }
}

// Handler de paste (no componente)
onCnpjPaste(event: ClipboardEvent): void {
  event.preventDefault();
  const pastedData = event.clipboardData?.getData('text') || '';
  // IMPORTANTE: Preservar letras - remover apenas caracteres especiais, não letras
  const cleaned = pastedData.replace(/[^A-Z0-9]/gi, '').toUpperCase();
  
  // Validação: aceita apenas numérico (14 dígitos) ou alfanumérico (12 alfanuméricos + 2 numéricos)
  const isValidNumeric = /^\d{14}$/.test(cleaned);
  const isValidAlphanumeric = /^[A-Z0-9]{12}\d{2}$/.test(cleaned);
  
  if (isValidNumeric || isValidAlphanumeric) {
    // CRÍTICO: Aplicar valor diretamente no formControl preservando letras
    // Não deixar a máscara processar, pois pode substituir letras por zeros
    this.form.get('cnpj')?.setValue(cleaned);
    // Aplicar máscara manualmente preservando letras
    this.applyMaskPreservingLetters(cleaned);
  } else {
    // Exibir mensagem de erro
    this.showError('CNPJ inválido. Use apenas números ou o padrão alfanumérico (12 caracteres alfanuméricos + 2 dígitos numéricos).');
  }
}

// Método auxiliar para aplicar máscara preservando letras
applyMaskPreservingLetters(value: string): void {
  if (value.length === 14) {
    const masked = `${value.slice(0, 2)}.${value.slice(2, 5)}.${value.slice(5, 8)}/${value.slice(8, 12)}-${value.slice(12, 14)}`;
    this.form.get('cnpj')?.setValue(masked, { emitEvent: false });
  }
}
```

**Referência:** [ngx-mask Documentation](https://www.npmjs.com/package/ngx-mask)

**IMPORTANTE:** 
- Se `ngx-mask` não aceitar letras na digitação manual mesmo com `mask="SS.SSS.SSS/SSSS-NN"`, use a OPCÃO 2 (desabilitar a máscara e usar handlers customizados).
- **SEMPRE testar digitando letras manualmente** para garantir que funcionam.

---

## 10) Exemplo prático (React + react-input-mask)

```jsx
// Antes
<InputMask mask="99.999.999/9999-99" value={cnpj} onChange={handleChange} />

// Depois - OPCÃO 1: Se react-input-mask suportar máscara alfanumérica
<InputMask 
  mask="AA.AAA.AAA/AAAA-NN" 
  value={cnpj} 
  onChange={handleChange}
  onKeyDown={handleCnpjKeyDown}
  onPaste={handleCnpjPaste}
/>

// Depois - OPCÃO 2: Se react-input-mask NÃO suportar, usar input customizado
<input
  type="text"
  value={cnpj}
  onChange={handleCnpjInput}
  onKeyDown={handleCnpjKeyDown}
  onPaste={handleCnpjPaste}
  placeholder="SS.SSS.SSS/SSSS-NN"
/>

// Validação (Yup)
Yup.string().matches(/^[A-Z0-9]{12}\d{2}$/i, 'CNPJ inválido')

// Handler de digitação manual (OBRIGATÓRIO para permitir letras)
const handleCnpjKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
  const key = event.key;
  const input = event.currentTarget;
  const currentValue = input.value.replace(/[^\w]/g, ''); // Remove máscara
  
  // Permitir teclas de controle
  if (['Backspace', 'Delete', 'Tab', 'ArrowLeft', 'ArrowRight', 'Home', 'End', 'Enter'].includes(key)) {
    return;
  }
  
  // Permitir Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X
  if (event.ctrlKey && ['a', 'c', 'v', 'x'].includes(key.toLowerCase())) {
    return;
  }
  
  // CRÍTICO: Permitir letras (A-Z, a-z) nos 12 primeiros caracteres
  if (/^[A-Za-z]$/.test(key) && currentValue.length < 12) {
    return; // PERMITIR a digitação da letra
  }
  
  // Permitir números em todas as posições
  if (/^[0-9]$/.test(key)) {
    return; // PERMITIR a digitação do número
  }
  
  // Bloquear outros caracteres
  event.preventDefault();
};

// Handler de input para aplicar máscara preservando letras (se não usar react-input-mask)
const handleCnpjInput = (event: React.ChangeEvent<HTMLInputElement>) => {
  const input = event.target;
  let value = input.value.replace(/[^\w]/g, '').toUpperCase(); // Remove máscara e converte para maiúscula
  
  // Limitar a 14 caracteres
  if (value.length > 14) {
    value = value.slice(0, 14);
  }
  
  // Aplicar máscara preservando letras
  if (value.length > 0) {
    let masked = '';
    if (value.length > 0) masked += value.slice(0, Math.min(2, value.length));
    if (value.length > 2) masked += '.' + value.slice(2, Math.min(5, value.length));
    if (value.length > 5) masked += '.' + value.slice(5, Math.min(8, value.length));
    if (value.length > 8) masked += '/' + value.slice(8, Math.min(12, value.length));
    if (value.length > 12) masked += '-' + value.slice(12, Math.min(14, value.length));
    
    setCnpj(masked);
  } else {
    setCnpj('');
  }
};

// Handler de paste (no componente)
const handleCnpjPaste = (event: React.ClipboardEvent<HTMLInputElement>) => {
  event.preventDefault();
  const pastedData = event.clipboardData.getData('text');
  // IMPORTANTE: Preservar letras - remover apenas caracteres especiais, não letras
  const cleaned = pastedData.replace(/[^A-Z0-9]/gi, '').toUpperCase();
  
  // Validação: aceita apenas numérico (14 dígitos) ou alfanumérico (12 alfanuméricos + 2 numéricos)
  const isValidNumeric = /^\d{14}$/.test(cleaned);
  const isValidAlphanumeric = /^[A-Z0-9]{12}\d{2}$/.test(cleaned);
  
  if (isValidNumeric || isValidAlphanumeric) {
    // CRÍTICO: Aplicar valor preservando letras e aplicar máscara manualmente
    const masked = cleaned.length === 14 
      ? `${cleaned.slice(0, 2)}.${cleaned.slice(2, 5)}.${cleaned.slice(5, 8)}/${cleaned.slice(8, 12)}-${cleaned.slice(12, 14)}`
      : cleaned;
    setCnpj(masked);
  } else {
    setError('CNPJ inválido. Use apenas números ou o padrão alfanumérico (12 caracteres alfanuméricos + 2 dígitos numéricos).');
  }
};
```

**Referência:** [react-input-mask GitHub](https://github.com/sanniassin/react-input-mask)

**IMPORTANTE:** 
- Se `react-input-mask` não aceitar letras na digitação manual mesmo com `mask="AA.AAA.AAA/AAAA-NN"`, use a OPCÃO 2 (input customizado com handlers).
- **SEMPRE testar digitando letras manualmente** para garantir que funcionam.

---

## 11) Conclusão

Este prompt deve ser aplicado **apenas em projetos Frontend**.  
A missão do agente é garantir que **a máscara e validação do CNPJ alfanumérico estejam de acordo com o padrão oficial** e **com as bibliotecas já utilizadas no projeto**, sem quebrar o comportamento anterior.

**PRIORIDADE MÁXIMA:** Resolver o problema reportado pelo cliente: **permitir digitação manual de letras nos campos de CNPJ**. O usuário DEVE conseguir digitar letras (A-Z) pressionando teclas do teclado, e as letras DEVEM aparecer IMEDIATAMENTE no campo.

```diff
+ Detectar biblioteca de máscara
+ Consultar documentação oficial
+ Ajustar máscara e regex para CNPJ alfanumérico
+ PRIORIDADE MÁXIMA: GARANTIR que aceita letras na DIGITAÇÃO MANUAL (pressionar teclas A-Z)
+ Verificar e remover atributos HTML que bloqueiam letras (type="number", etc.)
+ Verificar e ajustar handlers de eventos para permitir letras na digitação
+ Implementar handler customizado de digitação manual se necessário
+ Implementar validação de paste/clipboard (BLOQUEAR valores inválidos, PRESERVAR letras)
+ Testar digitação manual de letras caractere por caractere (não devem ser bloqueadas ou substituídas)
+ Testar colagem de CNPJ alfanumérico (letras devem ser preservadas)
+ Testar retrocompatibilidade
+ Testar validação de paste com valores válidos e inválidos
+ Gerar relatório completo com inventário e referências
```
