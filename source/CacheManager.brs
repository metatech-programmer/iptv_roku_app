' *************************************************************
' Ultimate IPTV 2026 - Cache Manager
' Gestiona el caché de playlists M3U para reducir tráfico de red
' *************************************************************

' Guardar playlist en caché
function CachePlaylist(playlistId as string, data as object) as boolean
    if playlistId = "" or data = invalid then return false
    
    sec = CreateObject("roRegistrySection", "CacheSection")
    if sec = invalid then return false
    
    ' Agregar timestamp
    cacheData = {
        data: data,
        timestamp: CreateObject("roDateTime").AsSeconds(),
        playlistId: playlistId
    }
    
    jsonStr = FormatJson(cacheData)
    if jsonStr <> invalid and jsonStr <> "" then
        sec.Write("cache_" + playlistId, jsonStr)
        sec.Flush()
        print "[CacheManager] Playlist guardada en caché: " + playlistId
        return true
    end if
    
    return false
end function

' Obtener playlist del caché
function GetCachedPlaylist(playlistId as string, maxAgeHours as integer) as object
    if playlistId = "" then return invalid
    
    sec = CreateObject("roRegistrySection", "CacheSection")
    if sec = invalid then return invalid
    
    jsonStr = sec.Read("cache_" + playlistId)
    if jsonStr = "" or jsonStr = invalid then
        print "[CacheManager] No hay caché para: " + playlistId
        return invalid
    end if
    
    cacheData = ParseJson(jsonStr)
    if cacheData = invalid then return invalid
    
    ' Verificar edad del caché
    now = CreateObject("roDateTime").AsSeconds()
    age = now - cacheData.timestamp
    maxAge = maxAgeHours * 3600 ' Convertir horas a segundos
    
    if age > maxAge then
        print "[CacheManager] Caché expirado para: " + playlistId + " (edad: " + (age/3600).ToStr() + "h)"
        return invalid
    end if
    
    print "[CacheManager] Caché válido para: " + playlistId + " (edad: " + (age/60).ToStr() + "min)"
    return cacheData.data
end function

' Limpiar todo el caché
function ClearCache() as void
    sec = CreateObject("roRegistrySection", "CacheSection")
    if sec = invalid then return
    
    keys = sec.GetKeyList()
    for each key in keys
        sec.Delete(key)
    end for
    sec.Flush()
    print "[CacheManager] Caché limpiado"
end function

' Limpiar caché de una playlist específica
function ClearPlaylistCache(playlistId as string) as void
    if playlistId = "" then return
    
    sec = CreateObject("roRegistrySection", "CacheSection")
    if sec = invalid then return
    
    sec.Delete("cache_" + playlistId)
    sec.Flush()
    print "[CacheManager] Caché eliminado para: " + playlistId
end function

' Obtener información del caché
function GetCacheInfo(playlistId as string) as object
    if playlistId = "" then return invalid
    
    sec = CreateObject("roRegistrySection", "CacheSection")
    if sec = invalid then return invalid
    
    jsonStr = sec.Read("cache_" + playlistId)
    if jsonStr = "" or jsonStr = invalid then return invalid
    
    cacheData = ParseJson(jsonStr)
    if cacheData = invalid then return invalid
    
    now = CreateObject("roDateTime").AsSeconds()
    age = now - cacheData.timestamp
    
    return {
        exists: true,
        ageSeconds: age,
        ageMinutes: Int(age / 60),
        ageHours: Int(age / 3600),
        timestamp: cacheData.timestamp
    }
end function
