import QtQuick
import QtQuick.Effects
import "Generated.js" as G

Item {
    id: root

    property var backend: null
    property var users: null
    property var sessions: null
    property var kbd: null

    readonly property string user: users?.lastUser || (userList.count > 0 ? userList.objectAt(0).name : "")

    Instantiator {
        id: userList
        model: root.users
        delegate: QtObject {
            required property string name
        }
        onObjectAdded: LockscreenService.userNames = Array.from({ length: count }, (_, i) => objectAt(i)?.name ?? "")
        onObjectRemoved: LockscreenService.userNames = Array.from({ length: count }, (_, i) => objectAt(i)?.name ?? "")
    }

    Binding { target: LockscreenService; property: "sddm"; value: root.backend }
    Binding { target: LockscreenService; property: "defaultUser"; value: root.user }
    Binding { target: LockscreenService; property: "capsLock"; value: root.kbd?.capsLock ?? false }

    Connections {
        target: root.backend
        function onLoginFailed() { LockscreenService.loginFailed() }
    }

    Component.onCompleted: LockscreenService.sessionIndex = root.sessions?.lastIndex ?? 0

    Repeater {
        model: G.fonts
        delegate: Item {
            id: font
            required property string modelData
            FontLoader { source: font.modelData }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Image {
        id: wall
        anchors.fill: parent
        source: "wall.jpg"
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        visible: false
        sourceSize.width: Math.max(1, Math.round(root.width * Screen.devicePixelRatio / LockscreenService.decodeDivisor))
        smooth: false

        readonly property bool settled: status === Image.Ready || status === Image.Error
    }

    MultiEffect {
        anchors.fill: wall
        source: wall
        blurEnabled: true
        autoPaddingEnabled: false
        blurMax: 64
        blur: LockscreenService.blurAmount
        opacity: wall.settled ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Colors.md3.surface_container, 0.65)
    }

    ClockWidget {
        anchors.fill: parent
    }

    LockLayout {
        anchors.fill: parent
    }

    LockSession {
        z: 20
        model: root.sessions
        anchors {
            right: parent.right
            rightMargin: 20
            bottom: parent.bottom
            bottomMargin: 20
        }
    }

    component LockCornerBlock: Item {
        id: block
        readonly property int cr: 26
        property int type: 0
        width: cr
        height: cr
        clip: true
        visible: Config.screenCorners
        Rectangle {
            width: block.cr * 4
            height: block.cr * 4
            radius: block.cr * 2
            color: "transparent"
            border.width: block.cr
            border.color: "black"
            x: (block.type === 1 || block.type === 3) ? -block.cr * 2 : -block.cr
            y: (block.type === 2 || block.type === 3) ? -block.cr * 2 : -block.cr
        }
    }

    LockCornerBlock { type: 0; anchors.top: parent.top; anchors.left: parent.left }
    LockCornerBlock { type: 1; anchors.top: parent.top; anchors.right: parent.right }
    LockCornerBlock { type: 2; anchors.bottom: parent.bottom; anchors.left: parent.left }
    LockCornerBlock { type: 3; anchors.bottom: parent.bottom; anchors.right: parent.right }
}
