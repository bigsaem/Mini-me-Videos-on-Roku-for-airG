' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ? "[Episodes] Init"
        
    m.posterGrid    =   m.top.findNode("PosterGrid")
    m.background    =   m.top.findNode("Background")
    m.errorScene = m.top.findNode("ErrorScene")
    m.busyspinner = m.top.findNode("BusySpinner")
    m.busyspinner.poster.uri = "pkg:/images/loader2.png"
    m.sceneTask = CreateObject("roSGNode", "GetEpisodes")
    m.top.observeField("visible", "onVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChildChange")
    
End Function

' handler of focused item in RowList
Sub OnItemFocused()
    itemFocused = m.top.itemFocused 
    
    m.top.focusedContent = m.top.content.getChild(itemFocused)


End Sub

function updateRow()
    m.CWTask = CreateObject("roSGNode", "GetEpisodes")
    m.CWTask.control = "RUN"
end function
' set proper focus to RowList in case if return from Details Screen
Sub onVisibleChange()
'print "in on visible change"
        
    if m.top.seasonUrl <> "" and m.top.canCallApi = true
        'loading indicator stuff
        centerx = (1280 - m.busyspinner.poster.bitmapWidth) / 2
        centery = (720 - m.busyspinner.poster.bitmapHeight) / 2
        m.busyspinner.translation = [ centerx, centery ]
        m.busyspinner.visible = true
        'loading indicator ends
        m.sceneTask.seasonCount = m.top.seasonCount.ToInt()
        m.sceneTask.seasonUrl = m.top.seasonUrl
        m.sceneTask.showName = m.top.showName
        m.sceneTask.observeField("content","gotContent")
        m.sceneTask.control = "RUN"      
        m.top.canCallApi = false    

    end if

    if m.top.visible = true then     
        m.posterGrid.setFocus(true)
    end if    
End Sub


Sub OnFocusedChildChange()
    if m.top.isInFocusChain() and not m.posterGrid.hasFocus() then
        m.posterGrid.setFocus(true)
    end if
End Sub


function gotContent()        
    jsonParsed = m.sceneTask.content

    result  = []
    x = 0
    y = 0
    i = 0
    for each season in jsonParsed.keys()
        i = i+1    
        for each episode in jsonParsed[Season]._embedded.items
            
            item = {}
            item.id = episode.id
            item.HDGRIDPOSTERURL = episode.thumbnail.small
            item.SDGRIDPOSTERURL = episode.thumbnail.medium
            item.Title = "Season " + i.toStr()
            hyphenIndex = Instr(1, episode.title, "-")
            if hyphenIndex > 3
                hyphenIndex = hyphenIndex - 3
            end if
            title = mid(episode.title, hyphenIndex)
            item.SHORTDESCRIPTIONLINE1 = title
            item.url = episode._links.files.href
            item.episodeNumber = episode.episode_number
            item.ContentType = "wow"
            
            if x < 4 then
                item.X = x
                item.Y = y
            else
                x=0
                y = y+1
                item.X = x
                item.Y = y
            end if
            x = x + 1
            result.push(item)
        end for
    end for  

    series = "Episodes"
    list = [
        {
            TITLE: series
            ContentList: result
        }
    ]
    
    m.top.allEpisodes = list
    m.top.content = parseJSONObject(list)
    m.top.refreshNode = parseJSONObject(list)
    
    m.busyspinner.visible = false
end function

' set proper focus to RowList in case if return from Details Screen

function parseJSONObject(list as Object)
    for each rowAA in list
        ' for index = 0 to 1
        row = CreateObject("RoSGNode", "ContentNode")
        row.Title = rowAA.Title
        for each itemAA in rowAA.ContentList
            item = CreateObject("RoSGNode", "ContentNode")
            ' We don't use item.setFields(itemAA) as doesn't cast streamFormat to proper value
            for each key in itemAA
                item[key] = itemAA[key]
            end for
            row.appendChild(item)
        end for
    end for

    return row
end function
