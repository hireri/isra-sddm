pragma Singleton
import QtQuick

QtObject {
    id: root

    property var sddm: null
    property string defaultUser: ""
    property string chosenUser: ""
    property var userNames: []
    readonly property string user: chosenUser || defaultUser
    property int sessionIndex: 0
    property bool capsLock: false
    property real clockHeight: 0

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: showFailure = false
    onUserChanged: currentText = ""

    readonly property real blurAmount: Config.blurEffects ? Math.max(0, Math.min(1, Config.lockscreen.blurAmount ?? 1)) : 0
    readonly property int decodeDivisor: blurAmount < 0.2 ? 1 : (blurAmount < 0.6 ? 2 : 4)

    function tryUnlock(): void {
        if (currentText === "" || unlockInProgress || !sddm)
            return;
        unlockInProgress = true;
        sddm.login(user, currentText, sessionIndex);
    }

    function loginFailed(): void {
        currentText = "";
        showFailure = true;
        unlockInProgress = false;
    }
}
