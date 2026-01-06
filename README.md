# Ultimate IPTV 2026 📺

<div align="center">

![Roku](https://img.shields.io/badge/Platform-Roku-6f1ab1?style=for-the-badge&logo=roku)
![Version](https://img.shields.io/badge/Version-1.2.1-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![BrightScript](https://img.shields.io/badge/BrightScript-SceneGraph-purple?style=for-the-badge)

### Sistema Profesional Multi-Lista IPTV para Roku

Una aplicación completa de IPTV con gestión de múltiples listas M3U, favoritos globales, búsqueda avanzada y reproducción optimizada.

[Características](#-características) • [Instalación](#-instalación) • [Uso](#-uso) • [Desarrollo](#-desarrollo) • [Licencia](#-licencia)

</div>

---

## 🌟 Características

### 📋 Gestión Multi-Lista
- **Múltiples Fuentes IPTV**: Agrega y gestiona ilimitadas listas M3U/M3U8
- **URLs y Archivos Locales**: Soporte para listas remotas y locales
- **Persistencia Automática**: Las listas se guardan en el registro del dispositivo
- **Edición y Eliminación**: Gestión completa de tus playlists

### ⭐ Sistema de Favoritos Globales
- **Favoritos Centralizados**: Marca canales de cualquier lista como favoritos
- **Acceso Rápido**: Vista dedicada de todos tus canales favoritos
- **Persistencia**: Los favoritos se mantienen entre sesiones
- **Gestión Fácil**: Añade o elimina favoritos con un botón

### 🔍 Búsqueda Avanzada
- **Búsqueda Global**: Busca en todas las listas simultáneamente
- **Búsqueda por Lista**: Filtra canales dentro de una lista específica
- **Resultados en Tiempo Real**: Filtrado instantáneo mientras escribes
- **Teclado Virtual**: Interfaz amigable para entrada de texto

### 📺 Reproductor de Video Profesional
- **Reproducción Optimizada**: Player dedicado con controles completos
- **Buffering Inteligente**: Manejo automático de buffer y reconexión
- **Información en Pantalla**: Título del canal y estado de reproducción
- **Control Total**: Play, pause, seek y controles de navegación

### 🎨 Interfaz Moderna
- **Diseño Responsive**: Adaptado para resoluciones FHD
- **Sidebar Expandible**: Navegación intuitiva con iconos y texto
- **Animaciones Suaves**: Transiciones fluidas entre vistas
- **Esqueletos de Carga**: Feedback visual durante la carga

### ⚙️ Sistema de Configuración
- **Panel de Ajustes**: Configuración centralizada de la aplicación
- **Gestión de Caché**: Control del sistema de almacenamiento en caché
- **Analytics**: Sistema de seguimiento de uso (opcional)
- **Debug Mode**: Herramientas de depuración para desarrolladores

## 📁 Estructura del Proyecto

```
roku/
├── manifest                        # Configuración de la aplicación
├── source/                         # Código fuente BrightScript
│   ├── Main.brs                   # Punto de entrada
│   ├── Utils.brs                  # Utilidades generales
│   ├── RegistryManager.brs        # Gestión del registro
│   ├── SettingsManager.brs        # Gestión de configuración
│   ├── CacheManager.brs           # Sistema de caché
│   └── AnalyticsManager.brs       # Analytics y métricas
├── components/                     # Componentes SceneGraph
│   ├── MainScene.xml/brs          # Escena principal
│   ├── VideoPlayer.xml/brs        # Reproductor de video
│   ├── SidebarMenu.xml/brs        # Menú lateral
│   ├── SearchDialog.xml/brs       # Diálogo de búsqueda
│   ├── SettingsDialog.xml/brs     # Diálogo de configuración
│   ├── M3ULoaderTask.xml/brs      # Carga asíncrona de M3U
│   ├── ChannelCard.xml/brs        # Card de canal
│   ├── PlaylistCard.xml/brs       # Card de playlist
│   ├── SkeletonCard.xml/brs       # Card de carga
│   └── ...                         # Otros componentes
└── images/                         # Recursos gráficos
    └── README_MISSING_ICONS.md    # Guía de iconos faltantes
```

## 🚀 Instalación

### Prerrequisitos

- **Roku Device**: Cualquier dispositivo Roku con modo desarrollador habilitado
- **Network**: Roku y tu computadora en la misma red
- **Tools**: Editor de texto para configuración

### Configuración del Dispositivo Roku

1. **Habilitar Modo Desarrollador**:
   - Presiona en el control remoto: `Home 3×, Up 2×, Right, Left, Right, Left, Right`
   - Configura una contraseña de desarrollador
   - Reinicia tu Roku

2. **Obtener la IP del Roku**:
   - Ve a `Settings > Network > About`
   - Anota la dirección IP

### Instalación de la Aplicación

#### Opción 1: Usando la Interfaz Web

1. Abre un navegador y ve a `http://[IP-DE-TU-ROKU]`
2. Ingresa tu usuario y contraseña de desarrollador
3. Ve a la sección "Development Application Installer"
4. Comprime el proyecto completo en un archivo ZIP
5. Sube el archivo ZIP y haz clic en "Install"

#### Opción 2: Usando Roku Plugin para VS Code

```bash
# Instala la extensión de Roku para VS Code
# Configura la IP de tu Roku en settings.json
# Presiona F5 para deployar automáticamente
```

## 📖 Uso

### Primera Configuración

1. **Agregar una Lista IPTV**:
   - Abre la aplicación
   - Ve al menú lateral (presiona ◀️)
   - Selecciona "Agregar Lista"
   - Ingresa la URL de tu lista M3U
   - Asigna un nombre a la lista
   - Presiona OK

2. **Ver Canales**:
   - Selecciona una lista de la pantalla de inicio
   - Explora los canales disponibles
   - Presiona OK en un canal para reproducirlo

### Funciones Principales

#### Agregar a Favoritos
- Mientras ves un canal, presiona `★` (Star/Asterisk) en el control remoto
- El canal se agregará a tu lista de favoritos globales

#### Buscar Canales
- Ve al menú lateral
- Selecciona "Buscar"
- Ingresa el nombre del canal
- Selecciona de los resultados

#### Gestionar Configuración
- Ve al menú lateral
- Selecciona "Configuración"
- Ajusta las opciones según tus preferencias

### Atajos del Control Remoto

| Botón | Función |
|-------|---------|
| **OK** | Seleccionar/Reproducir |
| **◀️ Back** | Volver/Salir del player |
| **⏯️ Play/Pause** | Pausar/Reanudar reproducción |
| **★ Star** | Agregar/Remover de favoritos |
| **⏪ Rewind** | Retroceder 10 segundos |
| **⏩ Fast Forward** | Avanzar 10 segundos |
| **🏠 Home** | Salir de la aplicación |

## 🛠️ Desarrollo

### Tecnologías Utilizadas

- **BrightScript**: Lenguaje de programación de Roku
- **SceneGraph**: Framework de UI de Roku
- **RSG Components**: Componentes personalizados reutilizables
- **Task Nodes**: Procesamiento asíncrono
- **Registry API**: Almacenamiento persistente

### Arquitectura

La aplicación sigue una arquitectura modular basada en componentes:

- **Managers**: Lógica de negocio (Registry, Settings, Cache, Analytics)
- **Components**: Componentes UI reutilizables (Cards, Dialogs, Menus)
- **Tasks**: Operaciones asíncronas (Carga de M3U)
- **Utils**: Funciones auxiliares compartidas

### Características Técnicas

- ✅ **Async Loading**: Carga de listas M3U en background
- ✅ **Error Handling**: Manejo robusto de errores de red y parsing
- ✅ **Memory Management**: Optimización de memoria para listas grandes
- ✅ **Responsive Design**: Adaptación a diferentes resoluciones
- ✅ **State Management**: Gestión centralizada del estado
- ✅ **Cache System**: Sistema de caché para mejorar performance

### Configuración de Desarrollo

1. **Clonar el Repositorio**:
```bash
git clone https://github.com/metatech-programmer/ultimate-iptv-2026.git
cd ultimate-iptv-2026
```

2. **Configurar el Manifest**:
   - Edita el archivo `manifest` según tus necesidades
   - Ajusta el título, versión y configuración

3. **Desarrollo Local**:
   - Usa VS Code con la extensión BrightScript Language
   - Configura la IP de tu Roku para deploy automático
   - Utiliza el debugger integrado

### Testing

```bash
# Deploy para testing
# Desde la carpeta del proyecto
zip -r ultimate-iptv.zip . -x "*.git*" -x "*.md"
# Sube el ZIP a http://[ROKU-IP]
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor, lee [CONTRIBUTING.md](CONTRIBUTING.md) para más detalles.

### Proceso de Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Changelog

### Version 1.2.1 (Actual)
- ✅ Sistema multi-lista completamente funcional
- ✅ Favoritos globales implementados
- ✅ Búsqueda avanzada en todas las listas
- ✅ Reproductor de video optimizado
- ✅ Sidebar con navegación mejorada
- ✅ Sistema de configuración completo
- ✅ Cache manager integrado
- ✅ Skeleton screens para mejor UX

## 🐛 Problemas Conocidos

- Los iconos del sidebar requieren archivos PNG (ver [images/README_MISSING_ICONS.md](images/README_MISSING_ICONS.md))
- Algunas streams con protección DRM no son compatibles
- La búsqueda puede ser lenta con listas muy grandes (>5000 canales)

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👤 Autor

**Tu Nombre**
- GitHub: [@metatech](https://github.com/metatech-programmer)

## 🙏 Agradecimientos

- Comunidad de desarrolladores de Roku
- Contribuidores del proyecto
- Usuarios que reportan bugs y sugieren mejoras

## 📞 Soporte

Si tienes problemas o preguntas:
- 🐛 [Reportar un Bug](https://github.com/metatech-programmer/ultimate-iptv-2026/issues)
- 💡 [Solicitar una Feature](https://github.com/metatech-programmer/ultimate-iptv-2026/issues)
- 📧 Contacto: santiagoaguilart0@gmail.com

---

<div align="center">

**⭐ Si te gusta este proyecto, dale una estrella en GitHub ⭐**

Hecho con ❤️ para la comunidad Roku

</div>
#   i p t v _ r o k u _ a p p  
 