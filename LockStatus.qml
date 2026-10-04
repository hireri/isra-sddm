import QtQuick

Row {
    id: root

    spacing: 12

    property bool capsLockOn: LockscreenService.capsLock

    Row {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.capsLockOn
        spacing: 4

        MaterialIcon {
            anchors.verticalCenter: parent.verticalCenter
            name: "shift-lock"
            filled: true
            iconSize: 16
            color: Colors.md3.tertiary
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Localization.t("lockSurface.caps_lock")
            color: Colors.md3.tertiary
            font.pixelSize: 12
            font.weight: Font.Medium
        }
    }
}
