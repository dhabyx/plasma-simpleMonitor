.pragma library

function columnCount(count, requested, screenWidth) {
    if (requested > 0)
        return Math.max(1, Math.min(8, Math.floor(requested)))
    var needed = Math.max(1, Math.ceil(count / 16))
    var fits = Math.max(1, Math.floor(Math.max(1, screenWidth) * 0.8 / 100))
    return Math.min(8, needed, fits)
}
function rowCount(count, columns) {
    return Math.ceil(Math.max(0, count) / Math.max(1, columns))
}
function rowFor(index, rows) { return index % Math.max(1, rows) }
function columnFor(index, rows) { return Math.floor(index / Math.max(1, rows)) }
