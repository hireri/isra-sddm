import QtQuick

Item {
    id: root

    property bool compact: false
    property bool opensUp: false
    property bool open: false
    property int pending: -1

    property var sddm: LockscreenService.sddm

    readonly property var _all: [
        { label: Localization.t("logout.suspend"), icon: "suspend", run: () => root.sddm.suspend(), available: root.sddm?.canSuspend ?? false },
        { label: Localization.t("logout.hibernate"), icon: "hibernate", run: () => root.sddm.hibernate(), available: root.sddm?.canHibernate ?? false },
        { label: Localization.t("lockSurface.restart"), icon: "reboot", run: () => root.sddm.reboot(), available: root.sddm?.canReboot ?? false, basic: true },
        { label: Localization.t("lockSurface.shut_down"), icon: "shutdown", run: () => root.sddm.powerOff(), available: root.sddm?.canPowerOff ?? false, basic: true }
    ]

    readonly property var entries: {
        const ok = _all.filter(e => e.available);
        return ok.length > 0 ? ok : _all.filter(e => e.basic);
    }

    readonly property var menuEntries: pending < 0
        ? entries.map(e => ({ label: e.label, icon: e.icon }))
        : [
            { label: entries[pending].label + "?", header: true },
            { label: Localization.t("lockSurface.confirm"), icon: "check", danger: true },
            { label: Localization.t("lockSurface.cancel"), icon: "close" }
        ]

    visible: entries.length > 0
    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    function close() {
        open = false;
        pending = -1;
    }

    onPendingChanged: autoClose.restart()

    Timer {
        id: autoClose
        interval: 8000
        running: root.open
        onTriggered: root.close()
    }

    LockButton {
        id: button
        size: root.compact ? 44 : 40
        icon: "shutdown"
        label: root.compact ? "" : Localization.t("lockSurface.power")
        trailing: root.compact ? "" : "keyboard-arrow-down"
        trailingFlipped: root.opensUp !== root.open
        container: Colors.md3.surface_container_high
        content: Colors.md3.on_surface
        onClicked: root.open ? root.close() : root.open = true
    }

    LockMenu {
        anchors {
            right: root.right
            bottom: root.opensUp ? root.top : undefined
            top: root.opensUp ? undefined : root.bottom
            bottomMargin: 8
            topMargin: 8
        }
        entries: root.menuEntries
        open: root.open
        opensUp: root.opensUp
        onTriggered: i => {
            if (root.pending < 0) {
                root.pending = i;
            } else if (i === 1) {
                root.entries[root.pending].run();
                root.close();
            } else {
                root.pending = -1;
            }
        }
    }
}
