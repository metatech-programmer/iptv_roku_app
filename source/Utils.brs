' *************************************************************
' Ultimate IPTV 2026 - Utilidades Comunes
' 
' Descripción: Funciones helper reutilizables
' *************************************************************

' *************************************************************
' Validar URL
' *************************************************************
function IsValidUrl(url as string) as boolean
    if url = invalid or url = "" then return false
    
    ' Debe empezar con http:// o https://
    if url.Left(7) = "http://" or url.Left(8) = "https://" then
        return true
    end if
    
    return false
end function

' *************************************************************
' Generar ID único basado en timestamp
' *************************************************************
function GenerateUniqueId(prefix as string) as string
    dt = CreateObject("roDateTime")
    timestamp = dt.AsSeconds().ToStr()
    random = Rnd(9999).ToStr()
    return prefix + "_" + timestamp + "_" + random
end function

' *************************************************************
' Truncar texto con ellipsis
' *************************************************************
function TruncateText(text as string, maxLength as integer) as string
    if text.Len() <= maxLength then
        return text
    end if
    
    return text.Left(maxLength - 3) + "..."
end function

' *************************************************************
' Limpiar texto HTML
' *************************************************************
function StripHtmlTags(html as string) as string
    ' Implementación simple - eliminar tags básicos
    cleaned = html
    
    ' Eliminar tags <...>
    while cleaned.InStr("<") >= 0 and cleaned.InStr(">") >= 0
        startPos = cleaned.InStr("<")
        endPos = cleaned.InStr(">")
        
        if startPos < endPos then
            ' Eliminar el tag
            before = cleaned.Left(startPos)
            after = cleaned.Mid(endPos + 1)
            cleaned = before + after
        else
            exit while
        end if
    end while
    
    return cleaned
end function

' *************************************************************
' Convertir segundos a formato HH:MM:SS
' *************************************************************
function FormatDuration(seconds as integer) as string
    hours = Int(seconds / 3600)
    minutes = Int((seconds mod 3600) / 60)
    secs = seconds mod 60
    
    if hours > 0 then
        return hours.ToStr() + ":" + Right("0" + minutes.ToStr(), 2) + ":" + Right("0" + secs.ToStr(), 2)
    else
        return minutes.ToStr() + ":" + Right("0" + secs.ToStr(), 2)
    end if
end function

' *************************************************************
' Obtener extensión de un archivo desde URL
' *************************************************************
function GetFileExtension(url as string) as string
    lastDot = -1
    
    for i = url.Len() - 1 to 0 step -1
        if url.Mid(i, 1) = "." then
            lastDot = i
            exit for
        end if
        
        ' Si encuentra ?, detener (parámetros de query)
        if url.Mid(i, 1) = "?" then
            exit for
        end if
    end for
    
    if lastDot > 0 then
        extension = url.Mid(lastDot + 1)
        
        ' Limpiar parámetros de query
        queryPos = extension.InStr("?")
        if queryPos >= 0 then
            extension = extension.Left(queryPos)
        end if
        
        return extension.ToLower()
    end if
    
    return ""
end function

' *************************************************************
' Detectar formato de stream desde URL
' *************************************************************
function DetectStreamFormat(url as string) as string
    extension = GetFileExtension(url)
    
    if extension = "m3u8" then
        return "hls"
    else if extension = "mp4" then
        return "mp4"
    else if extension = "mkv" then
        return "mkv"
    else if extension = "ts" then
        return "hls"
    else if url.InStr("/live/") > 0 or url.InStr("/stream/") > 0 then
        ' Probablemente HLS
        return "hls"
    else
        ' Por defecto HLS (más común para IPTV)
        return "hls"
    end if
end function

' *************************************************************
' Sanitizar nombre de archivo
' *************************************************************
function SanitizeFileName(name as string) as string
    ' Eliminar caracteres no válidos
    invalid_chars = ["/", "\", ":", "*", "?", Chr(34), "<", ">", "|"]
    sanitized = name
    
    for each char in invalid_chars
        sanitized = sanitized.Replace(char, "_")
    end for
    
    return sanitized
end function

' *************************************************************
' Comparar versiones (semver básico)
' Retorna: -1 si v1 < v2, 0 si iguales, 1 si v1 > v2
' *************************************************************
function CompareVersions(v1 as string, v2 as string) as integer
    parts1 = v1.Split(".")
    parts2 = v2.Split(".")
    
    maxLen = parts1.Count()
    if parts2.Count() > maxLen then maxLen = parts2.Count()
    
    for i = 0 to maxLen - 1
        num1 = 0
        num2 = 0
        
        if i < parts1.Count() then
            num1 = parts1[i].ToInt()
        end if
        
        if i < parts2.Count() then
            num2 = parts2[i].ToInt()
        end if
        
        if num1 < num2 then
            return -1
        else if num1 > num2 then
            return 1
        end if
    end for
    
    return 0 ' Iguales
end function

' *************************************************************
' Logger con timestamp
' *************************************************************
function LogMessage(level as string, message as string) as void
    dt = CreateObject("roDateTime")
    timestamp = dt.ToISOString()
    
    print "[" + timestamp + "] [" + level + "] " + message
end function
