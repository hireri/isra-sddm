pragma Singleton
import QtQuick
import "Generated.js" as G

// Mirror of the shell's Config from ~/.config/israshell/config.json by sync.sh
QtObject {
    readonly property var _c: G.config

    readonly property string user: G.user
    readonly property var lockscreen: _c.lockscreen ?? ({})
    readonly property var clock: _c.clock ?? ({})
    readonly property bool desktopClock: _c.desktopClock ?? true
    readonly property bool screenCorners: _c.screenCorners ?? true
    readonly property bool blurEffects: _c.blurEffects ?? true
    readonly property bool darkMode: _c.darkMode ?? true
    readonly property string fontFamily: _c.fontFamily ?? ""
    readonly property string language: _c.language ?? "en_US"
    readonly property int hourFormat: _c.hourFormat ?? 0
    readonly property int dateOrder: _c.dateOrder ?? 0
    readonly property var dateFormat: _c.dateFormat
}
