pragma Singleton
import QtQuick
import "Generated.js" as G

QtObject {
    function t(key) {
        return G.strings[key] ?? key;
    }
}
