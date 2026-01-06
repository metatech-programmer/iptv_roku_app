#!/bin/bash

# Script de Preparación para GitHub (Linux/Mac)
# Este script te ayuda a preparar el repositorio antes de subirlo

echo ""
echo "========================================"
echo " Ultimate IPTV 2026 - GitHub Setup"
echo "========================================"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Verificar si Git está instalado
echo -e "${YELLOW}📋 Verificando requisitos...${NC}"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo -e "${GREEN}✅ Git instalado: $GIT_VERSION${NC}"
else
    echo -e "${RED}❌ Git no está instalado${NC}"
    echo -e "${YELLOW}   Instálalo con tu gestor de paquetes${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}📁 Verificando archivos de documentación...${NC}"

DOCS=(
    "README.md"
    "LICENSE"
    ".gitignore"
    "CONTRIBUTING.md"
    "INSTALLATION.md"
    "FEATURES.md"
    "ARCHITECTURE.md"
    "CHANGELOG.md"
    "CODE_OF_CONDUCT.md"
    "SECURITY.md"
    "GITHUB_SETUP.md"
    "DOCS_INDEX.md"
)

ALL_FOUND=true
for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "${GREEN}✅ $doc${NC}"
    else
        echo -e "${RED}❌ $doc${NC}"
        ALL_FOUND=false
    fi
done

if [ "$ALL_FOUND" = false ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Faltan algunos archivos de documentación${NC}"
    read -p "¿Continuar de todos modos? (s/n): " CONTINUE
    if [ "$CONTINUE" != "s" ]; then
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}🔧 Configuración de Git${NC}"
echo ""

# Verificar configuración de Git
GIT_USER=$(git config --global user.name)
GIT_EMAIL=$(git config --global user.email)

if [ -z "$GIT_USER" ] || [ -z "$GIT_EMAIL" ]; then
    echo -e "${YELLOW}⚙️  Necesitas configurar Git primero${NC}"
    echo ""
    
    read -p "Ingresa tu nombre: " USER_NAME
    read -p "Ingresa tu email: " USER_EMAIL
    
    git config --global user.name "$USER_NAME"
    git config --global user.email "$USER_EMAIL"
    
    echo ""
    echo -e "${GREEN}✅ Git configurado correctamente${NC}"
else
    echo -e "${CYAN}Usuario Git: $GIT_USER${NC}"
    echo -e "${CYAN}Email Git: $GIT_EMAIL${NC}"
fi

echo ""
echo -e "${YELLOW}📝 Personalización del README${NC}"
echo ""
echo "Antes de subir a GitHub, debes personalizar algunos datos:"
echo "1. Abre README.md"
echo "2. Busca y reemplaza:"
echo "   - 'tu-usuario' → Tu usuario de GitHub"
echo "   - 'Tu Nombre' → Tu nombre real"
echo "   - 'tu-email@ejemplo.com' → Tu email"
echo ""

read -p "¿Ya personalizaste el README.md? (s/n): " PERSONALIZED
if [ "$PERSONALIZED" != "s" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Por favor personaliza el README.md antes de continuar${NC}"
    echo "   Luego ejecuta este script nuevamente"
    echo ""
    exit 1
fi

echo ""
echo -e "${YELLOW}🚀 Preparando repositorio Git${NC}"
echo ""

# Verificar si ya existe un repo
if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Ya existe un repositorio Git en esta carpeta${NC}"
    read -p "¿Quieres reinicializarlo? (s/n): " REINIT
    if [ "$REINIT" = "s" ]; then
        rm -rf .git
        echo -e "${GREEN}✅ Repositorio anterior eliminado${NC}"
    else
        echo -e "${CYAN}ℹ️  Usando repositorio existente${NC}"
        exit 0
    fi
fi

# Inicializar repositorio
echo -e "${CYAN}Inicializando repositorio Git...${NC}"
git init
git branch -M main

echo -e "${GREEN}✅ Repositorio inicializado${NC}"
echo ""

# Agregar archivos
echo -e "${CYAN}📦 Agregando archivos al staging area...${NC}"
git add .

echo -e "${GREEN}✅ Archivos agregados${NC}"
echo ""

# Primer commit
echo -e "${CYAN}💾 Creando commit inicial...${NC}"
git commit -m "🎉 Initial commit: Ultimate IPTV 2026 v1.2.1

- Sistema multi-lista IPTV completo
- Favoritos globales
- Búsqueda avanzada
- Reproductor profesional
- Documentación completa"

echo -e "${GREEN}✅ Commit creado${NC}"
echo ""

# Instrucciones finales
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN} ¡Preparación Completa! ✅${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}📋 Próximos pasos:${NC}"
echo ""
echo "1. Crea un repositorio en GitHub:"
echo -e "   ${CYAN}https://github.com/new${NC}"
echo ""
echo "2. Ejecuta estos comandos (reemplaza TU-USUARIO):"
echo ""
echo -e "   ${CYAN}git remote add origin https://github.com/TU-USUARIO/ultimate-iptv-2026.git${NC}"
echo -e "   ${CYAN}git push -u origin main${NC}"
echo ""
echo "3. Visita tu repositorio en:"
echo -e "   ${CYAN}https://github.com/TU-USUARIO/ultimate-iptv-2026${NC}"
echo ""
echo -e "${YELLOW}📖 Para más detalles, lee: GITHUB_SETUP.md${NC}"
echo ""

# Preguntar si quiere agregar el remote ahora
read -p "¿Quieres configurar el remote de GitHub ahora? (s/n): " CONFIG_REMOTE

if [ "$CONFIG_REMOTE" = "s" ]; then
    echo ""
    read -p "Ingresa tu usuario de GitHub: " GITHUB_USER
    read -p "Ingresa el nombre del repositorio (default: ultimate-iptv-2026): " REPO_NAME
    
    if [ -z "$REPO_NAME" ]; then
        REPO_NAME="ultimate-iptv-2026"
    fi
    
    REMOTE_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"
    
    echo ""
    echo -e "${CYAN}Configurando remote: $REMOTE_URL${NC}"
    git remote add origin "$REMOTE_URL"
    
    echo -e "${GREEN}✅ Remote configurado${NC}"
    echo ""
    echo -e "${YELLOW}Ahora puedes ejecutar:${NC}"
    echo -e "${CYAN}git push -u origin main${NC}"
    echo ""
fi

echo -e "${GREEN}🎉 ¡Todo listo para subir a GitHub!${NC}"
echo ""
