' *************************************************************
' MarqueeLabel
' - Shows truncated text normally
' - When focused and text overflows, scrolls horizontally
' *************************************************************

sub init()
    m.clip = m.top.findNode("clip")

    ' Create label inside clip
    m.label = CreateObject("roSGNode", "Label")
    m.label.translation = [0, 0]
    m.label.wrap = false
    m.label.ellipsizeOnBoundary = true
    m.clip.appendChild(m.label)

    m.overflowPx = 0
    m.isOverflow = false

    ' Timers / animations
    m.delayTimer = invalid
    m.scrollAnim = invalid

    ' Observe fields
    m.top.observeField("text", "onPropsChanged")
    m.top.observeField("font", "onPropsChanged")
    m.top.observeField("color", "onPropsChanged")
    m.top.observeField("horizAlign", "onPropsChanged")
    m.top.observeField("maskWidth", "onPropsChanged")
    m.top.observeField("maskHeight", "onPropsChanged")
    m.top.observeField("focused", "onFocusedChanged")

    ' Bounding rect changes when text/font changes
    m.label.observeField("boundingRect", "onBoundsChanged")

    applyProps()
end sub

sub onPropsChanged()
    applyProps()
end sub

sub applyProps()
    if m.clip <> invalid then
        m.clip.clippingRect = [0, 0, m.top.maskWidth, m.top.maskHeight]
    end if

    if m.label <> invalid then
        m.label.text = m.top.text
        m.label.font = m.top.font
        m.label.color = m.top.color
        m.label.translation = [0, 0]
    end if

    ' Re-evaluate overflow after layout settles
    scheduleRecalc()
end sub

sub onBoundsChanged()
    recalcOverflow()
end sub

sub scheduleRecalc()
    if m.recalcTimer = invalid then
        m.recalcTimer = CreateObject("roSGNode", "Timer")
        m.recalcTimer.repeat = false
        m.recalcTimer.duration = 0.05
        m.recalcTimer.observeField("fire", "onRecalcTimer")
        m.top.appendChild(m.recalcTimer)
    end if

    m.recalcTimer.control = "start"
end sub

sub onRecalcTimer()
    recalcOverflow()
end sub

sub recalcOverflow()
    if m.label = invalid then return

    rect = m.label.boundingRect
    if rect = invalid then return

    textW = rect.width
    maskW = m.top.maskWidth

    if textW = invalid or maskW = invalid then return

    if textW > maskW + 2 then
        m.isOverflow = true
        m.overflowPx = textW - maskW
    else
        m.isOverflow = false
        m.overflowPx = 0
        stopScroll(true)

        ' Alinear el texto dentro de la máscara cuando NO hay overflow
        align = m.top.horizAlign
        if align = invalid then align = "left"
        x = 0
        if align = "center" then
            x = (maskW - textW) / 2
        else if align = "right" then
            x = (maskW - textW)
        end if
        if x < 0 then x = 0
        m.label.translation = [x, 0]
    end if

    ' If focused, (re)start
    if m.top.focused and m.isOverflow then
        startScrollWithDelay()
    end if
end sub

sub onFocusedChanged()
    if m.top.focused and m.isOverflow then
        startScrollWithDelay()
    else
        stopScroll(true)
    end if
end sub

sub startScrollWithDelay()
    stopScroll(false)

    if m.delayTimer = invalid then
        m.delayTimer = CreateObject("roSGNode", "Timer")
        m.delayTimer.repeat = false
        m.delayTimer.observeField("fire", "onDelayFired")
        m.top.appendChild(m.delayTimer)
    end if

    m.delayTimer.duration = m.top.startDelay
    m.delayTimer.control = "start"
end sub

sub onDelayFired()
    if not m.top.focused or not m.isOverflow then return
    startScroll()
end sub

sub startScroll()
    if m.label = invalid then return

    ' Reset position
    m.label.translation = [0, 0]

    totalMove = m.overflowPx + 24 ' small gap
    pps = m.top.pixelsPerSecond
    if pps <= 0 then pps = 90

    moveSeconds = totalMove / pps
    duration = moveSeconds + 1.2 ' includes hold time

    anim = CreateObject("roSGNode", "Animation")
    anim.duration = duration
    anim.easeFunction = "linear"

    interp = CreateObject("roSGNode", "Vector2DFieldInterpolator")
    interp.fieldToInterp = "label.translation"

    ' Hold -> Move -> Hold
    interp.key = [0.0, 0.2, 0.85, 1.0]
    interp.keyValue = [
        [0.0, 0.0],
        [0.0, 0.0],
        [-totalMove, 0.0],
        [-totalMove, 0.0]
    ]

    anim.appendChild(interp)
    anim.observeField("state", "onAnimStateChanged")

    ' Attach the label as a named node under top so fieldToInterp resolves
    if m.top.findNode("label") = invalid then
        m.label.id = "label"
    end if

    m.top.appendChild(anim)
    m.scrollAnim = anim
    anim.control = "start"
end sub

sub onAnimStateChanged(event as object)
    if m.scrollAnim = invalid then return

    if m.scrollAnim.state = "stopped" then
        ' Loop while focused
        if m.top.focused and m.isOverflow then
            startScrollWithDelay()
        end if
    end if
end sub

sub stopScroll(resetPosition as boolean)
    if m.delayTimer <> invalid then
        m.delayTimer.control = "stop"
    end if

    if m.scrollAnim <> invalid then
        m.scrollAnim.control = "stop"
        m.top.removeChild(m.scrollAnim)
        m.scrollAnim = invalid
    end if

    if resetPosition and m.label <> invalid then
        m.label.translation = [0, 0]
    end if
end sub
