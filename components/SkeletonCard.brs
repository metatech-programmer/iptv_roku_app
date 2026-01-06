' *************************************************************
' Ultimate IPTV 2026 - Skeleton Card Logic
' Descripción: Animación "pulse" estilo React Skeleton
' *************************************************************

sub init()
    m.skeletonBox = m.top.findNode("skeletonBox")
    m.skeletonImage = m.top.findNode("skeletonImage")
    m.skeletonTitle = m.top.findNode("skeletonTitle")
    m.skeletonDesc = m.top.findNode("skeletonDesc")
    
    ' Animación sutil de pulse minimalista
    createMinimalPulseAnimation()
end sub

' Crear animación sutil y minimalista
sub createMinimalPulseAnimation()
    ' Animación muy sutil, solo para las barras
    pulseAnim = CreateObject("roSGNode", "Animation")
    pulseAnim.duration = 2.0
    pulseAnim.repeat = true
    pulseAnim.easeFunction = "linear"
    
    ' Pulse muy sutil
    interpImage = CreateObject("roSGNode", "FloatFieldInterpolator")
    interpImage.key = [0.0, 0.5, 1.0]
    interpImage.keyValue = [0.8, 1.0, 0.8]
    interpImage.fieldToInterp = m.skeletonImage.id + ".opacity"
    pulseAnim.appendChild(interpImage)
    
    interpTitle = CreateObject("roSGNode", "FloatFieldInterpolator")
    interpTitle.key = [0.0, 0.5, 1.0]
    interpTitle.keyValue = [0.8, 1.0, 0.8]
    interpTitle.fieldToInterp = m.skeletonTitle.id + ".opacity"
    pulseAnim.appendChild(interpTitle)
    
    m.top.appendChild(pulseAnim)
    pulseAnim.control = "start"
end sub
