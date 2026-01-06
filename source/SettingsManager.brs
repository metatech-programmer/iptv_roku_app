' *************************************************************
' Ultimate IPTV 2026 - Settings Manager
' Gestiona configuraciones persistentes de la aplicación
' *************************************************************

' Inicializar configuraciones por defecto
function InitSettings() as void
    sec = CreateObject("roRegistrySection", "SettingsSection")
    if sec = invalid then return
    
    ' Si no existen, crear defaults
    if sec.Read("initialized") = "" then
        defaultSettings = {
            cacheMaxAge: 24,           ' Horas
            autoRefresh: false,
            gridSize: "4x3",           ' Opciones: "3x3", "4x3", "5x3"
            theme: "dark",             ' dark/light
            autoplay: false,
            streamQuality: "auto",     ' auto/hd/sd
            showSubtitles: true,
            language: "es",            ' es/en/pt
            analytics: true
        }
        
        sec.Write("initialized", "true")
        for each key in defaultSettings
            sec.Write(key, FormatJson(defaultSettings[key]))
        end for
        sec.Flush()
        print "[SettingsManager] Configuraciones inicializadas"
    end if
end function

' Obtener una configuración
function GetSetting(key as string, defaultValue as dynamic) as dynamic
    sec = CreateObject("roRegistrySection", "SettingsSection")
    if sec = invalid then return defaultValue
    
    value = sec.Read(key)
    if value = "" or value = invalid then return defaultValue
    
    parsed = ParseJson(value)
    if parsed = invalid then return defaultValue
    
    return parsed
end function

' Guardar una configuración
function SaveSetting(key as string, value as dynamic) as boolean
    sec = CreateObject("roRegistrySection", "SettingsSection")
    if sec = invalid then return false
    
    jsonValue = FormatJson(value)
    if jsonValue <> invalid and jsonValue <> "" then
        sec.Write(key, jsonValue)
        sec.Flush()
        print "[SettingsManager] Guardado: " + key + " = " + jsonValue
        return true
    end if
    
    return false
end function

' Restablecer todas las configuraciones
function ResetSettings() as void
    sec = CreateObject("roRegistrySection", "SettingsSection")
    if sec = invalid then return
    
    keys = sec.GetKeyList()
    for each key in keys
        sec.Delete(key)
    end for
    sec.Flush()
    
    ' Reinicializar
    InitSettings()
    print "[SettingsManager] Configuraciones restablecidas"
end function

' Obtener todas las configuraciones
function GetAllSettings() as object
    settings = {}
    settings.cacheMaxAge = GetSetting("cacheMaxAge", 24)
    settings.autoRefresh = GetSetting("autoRefresh", false)
    settings.gridSize = GetSetting("gridSize", "4x3")
    settings.theme = GetSetting("theme", "dark")
    settings.autoplay = GetSetting("autoplay", false)
    settings.streamQuality = GetSetting("streamQuality", "auto")
    settings.showSubtitles = GetSetting("showSubtitles", true)
    settings.language = GetSetting("language", "es")
    settings.analytics = GetSetting("analytics", true)
    return settings
end function
