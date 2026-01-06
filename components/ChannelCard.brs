' *************************************************************
' Ultimate IPTV 2026 - Channel Card Component
' 
' Descripción: Lógica de la tarjeta de canal
' Muestra logo (tvg-logo) o placeholder
' Efecto glow blanco suave al recibir foco
' *************************************************************

sub init()
    ' Referencias a elementos UI minimalistas
    m.cardContainer = m.top.findNode("cardContainer")
    m.cardBackground = m.top.findNode("cardBackground")
    m.focusBorder = m.top.findNode("focusBorder")
    m.channelLogo = m.top.findNode("channelLogo")
    m.channelName = m.top.findNode("channelName")
    m.favoriteBadge = m.top.findNode("favoriteBadge")
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
        ' Badge favorito
        if m.favoriteBadge <> invalid then
            isFav = false
            if content.DoesExist("isFavorite") and content.isFavorite = true then
                isFav = true
            end if
            m.favoriteBadge.visible = isFav
        end if

        ' Asignar nombre del canal
        if content.title <> invalid then
            m.channelName.text = content.title
        end if
        
        ' Asignar logo
        if content.hdPosterUrl <> invalid and content.hdPosterUrl <> "" then
            m.channelLogo.uri = content.hdPosterUrl
        else
            ' Usar placeholder si no hay logo
            m.channelLogo.uri = "pkg:/images/tv_placeholder.png"
        end if
    end if
end sub

' *************************************************************
' Handler: Cambio de foco minimalista
' *************************************************************
sub onFocusPercentChange()
    focusPercent = m.top.focusPercent

    if m.channelName <> invalid then
        m.channelName.focused = (focusPercent > 0.5)
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
