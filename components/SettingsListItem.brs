' *************************************************************
' SettingsListItem
' *************************************************************

sub init()
    m.bg = m.top.findNode("bg")
    m.title = m.top.findNode("title")
end sub

sub onContentSet(event as object)
    if m.title = invalid then m.title = m.top.findNode("title")

    content = m.top.itemContent
    text = ""
    if content <> invalid and content.title <> invalid then
        text = content.title
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
        m.title.color = "#AAAAAA"
        m.title.focused = false
    end if
end sub
