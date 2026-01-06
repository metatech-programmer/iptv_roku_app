' *************************************************************
' Ultimate IPTV 2026 - Sidebar Menu Item Component
' Descripción: Lógica del item individual del sidebar
' *************************************************************

sub init()
    m.itemBg = m.top.findNode("itemBg")
    m.itemIcon = m.top.findNode("itemIcon")
end sub

' *************************************************************
' Handler: Contenido asignado
' *************************************************************
sub onContentSet(event as object)
    if m.itemIcon = invalid then m.itemIcon = m.top.findNode("itemIcon")

    defaultIcon = "pkg:/images/placeholder.png"
    iconUri = defaultIcon

    content = m.top.itemContent
    if content <> invalid then
        if content.hdPosterUrl <> invalid and content.hdPosterUrl <> "" then
            iconUri = content.hdPosterUrl
        end if
    end if

    m.itemIcon.uri = iconUri
    ' Reset tint when setting/re-setting icon
    m.itemIcon.blendColor = "#666666"
end sub

' *************************************************************
' Handler: Cambio de foco
' *************************************************************
sub onFocusChange(event as object)
    if m.itemBg = invalid then m.itemBg = m.top.findNode("itemBg")
    if m.itemIcon = invalid then m.itemIcon = m.top.findNode("itemIcon")

    focusValue = m.top.focusPercent
    if focusValue <> invalid and focusValue >= 0.5 then
        ' Foco activo
        m.itemBg.opacity = 0.8
        m.itemIcon.blendColor = "#E50914"
    else
        ' Sin foco
        m.itemBg.opacity = 0.0
        m.itemIcon.blendColor = "#666666"
    end if
end sub
