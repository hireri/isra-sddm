import QtQuick

Item {
    id: root

    property var model: null
    property bool open: false
    property var names: []

    visible: names.length > 1
    implicitWidth: 56
    implicitHeight: 56

    Instantiator {
        model: root.model
        delegate: QtObject {
            required property string name
        }
        onObjectAdded: root.names = Array.from({ length: count }, (_, i) => objectAt(i)?.name ?? "")
        onObjectRemoved: root.names = Array.from({ length: count }, (_, i) => objectAt(i)?.name ?? "")
    }

    Timer {
        interval: 6000
        running: root.open
        onTriggered: root.open = false
    }

    LockButton {
        anchors.fill: parent
        size: 56
        restRadius: 20
        icon: "monitor"
        container: Colors.md3.primary_container
        content: Colors.md3.on_primary_container
        onClicked: root.open = !root.open
    }

    LockMenu {
        width: 220
        anchors {
            right: parent.right
            bottom: parent.top
            bottomMargin: 8
        }
        opensUp: true
        open: root.open
        entries: root.names.map((n, i) => ({ label: n, icon: "", checked: i === LockscreenService.sessionIndex }))
        onTriggered: i => {
            LockscreenService.sessionIndex = i;
            root.open = false;
        }
    }
}
