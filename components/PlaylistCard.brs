' *************************************************************
' Ultimate IPTV 2026 - Playlist Card Component
' 
' Descripción: Lógica de la tarjeta de playlist
' Animación suave a 60fps cuando recibe foco
' *************************************************************

sub init()
    ' Referencias a elementos UI minimalistas
    m.cardContainer = m.top.findNode("cardContainer")
    m.cardBackground = m.top.findNode("cardBackground")
    m.focusBorder = m.top.findNode("focusBorder")
    m.cardIcon = m.top.findNode("cardIcon")
    m.cardTitle = m.top.findNode("cardTitle")
    m.cardDescription = m.top.findNode("cardDescription")
end sub

' *************************************************************
' ANIMACIONES REMOVIDAS - Diseño minimalista sin animaciones
' *************************************************************

' *************************************************************
' Handler: Contenido asignado
' *************************************************************
sub onContentSet()
    content = m.top.itemContent
    
    if content <> invalid then
        ' Asignar título
        if content.title <> invalid then
            m.cardTitle.text = content.title
        end if
        
        ' Asignar descripción
        if content.shortDescriptionLine1 <> invalid then
            m.cardDescription.text = content.shortDescriptionLine1
        end if
        
        ' Asignar icono/poster
        if content.hdPosterUrl <> invalid then
            m.cardIcon.uri = content.hdPosterUrl
        end if
    end if
end sub

' *************************************************************
' Handler: Cambio de foco minimalista
' *************************************************************
sub onFocusPercentChange()
    focusPercent = m.top.focusPercent

    if m.cardTitle <> invalid then
        m.cardTitle.focused = (focusPercent > 0.5)
    end if

    if m.cardDescription <> invalid then
        m.cardDescription.focused = (focusPercent > 0.5)
    end if
    
    if m.focusBorder <> invalid then
        ' Borde sutil blanco al enfocar
        if focusPercent > 0.5 then
            m.focusBorder.opacity = 0.15
        else
            m.focusBorder.opacity = 0.0
        end if
    end if
    
    if m.cardBackground <> invalid then
        ' Cambio sutil de color
        if focusPercent > 0.5 then
            m.cardBackground.color = "#242424"
        else
            m.cardBackground.color = "#1A1A1A"
        end if
    end if
end sub
