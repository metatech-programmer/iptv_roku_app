' *************************************************************
' Ultimate IPTV 2026 - Analytics Manager
' Tracking de uso y estadísticas
' *************************************************************

' Registrar visualización de canal
function LogChannelView(channelName as string, playlistName as string, duration as integer) as void
    if not GetSetting("analytics", true) then return
    
    sec = CreateObject("roRegistrySection", "AnalyticsSection")
    if sec = invalid then return
    
    ' Crear ID único para el canal
    channelId = channelName.Replace(" ", "_").ToLower()
    
    ' Obtener stats existentes
    statsJson = sec.Read("channel_" + channelId)
    stats = {}
    
    if statsJson <> "" and statsJson <> invalid then
        stats = ParseJson(statsJson)
        if stats = invalid then stats = {}
    end if
    
    ' Actualizar stats
    if not stats.DoesExist("viewCount") then stats.viewCount = 0
    if not stats.DoesExist("totalDuration") then stats.totalDuration = 0
    
    stats.viewCount = stats.viewCount + 1
    stats.totalDuration = stats.totalDuration + duration
    stats.channelName = channelName
    stats.playlistName = playlistName
    stats.lastViewed = CreateObject("roDateTime").AsSeconds()
    
    ' Guardar
    jsonStr = FormatJson(stats)
    if jsonStr <> invalid then
        sec.Write("channel_" + channelId, jsonStr)
        sec.Flush()
    end if
end function

' Obtener canales más vistos
function GetMostViewedChannels(limit as integer) as object
    sec = CreateObject("roRegistrySection", "AnalyticsSection")
    if sec = invalid then return []
    
    keys = sec.GetKeyList()
    allChannels = []
    
    for each key in keys
        if key.Left(8) = "channel_" then
            statsJson = sec.Read(key)
            if statsJson <> "" then
                stats = ParseJson(statsJson)
                if stats <> invalid then
                    allChannels.Push(stats)
                end if
            end if
        end if
    end for
    
    ' Ordenar por viewCount (bubble sort simple)
    for i = 0 to allChannels.Count() - 1
        for j = i + 1 to allChannels.Count() - 1
            if allChannels[j].viewCount > allChannels[i].viewCount then
                temp = allChannels[i]
                allChannels[i] = allChannels[j]
                allChannels[j] = temp
            end if
        end for
    end for
    
    ' Limitar resultados
    if allChannels.Count() > limit then
        result = []
        for i = 0 to limit - 1
            result.Push(allChannels[i])
        end for
        return result
    end if
    
    return allChannels
end function

' Obtener canales recientes
function GetRecentChannels(limit as integer) as object
    sec = CreateObject("roRegistrySection", "AnalyticsSection")
    if sec = invalid then return []
    
    keys = sec.GetKeyList()
    allChannels = []
    
    for each key in keys
        if key.Left(8) = "channel_" then
            statsJson = sec.Read(key)
            if statsJson <> "" then
                stats = ParseJson(statsJson)
                if stats <> invalid and stats.DoesExist("lastViewed") then
                    allChannels.Push(stats)
                end if
            end if
        end if
    end for
    
    ' Ordenar por lastViewed
    for i = 0 to allChannels.Count() - 1
        for j = i + 1 to allChannels.Count() - 1
            if allChannels[j].lastViewed > allChannels[i].lastViewed then
                temp = allChannels[i]
                allChannels[i] = allChannels[j]
                allChannels[j] = temp
            end if
        end for
    end for
    
    ' Limitar resultados
    if allChannels.Count() > limit then
        result = []
        for i = 0 to limit - 1
            result.Push(allChannels[i])
        end for
        return result
    end if
    
    return allChannels
end function

' Limpiar analytics
function ClearAnalytics() as void
    sec = CreateObject("roRegistrySection", "AnalyticsSection")
    if sec = invalid then return
    
    keys = sec.GetKeyList()
    for each key in keys
        sec.Delete(key)
    end for
    sec.Flush()
    print "[AnalyticsManager] Analytics limpiados"
end function

' Registrar error
function LogError(errorType as string, errorMessage as string, context as string) as void
    sec = CreateObject("roRegistrySection", "ErrorLogSection")
    if sec = invalid then return
    
    timestamp = CreateObject("roDateTime").AsSeconds()
    errorId = "error_" + timestamp.ToStr()
    
    errorData = {
        type: errorType,
        message: errorMessage,
        context: context,
        timestamp: timestamp
    }
    
    jsonStr = FormatJson(errorData)
    if jsonStr <> invalid then
        sec.Write(errorId, jsonStr)
        sec.Flush()
        print "[AnalyticsManager] Error registrado: " + errorType + " - " + errorMessage
    end if
end function
