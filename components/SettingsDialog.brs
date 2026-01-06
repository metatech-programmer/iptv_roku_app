' *************************************************************
' Ultimate IPTV 2026 - Settings Dialog MEJORADO
' Panel de configuraciones profesional con info detallada
' *************************************************************

sub init()
    m.settingsList = m.top.findNode("settingsList")
    m.settingDescription = m.top.findNode("settingDescription")
    m.appInfo = m.top.findNode("appInfo")
    
    ' Inicializar settings manager local
    initSettingsManager()
    
    ' Verificar que el registry se creó correctamente
    if m.registry = invalid then
        print "[SettingsDialog] ERROR: No se pudo crear roRegistrySection"
        return
    end if
    
    ' Cargar configuraciones actuales
    loadSettings()
    
    ' Mostrar info de la app
    updateAppInfo()
    
    ' Observers
    m.settingsList.observeField("itemSelected", "onSettingSelected")
    m.settingsList.observeField("itemFocused", "onSettingFocused")
    m.top.observeField("visible", "onVisibleChange")
    
    print "[SettingsDialog] Initialized"
end sub

' Mostrar información de la app
sub updateAppInfo()
    if m.appInfo = invalid then return
    
    deviceInfo = CreateObject("roDeviceInfo")
    
    info = "Ultimate IPTV 2026" + Chr(10)
    info = info + "Versión: 1.0.0" + Chr(10) + Chr(10)
    
    if deviceInfo <> invalid then
        info = info + "Dispositivo: " + deviceInfo.GetModel() + Chr(10)
        
        ' Usar GetOSVersion() en lugar de GetVersion() deprecado
        osVersion = deviceInfo.GetOSVersion()
        if osVersion <> invalid then
            info = info + "Firmware: " + osVersion.major + "." + osVersion.minor + "." + osVersion.revision + " build " + osVersion.build + Chr(10)
        end if
        
        displaySize = deviceInfo.GetDisplaySize()
        if displaySize <> invalid then
            info = info + "Resolución: " + displaySize.w.ToStr() + "×" + displaySize.h.ToStr() + Chr(10)
        end if
    end if
    
    m.appInfo.text = info
end sub

' Cuando cambia la visibilidad, ajustar foco
sub onVisibleChange()
    if m.top.visible then
        if m.settingsList <> invalid then
            m.settingsList.setFocus(true)
            ' Actualizar descripción del primer item
            if m.settingsList.content <> invalid and m.settingsList.content.getChildCount() > 0 then
                updateDescription(0)
            end if
        end if
    end if
end sub

' Actualizar descripción cuando cambia el foco
sub onSettingFocused(event as object)
    index = event.getData()
    updateDescription(index)
end sub

' Actualizar panel de descripción
sub updateDescription(index as integer)
    if m.settingsList = invalid or m.settingDescription = invalid then return
    if m.settingsList.content = invalid then return
    
    item = m.settingsList.content.getChild(index)
    if item = invalid then return
    
    settingKey = item.settingKey
    
    ' Descripciones detalladas para cada configuración
    descriptions = {
        cacheMaxAge: "Define cuánto tiempo se almacenan las playlists en caché antes de volver a descargarlas. Un valor mayor reduce el uso de datos pero puede mostrar contenido desactualizado.",
        gridSize: "Ajusta el número de elementos visibles en la pantalla principal. Más columnas y filas permiten ver más contenido a la vez.",
        theme: "Cambia el esquema de colores de la interfaz. El tema oscuro reduce el brillo de la pantalla y ahorra energía.",
        streamQuality: "Selecciona la calidad de reproducción. 'Auto' ajusta automáticamente según tu conexión. Calidades mayores requieren más ancho de banda.",
        subtitles: "Activa o desactiva los subtítulos cuando estén disponibles en el stream.",
        language: "Idioma de la interfaz de usuario. Afecta textos y mensajes de la aplicación.",
        autoplay: "Reproduce automáticamente el siguiente canal cuando termina el actual. Útil para ver múltiples canales seguidos.",
        analytics: "Permite recopilar datos anónimos de uso para mejorar la aplicación. Incluye canales vistos y duración.",
        clearCache: "Elimina todas las playlists almacenadas en caché. Libera espacio y fuerza la descarga actualizada de las listas.",
        reset: "Restaura todas las configuraciones a sus valores predeterminados de fábrica. Esta acción no se puede deshacer."
    }
    
    if descriptions.DoesExist(settingKey) then
        m.settingDescription.text = descriptions[settingKey]
    else
        m.settingDescription.text = ""
    end if
end sub

' Manejar teclas presionadas
function onKeyEvent(key as string, press as boolean) as boolean
    if press then
        if key = "back" then
            ' Cerrar el diálogo
            m.top.visible = false
            return true
        end if
    end if
    return false
end function

' Inicializar Settings Manager local (replica funciones de source)
sub initSettingsManager()
    m.registry = CreateObject("roRegistrySection", "SettingsSection")
    
    ' Defaults
    m.defaultSettings = {
        cacheMaxAge: 24
        gridSize: "4x3"
        theme: "dark"
        autoplay: false
        analytics: true
        streamQuality: "auto"
        subtitles: true
        language: "es"
    }
end sub

' Obtener todos los settings
function getAllSettingsLocal() as object
    settings = {}
    
    ' Verificar que registry existe
    if m.registry = invalid or m.defaultSettings = invalid then
        print "ERROR: Registry o defaultSettings no inicializados"
        ' Retornar valores por defecto hardcoded
        return {
            cacheMaxAge: 24
            gridSize: "4x3"
            theme: "dark"
            autoplay: false
            analytics: true
            streamQuality: "auto"
            subtitles: true
            language: "es"
        }
    end if
    
    ' Leer desde registry o usar defaults
    if m.registry.Exists("cacheMaxAge")
        settings.cacheMaxAge = m.registry.Read("cacheMaxAge").ToInt()
    else
        settings.cacheMaxAge = m.defaultSettings.cacheMaxAge
    end if
    
    if m.registry.Exists("gridSize")
        settings.gridSize = m.registry.Read("gridSize")
    else
        settings.gridSize = m.defaultSettings.gridSize
    end if
    
    if m.registry.Exists("theme")
        settings.theme = m.registry.Read("theme")
    else
        settings.theme = m.defaultSettings.theme
    end if
    
    if m.registry.Exists("autoplay")
        settings.autoplay = (m.registry.Read("autoplay") = "true")
    else
        settings.autoplay = m.defaultSettings.autoplay
    end if
    
    if m.registry.Exists("analytics")
        settings.analytics = (m.registry.Read("analytics") = "true")
    else
        settings.analytics = m.defaultSettings.analytics
    end if
    
    if m.registry.Exists("streamQuality")
        settings.streamQuality = m.registry.Read("streamQuality")
    else
        settings.streamQuality = m.defaultSettings.streamQuality
    end if
    
    if m.registry.Exists("subtitles")
        settings.subtitles = (m.registry.Read("subtitles") = "true")
    else
        settings.subtitles = m.defaultSettings.subtitles
    end if
    
    if m.registry.Exists("language")
        settings.language = m.registry.Read("language")
    else
        settings.language = m.defaultSettings.language
    end if
    
    return settings
end function

' Guardar setting individual
sub saveSettingLocal(key as string, value as dynamic)
    if m.registry = invalid then return
    
    if value = invalid then return
    
    ' Convert value to string based on type
    valueStr = ""
    valueType = type(value)
    
    if valueType = "roBoolean" or valueType = "Boolean"
        if value then
            valueStr = "true"
        else
            valueStr = "false"
        end if
    else if valueType = "roInt" or valueType = "Integer" or valueType = "roInteger"
        valueStr = value.ToStr()
    else if valueType = "roString" or valueType = "String"
        valueStr = value
    else
        ' Try to convert to string
        valueStr = value.ToStr()
    end if
    
    m.registry.Write(key, valueStr)
    m.registry.Flush()
end sub

sub loadSettings()
    settings = getAllSettingsLocal()
    
    content = CreateObject("roSGNode", "ContentNode")
    
    ' Duración de Caché
    cacheItem = content.createChild("ContentNode")
    cacheItem.title = "Duración de Caché: " + settings.cacheMaxAge.ToStr() + "h"
    cacheItem.addFields({settingKey: "cacheMaxAge", settingValue: settings.cacheMaxAge})
    
    ' Tamaño de Grid
    gridItem = content.createChild("ContentNode")
    gridItem.title = "Tamaño de Grid: " + settings.gridSize
    gridItem.addFields({settingKey: "gridSize", settingValue: settings.gridSize})
    
    ' Tema
    themeItem = content.createChild("ContentNode")
    if settings.theme = "dark" then
        themeItem.title = "Tema: Oscuro"
    else
        themeItem.title = "Tema: Claro"
    end if
    themeItem.addFields({settingKey: "theme", settingValue: settings.theme})
    
    ' Calidad de Stream
    qualityItem = content.createChild("ContentNode")
    qualityItem.title = "Calidad: " + settings.streamQuality
    qualityItem.addFields({settingKey: "streamQuality", settingValue: settings.streamQuality})
    
    ' Subtítulos
    subsItem = content.createChild("ContentNode")
    if settings.subtitles then
        subsItem.title = "Subtítulos: Activados"
    else
        subsItem.title = "Subtítulos: Desactivados"
    end if
    subsItem.addFields({settingKey: "subtitles", settingValue: settings.subtitles})
    
    ' Idioma
    langItem = content.createChild("ContentNode")
    langLabel = "Español"
    if settings.language = "en" then
        langLabel = "English"
    else if settings.language = "pt" then
        langLabel = "Português"
    end if
    langItem.title = "Idioma: " + langLabel
    langItem.addFields({settingKey: "language", settingValue: settings.language})
    
    ' Autoplay
    autoplayItem = content.createChild("ContentNode")
    if settings.autoplay then
        autoplayItem.title = "Autoplay: Activado"
    else
        autoplayItem.title = "Autoplay: Desactivado"
    end if
    autoplayItem.addFields({settingKey: "autoplay", settingValue: settings.autoplay})
    
    ' Analytics
    analyticsItem = content.createChild("ContentNode")
    if settings.analytics then
        analyticsItem.title = "Analytics: Activado"
    else
        analyticsItem.title = "Analytics: Desactivado"
    end if
    analyticsItem.addFields({settingKey: "analytics", settingValue: settings.analytics})
    
    ' Limpiar Caché
    clearCacheItem = content.createChild("ContentNode")
    clearCacheItem.title = "Limpiar Caché"
    clearCacheItem.addFields({settingKey: "clearCache", settingValue: "action"})
    
    ' Restablecer
    resetItem = content.createChild("ContentNode")
    resetItem.title = "Restablecer Todo"
    resetItem.addFields({settingKey: "reset", settingValue: "action"})
    
    m.settingsList.content = content
    m.settingsList.jumpToItem = 0
    
    print "[SettingsDialog] Settings loaded"
end sub

sub onSettingSelected(event as object)
    index = event.getData()
    item = m.settingsList.content.getChild(index)
    
    if item = invalid then return
    
    settingKey = item.settingKey
    
    if settingKey = "clearCache" then
        clearCacheLocal()
        m.top.settingChanged = {key: "clearCache", timestamp: CreateObject("roDateTime").AsSeconds()}
        print "[SettingsDialog] Cache cleared"
        ' Mantener el foco en la lista
        m.settingsList.setFocus(true)
    else if settingKey = "reset" then
        resetSettingsLocal()
        reloadAndFocus(0) ' Ir al primer item después de resetear
        m.top.settingChanged = {key: "reset", timestamp: CreateObject("roDateTime").AsSeconds()}
        print "[SettingsDialog] Settings reset to defaults"
    else if settingKey = "autoplay" or settingKey = "analytics" or settingKey = "subtitles" then
        ' Toggle boolean
        newValue = not item.settingValue
        saveSettingLocal(settingKey, newValue)
        reloadAndFocus(index)
        m.top.settingChanged = {key: settingKey, value: newValue}
        print "[SettingsDialog] Toggled "; settingKey; " to "; newValue
    else if settingKey = "cacheMaxAge" then
        ' Cycle through: 6, 12, 24, 48 hours
        values = [6, 12, 24, 48]
        currentValue = item.settingValue
        newIndex = 0
        for i = 0 to values.Count() - 1
            if values[i] = currentValue then
                newIndex = (i + 1) mod values.Count()
                exit for
            end if
        end for
        saveSettingLocal(settingKey, values[newIndex])
        reloadAndFocus(index)
        m.top.settingChanged = {key: settingKey, value: values[newIndex]}
        print "[SettingsDialog] Changed cache age to "; values[newIndex]; "h"
    else if settingKey = "gridSize" then
        ' Cycle through grid sizes
        values = ["3x2", "4x3", "5x3", "5x4"]
        currentValue = item.settingValue
        newIndex = 0
        for i = 0 to values.Count() - 1
            if values[i] = currentValue then
                newIndex = (i + 1) mod values.Count()
                exit for
            end if
        end for
        saveSettingLocal(settingKey, values[newIndex])
        reloadAndFocus(index)
        m.top.settingChanged = {key: settingKey, value: values[newIndex]}
        print "[SettingsDialog] Changed grid size to "; values[newIndex]
    else if settingKey = "theme" then
        ' Toggle theme
        if item.settingValue = "dark" then
            newValue = "light"
        else
            newValue = "dark"
        end if
        saveSettingLocal(settingKey, newValue)
        reloadAndFocus(index)
        m.top.settingChanged = {key: settingKey, value: newValue}
        print "[SettingsDialog] Changed theme to "; newValue
    else if settingKey = "streamQuality" then
        ' Cycle through quality options
        values = ["auto", "1080p", "720p", "480p"]
        currentValue = item.settingValue
        newIndex = 0
        for i = 0 to values.Count() - 1
            if values[i] = currentValue then
                newIndex = (i + 1) mod values.Count()
                exit for
            end if
        end for
        saveSettingLocal(settingKey, values[newIndex])
        reloadAndFocus(index)
        m.top.settingChanged = {key: settingKey, value: values[newIndex]}
        print "[SettingsDialog] Changed quality to "; values[newIndex]
    else if settingKey = "language" then
        ' Cycle through languages
        values = ["es", "en", "pt"]
        currentValue = item.settingValue
        newIndex = 0
        for i = 0 to values.Count() - 1
            if values[i] = currentValue then
                newIndex = (i + 1) mod values.Count()
                exit for
            end if
        end for
        saveSettingLocal(settingKey, values[newIndex])
        reloadAndFocus(index)
        m.top.settingChanged = {key: settingKey, value: values[newIndex]}
        print "[SettingsDialog] Changed language to "; values[newIndex]
    end if
end sub

' Helper function to reload settings and restore focus
sub reloadAndFocus(itemIndex as integer)
    loadSettings()
    m.settingsList.jumpToItem = itemIndex
    m.settingsList.setFocus(true)
end sub

' Limpiar caché local
sub clearCacheLocal()
    cacheRegistry = CreateObject("roRegistrySection", "CacheSection")
    if cacheRegistry <> invalid then
        cacheRegistry.Delete("def1")
        cacheRegistry.Flush()
        print "Cache cleared successfully"
    else
        print "ERROR: Could not create CacheSection registry"
    end if
end sub

' Restablecer settings a defaults
sub resetSettingsLocal()
    if m.registry = invalid then
        print "ERROR: Registry not initialized in resetSettingsLocal"
        return
    end if
    
    m.registry.Delete("cacheMaxAge")
    m.registry.Delete("gridSize")
    m.registry.Delete("theme")
    m.registry.Delete("autoplay")
    m.registry.Delete("analytics")
    m.registry.Delete("streamQuality")
    m.registry.Delete("subtitles")
    m.registry.Delete("language")
    m.registry.Flush()
    print "Settings reset to defaults"
end sub
