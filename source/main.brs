' ********** Copyright 2015 Roku Corp.  All Rights Reserved. ********** 

sub RunUserInterface(APIURL)
    screen = CreateObject("roSGScreen")
    scene = screen.CreateScene("HomeScene")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.Show()

    oneRow = GetApiArray(APIURL)

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
    request.setURL("http://vstage-api.mini-me.co/collections/78988/items?product=https%3A%2F%2Fapi.vhx.tv%2Fproducts%2F37342")
    request.SetURL("http://vstage-api.mini-me.co/collections?product=https%3A%2F%2Fapi.vhx.tv%2Fproducts%2F37342&type=series")
    ' request.SetUrl(APIURL)
    request.AddHeader("auth", "KPBR41wti28eGnLvVuQikPnPOVpv2TCk")
    jsonString = request.GetToString()
    jsonParsed = ParseJson(jsonString)
    jsonParsed = jsonParsed

    ' JSONArray = jasonParsed().getChildElements()

    ' for each collection in jsonParsed._embedded.collections
    ' test = collection.name

    ' end for

    result = []

    for each show in jsonParsed._embedded.collections
        item = {}
        item.HDPosterUrl = show.thumbnail.medium
        'item.hdBackgroundImageUrl = show.thumbnail.large '
        item.Title = show.name
        'item.ReleaseDate = " "'
        'item.Description = " " '
        item.SeasonAPI = show._links.seasons.href

        result.push(item)
    end for

    return result
end function



'    for each season in jsonParsed._embedded.items
'                item = {}
'                item.HDPosterUrl = season.thumbnail.medium
'                item.hdBackgroundImageUrl = season.thumbnail.large
'                item.Title = season.name
'                item.ReleaseDate = " "
'                item.Description = season.description
'                result.push(item)
'    end for

'    url = CreateObject("roUrlTransfer")
'    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
'    rsp = url.GetToString()

'    responseXML = ParseXML(rsp)
'    responseXML = responseXML.GetChildElements()
'    responseArray = responseXML.GetChildElements()

'    result = []

'   for each xmlItem in responseArray
'        if xmlItem.getName() = "item"
'            itemAA = xmlItem.GetChildElements()
'            if itemAA <> invalid
'                item = {}
'                for each xmlItem in itemAA
'                    item[xmlItem.getName()] = xmlItem.getText()
'                    if xmlItem.getName() = "media:content"
'                        item.stream = "https://gcs-vimeo.akamaized.net/exp=1570076855~acl=%2A%2F1226668184.mp4%2A~hmac=9e109b3465f27fd060a210d334adff79f127c54912d568b4fc8aa409650ac0e5/vimeo-prod-skyfire-std-us/01/3386/12/316932154/1226668184.mp4"
'                        item.url = "https://gcs-vimeo.akamaized.net/exp=1570076855~acl=%2A%2F1226668184.mp4%2A~hmac=9e109b3465f27fd060a210d334adff79f127c54912d568b4fc8aa409650ac0e5/vimeo-prod-skyfire-std-us/01/3386/12/316932154/1226668184.mp4"
'                        item.streamFormat = "mp4"

'                        mediaContent = xmlItem.GetChildElements()
'                        for each mediaContentItem in mediaContent
'                            if mediaContentItem.getName() = "media:thumbnail"
'                                item.HDPosterUrl = mediaContentItem.getattributes().url
'                                item.hdBackgroundImageUrl = mediaContentItem.getattributes().url
'                            end if
'                        end for
'                    end if
'                end for
'                result.push(item)
'            end if
'        end if
'    end for
