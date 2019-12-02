' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ' listen on port 8089
    ? "[HomeScene] Init"
    
    m.background    =    m.top.findNode("Background")
    m.itemmask      =    m.top.findNode("itemMask")
    ' GridScreen node with RowList

    m.gridScreen    =    m.top.findNode("GridScreen")
    m.episodes      =    m.top.findNode("Episodes")
    m.errorScene    =    m.top.findNode("ErrorScene")
    m.rowList       =    m.top.findNode("rowList")
    m.bg            =    m.top.findNode("GridScreen").getChild(0)
    ' DetailsScreen Node with description, Video Player

    m.detailsScreen =    m.top.findNode("DetailsScreen")
    m.videoPlayer   =    m.detailsScreen.findNode("VideoPlayer")
    
    m.option        =    m.top.findNode("option_btn")
    m.optionCont = m.top.findNode("optionCont")
    ' Observers
    m.top.observeField("rowItemSelected", "OnRowItemSelected")
    m.top.observeField("optionSelected", "OnOptionSelected")
    m.top.observeField("episodesRowItemSelected", "OnRowItemSelected") 
    m.top.observeField("playSelected", "OnRowItemSelected")
    m.videoPlayer.observeField("state", "checkEndOfEpisode")    
    m.top.observeField("visible", "OnVisibleChange")
    'animation for option bar
    m.animation = m.top.FindNode("myAnim1")
    m.gridAnim = m.top.findNode("slideUpItemMask")
    m.rowAnim = m.top.findNode("slideUpRowlist")
    m.videoFromEpisode = true

    m.exitConfirm = m.top.findNode("ExitConfirm")
    m.exitButtongrp = m.top.findNode("yesOrNo")
    m.mask = m.top.findNode("mask")
    m.yes = m.top.findNode("Yes")
    m.no = m.top.findNode("No")
    m.yes.observeField("buttonSelected", "exitMMV")
    m.no.observeField("buttonSelected", "exit_cancel")
    'print type(m.detailsScreen.videoPlayer)
End Function 
function exitMMV()
    m.top.exitApp = true
end function
function exit_cancel()
    m.mask.visible = false
    m.exitConfirm.visible = false
    m.top.visible = true
    m.gridScreen.setFocus(true)
end function



'When a video is completed go back to episode screen with focus on last item selected
function checkEndOfEpisode()
    if m.videoPlayer.visible = true and m.videoPlayer.state = "finished"    
        videoEnded()
    end if
end function
function OnVisibleChange()
    if m.top.visible = true
        m.videoFromEpisode = true
    end if
End Function

' if content set, focus on GridScreen
Function OnChangeContent()
    m.gridAnim.control = "start"
    m.rowAnim.control = "start"
    m.gridScreen.setFocus(true)
    'm.episodes.setFocus(true)
    'm.loadingIndicator.control = "stop"
End Function

function updateRow()
    m.CWTask = CreateObject("roSGNode", "ContinueWatching")
    m.CWTask.control = "RUN"

end function

'Option button selected handler
Function OnOptionSelected()
    m.mask.visible = true
    m.optionCont.visible = "true"
    m.animation.control = "start"
    m.optionCont.setFocus(true)
End Function 

' Row item selected handler
Function OnRowItemSelected()
    ?"On row item selected"
    if m.gridScreen.visible = true and m.episodes.visible = false 
        if m.gridScreen.itemFocused[0] = 0 and m.top.rowCount > 1
            selectedItem = m.gridScreen.focusedContent
            m.videoFromEpisode = false
            m.detailsScreen.id = m.gridScreen.focusedContent.id
            m.detailsScreen.epUrl = m.gridScreen.focusedContent.url            
            m.detailsScreen.content = m.gridScreen.focusedContent
            m.detailsScreen.passedTitle = m.gridScreen.focusedContent.Title
            m.detailsScreen.thumbnail = m.gridScreen.focusedContent.HDPOSTERURL
            m.detailsScreen.visible = true
            m.detailsScreen.setFocus(true)
        else
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
        end if

    else if m.gridScreen.visible = false and m.episodes.visible = true
        print m.episodes.focusedContent
        m.videoFromEpisode = true
        m.detailsScreen.id = m.episodes.focusedContent.id
        m.detailsScreen.epUrl = m.episodes.focusedContent.url
        m.detailsScreen.content = m.episodes.focusedContent
        m.detailsScreen.passedTitle = m.episodes.focusedContent.SHORTDESCRIPTIONLINE1
        m.detailsScreen.thumbnail = m.episodes.focusedContent.SDGRIDPOSTERURL
        m.detailsScreen.visible = true
        m.detailsScreen.setFocus(true)
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
            if m.detailsScreen.visible = false and m.exitConfirm.visible = false
                m.option.setFocus(true)
                result  = true
            end if

        else if key = "back"
        print "back pressed"
            if (m.optionCont.visible = true or m.option.hasFocus() = true) and m.gridScreen.visible = true
                m.mask.visible = false
                m.optionCont.visible = "false"
                m.gridScreen.setFocus(true)
                updateRow()
                result = true
            else if m.exitConfirm.visible = true
               m.exitConfirm.visible = false
               m.mask.visible = false
               m.gridScreen.setFocus(true)
               result = true   
            else if (m.optionCont.visible = true or m.option.hasFocus() = true) and m.episodes.visible = true
                m.mask.visible = false
                m.optionCont.visible = "false"
                m.episodes.setFocus(true)
                result = true
            else if m.detailsScreen.videoPlayerVisible = true            
                videoEnded()       
                result = true 
            else if m.gridScreen.visible = true and m.detailsScreen.visible = true
                m.detailsScreen.visible = false
                m.GridScreen.visible = true
                m.GridScreen.setFocus(true)
                result = true
            else if m.episodes.visible = true and m.detailsScreen.visible = true
                m.detailsScreen.visible=false
                m.episodes.visible = true
                m.episodes.setFocus(true)
                result = true
            else if m.gridScreen.visible = false and m.episodes.visible = true
                updateRow()
                m.gridScreen.setFocus(true)
                m.gridScreen.visible = true
                m.episodes.visible = false
                result = true            
            else if m.gridScreen.visible = true and m.episodes.visible = false and m.detailsScreen.visible = false
               m.exitConfirm.visible = true
               m.mask.visible = true
               m.exitButtongrp.setFocus(true)
               result = true  

            end if
        end if
    end if
    return result
End Function

function videoEnded()
    if m.videoFromEpisode = true 
        m.detailsScreen.videoPlayerVisible = false
        m.detailsScreen.visible=false
        
        m.episodes.visible = true        
        m.episodes.setFocus(true)
        
        print m.detailsScreen.fuckingflag
        if m.detailsScreen.fuckingflag = true
            m.episodes.content = m.episodes.refreshNode
        end if
    else 
        m.detailsScreen.videoPlayerVisible = false
        m.detailsScreen.visible=false
        m.gridScreen.visible = true
        m.gridScreen.setFocus(true)
    end if 
end function

