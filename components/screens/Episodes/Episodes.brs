' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ? "[Episodes] Init"
        
    m.MarkupGrid    =   m.top.findNode("MarkupGrid")
    m.background    =   m.top.findNode("Background")
    m.errorScene = m.top.findNode("ErrorScene")
    m.busyspinner = m.top.findNode("BusySpinner")
    m.busyspinner.poster.uri = "pkg:/images/loader2.png"
    m.sceneTask = CreateObject("roSGNode", "GetEpisodes")
    m.top.observeField("visible", "onVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.showTitle = m.top.findNode("show_title")
    m.showTitle.font.size = 30
    m.seasonNumber = 0
    m.seasonIndex = 0
End Function

' handler of focused item in RowList
Sub OnItemFocused()
    'print m.top.itemFocused
    itemIndex = m.MarkupGrid.itemFocused
    itemsPerSeason = []
    For x=0 To m.seasonNumber-1
        itemsPerSeason.push(m.top.content.getChild(x).getChildCount())
    End For
    season = 0
    sumOfItems = itemsPerSeason[0]
    while itemIndex >= sumOfItems
        season = season + 1
        sumOfItems = sumOfItems + itemsPerSeason[season]
    end while 
    if season > 0
        sumOfItems = sumOfItems - itemsPerSeason[season]
        itemIndex = itemIndex - sumOfItems
    end if
    print itemindex
    aa = CreateObject("roSGNode", "ContentNode")
    aa = m.top.content.getChild(season)
    m.top.focusedContent = aa.getChild(itemIndex)
End Sub

function updateRow()
    m.CWTask = CreateObject("roSGNode", "GetEpisodes")
    m.CWTask.control = "RUN"
end function
' set proper focus to RowList in case if return from Details Screen
Sub onVisibleChange()
'print "in on visible change"
    
'    if m.top.seasonUrl <> "" and m.top.canCallApi = true
'        'loading indicator stuff
'   
'        'm.top.canCallApi = false    
'    end if
    if m.top.visible = true 
        centerx = (1280 - m.busyspinner.poster.bitmapWidth) / 2
        centery = (720 - m.busyspinner.poster.bitmapHeight) / 2
        m.busyspinner.translation = [ centerx, centery ]
        m.busyspinner.visible = true
        'loading indicator ends
        print "thread runs again"
        m.sceneTask.seasonCount = m.top.seasonCount.ToInt()
        m.sceneTask.seasonUrl = m.top.seasonUrl
        m.sceneTask.showName = m.top.showName
        m.sceneTask.observeField("content","gotContent")
        m.sceneTask.control = "RUN"   
        m.showTitle.text = m.top.showName
        m.seasonIndex = 0
        m.MarkupGrid.setFocus(true)
    else 
        m.sceneTask.unobserveField("content")
        m.MarkupGrid.unobserveField("itemFocused")
    end if
  
End Sub


Sub OnFocusedChildChange()
    if m.top.isInFocusChain() and not m.MarkupGrid.hasFocus() then
        m.MarkupGrid.setFocus(true)
    end if
End Sub


function gotContent()      
      
    jsonParsed = m.sceneTask.content
    result  = []
    x = 0
    y = 0
    m.seasonNumber = 0
    m.newContent = createObject("RoSGNode", "ContentNode")
    for each season in jsonParsed.keys()
        m.seasonNumber = m.seasonNumber+1 
        m.sectionContent = m.newContent.createChild("ContentNode")
        m.sectionContent.CONTENTTYPE = "SECTION"
        m.sectionContent.title = "Season " + m.seasonNumber.toStr()
        print "this one should be printed before number"
        for each episode in jsonParsed[Season]._embedded.items
            
            item = m.sectionContent.createChild("ContentNode")
            item.id = episode.id
            item.HDGRIDPOSTERURL = episode.thumbnail.small
            item.SDGRIDPOSTERURL = episode.thumbnail.medium
            item.Title = episode.title
            hyphenIndex = Instr(1, episode.title, "-")
            if hyphenIndex > 3
                hyphenIndex = hyphenIndex - 3
            end if
            title = mid(episode.title, hyphenIndex)
            item.SHORTDESCRIPTIONLINE1 = title
            item.url = episode._links.files.href
            item.episodeNumber = episode.episode_number
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
        end for
    end for

    m.top.content = m.newContent
    m.top.refreshNode = m.newContent
    m.busyspinner.visible = false
    m.MarkupGrid.observeField("itemFocused","OnItemFocused")
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
