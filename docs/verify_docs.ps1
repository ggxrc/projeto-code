# Verificador de Documentação

Este script PowerShell verifica se todos os arquivos de documentação estão presentes
e se os links entre eles funcionam corretamente.

## Como Usar:
1. No PowerShell, navegue até a pasta raiz do projeto
2. Execute: .\docs\verify_docs.ps1

#>

$ErrorActionPreference = "Stop"
$docsFolder = Join-Path $PSScriptRoot ".."
Write-Host "Verificando documentação no diretório: $docsFolder" -ForegroundColor Cyan

# Lista de arquivos de documentação que devem existir
$requiredDocs = @(
    "README.md",
    "docs\index.md",
    "docs\guia_instalacao.md",
    "docs\guia_contribuidores.md",
    "docs\sistema_dialogos.md",
    "docs\sistema_orquestrador.md",
    "docs\sistema_controle_jogador.md",
    "docs\sistema_interface_usuario.md",
    "docs\recursos_artisticos.md",
    "docs\testes_depuracao.md",
    "docs\fluxo_balanceamento.md"
)

# Verificar existência dos arquivos
$missingFiles = @()
foreach ($doc in $requiredDocs) {
    $fullPath = Join-Path $docsFolder $doc
    if (-not (Test-Path $fullPath)) {
        $missingFiles += $doc
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "ERRO: Os seguintes arquivos de documentação estão faltando:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Red
    }
} else {
    Write-Host "✓ Todos os arquivos de documentação necessários estão presentes." -ForegroundColor Green
}

# Verificar links entre documentos
Write-Host "`nVerificando links entre documentos..." -ForegroundColor Cyan

$brokenLinks = @()
$checkedFiles = @()

function Check-MarkdownLinks {
    param (
        [string]$filePath
    )
    
    if ($checkedFiles -contains $filePath) {
        return
    }
    
    $checkedFiles += $filePath
    $fileContent = Get-Content $filePath -Raw
    $directory = Split-Path $filePath
    
    # Encontrar links em markdown [texto](url)
    $linkPattern = '\[([^\]]+)\]\(([^)]+)\)'
    $matches = [regex]::Matches($fileContent, $linkPattern)
    
    foreach ($match in $matches) {
        $linkText = $match.Groups[1].Value
        $linkTarget = $match.Groups[2].Value
        
        # Ignorar URLs externas
        if ($linkTarget -match '^https?://') {
            continue
        }
        
        # Resolver caminho relativo
        $targetPath = $linkTarget
        if (-not [System.IO.Path]::IsPathRooted($targetPath)) {
            $targetPath = Join-Path $directory $linkTarget
        }
        
        # Normalizar caminho
        $targetPath = [System.IO.Path]::GetFullPath($targetPath)
        
        if (-not (Test-Path $targetPath)) {
            $brokenLinks += @{
                SourceFile = $filePath
                LinkText = $linkText
                LinkTarget = $linkTarget
            }
        } else {
            # Se o link for para um arquivo markdown, verificar recursivamente
            if ($targetPath -match '\.md$') {
                Check-MarkdownLinks -filePath $targetPath
            }
        }
    }
}

# Verificar links em cada arquivo
foreach ($doc in $requiredDocs) {
    $fullPath = Join-Path $docsFolder $doc
    if (Test-Path $fullPath) {
        Check-MarkdownLinks -filePath $fullPath
    }
}

if ($brokenLinks.Count -gt 0) {
    Write-Host "ERRO: Os seguintes links estão quebrados:" -ForegroundColor Red
    foreach ($link in $brokenLinks) {
        Write-Host "  - Arquivo: $($link.SourceFile)" -ForegroundColor Red
        Write-Host "    Link: [$($link.LinkText)]($($link.LinkTarget))" -ForegroundColor Red
    }
} else {
    Write-Host "✓ Todos os links entre documentos estão funcionando." -ForegroundColor Green
}

Write-Host "`nVerificação de documentação concluída!" -ForegroundColor Cyan
