# 🚀 Guía Rápida: Subir a GitHub

Esta guía te ayudará a subir **Ultimate IPTV 2026** a GitHub paso a paso.

## 📋 Pre-requisitos

- Cuenta de GitHub (crear en [github.com](https://github.com) si no tienes)
- Git instalado en tu computadora
- Terminal o Command Prompt

## ⚡ Pasos Rápidos

### 1. Instalar Git (si no lo tienes)

**Windows:**
```powershell
# Descargar de: https://git-scm.com/download/win
# O instalar con Chocolatey:
choco install git
```

**Mac:**
```bash
# Con Homebrew:
brew install git
```

**Linux:**
```bash
# Ubuntu/Debian:
sudo apt-get install git

# Fedora:
sudo dnf install git
```

### 2. Configurar Git (Primera vez)

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@ejemplo.com"
```

### 3. Crear Repositorio en GitHub

1. Ve a [github.com](https://github.com)
2. Haz clic en el botón **"+"** (arriba derecha) → **"New repository"**
3. Completa:
   - **Repository name**: `ultimate-iptv-2026` (o el que prefieras)
   - **Description**: `Sistema Profesional Multi-Lista IPTV para Roku`
   - **Public** o **Private**: Selecciona según tu preferencia
   - ⚠️ **NO** marques "Initialize this repository with a README"
4. Haz clic en **"Create repository"**

### 4. Subir tu Código

Abre una terminal en la carpeta de tu proyecto:

```bash
# Navegar a la carpeta del proyecto
cd "c:\workspace\2026-1\Nueva carpeta\roku"

# Inicializar repositorio Git
git init

# Agregar todos los archivos
git add .

# Hacer el primer commit
git commit -m "🎉 Initial commit: Ultimate IPTV 2026 v1.2.1"

# Configurar la rama principal como 'main'
git branch -M main

# Conectar con tu repositorio de GitHub
# Reemplaza TU-USUARIO con tu nombre de usuario de GitHub
git remote add origin https://github.com/TU-USUARIO/ultimate-iptv-2026.git

# Subir el código
git push -u origin main
```

### 5. Verificar

Ve a tu repositorio en GitHub: `https://github.com/TU-USUARIO/ultimate-iptv-2026`

¡Deberías ver todos tus archivos! 🎉

## 📁 Archivos Incluidos

Tu repositorio ahora incluye:

```
✅ README.md                    - Documentación principal
✅ LICENSE                      - Licencia MIT
✅ .gitignore                   - Archivos a ignorar
✅ CONTRIBUTING.md              - Guía de contribución
✅ INSTALLATION.md              - Guía de instalación
✅ FEATURES.md                  - Documentación de características
✅ ARCHITECTURE.md              - Arquitectura del código
✅ CHANGELOG.md                 - Historial de cambios
✅ CODE_OF_CONDUCT.md           - Código de conducta
✅ SECURITY.md                  - Política de seguridad
✅ .github/                     - Templates de GitHub
    ✅ PULL_REQUEST_TEMPLATE.md
    ✅ ISSUE_TEMPLATE/
        ✅ bug_report.md
        ✅ feature_request.md
```

## 🎨 Personalizar README.md

Antes de hacer público, actualiza estos datos en [README.md](README.md):

```markdown
# Buscar y reemplazar:
- "tu-usuario" → Tu nombre de usuario de GitHub
- "Tu Nombre" → Tu nombre real
- "tu-email@ejemplo.com" → Tu email de contacto
```

## 🏷️ Crear un Release

1. Ve a tu repositorio en GitHub
2. Haz clic en **"Releases"** → **"Create a new release"**
3. Completa:
   - **Tag**: `v1.2.1`
   - **Title**: `Ultimate IPTV 2026 v1.2.1 - Initial Release`
   - **Description**: Copia el contenido del CHANGELOG
4. Adjunta el archivo ZIP de la app (opcional)
5. Haz clic en **"Publish release"**

## 🔄 Actualizaciones Futuras

Cuando hagas cambios:

```bash
# Ver estado de los archivos
git status

# Agregar archivos modificados
git add .

# O agregar archivos específicos
git add archivo.brs

# Hacer commit con mensaje descriptivo
git commit -m "feat: agregar soporte para EPG"

# Subir cambios
git push
```

### Convenciones de Mensajes de Commit

```
feat: Nueva característica
fix: Corrección de bug
docs: Cambios en documentación
style: Formato de código
refactor: Refactorización
test: Tests
chore: Mantenimiento
```

## 🛠️ Comandos Útiles

```bash
# Ver historial de commits
git log --oneline

# Ver diferencias
git diff

# Ver ramas
git branch

# Crear nueva rama
git checkout -b nombre-rama

# Cambiar de rama
git checkout main

# Deshacer cambios no guardados
git checkout -- archivo.brs

# Ver remotes
git remote -v

# Actualizar desde GitHub
git pull
```

## ❌ Solución de Problemas

### "Permission denied (publickey)"

Configura autenticación con token personal:

1. Ve a GitHub → Settings → Developer settings → Personal access tokens
2. Genera un nuevo token
3. Usa el token como contraseña al hacer push

### "Failed to push some refs"

```bash
# Primero traer cambios remotos
git pull origin main --rebase

# Luego hacer push
git push origin main
```

### "Conflict" al hacer pull

```bash
# Ver archivos en conflicto
git status

# Editar archivos y resolver conflictos manualmente
# Luego:
git add .
git commit -m "resolve conflicts"
git push
```

## 📝 Próximos Pasos

1. ✅ Personaliza el README con tu información
2. ✅ Agrega un logo o banner al README
3. ✅ Crea tu primer release (v1.2.1)
4. ✅ Agrega topics a tu repo: `roku`, `iptv`, `brightscript`, `streaming`
5. ✅ Habilita GitHub Pages si quieres una página web
6. ✅ Configura GitHub Actions para CI/CD (opcional)

## 🌟 Hacer tu Repo Atractivo

### Agregar Topics

1. Ve a tu repositorio
2. Haz clic en el ícono de engranaje junto a "About"
3. Agrega topics:
   - `roku`
   - `iptv`
   - `brightscript`
   - `scenegraph`
   - `streaming`
   - `roku-channel`
   - `m3u`

### Agregar Descripción

En la misma sección "About":
- **Description**: `Sistema profesional multi-lista IPTV para Roku con favoritos globales y búsqueda avanzada`
- **Website**: Tu sitio web (opcional)

### Badge al README

Agrega badges al inicio de README.md (ya incluidos):
- Platform badge
- Version badge
- License badge

## 📞 ¿Necesitas Ayuda?

- 📖 [GitHub Docs](https://docs.github.com)
- 📖 [Git Documentation](https://git-scm.com/doc)
- 💬 [GitHub Community](https://github.community/)

---

**¡Listo para compartir tu proyecto con el mundo! 🚀**
