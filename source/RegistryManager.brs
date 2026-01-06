' *************************************************************
' Ultimate IPTV 2026 - Registry Manager
' 
' Descripción: Utilidades para gestión de Registry
' Manejo centralizado de persistencia de datos
' *************************************************************

' *************************************************************
' Guardar objeto en Registry como JSON
' *************************************************************
function SaveToRegistry(sectionName as string, key as string, data as object) as boolean
    try
        sec = CreateObject("roRegistrySection", sectionName)
        jsonData = FormatJson(data)
        sec.Write(key, jsonData)
        return sec.Flush()
    catch e
        print "Error saving to registry: "; e
        return false
    end try
end function

' *************************************************************
' Leer objeto desde Registry (JSON)
' *************************************************************
function ReadFromRegistry(sectionName as string, key as string) as dynamic
    try
        sec = CreateObject("roRegistrySection", sectionName)
        jsonData = sec.Read(key)
        if jsonData <> "" then
            return ParseJson(jsonData)
        end if
    catch e
        print "Error reading from registry: "; e
    end try
    return invalid
end function

' *************************************************************
' Obtener todas las claves de una sección
' *************************************************************
function GetAllKeysFromRegistry(sectionName as string) as object
    try
        sec = CreateObject("roRegistrySection", sectionName)
        return sec.GetKeyList()
    catch e
        print "Error getting keys from registry: "; e
        return []
    end try
end function

' *************************************************************
' Borrar clave del Registry
' *************************************************************
function DeleteFromRegistry(sectionName as string, key as string) as boolean
    try
        sec = CreateObject("roRegistrySection", sectionName)
        sec.Delete(key)
        return sec.Flush()
    catch e
        print "Error deleting from registry: "; e
        return false
    end try
end function

' *************************************************************
' Verificar si existe una clave
' *************************************************************
function RegistryKeyExists(sectionName as string, key as string) as boolean
    try
        sec = CreateObject("roRegistrySection", sectionName)
        return sec.Exists(key)
    catch e
        print "Error checking registry key: "; e
        return false
    end try
end function

' *************************************************************
' Limpiar toda una sección del Registry
' *************************************************************
function ClearRegistrySection(sectionName as string) as boolean
    try
        sec = CreateObject("roRegistrySection", sectionName)
        keys = sec.GetKeyList()
        for each key in keys
            sec.Delete(key)
        end for
        return sec.Flush()
    catch e
        print "Error clearing registry section: "; e
        return false
    end try
end function
