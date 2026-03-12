# Script de test pour l'importation CSV
# Exécute les tests unitaires et génère un rapport

param(
    [switch]$Coverage,
    [switch]$Verbose,
    [switch]$Watch,
    [string]$Specific
)

Write-Host "🧪 Tests Unitaires - Import CSV Revato" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Navigation vers le dossier du projet
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectPath = Split-Path -Parent $scriptPath
Set-Location $projectPath

# Vérifier que Flutter est installé
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter n'est pas installé ou pas dans le PATH" -ForegroundColor Red
    exit 1
}

# Construction de la commande
$command = "flutter test"

if ($Specific) {
    Write-Host "🎯 Exécution des tests: $Specific" -ForegroundColor Yellow
    $command += " $Specific"
} else {
    Write-Host "🎯 Exécution de tous les tests d'import" -ForegroundColor Yellow
    $command += " test/services/business/dream_business_service_test.dart test/services/utils/import_service_test.dart"
}

if ($Coverage) {
    Write-Host "📊 Génération du coverage activée" -ForegroundColor Yellow
    $command += " --coverage"
}

if ($Verbose) {
    Write-Host "📝 Mode verbose activé" -ForegroundColor Yellow
    $command += " --verbose"
}

if ($Watch) {
    Write-Host "👀 Mode watch activé (redémarre à chaque changement)" -ForegroundColor Yellow
    # Note: flutter test ne supporte pas --watch nativement
    # On utilise une boucle avec file watcher
    Write-Host "⚠️  Le mode watch nécessite l'installation de 'watchexec'" -ForegroundColor Yellow
    Write-Host "    Installer avec: choco install watchexec" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "▶️  Lancement des tests..." -ForegroundColor Green
Write-Host ""

# Exécution des tests
Invoke-Expression $command
$testResult = $LASTEXITCODE

Write-Host ""

# Analyse du résultat
if ($testResult -eq 0) {
    Write-Host "✅ Tous les tests sont passés avec succès!" -ForegroundColor Green
    
    if ($Coverage) {
        Write-Host ""
        Write-Host "📊 Génération du rapport HTML..." -ForegroundColor Cyan
        
        # Vérifier si genhtml est disponible
        if (Get-Command genhtml -ErrorAction SilentlyContinue) {
            $coverageOut = "coverage/html"
            New-Item -ItemType Directory -Force -Path $coverageOut | Out-Null
            genhtml coverage/lcov.info -o $coverageOut
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Rapport généré dans: $coverageOut/index.html" -ForegroundColor Green
                Write-Host ""
                
                $openReport = Read-Host "Voulez-vous ouvrir le rapport? (o/N)"
                if ($openReport -eq "o" -or $openReport -eq "O") {
                    Start-Process "$coverageOut/index.html"
                }
            } else {
                Write-Host "⚠️  Erreur lors de la génération du rapport HTML" -ForegroundColor Yellow
            }
        } else {
            Write-Host "⚠️  genhtml non trouvé. Installez lcov pour générer le rapport HTML" -ForegroundColor Yellow
            Write-Host "    Sous Windows avec chocolatey: choco install lcov" -ForegroundColor Gray
            Write-Host ""
            Write-Host "📄 Fichier coverage brut disponible: coverage/lcov.info" -ForegroundColor Cyan
        }
    }
} else {
    Write-Host "❌ Des tests ont échoué!" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Conseils:" -ForegroundColor Yellow
    Write-Host "   - Vérifiez les messages d'erreur ci-dessus" -ForegroundColor Gray
    Write-Host "   - Relancez avec -Verbose pour plus de détails" -ForegroundColor Gray
    Write-Host "   - Vérifiez que les dépendances sont à jour: flutter pub get" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "📚 Pour plus d'informations, consultez:" -ForegroundColor Cyan
Write-Host "   docs/TESTS_IMPORT_CSV.md" -ForegroundColor Gray
Write-Host ""

# Statistiques rapides
Write-Host "📈 Statistiques:" -ForegroundColor Cyan
$testFiles = @(
    "test/services/business/dream_business_service_test.dart",
    "test/services/utils/import_service_test.dart"
)

foreach ($file in $testFiles) {
    if (Test-Path $file) {
        $lines = (Get-Content $file | Measure-Object -Line).Lines
        $tests = (Select-String -Path $file -Pattern "\s+test\(" | Measure-Object).Count
        Write-Host "   $file" -ForegroundColor Gray
        Write-Host "     → $lines lignes, $tests tests" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "✨ Fait!" -ForegroundColor Green
