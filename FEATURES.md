# 🌟 Características Detalladas - Ultimate IPTV 2026

Documentación completa de todas las características y funcionalidades de Ultimate IPTV 2026.

**Proyecto**: Ultimate IPTV 2026  
**Repositorio**: [metatech-programmer/iptv_roku_app](https://github.com/metatech-programmer/iptv_roku_app)  
**Autor**: Santiago Aguilar ([@metatech-programmer](https://github.com/metatech-programmer))  
**Versión**: 1.2.1

## 📋 Tabla de Contenidos

- [Gestión de Listas IPTV](#-gestión-de-listas-iptv)
- [Sistema de Favoritos](#-sistema-de-favoritos)
- [Búsqueda de Canales](#-búsqueda-de-canales)
- [Reproductor de Video](#-reproductor-de-video)
- [Interfaz de Usuario](#-interfaz-de-usuario)
- [Configuración y Ajustes](#️-configuración-y-ajustes)
- [Características Técnicas](#-características-técnicas)

---

## 📋 Gestión de Listas IPTV

### Agregar Listas

Ultimate IPTV 2026 permite gestionar múltiples listas IPTV simultáneamente.

#### Formatos Soportados

- **M3U**: Archivo de lista de reproducción estándar
- **M3U8**: Lista de reproducción UTF-8 (HLS)
- **URLs Remotas**: Listas alojadas en servidores web
- **Archivos Locales**: Listas almacenadas localmente (próximamente)

#### Proceso de Agregar Lista

1. **Navegación**: Menú lateral → "Agregar Lista"
2. **Entrada de Datos**:
   - URL de la lista (ej: `http://provider.com/playlist.m3u`)
   - Nombre personalizado (ej: "Mis Deportes")
3. **Validación**: Verificación automática del formato
4. **Carga**: Procesamiento asíncrono en segundo plano
5. **Confirmación**: Notificación de éxito o error

#### Características de Parsing

```brightscript
' Soporte completo de etiquetas M3U
#EXTM3U
#EXTINF:-1 tvg-id="canal1" tvg-name="Canal 1" tvg-logo="logo.png" group-title="Deportes",Canal Deportivo
http://stream.url/canal1
```

**Etiquetas Soportadas**:
- ✅ `tvg-id`: Identificador único del canal
- ✅ `tvg-name`: Nombre del canal
- ✅ `tvg-logo`: URL del logo/thumbnail
- ✅ `group-title`: Categoría del canal
- ✅ `tvg-country`: País del canal
- ✅ `tvg-language`: Idioma del canal

### Gestión de Listas

#### Ver Listas

- **Vista de Tarjetas**: Diseño visual con thumbnails
- **Información Rápida**: Nombre, número de canales, última actualización
- **Acceso Directo**: Un click para acceder a los canales

#### Editar Listas

- **Cambiar Nombre**: Personaliza el nombre de visualización
- **Actualizar URL**: Modifica la fuente de la lista
- **Recargar**: Fuerza una actualización de la lista

#### Eliminar Listas

- **Confirmación**: Diálogo de seguridad antes de eliminar
- **Limpieza Automática**: Elimina datos asociados del cache
- **Persistencia**: Los favoritos de esa lista se mantienen

### Organización por Categorías

Cuando una lista incluye categorías (`group-title`):

1. **Vista de Categorías**: Primera pantalla muestra las categorías
2. **Filtrado**: Solo muestra canales de la categoría seleccionada
3. **Navegación**: Fácil retorno a la vista de categorías

**Ejemplo de Estructura**:
```
Lista: "Mi IPTV"
├── Deportes (15 canales)
├── Noticias (8 canales)
├── Películas (45 canales)
└── Música (12 canales)
```

---

## ⭐ Sistema de Favoritos

### Favoritos Globales

A diferencia de otros reproductores, Ultimate IPTV 2026 usa un sistema de favoritos **global** que trasciende las listas individuales.

#### Características Principales

- **Centralizado**: Una sola vista para todos los favoritos
- **Multi-Lista**: Favoritos de diferentes listas en un solo lugar
- **Persistente**: Se mantienen incluso si eliminas/agregas listas
- **Rápido Acceso**: Dedicada vista en el menú principal

### Agregar a Favoritos

#### Método 1: Desde Vista de Canales
1. Navega al canal deseado
2. Presiona el botón **★ (Star)** en el control remoto
3. Confirmación visual instantánea

#### Método 2: Desde el Reproductor
1. Mientras reproduces un canal
2. Presiona el botón **★ (Star)**
3. El canal se agrega sin interrumpir la reproducción

### Gestionar Favoritos

#### Ver Favoritos
```
Home → Favoritos
```
Muestra todos los canales marcados con:
- Logo del canal
- Nombre del canal
- Lista de origen
- Indicador de favorito (★)

#### Eliminar de Favoritos
1. Navega al canal favorito
2. Presiona **★ (Star)** nuevamente
3. El favorito se elimina con confirmación visual

### Almacenamiento de Favoritos

Los favoritos se almacenan usando un identificador único compuesto:
```
favoriteID = channelURL + "|" + channelName
```

Esto permite:
- ✅ Identificación única por URL + nombre
- ✅ Soporte multi-lista
- ✅ Prevención de duplicados
- ✅ Persistencia entre sesiones

---

## 🔍 Búsqueda de Canales

### Búsqueda Global

Busca en **todas** las listas IPTV simultáneamente.

#### Características

- **Tiempo Real**: Resultados mientras escribes
- **Multi-Lista**: Busca en todas las listas cargadas
- **Filtrado Inteligente**: Coincidencia parcial y completa
- **Sin Límites**: No hay restricción en el número de resultados

#### Cómo Usar

1. **Abrir Búsqueda**: Menú lateral → "Buscar"
2. **Ingresar Texto**: Usa el teclado virtual
3. **Ver Resultados**: Actualización automática
4. **Reproducir**: Selecciona un resultado y presiona OK

#### Campos de Búsqueda

La búsqueda examina:
- ✅ Nombre del canal
- ✅ Categoría/Grupo
- ✅ ID del canal (si está disponible)

**Ejemplo**:
```
Búsqueda: "deporte"
Resultados:
  - Deportes ESPN (Lista: TV Cable)
  - Canal Deportivo HD (Lista: IPTV Premium)
  - FOX Deportes (Lista: Internacionales)
```

### Búsqueda por Lista

Filtra canales dentro de una lista específica.

#### Activación
1. Entra a una lista
2. Abre el diálogo de búsqueda
3. La búsqueda se limita a esa lista

#### Ventajas
- Resultados más específicos
- Carga más rápida
- Ideal para listas grandes

### Teclado Virtual

Interfaz amigable para entrada de texto:

```
[Q][W][E][R][T][Y][U][I][O][P]
[A][S][D][F][G][H][J][K][L]
[Z][X][C][V][B][N][M]
[SPACE] [BACKSPACE] [CLEAR]
```

**Controles**:
- **Flechas**: Navegar entre teclas
- **OK**: Ingresar letra
- **Back**: Cerrar búsqueda
- **Play**: Ejecutar búsqueda

---

## 📺 Reproductor de Video

### Características del Player

Ultimate IPTV 2026 incluye un reproductor de video profesional optimizado para streaming IPTV.

#### Formatos Soportados

**Protocolos de Streaming**:
- ✅ HTTP/HTTPS
- ✅ HLS (HTTP Live Streaming)
- ✅ RTMP (Real-Time Messaging Protocol)
- ✅ UDP/RTP (con limitaciones)

**Codecs de Video**:
- ✅ H.264 (AVC)
- ✅ H.265 (HEVC) - en dispositivos compatibles
- ✅ MPEG-2
- ✅ MPEG-4

**Codecs de Audio**:
- ✅ AAC
- ✅ MP3
- ✅ AC3

### Controles de Reproducción

#### Controles Básicos

| Acción | Botón | Descripción |
|--------|-------|-------------|
| **Reproducir** | OK | Inicia la reproducción |
| **Pausar** | ⏯️ Play/Pause | Pausa/reanuda |
| **Detener** | ◀️ Back | Detiene y vuelve |
| **Retroceder** | ⏪ Rewind | -10 segundos |
| **Avanzar** | ⏩ Fast Forward | +10 segundos |
| **Favorito** | ★ Star | Agregar/remover favorito |

#### Información en Pantalla

Durante la reproducción se muestra:
```
┌─────────────────────────────┐
│ 📺 Canal Deportivo HD       │
│                             │
│    [●] Reproduciendo        │
│    00:05:23 / Live          │
│                             │
│ ★ Agregar a Favoritos       │
└─────────────────────────────┘
```

### Buffering Inteligente

#### Sistema Automático

- **Buffer Inicial**: 3-5 segundos antes de reproducir
- **Rebuffering**: Detección y recarga automática
- **Indicador Visual**: Spinner durante la carga
- **Timeout**: 30 segundos antes de reportar error

#### Estados del Player

```brightscript
' Estados manejados
state = "none"       ' Sin inicializar
state = "buffering"  ' Cargando contenido
state = "playing"    ' Reproduciendo
state = "paused"     ' En pausa
state = "error"      ' Error de reproducción
state = "finished"   ' Stream terminado
```

### Manejo de Errores

#### Tipos de Errores

1. **Error de Red**:
   - Reconexión automática (3 intentos)
   - Mensaje: "Error de conexión. Reintentando..."

2. **Stream No Disponible**:
   - Mensaje: "El canal no está disponible"
   - Opción de volver o probar otro canal

3. **Formato No Soportado**:
   - Mensaje: "Formato de video no compatible"
   - Sugerencia de contactar al proveedor

4. **Timeout**:
   - Mensaje: "Tiempo de espera agotado"
   - Opción de reintentar

### Optimizaciones

- **Precarga**: Carga metadatos antes de reproducir
- **Cleanup**: Liberación automática de recursos
- **Memory Management**: Control de uso de memoria
- **State Persistence**: Mantiene el estado entre pausas

---

## 🎨 Interfaz de Usuario

### Diseño Responsive

La UI se adapta automáticamente a la resolución del dispositivo.

#### Resoluciones Soportadas

- **FHD (1920×1080)**: Diseño principal optimizado
- **HD (1280×720)**: Adaptación automática
- **SD (720×480)**: Soporte básico

#### Sistema de Grids

```brightscript
' Configuración responsive automática
if width = 1920 then
    itemSize = [300, 250]
    itemSpacing = [20, 20]
    numColumns = 5
else if width = 1280 then
    itemSize = [240, 200]
    itemSpacing = [15, 15]
    numColumns = 4
end if
```

### Sidebar Expandible

#### Estados del Sidebar

**Estado Colapsado**:
```
┌────┐
│ 🏠 │
│ 🔍 │
│ ➕ │
│ ⚙️ │
└────┘
```

**Estado Expandido**:
```
┌──────────────────┐
│ 🏠 Inicio        │
│ 🔍 Buscar        │
│ ➕ Agregar Lista │
│ ⚙️ Configuración │
└──────────────────┘
```

#### Animaciones

- **Apertura**: Slide-in desde la izquierda (200ms)
- **Cierre**: Slide-out hacia la izquierda (200ms)
- **Opacidad**: Transición suave de iconos
- **Focus**: Highlight visual del item seleccionado

### Skeleton Screens

Durante la carga de contenido, se muestran "esqueletos" que simulan la estructura final.

#### Beneficios

- ✅ Mejor UX: El usuario sabe que algo está pasando
- ✅ Percepción de velocidad: Sensación de carga más rápida
- ✅ Profesionalismo: Apariencia moderna

#### Implementación

```xml
<SkeletonCard>
  <Rectangle color="0x404040" /> <!-- Base gris -->
  <Animation> <!-- Efecto shimmer -->
    <Vector2DFieldInterpolator />
  </Animation>
</SkeletonCard>
```

### Feedback Visual

#### Indicadores de Estado

- **Cargando**: Spinner animado
- **Éxito**: Mensaje temporal verde
- **Error**: Mensaje persistente rojo
- **Favorito**: Estrella dorada

#### Transiciones

- Vista → Vista: Fade (150ms)
- Dialog → Overlay: Scale + Fade (200ms)
- Sidebar: Slide (200ms)

---

## ⚙️ Configuración y Ajustes

### Panel de Configuración

Acceso: `Menú Lateral → Configuración`

#### Opciones Disponibles

##### 1. Autoplay
```
Setting: autoplayEnabled
Type: Boolean
Default: true
```
- **Enabled**: Reproduce automáticamente al seleccionar canal
- **Disabled**: Muestra información antes de reproducir

##### 2. Gestión de Caché
```
Action: clearCache()
```
- Limpia thumbnails y datos temporales
- Libera espacio de almacenamiento
- No afecta listas ni favoritos

##### 3. Analytics
```
Setting: analyticsEnabled
Type: Boolean
Default: false
```
- **Enabled**: Envía métricas de uso anónimas
- **Disabled**: Sin recopilación de datos

##### 4. Debug Mode
```
Setting: debugMode
Type: Boolean
Default: false
```
- Habilita logs detallados
- Muestra información técnica en pantalla
- Útil para desarrollo y troubleshooting

### Persistencia de Configuración

Todos los ajustes se guardan usando el Registry API de Roku:

```brightscript
' Guardar configuración
settings = {
    autoplay: true,
    analytics: false,
    debugMode: false
}
RegistryManager.saveSettings(settings)

' Cargar configuración
savedSettings = RegistryManager.loadSettings()
```

### Reset de Configuración

Opción para restaurar valores predeterminados:
1. Configuración → "Restablecer a Predeterminados"
2. Confirmación de seguridad
3. Reinicio de la app

---

## 🔧 Características Técnicas

### Arquitectura

#### Patrón MVC

- **Model**: Datos (listas, canales, favoritos)
- **View**: Componentes SceneGraph (XML)
- **Controller**: Lógica (BrightScript)

#### Componentes Principales

```
MainScene (Controlador Principal)
  ├── SidebarMenu (Navegación)
  ├── HomeGrid (Vista principal)
  ├── VideoPlayer (Reproductor)
  ├── SearchDialog (Búsqueda)
  └── SettingsDialog (Configuración)
```

### Managers

#### RegistryManager
```brightscript
' Gestión de almacenamiento persistente
- SavePlaylists()
- LoadPlaylists()
- SaveFavorites()
- LoadFavorites()
- SaveSettings()
- LoadSettings()
```

#### CacheManager
```brightscript
' Sistema de caché de imágenes
- CacheImage(url)
- GetCachedImage(url)
- ClearCache()
- GetCacheSize()
```

#### SettingsManager
```brightscript
' Gestión centralizada de configuración
- GetSetting(key)
- SetSetting(key, value)
- ResetToDefaults()
```

#### AnalyticsManager
```brightscript
' Métricas y seguimiento (opcional)
- TrackEvent(eventName, data)
- TrackScreenView(screenName)
- TrackError(errorType, message)
```

### Task Nodes

#### M3ULoaderTask

Carga asíncrona de listas M3U:

```brightscript
' Operación en background
Task: M3ULoaderTask
Input: url (string)
Output: channels (array)
Status: ready | running | done | error
```

**Ventajas**:
- ✅ No bloquea la UI
- ✅ Maneja listas grandes (10,000+ canales)
- ✅ Parsing eficiente
- ✅ Manejo de errores robusto

### Optimizaciones de Performance

#### Memory Management

```brightscript
' Liberación de recursos no usados
function cleanup()
    m.channelList.clear()
    m.thumbnailCache.clear()
    m.videoPlayer.control = "stop"
    m.videoPlayer = invalid
end function
```

#### Lazy Loading

- Carga de thumbnails bajo demanda
- Virtualización de listas grandes
- Precarga inteligente del siguiente item

#### Debouncing

Búsqueda con debounce para evitar procesamiento excesivo:

```brightscript
' Espera 300ms después de la última tecla
function onSearchTextChange()
    m.searchTimer.control = "stop"
    m.searchTimer.duration = 0.3
    m.searchTimer.control = "start"
end function
```

### APIs Utilizadas

#### Roku APIs
- **roSGScreen**: Gestión de pantalla principal
- **roVideoPlayer**: Reproducción de video
- **roRegistrySection**: Almacenamiento persistente
- **roUrlTransfer**: Descarga de contenido remoto
- **roDateTime**: Manejo de fechas y tiempo

#### Custom Interfaces

```brightscript
' Interfaz de componentes personalizados
<interface>
    <field id="channelData" type="assocarray" />
    <field id="isLoading" type="bool" />
    <field id="selectedIndex" type="int" />
    <function name="loadChannels" />
    <function name="clearData" />
</interface>
```

### Seguridad

#### Validación de Inputs
- URLs: Validación de formato y protocolo
- Nombres: Sanitización de caracteres especiales
- Datos de usuario: Escape de caracteres HTML

#### Manejo Seguro de Credenciales
- Sin almacenamiento de contraseñas
- Tokens encriptados (si aplica)
- Limpieza de datos sensibles en memoria

---

## 📊 Métricas y Estadísticas

### Métricas Disponibles (Si Analytics Habilitado)

#### Uso General
- Número de listas agregadas
- Total de canales disponibles
- Canales favoritos marcados
- Tiempo promedio de sesión

#### Reproducción
- Canales más vistos
- Tiempo total de reproducción
- Streams exitosos vs fallidos
- Tiempo promedio de buffering

#### Búsquedas
- Términos más buscados
- Búsquedas exitosas vs sin resultados
- Tiempo de búsqueda

### Privacidad

- ✅ Datos anónimos únicamente
- ✅ Sin información personal
- ✅ Opt-out disponible
- ✅ Datos almacenados localmente

---

## 🚀 Roadmap de Características Futuras

### En Desarrollo
- [ ] Soporte para EPG (Electronic Program Guide)
- [ ] Catch-up TV
- [ ] Grabación de streams
- [ ] Múltiples perfiles de usuario

### Planificado
- [ ] Sincronización en la nube
- [ ] Soporte para subtítulos
- [ ] Control parental
- [ ] Temas personalizables

### Considerado
- [ ] Integración con Trakt
- [ ] Recomendaciones AI
- [ ] Soporte VPN integrado
- [ ] Multi-audio tracks

---

## ❓ Preguntas Frecuentes

### ¿Cuántas listas puedo agregar?

No hay límite técnico, pero se recomienda no más de 10-15 listas para mantener performance óptima.

### ¿Los favoritos se mantienen si elimino una lista?

Sí, los favoritos son globales e independientes de las listas.

### ¿Puedo cambiar el orden de las listas?

Actualmente no, se muestran en orden de agregación.

### ¿Soporta listas con EPG?

EPG está planificado para futuras versiones.

### ¿Funciona sin internet?

No, requiere conexión activa para streaming.

---

**¿Más preguntas?** Abre un [issue en GitHub](https://github.com/tu-usuario/ultimate-iptv-2026/issues) 🚀
