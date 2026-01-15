
# Base de Conhecimento para Adequação ao CNPJ Alfanumérico

## Objetivo

Este documento tem como finalidade orientar a adequação de sistemas ao novo formato de CNPJ alfanumérico, conforme as normas da Receita Federal do Brasil (IN RFB nº 2.119/2022 e IN RFB nº 2.229/2024). O objetivo é identificar os impactos e adaptações necessárias em APIs, front-end e banco de dados.

## 1. Estrutura do CNPJ Alfanumérico

| Bloco | Posição | Conteúdo      | Tipo                       |
|-------|---------|---------------|----------------------------|
| Raiz  | 1–8     | Alfanumérica  | Letras maiúsculas e números |
| Ordem | 9–12    | Alfanumérica  | Letras maiúsculas e números |
| DV    | 13–14   | Numérica      | Apenas números             |

- Total: 14 caracteres
- Novo formato: `SS.SSS.SSS/SSSS-NN`

## 2. Impactos e Adaptações Necessárias

### 2.1 Banco de Dados

- Alterar colunas que armazenam CNPJ de `CHAR(14)` ou `VARCHAR(14)` com restrição numérica para `VARCHAR(14)` permitindo letras.
- Atualizar **constraints**, **índices**, **chaves primárias/estrangeiras**.
- Corrigir procedures, triggers e views com validações ou regras sobre CNPJ.

**Exemplo SQL:**
```sql
ALTER TABLE empresas
ALTER COLUMN cnpj TYPE VARCHAR(14);
```

### 2.2 Back-end / APIs

#### Validação

- Validar CNPJs com regex alfanumérica:
```regex
^[A-Z0-9]{12}\d{2}$
```

#### Lógica de cálculo do dígito verificador

1. Converter cada caractere para ASCII.
2. Subtrair 48.
3. Aplicar pesos de 2 a 9 da direita para a esquerda (reiniciando a cada 8 posições).
4. Somar os produtos.
5. Calcular módulo 11:
   - Se resto = 0 ou 1 → DV = 0
   - Senão → DV = 11 - resto

#### Exemplo de cálculo em pseudocódigo:
```pseudo
valores = ascii(cnpj[i]) - 48
pesos = [5,4,3,2,9,8,7,6,5,4,3,2]
soma = sum(valores[i] * pesos[i])
resto = soma % 11
dv1 = 0 if resto < 2 else 11 - resto
```

### 2.3 Front-end

- Permitir entrada de letras e números nos 12 primeiros dígitos.
- Alterar máscaras de input:
  - De: `##.###.###/####-##`
  - Para: `SS.SSS.SSS/SSSS-NN`
- Validar com regex e feedback ao usuário sobre erro de DV.

### 2.4 Testes

Checklist:
- [ ] Testes com CNPJ numérico e alfanumérico.
- [ ] Verificar ordenações (ORDER BY).
- [ ] Verificar validações de entrada e consistência.
- [ ] Validar integração com sistemas externos.
- [ ] Atualizar mocks de testes automatizados.

## 3. Compatibilidade

- Ambos os formatos (numérico e alfanumérico) serão válidos.
- Não converter para número usando `parseInt`, `Number()` etc.
- Validar formato e DV antes de persistir.

## 4. Cronograma

- Início da geração: **julho de 2026**
- Os sistemas **devem estar prontos antes disso**.
- Adoção **retrocompatível**.

## 5. Conclusão

Todos os ajustes listados já podem ser implementados. A base técnica aqui descrita deve ser aplicada de forma independente da linguagem de programação ou tecnologia adotada, respeitando os princípios de validação e armazenamento estabelecidos pela Receita Federal.

---

**Fontes Oficiais:**
- IN RFB nº 2.119/2022
- IN RFB nº 2.229/2024
- Anexo XV – CNPJ Alfanumérico
