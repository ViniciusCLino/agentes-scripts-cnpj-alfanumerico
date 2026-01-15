# Script PowerShell para copiar uma pasta para múltiplos repositórios git
# Uso: .\copy_folder_to_repos.ps1 <nome_da_pasta> <diretorio_dos_repositorios>

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderName,
    
    [Parameter(Mandatory=$true)]
    [string]$ReposDirectory
)

# Verificar se o diretório dos repositórios existe
if (-not (Test-Path $ReposDirectory -PathType Container)) {
    Write-Error "Erro: Diretório '$ReposDirectory' não existe"
    exit 1
}

# Verificar se a pasta a ser copiada existe
if (-not (Test-Path $FolderName -PathType Container)) {
    Write-Error "Erro: Pasta '$FolderName' não existe no diretório atual"
    exit 1
}

Write-Host "Iniciando cópia da pasta '$FolderName' para repositórios em '$ReposDirectory'" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Contador para estatísticas
$copiedCount = 0
$skippedCount = 0
$errorCount = 0

# Obter todos os diretórios no diretório dos repositórios
$repos = Get-ChildItem -Path $ReposDirectory -Directory

foreach ($repo in $repos) {
    $repoName = $repo.Name
    $repoPath = $repo.FullName
    
    Write-Host "Processando repositório: $repoName" -ForegroundColor Yellow
    
    # Verificar se é um repositório git
    if (Test-Path "$repoPath\.git" -PathType Container) {
        # Verificar se a pasta já existe no repositório
        if (Test-Path "$repoPath\$FolderName" -PathType Container) {
            Write-Host "  ⚠️  Pasta '$FolderName' já existe em $repoName - PULANDO" -ForegroundColor Yellow
            $skippedCount++
        } else {
            # Copiar a pasta para o repositório
            try {
                Copy-Item -Path $FolderName -Destination $repoPath -Recurse -Force
                Write-Host "  ✅ Pasta '$FolderName' copiada com sucesso para $repoName" -ForegroundColor Green
                $copiedCount++
            } catch {
                Write-Host "  ❌ Erro ao copiar pasta para $repoName`: $($_.Exception.Message)" -ForegroundColor Red
                $errorCount++
            }
        }
    } else {
        Write-Host "  ⚠️  $repoName não é um repositório git - PULANDO" -ForegroundColor Yellow
        $skippedCount++
    }
    Write-Host ""
}

Write-Host "================================================" -ForegroundColor Green
Write-Host "Resumo da operação:" -ForegroundColor Cyan
Write-Host "  ✅ Pastas copiadas: $copiedCount" -ForegroundColor Green
Write-Host "  ⚠️  Repositórios pulados: $skippedCount" -ForegroundColor Yellow
Write-Host "  ❌ Erros: $errorCount" -ForegroundColor Red
Write-Host "================================================" -ForegroundColor Green

if ($errorCount -gt 0) {
    Write-Host "Atenção: Houve $errorCount erro(s) durante a operação" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Operação concluída com sucesso!" -ForegroundColor Green
    exit 0
}

