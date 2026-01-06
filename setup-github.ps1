# Script de Preparación para GitHub
# Este script te ayuda a preparar el repositorio antes de subirlo

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Ultimate IPTV 2026 - GitHub Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si Git está instalado
Write-Host "📋 Verificando requisitos..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "✅ Git instalado: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git no está instalado" -ForegroundColor Red
    Write-Host "   Descárgalo de: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "📁 Verificando archivos de documentación..." -ForegroundColor Yellow

$docs = @(
    "README.md",
    "LICENSE",
    ".gitignore",
    "CONTRIBUTING.md",
    "INSTALLATION.md",
    "FEATURES.md",
    "ARCHITECTURE.md",
    "CHANGELOG.md",
    "CODE_OF_CONDUCT.md",
    "SECURITY.md",
    "GITHUB_SETUP.md",
    "DOCS_INDEX.md"
)

$allFound = $true
foreach ($doc in $docs) {
    if (Test-Path $doc) {
        Write-Host "✅ $doc" -ForegroundColor Green
    } else {
        Write-Host "❌ $doc" -ForegroundColor Red
        $allFound = $false
    }
}

if (-not $allFound) {
    Write-Host ""
    Write-Host "⚠️  Faltan algunos archivos de documentación" -ForegroundColor Yellow
    Write-Host "   Asegúrate de tener todos los archivos necesarios" -ForegroundColor Yellow
    $continue = Read-Host "¿Continuar de todos modos? (s/n)"
    if ($continue -ne "s") {
        exit
    }
}

Write-Host ""
Write-Host "🔧 Configuración de Git" -ForegroundColor Yellow
Write-Host ""

# Verificar configuración de Git
$gitUser = git config --global user.name
$gitEmail = git config --global user.email

if ([string]::IsNullOrWhiteSpace($gitUser) -or [string]::IsNullOrWhiteSpace($gitEmail)) {
    Write-Host "⚙️  Necesitas configurar Git primero" -ForegroundColor Yellow
    Write-Host ""
    
    $userName = Read-Host "Ingresa tu nombre"
    $userEmail = Read-Host "Ingresa tu email"
    
    git config --global user.name "$userName"
    git config --global user.email "$userEmail"
    
    Write-Host ""
    Write-Host "✅ Git configurado correctamente" -ForegroundColor Green
} else {
    Write-Host "Usuario Git: $gitUser" -ForegroundColor Cyan
    Write-Host "Email Git: $gitEmail" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "📝 Personalización del README" -ForegroundColor Yellow
Write-Host ""
Write-Host "Antes de subir a GitHub, debes personalizar algunos datos:" -ForegroundColor White
Write-Host "1. Abre README.md" -ForegroundColor White
Write-Host "2. Busca y reemplaza:" -ForegroundColor White
Write-Host "   - 'tu-usuario' → Tu usuario de GitHub" -ForegroundColor White
Write-Host "   - 'Tu Nombre' → Tu nombre real" -ForegroundColor White
Write-Host "   - 'tu-email@ejemplo.com' → Tu email" -ForegroundColor White
Write-Host ""

$personalized = Read-Host "¿Ya personalizaste el README.md? (s/n)"
if ($personalized -ne "s") {
    Write-Host ""
    Write-Host "⚠️  Por favor personaliza el README.md antes de continuar" -ForegroundColor Yellow
    Write-Host "   Luego ejecuta este script nuevamente" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit
}

Write-Host ""
Write-Host "🚀 Preparando repositorio Git" -ForegroundColor Yellow
Write-Host ""

# Verificar si ya existe un repo
if (Test-Path ".git") {
    Write-Host "⚠️  Ya existe un repositorio Git en esta carpeta" -ForegroundColor Yellow
    $reinit = Read-Host "¿Quieres reinicializarlo? (s/n)"
    if ($reinit -eq "s") {
        Remove-Item -Recurse -Force .git
        Write-Host "✅ Repositorio anterior eliminado" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Usando repositorio existente" -ForegroundColor Cyan
        exit
    }
}

# Inicializar repositorio
Write-Host "Inicializando repositorio Git..." -ForegroundColor Cyan
git init
git branch -M main

Write-Host "✅ Repositorio inicializado" -ForegroundColor Green
Write-Host ""

# Agregar archivos
Write-Host "📦 Agregando archivos al staging area..." -ForegroundColor Cyan
git add .

Write-Host "✅ Archivos agregados" -ForegroundColor Green
Write-Host ""

# Primer commit
Write-Host "💾 Creando commit inicial..." -ForegroundColor Cyan
git commit -m "🎉 Initial commit: Ultimate IPTV 2026 v1.2.1

- Sistema multi-lista IPTV completo
- Favoritos globales
- Búsqueda avanzada
- Reproductor profesional
- Documentación completa"

Write-Host "✅ Commit creado" -ForegroundColor Green
Write-Host ""

# Instrucciones finales
Write-Host "========================================" -ForegroundColor Green
Write-Host " ¡Preparación Completa! ✅" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Crea un repositorio en GitHub:" -ForegroundColor White
Write-Host "   https://github.com/new" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Ejecuta estos comandos (reemplaza TU-USUARIO):" -ForegroundColor White
Write-Host ""
Write-Host "   git remote add origin https://github.com/TU-USUARIO/ultimate-iptv-2026.git" -ForegroundColor Cyan
Write-Host "   git push -u origin main" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Visita tu repositorio en:" -ForegroundColor White
Write-Host "   https://github.com/TU-USUARIO/ultimate-iptv-2026" -ForegroundColor Cyan
Write-Host ""
Write-Host "📖 Para más detalles, lee: GITHUB_SETUP.md" -ForegroundColor Yellow
Write-Host ""

# Preguntar si quiere agregar el remote ahora
Write-Host "¿Quieres configurar el remote de GitHub ahora? (s/n)" -ForegroundColor Yellow
$configRemote = Read-Host

if ($configRemote -eq "s") {
    Write-Host ""
    $githubUser = Read-Host "Ingresa tu usuario de GitHub"
    $repoName = Read-Host "Ingresa el nombre del repositorio (default: ultimate-iptv-2026)"
    
    if ([string]::IsNullOrWhiteSpace($repoName)) {
        $repoName = "ultimate-iptv-2026"
    }
    
    $remoteUrl = "https://github.com/$githubUser/$repoName.git"
    
    Write-Host ""
    Write-Host "Configurando remote: $remoteUrl" -ForegroundColor Cyan
    git remote add origin $remoteUrl
    
    Write-Host "✅ Remote configurado" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ahora puedes ejecutar:" -ForegroundColor Yellow
    Write-Host "git push -u origin main" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "🎉 ¡Todo listo para subir a GitHub!" -ForegroundColor Green
Write-Host ""
pause
