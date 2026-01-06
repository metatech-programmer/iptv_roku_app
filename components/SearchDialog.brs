' *************************************************************
' Ultimate IPTV 2026 - Search Dialog Logic
' Descripción: Buscador profesional minimalista
' *************************************************************

sub init()
    m.searchKeyboard = m.top.findNode("searchKeyboard")
    
    ' Observers
    m.top.observeField("visible", "onVisibleChange")
    
    if m.searchKeyboard <> invalid then
        m.searchKeyboard.observeField("buttonSelected", "onSearchButtonPressed")
    end if
    
    print "[SearchDialog] Initialized professionally"
end sub

' Cuando el diálogo se hace visible
sub onVisibleChange()
    if m.top.visible and m.searchKeyboard <> invalid then
        ' Mostrar keyboard
        m.searchKeyboard.visible = true
        m.searchKeyboard.setFocus(true)
        m.searchKeyboard.text = ""
        print "[SearchDialog] Keyboard opened"
    else if m.searchKeyboard <> invalid then
        m.searchKeyboard.visible = false
    end if
end sub

' Handler de botones
sub onSearchButtonPressed(event as object)
    buttonIndex = event.getData()
    
    if m.searchKeyboard = invalid then return
    
    if buttonIndex = 0 then ' Buscar
        query = m.searchKeyboard.text
        
        if query = invalid or query = "" then
            print "[SearchDialog] Empty query"
            m.top.searchResult = {error: "empty"}
            m.top.visible = false
            return
        end if
        
        if query.Len() < 3 then
            print "[SearchDialog] Query too short: "; query
            m.top.searchResult = {error: "short"}
            m.top.visible = false
            return
        end if
        
        ' Buscar y retornar resultado
        print "[SearchDialog] Searching for: "; query
        m.top.searchResult = {query: query, success: true}
        
        ' Guardar en historial
        saveToHistory(query)
        
        ' Cerrar dialog
        m.top.visible = false
        
    else ' Cancelar
        print "[SearchDialog] Search cancelled"
        m.top.searchResult = {error: "cancelled"}
        m.top.visible = false
    end if
end sub

' Guardar búsqueda en historial
sub saveToHistory(query as string)
    if query = "" or query.Len() < 3 then return
    
    sec = CreateObject("roRegistrySection", "SearchHistorySection")
    if sec = invalid then return
    
    ' Evitar duplicados recientes
    keys = sec.GetKeyList()
    for each key in keys
        json = sec.Read(key)
        if json <> "" and json <> invalid then
            item = ParseJson(json)
            if item <> invalid and item.query = query then
                ' Ya existe, no duplicar
                return
            end if
        end if
    end for
    
    timestamp = CreateObject("roDateTime").AsSeconds()
    historyItem = {
        query: query,
        timestamp: timestamp
    }
    
    json = FormatJson(historyItem)
    if json <> invalid and json <> "" then
        sec.Write("search_" + timestamp.ToStr(), json)
        sec.Flush()
        print "[SearchDialog] ✓ Saved to history: "; query
    end if
end sub
