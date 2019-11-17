sub RunUserInterface(APIURL)

'    screen2 = CreateObject("roSGScreen")
'    scene2 = screen.CreateScene("GridScreen")
    'm.gridScreen = m.findNode("GridScreen")

    oneRow = GetApiArray(APIURL)
    list = []
    
    if oneRow[0] = invalid
        screen = CreateObject("roSGScreen")
        scene = screen.CreateScene("ErrorScene")
        port = CreateObject("roMessagePort")
        screen.SetMessagePort(port)
        screen.Show()
        while true
            msg = Wait(0, port)
            ? "------------------"
            ? "msg = ";
        end while
    else     

        screen = CreateObject("roSGScreen")
        scene = screen.CreateScene("HomeScene")
        port = CreateObject("roMessagePort")
        screen.SetMessagePort(port)
        screen.Show()
        series = "Series"
        continue = "Continue watching..."
        list = [
            {
                TITLE: series
                ContentList: oneRow
            }
            {
                TITLE: continue
                ContentList: oneRow
            }
        ]
        scene.gridContent = parseJSONObject(list)
    
        while true
            msg = Wait(0, port)
            ? "------------------"
            ? "msg = ";
        end while
    end if
    


    if screen <> invalid then
        screen.Close()
        screen = invalid
    end if
end sub

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

function GetApiArray(APIURL)

    request = CreateObject("roUrlTransfer")
    request.setRequest("GET")
    '????why there are too url
    'request.setURL("http://vstage-api.mini-me.co/collections/78988/items?product=https%3A%2F%2Fapi.vhx.tv%2Fproducts%2F37342")
    request.setURL("http://vstage-api.mini-me.co/collections?product=https%3A%2F%2Fapi.vhx.tv%2Fproducts%2F37342&type=series")
    ' request.SetUrl(APIURL)
    request.AddHeader("auth", "KPBR41wti28eGnLvVuQikPnPOVpv2TCk")
    jsonString = request.GetToString()
    jsonParsed = ParseJson(jsonString)

    result = []
    
    if jsonParsed = Invalid
        
        print scene
        return result
    end if



    for each show in jsonParsed._embedded.collections
        item = {}
        item.HDPosterUrl = show.thumbnail.medium
        'item.hdBackgroundImageUrl = show.thumbnail.large '
        item.Title = show.name
        'item.ReleaseDate = " "'
        'item.Description = " " '
        item.seasonUrl = show._links.seasons.href
        item.seasonNumber = show.seasons_count.ToStr()
        result.push(item)
    end for

    return result
end function