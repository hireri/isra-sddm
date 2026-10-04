import QtQuick

Greeter {
    backend: sddm
    users: userModel
    sessions: sessionModel
    kbd: keyboard
}
