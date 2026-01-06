# 📥 Guía de Instalación - Ultimate IPTV 2026

Esta guía te llevará paso a paso por el proceso de instalación de Ultimate IPTV 2026 en tu dispositivo Roku.

## 📋 Tabla de Contenidos

- [Requisitos](#-requisitos)
- [Preparación del Dispositivo Roku](#-preparación-del-dispositivo-roku)
- [Métodos de Instalación](#-métodos-de-instalación)
- [Post-Instalación](#-post-instalación)
- [Solución de Problemas](#-solución-de-problemas)

## ✅ Requisitos

### Hardware Necesario

- **Dispositivo Roku** (cualquier modelo compatible):
  - Roku Express
  - Roku Streaming Stick
  - Roku Premiere
  - Roku Ultra
  - Roku TV
  
- **Red WiFi o Ethernet** estable
- **Computadora** en la misma red que el Roku
- **Control remoto Roku** (original o app móvil)

### Software Necesario

- Navegador web moderno (Chrome, Firefox, Edge, Safari)
- Editor de texto (opcional, para desarrollo)
- Herramienta de compresión ZIP

### Conocimientos Previos

- ✅ Nivel Básico: Para instalación desde ZIP
- ⚙️ Nivel Medio: Para instalación con herramientas de desarrollo
- 🔧 Nivel Avanzado: Para modificación del código

## 🔧 Preparación del Dispositivo Roku

### Paso 1: Habilitar el Modo Desarrollador

El modo desarrollador permite instalar aplicaciones personalizadas en tu Roku.

1. **Acceder al Menú Secreto**:
   
   En tu control remoto Roku, presiona la siguiente secuencia:
   ```
   Home (3 veces rápido)
   Up (2 veces)
   Right
   Left
   Right
   Left
   Right
   ```
   
   > 💡 **Tip**: Si no funciona, asegúrate de estar en la pantalla principal y presiona los botones más lentamente.

2. **Pantalla de Configuración**:
   
   Aparecerá una pantalla titulada "Developer Settings" o "Configuración de Desarrollador"

3. **Habilitar el Installer**:
   
   - Selecciona "Enable Installer" o "Habilitar Instalador"
   - Marca la casilla para habilitarlo
   - Acepta los términos y condiciones

4. **Configurar Contraseña**:
   
   - Crea una contraseña de desarrollador
   - Esta contraseña será requerida para instalar apps
   - **⚠️ Importante**: Anota esta contraseña, la necesitarás después

5. **Reiniciar el Roku**:
   
   - Selecciona "Restart" o reinicia manualmente
   - Espera a que el dispositivo se reinicie completamente

### Paso 2: Obtener la Dirección IP del Roku

1. **Navegar a Configuración**:
   ```
   Home → Settings → Network → About
   ```
   O en español:
   ```
   Inicio → Configuración → Red → Acerca de
   ```

2. **Anotar la Dirección IP**:
   
   Verás algo como:
   ```
   IP Address: 192.168.1.100
   ```
   
   **✏️ Anota esta IP**, la necesitarás para la instalación.

### Paso 3: Verificar la Conexión

1. **Asegurar Misma Red**:
   
   Tu computadora y el Roku deben estar en la misma red WiFi o conectados al mismo router.

2. **Probar Conexión**:
   
   Desde tu computadora, abre un navegador y ve a:
   ```
   http://192.168.1.100
   ```
   (Reemplaza con la IP de tu Roku)
   
   Deberías ver la página "Roku Development Portal"

## 📦 Métodos de Instalación

### Método 1: Instalación desde ZIP (Recomendado para Usuarios)

#### Paso 1: Descargar el Proyecto

**Opción A - Desde GitHub Releases**:
1. Ve a la [página de releases](https://github.com/tu-usuario/ultimate-iptv-2026/releases)
2. Descarga el archivo `ultimate-iptv-2026-v1.2.1.zip`

**Opción B - Clonar el Repositorio**:
```bash
git clone https://github.com/tu-usuario/ultimate-iptv-2026.git
cd ultimate-iptv-2026
```

#### Paso 2: Crear el Archivo ZIP (si clonaste)

Si descargaste desde releases, salta este paso.

**En Windows**:
```powershell
# Desde la carpeta del proyecto
Compress-Archive -Path * -DestinationPath ultimate-iptv-2026.zip
```

**En Mac/Linux**:
```bash
zip -r ultimate-iptv-2026.zip . -x "*.git*" -x "*.md" -x ".DS_Store"
```

#### Paso 3: Subir a Roku

1. **Abrir el Portal de Desarrollo**:
   ```
   http://[IP-DE-TU-ROKU]
   ```

2. **Iniciar Sesión**:
   - Usuario: `rokudev` (predeterminado)
   - Contraseña: La que configuraste en el modo desarrollador

3. **Ir a "Development Application Installer"**:
   
   Encontrarás esta sección en la página principal.

4. **Subir el ZIP**:
   - Haz clic en "Browse" o "Examinar"
   - Selecciona el archivo `ultimate-iptv-2026.zip`
   - Haz clic en "Install" o "Instalar"

5. **Esperar la Instalación**:
   
   Verás un progreso de:
   - Uploading (Subiendo)
   - Installing (Instalando)
   - Success (Éxito)

6. **¡Listo!**:
   
   La app se instalará y se iniciará automáticamente.

### Método 2: Instalación con VS Code (Para Desarrolladores)

#### Paso 1: Instalar VS Code y Extensiones

1. **Descargar VS Code**:
   - Ve a [code.visualstudio.com](https://code.visualstudio.com/)
   - Descarga e instala

2. **Instalar Extensión BrightScript**:
   - Abre VS Code
   - Ve a Extensions (Ctrl+Shift+X)
   - Busca "BrightScript Language"
   - Instala la extensión de RokuCommunity

#### Paso 2: Configurar el Proyecto

1. **Abrir la Carpeta del Proyecto**:
   ```
   File → Open Folder → Selecciona la carpeta roku/
   ```

2. **Crear Archivo de Configuración**:
   
   Crea `.vscode/launch.json`:
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "type": "brightscript",
         "request": "launch",
         "name": "Launch on Roku",
         "host": "192.168.1.100",
         "password": "tu-contraseña-dev",
         "rootDir": "${workspaceFolder}",
         "stopOnEntry": false
       }
     ]
   }
   ```

3. **Actualizar Valores**:
   - Reemplaza `192.168.1.100` con la IP de tu Roku
   - Reemplaza `tu-contraseña-dev` con tu contraseña

#### Paso 3: Deploy con Un Click

1. **Presiona F5** o ve a `Run → Start Debugging`
2. La extensión automáticamente:
   - Empaqueta el proyecto
   - Sube el ZIP al Roku
   - Instala la aplicación
   - Inicia el debugger

### Método 3: Instalación con curl (Avanzado)

Para automatización o scripts:

```bash
#!/bin/bash

ROKU_IP="192.168.1.100"
ROKU_PASSWORD="tu-contraseña"
ZIP_FILE="ultimate-iptv-2026.zip"

curl -u "rokudev:${ROKU_PASSWORD}" \
     -F "mysubmit=Install" \
     -F "archive=@${ZIP_FILE}" \
     http://${ROKU_IP}/plugin_install
```

## ✨ Post-Instalación

### Primera Ejecución

1. **Localizar la App**:
   
   La app aparecerá en tu pantalla principal de Roku con el nombre:
   ```
   Ultimate IPTV 2026
   ```

2. **Iniciar la Aplicación**:
   
   Selecciona el ícono y presiona OK.

3. **Pantalla de Bienvenida**:
   
   Verás la pantalla principal con:
   - Opción para agregar listas
   - Menú lateral
   - Vista de listas vacía

### Configuración Inicial

#### Agregar Tu Primera Lista IPTV

1. **Abrir el Menú Lateral**:
   - Presiona el botón **◀️ Back** o navega a la izquierda

2. **Seleccionar "Agregar Lista"**:
   - Usa las flechas para navegar
   - Presiona OK

3. **Ingresar URL de la Lista**:
   ```
   Ejemplo:
   http://ejemplo.com/lista.m3u
   ```

4. **Asignar un Nombre**:
   ```
   Ejemplo:
   Mis Canales Favoritos
   ```

5. **Confirmar**:
   - Presiona OK
   - Espera a que la lista se cargue

#### Configurar Ajustes

1. **Ir a Configuración**:
   - Menú lateral → Configuración

2. **Opciones Disponibles**:
   - 🎯 Autoplay: Reproducción automática
   - 🗂️ Cache: Limpiar caché de imágenes
   - 📊 Analytics: Habilitar/deshabilitar

## 🔍 Verificación de la Instalación

### Checklist Post-Instalación

- [ ] La app aparece en la pantalla principal
- [ ] Se puede abrir sin errores
- [ ] El menú lateral responde
- [ ] Se puede agregar una lista IPTV
- [ ] Los canales se cargan correctamente
- [ ] La reproducción de video funciona
- [ ] Los favoritos se pueden marcar

### Verificar Logs (Opcional)

Para desarrolladores que quieran verificar logs:

1. **Habilitar Telnet en el Roku**:
   ```
   Settings → System → Advanced system settings → Developer options → Telnet
   ```

2. **Conectar vía Telnet**:
   ```bash
   telnet [IP-DEL-ROKU] 8085
   ```

3. **Ver Logs en Tiempo Real**:
   Los mensajes `print` del código aparecerán aquí.

## 🐛 Solución de Problemas

### Problema: No Puedo Acceder al Modo Desarrollador

**Solución**:
- Asegúrate de estar en la pantalla HOME
- Presiona la secuencia más lentamente
- Verifica que tu Roku esté actualizado
- Algunos modelos muy antiguos pueden no soportarlo

### Problema: No Aparece la Página del Desarrollador

**Solución**:
- Verifica que la IP sea correcta
- Asegúrate de estar en la misma red
- Intenta reiniciar el Roku
- Verifica que el modo desarrollador esté habilitado
- Prueba con `http://` no `https://`

### Problema: Error al Subir el ZIP

**Posibles Causas y Soluciones**:

1. **Archivo ZIP Corrupto**:
   ```bash
   # Verifica el ZIP
   unzip -t ultimate-iptv-2026.zip
   ```

2. **Contraseña Incorrecta**:
   - Reingresa la contraseña cuidadosamente
   - Considera restablecerla desde el modo desarrollador

3. **Archivo Demasiado Grande**:
   - Elimina archivos innecesarios (backups, .DS_Store, etc.)
   - El límite es ~4MB para apps básicas

### Problema: La App se Cierra al Iniciar

**Solución**:
- Revisa los logs vía telnet
- Verifica que todas las imágenes requeridas existan
- Asegúrate de que el manifest sea válido
- Reinstala la aplicación

### Problema: No Carga las Listas M3U

**Solución**:
- Verifica que la URL sea accesible desde el navegador
- Comprueba que el formato sea M3U válido
- Asegura que el Roku tenga conexión a internet
- Prueba con una lista más pequeña primero

### Problema: Los Iconos No Aparecen

**Solución**:
- Lee [images/README_MISSING_ICONS.md](images/README_MISSING_ICONS.md)
- Agrega los archivos PNG faltantes
- Recompila y reinstala

## 🔄 Actualización de la App

### Actualizar a una Nueva Versión

1. **Descargar la Nueva Versión**:
   - Obtén el nuevo ZIP de releases

2. **Desinstalar la Versión Anterior**:
   ```
   Portal Web → Delete → Confirm
   ```

3. **Instalar la Nueva Versión**:
   - Sigue el proceso de instalación normal
   - Tus datos persistirán (listas, favoritos)

### Mantener Configuración

Los datos se guardan en el registro del Roku y se mantendrán entre instalaciones:
- ✅ Listas IPTV guardadas
- ✅ Canales favoritos
- ✅ Configuración de la app

## 📱 Instalación en Múltiples Rokus

Si tienes varios dispositivos Roku:

1. **Habilita el modo desarrollador en cada uno**
2. **Anota las IPs de todos**
3. **Instala en cada uno individualmente**

O usa un script:
```bash
#!/bin/bash
ROKUS=("192.168.1.100" "192.168.1.101" "192.168.1.102")
PASSWORD="tu-contraseña"

for roku in "${ROKUS[@]}"
do
    echo "Installing on $roku..."
    curl -u "rokudev:${PASSWORD}" \
         -F "mysubmit=Install" \
         -F "archive=@ultimate-iptv-2026.zip" \
         http://${roku}/plugin_install
done
```

## 🎓 Recursos Adicionales

### Documentación Oficial de Roku

- [Guía del Desarrollador](https://developer.roku.com/docs/)
- [Developer Setup](https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md)
- [Sideloading Channels](https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md#step-2-accessing-the-development-application-installer)

### Videos Tutoriales

- [Cómo habilitar el modo desarrollador en Roku](https://www.youtube.com/results?search_query=roku+developer+mode)
- [Installing Roku Apps for Development](https://www.youtube.com/results?search_query=roku+sideload+app)

## ❓ ¿Necesitas Ayuda?

Si tienes problemas:

1. 📖 Lee la sección de [Solución de Problemas](#-solución-de-problemas)
2. 🔍 Busca en [Issues existentes](https://github.com/tu-usuario/ultimate-iptv-2026/issues)
3. 🐛 [Reporta un nuevo bug](https://github.com/tu-usuario/ultimate-iptv-2026/issues/new)
4. 💬 Contacta al soporte de la comunidad

---

**¡Disfruta de Ultimate IPTV 2026! 📺✨**
