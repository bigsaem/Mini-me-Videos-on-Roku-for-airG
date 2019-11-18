function init()
   m.buttongrp = m.top.findNode("button_grp")
   m.button1= m.top.FindNode("option_btn1")
   m.button1.textFont.size = "20"
   m.button1.focusedTextFont.size = "20"
   m.button1.focusedTextFont.textColor="#ffffff"
   m.top.observeField("visible", "focus")
   m.button1.observeField("buttonSelected", "onButtonSelected")
end function

function focus()
    if m.top.visible = true then
        m.buttongrp.setFocus(true)
    end if
end function

Function onButtonSelected()
    sec = createObject("roRegistrySection", "MySection")
    list = sec.GetKeyList()
    for each item in list
        print item
        'sec.Delete(item)
    end for
End Function