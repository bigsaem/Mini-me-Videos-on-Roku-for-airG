Function Init()
    ? "[ErrorScene] Init"
    m.background = m.top.findNode("Background")
    m.label = m.top.findNode("Label")
    m.labell = m.top.findNode("Labell")
    msg = "Sorry, unable to connect to Mini-Me Videos at this time."
    m.labell.text = msg
'    font = m.label.font
'    font.size = 40
    m.label.font.size = 40
End Function


Function OnKeyEvent(key, press) as Boolean
    ? ">>> ErrorScene >> OnkeyEvent"
    result = false
    if press then
        if key = "options"
            ' option key handler (do nothing)
            result  = true
            'back key handler
        else if key = "back"
        end if
    end if
    return result
End Function