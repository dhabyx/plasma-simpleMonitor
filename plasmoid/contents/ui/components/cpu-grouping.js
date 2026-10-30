.pragma library
// Treat cpuinfo as data. Never infer sibling relationships from numbering.
function parseCpuInfo(text) {
    var records = {}, diePackages = {}, incomplete = false
    var blocks = String(text || "").split(/\n\s*\n/)
    for (var i = 0; i < blocks.length; ++i) {
        var fields = {}, lines = blocks[i].split(/\r?\n/)
        for (var j = 0; j < lines.length; ++j) {
            var m = /^\s*(processor|physical id|core id|die id)\s*:\s*(\d+)\s*$/.exec(lines[j])
            if (m) fields[m[1]] = Number(m[2])
        }
        if (fields.processor === undefined) continue
        var id = fields.processor
        if (Object.prototype.hasOwnProperty.call(records, id)) {
            records[id] = { id: id }; incomplete = true; continue
        }
        records[id] = { id:id, physical:fields['physical id'], core:fields['core id'], die:fields['die id'] }
        if (fields['physical id'] !== undefined && fields['die id'] !== undefined) diePackages[fields['physical id']] = true
    }
    var ids = Object.keys(records).map(Number).sort(function(a,b){return a-b})
    for (var k=0; k<ids.length; ++k) {
        var row=records[ids[k]]
        if (row.physical === undefined || row.core === undefined || (diePackages[row.physical] && row.die === undefined)) {
            row.group = 'cpu:' + row.id; incomplete = true
        } else {
            row.group = 'p:' + row.physical + ':d:' + (row.die === undefined ? '-' : row.die) + ':c:' + row.core
        }
    }
    return {records:records, ids:ids, incomplete:incomplete}
}
function sameIds(a, b) {
    var left=(a || []).map(Number).sort(function(x,y){return x-y})
    var right=(b || []).map(Number).sort(function(x,y){return x-y})
    return JSON.stringify(left) === JSON.stringify(right)
}
function representativeIds(topology, usageIds, temperatureIds) {
    var available={}, groups={}, result=[]
    for (var i=0;i<usageIds.length;++i) available[usageIds[i]]=true
    var ids=temperatureIds.slice().sort(function(a,b){return a-b})
    for (var j=0;j<ids.length;++j) {
        var id=ids[j]
        if (!available[id]) continue
        var row=topology.records && topology.records[id]
        var group=row && row.group ? row.group : 'cpu:' + id
        if (!groups[group]) { groups[group]=true; result.push(id) }
    }
    return result
}
