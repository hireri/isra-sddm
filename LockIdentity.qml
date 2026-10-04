import QtQuick
import QtQuick.Effects

Item {
    id: root

    property real avatarSize: 44
    property real nameSize: 14
    property bool showStatus: true

    property string user: LockscreenService.user

    z: 10

    property bool menuUp: false
    property bool menuAlignLeft: true
    property bool open: false

    readonly property bool switchable: LockscreenService.userNames.length > 1

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 10

        Item {
            width: root.avatarSize
            height: root.avatarSize
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: face
                anchors.fill: parent
                source: root.user === Config.user ? "face.png" : ""
                sourceSize: Qt.size(root.avatarSize * 2, root.avatarSize * 2)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: false
            }

            MaterialShape {
                id: mask
                anchors.fill: parent
                name: "cookie12"
                immediate: true
                shapeSize: root.avatarSize
                color: "white"
                opacity: 0
                layer.enabled: true
                layer.smooth: true
            }

            MultiEffect {
                anchors.fill: parent
                source: face
                opacity: face.status === Image.Ready ? 1 : 0
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
                maskEnabled: true
                maskSource: mask
                maskThresholdMin: 0.5
                maskSpreadAtMin: 0.5
            }

            MaterialShape {
                anchors.fill: parent
                visible: face.status === Image.Error || face.status === Image.Null
                name: "cookie12"
                immediate: true
                shapeSize: root.avatarSize
                color: Colors.md3.primary

                Text {
                    anchors.centerIn: parent
                    text: root.user.charAt(0).toUpperCase()
                    color: Colors.md3.on_primary
                    font.pixelSize: root.avatarSize * 0.4
                    font.weight: Font.Medium
                }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                text: root.user
                color: Colors.md3.on_surface
                font.pixelSize: root.nameSize
                font.weight: Font.Medium
            }
            Text {
                visible: root.showStatus
                text: Localization.t("lockSurface.locked")
                color: Colors.md3.on_surface_variant
                font.pixelSize: 11
            }
        }
    }

    TapHandler {
        enabled: root.switchable
        onTapped: root.open = !root.open
    }

    HoverHandler {
        enabled: root.switchable
        cursorShape: Qt.PointingHandCursor
    }

    Timer {
        interval: 6000
        running: root.open
        onTriggered: root.open = false
    }

    LockMenu {
        z: 10
        anchors {
            left: root.menuAlignLeft ? parent.left : undefined
            right: root.menuAlignLeft ? undefined : parent.right
            top: root.menuUp ? undefined : parent.bottom
            bottom: root.menuUp ? parent.top : undefined
            topMargin: 8
            bottomMargin: 8
        }
        alignLeft: root.menuAlignLeft
        opensUp: root.menuUp
        open: root.open
        entries: LockscreenService.userNames.map(n => ({ label: n, icon: "", checked: n === LockscreenService.user }))
        onTriggered: i => {
            LockscreenService.chosenUser = LockscreenService.userNames[i];
            root.open = false;
        }
    }
}
