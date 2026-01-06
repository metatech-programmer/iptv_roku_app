' *************************************************************
' Ultimate IPTV 2026 - M3U Loader Task
' 
' Descripción: Parser robusto de archivos M3U/M3U8
' Ejecuta en background (Task) para no bloquear la UI
' Extrae: nombre, URL, logo (tvg-logo), grupo (group-title)
' *************************************************************

sub init()
    m.top.functionName = "loadAndParseM3U"
end sub

' *************************************************************
' Función Principal: Descargar y Parsear M3U
' *************************************************************
sub loadAndParseM3U()
    url = m.top.url
    result = {
        categories: {}
        error: invalid
    }
    
    ' Validar URL
    if url = "" or url = invalid then
        result.error = "URL inválida"
        m.top.result = result
        return
    end if
    
    print "M3ULoaderTask: Descargando desde: "; url
    
    ' Intentar descargar con reintentos
    maxRetries = 3
    retryCount = 0
    response = invalid
    
    while retryCount < maxRetries and (response = invalid or response = "")
        if retryCount > 0 then
            print "M3ULoaderTask: Reintento " + retryCount.ToStr() + " de " + maxRetries.ToStr()
            ' Esperar antes de reintentar (1, 2, 3 segundos)
            sleep(retryCount * 1000)
        end if
        
        ' Descargar el contenido M3U
        transfer = CreateObject("roUrlTransfer")
        transfer.SetUrl(url)
        transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
        transfer.InitClientCertificates()
        transfer.EnablePeerVerification(false)
        transfer.EnableHostVerification(false)
        
        ' Timeout de 30 segundos
        port = CreateObject("roMessagePort")
        transfer.SetPort(port)
        
        if transfer.AsyncGetToString() then
            event = wait(30000, port) ' Timeout 30s
            if type(event) = "roUrlEvent" then
                if event.GetResponseCode() = 200 then
                    response = event.GetString()
                else
                    print "M3ULoaderTask: Error HTTP " + event.GetResponseCode().ToStr()
                end if
            else
                print "M3ULoaderTask: Timeout esperando respuesta"
            end if
        end if
        
        retryCount = retryCount + 1
    end while
    
    if response = "" or response = invalid then
        result.error = "No se pudo descargar después de " + maxRetries.ToStr() + " intentos"
        m.top.result = result
        return
    end if
    
    print "M3ULoaderTask: Contenido descargado (" + response.Len().ToStr() + " bytes), parseando..."
    
    ' Parsear el contenido
    parseResult = parseM3UContent(response)
    
    if parseResult.categories.Count() = 0 then
        result.error = "No se encontraron canales válidos en la lista"
        m.top.result = result
        return
    end if
    
    print "M3ULoaderTask: Parseado completo. Categorías: "; parseResult.categories.Count()
    m.top.result = parseResult
end sub

' *************************************************************
' Parsear Contenido M3U
' Busca patrones #EXTINF y agrupa por group-title
' *************************************************************
function parseM3UContent(content as string) as object
    categories = {}
    lines = content.Split(Chr(10)) ' Split por salto de línea
    
    currentChannel = invalid
    channelCount = 0
    
    for i = 0 to lines.Count() - 1
        line = lines[i].Trim()
        
        ' Ignorar líneas vacías
        if line = "" then continue for
        
        ' Detectar línea #EXTINF
        if line.Left(7) = "#EXTINF" then
            ' Parsear información del canal
            currentChannel = parseExtInfLine(line)
        else if currentChannel <> invalid and not line.Left(1) = "#" then
            ' Esta línea es la URL del stream
            currentChannel.url = line.Trim()
            
            ' Agregar canal a la categoría correspondiente
            categoryName = currentChannel.group
            if categoryName = "" then
                categoryName = "Sin Categoría"
            end if
            
            ' Crear categoría si no existe
            if not categories.DoesExist(categoryName) then
                categories[categoryName] = []
            end if
            
            ' Agregar canal
            categories[categoryName].Push(currentChannel)
            channelCount++
            
            ' Resetear
            currentChannel = invalid
        end if
    end for
    
    print "M3ULoaderTask: Total canales parseados: "; channelCount
    
    return {
        categories: categories
        error: invalid
    }
end function

' *************************************************************
' Parsear una línea #EXTINF
' Formato: #EXTINF:-1 tvg-id="..." tvg-logo="..." group-title="...",Nombre Canal
' *************************************************************
function parseExtInfLine(line as string) as object
    channel = {
        name: ""
        logo: ""
        group: ""
        url: ""
    }
    
    ' Extraer tvg-logo
    channel.logo = extractAttribute(line, "tvg-logo")
    
    ' Extraer group-title
    channel.group = extractAttribute(line, "group-title")
    
    ' Extraer nombre del canal (después de la última coma)
    commaPos = line.InStr(",")
    if commaPos > 0 then
        channel.name = line.Mid(commaPos + 1).Trim()
    else
        channel.name = "Canal Sin Nombre"
    end if
    
    ' Limpiar nombre (quitar caracteres especiales)
    channel.name = cleanChannelName(channel.name)
    
    return channel
end function

' *************************************************************
' Extraer atributo de una línea #EXTINF
' Busca: attrName="value"
' *************************************************************
function extractAttribute(line as string, attrName as string) as string
    searchPattern = attrName + "=" + Chr(34) ' attrName="
    startPos = line.InStr(searchPattern)
    
    if startPos < 0 then return ""
    
    ' Moverse al inicio del valor (después de ")
    valueStart = startPos + searchPattern.Len()
    
    ' Buscar el cierre de comillas
    endPos = line.InStr(valueStart, Chr(34))
    
    if endPos < 0 then return ""
    
    ' Extraer valor
    value = line.Mid(valueStart, endPos - valueStart)
    return value.Trim()
end function

' *************************************************************
' Limpiar nombre del canal
' Elimina caracteres HTML, espacios extra, etc.
' *************************************************************
function cleanChannelName(name as string) as string
    ' Reemplazar entidades HTML comunes
    cleaned = name
    cleaned = cleaned.Replace("&amp;", "&")
    cleaned = cleaned.Replace("&quot;", Chr(34))
    cleaned = cleaned.Replace("&apos;", "'")
    cleaned = cleaned.Replace("&lt;", "<")
    cleaned = cleaned.Replace("&gt;", ">")
    
    ' Eliminar múltiples espacios
    while cleaned.InStr("  ") >= 0
        cleaned = cleaned.Replace("  ", " ")
    end while
    
    return cleaned.Trim()
end function

' *************************************************************
' Helper: String InStr con offset
' *************************************************************
function InStrWithOffset(haystack as string, offset as integer, needle as string) as integer
    if offset >= haystack.Len() then return -1
    
    substring = haystack.Mid(offset)
    position = substring.InStr(needle)
    
    if position < 0 then return -1
    
    return offset + position
end function
