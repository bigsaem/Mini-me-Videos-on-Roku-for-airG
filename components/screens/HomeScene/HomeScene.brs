' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ' listen on port 8089
    ? "[HomeScene] Init"
    m.busyspinner = m.top.findNode("exampleBusySpinner")
    'print m.busySpinner
'    m.busyspinner.poster.observeField("loadStatus", "showspinner")
'    m.busyspinner.poster.uri = "pkg:/images/loader.png"
    ' GridScreen node with RowList
    m.gridScreen = m.top.findNode("GridScreen")
    
    m.videoPlayer2 = m.top.findNode("videoPlayer2")
    
    m.errorScene = m.top.findNode("ErrorScene")
    
    
    m.bg = m.top.findNode("GridScreen").getChild(0)

    ' DetailsScreen Node with description, Video Player

    m.detailsScreen = m.top.findNode("DetailsScreen")
    m.option = m.top.findNode("option_btn")

    
   ' Empty
    m.episodes = m.top.findNode("Episodes")
    m.optionCont = m.top.findNode("optionCont")

    ' Observer to handle Item selection on RowList inside GridScreen (alias="GridScreen.rowItemSelected")
    m.top.observeField("rowItemSelected", "OnRowItemSelected")
    

    ' Observer to handle Item selection on RowList inside GridScreen (alias="GridScreen.rowItemSelected")
    m.top.observeField("optionBtnSelected", "OnOptionSelected")

    m.top.observeField("episodesRowItemSelected", "OnRowItemSelected")
    
    m.top.observeField("playSelected", "OnRowItemSelected")
    
    
    ' loading indicator starts at initializatio of channel
    'm.loadingIndicator = m.top.findNode("loadingIndicator")

    'animation for option bar
    m.animation = m.top.FindNode("myAnim1")
    
    'print type(m.detailsScreen.videoPlayer)
End Function 

Function showspinner()
      if(m.busyspinner.poster.loadStatus = "ready")
        centerx = (1280 - m.busyspinner.poster.bitmapWidth) / 2
        centery = (720 - m.busyspinner.poster.bitmapHeight) / 2
        m.busyspinner.translation = [ centerx, centery ]
        m.busyspinner.visible = true
      end if
End function

' if content set, focus on GridScreen
Function OnChangeContent()
    m.gridScreen.setFocus(true)
    'm.episodes.setFocus(true)
    'm.loadingIndicator.control = "stop"
End Function

'Option button selected handler
Function OnOptionSelected()
    m.optionCont.visible = "true"
    m.animation.control = "start"
    m.optionCont.setFocus(true)
End Function 
' Row item selected handler
Function OnRowItemSelected()
    ?"On row item selected"
    ' On select any item on home scene, show Details node and hide Grid
'    m.gridScreen.visible = "false"
'    m.detailsScreen.content = m.gridScreen.focusedContent
'    m.detailsScreen.setFocus(true)
'    m.detailsScreen.visible = "true"

    if m.gridScreen.visible = true and m.episodes.visible = false
        if m.gridScreen.itemFocused[0] = 1
            m.gridScreen.visible = "false"
            selectedItem = m.gridScreen.focusedContent
            print selectedItem
            'init of video player and start playback
            'm.detailsScreen.visible = true
            'm.detailsScreen.videoPlayerVisible = true
            m.videoPlayerVisible = true
            m.videoPlayer2.visible = true
            m.videoPlayer2.setFocus(true)
            m.videoPlayer2.content = selectedItem
            print "started playing from home"
            m.videoPlayer2.control = "play"
            sec = createObject("roRegistrySection", "MySection")
            Key = m.videoPlayer2.content.id
            if sec.Exists(Key)
              ' Parse json to get bookmark time
              readJsonString =  sec.Read(Key)
              readJsonObject = parseJson(readJsonString)
              m.videoPlayer2.seek = readJsonObject.time
            end if        
            m.videoPlayer2.observeField("state", "OnVideoPlayerStateChange")
        else
            print m.gridScreen.focusedContent
            m.gridScreen.visible = "false"
            m.episodes.showName = m.gridScreen.focusedContent.title
            m.episodes.seasonUrl = m.gridScreen.focusedContent.seasonUrl
            m.episodes.seasonCount = m.gridScreen.focusedContent.seasonNumber
            m.episodes.canCallApi = true
            m.episodes.content = m.gridScreen.focusedContent
            m.episodes.setFocus(true)
            m.episodes.visible = true 
            
            result = true 
        end if
    else if m.gridScreen.visible = false and m.episodes.visible = true
        m.episodes.visible = false
        m.detailsScreen.epUrl = m.episodes.focusedContent.url
        m.detailsScreen.content = m.episodes.focusedContent
        m.detailsScreen.setFocus(true)
        m.detailsScreen.visible = true
        m.detailsScreen.allEpisodes = m.episodes.allEpisodes
        
        print "epi **********************"
        print m.episodes.allEpisodes
        print "details***************************"
        print m.detailsScreen.allEpisodes
        
        'm.detailsScreen.videoPlayerVisible = true
        result = true
    end if
    
End Function

' set proper focus on buttons and stops video if return from Playback to details
'Sub onVideoVisibleChange()
'    print "in HS onVideoVisibleChange"
'    if m.videoPlayer2.visible = false and (m.top.visible = true or m.top.visible = false)
'        TimeStamp = Str(m.videoPlayer2.position)
'        Key = m.videoPlayer2.content.id
'        print m.videoPlayer2.content
'        ' Construct json here
'        valueJson = {"time":  m.videoPlayer2.position, "url": m.videoPlayer2.content.url, "streamFormat": "mp4", "id": Key}
'        ' Then turn json into string
'        valueJsonString = FormatJson(valueJson, 0)
'        sec = createObject("roRegistrySection", "MySection")
'        sec.Write(Key, valueJsonString)
'        sec.Flush()
'    end if
'End Sub

Sub OnVideoPlayerStateChange()
    print "in HS onVideoPlayerStateChange"
    ? "HomeScene > OnVideoPlayerStateChange : state == ";m.videoPlayer2.state
    if m.videoPlayer2.visible = false and (m.top.visible = true or m.top.visible = false)
        TimeStamp = Str(m.videoPlayer2.position)
        Key = m.videoPlayer2.content.id
        print m.videoPlayer2.content
        ' Construct json here
        valueJson = {"time":  m.videoPlayer2.position, "url": m.videoPlayer2.content.url, "streamFormat": "mp4", "id": Key}
        ' Then turn json into string
        valueJsonString = FormatJson(valueJson, 0)
        sec = createObject("roRegistrySection", "MySection")
        sec.Write(Key, valueJsonString)
        sec.Flush()
    end if
    if m.videoPlayer2.state = "error"
        'hide vide player in case of error
        m.videoPlayer2.visible = false
        m.GridScreen.visible = true
        m.GridScreen.setFocus(true)
    else if m.videoPlayer2.state = "playing"
    else if m.videoPlayer2.state = "finished"
        'hide vide player if video is finished
        m.videoPlayer2.visible = false
        
        Key = m.videoPlayer2.content.id
        sec = createObject("roRegistrySection", "MySection")
        sec.Delete(Key)
        onItemSelected()
        m.GridScreen.visible = true
        m.GridScreen.setFocus(true)
    end if
end Sub

' Main Remote keypress event loop
Function OnKeyEvent(key, press) as Boolean
    ? ">>> HomeScene >> OnkeyEvent"
    
    result = false
    if press then
        if key = "options"
            ' option key handler

            m.option.setFocus(true)
            'print m.option.hasFocus()
            result  = true


        else if key = "back"
        print "back pressed"
            if m.option.hasFocus() = true or m.optionCont.visible
                m.optionCont.visible = "false"
                m.gridScreen.setFocus(true)
                result = true
            ' if Episodes opened
            end if
            if m.gridScreen.visible = false and m.videoPlayer2.visible = true
                m.videoPlayer2.visible = false
                m.videoPlayerVisible = false
                m.videoPlayer2.control = "stop"
                m.GridScreen.visible = true
                m.GridScreen.setFocus(true)
                result = true
            else if m.gridScreen.visible = false and m.episodes.visible = true
                m.gridScreen.setFocus(true)
                m.gridScreen.visible =true
                'm.detailsScreen.visible = "false"
                m.episodes.visible = false
                result = true            
'            else if m.episodes.visible = false and m.detailsScreen.visible = true
'                m.episodes.setFocus(true)
'                m.episodes.visible = true
'                m.detailsScreen.visible = false
'                result = true
                
            else if m.episodes.visible = false and m.detailsScreen.videoPlayerVisible = true
                m.detailsScreen.videoPlayerVisible = false
                m.detailsScreen.visible=false
                m.episodes.visible = true
                m.episodes.setFocus(true)
                'print "this one runs"
                result = true 
            else if m.detailsScreen.visible = true and m.detailsScreen.videoPlayerVisible = false
                m.detailsScreen.visible=false
                m.episodes.visible = true
                m.episodes.setFocus(true)
                result = true
            'end if
            'if video player opened
            else if m.gridScreen.visible = false and m.episodes.videoPlayerVisible = true
                m.detailsScreen.videoPlayerVisible = false
                m.detailsScreen.visible = false
                m.episodes.visible = true
                m.episodes.setFocus(true)
                result = true   
            end if


        end if
    end if
    return result
End Function
