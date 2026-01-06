' *************************************************************
' Ultimate IPTV 2026 - Video Player Component MEJORADO
' 
' Descripción: Reproductor profesional con:
' - Cambio de canal (anterior/siguiente)
' - Lista lateral de canales
' - Controles espaciados y funcionales
' - Info detallada del canal actual
' *************************************************************

sub init()
    ' Referencias a nodos principales
    m.videoNode = m.top.findNode("videoNode")
    m.controlsOverlay = m.top.findNode("controlsOverlay")
    m.channelTitle = m.top.findNode("channelTitle")
    m.channelCategory = m.top.findNode("channelCategory")
    m.channelCounter = m.top.findNode("channelCounter")
    m.channelLogo = m.top.findNode("channelLogo")
    m.playbackInfo = m.top.findNode("playbackInfo")
    m.bufferingGroup = m.top.findNode("bufferingGroup")
    m.loadingGroup = m.top.findNode("loadingGroup")
    m.loadingChannelName = m.top.findNode("loadingChannelName")
    m.switchStatusGroup = m.top.findNode("switchStatusGroup")
    m.switchStatusLabel = m.top.findNode("switchStatusLabel")
    m.playPauseLabel = m.top.findNode("playPauseLabel")
    
    ' Setup closed captions según configuración global del sistema (Requisito 4.8)
    setupClosedCaptions()
    
    ' Panel de lista de canales
    m.channelListPanel = m.top.findNode("channelListPanel")
    m.channelListView = m.top.findNode("channelListView")
    m.browserTitle = m.top.findNode("browserTitle")
    
    ' Variables de estado
    m.overlayVisible = false
    m.overlayTimer = invalid
    m.channelListVisible = false
    m.currentChannels = []

    ' Navegador (Listas -> Categorías -> Canales)
    m.browserLevel = 0 ' 0 playlists, 1 categories, 2 channels
    m.browserSelectedPlaylist = invalid
    m.browserSelectedCategory = invalid
    m.browserCategories = invalid
    m.browserChannelList = []
    m.browserNavMode = "channel" ' "channel" hasta que el usuario use up/down; luego "menu"
    m.browserTouchedList = false
    m.browserLoaderTask = invalid
    m.favoritesIndex = {}

    ' Evita que onChannelListSet resetee el navegador en cada cambio
    m.browserInitialized = false

    ' Estado de cambio/cancelación de canal
    m.switchInProgress = false
    m.switchPrevUrl = ""
    m.switchPrevIndex = 0
    
    ' Bookmarking (Requisito 4.10)
    m.bookmarkTimer = invalid
    m.lastBookmarkPosition = 0
    m.bookmarkInterval = 10 ' Guardar cada 10 segundos
    
    ' Timeout para streams lentos (certificación 3.6 - 8 segundos)
    m.streamTimeoutTimer = invalid
    m.streamTimeout = 6 ' 6 segundos para dar margen
    m.isDeepLinkPlayback = false
    
    ' Observers
    m.top.observeField("streamUrl", "onStreamUrlSet")
    m.top.observeField("title", "onTitleSet")
    m.top.observeField("channelList", "onChannelListSet")
    m.top.observeField("currentChannelIndex", "updateChannelInfo")
    m.videoNode.observeField("state", "onVideoStateChange")
    m.videoNode.observeField("position", "onPositionChange")
    m.videoNode.observeField("position", "onPositionChangeForBookmark")
    
    if m.channelListView <> invalid then
        m.channelListView.observeField("itemSelected", "onBrowserItemSelected")
    end if

    buildFavoritesIndex()
    
    ' Focus al player
    m.top.setFocus(true)
    
    print "[VideoPlayer] Initialized with advanced controls"
end sub

' Mostrar feedback inmediato al cambiar de canal
sub beginChannelSwitchFeedback(channel as object)
    labelText = "Cambiando canal..."
    if channel <> invalid and GetInterface(channel, "ifAssociativeArray") <> invalid then
        if channel.name <> invalid and channel.name <> "" then
            labelText = "Cambiando canal: " + channel.name
        end if
    end if

    if m.switchStatusLabel <> invalid then
        m.switchStatusLabel.text = labelText
    end if
    if m.switchStatusGroup <> invalid then
        m.switchStatusGroup.visible = true
    end if

    ' Mantener feedback también en overlay si está visible
    if m.playbackInfo <> invalid then
        m.playbackInfo.text = "Cambiando canal..."
        m.playbackInfo.color = "#888888"
    end if
end sub

sub endChannelSwitchFeedback()
    if m.switchStatusGroup <> invalid then
        m.switchStatusGroup.visible = false
    end if
end sub

sub cancelChannelSwitch()
    if not m.switchInProgress then return

    m.switchInProgress = false
    endChannelSwitchFeedback()

    ' Cancelar intento actual
    if m.videoNode <> invalid then
        m.videoNode.control = "stop"
    end if

    ' Volver al canal anterior
    if m.switchPrevUrl <> invalid and m.switchPrevUrl <> "" then
        m.top.streamUrl = m.switchPrevUrl
    end if
    m.top.currentChannelIndex = m.switchPrevIndex
    updateChannelInfo()

    if m.playbackInfo <> invalid then
        m.playbackInfo.text = "Cancelado"
        m.playbackInfo.color = "#888888"
    end if
end sub

' *************************************************************
' Favoritos (para mostrar estrella dentro del reproductor)
' *************************************************************

sub buildFavoritesIndex()
    m.favoritesIndex = {}

    sec = CreateObject("roRegistrySection", "FavoritesSection")
    if sec = invalid then return

    keys = sec.GetKeyList()
    for each key in keys
        json = sec.Read(key)
        if json <> invalid and json <> "" then
            fav = ParseJson(json)
            if fav <> invalid and GetInterface(fav, "ifAssociativeArray") <> invalid then
                if fav.url <> invalid and fav.url <> "" then
                    m.favoritesIndex[fav.url] = true
                end if
            end if
        end if
    end for
end sub

function findFavoriteKeyByUrlLocal(url as string) as dynamic
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

function makeFavoriteKeyForUrlLocal(url as string) as string
    if url = invalid then return "fav_invalid"

    urlStr = url
    tailLen = 64
    tail = urlStr
    if urlStr.Len() > tailLen then
        tail = urlStr.Mid(urlStr.Len() - tailLen, tailLen)
    end if

    key = "fav_" + urlStr.Len().ToStr() + "_" + tail
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

    maxLen = 120
    if key.Len() > maxLen then
        key = key.Left(maxLen)
    end if
    return key
end function

sub toggleFavoriteCurrentChannel()
    if m.currentChannels = invalid or m.currentChannels.Count() = 0 then return

    idx = m.top.currentChannelIndex
    if idx < 0 or idx >= m.currentChannels.Count() then return

    ch = m.currentChannels[idx]
    if ch = invalid or GetInterface(ch, "ifAssociativeArray") = invalid then return

    url = invalid
    if ch.url <> invalid then url = ch.url
    if url = invalid or url = "" then
        if m.playbackInfo <> invalid then
            m.playbackInfo.text = "⚠ No se puede guardar favorito"
            m.playbackInfo.color = "#FF4444"
        end if
        return
    end if

    sec = CreateObject("roRegistrySection", "FavoritesSection")
    if sec = invalid then return

    existingKey = findFavoriteKeyByUrlLocal(url)
    if existingKey <> invalid then
        sec.Delete(existingKey)
        sec.Flush()
        buildFavoritesIndex()

        ch.isFavorite = false
        if m.playbackInfo <> invalid then
            m.playbackInfo.text = "🗑️ Quitado de favoritos"
            m.playbackInfo.color = "#888888"
        end if
    else
        favId = makeFavoriteKeyForUrlLocal(url)
        if sec.Exists(favId) then
            favId = favId + "_" + CreateObject("roDateTime").AsSeconds().ToStr()
        end if

        favItem = {
            name: ch.name
            url: url
            logo: ch.logo
            group: ""
        }
        if ch.categoryName <> invalid and ch.categoryName <> "" then favItem.group = ch.categoryName
        if ch.group <> invalid and ch.group <> "" then favItem.group = ch.group

        jsonStr = FormatJson(favItem)
        if jsonStr <> invalid and jsonStr <> "" then
            sec.Write(favId, jsonStr)
            sec.Flush()
            buildFavoritesIndex()

            ch.isFavorite = true
            if m.playbackInfo <> invalid then
                m.playbackInfo.text = "⭐ Agregado a favoritos"
                m.playbackInfo.color = "#888888"
            end if
        end if
    end if

    ' Si el navegador está mostrando canales, actualizar estrella del item actual
    if m.channelListVisible and m.browserLevel = 2 and m.channelListView <> invalid and m.channelListView.content <> invalid then
        focused = m.channelListView.itemFocused
        if focused >= 0 and focused < m.channelListView.content.getChildCount() then
            node = m.channelListView.content.getChild(focused)
            if node <> invalid then
                node.addFields({isFavorite: isFavoriteUrl(url)})
            end if
        end if
    end if
end sub

' *************************************************************
' Settings/Cache (local) - los scripts de componentes no ven funciones de /source
' *************************************************************

function getSettingLocal(key as string, defaultValue as dynamic) as dynamic
    sec = CreateObject("roRegistrySection", "SettingsSection")
    if sec = invalid then return defaultValue

    value = sec.Read(key)
    if value = "" or value = invalid then return defaultValue

    parsed = ParseJson(value)
    if parsed = invalid then return defaultValue
    return parsed
end function

function getCachedPlaylistLocal(playlistId as string, maxAgeHours as integer) as object
    if playlistId = invalid or playlistId = "" then return invalid

    sec = CreateObject("roRegistrySection", "CacheSection")
    if sec = invalid then return invalid

    jsonStr = sec.Read("cache_" + playlistId)
    if jsonStr = "" or jsonStr = invalid then return invalid

    cacheData = ParseJson(jsonStr)
    if cacheData = invalid then return invalid

    now = CreateObject("roDateTime").AsSeconds()
    age = now - cacheData.timestamp
    maxAge = maxAgeHours * 3600
    if age > maxAge then return invalid

    return cacheData.data
end function

sub cachePlaylistLocal(playlistId as string, data as object)
    if playlistId = invalid or playlistId = "" then return
    if data = invalid then return

    sec = CreateObject("roRegistrySection", "CacheSection")
    if sec = invalid then return

    cacheData = {
        data: data
        timestamp: CreateObject("roDateTime").AsSeconds()
        playlistId: playlistId
    }
    jsonStr = FormatJson(cacheData)
    if jsonStr <> invalid and jsonStr <> "" then
        sec.Write("cache_" + playlistId, jsonStr)
        sec.Flush()
    end if
end sub

function isFavoriteUrl(url as string) as boolean
    if url = invalid or url = "" then return false
    if m.favoritesIndex = invalid then return false
    if GetInterface(m.favoritesIndex, "ifAssociativeArray") = invalid then return false
    return m.favoritesIndex.DoesExist(url)
end function

' *************************************************************
' Handler: Lista de canales establecida
' *************************************************************
sub onChannelListSet()
    m.currentChannels = m.top.channelList
    if m.currentChannels <> invalid and m.currentChannels.Count() > 0 then
        print "[VideoPlayer] Channel list set: "; m.currentChannels.Count(); " channels"
        updateChannelInfo()
        ' Inicializar el navegador solo una vez (siempre que no esté ya armado)
        if not m.browserInitialized then
            populatePlaylistsBrowser()
            m.browserInitialized = true
        end if
    end if
end sub

' Actualizar información del canal actual
sub updateChannelInfo()
    if m.currentChannels = invalid or m.currentChannels.Count() = 0 then return
    
    index = m.top.currentChannelIndex
    if index < 0 or index >= m.currentChannels.Count() then return
    
    currentChannel = m.currentChannels[index]
    
    ' Actualizar título
    if currentChannel.name <> invalid and m.channelTitle <> invalid then
        m.channelTitle.text = currentChannel.name
    end if
    
    ' Actualizar categoría
    if currentChannel.categoryName <> invalid and m.channelCategory <> invalid then
        m.channelCategory.text = currentChannel.categoryName
    else if m.channelCategory <> invalid then
        m.channelCategory.text = "Canal IPTV"
    end if

        if m.channelCategory <> invalid then
            m.channelCategory.focused = m.overlayVisible
        end if
    
    ' Actualizar logo
    if currentChannel.logo <> invalid and m.channelLogo <> invalid then
        m.channelLogo.uri = currentChannel.logo
    end if
    
    ' Actualizar contador
    if m.channelCounter <> invalid then
        m.channelCounter.text = (index + 1).ToStr() + " / " + m.currentChannels.Count().ToStr()
    end if
    
    print "[VideoPlayer] Updated to channel "; index + 1; " of "; m.currentChannels.Count()
end sub

' Poblar lista lateral de canales
sub populatePlaylistsBrowser()
    m.browserLevel = 0
    m.browserSelectedPlaylist = invalid
    m.browserSelectedCategory = invalid
    m.browserCategories = invalid
    m.browserChannelList = []

    if m.browserTitle <> invalid then m.browserTitle.text = "Listas"
    if m.channelListView = invalid then return

    playlists = m.top.playlists
    content = CreateObject("roSGNode", "ContentNode")

    ' Favoritos (pseudo-playlist)
    favNode = content.createChild("ContentNode")
    favNode.title = "⭐ FAVORITOS"
    favNode.addFields({itemType: "favorites", playlistId: "__favorites__"})

    if playlists <> invalid and GetInterface(playlists, "ifArray") <> invalid and playlists.Count() > 0 then
        for i = 0 to playlists.Count() - 1
            p = playlists[i]
            if p <> invalid and GetInterface(p, "ifAssociativeArray") <> invalid then
                node = content.createChild("ContentNode")
                node.title = p.name
                node.addFields({itemType: "playlist", playlistId: p.id, playlistUrl: p.url})
            end if
        end for
    else
        ' Si no hay listas, igual mostramos Favoritos
    end if

    m.channelListView.content = content
    m.channelListView.jumpToItem = 0
end sub

function getFavoritesChannelsLocal() as object
    channels = []
    sec = CreateObject("roRegistrySection", "FavoritesSection")
    if sec = invalid then return channels

    keys = sec.GetKeyList()
    for each key in keys
        json = sec.Read(key)
        if json <> invalid and json <> "" then
            fav = ParseJson(json)
            if fav <> invalid and GetInterface(fav, "ifAssociativeArray") <> invalid then
                ch = {
                    name: fav.name
                    url: fav.url
                    logo: fav.logo
                    categoryName: "Favoritos"
                    playlistName: "⭐ FAVORITOS"
                    isFavorite: true
                }
                if fav.group <> invalid and fav.group <> "" then
                    ch.categoryName = fav.group
                end if
                channels.Push(ch)
            end if
        end if
    end for

    return channels
end function

sub populateCategoriesBrowser(categories as object)
    m.browserLevel = 1
    m.browserSelectedCategory = invalid
    m.browserCategories = categories

    if m.browserTitle <> invalid then
        plName = "Categorías"
        if m.browserSelectedPlaylist <> invalid and m.browserSelectedPlaylist.name <> invalid then
            plName = m.browserSelectedPlaylist.name
        end if
        m.browserTitle.text = plName
    end if

    if m.channelListView = invalid then return
    content = CreateObject("roSGNode", "ContentNode")

    if categories <> invalid and GetInterface(categories, "ifAssociativeArray") <> invalid then
        for each catName in categories
            node = content.createChild("ContentNode")
            node.title = catName
            node.addFields({itemType: "category", categoryName: catName})
        end for
    end if

    if content.getChildCount() = 0 then
        node = content.createChild("ContentNode")
        node.title = "(Sin categorías)"
        node.addFields({itemType: "empty"})
    end if

    m.channelListView.content = content
    m.channelListView.jumpToItem = 0
end sub

sub populateChannelsBrowser(channels as object)
    m.browserLevel = 2
    m.browserChannelList = []

    if m.browserTitle <> invalid then
        title = "Canales"
        if m.browserSelectedCategory <> invalid and m.browserSelectedCategory <> "" then
            title = m.browserSelectedCategory
        end if
        m.browserTitle.text = title
    end if

    if m.channelListView = invalid then return
    content = CreateObject("roSGNode", "ContentNode")

    if channels <> invalid and GetInterface(channels, "ifArray") <> invalid then
        for i = 0 to channels.Count() - 1
            ch = channels[i]
            if ch <> invalid and GetInterface(ch, "ifAssociativeArray") <> invalid then
                ' Marcar favorito dentro del objeto
                if ch.url <> invalid and ch.url <> "" then
                    ch.isFavorite = isFavoriteUrl(ch.url)
                end if

                node = content.createChild("ContentNode")
                node.title = ch.name
                node.addFields({itemType: "channel", channelIndex: i, isFavorite: (ch.DoesExist("isFavorite") and ch.isFavorite = true)})
            end if
        end for
        m.browserChannelList = channels
    end if

    if content.getChildCount() = 0 then
        node = content.createChild("ContentNode")
        node.title = "(Sin canales)"
        node.addFields({itemType: "empty"})
    end if

    m.channelListView.content = content
    m.channelListView.jumpToItem = 0
end sub

sub loadCategoriesForSelectedPlaylist(playlist as object)
    if playlist = invalid or GetInterface(playlist, "ifAssociativeArray") = invalid then return

    pid = playlist.id
    if pid = invalid or pid = "" then return

    maxAge = getSettingLocal("cacheMaxAge", 24)
    cached = getCachedPlaylistLocal(pid, maxAge)
    if cached <> invalid and cached.categories <> invalid then
        populateCategoriesBrowser(cached.categories)
        return
    end if

    ' Cargar desde red usando M3ULoaderTask
    if m.browserTitle <> invalid then m.browserTitle.text = "Cargando..."

    m.browserLoaderTask = CreateObject("roSGNode", "M3ULoaderTask")
    m.browserLoaderTask.observeField("result", "onBrowserPlaylistLoaded")
    m.browserLoaderTask.url = playlist.url
    m.browserLoaderTask.control = "RUN"
end sub

sub onBrowserPlaylistLoaded(event as object)
    result = event.getData()
    if result <> invalid and result.error = invalid and result.categories <> invalid then
        ' Guardar en caché
        if m.browserSelectedPlaylist <> invalid and m.browserSelectedPlaylist.id <> invalid then
            cachePlaylistLocal(m.browserSelectedPlaylist.id, result)
        end if
        populateCategoriesBrowser(result.categories)
    else
        ' Fallback: volver a playlists
        populatePlaylistsBrowser()
    end if
end sub

' *************************************************************
' Handler: URL del stream establecida
' *************************************************************
sub onStreamUrlSet()
    url = m.top.streamUrl
    
    if url <> "" and url <> invalid then
        ' Resetear bookmarking para nuevo contenido
        m.lastBookmarkPosition = 0
        m.bookmarkPending = true
        
        ' Reiniciar el Video node SIEMPRE cuando cambia la URL.
        ' Esto evita que el cambio quede "pegado" hasta que el usuario presione left/right.
        if m.videoNode <> invalid then
            m.videoNode.control = "stop"
            m.videoNode.content = invalid
        end if

        ' Configurar contenido del video
        videoContent = CreateObject("roSGNode", "ContentNode")
        videoContent.url = url
        videoContent.streamFormat = "hls" ' Asumir HLS por defecto
        
        ' Detectar formato si es .m3u8 o .mp4
        if url.InStr(".m3u8") > 0 or url.InStr("/live/") > 0 then
            videoContent.streamFormat = "hls"
        else if url.InStr(".mp4") > 0 then
            videoContent.streamFormat = "mp4"
        end if
        
        m.videoNode.content = videoContent
        m.videoNode.control = "play"
        
        ' Iniciar timeout para streams lentos (solo si es deep link)
        if m.isDeepLinkPlayback then
            startStreamTimeout()
        end if
        
        print "VideoPlayer: Iniciando stream: "; url
    end if
end sub

' *************************************************************
' Handler: Título establecido
' *************************************************************
sub onTitleSet()
    title = m.top.title
    if title <> "" and title <> invalid then
        m.channelTitle.text = title
        ' El marquee sólo debe moverse cuando el overlay está visible
        m.channelTitle.focused = m.overlayVisible

        if m.loadingChannelName <> invalid then
            m.loadingChannelName.text = title
            m.loadingChannelName.focused = (m.loadingGroup <> invalid and m.loadingGroup.visible)
        end if
    end if
end sub

' *************************************************************
' Handler: Cambio de estado del video
' Estados: none, buffering, playing, paused, stopped, finished, error
' *************************************************************
sub onVideoStateChange()
    state = m.videoNode.state
    
    print "[VideoPlayer] Video state: "; state
    
    if state = "buffering" then
        ' Mostrar spinner de buffering
        if m.bufferingGroup <> invalid then
            m.bufferingGroup.visible = true
        end if
        if m.playbackInfo <> invalid then
            m.playbackInfo.text = "Cargando stream..."
        end if
            if m.loadingChannelName <> invalid then
                m.loadingChannelName.focused = (m.loadingGroup <> invalid and m.loadingGroup.visible)
            end if
    else if state = "playing" then
        ' Stream exitoso - cancelar timeout
        cancelStreamTimeout()
        
        ' Ocultar loading y buffering
        if m.loadingGroup <> invalid then
            m.loadingGroup.visible = false
        end if
        if m.bufferingGroup <> invalid then
            m.bufferingGroup.visible = false
        end if
        if m.playbackInfo <> invalid then
            m.playbackInfo.text = "● EN VIVO"
        end if

        ' Notificar que el video está reproduciendo (para beacon de deep link)
        m.top.videoPlaying = true

        ' Restaurar bookmark si está pendiente (Requisito 4.10)
        if m.bookmarkPending = true then
            m.bookmarkPending = false
            ' Verificar que sea contenido VOD > 15 minutos antes de restaurar
            if m.videoNode.duration > 900 then
                restoreBookmark()
            end if
        end if

        ' Si el cambio de canal terminó, ocultar feedback
        if m.switchInProgress then
            m.switchInProgress = false
            endChannelSwitchFeedback()
        end if
        if m.playPauseLabel <> invalid then
            m.playPauseLabel.text = "⏸ Pausar"
        end if
        
        ' Auto-ocultar overlay después de 3 segundos
        if m.overlayVisible then
            startOverlayTimer()
        end if
            if m.loadingChannelName <> invalid then
                m.loadingChannelName.focused = false
            end if
    else if state = "paused" then
        if m.playbackInfo <> invalid then
            m.playbackInfo.text = "⏸ PAUSADO"
        end if
        if m.playPauseLabel <> invalid then
            m.playPauseLabel.text = "▶ Reanudar"
        end if
        if m.bufferingGroup <> invalid then
            m.bufferingGroup.visible = false
        end if
    else if state = "finished" then
        ' Video terminado - salir
        print "[VideoPlayer] Stream finished"
        m.top.finished = true
    else if state = "error" then
        ' Error en el stream - cancelar timeout
        cancelStreamTimeout()
        
        print "[VideoPlayer] ERROR - Stream failed"
        
        ' Si es deep link playback, intentar siguiente canal
        if m.isDeepLinkPlayback and m.currentChannels <> invalid and m.currentChannels.Count() > 1 then
            print "[VideoPlayer] Deep link stream failed, trying next available channel"
            tryNextAvailableChannel()
            return
        end if
        
        if m.loadingGroup <> invalid then
            m.loadingGroup.visible = false
        end if
        if m.controlsOverlay <> invalid then
            m.controlsOverlay.visible = true
            m.overlayVisible = true
        end if
        if m.playbackInfo <> invalid then
            m.playbackInfo.text = "⚠ ERROR: Stream no disponible"
            m.playbackInfo.color = "#FF4444"
        end if
        if m.bufferingGroup <> invalid then
            m.bufferingGroup.visible = false
        end if

        if m.switchInProgress then
            m.switchInProgress = false
            endChannelSwitchFeedback()
        end if
        
        ' Mostrar mensaje de ayuda
        if m.channelTitle <> invalid then
            m.channelTitle.text = "Este canal no está disponible en este momento"
        end if
            if m.loadingChannelName <> invalid then
                m.loadingChannelName.focused = false
            end if
    end if
end sub

' *************************************************************
' Handler: Cambio de posición (tiempo de reproducción)
' *************************************************************
sub onPositionChange()
    ' Actualizar información de tiempo si es VOD (no en vivo)
    position = m.videoNode.position
    duration = m.videoNode.duration
    
    if duration > 0 then
        ' Es VOD - mostrar progreso
        posStr = formatTime(position)
        durStr = formatTime(duration)
        m.playbackInfo.text = posStr + " / " + durStr
    end if
end sub

' *************************************************************
' Toggle Overlay de Controles
' *************************************************************
sub toggleOverlay()
    m.overlayVisible = not m.overlayVisible
    m.controlsOverlay.visible = m.overlayVisible

    if m.channelTitle <> invalid then
        m.channelTitle.focused = m.overlayVisible
    end if

    if m.channelCategory <> invalid then
        m.channelCategory.focused = m.overlayVisible
    end if
    
    if m.overlayVisible then
        ' Overlay visible - auto-ocultar en 5 segundos
        startOverlayTimer()
    else
        ' Overlay oculto - cancelar timer
        if m.overlayTimer <> invalid then
            m.overlayTimer.control = "stop"
        end if
    end if
end sub

' *************************************************************
' Iniciar timer para auto-ocultar overlay
' *************************************************************
sub startOverlayTimer()
    if m.overlayTimer = invalid then
        m.overlayTimer = CreateObject("roSGNode", "Timer")
        m.overlayTimer.duration = 5
        m.overlayTimer.repeat = false
        m.overlayTimer.observeField("fire", "onOverlayTimerFired")
        m.top.appendChild(m.overlayTimer)
    end if
    
    m.overlayTimer.control = "start"
end sub

' *************************************************************
' Handler: Timer del overlay expiró
' *************************************************************
sub onOverlayTimerFired()
    ' Auto-ocultar overlay
    if m.overlayVisible and m.videoNode.state = "playing" then
        m.overlayVisible = false
        m.controlsOverlay.visible = false

        if m.channelTitle <> invalid then
            m.channelTitle.focused = false
        end if

        if m.channelCategory <> invalid then
            m.channelCategory.focused = false
        end if
    end if
end sub

' *************************************************************
' Formatear tiempo en MM:SS
' *************************************************************
function formatTime(seconds as integer) as string
    minutes = Int(seconds / 60)
    secs = seconds mod 60
    return minutes.ToStr() + ":" + Right("0" + secs.ToStr(), 2)
end function

' *************************************************************
' Manejo de Eventos de Teclado
' *************************************************************
function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    ' Si está cambiando de canal, BACK cancela la carga (no sale del player)
    if key = "back" and m.switchInProgress then
        cancelChannelSwitch()
        return true
    end if
    
    ' Si el navegador está visible, manejar por separado (pero permitir * para favoritos)
    if m.channelListVisible then
        if key = "options" or key = "*" then
            toggleFavoriteCurrentChannel()
            return true
        end if
        return handleBrowserKeys(key)
    end if
    
    ' OK - Toggle navegador (listas/categorías/canales)
    if key = "OK" then
        toggleBrowser()
        return true
    end if
    
    ' Flechas arriba/abajo - Mostrar overlay
    if key = "up" or key = "down" then
        if not m.overlayVisible then
            toggleOverlay()
        end if
        return true
    end if
    
    ' Flechas izquierda/derecha - Cambiar canal
    if key = "left" then
        changeChannel(-1) ' Canal anterior
        return true
    else if key = "right" then
        changeChannel(1) ' Canal siguiente
        return true
    end if
    
    ' Play/Pause
    if key = "play" then
        if m.videoNode.state = "playing" then
            m.videoNode.control = "pause"
        else
            m.videoNode.control = "resume"
        end if
        return true
    end if
    
    ' Fast Forward / Rewind (si es VOD)
    if key = "fastforward" then
        if m.videoNode.duration > 0 then
            newPos = m.videoNode.position + 30
            m.videoNode.seek = newPos
            return true
        end if
    else if key = "rewind" then
        if m.videoNode.duration > 0 then
            newPos = m.videoNode.position - 10
            if newPos < 0 then newPos = 0
            m.videoNode.seek = newPos
            return true
        end if
    end if
    
    ' Instant Replay - Retroceder 10 segundos (Requisito 4.9)
    if key = "replay" or key = "instantreplay" then
        ' Requisito: debe retroceder entre 10 y 25 segundos
        ' Implementamos 10 segundos para experiencia óptima
        rewindSeconds = 10
        newPos = m.videoNode.position - rewindSeconds
        if newPos < 0 then newPos = 0
        m.videoNode.seek = newPos
        
        ' Mostrar feedback visual
        if m.playbackInfo <> invalid then
            m.playbackInfo.text = "↺ -" + rewindSeconds.ToStr() + "s"
            m.playbackInfo.color = "#00BFFF"
        end if
        if not m.overlayVisible then
            toggleOverlay()
        end if
        
        print "[VideoPlayer] Instant replay: -" + rewindSeconds.ToStr() + "s"
        return true
    end if
    
    ' Asterisco/Opciones - Favoritos
    if key = "options" or key = "*" then
        toggleFavoriteCurrentChannel()
        return true
    end if

    ' Info - Toggle overlay de controles
    if key = "info" then
        toggleOverlay()
        return true
    end if
    
    ' BACK - Salir del player
    if key = "back" then
        ' Detener video
        m.videoNode.control = "stop"
        m.top.finished = true
        return true
    end if
    
    return false
end function

' Cambiar canal (offset: -1 = anterior, +1 = siguiente)
sub changeChannel(offset as integer)
    if m.currentChannels = invalid or m.currentChannels.Count() = 0 then return
    
    currentIndex = m.top.currentChannelIndex
    newIndex = currentIndex + offset
    
    ' Wrap around
    if newIndex < 0 then
        newIndex = m.currentChannels.Count() - 1
    else if newIndex >= m.currentChannels.Count() then
        newIndex = 0
    end if
    
    ' Guardar canal anterior para poder cancelar
    m.switchPrevIndex = currentIndex
    m.switchPrevUrl = m.top.streamUrl
    m.switchInProgress = true

    ' Cambiar canal
    m.top.currentChannelIndex = newIndex
    channel = m.currentChannels[newIndex]

    beginChannelSwitchFeedback(channel)
    
    ' Actualizar stream
    if channel.url <> invalid then
        m.top.streamUrl = channel.url
    end if
    
    ' Actualizar info
    updateChannelInfo()
    
    ' Notificar cambio
    m.top.channelChanged = newIndex
    
    print "[VideoPlayer] Changed to channel: "; newIndex + 1; "/"; m.currentChannels.Count()
end sub

' Toggle panel de lista de canales
sub toggleBrowser()
    m.channelListVisible = not m.channelListVisible
    
    if m.channelListPanel <> invalid then
        m.channelListPanel.visible = m.channelListVisible
    end if
    
    if m.channelListVisible then
        ' Reset del modo de navegación
        m.browserNavMode = "channel"
        m.browserTouchedList = false

        ' Mostrar playlists y dar foco
        populatePlaylistsBrowser()
        if m.channelListView <> invalid then
            m.channelListView.setFocus(true)
        end if
        
        ' Mantener reproducción (no pausar)
    else
        ' Devolver foco al player
        m.top.setFocus(true)
        ' Mantener estado de reproducción
    end if
end sub

function handleBrowserKeys(key as string) as boolean
    ' Si está cambiando de canal, BACK cancela la carga (y no navega niveles)
    if key = "back" and m.switchInProgress then
        cancelChannelSwitch()
        return true
    end if
    ' Detectar primera interacción de lista
    if key = "up" or key = "down" then
        if not m.browserTouchedList then
            m.browserTouchedList = true
            m.browserNavMode = "menu"
        end if
        return false ' Dejar que el MarkupList maneje el scroll
    end if

    if key = "back" then
        ' BACK: si estamos dentro de categorías/canales, subir un nivel; si estamos en listas, cerrar
        if m.browserLevel = 2 then
            if m.browserCategories <> invalid then
                populateCategoriesBrowser(m.browserCategories)
            else
                populatePlaylistsBrowser()
            end if
            return true
        else if m.browserLevel = 1 then
            populatePlaylistsBrowser()
            return true
        end if

        toggleBrowser()
        return true
    end if

    ' En modo "channel", left/right siguen cambiando canal aunque el menú esté visible
    if key = "left" or key = "right" then
        if m.browserNavMode = "channel" then
            if key = "left" then changeChannel(-1) else changeChannel(1)
            return true
        end if

        ' En modo "menu", left/right navegan niveles
        if key = "left" then
            if m.browserLevel = 2 then
                if m.browserCategories <> invalid then
                    populateCategoriesBrowser(m.browserCategories)
                else
                    populatePlaylistsBrowser()
                end if
                return true
            else if m.browserLevel = 1 then
                populatePlaylistsBrowser()
                return true
            end if
        else if key = "right" then
            ' OK confirma/entra. RIGHT no navega niveles.
            return true
        end if
    end if

    if key = "OK" then
        ' No consumir OK: el MarkupList debe disparar itemSelected
        return false
    end if

    return false
end function

' Handler: Canal seleccionado de la lista
sub onBrowserItemSelected(event as object)
    selectedIndex = event.getData()

    if m.channelListView = invalid or m.channelListView.content = invalid then return
    item = m.channelListView.content.getChild(selectedIndex)
    if item = invalid or not item.DoesExist("itemType") then return

    t = item.itemType
    if t = "favorites" then
        m.browserSelectedPlaylist = {id: "__favorites__", name: "⭐ FAVORITOS", url: ""}
        m.browserCategories = invalid
        m.browserSelectedCategory = invalid
        favChannels = getFavoritesChannelsLocal()
        populateChannelsBrowser(favChannels)
        return
    end if
    if t = "playlist" then
        ' Guardar playlist seleccionada
        m.browserSelectedPlaylist = {
            id: item.playlistId
            name: item.title
            url: item.playlistUrl
        }
        loadCategoriesForSelectedPlaylist(m.browserSelectedPlaylist)
        return
    else if t = "category" then
        if item.categoryName <> invalid and m.browserCategories <> invalid then
            m.browserSelectedCategory = item.categoryName
            channels = m.browserCategories[m.browserSelectedCategory]
            populateChannelsBrowser(channels)
        end if
        return
    else if t = "channel" then
        if m.browserChannelList = invalid or GetInterface(m.browserChannelList, "ifArray") = invalid then return
        idx = item.channelIndex
        if idx < 0 or idx >= m.browserChannelList.Count() then return

        selectedChannel = m.browserChannelList[idx]
        selectedUrl = invalid
        if selectedChannel <> invalid and GetInterface(selectedChannel, "ifAssociativeArray") <> invalid then
            if selectedChannel.url <> invalid and selectedChannel.url <> "" then
                selectedUrl = selectedChannel.url
            end if
        end if

        ' Guardar canal anterior para poder cancelar
        m.switchPrevIndex = m.top.currentChannelIndex
        m.switchPrevUrl = m.top.streamUrl
        m.switchInProgress = true

        ' Cambiar canal desde el navegador
        m.currentChannels = m.browserChannelList
        m.top.channelList = m.browserChannelList
        m.top.currentChannelIndex = idx
        channel = selectedChannel

        beginChannelSwitchFeedback(channel)

        if selectedUrl <> invalid then
            m.top.streamUrl = selectedUrl
        end if

        ' Al cambiar canal, cerrar navegador
        ' Ocultar el panel de navegador después de seleccionar canal
        m.channelListVisible = false
        if m.channelListPanel <> invalid then
            m.channelListPanel.visible = false
        end if
        m.top.setFocus(true)
    end if
end sub

' *************************************************************
' CLOSED CAPTIONS SUPPORT (Requisito 4.8)
' *************************************************************

' Configurar closed captions respetando configuración global del sistema
sub setupClosedCaptions()
    if m.videoNode = invalid then return
    
    ' Obtener configuración global de closed captions del sistema
    device = CreateObject("roDeviceInfo")
    if device = invalid then return
    
    ' Configurar según los ajustes globales del usuario
    ' Los modos soportados son: "On", "Off", "OnReplay", "OnMute" (Roku TVs)
    captionsMode = device.GetCaptionsMode()
    
    if captionsMode = "On" then
        ' Usuario tiene captions siempre activados
        m.videoNode.globalCaptionMode = "On"
    else if captionsMode = "Off" then
        m.videoNode.globalCaptionMode = "Off"
    else if captionsMode = "OnReplay" then
        ' Activar durante instant replay
        m.videoNode.globalCaptionMode = "When replay"
    else if captionsMode = "OnMute" then
        ' Activar cuando está silenciado (solo Roku TVs)
        m.videoNode.globalCaptionMode = "When mute"
    else
        ' Por defecto usar configuración del sistema
        m.videoNode.globalCaptionMode = "On"
    end if
    
    print "[VideoPlayer] Closed captions configurado: " + captionsMode
end sub

' *************************************************************
' BOOKMARKING AUTOMÁTICO (Requisito 4.10)
' *************************************************************

' Guardar posición de reproducción cada 10 segundos para VOD > 15 minutos
sub onPositionChangeForBookmark(event as object)
    if m.videoNode = invalid then return
    
    position = m.videoNode.position
    duration = m.videoNode.duration
    
    ' Solo aplicar bookmarking para VOD > 15 minutos (900 segundos)
    if duration <= 900 then return
    
    ' Guardar cada 10 segundos
    if Abs(position - m.lastBookmarkPosition) >= m.bookmarkInterval then
        saveBookmark(position, duration)
        m.lastBookmarkPosition = position
    end if
end sub

' Guardar bookmark en registry
sub saveBookmark(position as float, duration as float)
    if m.top.streamUrl = invalid or m.top.streamUrl = "" then return
    
    ' Crear key único basado en URL
    url = m.top.streamUrl
    key = createBookmarkKey(url)
    
    bookmark = {
        url: url
        title: m.top.title
        position: position
        duration: duration
        timestamp: CreateObject("roDateTime").AsSeconds()
    }
    
    sec = CreateObject("roRegistrySection", "BookmarksSection")
    if sec <> invalid then
        json = FormatJson(bookmark)
        sec.Write(key, json)
        sec.Flush()
        print "[VideoPlayer] Bookmark guardado: " + m.top.title + " @ " + position.ToStr() + "s"
    end if
end sub

' Restaurar bookmark al iniciar reproducción
sub restoreBookmark()
    if m.top.streamUrl = invalid or m.top.streamUrl = "" then return
    if m.videoNode = invalid then return
    
    url = m.top.streamUrl
    key = createBookmarkKey(url)
    
    sec = CreateObject("roRegistrySection", "BookmarksSection")
    if sec = invalid then return
    
    json = sec.Read(key)
    if json = invalid or json = "" then return
    
    bookmark = ParseJson(json)
    if bookmark = invalid then return
    
    ' Verificar que el bookmark no sea muy antiguo (30 días = 2592000 segundos)
    if bookmark.timestamp <> invalid then
        now = CreateObject("roDateTime").AsSeconds()
        age = now - bookmark.timestamp
        if age > 2592000 then
            ' Bookmark expirado, eliminarlo
            sec.Delete(key)
            sec.Flush()
            return
        end if
    end if
    
    ' Restaurar posición si está disponible
    if bookmark.position <> invalid and bookmark.position > 0 then
        m.videoNode.seek = bookmark.position
        print "[VideoPlayer] Bookmark restaurado: " + m.top.title + " @ " + bookmark.position.ToStr() + "s"
    end if
end sub

' Crear key único para bookmark basado en URL
function createBookmarkKey(url as string) as string
    if url = invalid then return "bm_invalid"
    
    ' Usar hash simple basado en longitud y cola de URL
    urlStr = url
    tailLen = 64
    tail = urlStr
    if urlStr.Len() > tailLen then
        tail = urlStr.Mid(urlStr.Len() - tailLen, tailLen)
    end if
    
    key = "bm_" + urlStr.Len().ToStr() + "_" + tail
    key = key.Replace(" ", "_")
    key = key.Replace("/", "_")
    key = key.Replace(":", "_")
    key = key.Replace("?", "_")
    key = key.Replace("&", "_")
    key = key.Replace("=", "_")
    key = key.Replace("#", "_")
    key = key.Replace("%", "_")
    key = key.Replace(".", "_")
    
    maxLen = 120
    if key.Len() > maxLen then
        key = Left(key, maxLen)
    end if
    
    return key
end function

' *************************************************************
' DIRECT TO PLAY SUPPORT (Requisito 5.2)
' *************************************************************

' Esta función permite reproducción directa mediante comandos de voz
' Ya está implementada en MainScene.brs mediante deep linking
' El VideoPlayer solo necesita soportar inicio rápido < 8 segundos (ya implementado)

' *************************************************************
' STREAM TIMEOUT & FALLBACK (Requisito 3.6 - 8 segundos)
' *************************************************************

' Iniciar timeout para detectar streams lentos o caídos
sub startStreamTimeout()
    cancelStreamTimeout() ' Limpiar timer anterior si existe
    
    m.streamTimeoutTimer = CreateObject("roSGNode", "Timer")
    m.streamTimeoutTimer.duration = m.streamTimeout
    m.streamTimeoutTimer.repeat = false
    m.streamTimeoutTimer.observeField("fire", "onStreamTimeout")
    m.streamTimeoutTimer.control = "start"
    
    print "[VideoPlayer] Stream timeout started: "; m.streamTimeout; "s"
end sub

' Cancelar timeout cuando stream funciona
sub cancelStreamTimeout()
    if m.streamTimeoutTimer <> invalid then
        m.streamTimeoutTimer.control = "stop"
        m.streamTimeoutTimer.unobserveField("fire")
        m.streamTimeoutTimer = invalid
    end if
end sub

' Timeout alcanzado - stream muy lento o no responde
sub onStreamTimeout(event as object)
    print "[VideoPlayer] Stream timeout reached - trying next channel"
    
    ' Solo aplicar fallback si es deep link playback
    if m.isDeepLinkPlayback and m.currentChannels <> invalid and m.currentChannels.Count() > 1 then
        tryNextAvailableChannel()
    else
        print "[VideoPlayer] No fallback available - showing error"
    end if
end sub

' Intentar con el siguiente canal disponible
sub tryNextAvailableChannel()
    if m.currentChannels = invalid or m.currentChannels.Count() <= 1 then
        print "[VideoPlayer] No more channels to try"
        return
    end if
    
    currentIndex = m.top.currentChannelIndex
    maxAttempts = 3 ' Intentar hasta 3 canales
    attempts = 0
    
    ' Intentar con los siguientes canales
    while attempts < maxAttempts and attempts < m.currentChannels.Count()
        nextIndex = (currentIndex + attempts + 1) mod m.currentChannels.Count()
        
        if nextIndex >= 0 and nextIndex < m.currentChannels.Count() then
            nextChannel = m.currentChannels[nextIndex]
            if nextChannel <> invalid and nextChannel.url <> invalid and nextChannel.url <> "" then
                print "[VideoPlayer] Trying fallback channel: "; nextChannel.name
                
                ' Cambiar al siguiente canal
                m.top.currentChannelIndex = nextIndex
                m.top.streamUrl = nextChannel.url
                updateChannelInfo()
                return
            end if
        end if
        
        attempts = attempts + 1
    end while
    
    print "[VideoPlayer] All fallback attempts exhausted"
    m.isDeepLinkPlayback = false ' Desactivar fallback automático
end sub
