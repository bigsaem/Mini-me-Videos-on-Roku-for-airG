 ' inits video screen
 ' sets all observers 
Function Init()
    ? "[VideoScreen] init"
    m.popupbox = m.top.findNode("popupBox")
    m.buttongrpp = m.top.findNode("button_grpp")
    m.buttongrpp.translation = "[440,500]"
    m.btn_begin = m.top.findNode("play_from_beginning")
    m.btn_begin.observeField("buttonSelected", "onBeginButtonSelected")
    m.btn_resume = m.top.findNode("resume")
    m.btn_resume.observeField("buttonSelected","onResumeButtonSelected")
    m.eptitle = m.top.findNode("ep_title")
    m.eptitle.translation = "[440,470]"
    m.poster = m.top.findNode("thumbnail_box")
    m.poster.uri = m.top.thumbnail
    m.top.observeField("visible", "onVisibleChange")
   ' m.top.observeField("focusedChild", "OnFocusedChildChange")
     
    'm.content           =   CreateObject("roSGNode", "ContentNode") 
    m.gVideos = m.top.findNode("getVideos")
    m.videoPlayer       =   m.top.findNode("VideoPlayer")
    customizeProgressBar(m.videoPlayer.retrievingBar)
    tpbar = m.videoPlayer.trickPlayBar
    customizeProgressBar(tpbar)
    tpbar.completedBarImageUri = "pkg:/images/barcolor.png"
    customizeProgressBar(m.videoPlayer.bufferingBar)
    customizeProgressBar(m.videoPlayer.progressBar)
    m.background  = m.top.findNode("Background")
    
    fileUrl = ""
    m.videoPlayer.tranlsation = "[0,0]"
    m.epTask = CreateObject("roSGNode", "getVideos")
    m.epTask.observeField("fEpUrl", "gotContent")
    m.mask = m.top.findNode("mask")
End Function


' set proper focus to buttons if Details opened and stops Video if Details closed
Sub onVisibleChange()

    ? "[VideoScreen] onVisibleChange"

    m.buttongrpp.setFocus(true)
    m.popupbox.visible = false
    if m.top.epUrl <> "" and (m.videoPlayer.state = "none" or m.videoPlayer.state = "stopped")
        m.epTask.id = m.top.id
        m.epTask.contenturi = m.top.epUrl
        m.epTask.episodeName = m.top.content.ShortDescriptionLine1
        m.epTask.control = "RUN"
    else 'if m.videoPlayer.state = "playing"
        m.videoPlayer.visible = false
        m.videoPlayer.control = "stop"
    end if
    if m.top.visible = false
        m.mask.visible = false
    end if
End Sub

'callback function for when the vTask completes the API call
function gotContent()
    sec = createObject("roRegistrySection", "MySection")
    Key = m.epTask.passNode.id
    if sec.Exists(Key)
        m.popupbox.visible = true
         m.mask.visible = true
        m.poster.uri = m.top.thumbnail
        m.eptitle.text = m.top.passedTitle
    else 
        onBeginButtonSelected()
    end if
end function

' set proper focus on buttons and stops video if return from Playback to details
Sub onVideoVisibleChange()
    if m.videoPlayer.visible = false and (m.top.visible = true or m.top.visible = false)
        TimeStamp = Str(m.videoPlayer.position)
        Key = m.videoPlayer.content.id
        sec = createObject("roRegistrySection", "MySection")
        if m.videoPlayer.position > 10 and m.videoPlayer.position < (Val(m.videoPlayer.content.description) - 10)
            ' Construct json here
            valueJson = {"time":  m.videoPlayer.position, "thumbnail":m.top.thumbnail, "url": m.top.epUrl, "streamFormat": "mp4", "id": Key, "duration": m.videoPlayer.content.description, "name": m.videoPlayer.content.Title }
            ' Then turn json into string
            valueJsonString = FormatJson(valueJson, 0)
            sec.Write(Key, valueJsonString)
            sec.Flush()
        else 
            sec.Delete(Key)
        end if
    end if
End Sub

'Handles when the user chooses to resume episode
function onResumeButtonSelected()
    m.top.content = m.epTask.passNode
    m.videoPlayer.content = m.top.content    
    playFromLastTime()
end function

'Handles when user chooses to play from beginning
function onBeginButtonSelected()
    m.top.content = m.epTask.passNode
    m.videoPlayer.content = m.top.content    
    playFromBeginning()
end function

'Starts episode from beginning if the user chosses to play from beginning
function playFromBeginning()
    m.videoPlayer.visible = true
    m.videoPlayer.setFocus(true)
    m.videoPlayer.control = "play"
    sec = createObject("roRegistrySection", "MySection")
    m.videoPlayer.observeField("state", "OnVideoPlayerStateChange")
end function

'Playes episode from the same time that it was stopped last
function playFromLastTime()
    m.videoPlayer.visible = true
    m.videoPlayer.setFocus(true)
    m.videoPlayer.control = "play"
    sec = createObject("roRegistrySection", "MySection")
    Key = m.videoPlayer.content.id
    if sec.Exists(Key)
      ' Parse json to get bookmark time
      readJsonString =  sec.Read(Key)
      readJsonObject = parseJson(readJsonString)
      m.videoPlayer.seek = readJsonObject.time
    end if        
    m.videoPlayer.observeField("state", "OnVideoPlayerStateChange")
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
        
        m.videoPlayer.visible = true
        m.videoPlayer.setFocus(true)
        m.videoPlayer.control = "play"
        sec = createObject("roRegistrySection", "MySection")
        Key = m.videoPlayer.content.id
        if sec.Exists(Key)
          ' Parse json to get bookmark time
          readJsonString =  sec.Read(Key)
          readJsonObject = parseJson(readJsonString)
          m.videoPlayer.seek = readJsonObject.time
        end if        
          m.videoPlayer.observeField("state", "OnVideoPlayerStateChange")
        
    'End if
End Sub

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

'Formats the progress bar to have the majestic mini-me blue colour
sub customizeProgressBar(progressBar as Dynamic)
    bar = progressBar
    if bar <> invalid
        bar.filledBarImageUri = "pkg:/images/barcolor.png"
        bar.filledBarBlendColor = "0xFFFFFFFF"
    end if
end sub