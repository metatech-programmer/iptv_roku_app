' *************************************************************
' Ultimate IPTV 2026 - MainScene Controller (COMPLETO)
' *************************************************************

sub init()
    ' Estado de deep link y beacon
    m.isDeepLinkLaunch = false
    m.beaconFired = false
    
    ' Setup UI
    setupResponsiveLayout()
    
    ' Referencias UI principales
    m.homeGrid = m.top.findNode("homeGrid")
    m.categoriesGrid = m.top.findNode("categoriesGrid")
    m.channelsGrid = m.top.findNode("channelsGrid")
    m.skeletonGrid = m.top.findNode("skeletonGrid")
    m.loadingSpinner = m.top.findNode("loadingSpinner")
    m.mainContent = m.top.findNode("mainContent")
    
    applyResponsiveLayout()
    
    if m.homeGrid = invalid then
        print "[MainScene] ERROR: homeGrid no existe"
        return
    end if
    
    ' Referencias Sidebar
    m.sidebar = m.top.findNode("sidebar")
    m.sidebarExpanded = m.top.findNode("sidebarExpanded")
    m.sidebarMenu = m.top.findNode("sidebarMenu")
    m.sidebarActive = false
    
    ' Referencias iconos
    m.homeIcon = m.top.findNode("homeIcon")
    m.searchIcon = m.top.findNode("searchIcon")
    m.addIcon = m.top.findNode("addIcon")
    m.settingsIcon = m.top.findNode("settingsIcon")
    
    if m.homeIcon <> invalid then m.homeIcon.opacity = 1.0
    if m.searchIcon <> invalid then m.searchIcon.opacity = 0.4
    if m.addIcon <> invalid then m.addIcon.opacity = 0.4
    if m.settingsIcon <> invalid then m.settingsIcon.opacity = 0.4
    
    if m.sidebarMenu = invalid then
        print "[MainScene] ERROR: sidebarMenu no existe"
        return
    end if
    
    ' Referencias otros
    m.searchDialog = m.top.findNode("searchDialog")
    m.settingsDialog = m.top.findNode("settingsDialog")
    m.addPlaylistKeyboard = m.top.findNode("addPlaylistKeyboard")
    m.toastBackground = m.top.findNode("toastBackground")
    m.toastLabel = m.top.findNode("toastLabel")

    ' Estado Inicial
    m.navigationLevel = 0 
    m.currentPlaylist = invalid
    m.currentCategory = invalid
    m.currentCategoryName = invalid
    m.currentCategories = invalid
    m.playlists = []
    m.favorites = []
    m.favoritesIndex = {}
    m.isSearchResultsView = false

    ' Estado búsqueda global
    m.searchIndexChannels = []
    m.searchIndexLoadedPlaylists = {}
    m.searchLoadQueue = []
    m.searchLoadQueuePos = 0
    m.searchPendingQuery = invalid
    m.searchIndexBuilding = false
    m.searchLoaderTask = invalid
    m.searchLoadingPlaylist = invalid
    
    initializeRegistry()
    
    ' Observer para deep linking
    m.top.observeField("deepLinkArgs", "onDeepLinkArgs")
    
    ' Cargar settings y datos
    InitSettings()
    loadAndApplySettings()
    loadPlaylists()
    
    ' Verificar si hay deep link DESPUÉS de cargar playlists
    ' Esto asegura que las playlists estén disponibles para deep linking
    if m.top.deepLinkArgs <> invalid and m.top.deepLinkArgs.Count() > 0 then
        m.isDeepLinkLaunch = true
        print "[Beacon] Deep link detected at launch, beacon will fire when video plays"
        ' Procesar deep link
        onDeepLinkArgs(m.top.deepLinkArgs)
    else
        ' No hay deep link, disparar beacon normal
        fireAppLaunchCompleteBeacon()
    end if
    
    ' Observers
    if m.homeGrid <> invalid then
        m.homeGrid.observeField("itemSelected", "onHomeItemSelected")
        m.homeGrid.observeField("itemFocused", "onGridFocusChange")
    end if
    
    if m.categoriesGrid <> invalid then
        m.categoriesGrid.observeField("itemSelected", "onCategoryItemSelected")
        m.categoriesGrid.observeField("itemFocused", "onGridFocusChange")
    end if
    
    if m.channelsGrid <> invalid then
        m.channelsGrid.observeField("itemSelected", "onChannelItemSelected")
        m.channelsGrid.observeField("itemFocused", "onGridFocusChange")
    end if
    
    if m.sidebarMenu <> invalid then
        m.sidebarMenu.observeField("itemSelected", "onSidebarMenuSelected")
    end if
    
    if m.searchDialog <> invalid then
        m.searchDialog.observeField("searchResult", "onSearchResult")
        m.searchDialog.observeField("visible", "onSearchDialogVisibleChange")
    end if
    
    if m.settingsDialog <> invalid then
        m.settingsDialog.observeField("settingChanged", "onSettingChanged")
        m.settingsDialog.observeField("visible", "onSettingsDialogVisibleChange")
    end if
    
    if m.addPlaylistKeyboard <> invalid then
        m.addPlaylistKeyboard.observeField("buttonSelected", "onAddPlaylistButton")
        m.addPlaylistKeyboard.observeField("visible", "onAddPlaylistVisibleChange")
    end if
    
    if m.homeGrid <> invalid then m.homeGrid.setFocus(true)
end sub

' *************************************************************
' *************************************************************
' LÓGICA DEL SIDEBAR
' *************************************************************
sub toggleSidebar(active as boolean)
    m.sidebarActive = active
    
    ' SIN ANIMACIÓN - Solo mostrar/ocultar
    if active then
        ' Abrir menú
        if m.sidebarExpanded <> invalid then
            m.sidebarExpanded.visible = true
        end if
        
        if m.sidebarMenu <> invalid then
            m.sidebarMenu.setFocus(true)
        end if
    else
        ' Cerrar menú
        if m.sidebarExpanded <> invalid then
            m.sidebarExpanded.visible = false
        end if
        
        ' Devolver foco al grid correspondiente
        if m.navigationLevel = 0 and m.homeGrid <> invalid then
            m.homeGrid.setFocus(true)
        else if m.navigationLevel = 1 and m.categoriesGrid <> invalid then
            m.categoriesGrid.setFocus(true)
        else if m.navigationLevel = 2 and m.channelsGrid <> invalid then
            m.channelsGrid.setFocus(true)
        end if
    end if
end sub

sub onSidebarMenuSelected(event as object)
    index = event.getData()
    toggleSidebar(false) ' Cerrar menú
    
    ' Actualizar opacidad de iconos
    updateSidebarIcons(index)
    
    if index = 0 then ' Inicio
        showHomeGrid()
    else if index = 1 then ' Buscar
        openSearchDialog()
    else if index = 2 then ' Agregar
        showAddPlaylistDialog()
    else if index = 3 then ' Configuración (nuevo)
        openSettingsDialog()
    end if
end sub

' Actualizar visibilidad de iconos del sidebar
sub updateSidebarIcons(activeIndex as integer)
    if m.homeIcon <> invalid then
        m.homeIcon.opacity = 0.4
        if activeIndex = 0 then m.homeIcon.opacity = 1.0
    end if
    
    if m.searchIcon <> invalid then
        m.searchIcon.opacity = 0.4
        if activeIndex = 1 then m.searchIcon.opacity = 1.0
    end if
    
    if m.addIcon <> invalid then
        m.addIcon.opacity = 0.4
        if activeIndex = 2 then m.addIcon.opacity = 1.0
    end if
    
    if m.settingsIcon <> invalid then
        m.settingsIcon.opacity = 0.4
        if activeIndex = 3 then m.settingsIcon.opacity = 1.0
    end if
end sub

' *************************************************************
' REGISTRO Y DATOS
' *************************************************************
sub initializeRegistry()
    print "[MainScene] initializeRegistry START"
    sec = CreateObject("roRegistrySection", "PlaylistsSection")
    if sec = invalid then
        print "[MainScene] ERROR: No se pudo crear roRegistrySection"
        return
    end if
    
    keys = sec.GetKeyList()
    if keys.Count() = 0 then
        print "[MainScene] Inicializando playlists por defecto..."
        defaultPlaylists = [
            {id: "def1", name: "Samsung TV Plus", url: "https://apsattv.com/ssungusa.m3u"},
            {id: "def2", name: "IPTV Org Global", url: "https://iptv-org.github.io/iptv/index.m3u"},
            {id: "def3", name: "Canales Español", url: "https://iptv-org.github.io/iptv/languages/spa.m3u"},
            {id: "def4", name: "Películas (Canales de cine 24/7)", url: "https://iptv-org.github.io/iptv/categories/movies.m3u"},
            {id: "def5", name: "🎌 Anime y Animación", url: "https://iptv-org.github.io/iptv/categories/animation.m3u"},
            {id: "def6", name: "🍿 Series y Entretenimiento General", url: "https://iptv-org.github.io/iptv/categories/entertainment.m3u"}
        ]
        for each p in defaultPlaylists
            jsonStr = FormatJson(p)
            if jsonStr <> invalid and jsonStr <> "" then
                sec.Write(p.id, jsonStr)
            end if
        end for
        sec.Flush()
        print "[MainScene] Playlists guardadas: " + sec.GetKeyList().Count().ToStr()
    else
        print "[MainScene] Playlists existentes: " + keys.Count().ToStr()
    end if
end sub

sub loadPlaylists()
    print "[MainScene] loadPlaylists START"
    m.playlists = []
    sec = CreateObject("roRegistrySection", "PlaylistsSection")
    if sec = invalid then
        print "[MainScene] ERROR: No se pudo crear roRegistrySection"
        return
    end if
    
    keys = sec.GetKeyList()
    print "[MainScene] Cargando " + keys.Count().ToStr() + " playlists..."
    
    for each key in keys
        json = sec.Read(key)
        if json <> "" and json <> invalid then
            item = ParseJson(json)
            if item <> invalid then
                m.playlists.Push(item)
                print "[MainScene] Playlist cargada: " + key
            end if
        end if
    end for
    
    print "[MainScene] Total playlists cargadas: " + m.playlists.Count().ToStr()
    loadFavorites()
    showHomeGrid()
end sub

sub loadFavorites()
    print "[MainScene] loadFavorites START"
    m.favorites = []
    sec = CreateObject("roRegistrySection", "FavoritesSection")
    if sec = invalid then
        print "[MainScene] WARN: No se pudo crear FavoritesSection"
        return
    end if
    
    keys = sec.GetKeyList()
    print "[MainScene] Cargando " + keys.Count().ToStr() + " favoritos..."
    print "[MainScene] Keys encontradas: " + keys.Count().ToStr()
    
    if keys.Count() > 0 then
        for i = 0 to keys.Count() - 1
            print "[MainScene] Key[" + i.ToStr() + "]: " + keys[i]
        end for
    end if
    
    for each key in keys
        json = sec.Read(key)
        print "[MainScene] Leyendo key '" + key + "': " + Left(json, 50)
        if json <> "" and json <> invalid then
            item = ParseJson(json)
            if item <> invalid then
                m.favorites.Push(item)
                print "[MainScene] Favorito cargado: " + item.name
            end if
        end if
    end for
    
    print "[MainScene] Total favoritos cargados: " + m.favorites.Count().ToStr()
    rebuildFavoritesIndex()
end sub

sub showHomeGrid()
    m.navigationLevel = 0
    m.isSearchResultsView = false
    
    if m.homeGrid = invalid then
        print "[showHomeGrid] ERROR: homeGrid es invalid"
        return
    end if
    
    content = CreateObject("roSGNode", "ContentNode")
    
    ' Favoritos
    favCard = content.createChild("ContentNode")
    favCard.title = "⭐ FAVORITOS"
    favCard.hdPosterUrl = "pkg:/images/favorites_icon.png"
    favCard.shortDescriptionLine1 = m.favorites.Count().ToStr() + " canales"
    favCard.addFields({cardType: "favorites"})
    
    ' Canales más vistos (Analytics)
    mostViewed = GetMostViewedChannels(1)
    if mostViewed.Count() > 0 then
        popularCard = content.createChild("ContentNode")
        popularCard.title = "🔥 MÁS VISTOS"
        popularCard.hdPosterUrl = "pkg:/images/category_icon.png"
        popularCard.shortDescriptionLine1 = "Tus canales favoritos"
        popularCard.addFields({cardType: "popular"})
    end if
    
    ' Canales recientes
    recent = GetRecentChannels(1)
    if recent.Count() > 0 then
        recentCard = content.createChild("ContentNode")
        recentCard.title = "🕒 RECIENTES"
        recentCard.hdPosterUrl = "pkg:/images/playlist_icon.png"
        recentCard.shortDescriptionLine1 = "Últimos vistos"
        recentCard.addFields({cardType: "recent"})
    end if
    
    ' Playlists
    for each p in m.playlists
        card = content.createChild("ContentNode")
        card.title = p.name
        card.hdPosterUrl = "pkg:/images/playlist_icon.png"
        
        ' Mostrar info de caché si existe
        cacheInfo = GetCacheInfo(p.id)
        if cacheInfo <> invalid and cacheInfo.exists then
            hours = cacheInfo.ageHours
            if hours = 0 then
                card.shortDescriptionLine1 = "✓ Caché: < 1h"
            else
                card.shortDescriptionLine1 = "✓ Caché: " + hours.ToStr() + "h"
            end if
        else
            card.shortDescriptionLine1 = "Lista M3U"
        end if
        
        card.addFields({cardType: "playlist", playlistId: p.id, playlistUrl: p.url, playlistData: p})
    end for
    
    ' Agregar
    addCard = content.createChild("ContentNode")
    addCard.title = "[+] AGREGAR LISTA"
    addCard.hdPosterUrl = "pkg:/images/add_icon.png"
    addCard.shortDescriptionLine1 = "Nueva playlist"
    addCard.addFields({cardType: "add"})
    
    m.homeGrid.content = content
    setActiveMainView("home")
    m.homeGrid.setFocus(true)
    
    print "[showHomeGrid] Grid actualizado con " + content.getChildCount().ToStr() + " items"
end sub

' *************************************************************
' NAVEGACIÓN
' *************************************************************
sub onHomeItemSelected(event as object)
    item = m.homeGrid.content.getChild(event.getData())
    cardType = invalid
    if item.DoesExist("cardType") then cardType = item.cardType
    
    if cardType = "favorites" then
        showFavoritesAsChannels()
    else if cardType = "popular" then
        showPopularChannels()
    else if cardType = "recent" then
        showRecentChannels()
    else if cardType = "playlist" then
        m.currentPlaylist = {id: item.playlistId, name: item.title, url: item.playlistUrl}
        loadPlaylistCategories()
    else if cardType = "add" then
        showAddPlaylistDialog()
    end if
end sub

sub showPopularChannels()
    m.navigationLevel = 2
    m.currentPlaylist = {name: "🔥 MÁS VISTOS"}
    m.isSearchResultsView = false
    
    mostViewed = GetMostViewedChannels(20)
    content = CreateObject("roSGNode", "ContentNode")
    
    for each stats in mostViewed
        ' Necesitamos URL para poder reproducir
        if stats <> invalid and stats.DoesExist("channelUrl") and stats.channelUrl <> invalid and stats.channelUrl <> "" then
        node = content.createChild("ContentNode")
            node.title = stats.channelName
            poster = "pkg:/images/tv_placeholder.png"
            if stats.DoesExist("channelLogo") and stats.channelLogo <> invalid and stats.channelLogo <> "" then
                poster = stats.channelLogo
            end if
            node.hdPosterUrl = poster
            node.shortDescriptionLine1 = stats.views.ToStr() + " visualizaciones"
            ch = {
                name: stats.channelName
                url: stats.channelUrl
                logo: poster
                group: invalid
                playlistName: stats.playlistName
            }
            if stats.DoesExist("channelGroup") then ch.group = stats.channelGroup
            node.addFields({streamUrl: stats.channelUrl, channelData: ch, playlistName: stats.playlistName, isFavorite: isFavoriteUrl(stats.channelUrl)})
        end if
    end for
    
    if content.getChildCount() = 0 then
        showToast("No hay historial de visualizaciones", "#FF9800")
        return
    end if
    
    m.channelsGrid.content = content
    setActiveMainView("channels")
    m.channelsGrid.setFocus(true)
end sub

sub showRecentChannels()
    m.navigationLevel = 2
    m.currentPlaylist = {name: "🕒 RECIENTES"}
    m.isSearchResultsView = false
    
    recent = GetRecentChannels(20)
    content = CreateObject("roSGNode", "ContentNode")
    
    for each stats in recent
        ' Necesitamos URL para poder reproducir
        if stats <> invalid and stats.DoesExist("channelUrl") and stats.channelUrl <> invalid and stats.channelUrl <> "" then
        node = content.createChild("ContentNode")
            node.title = stats.channelName
            poster = "pkg:/images/tv_placeholder.png"
            if stats.DoesExist("channelLogo") and stats.channelLogo <> invalid and stats.channelLogo <> "" then
                poster = stats.channelLogo
            end if
            node.hdPosterUrl = poster
            node.shortDescriptionLine1 = stats.playlistName
            ch = {
                name: stats.channelName
                url: stats.channelUrl
                logo: poster
                group: invalid
                playlistName: stats.playlistName
            }
            if stats.DoesExist("channelGroup") then ch.group = stats.channelGroup
            node.addFields({streamUrl: stats.channelUrl, channelData: ch, playlistName: stats.playlistName, isFavorite: isFavoriteUrl(stats.channelUrl)})
        end if
    end for
    
    if content.getChildCount() = 0 then
        showToast("No hay canales recientes", "#FF9800")
        return
    end if
    
    m.channelsGrid.content = content
    setActiveMainView("channels")
    m.channelsGrid.setFocus(true)
end sub

sub showFavoritesAsChannels()
    m.navigationLevel = 2
    m.currentPlaylist = {name: "⭐ FAVORITOS GLOBALES"}
    m.isSearchResultsView = false
    content = CreateObject("roSGNode", "ContentNode")
    for each ch in m.favorites
        node = content.createChild("ContentNode")
        node.title = ch.name
        node.hdPosterUrl = ch.logo
        node.shortDescriptionLine1 = ch.group
        node.addFields({streamUrl: ch.url, channelData: ch, playlistName: "⭐ FAVORITOS GLOBALES", isFavorite: true})
    end for
    m.channelsGrid.content = content
    setActiveMainView("channels")
    m.channelsGrid.setFocus(true)
end sub

sub loadPlaylistCategories()
    m.navigationLevel = 1
    
    ' Intentar cargar desde caché primero
    maxAge = GetSetting("cacheMaxAge", 24)
    cachedData = GetCachedPlaylist(m.currentPlaylist.id, maxAge)
    
    if cachedData <> invalid then
        print "[MainScene] Usando playlist desde caché"
        m.currentCategories = cachedData.categories
        displayCategories()
        showToast("✓ Cargado desde caché", "#4CAF50")
        return
    end if
    
    ' No hay caché válido - cargar desde red
    print "[MainScene] Cargando playlist desde red..."
    showLoadingSkeleton(true)
    
    m.loaderTask = CreateObject("roSGNode", "M3ULoaderTask")
    m.loaderTask.observeField("result", "onPlaylistLoaded")
    m.loaderTask.url = m.currentPlaylist.url
    m.loaderTask.control = "RUN"
end sub

sub displayCategories()
    ' Mostrar categorías en el grid
    content = CreateObject("roSGNode", "ContentNode")
    for each catName in m.currentCategories.Keys()
        node = content.createChild("ContentNode")
        node.title = catName
        node.hdPosterUrl = "pkg:/images/category_icon.png"
        node.shortDescriptionLine1 = m.currentCategories[catName].Count().ToStr() + " canales"
    end for
    
    m.categoriesGrid.content = content
    setActiveMainView("categories")
    m.categoriesGrid.setFocus(true)
end sub

sub onPlaylistLoaded(event as object)
    showLoadingSkeleton(false)
    result = event.getData()
    if result.error <> invalid then
        showToast("Error al cargar lista", "#D32F2F")
        LogError("playlist_load", result.error, m.currentPlaylist.url)
        return
    end if
    
    m.currentCategories = result.categories
    
    ' Guardar en caché
    cacheSuccess = CachePlaylist(m.currentPlaylist.id, result)
    if cacheSuccess then
        print "[MainScene] Playlist guardada en caché exitosamente"
    end if
    
    displayCategories()
    showToast("✓ " + m.currentCategories.Count().ToStr() + " categorías cargadas", "#4CAF50")
end sub

sub onCategoryItemSelected(event as object)
    selectedIndex = event.getData()
    categoryItem = m.categoriesGrid.content.getChild(selectedIndex)
    catName = categoryItem.title
    
    m.navigationLevel = 2
    m.isSearchResultsView = false

    ' Guardar la categoría actual (por nombre)
    m.currentCategory = catName
    m.currentCategoryName = catName
    
    channels = m.currentCategories[catName]
    
    ' Optimización: Limitar canales mostrados inicialmente
    maxChannels = 100
    channelsToShow = channels
    
    if channels.Count() > maxChannels then
        print "[MainScene] Categoría tiene " + channels.Count().ToStr() + " canales, limitando a " + maxChannels.ToStr()
        channelsToShow = []
        for i = 0 to maxChannels - 1
            channelsToShow.Push(channels[i])
        end for
        showToast("Mostrando " + maxChannels.ToStr() + " de " + channels.Count().ToStr() + " canales", "#FF9800")
    end if
    
    content = CreateObject("roSGNode", "ContentNode")
    for each ch in channelsToShow
        node = content.createChild("ContentNode")
        node.title = ch.name
        node.hdPosterUrl = ch.logo
        node.shortDescriptionLine1 = catName
        node.addFields({streamUrl: ch.url, channelData: ch, playlistName: m.currentPlaylist.name, isFavorite: isFavoriteChannel(ch)})
    end for
    
    m.channelsGrid.content = content
    setActiveMainView("channels")
    m.channelsGrid.setFocus(true)
    
    ' Liberar memoria de categorías no usadas
    m.categoriesGrid.content = CreateObject("roSGNode", "ContentNode")
end sub

sub onChannelItemSelected(event as object)
    selectedIndex = event.getData()
    item = m.channelsGrid.content.getChild(selectedIndex)
    
    ' Obtener valores de forma segura
    streamUrl = ""
    title = "Canal"
    
    if item <> invalid then
        if item.DoesExist("streamUrl") then
            streamUrl = item.streamUrl
        else if item.DoesExist("url") then
            streamUrl = item.url
        end if
        if item.title <> invalid then
            title = item.title
        end if

        ' Guardar datos ricos del canal para analytics (URL/logo/grupo/playlist)
        channelData = invalid
        if item.DoesExist("channelData") and item.channelData <> invalid then
            channelData = item.channelData
        else
            channelData = {
                name: title
                url: streamUrl
                logo: invalid
                group: invalid
            }
            if item.hdPosterUrl <> invalid then channelData.logo = item.hdPosterUrl
            if item.shortDescriptionLine1 <> invalid then channelData.group = item.shortDescriptionLine1
        end if
        if channelData <> invalid then
            if not channelData.DoesExist("name") then channelData.name = title
            if not channelData.DoesExist("url") then channelData.url = streamUrl
            if item.DoesExist("playlistName") and item.playlistName <> invalid and item.playlistName <> "" then
                channelData.playlistName = item.playlistName
            else if m.currentPlaylist <> invalid and m.currentPlaylist.DoesExist("name") then
                channelData.playlistName = m.currentPlaylist.name
            end if
            m.currentChannel = channelData
        end if
    end if
    
    ' Pasar lista completa de canales y el índice seleccionado
    launchPlayer(streamUrl, title, selectedIndex)
end sub

' Construir lista de canales desde el contenido actual del grid (siempre consistente con el índice)
function buildChannelListFromGrid() as object
    channels = []
    if m.channelsGrid = invalid or m.channelsGrid.content = invalid then return channels

    content = m.channelsGrid.content
    count = content.getChildCount()
    if count <= 0 then return channels

    for i = 0 to count - 1
        node = content.getChild(i)
        if node = invalid then
            channels.Push({name: "Canal", url: "", logo: invalid, categoryName: invalid})
        else if node.DoesExist("channelData") and node.channelData <> invalid then
            ' Reusar el objeto original si existe
            ch = node.channelData
            if type(ch) = "roAssociativeArray" then
                ' Asegurar campos mínimos esperados por el player
                if not ch.DoesExist("name") and node.title <> invalid then ch.name = node.title
                if not ch.DoesExist("url") then
                    if node.DoesExist("streamUrl") then ch.url = node.streamUrl
                    if node.DoesExist("url") then ch.url = node.url
                end if
                if not ch.DoesExist("logo") and node.hdPosterUrl <> invalid then ch.logo = node.hdPosterUrl
                if not ch.DoesExist("categoryName") then
                    if node.shortDescriptionLine1 <> invalid then ch.categoryName = node.shortDescriptionLine1
                    if node.description <> invalid then ch.categoryName = node.description
                end if

                ' Propagar favorito para lista del player
                if node.DoesExist("isFavorite") then
                    ch.isFavorite = (node.isFavorite = true)
                end if
                channels.Push(ch)
            end if
        else
            ch = {
                name: node.title
                url: ""
                logo: node.hdPosterUrl
                categoryName: node.shortDescriptionLine1
            }
            if node.DoesExist("streamUrl") then ch.url = node.streamUrl
            if ch.url = "" and node.DoesExist("url") then ch.url = node.url
            if ch.categoryName = invalid or ch.categoryName = "" then ch.categoryName = node.description

            if node.DoesExist("isFavorite") then
                ch.isFavorite = (node.isFavorite = true)
            end if
            channels.Push(ch)
        end if
    end for

    return channels
end function

sub launchPlayer(url as string, title as string, channelIndex as integer)
    ' Validación de parámetros
    if url = invalid or url = "" then
        print "[launchPlayer] ERROR: URL inválida"
        showToast("Error: URL de video inválida", "#1A1A1A")
        return
    end if
    
    print "[launchPlayer] Iniciando reproductor para: " + title
    print "[launchPlayer] URL: " + url
    
    m.navigationLevel = 3
    m.player = CreateObject("roSGNode", "VideoPlayer")
    
    if m.player <> invalid then
        m.player.streamUrl = url
        m.player.title = title

        ' Pasar playlists para el navegador del reproductor (OK)
        if m.playlists <> invalid then
            m.player.playlists = m.playlists
        end if
        
        ' Pasar lista de canales para navegación (desde el grid actual)
        channelsPassed = false
        channelList = buildChannelListFromGrid()

        if channelList <> invalid and type(channelList) = "roArray" and channelList.Count() > 0 then
            m.player.channelList = channelList
            if channelIndex < 0 then channelIndex = 0
            if channelIndex >= channelList.Count() then channelIndex = 0
            m.player.currentChannelIndex = channelIndex
            channelsPassed = true
            print "[launchPlayer] Passed "; channelList.Count(); " channels to player (from grid)"
        else
            print "[launchPlayer] Warning: No channel list available (grid empty)"
        end if
        
        m.player.observeField("finished", "onPlayerFinished")
        m.player.observeField("channelChanged", "onPlayerChannelChanged")
        
        ' Marcar si es deep link playback para habilitar timeout/fallback
        if m.isDeepLinkLaunch then
            m.player.isDeepLinkPlayback = true
        end if
        
        ' Observer para disparar beacon cuando video empieza (deep link launch)
        if m.isDeepLinkLaunch and not m.beaconFired then
            m.player.observeField("videoPlaying", "onVideoPlayingForBeacon")
            print "[Beacon] Observer added - will fire beacon when video starts playing"
        end if
        
        ' Guardar datos para analytics
        m.playerStartTime = CreateObject("roDateTime").AsSeconds()
        m.currentChannelName = title
        if m.currentChannel <> invalid and m.currentChannel.DoesExist("playlistName") then
            m.currentPlaylistName = m.currentChannel.playlistName
        else if m.currentPlaylist <> invalid then
            m.currentPlaylistName = m.currentPlaylist.name
        end if
        
        m.top.appendChild(m.player)
        m.player.setFocus(true)
        
        ' Ocultar TODO el contenido de MainScene para que el player sea visible
        if m.mainContent <> invalid then
            m.mainContent.visible = false
        end if
        
        ' Ocultar grids individuales también
        if m.channelsGrid <> invalid then
            m.channelsGrid.visible = false
        end if
        if m.homeGrid <> invalid then
            m.homeGrid.visible = false
        end if
        if m.categoriesGrid <> invalid then
            m.categoriesGrid.visible = false
        end if
        
        ' Ocultar sidebar
        if m.sidebar <> invalid then
            m.sidebar.visible = false
        end if
        if m.sidebarExpanded <> invalid then
            m.sidebarExpanded.visible = false
        end if
        
        print "[launchPlayer] Player appended and focused, all UI hidden"
    else
        print "[launchPlayer] ERROR: No se pudo crear VideoPlayer"
        showToast("Error al crear el reproductor", "#1A1A1A")
    end if
end sub

sub onPlayerChannelChanged(event as object)
    ' Registrar segmento del canal anterior y actualizar al nuevo
    newIndex = event.getData()
    print "[MainScene] Player changed to channel index: "; newIndex

    if m.playerStartTime <> invalid then
        now = CreateObject("roDateTime").AsSeconds()
        duration = now - m.playerStartTime
        if duration > 0 and m.currentChannel <> invalid then
            LogChannelView(m.currentChannel, duration)
        end if
        m.playerStartTime = now
    else
        m.playerStartTime = CreateObject("roDateTime").AsSeconds()
    end if

    ' Actualizar canal actual desde la lista del player
    if m.player <> invalid and m.player.DoesExist("channelList") and m.player.channelList <> invalid then
        cl = m.player.channelList
        if type(cl) = "roArray" and newIndex >= 0 and newIndex < cl.Count() then
            ch = cl[newIndex]
            if type(ch) = "roAssociativeArray" then
                if not ch.DoesExist("playlistName") and m.currentPlaylistName <> invalid then ch.playlistName = m.currentPlaylistName
                m.currentChannel = ch
                if ch.DoesExist("name") then m.currentChannelName = ch.name
                if ch.DoesExist("playlistName") then m.currentPlaylistName = ch.playlistName
            end if
        end if
    end if
end sub

sub onPlayerFinished()
    m.navigationLevel = 2
    
    ' Registrar analytics
    if m.playerStartTime <> invalid then
        endTime = CreateObject("roDateTime").AsSeconds()
        duration = endTime - m.playerStartTime
        
        if m.currentChannel <> invalid then
            LogChannelView(m.currentChannel, duration)
            if m.currentChannel.DoesExist("name") then
                print "[MainScene] Analytics: " + m.currentChannel.name + " - " + duration.ToStr() + "s"
            end if
        else if m.currentChannelName <> invalid and m.currentPlaylistName <> invalid then
            LogChannelView({name: m.currentChannelName, url: "", playlistName: m.currentPlaylistName}, duration)
            print "[MainScene] Analytics: " + m.currentChannelName + " - " + duration.ToStr() + "s"
        end if
        
        m.playerStartTime = invalid
    end if
    
    ' Remover player
    if m.player <> invalid then
        m.top.removeChild(m.player)
        m.player = invalid
    end if
    
    ' Restaurar visibilidad del contenido según el nivel de navegación
    if m.mainContent <> invalid then
        m.mainContent.visible = true
    end if
    
    ' Restaurar sidebar
    if m.sidebar <> invalid then
        m.sidebar.visible = true
    end if
    
    ' Mostrar el grid apropiado según navigationLevel
    if m.navigationLevel = 2 and m.channelsGrid <> invalid then
        setActiveMainView("channels")
        m.channelsGrid.setFocus(true)
    else if m.navigationLevel = 1 and m.categoriesGrid <> invalid then
        setActiveMainView("categories")
        m.categoriesGrid.setFocus(true)
    else if m.homeGrid <> invalid then
        setActiveMainView("home")
        m.homeGrid.setFocus(true)
    end if
    
    print "[MainScene] Player finished and removed, content restored"
end sub

' Callback para disparar beacon cuando video empieza a reproducir (deep link)
sub onVideoPlayingForBeacon(event as object)
    isPlaying = event.getData()
    if isPlaying = true and not m.beaconFired then
        fireAppLaunchCompleteBeacon()
        m.beaconFired = true
        print "[Beacon] AppLaunchComplete fired after video started playing (deep link launch)"
    end if
end sub

' *************************************************************
' FAVORITOS
' *************************************************************
sub toggleFavorite()
    if m.channelsGrid = invalid or m.channelsGrid.content = invalid then
        return
    end if
    
    index = m.channelsGrid.itemFocused
    if index < 0 then return
    
    item = m.channelsGrid.content.getChild(index)
    if item = invalid then
        showToast("⚠ No se puede agregar este canal", "#FF9800")
        return
    end if

    channelData = invalid
    if item.DoesExist("channelData") and item.channelData <> invalid then
        channelData = item.channelData
    else
        ' Fallback para nodos sin channelData
        streamUrl = ""
        if item.DoesExist("streamUrl") and item.streamUrl <> invalid then streamUrl = item.streamUrl
        if streamUrl = "" and item.DoesExist("url") and item.url <> invalid then streamUrl = item.url

        groupName = ""
        if item.DoesExist("shortDescriptionLine1") and item.shortDescriptionLine1 <> invalid then groupName = item.shortDescriptionLine1
        if groupName = "" and item.DoesExist("description") and item.description <> invalid then groupName = item.description

        channelData = {
            name: item.title
            url: streamUrl
            logo: item.hdPosterUrl
            group: groupName
        }
    end if

    ' Normalizar campos mínimos (para búsqueda u otros listados)
    if channelData <> invalid and GetInterface(channelData, "ifAssociativeArray") <> invalid then
        if (not channelData.DoesExist("url") or channelData.url = invalid or channelData.url = "") and item.DoesExist("streamUrl") and item.streamUrl <> invalid then
            channelData.url = item.streamUrl
        end if
        if (not channelData.DoesExist("logo") or channelData.logo = invalid or channelData.logo = "") and item.hdPosterUrl <> invalid then
            channelData.logo = item.hdPosterUrl
        end if
        if (not channelData.DoesExist("group") or channelData.group = invalid or channelData.group = "") then
            if channelData.DoesExist("categoryName") and channelData.categoryName <> invalid and channelData.categoryName <> "" then
                channelData.group = channelData.categoryName
            end if
        end if
    end if

    if channelData = invalid or not channelData.DoesExist("name") or not channelData.DoesExist("url") or channelData.url = invalid or channelData.url = "" then
        showToast("⚠ No se puede agregar este canal", "#FF9800")
        return
    end if

    urlStr = channelData.url
    
    sec = CreateObject("roRegistrySection", "FavoritesSection")
    if sec = invalid then
        showToast("⚠ Error al acceder a favoritos", "#F44336")
        return
    end if
    
    ' Verificar si ya existe por URL (evita IDs inválidos/largos)
    existingKey = findFavoriteKeyByUrl(urlStr)
    if existingKey <> invalid then
        ' Toggle completo: permitir quitar desde cualquier vista
        sec.Delete(existingKey)
        sec.Flush()

        if not sec.Exists(existingKey) then
            print "[toggleFavorite] ✓ Favorito eliminado correctamente del Registry"

            newFavorites = []
            for each fav in m.favorites
                if fav.name <> channelData.name or fav.url <> channelData.url then
                    newFavorites.Push(fav)
                end if
            end for
            m.favorites = newFavorites

            rebuildFavoritesIndex()

            ' Actualizar badge en el item actual
            if item <> invalid then
                item.addFields({isFavorite: false})
            end if

            showToast("🗑️ Favorito eliminado: " + channelData.name, "#F44336")

            ' Si estamos en vista de Favoritos, recargar el listado
            if m.currentPlaylist <> invalid and m.currentPlaylist.name = "⭐ FAVORITOS GLOBALES" then
                showFavoritesAsChannels()
            end if
        else
            print "[toggleFavorite] ✗ ERROR: No se pudo eliminar del Registry"
            showToast("⚠ Error al eliminar favorito", "#F44336")
        end if
    else
        ' Agregar a favoritos
        favId = makeFavoriteKeyForUrl(urlStr)
        if sec.Exists(favId) then
            favId = favId + "_" + CreateObject("roDateTime").AsSeconds().ToStr()
        end if

        favoriteItem = {
            name: channelData.name
            url: channelData.url
            logo: channelData.logo
            group: channelData.group
        }
        
        jsonStr = FormatJson(favoriteItem)
        if jsonStr <> invalid and jsonStr <> "" then
            sec.Write(favId, jsonStr)
            sec.Flush()
            
            ' Verificar que se guardó
            if sec.Exists(favId) then
                print "[toggleFavorite] ✓ Favorito guardado correctamente en Registry"
                print "[toggleFavorite] Favorito ID: " + favId
                
                m.favorites.Push(favoriteItem)

                rebuildFavoritesIndex()

                ' Actualizar badge en el item actual (sin recargar todo)
                if item <> invalid then
                    item.addFields({isFavorite: true})
                end if
                
                print "[toggleFavorite] Total favoritos ahora: " + m.favorites.Count().ToStr()
                
                showToast("⭐ " + channelData.name + " agregado a favoritos", "#4CAF50")
            else
                print "[toggleFavorite] ✗ ERROR: No se pudo verificar el guardado"
                showToast("⚠ Error al guardar favorito", "#F44336")
            end if
        else
            print "[toggleFavorite] ✗ ERROR: FormatJson falló"
            showToast("⚠ Error al formatear datos", "#F44336")
        end if
    end if
    
    ' Actualizar home grid si está visible
    if m.navigationLevel = 0 then
        showHomeGrid()
    end if
end sub

' Eliminar playlist seleccionada (tecla *)
sub deletePlaylist()
    if m.homeGrid = invalid or m.homeGrid.content = invalid then
        return
    end if
    
    index = m.homeGrid.itemFocused
    if index < 0 then return
    
    item = m.homeGrid.content.getChild(index)
    if item = invalid then
        showToast("⚠ No se puede eliminar este item", "#FF9800")
        return
    end if

    cardType = invalid
    if item.DoesExist("cardType") then cardType = item.cardType
    if cardType <> "playlist" then
        showToast("⚠ No se pueden eliminar las tarjetas del sistema", "#FF9800")
        return
    end if

    playlistData = invalid
    if item.DoesExist("playlistData") and item.playlistData <> invalid then
        playlistData = item.playlistData
    else
        playlistData = {id: item.playlistId, name: item.title, url: item.playlistUrl}
    end if
    playlistId = playlistData.id
    
    ' Eliminar del Registry
    sec = CreateObject("roRegistrySection", "PlaylistsSection")
    if sec <> invalid then
        if sec.Exists(playlistId) then
            sec.Delete(playlistId)
            sec.Flush()
            
            ' Eliminar del array local
            newPlaylists = []
            for each p in m.playlists
                if p.id <> playlistId then
                    newPlaylists.Push(p)
                end if
            end for
            m.playlists = newPlaylists
            
            ' Eliminar caché de la playlist también
            cacheRegistry = CreateObject("roRegistrySection", "CacheSection")
            if cacheRegistry <> invalid and cacheRegistry.Exists(playlistId) then
                cacheRegistry.Delete(playlistId)
                cacheRegistry.Flush()
            end if
            
            showToast("🗑️ Playlist eliminada: " + playlistData.name, "#F44336")
            
            ' Recargar home grid
            showHomeGrid()
        else
            showToast("⚠ Playlist no encontrada", "#FF9800")
        end if
    end if
end sub

' Eliminar favorito seleccionado (tecla REPLAY)
sub deleteFavorite()
    if m.channelsGrid = invalid or m.channelsGrid.content = invalid then
        return
    end if
    
    index = m.channelsGrid.itemFocused
    if index < 0 then return
    
    item = m.channelsGrid.content.getChild(index)
    if item = invalid or item.channelData = invalid then
        showToast("⚠ No se puede eliminar este canal", "#FF9800")
        return
    end if
    
    channelData = item.channelData

    urlStr = channelData.url
    
    sec = CreateObject("roRegistrySection", "FavoritesSection")
    favKey = findFavoriteKeyByUrl(urlStr)
    if sec <> invalid and favKey <> invalid and sec.Exists(favKey) then
        sec.Delete(favKey)
        sec.Flush()
        
        ' Actualizar array local
        newFavorites = []
        for each fav in m.favorites
            if fav.name <> channelData.name or fav.url <> channelData.url then
                newFavorites.Push(fav)
            end if
        end for
        m.favorites = newFavorites

        rebuildFavoritesIndex()
        
        showToast("🗑️ Favorito eliminado: " + channelData.name, "#F44336")
        
        ' Recargar lista de favoritos
        showFavoritesAsChannels()
    else
        showToast("⚠ Este canal no está en favoritos", "#FF9800")
    end if
end sub

' *************************************************************
' TECLAS
' *************************************************************
function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    ' Si está abierto el dialog de agregar playlist, BACK debe cerrarlo
    if key = "back" then
        if m.addPlaylistKeyboard <> invalid and m.addPlaylistKeyboard.visible then
            m.addPlaylistKeyboard.visible = false
            ' Mantener una UI consistente
            if m.navigationLevel = 0 then
                setActiveMainView("home")
                if m.homeGrid <> invalid then m.homeGrid.setFocus(true)
            else if m.navigationLevel = 1 then
                setActiveMainView("categories")
                if m.categoriesGrid <> invalid then m.categoriesGrid.setFocus(true)
            else if m.navigationLevel = 2 then
                setActiveMainView("channels")
                if m.channelsGrid <> invalid then m.channelsGrid.setFocus(true)
            end if
            return true
        end if
    end if
    
    ' Tecla * para agregar a favoritos (y borrar SOLO dentro de Favoritos) o eliminar playlist
    if key = "options" or key = "*" then
        if m.navigationLevel = 2 and m.channelsGrid.visible then
            if m.currentPlaylist <> invalid and m.currentPlaylist.name = "⭐ FAVORITOS GLOBALES" then
                deleteFavorite()
            else
                toggleFavorite()
            end if
            return true
        else if m.navigationLevel = 0 and m.homeGrid.visible then
            ' Eliminar playlist cuando se está en home
            deletePlaylist()
            return true
        end if
    else if key = "left" then
        if not m.sidebarActive then 
            toggleSidebar(true)
            return true
        end if
    else if key = "right" then
        if m.sidebarActive then
            toggleSidebar(false)
            return true
        end if
    else if key = "back" then
        if m.sidebarActive then
            toggleSidebar(false)
            return true
        end if
        
        if m.navigationLevel = 3 then
            if m.player <> invalid then m.player.finished = true
            return true
        else if m.navigationLevel = 2 then
            if m.currentPlaylist <> invalid and m.currentPlaylist.name = "⭐ FAVORITOS GLOBALES" then
                showHomeGrid()
            else
                ' Volver a categorías. Nota: categoriesGrid.content se limpia al entrar a canales,
                ' así que hay que reconstruir la vista desde m.currentCategories.
                if m.currentCategories <> invalid and GetInterface(m.currentCategories, "ifAssociativeArray") <> invalid and m.currentCategories.Count() > 0 then
                    m.navigationLevel = 1
                    displayCategories()
                else
                    ' Vistas como "Recientes" / "Más vistos" no tienen categorías
                    showHomeGrid()
                end if
            end if
            return true
        else if m.navigationLevel = 1 then
            showHomeGrid()
            return true
        end if
    end if
    return false
end function

' *************************************************************
' UTILIDADES
' *************************************************************
sub onGridFocusChange(event as object)
    if event = invalid then return
    
    grid = event.getRoSGNode()
    if grid = invalid or grid.content = invalid then return
    
    index = event.getData()
    if index < 0 or index >= grid.content.getChildCount() then return
    
    item = grid.content.getChild(index)
    if item = invalid then return
    
    ' Hero Background (removido en diseño minimalista)
    ' statusLabel también removido
end sub

    ' Centraliza la visibilidad de las vistas principales para evitar overlays al navegar rápido.
    sub setActiveMainView(view as string)
        if m.homeGrid <> invalid then m.homeGrid.visible = false
        if m.categoriesGrid <> invalid then m.categoriesGrid.visible = false
        if m.channelsGrid <> invalid then m.channelsGrid.visible = false
        if m.skeletonGrid <> invalid then m.skeletonGrid.visible = false

        if view = "home" then
            if m.homeGrid <> invalid then m.homeGrid.visible = true
        else if view = "categories" then
            if m.categoriesGrid <> invalid then m.categoriesGrid.visible = true
        else if view = "channels" then
            if m.channelsGrid <> invalid then m.channelsGrid.visible = true
        else if view = "skeleton" then
            if m.skeletonGrid <> invalid then m.skeletonGrid.visible = true
        end if
    end sub

sub showLoadingSkeleton(loading as boolean)
    if loading then
        dummy = CreateObject("roSGNode", "ContentNode")
        for i=0 to 11
            dummy.createChild("ContentNode")
        end for
        m.skeletonGrid.content = dummy
        m.skeletonGrid.visible = true
        setActiveMainView("skeleton")
    else
        m.skeletonGrid.visible = false
    end if
end sub

sub showAddPlaylistDialog()
    if m.addPlaylistKeyboard <> invalid then
        m.addPlaylistKeyboard.title = "Agregar Playlist"
        m.addPlaylistKeyboard.buttons = ["Guardar", "Cancelar"]
        m.addPlaylistKeyboard.visible = true
        m.addPlaylistKeyboard.setFocus(true)
    end if
end sub

sub openSearchDialog()
    print "[MainScene] Opening search dialog"
    if m.searchDialog <> invalid then
        m.searchDialog.visible = true
        ' NO establecer foco aquí - el keyboard dialog lo tomará automáticamente
    end if
end sub

sub openSettingsDialog()
    if m.settingsDialog <> invalid then
        m.settingsDialog.visible = true
        m.settingsDialog.setFocus(true)
    end if
end sub

' Cuando el settings dialog se cierra, devolver foco al grid activo
sub onSettingsDialogVisibleChange()
    if m.settingsDialog <> invalid and not m.settingsDialog.visible then
        ' Devolver el foco al grid activo según navigationLevel
        if m.navigationLevel = 0 and m.homeGrid <> invalid then
            m.homeGrid.setFocus(true)
        else if m.navigationLevel = 1 and m.categoriesGrid <> invalid then
            m.categoriesGrid.setFocus(true)
        else if m.navigationLevel = 2 and m.channelsGrid <> invalid then
            m.channelsGrid.setFocus(true)
        end if
    end if
end sub

' Cuando el search dialog se cierra, devolver foco al grid activo
sub onSearchDialogVisibleChange()
    if m.searchDialog <> invalid and not m.searchDialog.visible then
        ' Devolver el foco al grid activo según navigationLevel
        if m.navigationLevel = 0 and m.homeGrid <> invalid then
            m.homeGrid.setFocus(true)
        else if m.navigationLevel = 1 and m.categoriesGrid <> invalid then
            m.categoriesGrid.setFocus(true)
        else if m.navigationLevel = 2 and m.channelsGrid <> invalid then
            m.channelsGrid.setFocus(true)
        end if
    end if
end sub

sub onAddPlaylistButton(event as object)
    buttonIndex = event.getData()
    
    if m.addPlaylistKeyboard = invalid then return
    
    if buttonIndex = 0 then ' Guardar
        url = m.addPlaylistKeyboard.text
        
        if url = invalid or url = "" then
            showToast("⚠ Debes ingresar una URL", "#FF9800")
            return
        end if
        
        ' Validar que sea una URL válida
        if not url.Instr("http") = 0 then
            showToast("⚠ URL inválida (debe comenzar con http)", "#FF9800")
            return
        end if
        
        ' Generar nombre basado en URL
        playlistName = "Playlist " + (m.playlists.Count() + 1).ToStr()
        
        ' Generar ID único con timestamp
        playlistId = "pl_" + CreateObject("roDateTime").AsSeconds().ToStr()
        
        ' Crear playlist
        newPlaylist = {
            id: playlistId
            name: playlistName
            url: url
        }
        
        ' Guardar en registry con verificación
        sec = CreateObject("roRegistrySection", "PlaylistsSection")
        if sec <> invalid then
            jsonStr = FormatJson(newPlaylist)
            if jsonStr <> invalid and jsonStr <> "" then
                sec.Write(playlistId, jsonStr)
                sec.Flush()
                
                ' Verificar que se guardó correctamente
                if sec.Exists(playlistId) then
                    print "[AddPlaylist] ✓ Playlist guardada correctamente en Registry"
                    
                    ' Agregar al array local
                    m.playlists.Push(newPlaylist)
                    
                    ' Cerrar dialog
                    m.addPlaylistKeyboard.visible = false
                    
                    ' Mostrar confirmación y recargar
                    showToast("✓ Playlist agregada: " + playlistName, "#4CAF50")
                    showHomeGrid()
                    
                    ' Cargar automáticamente la nueva playlist
                    m.currentPlaylist = newPlaylist
                    loadPlaylistCategories()
                else
                    print "[AddPlaylist] ✗ ERROR: No se pudo verificar el guardado"
                    showToast("⚠ Error al guardar playlist", "#F44336")
                end if
            else
                print "[AddPlaylist] ✗ ERROR: FormatJson falló"
                showToast("⚠ Error al formatear datos", "#F44336")
            end if
        else
            print "[AddPlaylist] ✗ ERROR: No se pudo crear Registry Section"
            showToast("⚠ Error al acceder al almacenamiento", "#F44336")
        end if
        
    else ' Cancelar
        m.addPlaylistKeyboard.visible = false
        if m.homeGrid <> invalid then
            m.homeGrid.setFocus(true)
        end if
    end if
end sub

sub onSettingChanged(event as object)
    data = event.getData()
    if data = invalid then return
    
    print "[MainScene] Setting changed: " + data.key
    
    if data.key = "clearCache" then
        showToast("✓ Caché limpiado correctamente", "#4CAF50")
        ' NO recargar - solo mantener el diálogo abierto
        ' El usuario puede seguir navegando en configuración
    else if data.key = "reset" then
        showToast("✓ Configuración restablecida a valores por defecto", "#4CAF50")
        ' Aplicar configuración por defecto
        applyResponsiveLayout()
    else if data.key = "gridSize" then
        showToast("✓ Tamaño de grid actualizado: " + data.value.ToStr(), "#4CAF50")
        ' Aplicar nuevo tamaño de grid
        applyGridSize(data.value)
    else if data.key = "theme" then
        showToast("✓ Tema cambiado: " + data.value, "#4CAF50")
        ' Aplicar nuevo tema
        applyTheme(data.value)
    else if data.key = "streamQuality" then
        showToast("✓ Calidad de stream: " + data.value, "#4CAF50")
    else if data.key = "language" then
        showToast("✓ Idioma actualizado", "#4CAF50")
    else if data.key = "autoplay" then
        if data.value then
            showToast("✓ Autoplay activado", "#4CAF50")
        else
            showToast("✓ Autoplay desactivado", "#FF9800")
        end if
    else if data.key = "analytics" then
        if data.value then
            showToast("✓ Analytics activado", "#4CAF50")
        else
            showToast("✓ Analytics desactivado", "#FF9800")
        end if
    else if data.key = "subtitles" then
        if data.value then
            showToast("✓ Subtítulos activados", "#4CAF50")
        else
            showToast("✓ Subtítulos desactivados", "#FF9800")
        end if
    else
        showToast("✓ Configuración actualizada", "#4CAF50")
    end if
end sub

sub onSearchResult(event as object)
    data = event.getData()
    if data = invalid then return
    
    ' Manejar errores
    if data.error <> invalid then
        if data.error = "empty" then
            showToast("Debes escribir algo para buscar", "#1A1A1A")
        else if data.error = "short" then
            showToast("Escribe al menos 3 caracteres", "#1A1A1A")
        else if data.error = "cancelled" then
            print "[MainScene] Search cancelled by user"
        end if
        return
    end if
    
    ' Búsqueda exitosa
    if data.success and data.query <> invalid then
        query = data.query
        print "[MainScene] Performing search for: "; query

        ' Búsqueda global: cargar/indexar todas las playlists y luego buscar
        startGlobalSearch(query)
    end if
end sub


' *************************************************************
' BÚSQUEDA GLOBAL (todas las playlists)
' *************************************************************

' Inicia (o reutiliza) el índice de canales de todas las playlists y ejecuta la búsqueda.
sub startGlobalSearch(query as string)
    if query = invalid then return
    q = query.Trim()
    if q = "" then return

    m.searchPendingQuery = q

    ' 1) Indexar lo que ya esté disponible desde caché (sin red)
    buildSearchIndexFromCache()

    ' 2) Determinar playlists que faltan por cargar
    m.searchLoadQueue = []
    m.searchLoadQueuePos = 0

    if m.playlists <> invalid and GetInterface(m.playlists, "ifArray") <> invalid then
        for each p in m.playlists
            if p <> invalid and GetInterface(p, "ifAssociativeArray") <> invalid then
                pid = p.id
                if pid <> invalid and pid <> "" then
                    if not m.searchIndexLoadedPlaylists.DoesExist(pid) then
                        ' Si no está en caché, se agrega a la cola de carga
                        m.searchLoadQueue.Push(p)
                    end if
                end if
            end if
        end for
    end if

    if m.searchLoadQueue.Count() = 0 then
        ' Todo listo; buscar inmediatamente
        results = performGlobalSearchOnIndex(q)
        if results.Count() = 0 then
            showToast("No se encontraron canales", "#1A1A1A")
        else
            displaySearchResults(results, q)
            showToast(results.Count().ToStr() + " canales encontrados", "#1A1A1A")
        end if
        return
    end if

    ' 3) Cargar playlists faltantes en background (secuencial) y luego buscar
    if not m.searchIndexBuilding then
        m.searchIndexBuilding = true
        showLoadingSkeleton(true)
        showToast("Cargando listas para buscar...", "#1A1A1A")
        loadNextPlaylistForSearchIndex()
    end if
end sub

' Indexa playlists desde caché (si están vigentes) para evitar red.
sub buildSearchIndexFromCache()
    if m.playlists = invalid or GetInterface(m.playlists, "ifArray") = invalid then return

    maxAge = GetSetting("cacheMaxAge", 24)

    for each p in m.playlists
        if p <> invalid and GetInterface(p, "ifAssociativeArray") <> invalid then
            pid = p.id
            if pid <> invalid and pid <> "" then
                if not m.searchIndexLoadedPlaylists.DoesExist(pid) then
                    cached = GetCachedPlaylist(pid, maxAge)
                    if cached <> invalid and cached.categories <> invalid then
                        addCategoriesToSearchIndex(cached.categories, p.name, pid)
                    end if
                end if
            end if
        end if
    end for

    ' También indexar la playlist actualmente abierta si está cargada (aunque no esté en caché)
    if m.currentPlaylist <> invalid and GetInterface(m.currentPlaylist, "ifAssociativeArray") <> invalid then
        pid = m.currentPlaylist.id
        if pid <> invalid and pid <> "" then
            if not m.searchIndexLoadedPlaylists.DoesExist(pid) then
                if m.currentCategories <> invalid and GetInterface(m.currentCategories, "ifAssociativeArray") <> invalid then
                    addCategoriesToSearchIndex(m.currentCategories, m.currentPlaylist.name, pid)
                end if
            end if
        end if
    end if
end sub

' Carga secuencialmente playlists faltantes para completar el índice.
sub loadNextPlaylistForSearchIndex()
    if m.searchLoadQueue = invalid or m.searchLoadQueuePos >= m.searchLoadQueue.Count() then
        ' Terminado
        m.searchIndexBuilding = false
        showLoadingSkeleton(false)

        q = m.searchPendingQuery
        results = performGlobalSearchOnIndex(q)
        if results.Count() = 0 then
            showToast("No se encontraron canales", "#1A1A1A")
        else
            displaySearchResults(results, q)
            showToast(results.Count().ToStr() + " canales encontrados", "#1A1A1A")
        end if
        return
    end if

    p = m.searchLoadQueue[m.searchLoadQueuePos]
    m.searchLoadQueuePos = m.searchLoadQueuePos + 1

    if p = invalid or GetInterface(p, "ifAssociativeArray") = invalid then
        loadNextPlaylistForSearchIndex()
        return
    end if

    if p.url = invalid or p.url = "" then
        loadNextPlaylistForSearchIndex()
        return
    end if

    m.searchLoadingPlaylist = p
    m.searchLoaderTask = CreateObject("roSGNode", "M3ULoaderTask")
    m.searchLoaderTask.observeField("result", "onSearchPlaylistLoaded")
    m.searchLoaderTask.url = p.url
    m.searchLoaderTask.control = "RUN"
end sub

sub onSearchPlaylistLoaded(event as object)
    result = event.getData()
    p = m.searchLoadingPlaylist

    if p <> invalid and GetInterface(p, "ifAssociativeArray") <> invalid then
        pid = p.id
        if pid <> invalid and pid <> "" then
            if result <> invalid and result.error = invalid and result.categories <> invalid then
                ' Guardar en caché y agregar al índice
                CachePlaylist(pid, result)
                addCategoriesToSearchIndex(result.categories, p.name, pid)
            else
                print "[MainScene] WARN: No se pudo cargar playlist para búsqueda: "; p.name
                if result <> invalid and result.error <> invalid then
                    print "[MainScene] Error: "; result.error
                end if
                ' Marcar como procesada para no reintentar en bucle
                m.searchIndexLoadedPlaylists[pid] = true
            end if
        end if
    end if

    loadNextPlaylistForSearchIndex()
end sub

' Agrega categorías/canales al índice global (aplana AA -> array)
sub addCategoriesToSearchIndex(categories as object, playlistName as string, playlistId as string)
    if categories = invalid or GetInterface(categories, "ifAssociativeArray") = invalid then return
    if playlistId = invalid or playlistId = "" then return

    for each catName in categories
        channels = categories[catName]
        if channels <> invalid and GetInterface(channels, "ifArray") <> invalid then
            for each channel in channels
                if channel <> invalid and GetInterface(channel, "ifAssociativeArray") <> invalid then
                    ' Enriquecer canal para UI/analytics
                    channel.categoryName = catName
                    channel.playlistName = playlistName
                    channel.playlistId = playlistId
                    m.searchIndexChannels.Push(channel)
                end if
            end for
        end if
    end for

    m.searchIndexLoadedPlaylists[playlistId] = true
end sub

' Ejecuta la búsqueda sobre el índice global ya cargado
function performGlobalSearchOnIndex(query as string) as object
    results = []
    q = LCase(query)

    if m.searchIndexChannels = invalid or GetInterface(m.searchIndexChannels, "ifArray") = invalid then
        return results
    end if

    for each channel in m.searchIndexChannels
        if channel <> invalid and GetInterface(channel, "ifAssociativeArray") <> invalid then
            if channel.name <> invalid then
                channelName = LCase(channel.name)
                if channelName.Instr(q) >= 0 then
                    results.Push(channel)
                end if
            end if
        end if
    end for

    print "[MainScene] Found "; results.Count(); " channels matching '"; q; "'"
    return results
end function

' Mostrar resultados de búsqueda
sub displaySearchResults(results as object, query as string)
    if m.channelsGrid = invalid or results.Count() = 0 then return

    m.isSearchResultsView = true

    ' Agrupar por orden (playlist -> categoría -> nombre)
    results = sortChannelsForSearchResults(results)
    
    ' Cambiar a vista de canales
    setActiveMainView("channels")
    
    ' Crear ContentNode con los resultados
    content = CreateObject("roSGNode", "ContentNode")
    for each channel in results
        node = content.createChild("ContentNode")
        node.title = channel.name
        if channel.logo <> invalid then
            node.hdPosterUrl = channel.logo
        end if
        node.url = channel.url

        ' Mantener compatibilidad con el flujo normal (reproducción/analytics)
        fields = {
            streamUrl: channel.url
            channelData: channel
        }
        fields.isFavorite = isFavoriteChannel(channel)
        if channel.playlistName <> invalid and channel.playlistName <> "" then
            fields.playlistName = channel.playlistName
        else if m.currentPlaylist <> invalid and m.currentPlaylist.name <> invalid then
            fields.playlistName = m.currentPlaylist.name
        end if
        node.addFields(fields)
        
        ' Mostrar categoría como descripción
        if channel.playlistName <> invalid and channel.playlistName <> "" then
            if channel.categoryName <> invalid and channel.categoryName <> "" then
                node.description = channel.playlistName + " / " + channel.categoryName
            else
                node.description = channel.playlistName
            end if
        else if channel.categoryName <> invalid then
            node.description = channel.categoryName
        end if
    end for
    
    m.channelsGrid.content = content
    m.channelsGrid.setFocus(true)
    m.channelsGrid.jumpToItem = 0
    
    ' Actualizar nivel de navegación
    m.navigationLevel = 2
    
    print "[MainScene] Displaying "; results.Count(); " search results"
end sub

' *************************************************************
' ORDENAMIENTO DE RESULTADOS (agrupación por orden)
' *************************************************************

function sortChannelsForSearchResults(channels as object) as object
    if channels = invalid then return channels
    if GetInterface(channels, "ifArray") = invalid then return channels
    if channels.Count() < 2 then return channels

    keys = []
    for each ch in channels
        keys.Push(makeSearchSortKey(ch))
    end for

    quickSortParallel(keys, channels, 0, channels.Count() - 1)
    return channels
end function

function makeSearchSortKey(channel as object) as string
    pl = ""
    cat = ""
    nm = ""

    if channel <> invalid and GetInterface(channel, "ifAssociativeArray") <> invalid then
        if channel.playlistName <> invalid then pl = channel.playlistName
        if channel.categoryName <> invalid then cat = channel.categoryName
        if channel.name <> invalid then nm = channel.name
    end if

    sep = Chr(9)
    ' Orden: nombre de canal -> playlist -> categoría
    return LCase(nm) + sep + LCase(pl) + sep + LCase(cat)
end function

sub quickSortParallel(keys as object, items as object, low as integer, high as integer)
    if low >= high then return

    p = partitionParallel(keys, items, low, high)
    if p > low then quickSortParallel(keys, items, low, p - 1)
    if p < high then quickSortParallel(keys, items, p + 1, high)
end sub

function partitionParallel(keys as object, items as object, low as integer, high as integer) as integer
    pivot = keys[high]
    i = low - 1

    for j = low to high - 1
        if keys[j] <= pivot then
            i = i + 1
            swapParallel(keys, items, i, j)
        end if
    end for

    swapParallel(keys, items, i + 1, high)
    return i + 1
end function

sub swapParallel(keys as object, items as object, i as integer, j as integer)
    if i = j then return

    tmpKey = keys[i]
    keys[i] = keys[j]
    keys[j] = tmpKey

    tmpItem = items[i]
    items[i] = items[j]
    items[j] = tmpItem
end sub

sub showToast(msg as string, color as string)
    if m.toastLabel <> invalid and m.toastBackground <> invalid then
        ' Remover emojis y simplificar mensaje
        cleanMsg = msg
        cleanMsg = cleanMsg.Replace("✓ ", "")
        cleanMsg = cleanMsg.Replace("⚠ ", "")
        cleanMsg = cleanMsg.Replace("❌ ", "")
        cleanMsg = cleanMsg.Replace("⭐ ", "")
        cleanMsg = cleanMsg.Replace("🗑️ ", "")
        
        m.toastLabel.text = cleanMsg
        
        ' Color minimalista siempre igual
        m.toastBackground.color = "#1A1A1A"
        
        ' Animación de entrada sutil
        m.toastBackground.opacity = 0.0
        m.toastBackground.visible = true
        
        fadeIn = CreateObject("roSGNode", "Animation")
        fadeIn.duration = 0.2
        fadeIn.easeFunction = "linear"
        interpIn = CreateObject("roSGNode", "FloatFieldInterpolator")
        interpIn.key = [0.0, 1.0]
        interpIn.keyValue = [0.0, 0.95]
        interpIn.fieldToInterp = "toastBackground.opacity"
        fadeIn.appendChild(interpIn)
        m.top.appendChild(fadeIn)
        fadeIn.control = "start"
        
        ' Auto-ocultar después de 1.5 segundos
        timer = CreateObject("roSGNode", "Timer")
        timer.duration = 1.5
        timer.repeat = false
        timer.observeField("fire", "hideToast")
        m.toastTimer = timer 
        timer.control = "start"
    end if
end sub

sub hideToast()
    if m.toastBackground <> invalid then
        ' Animación de salida sutil
        fadeOut = CreateObject("roSGNode", "Animation")
        fadeOut.duration = 0.2
        fadeOut.easeFunction = "linear"
        interpOut = CreateObject("roSGNode", "FloatFieldInterpolator")
        interpOut.key = [0.0, 1.0]
        interpOut.keyValue = [0.95, 0.0]
        interpOut.fieldToInterp = "toastBackground.opacity"
        fadeOut.appendChild(interpOut)
        fadeOut.observeField("state", "onToastFadeComplete")
        m.toastFadeOut = fadeOut
        m.top.appendChild(fadeOut)
        fadeOut.control = "start"
    end if
end sub

sub onToastFadeComplete(event as object)
    state = event.getData()
    if state = "stopped" and m.toastBackground <> invalid then
        m.toastBackground.visible = false
    end if
end sub
' *************************************************************
' LOCAL MANAGER FUNCTIONS (replican source/ managers)
' *************************************************************

' === SETTINGS MANAGER ===
sub InitSettings()
    m.settingsRegistry = CreateObject("roRegistrySection", "SettingsSection")
    
    ' Escribir defaults si no existen (uno por uno para mantener keys correctas)
    if not m.settingsRegistry.Exists("cacheMaxAge")
        m.settingsRegistry.Write("cacheMaxAge", "24")
    end if
    if not m.settingsRegistry.Exists("gridSize")
        m.settingsRegistry.Write("gridSize", "4x3")
    end if
    if not m.settingsRegistry.Exists("theme")
        m.settingsRegistry.Write("theme", "dark")
    end if
    if not m.settingsRegistry.Exists("autoplay")
        m.settingsRegistry.Write("autoplay", "false")
    end if
    if not m.settingsRegistry.Exists("analytics")
        m.settingsRegistry.Write("analytics", "true")
    end if
    if not m.settingsRegistry.Exists("streamQuality")
        m.settingsRegistry.Write("streamQuality", "auto")
    end if
    if not m.settingsRegistry.Exists("subtitles")
        m.settingsRegistry.Write("subtitles", "true")
    end if
    if not m.settingsRegistry.Exists("language")
        m.settingsRegistry.Write("language", "es")
    end if
    
    m.settingsRegistry.Flush()
end sub

function GetSetting(key as string, defaultValue as dynamic) as dynamic
    if m.settingsRegistry = invalid then
        m.settingsRegistry = CreateObject("roRegistrySection", "SettingsSection")
    end if
    
    if m.settingsRegistry.Exists(key)
        value = m.settingsRegistry.Read(key)
        ' Convert to appropriate type
        if defaultValue <> invalid then
            if type(defaultValue) = "roInt" or type(defaultValue) = "Integer"
                return value.ToInt()
            else if type(defaultValue) = "roBoolean" or type(defaultValue) = "Boolean"
                return (value = "true")
            end if
        end if
        return value
    end if
    return defaultValue
end function

' Load and apply saved settings on startup
sub loadAndApplySettings()
    ' Get saved settings
    gridSize = GetSetting("gridSize", "4x3")
    theme = GetSetting("theme", "dark")
    
    ' Apply grid size
    if gridSize <> invalid then
        applyGridSize(gridSize)
    end if
    
    ' Apply theme
    if theme <> invalid then
        applyTheme(theme)
    end if
    
    print "Settings loaded and applied: gridSize="; gridSize; " theme="; theme
end sub

' === CACHE MANAGER ===
function GetCachedPlaylist(playlistId as string, maxAgeHours as integer) as object
    cacheRegistry = CreateObject("roRegistrySection", "CacheSection")
    
    if not cacheRegistry.Exists(playlistId) then
        return invalid
    end if
    
    ' Check timestamp
    timestampKey = playlistId + "_timestamp"
    if not cacheRegistry.Exists(timestampKey) then
        return invalid
    end if
    
    timestamp = cacheRegistry.Read(timestampKey).ToInt()
    now = CreateObject("roDateTime").AsSeconds()
    ageHours = (now - timestamp) / 3600
    
    if ageHours > maxAgeHours then
        return invalid ' Cache expired
    end if
    
    ' Parse cached data
    cachedJson = cacheRegistry.Read(playlistId)
    return ParseJson(cachedJson)
end function

function CachePlaylist(playlistId as string, data as object) as boolean
    cacheRegistry = CreateObject("roRegistrySection", "CacheSection")
    if cacheRegistry = invalid then
        print "[CachePlaylist] ERROR: No se pudo crear CacheSection"
        return false
    end if
    
    ' Serialize data
    jsonString = FormatJson(data)
    if jsonString = invalid or jsonString = "" then
        print "[CachePlaylist] ERROR: FormatJson falló"
        return false
    end if
    
    ' Save data
    cacheRegistry.Write(playlistId, jsonString)
    
    ' Save timestamp
    timestamp = CreateObject("roDateTime").AsSeconds()
    cacheRegistry.Write(playlistId + "_timestamp", timestamp.ToStr())
    
    cacheRegistry.Flush()
    
    ' Verify save
    if cacheRegistry.Exists(playlistId) then
        print "[CachePlaylist] ✓ Cache guardado correctamente para: " + playlistId
        return true
    else
        print "[CachePlaylist] ✗ ERROR: No se pudo verificar el guardado"
        return false
    end if
end function

' === ANALYTICS MANAGER ===
sub LogChannelView(channelData as object, durationSeconds as integer)
    analyticsEnabled = GetSetting("analytics", true)
    if not analyticsEnabled then return
    
    analyticsRegistry = CreateObject("roRegistrySection", "AnalyticsSection")
    if analyticsRegistry = invalid then
        print "[LogChannelView] ERROR: No se pudo crear AnalyticsSection"
        return
    end if
    
    if channelData = invalid then return

    channelName = ""
    playlistName = ""
    channelUrl = ""
    channelLogo = ""
    channelGroup = ""

    if channelData.DoesExist("name") and channelData.name <> invalid then channelName = channelData.name
    if channelData.DoesExist("playlistName") and channelData.playlistName <> invalid then playlistName = channelData.playlistName
    if channelData.DoesExist("url") and channelData.url <> invalid then channelUrl = channelData.url
    if channelData.DoesExist("logo") and channelData.logo <> invalid then channelLogo = channelData.logo
    if channelData.DoesExist("group") and channelData.group <> invalid then channelGroup = channelData.group
    if channelData.DoesExist("categoryName") and channelGroup = "" and channelData.categoryName <> invalid then channelGroup = channelData.categoryName

    ' Generate key (prefer URL for replayability)
    key = channelUrl
    if key = invalid or key = "" then key = channelName + "|" + playlistName
    key = key.Replace(" ", "_").Replace("/", "_").Replace(":", "_")
    
    ' Read existing data
    if analyticsRegistry.Exists(key)
        jsonStr = analyticsRegistry.Read(key)
        if jsonStr <> invalid and jsonStr <> "" then
            data = ParseJson(jsonStr)
            if data <> invalid then
                data.views = data.views + 1
                data.totalDuration = data.totalDuration + durationSeconds
                data.lastViewed = CreateObject("roDateTime").AsSeconds()

                ' Backfill richer fields for older records
                if channelName <> "" then data.channelName = channelName
                if playlistName <> "" then data.playlistName = playlistName
                if channelUrl <> "" then data.channelUrl = channelUrl
                if channelLogo <> "" then data.channelLogo = channelLogo
                if channelGroup <> "" then data.channelGroup = channelGroup
            else
                ' JSON parse failed, create new
                data = {
                    channelName: channelName
                    playlistName: playlistName
                    channelUrl: channelUrl
                    channelLogo: channelLogo
                    channelGroup: channelGroup
                    views: 1
                    totalDuration: durationSeconds
                    lastViewed: CreateObject("roDateTime").AsSeconds()
                }
            end if
        else
            ' Read failed, create new
            data = {
                channelName: channelName
                playlistName: playlistName
                channelUrl: channelUrl
                channelLogo: channelLogo
                channelGroup: channelGroup
                views: 1
                totalDuration: durationSeconds
                lastViewed: CreateObject("roDateTime").AsSeconds()
            }
        end if
    else
        data = {
            channelName: channelName
            playlistName: playlistName
            channelUrl: channelUrl
            channelLogo: channelLogo
            channelGroup: channelGroup
            views: 1
            totalDuration: durationSeconds
            lastViewed: CreateObject("roDateTime").AsSeconds()
        }
    end if
    
    ' Save with verification
    jsonStr = FormatJson(data)
    if jsonStr <> invalid and jsonStr <> "" then
        analyticsRegistry.Write(key, jsonStr)
        analyticsRegistry.Flush()
        
        if analyticsRegistry.Exists(key) then
            print "[LogChannelView] ✓ Analytics guardado: " + key + " (vistas: " + data.views.ToStr() + ")"
        else
            print "[LogChannelView] ✗ ERROR: No se pudo verificar el guardado"
        end if
    else
        print "[LogChannelView] ✗ ERROR: FormatJson falló"
    end if
end sub

function GetMostViewedChannels(limit as integer) as object
    analyticsRegistry = CreateObject("roRegistrySection", "AnalyticsSection")
    keys = analyticsRegistry.GetKeyList()
    
    channels = []
    for each key in keys
        if not key.InStr("_error_") > -1 then
            data = ParseJson(analyticsRegistry.Read(key))
            if data <> invalid then
                channels.Push(data)
            end if
        end if
    end for
    
    ' Sort by views (bubble sort)
    for i = 0 to channels.Count() - 1
        for j = 0 to channels.Count() - 2 - i
            if channels[j].views < channels[j + 1].views then
                temp = channels[j]
                channels[j] = channels[j + 1]
                channels[j + 1] = temp
            end if
        end for
    end for
    
    ' Limit results
    if channels.Count() > limit then
        result = []
        for i = 0 to limit - 1
            result.Push(channels[i])
        end for
        return result
    end if
    
    return channels
end function

sub LogError(errorType as string, message as string, context as string)
    errorRegistry = CreateObject("roRegistrySection", "ErrorLogSection")
    
    timestamp = CreateObject("roDateTime").AsSeconds()
    key = errorType + "_" + timestamp.ToStr()
    
    errorData = {
        type: errorType
        message: message
        context: context
        timestamp: timestamp
    }
    
    errorRegistry.Write(key, FormatJson(errorData))
    errorRegistry.Flush()
    
    print "[ERROR] " + errorType + ": " + message
end sub

function GetCacheInfo(playlistId as string) as object
    cacheRegistry = CreateObject("roRegistrySection", "CacheSection")
    
    if not cacheRegistry.Exists(playlistId) then
        return {exists: false}
    end if
    
    timestampKey = playlistId + "_timestamp"
    if not cacheRegistry.Exists(timestampKey) then
        return {exists: false}
    end if
    
    timestamp = cacheRegistry.Read(timestampKey).ToInt()
    now = CreateObject("roDateTime").AsSeconds()
    ageSeconds = now - timestamp
    ageHours = Int(ageSeconds / 3600)
    
    return {
        exists: true
        ageHours: ageHours
        ageSeconds: ageSeconds
        timestamp: timestamp
    }
end function

function GetRecentChannels(limit as integer) as object
    analyticsRegistry = CreateObject("roRegistrySection", "AnalyticsSection")
    keys = analyticsRegistry.GetKeyList()
    
    channels = []
    for each key in keys
        if not key.InStr("_error_") > -1 then
            data = ParseJson(analyticsRegistry.Read(key))
            if data <> invalid then
                channels.Push(data)
            end if
        end if
    end for
    
    ' Sort by lastViewed (bubble sort)
    for i = 0 to channels.Count() - 1
        for j = 0 to channels.Count() - 2 - i
            if channels[j].lastViewed < channels[j + 1].lastViewed then
                temp = channels[j]
                channels[j] = channels[j + 1]
                channels[j + 1] = temp
            end if
        end for
    end for
    
    ' Limit results
    if channels.Count() > limit then
        result = []
        for i = 0 to limit - 1
            result.Push(channels[i])
        end for
        return result
    end if
    
    return channels
end function

' ===========================
' RESPONSIVE LAYOUT FUNCTIONS
' ===========================

' Detect screen resolution and setup responsive parameters
function setupResponsiveLayout() as object
    ' ============================================
    ' CÁLCULOS DINÁMICOS CON RODEVICEINFO
    ' ============================================
    ' Get screen resolution dynamically
    di = CreateObject("roDeviceInfo")
    resolution = di.GetDisplaySize()
    
    ' Default to 1920x1080 if detection fails
    screenWidth = 1920
    screenHeight = 1080
    
    if resolution <> invalid then
        screenWidth = resolution.w
        screenHeight = resolution.h
        print "[ResponsiveLayout] Screen detected: "; screenWidth; "x"; screenHeight
    else
        print "[ResponsiveLayout] WARNING: Could not detect screen, using default 1920x1080"
    end if
    
    ' ============================================
    ' AUTOSCALING - DISEÑO PARA 1080p (divisible por 3)
    ' ============================================
    ' Calculate scale factors based on 1920x1080 (FHD) as reference
    ' IMPORTANTE: 720p es exactamente 2/3 de 1080p, por eso usamos múltiplos de 3
    scaleX = screenWidth / 1920.0
    scaleY = screenHeight / 1080.0
    
    ' Use minimum scale to maintain aspect ratio
    scale = scaleX
    if scaleY < scaleX then scale = scaleY
    
    ' ============================================
    ' DIMENSIONES BASE - TODAS DIVISIBLES POR 3
    ' ============================================
    ' Para 1080p: 381, 240, 24, 21, 144, 150
    ' Para 720p: se escalan automáticamente a 254, 160, 16, 14, 96, 100
    
    ' Create responsive parameters object
    responsive = {
        screenWidth: screenWidth
        screenHeight: screenHeight
        scaleX: scaleX
        scaleY: scaleY
        scale: scale
        
        ' ============================================
        ' HOME GRID - Dimensiones divisibles por 3
        ' ============================================
        homeGridWidth: Int(381 * scale)        ' 381 / 3 = 127
        homeGridHeight: Int(240 * scale)       ' 240 / 3 = 80
        homeGridSpacingX: Int(24 * scale)      ' 24 / 3 = 8
        homeGridSpacingY: Int(24 * scale)      ' 24 / 3 = 8
        homeGridTranslationX: Int(144 * scale) ' 144 / 3 = 48 (sidebar width)
        homeGridTranslationY: Int(150 * scale) ' 150 / 3 = 50
        homeGridNumColumns: 4
        homeGridNumRows: 3
        
        ' ============================================
        ' CHANNELS GRID - Dimensiones divisibles por 3
        ' ============================================
        channelsGridWidth: Int(279 * scale)    ' 279 / 3 = 93
        channelsGridHeight: Int(198 * scale)   ' 198 / 3 = 66
        channelsGridSpacingX: Int(21 * scale)  ' 21 / 3 = 7
        channelsGridSpacingY: Int(21 * scale)  ' 21 / 3 = 7
        channelsGridTranslationX: Int(144 * scale)
        channelsGridTranslationY: Int(150 * scale)
        channelsGridNumColumns: 5
        channelsGridNumRows: 3
        
        ' ============================================
        ' CATEGORIES GRID - Dimensiones divisibles por 3
        ' ============================================
        categoriesGridWidth: Int(351 * scale)  ' 351 / 3 = 117
        categoriesGridHeight: Int(198 * scale) ' 198 / 3 = 66
        categoriesGridSpacingX: Int(24 * scale)
        categoriesGridSpacingY: Int(24 * scale)
        categoriesGridTranslationX: Int(144 * scale)
        categoriesGridTranslationY: Int(150 * scale)
        categoriesGridNumColumns: 4
        categoriesGridNumRows: 3
        
        ' ============================================
        ' SIDEBAR - Dimensiones divisibles por 3
        ' ============================================
        sidebarWidth: Int(144 * scale)         ' 144 / 3 = 48
        sidebarTranslationY: Int(150 * scale)
        
        ' ============================================
        ' HEADER - Dimensiones divisibles por 3
        ' ============================================
        headerTranslationY: Int(45 * scale)    ' 45 / 3 = 15
        headerFontSize: Int(42 * scale)        ' 42 / 3 = 14
        
        ' ============================================
        ' LOADING ELEMENTS - Centralizados dinámicamente
        ' ============================================
        loadingLabelTranslationX: Int(screenWidth / 2)
        loadingLabelTranslationY: Int(screenHeight / 2)
        loadingSpinnerTranslationX: Int(screenWidth / 2 - 45 * scale) ' centrado - radius/2
        loadingSpinnerTranslationY: Int(screenHeight / 2 - 45 * scale)
        loadingLabelFontSize: Int(33 * scale)  ' 33 / 3 = 11
        
        ' ============================================
        ' TOAST MESSAGE - Dimensiones divisibles por 3
        ' ============================================
        toastTranslationX: Int((screenWidth - 600 * scale) / 2)
        toastTranslationY: Int(screenHeight - 150 * scale)
        toastWidth: Int(600 * scale)           ' 600 / 3 = 200
        toastHeight: Int(81 * scale)           ' 81 / 3 = 27
        toastFontSize: Int(30 * scale)         ' 30 / 3 = 10
        
        ' ============================================
        ' SKELETON LOADING - Dimensiones divisibles por 3
        ' ============================================
        skeletonGridWidth: Int(381 * scale)
        skeletonGridHeight: Int(240 * scale)
        skeletonGridSpacingX: Int(24 * scale)
        skeletonGridSpacingY: Int(24 * scale)
        skeletonGridTranslationX: Int(144 * scale)
        skeletonGridTranslationY: Int(150 * scale)
    }
    
    ' ============================================
    ' AJUSTE DINÁMICO DE COLUMNAS SEGÚN RESOLUCIÓN
    ' ============================================
    if screenWidth >= 3840 then ' 4K (3840x2160)
        responsive.homeGridNumColumns = 7
        responsive.channelsGridNumColumns = 9
        responsive.categoriesGridNumColumns = 6
        print "[ResponsiveLayout] 4K mode: 7/9/6 columns"
    else if screenWidth >= 1920 then ' Full HD (1920x1080)
        responsive.homeGridNumColumns = 4
        responsive.channelsGridNumColumns = 5
        responsive.categoriesGridNumColumns = 4
        print "[ResponsiveLayout] FHD mode: 4/5/4 columns"
    else if screenWidth >= 1280 then ' HD (1280x720)
        responsive.homeGridNumColumns = 3
        responsive.channelsGridNumColumns = 4
        responsive.categoriesGridNumColumns = 3
        print "[ResponsiveLayout] HD mode: 3/4/3 columns"
    else ' SD (menor a 720p)
        responsive.homeGridNumColumns = 2
        responsive.channelsGridNumColumns = 3
        responsive.categoriesGridNumColumns = 2
        print "[ResponsiveLayout] SD mode: 2/3/2 columns"
    end if
    
    print "[ResponsiveLayout] ✓ Initialized: "; screenWidth; "x"; screenHeight; " | Scale="; scale; " | Base values divisible by 3"
    
    ' Store in module scope for access in other functions
    m.responsive = responsive
    
    return responsive
end function

' Apply responsive layout to all UI elements
sub applyResponsiveLayout()
    if m.responsive = invalid then
        print "[ResponsiveLayout] ERROR: m.responsive is invalid"
        return
    end if
    
    print "[ResponsiveLayout] Applying responsive layout..."
    
    ' ============================================
    ' APPLY TO HOME GRID
    ' ============================================
    if m.homeGrid <> invalid then
        m.homeGrid.itemSize = [m.responsive.homeGridWidth, m.responsive.homeGridHeight]
        m.homeGrid.itemSpacing = [m.responsive.homeGridSpacingX, m.responsive.homeGridSpacingY]
        m.homeGrid.translation = [m.responsive.homeGridTranslationX, m.responsive.homeGridTranslationY]
        m.homeGrid.numColumns = m.responsive.homeGridNumColumns
        m.homeGrid.numRows = m.responsive.homeGridNumRows
        print "[ResponsiveLayout] ✓ Home grid: "; m.responsive.homeGridWidth; "x"; m.responsive.homeGridHeight; " | "; m.responsive.homeGridNumColumns; "x"; m.responsive.homeGridNumRows
    end if
    
    ' ============================================
    ' APPLY TO CATEGORIES GRID
    ' ============================================
    if m.categoriesGrid <> invalid then
        m.categoriesGrid.itemSize = [m.responsive.categoriesGridWidth, m.responsive.categoriesGridHeight]
        m.categoriesGrid.itemSpacing = [m.responsive.categoriesGridSpacingX, m.responsive.categoriesGridSpacingY]
        m.categoriesGrid.translation = [m.responsive.categoriesGridTranslationX, m.responsive.categoriesGridTranslationY]
        m.categoriesGrid.numColumns = m.responsive.categoriesGridNumColumns
        m.categoriesGrid.numRows = m.responsive.categoriesGridNumRows
        print "[ResponsiveLayout] ✓ Categories grid: "; m.responsive.categoriesGridWidth; "x"; m.responsive.categoriesGridHeight
    end if
    
    ' ============================================
    ' APPLY TO CHANNELS GRID
    ' ============================================
    if m.channelsGrid <> invalid then
        m.channelsGrid.itemSize = [m.responsive.channelsGridWidth, m.responsive.channelsGridHeight]
        m.channelsGrid.itemSpacing = [m.responsive.channelsGridSpacingX, m.responsive.channelsGridSpacingY]
        m.channelsGrid.translation = [m.responsive.channelsGridTranslationX, m.responsive.channelsGridTranslationY]
        m.channelsGrid.numColumns = m.responsive.channelsGridNumColumns
        m.channelsGrid.numRows = m.responsive.channelsGridNumRows
        print "[ResponsiveLayout] ✓ Channels grid: "; m.responsive.channelsGridWidth; "x"; m.responsive.channelsGridHeight
    end if
    
    ' ============================================
    ' APPLY TO SKELETON GRID
    ' ============================================
    if m.skeletonGrid <> invalid then
        m.skeletonGrid.itemSize = [m.responsive.skeletonGridWidth, m.responsive.skeletonGridHeight]
        m.skeletonGrid.itemSpacing = [m.responsive.skeletonGridSpacingX, m.responsive.skeletonGridSpacingY]
        m.skeletonGrid.translation = [m.responsive.skeletonGridTranslationX, m.responsive.skeletonGridTranslationY]
        print "[ResponsiveLayout] ✓ Skeleton grid applied"
    end if
    
    ' ============================================
    ' APPLY TO SIDEBAR
    ' ============================================
    if m.sidebar <> invalid then
        m.sidebar.width = m.responsive.sidebarWidth
        m.sidebar.translation = [0, m.responsive.sidebarTranslationY]
        print "[ResponsiveLayout] ✓ Sidebar: width="; m.responsive.sidebarWidth
    end if
    
    if m.sidebarBackground <> invalid then
        m.sidebarBackground.width = m.responsive.sidebarWidth
        m.sidebarBackground.height = m.responsive.screenHeight
    end if
    
    ' ============================================
    ' APPLY TO HEADER (si existe)
    ' ============================================
    if m.headerLabel <> invalid then
        m.headerLabel.translation = [m.responsive.homeGridTranslationX, m.responsive.headerTranslationY]
        m.headerLabel.font.size = m.responsive.headerFontSize
        print "[ResponsiveLayout] ✓ Header positioned"
    end if
    
    ' ============================================
    ' APPLY TO LOADING ELEMENTS
    ' ============================================
    if m.loadingLabel <> invalid then
        m.loadingLabel.translation = [m.responsive.loadingLabelTranslationX, m.responsive.loadingLabelTranslationY]
        m.loadingLabel.font.size = m.responsive.loadingLabelFontSize
    end if
    
    if m.loadingSpinner <> invalid then
        m.loadingSpinner.translation = [m.responsive.loadingSpinnerTranslationX, m.responsive.loadingSpinnerTranslationY]
        print "[ResponsiveLayout] ✓ Loading elements centered"
    end if
    
    ' ============================================
    ' APPLY TO TOAST MESSAGE
    ' ============================================
    if m.toastBackground <> invalid then
        m.toastBackground.translation = [m.responsive.toastTranslationX, m.responsive.toastTranslationY]
        m.toastBackground.width = m.responsive.toastWidth
        m.toastBackground.height = m.responsive.toastHeight
    end if
    
    if m.toastLabel <> invalid then
        m.toastLabel.translation = [m.responsive.toastTranslationX + 20, m.responsive.toastTranslationY + 15]
        m.toastLabel.width = m.responsive.toastWidth - 40
        m.toastLabel.font.size = m.responsive.toastFontSize
        print "[ResponsiveLayout] ✓ Toast message positioned"
    end if
    
    print "[ResponsiveLayout] ✓✓✓ All elements applied successfully! ✓✓✓"
end sub

' ===========================
' SETTINGS FUNCTIONS
' ===========================

' Apply grid size from settings
sub applyGridSize(gridSize as string)
    if gridSize = invalid or m.responsive = invalid then return
    
    ' Parse grid size (e.g., "4x3" -> 4 columns, 3 rows)
    parts = gridSize.Split("x")
    if parts.Count() = 2 then
        columns = parts[0].ToInt()
        rows = parts[1].ToInt()
        
        if columns > 0 and rows > 0 then
            ' Update responsive parameters
            m.responsive.homeGridNumColumns = columns
            m.responsive.homeGridNumRows = rows
            m.responsive.channelsGridNumColumns = columns + 1
            m.responsive.channelsGridNumRows = rows
            
            ' Apply to grids
            if m.homeGrid <> invalid then
                m.homeGrid.numColumns = m.responsive.homeGridNumColumns
                m.homeGrid.numRows = m.responsive.homeGridNumRows
            end if
            
            if m.channelsGrid <> invalid then
                m.channelsGrid.numColumns = m.responsive.channelsGridNumColumns
                m.channelsGrid.numRows = m.responsive.channelsGridNumRows
            end if
            
            print "Grid size applied: "; columns; "x"; rows
        end if
    end if
end sub

' Apply theme from settings
sub applyTheme(theme as string)
    if theme = invalid then return
    
    if theme = "light" then
        ' Light theme colors
        if m.background <> invalid then
            m.background.color = "#F5F5F5"
        end if
        
        if m.sidebarBackground <> invalid then
            m.sidebarBackground.color = "#EEEEEE"
            m.sidebarBackground.opacity = 0.95
        end if
        
        if m.headerLabel <> invalid then
            m.headerLabel.color = "#D32F2F"
        end if
        
        if m.loadingLabel <> invalid then
            m.loadingLabel.color = "#212121"
        end if
        
        print "Light theme applied"
    else
        ' Dark theme colors (default)
        if m.background <> invalid then
            m.background.color = "#0A0A0A"
        end if
        
        if m.sidebarBackground <> invalid then
            m.sidebarBackground.color = "#000000"
            m.sidebarBackground.opacity = 0.95
        end if
        
        if m.headerLabel <> invalid then
            m.headerLabel.color = "#E50914"
        end if
        
        if m.loadingLabel <> invalid then
            m.loadingLabel.color = "#FFFFFF"
        end if
        
        print "Dark theme applied"
    end if
end sub

' *************************************************************
' FAVORITOS - ÍNDICE (para UI rápida)
' *************************************************************

sub rebuildFavoritesIndex()
    m.favoritesIndex = {}
    if m.favorites = invalid or GetInterface(m.favorites, "ifArray") = invalid then return

    for each fav in m.favorites
        if fav <> invalid and GetInterface(fav, "ifAssociativeArray") <> invalid then
            if fav.url <> invalid and fav.url <> "" then
                m.favoritesIndex[fav.url] = true
            end if
            if fav.name <> invalid and fav.name <> "" then
                m.favoritesIndex["name:" + LCase(fav.name)] = true
            end if
        end if
    end for
end sub

function isFavoriteUrl(url as string) as boolean
    if url = invalid or url = "" then return false
    if m.favoritesIndex = invalid then return false
    if GetInterface(m.favoritesIndex, "ifAssociativeArray") = invalid then return false
    return m.favoritesIndex.DoesExist(url)
end function

function isFavoriteChannel(channel as object) as boolean
    if channel = invalid or GetInterface(channel, "ifAssociativeArray") = invalid then return false
    if channel.DoesExist("url") and channel.url <> invalid and channel.url <> "" then
        if isFavoriteUrl(channel.url) then return true
    end if
    if channel.DoesExist("name") and channel.name <> invalid and channel.name <> "" then
        if m.favoritesIndex <> invalid and m.favoritesIndex.DoesExist("name:" + LCase(channel.name)) then return true
    end if
    return false
end function

sub onAddPlaylistVisibleChange()
    ' Si el dialog de agregar se cierra (por cancel o back), restaurar foco
    if m.addPlaylistKeyboard <> invalid and not m.addPlaylistKeyboard.visible then
        if m.navigationLevel = 0 and m.homeGrid <> invalid then
            m.homeGrid.setFocus(true)
        else if m.navigationLevel = 1 and m.categoriesGrid <> invalid then
            m.categoriesGrid.setFocus(true)
        else if m.navigationLevel = 2 and m.channelsGrid <> invalid then
            m.channelsGrid.setFocus(true)
        end if
    end if
end sub

' Busca un favorito existente por URL y devuelve la key del Registry.
function findFavoriteKeyByUrl(url as string) as dynamic
    if url = invalid or url = "" then return invalid

    sec = CreateObject("roRegistrySection", "FavoritesSection")
    if sec = invalid then return invalid

    keys = sec.GetKeyList()
    for each key in keys
        json = sec.Read(key)
        if json <> invalid and json <> "" then
            fav = ParseJson(json)
            if fav <> invalid and GetInterface(fav, "ifAssociativeArray") <> invalid then
                if fav.url <> invalid and fav.url = url then
                    return key
                end if
            end if
        end if
    end for

    return invalid
end function

' Genera una key corta y estable basada solo en la URL.
function makeFavoriteKeyForUrl(url as string) as string
    if url = invalid then return "fav_invalid"

    urlStr = url
    tailLen = 64
    tail = urlStr
    if urlStr.Len() > tailLen then
        tail = urlStr.Mid(urlStr.Len() - tailLen, tailLen)
    end if

    key = "fav_" + urlStr.Len().ToStr() + "_" + tail
    ' Sanitizar caracteres problemáticos para keys
    key = key.Replace(" ", "_")
    key = key.Replace("/", "_")
    key = key.Replace(":", "_")
    key = key.Replace("?", "_")
    key = key.Replace("&", "_")
    key = key.Replace("=", "_")
    key = key.Replace("#", "_")
    key = key.Replace("%", "_")
    key = key.Replace(".", "_")
    key = key.Replace(",", "_")
    key = key.Replace("'", "_")

    ' Limitar longitud
    maxLen = 120
    if key.Len() > maxLen then
        key = key.Left(maxLen)
    end if

    return key
end function

' *************************************************************
' Fire AppLaunchComplete Beacon
' Requerido para certificación Roku - Performance 3.2
' *************************************************************
sub fireAppLaunchCompleteBeacon()
    ' Usar signalBeacon() según la documentación oficial de Roku
    ' https://developer.roku.com/docs/developer-program/performance/measuring-channel-performance.md
    m.top.signalBeacon("AppLaunchComplete")
    print "[Beacon] AppLaunchComplete beacon fired via signalBeacon()"
end sub

' *************************************************************
' Handle Deep Link Arguments
' Maneja los argumentos de deep linking cuando llegan
' Basado en ejemplo oficial: https://github.com/rokudev/deep-linking-samples
' *************************************************************
sub onDeepLinkArgs(event as Object)
    if event = invalid then return

    ' Obtener el payload del deep link
    args = invalid
    if type(event) = "roSGNodeEvent" then
        args = event.getData()
    else if type(event) = "roAssociativeArray" then
        args = event
    end if
    
    if args = invalid then return

    ' Extraer contentId y mediaType (según ejemplo oficial)
    contentId = invalid
    mediaType = invalid
    
    if args.DoesExist("contentId") then contentId = args.contentId
    if args.DoesExist("mediaType") then mediaType = args.mediaType
    
    print "[DeepLink] contentId: "; contentId; " mediaType: "; mediaType

    ' Validar que tenemos los parámetros requeridos
    if contentId <> invalid and contentId <> "" then
        ' Validar mediaType y ejecutar comportamiento apropiado
        if validateDeepLink(contentId, mediaType) then
            handleDeepLinkPlayback(contentId, mediaType)
        else
            print "[DeepLink] Invalid deep link, showing home screen"
        end if
    else
        print "[DeepLink] Missing contentId, showing home screen"
    end if
end sub

' Valida los parámetros del deep link según certificación
function validateDeepLink(contentId as String, mediaType as String) as Boolean
    ' Lista de mediaTypes válidos según certificación Roku
    validMediaTypes = {
        movie: "movie"
        episode: "episode"
        season: "season"
        series: "series"
        shortformvideo: "shortFormVideo"
        tvspecial: "tvSpecial"
        live: "live"
    }
    
    if contentId = invalid or contentId = "" then
        print "[DeepLink] Invalid contentId"
        return false
    end if
    
    if mediaType <> invalid and mediaType <> "" then
        mediaTypeLower = LCase(mediaType)
        if validMediaTypes[mediaTypeLower] = invalid then
            print "[DeepLink] Unknown mediaType: "; mediaType
            ' Aceptamos mediaTypes desconocidos para mejor UX
            return true
        end if
    end if
    
    return true
end function

' Maneja la reproducción según el deep link
sub handleDeepLinkPlayback(contentId as String, mediaType as String)
    print "[DeepLink] Handling playback for contentId: "; contentId
    playContentById(contentId, mediaType)
end sub

' Intentar reproducir contenido por ID o URL (usado por deep linking)
' Implementa requisitos de certificación 5.1 para todos los mediaTypes
sub playContentById(contentId as String, mediaType as String)
    if contentId = invalid or contentId = "" then
        print "[DeepLink] Invalid contentId, launching home screen"
        return
    end if
    
    print "[playContentById] contentId:"; contentId; " mediaType:"; mediaType
    
    ' Normalizar mediaType (case-insensitive según documentación)
    mediaTypeLower = ""
    if mediaType <> invalid and mediaType <> "" then
        mediaTypeLower = LCase(mediaType)
    end if

    ' Si es una URL directa, lanzar el player con ella
    lower = LCase(contentId)
    if lower.Left(7) = "http://" or lower.Left(8) = "https://" or lower.IndexOf("m3u8") <> -1 then
        ' Reproducción directa para cualquier mediaType que sea URL
        launchPlayer(contentId, "Deep Link - " + mediaType, 0)
        return
    end if

    ' Buscar en las playlists predefinidas por ID (def1-def6)
    if m.playlists <> invalid and m.playlists.Count() > 0 then
        for each pl in m.playlists
            if pl <> invalid and pl.DoesExist("id") and pl.id = contentId then
                print "[playContentById] Playlist encontrada: "; pl.name
                
                ' Según certificación: movie, episode, series, shortFormVideo, tvSpecial
                ' requieren reproducción directa. Season puede mostrar picker (opcional).
                ' Para IPTV, tratamos todas las playlists como "live" y reproducimos
                ' el primer canal disponible.
                
                m.deepLinkAutoPlay = true
                m.currentPlaylist = pl
                ' Cargar la playlist con el task
                m.loaderTask = CreateObject("roSGNode", "M3ULoaderTask")
                m.loaderTask.observeField("result", "onDeepLinkPlaylistLoaded")
                m.loaderTask.url = pl.url
                m.loaderTask.control = "RUN"
                return
            end if
        end for
    end if

    ' Buscar en canales cargados por ID o nombre
    ' Esto maneja cuando el contentId es un canal específico
    if m.playlists <> invalid then
        for each pl in m.playlists
            if pl <> invalid and pl.DoesExist("channels") and pl.channels <> invalid then
                for i = 0 to pl.channels.Count() - 1
                    ch = pl.channels[i]
                    if ch <> invalid then
                        ' Buscar por ID exacto
                        if ch.DoesExist("id") and ch.id = contentId then
                            ' Reproducción directa según mediaType
                            launchPlayerForMediaType(ch.url, ch.name, i, mediaTypeLower)
                            return
                        end if
                        ' Buscar por nombre (case-insensitive)
                        if ch.DoesExist("name") and LCase(ch.name) = LCase(contentId) then
                            launchPlayerForMediaType(ch.url, ch.name, i, mediaTypeLower)
                            return
                        end if
                    end if
                end for
            end if
        end for
    end if

    ' ContentId no encontrado - según certificación, mostrar home screen
    print "[playContentById] Content not found for contentId: "; contentId; " - showing home screen"
    ' Ya estamos en home screen por defecto, no hacer nada
end sub

' Lanzar player según el mediaType requerido por certificación
sub launchPlayerForMediaType(url as String, title as String, index as Integer, mediaType as String)
    ' Según certificación Roku 5.1:
    ' - movie, episode, shortFormVideo, tvSpecial: reproducción directa con bookmarks
    ' - series: reproducción directa con smart bookmarks
    ' - season: puede mostrar picker (opcional para IPTV no aplica)
    
    if mediaType = "movie" or mediaType = "episode" or mediaType = "shortformvideo" or mediaType = "tvspecial" then
        ' Reproducción directa (bookmarks se manejan automáticamente en VideoPlayer)
        print "[DeepLink] Playing "; mediaType; " directly: "; title
        launchPlayer(url, title, index)
    else if mediaType = "series" then
        ' Reproducción directa con smart bookmarks
        ' Para IPTV, simplemente reproducimos el contenido
        print "[DeepLink] Playing series directly: "; title
        launchPlayer(url, title, index)
    else if mediaType = "season" then
        ' Opcional: mostrar picker de episodios
        ' Para IPTV, reproducimos directamente
        print "[DeepLink] Playing season content: "; title
        launchPlayer(url, title, index)
    else if mediaType = "live" or mediaType = "" then
        ' Contenido live/streaming (común en IPTV)
        print "[DeepLink] Playing live content: "; title
        launchPlayer(url, title, index)
    else
        ' MediaType no reconocido - reproducir de todos modos (mejor UX)
        print "[DeepLink] Unknown mediaType, playing anyway: "; title
        launchPlayer(url, title, index)
    end if
end sub

' Callback para cuando se carga una playlist desde deep link
sub onDeepLinkPlaylistLoaded(event as object)
    result = event.getData()
    if result.error <> invalid then
        print "[DeepLink] Error al cargar playlist: "; result.error
        return
    end if
    
    print "[DeepLink] Playlist cargada, buscando primer canal disponible"
    
    ' Obtener el primer canal disponible de cualquier categoría
    if result.categories <> invalid and result.categories.Count() > 0 then
        for each catName in result.categories.Keys()
            channels = result.categories[catName]
            if channels <> invalid and channels.Count() > 0 then
                ' Reproducir el primer canal
                firstChannel = channels[0]
                if firstChannel <> invalid and firstChannel.DoesExist("url") and firstChannel.url <> invalid then
                    print "[DeepLink] Reproduciendo: "; firstChannel.name
                    launchPlayer(firstChannel.url, firstChannel.name, 0)
                    return
                end if
            end if
        end for
    end if
    
    print "[DeepLink] No se encontraron canales reproducibles en la playlist"
end sub