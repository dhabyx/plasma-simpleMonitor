.pragma library
// The C++ type string is a deliberately conservative guard: unsupported or
// renamed hosts are left untouched, including plasmashell and popup windows.
function isWindowed(app, windowDescription, isOwnerWindow) {
    return isOwnerWindow && app === 'plasmawindowed' && /^PlasmaWindowedView\(0x[0-9a-f]+\)$/i.test(windowDescription);
}
// Avoid resizing back and forth when a live value changes a few glyphs.
function shouldAdjustWidth(current, desired) {
    return desired > current || current - desired > 12;
}
