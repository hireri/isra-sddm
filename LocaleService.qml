pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property var _qtLocale: Qt.locale(Config.language.split("_").slice(0, 2).join("_"))

    property string liveTime: "00:00"
    property string liveSecs: ""
    property string liveAmPm: ""
    property string shortDateText: ""

    function _update() {
        const now = new Date();
        const fmt12 = Config.hourFormat !== 0;
        const h = now.getHours();
        const hDisp = fmt12 ? (h % 12 || 12) : h;

        liveTime = String(hDisp).padStart(2, '0') + ":" + String(now.getMinutes()).padStart(2, '0');
        liveSecs = String(now.getSeconds()).padStart(2, '0');
        const amPmWord = h >= 12 ? Localization.t("clock.pm") : Localization.t("clock.am");
        liveAmPm = Config.hourFormat === 0 ? "" : (" " + (Config.hourFormat === 2 ? amPmWord : amPmWord.toLowerCase()));
        shortDateText = now.toLocaleString(root._qtLocale, Config.dateOrder === 1 ? "ddd, MMM dd" : "ddd, dd MMM");
    }

    property Timer _tick: Timer {
        interval: 250
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._update()
    }
}
