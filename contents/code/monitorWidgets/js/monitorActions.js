function modelAddData(model,index,value) {
    if (model.count <= index) {
        model.append(value)
    }
    else {
        model.set(index,value)
    }
}

function removeQuotes(value) {
    return String(value).replace(/["']/g,'')
}

function parseOsRelease(text){
    var arrayResult = []
    var textLineSplit =text.split('\n')
    for (i in textLineSplit)
    {
        switch (textLineSplit[i].split('=')[0]) {
        case "NAME" :
            arrayResult["name"]=removeQuotes(textLineSplit[i].split('=')[1])
            break
        case "ID" :
            arrayResult["id"]=removeQuotes(textLineSplit[i].split('=')[1])
            break
        case "VERSION" :
            arrayResult["version"]=removeQuotes(textLineSplit[i].split('=')[1])
            break
        }
    }

    for (i in arrayResult)
        console.log(arrayResult[i])
    return arrayResult
}

function parseKernelRelease(text){
    var arrayResult = []
    var textLineSplit =text.split(' ')
    arrayResult["name"]=textLineSplit[0]
    if (textLineSplit[2].indexOf('-')>=0)
        textLineSplit[2]=textLineSplit[2].split('-')[0]
    arrayResult["version"]=textLineSplit[2]
    return arrayResult
}

function formatNumberLength(num, length) {
    var r = "" + num;
    while (r.length < length) {
        r = "0" + r;
    }
    return r;
}

function getLogoInfo() {
    var distrosLogoNames = ["logoTux", "logoTuz",
                            "logoSlackware", "logoUbuntu",
                            "logoKubuntu"]
    for (i in distrosLogoNames) {
        if (plasmoid.readConfig(distrosLogoNames[i]) == true) {
            return distrosLogoNames[i].replace("logo","").toLowerCase()
        }
    }
}

function configListener() {
    if (plasmoid.readConfig("standard") == true)
        plasmoid.setBackgroundHints(StandardBackground)
    else if (plasmoid.readConfig("crystal") == true)
        plasmoid.setBackgroundHints(NoBackground)
    else if (plasmoid.readConfig("translucent") == true)
        plasmoid.setBackgroundHints(TranslucentBackground)
    distroLogo.source = "monitorWidgets/images/distro-"+getLogoInfo()+".png"
    swapArea.visible=plasmoid.readConfig("showSwap")
    uptimePicker.visible=plasmoid.readConfig("showUptime")
    coreTempList.highTemp =plasmoid.readConfig("cpuHighTemp")
    coreTempList.criticalTemp =plasmoid.readConfig("cpuCritTemp")
    coreTempList.tempUnit = plasmoid.readConfig("fahrenheit")
}
