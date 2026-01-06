' *************************************************************
' Ultimate IPTV 2026 - Main Entry Point
' 
' Descripción: Punto de entrada de la aplicación
' Inicializa la MainScene y configura el puerto de eventos
' *************************************************************

sub Main(args as Dynamic)
    ' Obtener la pantalla principal
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    
    ' Crear y mostrar la escena principal
    m.scene = screen.CreateScene("MainScene")
    
    ' Imprimir args para debugging (según ejemplo oficial de Roku)
    print "args= "; FormatJSON(args)
    
    ' Procesar deep linking inicial según ejemplo oficial
    deeplink = getDeepLinkParams(args)
    print "deeplink= "; deeplink
    
    ' Pasar deep link a la escena si existe
    if deeplink <> invalid then
        m.scene.deepLinkArgs = deeplink
    end if
    
    screen.show()
    
    ' Loop principal de eventos
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then 
                return
            end if
        else if msgType = "roInputEvent"
            ' Manejar eventos de deep linking mientras la app está corriendo
            if msg.IsInput()
                info = msg.GetInfo()
                print "roInputEvent received: "; FormatJSON(info)
                if info.DoesExist("mediatype") and info.DoesExist("contentid")
                    deeplink = {
                        contentId: info.contentid
                        mediaType: info.mediatype
                    }
                    ' Enviar el deep link a la escena
                    m.scene.deepLinkArgs = deeplink
                end if
            end if
        end if
    end while
end sub

' Extrae y valida parámetros de deep linking según ejemplo oficial de Roku
function getDeepLinkParams(args as Dynamic) as Dynamic
    deeplink = invalid
    
    if args <> invalid and type(args) = "roAssociativeArray" then
        ' Validar que tenemos contentId y mediaType (case-insensitive)
        hasContentId = args.DoesExist("contentid") or args.DoesExist("contentId") or args.DoesExist("contentID")
        hasMediaType = args.DoesExist("mediatype") or args.DoesExist("mediaType") or args.DoesExist("mediaType")
        
        if hasContentId and hasMediaType then
            ' Extraer contentId (case-insensitive)
            contentId = invalid
            if args.DoesExist("contentid") then contentId = args.contentid
            if args.DoesExist("contentId") then contentId = args.contentId
            if args.DoesExist("contentID") then contentId = args.contentID
            
            ' Extraer mediaType (case-insensitive)
            mediaType = invalid
            if args.DoesExist("mediatype") then mediaType = args.mediatype
            if args.DoesExist("mediaType") then mediaType = args.mediaType
            if args.DoesExist("MediaType") then mediaType = args.MediaType
            
            if contentId <> invalid and mediaType <> invalid then
                deeplink = {
                    contentId: contentId
                    mediaType: mediaType
                }
            end if
        end if
    end if
    
    return deeplink
end function