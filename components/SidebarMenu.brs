' *************************************************************
' Ultimate IPTV 2026 - Sidebar Menu Logic
' Descripción: Lógica del menú lateral navegable
' *************************************************************

sub init()
    m.menuList = m.top.findNode("menuList")
    m.sidebarBg = m.top.findNode("sidebarBg")
    
    ' Crear items del menú
    createMenuItems()
    
    ' Observer para selección
    m.menuList.observeField("itemSelected", "onMenuItemSelected")
end sub

' Crear items del menú
sub createMenuItems()
    content = CreateObject("roSGNode", "ContentNode")
    
    ' Item 1: Home
    homeItem = content.createChild("ContentNode")
    homeItem.title = "🏠"
    homeItem.shortDescriptionLine1 = "Home"
    homeItem.hdPosterUrl = "pkg:/images/home_icon.png"
    
    ' Item 2: Favoritos
    favItem = content.createChild("ContentNode")
    favItem.title = "⭐"
    favItem.shortDescriptionLine1 = "Favoritos"
    favItem.hdPosterUrl = "pkg:/images/favorites_icon.png"
    
    ' Item 3: Buscar
    searchItem = content.createChild("ContentNode")
    searchItem.title = "🔍"
    searchItem.shortDescriptionLine1 = "Buscar"
    searchItem.hdPosterUrl = "pkg:/images/search_icon.png"
    
    ' Item 4: Agregar
    addItem = content.createChild("ContentNode")
    addItem.title = "➕"
    addItem.shortDescriptionLine1 = "Agregar"
    addItem.hdPosterUrl = "pkg:/images/add_icon.png"
    
    ' Item 5: Configuración
    settingsItem = content.createChild("ContentNode")
    settingsItem.title = "⚙️"
    settingsItem.shortDescriptionLine1 = "Config"
    settingsItem.hdPosterUrl = "pkg:/images/settings_icon.png"
    
    m.menuList.content = content
end sub

' Handler: Item seleccionado
sub onMenuItemSelected(event as object)
    index = event.getData()
    print "[SidebarMenu] Item seleccionado: "; index
    
    ' Emitir al padre
    m.top.menuItemSelected = index
end sub
