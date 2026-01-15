@echo off
REM Script para criar merge request no GitLab usando glab CLI
REM Uso: create_merge_request.bat <caminho_do_diretorio>

if "%~1"=="" (
    echo [ERROR] Caminho do diretorio nao fornecido
    echo.
    echo Uso: %0 ^<caminho_do_diretorio^>
    echo.
    echo Este script cria um merge request no GitLab usando glab CLI
    echo Branch de origem: fix-cnpj-alfanumerico-impl
    echo Branch de destino: fix-cnpj-alfanumerico-qa
    echo.
    echo Exemplo:
    echo   %0 C:\caminho\para\projeto
    echo   %0 .
    exit /b 1
)

if "%~1"=="-h" (
    goto :help
)
if "%~1"=="--help" (
    goto :help
)

echo [INFO] Iniciando criacao de merge request...
echo [INFO] Diretorio do projeto: %~1

REM Verificar se o glab esta instalado
where glab >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] glab CLI nao esta instalado ou nao esta no PATH
    echo [INFO] Para instalar o glab, visite: https://github.com/profclems/glab
    exit /b 1
)
echo [SUCCESS] glab CLI encontrado

REM Verificar se o diretorio existe
if not exist "%~1" (
    echo [ERROR] Diretorio '%~1' nao existe
    exit /b 1
)

REM Navegar para o diretorio
cd /d "%~1"
if %errorlevel% neq 0 (
    echo [ERROR] Nao foi possivel acessar o diretorio '%~1'
    exit /b 1
)

REM Verificar se e um repositorio Git
if not exist ".git" (
    echo [ERROR] O diretorio '%~1' nao e um repositorio Git
    exit /b 1
)
echo [SUCCESS] Repositorio Git valido encontrado em '%~1'

REM Verificar autenticacao
glab auth status >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Voce nao esta autenticado no glab
    echo [INFO] Execute 'glab auth login' para autenticar
    exit /b 1
)
echo [SUCCESS] Usuario autenticado no glab

REM Verificar remote
git remote show origin >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Remote 'origin' nao configurado
    echo [INFO] Configure o remote com: git remote add origin <url_do_repositorio>
    exit /b 1
)
echo [SUCCESS] Remote 'origin' configurado

REM Verificar se as branches existem
git show-ref --verify --quiet refs/heads/fix-cnpj-alfanumerico-impl
if %errorlevel% neq 0 (
    echo [ERROR] Branch de origem 'fix-cnpj-alfanumerico-impl' nao existe localmente
    echo [INFO] Branches disponiveis:
    git branch --list
    exit /b 1
)

git show-ref --verify --quiet refs/heads/fix-cnpj-alfanumerico-qa >nul 2>&1
if %errorlevel% neq 0 (
    git show-ref --verify --quiet refs/remotes/origin/fix-cnpj-alfanumerico-qa >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Branch de destino 'fix-cnpj-alfanumerico-qa' nao existe
        echo [INFO] Branches disponiveis:
        git branch -a
        exit /b 1
    )
)
echo [SUCCESS] Branches 'fix-cnpj-alfanumerico-impl' e 'fix-cnpj-alfanumerico-qa' encontradas

REM Verificar se a branch de origem foi enviada para o remoto
git show-ref --verify --quiet refs/remotes/origin/fix-cnpj-alfanumerico-impl >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Branch de origem nao foi enviada para o remoto
    echo [INFO] Enviando branch para o remoto...
    git push -u origin fix-cnpj-alfanumerico-impl
    if %errorlevel% neq 0 (
        echo [ERROR] Falha ao enviar branch para o remoto
        exit /b 1
    )
    echo [SUCCESS] Branch enviada para o remoto
)

REM Criar o merge request
echo [INFO] Criando merge request...
echo [INFO] Branch de origem: fix-cnpj-alfanumerico-impl
echo [INFO] Branch de destino: fix-cnpj-alfanumerico-qa

REM Criar MR sem aspas duplas para evitar problemas no Windows
glab mr create --source-branch fix-cnpj-alfanumerico-impl --target-branch fix-cnpj-alfanumerico-qa --title Implementacoes dos ajustes do projeto CNPJ Alfanumerico --description Merge request para implementacao das correcoes do CNPJ alfanumerico
if %errorlevel% equ 0 (
    echo [SUCCESS] Merge request criado com sucesso!
    echo [INFO] Voce pode visualizar o MR no GitLab ou usar 'glab mr list' para listar os MRs
) else (
    echo [ERROR] Falha ao criar o merge request
    echo [INFO] Tente criar manualmente: glab mr create -s fix-cnpj-alfanumerico-impl -t fix-cnpj-alfanumerico-qa
    exit /b 1
)

echo [SUCCESS] Processo concluido com sucesso!
exit /b 0

:help
echo Uso: %0 ^<caminho_do_diretorio^>
echo.
echo Este script cria um merge request no GitLab usando glab CLI
echo Branch de origem: fix-cnpj-alfanumerico-impl
echo Branch de destino: fix-cnpj-alfanumerico-qa
echo.
echo Exemplo:
echo   %0 C:\caminho\para\projeto
echo   %0 .
exit /b 0
