Function Init()
    ? "[ErrorScene] Init"
    m.background = m.top.findNode("Background")
    m.label = m.top.findNode("Label")
'    font = m.label.font
'    font.size = 40
    m.label.font.size = 40
End Function
Function OnKeyEvent(key, press) as Boolean
    ? ">>> ErrorScene >> OnkeyEvent"
    result = false
    if press then
        if key = "back"
            print "Back button clicked"
        end if
    end if
    return result
End Function