' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ? "[Episodes] Init"
        
    m.rowList       =   m.top.findNode("RowList")
    m.background    =   m.top.findNode("Background")
'    m.itemposter = m.top.findNode("itemPoster")
    m.itemmask = m.top.findNode("itemMask")
    m.description   =   m.top.findNode("Description")
    
    
    m.sceneTask = CreateObject("roSGNode", "GetEpisodes")
    m.sceneTask.contenturi =  "http://vstage-api.mini-me.co/collections/78988/items?product=https%3A%2F%2Fapi.vhx.tv%2Fproducts%2F37342"
    
    print "in ep init"
    
    
    m.top.observeField("visible", "onVisibleChange")
   ' m.top.observeField("focusedChild", "OnFocusedChildChange")
    
End Function

' handler of focused item in RowList
Sub OnItemFocused()
    print("in on item focused")

    'print m.top.showName

    itemFocused = m.top.itemFocused

    'When an item gains the key focus, set to a 2-element array, 
    'where element 0 contains the index of the focused row, 
    'and element 1 contains the index of the focused item in that row.
    If itemFocused.Count() = 2 then
        focusedContent          = m.top.content.getChild(itemFocused[0]).getChild(itemFocused[1])
        if focusedContent <> invalid then
            m.top.focusedContent    = focusedContent
            
            m.description.content   = focusedContent
        end if
    end if
End Sub

' set proper focus to RowList in case if return from Details Screen
Sub onVisibleChange()
print "in on visible change"

if m.top.showName <> ""
    m.sceneTask.showName = m.top.showName
    m.sceneTask.observeField("content","gotContent")
    m.sceneTask.control = "RUN"
end if

    if m.top.visible = true then
            
        m.rowList.setFocus(true)
        
    end if
End Sub


Sub OnFocusedChildChange()
print "in on child change"
    if m.top.isInFocusChain() and not m.rowList.hasFocus() then
        m.rowList.setFocus(true)        
    end if
End Sub

function gotContent()    
    
    jsonParsed = m.sceneTask.content

    result  = []
    
    for each episode in jsonParsed._embedded.items
        item = {}
        item.HDPosterUrl = episode.thumbnail.medium
        item.hdBackgroundImageUrl = episode.thumbnail.large
        item.Title = episode.name   
        item.Description = " "     
        item.ReleaseDate = " "
        result.push(item)
    end for
    
    row = result
    
    series = "Episodes"
    list = [
        {
            TITLE: series
            ContentList: row
        }
    ]
    
    m.top.content = parseJSONObject(list)
    
    
    
end function
' set proper focus to RowList in case if return from Details Screen

function parseJSONObject(list as Object)
    RowItems = CreateObject("RoSGNode", "ContentNode")

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
        RowItems.appendChild(row)
    end for

    return RowItems
end function
