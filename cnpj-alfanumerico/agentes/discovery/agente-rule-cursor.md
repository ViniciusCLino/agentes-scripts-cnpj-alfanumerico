Você é um especialista em análise de sistemas e deve gerar um **arquivo `.rules` para o Cursor**.  
O objetivo do arquivo é mapear as informações essenciais do sistema para facilitar a compreensão e futuras alterações.  
 
🔎 **Analise o código do projeto e documente os seguintes pontos:**
1. Arquitetura utilizada (ex: Monolito, Microsserviços, Clean Architecture, Hexagonal, MVC, CQRS, Event-Driven, etc.).  
2. Hierarquia de diretórios (listar estrutura principal de pastas e responsabilidades).  
3. Tecnologias utilizadas (linguagens, frameworks, runtimes, com versões se disponíveis).  
4. Bibliotecas, pacotes e repositórios utilizados (nome, versão, link/repositório oficial).  
5. Design patterns aplicados (ex: Singleton, Repository, Factory, Observer, Strategy), explicando onde e como são usados.  
 
📄 **Formato de saída esperado:**
Gerar um arquivo chamado `projetorules.mdc` no formato YAML e salve na pasta .cursor/rules com a seguinte estrutura:
 
```yaml
# projetosrules
# Versão: 1.0
# Data: {data atual}
# Finalidade: Documentação analítica do sistema para uso no Cursor.
 
rules:
  - id: system-analysis
    description: >
      Analisa o sistema completo e gera um relatório estruturado contendo
      arquitetura, hierarquia de diretórios, tecnologias, bibliotecas e
      padrões de design utilizados.
 
    steps:
      - step: Identificar arquitetura
        instruction: >
          Descrever a arquitetura utilizada.
 
      - step: Mapear hierarquia de diretórios
        instruction: >
          Listar a estrutura principal de diretórios.
 
      - step: Levantar tecnologias utilizadas
        instruction: >
          Identificar linguagens, frameworks e runtimes.
 
      - step: Bibliotecas, pacotes e repositórios
        instruction: >
          Listar dependências, versões e links oficiais.
 
      - step: Design patterns
        instruction: >
          Registrar os padrões de projeto identificados.
 
    output_format: |
      # 📋 System Analysis Report
      ## Arquitetura
      - {descrição detalhada}
 
      ## Hierarquia de Diretórios
      ```plaintext
      {estrutura de pastas}
      ```
 
      ## Tecnologias
      - Linguagens: {linguagens}
      - Frameworks: {frameworks}
      - Runtimes: {runtimes}
 
      ## Bibliotecas e Pacotes
      - Nome: {biblioteca}
        Versão: {versão}
        Repositório: {link}
 
      ## Design Patterns
      - Padrão: {nome}
        Aplicação: {descrição de uso}