# Arquitectura del Código - Ultimate IPTV 2026

Este documento describe la arquitectura técnica y organización del código de Ultimate IPTV 2026.

## 📐 Arquitectura General

### Patrón de Diseño

La aplicación sigue una arquitectura **basada en componentes** con **separación de responsabilidades** (SoC).

```
┌─────────────────────────────────────────┐
│           User Interface Layer          │
│  (SceneGraph XML Components + UI Logic) │
├─────────────────────────────────────────┤
│          Business Logic Layer           │
│    (Managers + Controllers + Utils)     │
├─────────────────────────────────────────┤
│           Data Layer                    │
│  (Registry + Cache + Network Access)    │
└─────────────────────────────────────────┘
```

## 🗂️ Estructura de Directorios

```
roku/
│
├── manifest                    # App configuration
│
├── source/                     # BrightScript source files
│   ├── Main.brs               # Entry point
│   ├── Utils.brs              # Utility functions
│   ├── RegistryManager.brs    # Persistent storage
│   ├── SettingsManager.brs    # App settings
│   ├── CacheManager.brs       # Image cache
│   └── AnalyticsManager.brs   # Metrics tracking
│
├── components/                 # SceneGraph components
│   │
│   ├── MainScene.xml          # Main scene container
│   ├── MainScene.brs          # Main controller logic
│   │
│   ├── VideoPlayer.xml        # Video player UI
│   ├── VideoPlayer.brs        # Player control logic
│   │
│   ├── SidebarMenu.xml        # Sidebar container
│   ├── SidebarMenu.brs        # Sidebar logic
│   ├── SidebarMenuItem.xml    # Menu item (icon + text)
│   ├── SidebarMenuItem.brs    # Menu item logic
│   ├── SidebarMenuTextItem.xml # Text-only menu item
│   ├── SidebarMenuTextItem.brs # Text item logic
│   │
│   ├── SearchDialog.xml       # Search interface
│   ├── SearchDialog.brs       # Search logic
│   │
│   ├── SettingsDialog.xml     # Settings interface
│   ├── SettingsDialog.brs     # Settings logic
│   │
│   ├── M3ULoaderTask.xml      # Async M3U loader
│   ├── M3ULoaderTask.brs      # Parser logic
│   │
│   ├── ChannelCard.xml        # Channel card UI
│   ├── ChannelCard.brs        # Channel card logic
│   ├── ChannelListItem.xml    # Channel list item
│   ├── ChannelListItem.brs    # List item logic
│   │
│   ├── PlaylistCard.xml       # Playlist card UI
│   ├── PlaylistCard.brs       # Playlist card logic
│   │
│   ├── SkeletonCard.xml       # Loading skeleton
│   ├── SkeletonCard.brs       # Skeleton animation
│   │
│   └── MarqueeLabel.xml       # Scrolling text
│       MarqueeLabel.brs       # Marquee logic
│
└── images/                    # App resources
    ├── splash-fhd.jpg        # Splash screen
    ├── mm_icon_focus_hd.png  # App icon (focus)
    ├── mm_icon_side_hd.png   # App icon (side)
    └── README_MISSING_ICONS.md # Icon guide
```

## 🔧 Componentes Principales

### 1. MainScene (Hub Central)

**Responsabilidades**:
- Coordinación de todas las vistas
- Gestión del estado global de la app
- Navegación entre pantallas
- Manejo de eventos del control remoto

**Vistas Manejadas**:
```brightscript
m.views = {
    home: "homeView"           ' Lista de playlists
    categories: "categoriesView" ' Categorías de una lista
    channels: "channelsView"    ' Canales de una categoría
    favorites: "favoritesView"  ' Canales favoritos
    player: "playerView"        ' Reproductor de video
}
```

**Estado Principal**:
```brightscript
m.state = {
    currentView: "home"
    playlists: []
    currentPlaylist: {}
    currentCategory: ""
    channels: []
    favorites: []
    isLoading: false
}
```

### 2. VideoPlayer

**Funcionalidad**:
- Reproducción de streams IPTV
- Control de playback
- Manejo de estados de buffer
- Gestión de errores de stream

**Interfaz**:
```xml
<interface>
    <field id="channelData" type="assocarray" />
    <field id="visible" type="bool" />
    <field id="playerState" type="string" />
</interface>
```

**Estados**:
```brightscript
' Posibles estados del player
"none" | "buffering" | "playing" | "paused" | "error" | "finished"
```

### 3. SidebarMenu

**Funcionalidad**:
- Navegación principal de la app
- Estados colapsado/expandido
- Animaciones de transición
- Highlights de selección

**Items del Menú**:
```brightscript
menuItems = [
    {icon: "home.png", text: "Inicio", action: "showHome"}
    {icon: "search.png", text: "Buscar", action: "showSearch"}
    {icon: "add.png", text: "Agregar Lista", action: "showAddDialog"}
    {icon: "settings.png", text: "Configuración", action: "showSettings"}
]
```

### 4. M3ULoaderTask (Async Worker)

**Propósito**: Cargar y parsear listas M3U sin bloquear la UI

**Proceso**:
```brightscript
' 1. Input
task.url = "http://provider.com/playlist.m3u"
task.control = "RUN"

' 2. Processing (en background)
- Download content
- Parse M3U format
- Extract channel info
- Build channel array

' 3. Output
task.channels = [array of channels]
task.status = "done" | "error"
```

**Parsing Logic**:
```brightscript
function parseM3U(content as String) as Object
    channels = []
    lines = content.Split(chr(10))
    
    for each line in lines
        if line.StartsWith("#EXTINF:")
            ' Extract metadata
            tvgId = extractAttribute(line, "tvg-id")
            tvgName = extractAttribute(line, "tvg-name")
            tvgLogo = extractAttribute(line, "tvg-logo")
            groupTitle = extractAttribute(line, "group-title")
            
            ' Next line is the stream URL
            streamUrl = lines[i + 1]
            
            ' Build channel object
            channel = {
                id: tvgId
                name: tvgName
                logo: tvgLogo
                category: groupTitle
                url: streamUrl
            }
            
            channels.push(channel)
        end if
    end for
    
    return {channels: channels}
end function
```

## 🔄 Flujo de Datos

### Agregar una Lista

```
User Action: "Agregar Lista"
    ↓
MainScene: showAddPlaylistDialog()
    ↓
User Input: URL + Nombre
    ↓
MainScene: startM3ULoader(url)
    ↓
M3ULoaderTask: RUNNING
    ↓ (background)
Download & Parse M3U
    ↓
M3ULoaderTask: DONE
    ↓
MainScene: onM3ULoadComplete()
    ↓
Create playlist object
    ↓
RegistryManager: savePlaylist()
    ↓
Update homeGrid
    ↓
Show success message
```

### Reproducir un Canal

```
User Action: Select Channel + OK
    ↓
MainScene: onChannelSelected(channelData)
    ↓
Show VideoPlayer
    ↓
VideoPlayer: setChannel(channelData)
    ↓
Player: content.url = channelData.url
    ↓
Player: control = "play"
    ↓
Monitor player states:
    - buffering → Show spinner
    - playing → Hide spinner
    - error → Show error message
```

### Sistema de Favoritos

```
User Action: Press ★ (Star)
    ↓
MainScene: toggleFavorite()
    ↓
Check if already favorite:
    ├─ YES → Remove from favorites
    └─ NO  → Add to favorites
    ↓
RegistryManager: saveFavorites()
    ↓
Update UI indicator
    ↓
Refresh favorites view (if visible)
```

## 💾 Gestión de Datos

### Registry Storage

Roku proporciona almacenamiento persistente mediante el Registry API.

**Estructura de Datos**:

```brightscript
' Section: "UltimateIPTV"
Registry Keys:
├── "playlists"     → JSON string of playlists array
├── "favorites"     → JSON string of favorites array
├── "settings"      → JSON string of settings object
└── "cache_index"   → JSON string of cache metadata
```

**RegistryManager Implementation**:

```brightscript
function saveData(key as String, data as Object) as Boolean
    section = CreateObject("roRegistrySection", "UltimateIPTV")
    jsonString = FormatJson(data)
    section.Write(key, jsonString)
    return section.Flush()
end function

function loadData(key as String) as Object
    section = CreateObject("roRegistrySection", "UltimateIPTV")
    jsonString = section.Read(key)
    if jsonString <> "" then
        return ParseJson(jsonString)
    end if
    return invalid
end function
```

### Cache System

**Propósito**: Cachear thumbnails y logos para acceso rápido

```brightscript
' CacheManager
function cacheImage(url as String) as String
    ' Generate cache key from URL
    cacheKey = md5(url)
    cachePath = "tmp:/" + cacheKey + ".png"
    
    ' Check if already cached
    if fileExists(cachePath) then
        return cachePath
    end if
    
    ' Download and cache
    transfer = CreateObject("roUrlTransfer")
    transfer.SetUrl(url)
    if transfer.GetToFile(cachePath) then
        updateCacheIndex(url, cachePath)
        return cachePath
    end if
    
    return "" ' Failed
end function

function clearCache() as Void
    cacheIndex = loadCacheIndex()
    for each item in cacheIndex
        DeleteFile(item.path)
    end for
    saveCacheIndex([])
end function
```

## 🎨 UI Components

### Component Hierarchy

```
MainScene
├── Sidebar
│   ├── SidebarMenuItem (Home)
│   ├── SidebarMenuItem (Search)
│   ├── SidebarMenuItem (Add)
│   └── SidebarMenuItem (Settings)
│
├── ContentArea
│   ├── HomeGrid (Playlist cards)
│   ├── CategoriesGrid (Category cards)
│   ├── ChannelsGrid (Channel cards)
│   └── FavoritesGrid (Favorite channels)
│
├── Overlays
│   ├── SearchDialog
│   ├── SettingsDialog
│   ├── AddPlaylistDialog
│   └── ConfirmDialog
│
└── VideoPlayer
    ├── PlayerContent (roVideoPlayer)
    ├── InfoOverlay
    └── ControlsOverlay
```

### Component Communication

**Parent → Child**:
```brightscript
' Set field in child component
m.videoPlayer.channelData = channelInfo
m.searchDialog.visible = true
```

**Child → Parent**:
```xml
<!-- Define field in child interface -->
<field id="itemSelected" type="int" onChange="onItemSelected"/>
```

```brightscript
' Observe field in parent
m.channelsGrid.observeField("itemSelected", "onChannelSelected")

function onChannelSelected(event as Object)
    index = event.getData()
    ' Handle selection
end function
```

## ⚡ Optimizaciones

### Memory Management

```brightscript
' Limpiar recursos al cambiar de vista
function changeView(newView as String)
    ' Limpiar vista anterior
    if m.currentView = "channels" then
        m.channelsGrid.content = invalid
        m.channelsGrid.visible = false
    end if
    
    ' Mostrar nueva vista
    showView(newView)
    m.currentView = newView
end function
```

### Lazy Loading

```brightscript
' Cargar thumbnails bajo demanda
function onGridItemFocused(event as Object)
    index = event.getData()
    
    ' Precargar thumbnails de items cercanos
    for i = index - 2 to index + 2
        if i >= 0 and i < m.channels.count() then
            loadThumbnail(m.channels[i])
        end if
    end for
end function
```

### Debouncing

```brightscript
' Búsqueda con debounce
function onSearchTextChange()
    m.searchTimer.control = "stop"
    m.searchTimer.duration = 0.3  ' 300ms
    m.searchTimer.control = "start"
end function

function onSearchTimerFire()
    performSearch(m.searchText)
end function
```

## 🔐 Error Handling

### Try-Catch Pattern

```brightscript
function safeOperation() as Dynamic
    try
        ' Operación que puede fallar
        result = riskyFunction()
        return result
    catch error
        print "[ERROR]"; error.message
        logError(error)
        return invalid
    end try
end function
```

### Validation

```brightscript
function validateUrl(url as String) as Boolean
    if url = "" or url = invalid then
        return false
    end if
    
    ' Check protocol
    if not url.StartsWith("http://") and not url.StartsWith("https://") then
        return false
    end if
    
    return true
end function

function validatePlaylistData(data as Object) as Boolean
    if data = invalid then return false
    if data.url = invalid or data.url = "" then return false
    if data.name = invalid or data.name = "" then return false
    return true
end function
```

## 📊 Debug & Logging

### Debug Mode

```brightscript
function log(message as String, level = "INFO" as String)
    if m.global.debugMode = true then
        timestamp = CreateObject("roDateTime").ToISOString()
        print "[" + timestamp + "] [" + level + "] " + message
    end if
end function

' Usage
log("Loading playlist: " + playlistName)
log("Channel count: " + channels.count().ToStr())
log("Error loading stream", "ERROR")
```

### Performance Monitoring

```brightscript
function measurePerformance(operationName as String)
    startTime = CreateObject("roTimespan")
    
    ' Perform operation
    result = performOperation()
    
    elapsed = startTime.TotalMilliseconds()
    log("Operation '" + operationName + "' took " + elapsed.ToStr() + "ms")
    
    return result
end function
```

## 🧪 Testing Considerations

### Manual Testing Checklist

- [ ] App loads without errors
- [ ] All menu items respond
- [ ] Playlist can be added
- [ ] Channels load correctly
- [ ] Video playback works
- [ ] Favorites can be toggled
- [ ] Search returns results
- [ ] Settings persist
- [ ] Memory cleanup works
- [ ] No crashes on edge cases

### Edge Cases to Test

1. **Empty Lists**: Playlist with 0 channels
2. **Large Lists**: 10,000+ channels
3. **Invalid URLs**: Malformed M3U URLs
4. **Network Issues**: Timeout, no connection
5. **Invalid Streams**: 404, 500 errors
6. **Special Characters**: Unicode in names
7. **Memory Pressure**: Multiple large lists

## 📚 Code Style Guide

### Naming Conventions

```brightscript
' Variables: camelCase
myVariable = "value"
channelCount = 0

' Constants: UPPER_SNAKE_CASE
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30

' Functions: camelCase
function calculateTotal()
end function

' Components: PascalCase
ChannelCard.xml
VideoPlayer.xml
```

### Comments

```brightscript
' Single-line comment

' *************************************************************
' Multi-line section header
' Describes major section of code
' *************************************************************

' TODO: Add error handling here
' FIXME: This breaks with large lists
' NOTE: Important information about this code
```

## 🔄 Future Improvements

### Planned Refactorings

1. **State Management**: Implement centralized state manager
2. **Component Library**: Create reusable component library
3. **Testing Framework**: Add unit tests for critical functions
4. **Build System**: Implement automated build and deployment
5. **Documentation**: Add JSDoc-style comments

### Architecture Evolution

```
Current: Monolithic MainScene
    ↓
Future: Modular Controllers

MainScene (Coordinator only)
├── PlaylistController
├── ChannelController
├── FavoritesController
├── SearchController
└── SettingsController
```

---

**Questions?** Contact the development team or open an issue on GitHub.
