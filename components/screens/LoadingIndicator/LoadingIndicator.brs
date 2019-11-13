    sub init()
      print "in spinner"
      m.busyspinner = m.top.findNode("exampleBusySpinner")
      m.busyspinner.poster.observeField("loadStatus", "showspinner")
      m.busyspinner.poster.uri = "pkg:/images/loader.png"
      m.top.setFocus(true)
    end sub

    sub showspinner()
      if(m.busyspinner.poster.loadStatus = "ready")
        centerx = (1280 - m.busyspinner.poster.bitmapWidth) / 2
        centery = (720 - m.busyspinner.poster.bitmapHeight) / 2
        m.busyspinner.translation = [ centerx, centery ]
    
        m.busyspinner.visible = true
      end if
    end sub