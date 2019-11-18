' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ' listen on port 8089
    ? "[HomeScene] Init"
    
    m.background = m.top.findNode("Background")
    m.itemmask = m.top.findNode("itemMask")
    ' GridScreen node with RowList
    m.gridScreen = m.top.findNode("GridScreen")
    m.episodes = m.top.findNode("Episodes")
'    m.episodes.observeField("renderTracking", "showspinner")
    m.errorScene = m.top.findNode("ErrorScene")
    m.rowList = m.top.findNode("rowList")
    print "hi"
    print m.rowList.visible
    
    m.bg = m.top.findNode("GridScreen").getChild(0)

    ' DetailsScreen Node with description, Video Player

    m.detailsScreen = m.top.findNode("DetailsScreen")
    m.option = m.top.findNode("option_btn")

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
    
    m.gridAnim = m.top.findNode("slideUpItemMask")
    m.rowAnim = m.top.findNode("slideUpRowlist")
    'print type(m.detailsScreen.videoPlayer)
End Function 

' if content set, focus on GridScreen
Function OnChangeContent()
    m.gridAnim.control = "start"
    m.rowAnim.control = "start"
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

    if m.gridScreen.visible = true and m.episodes.visible = false
        'anim stuff
        m.itemmask.height = "720"
        m.slideFull = m.top.findNode("slideUpFull")
        m.slideFull.control = "start"
        m.gridScreen.visible = "false"
        m.episodes.showName = m.gridScreen.focusedContent.title
        m.episodes.seasonUrl = m.gridScreen.focusedContent.seasonUrl
        m.episodes.seasonCount = m.gridScreen.focusedContent.seasonNumber
        m.episodes.canCallApi = true
        m.episodes.content = m.gridScreen.focusedContent
        m.episodes.setFocus(true)
        m.episodes.visible = true 
        
        result = true
    else if m.gridScreen.visible = false and m.episodes.visible = true
        m.episodes.visible = false
        m.detailsScreen.epUrl = m.episodes.focusedContent.url
        m.detailsScreen.content = m.episodes.focusedContent
        m.detailsScreen.setFocus(true)
        m.detailsScreen.visible = true
        'm.detailsScreen.videoPlayerVisible = true
        result = true
    end if
    
End Function

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
            if m.option.hasFocus() = true or m.optionCont.visible
                m.optionCont.visible = "false"
                m.gridScreen.setFocus(true)
                result = true
            ' if Episodes opened
            end if
            if m.gridScreen.visible = false and m.episodes.visible = true
                'anim stuff
                
                m.slideFull = m.top.findNode("slideDown")
                m.slideFull.control = "start"
   
                m.gridScreen.setFocus(true)
                m.gridScreen.visible = true
                m.episodes.visible = false
                'm.detailsScreen.visible = "false"
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
