' ********** Copyright 2015 Roku Corp.  All Rights Reserved. ********** 

Sub RunUserInterface()
    screen = CreateObject("roSGScreen")
    scene = screen.CreateScene("HomeScene")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.Show()
    
    oneRow = GetApiArray()
    

    test = "TEST"
    
    list = [
        {
            TITLE : test
            ContentList : oneRow  
        }
        {
            TITLE : test
            ContentList : oneRow
        }
    ]
    scene.gridContent = ParseXMLContent(list)

    while true
        msg = wait(0, port)
        print "------------------"
        print "msg = "; 
    end while
    
    if screen <> invalid then
        screen.Close()
        screen = invalid
    end if
End Sub


Function ParseXMLContent(list As Object)
    RowItems = createObject("RoSGNode","ContentNode")
    
    for each rowAA in list
    'for index = 0 to 1
        row = createObject("RoSGNode","ContentNode")
        row.Title = rowAA.Title

        for each itemAA in rowAA.ContentList
            item = createObject("RoSGNode","ContentNode")
            ' We don't use item.setFields(itemAA) as doesn't cast streamFormat to proper value
            for each key in itemAA
                item[key] = itemAA[key]
            end for
            row.appendChild(item)
        end for
        RowItems.appendChild(row)
    end for

    return RowItems
End Function


Function GetApiArray()


    request = CreateObject("roUrlTransfer")
    request.setRequest("GET")
    request.SetURL("http://vstage-api.mini-me.co/collections?product=https%3A%2F%2Fapi.vhx.tv%2Fproducts%2F37342&type=series")
    request.AddHeader("auth", "KPBR41wti28eGnLvVuQikPnPOVpv2TCk")
    jsonString = request.GetToString()
    jsonParsed = parseJSON(jsonString)
    jsonParsed = jsonParsed
    
    'JSONArray = jasonParsed().getChildElements()
    
    'for each collection in jsonParsed._embedded.collections
     'test = collection.name

    'end for

    result = []
        
    for each collection in jsonParsed._embedded.collections
                item = {}
                item.HDPosterUrl = collection.thumbnail.medium
                item.hdBackgroundImageUrl = collection.thumbnail.large
                item.Title = collection.name
                item.ReleaseDate = " "
                item.Description = collection.description
                result.push(item)
    end for
        
        
        
'    url = CreateObject("roUrlTransfer")
'    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
'    rsp = url.GetToString()

'    responseXML = ParseXML(rsp)
'    responseXML = responseXML.GetChildElements()
'    responseArray = responseXML.GetChildElements()

'    result = []

'   for each xmlItem in responseArray
''        if xmlItem.getName() = "item"
'            itemAA = xmlItem.GetChildElements()
'            if itemAA <> invalid
'                item = {}
'                for each xmlItem in itemAA
'                    item[xmlItem.getName()] = xmlItem.getText()
'                    if xmlItem.getName() = "media:content"
'                        item.stream = "https://gcs-vimeo.akamaized.net/exp=1570076855~acl=%2A%2F1226668184.mp4%2A~hmac=9e109b3465f27fd060a210d334adff79f127c54912d568b4fc8aa409650ac0e5/vimeo-prod-skyfire-std-us/01/3386/12/316932154/1226668184.mp4"
'                        item.url = "https://gcs-vimeo.akamaized.net/exp=1570076855~acl=%2A%2F1226668184.mp4%2A~hmac=9e109b3465f27fd060a210d334adff79f127c54912d568b4fc8aa409650ac0e5/vimeo-prod-skyfire-std-us/01/3386/12/316932154/1226668184.mp4"
'                        item.streamFormat = "mp4"
'                        
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

    return result
End Function


Function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml=CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function
