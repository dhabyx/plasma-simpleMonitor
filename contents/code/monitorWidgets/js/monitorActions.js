function modelAddData(model,index,value) {
    if (model.count <= index) {
        model.append(value)
    }
    else {
        model.set(index,value)
    }
}

function parseOsRelease(text){
    var arrayResult = []
    var textLineSplit =text.split('\n')
    arrayResult["name"]=textLineSplit[0].split('=')[1]
    arrayResult["id"]=textLineSplit[2].split('=')[1]
    arrayResult["version"]=textLineSplit[3].split('=')[1]
    /*
    for (i in arrayResult)
        console.log(arrayResult[i])
        */
    return arrayResult
}

function parseKernelRelease(text){
    var arrayResult = []
    var textLineSplit =text.split(' ')
    arrayResult["name"]=textLineSplit[0]
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
