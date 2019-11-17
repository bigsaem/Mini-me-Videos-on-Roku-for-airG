' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ? "[Episodes] Init"
        
    m.rowList       =   m.top.findNode("RowList")
    m.posterGrid    =   m.top.findNode("PosterGrid")
    m.background    =   m.top.findNode("Background")
   ' m.itemmask = m.top.findNode("itemMask")
    'm.description   =   m.top.findNode("Description")   
    m.sceneTask = CreateObject("roSGNode", "GetEpisodes")
    m.top.observeField("visible", "onVisibleChange")
    m.top.observeField("focusedChild", "OnFocusedChildChange")
    
End Function

' handler of focused item in RowList
Sub OnItemFocused()
    itemFocused = m.top.itemFocused
    m.top.focusedContent = m.top.content.getChild(itemFocused)
    'When an item gains the key focus, set to a 2-element array, 
    'where element 0 contains the index of the focused row, 
    'and element 1 contains the index of the focused item in that row.
'    If itemFocused.Count() = 2 then
'        focusedContent = m.top.content.getChild(itemFocused[0]).getChild(itemFocused[1])
'        if focusedContent <> invalid then
'            m.top.focusedContent    = focusedContent
'            m.top.epUrl = focusedContent.url
'            m.description.content   = focusedContent
'        end if
'    end if
End Sub

' set proper focus to RowList in case if return from Details Screen
Sub onVisibleChange()
'print "in on visible change"

    if m.top.seasonUrl <> "" and m.top.canCallApi = true
        m.sceneTask.seasonCount = m.top.seasonCount.ToInt()
        m.sceneTask.seasonUrl = m.top.seasonUrl
        m.sceneTask.observeField("content","gotContent")
        m.sceneTask.control = "RUN"
        m.top.canCallApi = false
        
    end if

    if m.top.visible = true then
        m.posterGrid.setFocus(true)
        'm.rowList.setFocus(true)   
    end if
End Sub


Sub OnFocusedChildChange()
'    if m.top.isInFocusChain() and not m.rowList.hasFocus() then
'        m.rowList.setFocus(true)
'    end if
    
    if m.top.isInFocusChain() and not m.posterGrid.hasFocus() then
        m.posterGrid.setFocus(true)
    end if
End Sub


function gotContent()    
    jsonParsed = m.sceneTask.content    
    'print jasonParsed[Season1]._embedded.items

    result  = []
    resultReversed = []
    x = 0
    y = 0
    i = 0
    for each season in jsonParsed.keys()
        i = i+1    
        for each episode in jsonParsed[Season]._embedded.items
            
            item = {}
            item.HDGRIDPOSTERURL = episode.thumbnail.medium
            item.SDGRIDPOSTERURL = episode.thumbnail.medium
'           item.hdBackgroundImageUrl = episode.thumbnail.large

            
            item.Title = "Season " + i.toStr()

            item.SHORTDESCRIPTIONLINE1 = episode.title   
            item.url = episode._links.files.href
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
    m.top.content = parseJSONObject(list)
end function
' set proper focus to RowList in case if return from Details Screen

function parseJSONObject(list as Object)
'    RowItems = CreateObject("RoSGNode", "ContentNode")

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
'        RowItems.appendChild(row)
    end for

    return row
end function
