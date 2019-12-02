sub RunUserInterface(APIURL)

'    screen2 = CreateObject("roSGScreen")
'    scene2 = screen.CreateScene("GridScreen")
    'm.gridScreen = m.findNode("GridScreen")
     
    APIURL = "http://vstage-api.mini-me.co/collections?product=https%3A%2F%2Fapi.vhx.tv%2Fproducts%2F37342&type=series"
    oneRow = GetContinueWatchingArray()
    twoRow = GetApiArray(APIURL)
    size = 0
    
    for each item in oneRow
        size = size + 1
    end for
        
    print size
    
    list = []
        
    if twoRow = invalid
        screen = CreateObject("roSGScreen")
        scene = screen.CreateScene("ErrorScene")
        port = CreateObject("roMessagePort")
        screen.SetMessagePort(port)
        screen.Show()
        
        while true
            msg = Wait(0, port)
            ? "------------------"
            ? "msg = "
        end while
    else
        screen = CreateObject("roSGScreen")
        scene = screen.CreateScene("HomeScene")
        port = CreateObject("roMessagePort")
        screen.SetMessagePort(port)
        screen.Show()
        series = "Series"
        continue = "Continue watching..."
        
        if size <> 0
            list = [
                {
                    TITLE: continue
                    ContentList: oneRow
                }
                {
                    TITLE: series
                    ContentList: twoRow
                }
            ]
            scene.rowCount = 2
        else
            list = [
                {
                TITLE: series
                ContentList: twoRow
                }
            ]
            scene.rowCount = 1
            
        end if
        
        scene.APIArray = twoRow         
        scene.gridContent = parseJSONObject(list)


    
        while true
            msg = Wait(0, port)
            ? "------------------"
            ? "msg = ";
        end while
        
        canGetApi = false
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
    request.SetUrl(APIURL)
    request.AddHeader("auth", "KPBR41wti28eGnLvVuQikPnPOVpv2TCk")
    jsonString = request.GetToString()
    
    

    result = []
    
    if jsonString = ""
        return invalid
    end if

    jsonParsed = ParseJson(jsonString)

    if jsonParsed = invalid
        return invalid
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

function GetContinueWatchingArray()
    result = []
    seriesInputted = []
    
    sec = createObject("roRegistrySection", "MySection")
    list = sec.GetKeyList()
    for each item in list
        inputted = false
        print item
        jsonString = sec.Read(item)
        jsonObject = parseJson(jsonString)
        
        for each seriesTitle in seriesInputted
            if seriesTitle = jsonObject.series
                inputted = true
                exit for
            end if
        end for
        
        if inputted = false
            print "inputting"
            tempItem = {}
            'tempNode = CreateObject("roSGNode", "ContentNode")
            tempItem.streamFormat = jsonObject.streamFormat
            tempItem.url = jsonObject.url
            tempItem.id = item
            tempItem.HDPosterUrl = jsonObject.thumbnail
            tempItem.description = jsonObject.description
            tempItem.Title = jsonObject.name
            seriesTitle = jsonObject.series
            result.push(tempItem)
            seriesInputted.push(seriesTitle)
        end if
    end for
    
    return result
  
end function