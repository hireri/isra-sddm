import QtQuick
import QtQuick.Window
import "file:///usr/share/sddm/themes/isra"

Window {
    visible: true
    width: 1280
    height: 720

    Greeter {
        anchors.fill: parent
        backend: QtObject {
            property bool canReboot: true
            property bool canPowerOff: true
            property bool canSuspend: true
            property bool canHibernate: true
            signal loginFailed()
            function login(u, p, s) { console.log("login", u, s); Qt.callLater(loginFailed) }
            function reboot() { console.log("reboot") }
            function powerOff() { console.log("powerOff") }
            function suspend() { console.log("suspend") }
            function hibernate() { console.log("hibernate") }
        }
        users: ListModel {
            property string lastUser: "aveline"
            ListElement { name: "aveline" }
            ListElement { name: "guest" }
        }
        sessions: ListModel {
            property int lastIndex: 0
            ListElement { name: "Hyprland" }
            ListElement { name: "Plasma" }
        }
        kbd: QtObject { property bool capsLock: false }
    }
}
