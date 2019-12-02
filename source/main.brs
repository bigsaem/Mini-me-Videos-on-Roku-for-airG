sub RunUserInterface(args)
    'unit test code
    if args.RunTests = "true" and type(TestRunner) = "Function" then
        Runner = TestRunner()
        Runner.SetFunctions([
            TestSuite__Main
        ])
        Runner.Logger.SetVerbosity(3)
        Runner.Logger.SetEcho(false)
        Runner.Logger.SetJUnit(false)
        Runner.SetFailFast(true)
        Runner.Run()
    end if
    
    'initial API call
    APIURL = "http://vstage-api.mini-me.co/collections?product=https%3A%2F%2Fapi.vhx.tv%2Fproducts%2F37342&type=series"
    oneRow = GetContinueWatchingArray()
    twoRow = GetApiArray(APIURL)
    size = 0
    for each item in oneRow
        size = size + 1
    end for
    print size
    list = []
    'API call failed, go to error screen
    if twoRow = invalid
        screen = CreateObject("roSGScreen")
        scene = screen.CreateScene("ErrorScene")
        port = CreateObject("roMessagePort")
        screen.SetMessagePort(port)
        screen.Show()
        while true
            msg = Wait(0, port)
            msgType = type(msg)
            ? "------------------"
            ? "msg = "

        end while
    else
        screen = CreateObject("roSGScreen")
        scene = screen.CreateScene("HomeScene")
        port = CreateObject("roMessagePort")
        screen.SetMessagePort(port)
        screen.Show()
        scene.backExitsScene = false
        scene.observeField("exitApp", port)
        scene.setFocus(true)
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
            msgType = type(msg)
            ? "------------------"
            ? "msg = ";
            if msgType = "roSGNodeEvent" then
                field = msg.getField()
                print field
                if field = "exitApp" then
                    return
                end if
            end if
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
        row = CreateObject("RoSGNode", "ContentNode")
        row.Title = rowAA.Title
        for each itemAA in rowAA.ContentList
            item = CreateObject("RoSGNode", "ContentNode")
            for each key in itemAA
                item[key] = itemAA[key]
            end for
            row.appendChild(item)
        end for
        RowItems.appendChild(row)
    end for
    return RowItems
end function

'generate api call and retrieve JSON file
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
        item.Title = show.name
        item.seasonUrl = show._links.seasons.href
        item.seasonNumber = show.seasons_count.ToStr()
        result.push(item)
    end for
    return result
end function

'check registry and fill up theh continue watching array
function GetContinueWatchingArray()
    result = []
    sec = createObject("roRegistrySection", "MySection")
    list = sec.GetKeyList()
    for each item in list
        jsonString = sec.Read(item)
        jsonObject = parseJson(jsonString)
        tempItem = {}
        tempItem.streamFormat = jsonObject.streamFormat
        tempItem.url = jsonObject.url
        tempItem.id = item
        tempItem.HDPosterUrl = jsonObject.thumbnail
        tempItem.description = jsonObject.description
        tempItem.Title = jsonObject.name
        result.push(tempItem)
    end for
    
    return result
  
end function