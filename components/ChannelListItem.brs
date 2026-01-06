' *************************************************************
' ChannelListItem
' *************************************************************

sub init()
    m.bg = m.top.findNode("bg")
    m.title = m.top.findNode("title")
    m.favoriteBadge = m.top.findNode("favoriteBadge")
end sub

sub onContentSet(event as object)
    if m.title = invalid then m.title = m.top.findNode("title")
    if m.favoriteBadge = invalid then m.favoriteBadge = m.top.findNode("favoriteBadge")

    content = m.top.itemContent
    text = ""

    if content <> invalid then
        if m.favoriteBadge <> invalid then
            isFav = false
            if content.DoesExist("isFavorite") and content.isFavorite = true then
                isFav = true
            end if
            m.favoriteBadge.visible = isFav
        end if

        if content.title <> invalid then
            text = content.title
        else if content.name <> invalid then
            text = content.name
        end if
    end if

    m.title.text = text
end sub

sub onFocusChange(event as object)
    if m.bg = invalid then m.bg = m.top.findNode("bg")
    if m.title = invalid then m.title = m.top.findNode("title")

    focusValue = m.top.focusPercent
    focused = (focusValue <> invalid and focusValue >= 0.5)

    if focused then
        m.bg.opacity = 0.9
        m.title.color = "#FFFFFF"
        m.title.focused = true
    else
        m.bg.opacity = 0.0
        m.title.color = "#CCCCCC"
        m.title.focused = false
    end if
end sub
