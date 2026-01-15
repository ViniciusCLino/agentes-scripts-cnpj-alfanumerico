# Script PowerShell para clonar repositórios a partir do arquivo repositorios.csv
# Uso: .\clone_repos.ps1 <pasta_destino>

param(
    [Parameter(Mandatory=$true)]
    [string]$DestDir
)

# Caminho para o arquivo CSV
$csvFile = "..\repositorios\repositorios.csv"

# Verificar se o arquivo CSV existe
if (-not (Test-Path $csvFile)) {
    Write-Host "Erro: Arquivo $csvFile não encontrado." -ForegroundColor Red
    exit 1
}

# Criar pasta de destino se não existir
if (-not (Test-Path $DestDir)) {
    Write-Host "Criando pasta de destino: $DestDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
}

# Contador de repositórios processados
$count = 0
$success = 0
$failed = 0

Write-Host "Iniciando clonagem dos repositórios..." -ForegroundColor Green
Write-Host "Pasta de destino: $DestDir" -ForegroundColor Cyan
Write-Host "----------------------------------------"

# Ler o arquivo CSV
$csvContent = Import-Csv -Path $csvFile -Delimiter ";"

foreach ($row in $csvContent) {
    # Pular linhas vazias
    if ([string]::IsNullOrEmpty($row.URL)) {
        continue
    }
    
    $count++
    
    # Extrair o nome do repositório da URL
    $repoName = [System.IO.Path]::GetFileNameWithoutExtension($row.URL)
    
    # Caminho completo do repositório
    $repoPath = Join-Path $DestDir $repoName
    
    Write-Host "[$count] Clonando: $($row.Nome)" -ForegroundColor White
    Write-Host "URL: $($row.URL)" -ForegroundColor Gray
    Write-Host "Destino: $repoPath" -ForegroundColor Gray
    
    # Verificar se o repositório já existe
    if (Test-Path $repoPath) {
        Write-Host "⚠️  Repositório já existe, pulando..." -ForegroundColor Yellow
        Write-Host "----------------------------------------"
        continue
    }
    
    # Clonar o repositório
    try {
        $gitResult = git clone $row.URL $repoPath 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Repositório clonado com sucesso!" -ForegroundColor Green
            $success++
        } else {
            Write-Host "❌ Erro ao clonar repositório" -ForegroundColor Red
            Write-Host "Erro: $gitResult" -ForegroundColor Red
            $failed++
        }
    } catch {
        Write-Host "❌ Erro ao clonar repositório" -ForegroundColor Red
        Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
        $failed++
    }
    
    Write-Host "----------------------------------------"
}

Write-Host ""
Write-Host "Resumo da operação:" -ForegroundColor Cyan
Write-Host "Total de repositórios processados: $count" -ForegroundColor White
Write-Host "Clonados com sucesso: $success" -ForegroundColor Green
Write-Host "Falhas: $failed" -ForegroundColor Red
Write-Host ""
Write-Host "Repositórios salvos em: $DestDir" -ForegroundColor Cyan
