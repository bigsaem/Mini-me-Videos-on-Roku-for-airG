' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits details screen
 ' sets all observers 
 ' configures buttons for Details screen
Function Init()
    ? "[DetailsScreen] init"

    m.top.observeField("visible", "onVisibleChange")
   ' m.top.observeField("focusedChild", "OnFocusedChildChange")

    'm.content           =   CreateObject("roSGNode", "ContentNode") 
    m.gVideos = m.top.findNode("getVideos")
     
    'm.buttons           =   m.top.findNode("Buttons")
    m.videoPlayer       =   m.top.findNode("VideoPlayer")
    'm.poster            =   m.top.findNode("Poster")
    'm.description       =   m.top.findNode("Description")
    m.background        =   m.top.findNode("Background")
    
    fileUrl = ""
    
    m.epTask = CreateObject("roSGNode", "getVideos")
    m.epTask.observeField("fEpUrl", "gotContent")
    ' create buttons
    result = []
    'for each button in ["Play", "Second button"]
        'result.push({title : button})
    'end for
    'm.buttons.content = ContentList2SimpleNode(result)
End Function

' set proper focus to buttons if Details opened and stops Video if Details closed
Sub onVisibleChange()
    ? "[DetailsScreen] onVisibleChange"
    
    print "************************"
    print "video state"
    print m.videoPlayer.state
    
    if m.top.epUrl <> "" and (m.videoPlayer.state = "none" or m.videoPlayer.state = "stopped")
        m.epTask.contenturi = m.top.epUrl
        m.epTask.control = "RUN"
        
    else 'if m.videoPlayer.state = "playing"
        print "stopping state"
        m.videoPlayer.visible = false
        m.videoPlayer.control = "stop"
    
    end if
    
    

'    else
'        m.videoPlayer.visible = false
'        m.videoPlayer.control = "stop"
'        m.poster.uri=""
'        m.background.uri=""
'    end if
End Sub

' set proper focus to Buttons in case if return from Video PLayer
Sub OnFocusedChildChange()
    if m.top.isInFocusChain() and not m.buttons.hasFocus() and not m.videoPlayer.hasFocus() then
        m.buttons.setFocus(true)
    end if
End Sub

' set proper focus on buttons and stops video if return from Playback to details
Sub onVideoVisibleChange()
    if m.videoPlayer.visible = false and (m.top.visible = true or m.top.visible = false)
        print "im here"
        'm.buttons.setFocus(true)
        'm.videoPlayer.control = "stop"
        TimeStamp = Str(m.videoPlayer.position)
        Key = m.videoPlayer.content.id
        ' Construct json here
        valueJson = {"time":  m.videoPlayer.position}
        ' Then turn json into string
        valueJsonString = FormatJson(valueJson, 0)
        sec = createObject("roRegistrySection", "MySection")
        sec.Write(Key, valueJsonString)
        sec.Flush()
    end if
End Sub

function gotContent()
    'just changed
    print  m.epTask.fEpUrl
    print m.epTask.passNode
    'print fileUrl
    print "got url"
    print "after"
    
    m.top.content = m.epTask.passNode
    OnContentChange()
end function

' event handler of Video player msg
Sub OnVideoPlayerStateChange()
    if m.videoPlayer.state = "error"
        ' error handling
        m.videoPlayer.visible = false
    else if m.videoPlayer.state = "playing"
        ' playback handling
    else if m.videoPlayer.state = "finished"
        m.videoPlayer.visible = false
        Key = m.videoPlayer.content.id
        sec = createObject("roRegistrySection", "MySection")
        sec.Delete(Key)
    end if
End Sub

' on Button press handler
Sub onItemSelected()
    ' first button is Play
            
    'if m.top.itemSelected = 0
        'm.top.visible = false
        m.videoPlayer.visible = true
        m.videoPlayer.setFocus(true)
        m.videoPlayer.control = "play"
        sec = createObject("roRegistrySection", "MySection")
        ' TODO change my section to something else? 
        BookmarkTime = 0
        ' Key = m.top.streamUrl
        Key = m.videoPlayer.content.id
        ' Key should be video/episode id
        if sec.Exists(Key)
          ' Parse json to get bookmark time
          '  testObject = ParseJson(testString)
          '  testObject.time
          readJsonString =  sec.Read(Key)
          readJsonObject = parseJson(readJsonString)
          m.videoPlayer.seek = readJsonObject.time
        end if
        ' Should parse json string here to get json object, to get time
        m.videoPlayer.observeField("state", "OnVideoPlayerStateChange")
    'End if
End Sub

' Content change handler
Sub OnContentChange()
'?"on content change"

    
    m.videoPlayer.content   = m.top.content    
    onItemSelected()
    
End Sub

'///////////////////////////////////////////'
' Helper function convert AA to Node
Function ContentList2SimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object
    result = createObject("roSGNode",nodeType)
    if result <> invalid
        for each itemAA in contentList
            item = createObject("roSGNode", nodeType)
            item.setFields(itemAA)
            result.appendChild(item)
        end for
    end if
    return result
End Function