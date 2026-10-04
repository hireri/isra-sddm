import QtQuick
import QtQuick.Shapes
import "Icons.js" as Icons

Item {
    id: root

    property string name: ""
    property bool filled: false
    property color color: "white"
    property real iconSize: 24

    width: iconSize
    height: iconSize

    readonly property var paths: (filled && Icons.filled[name]) || Icons.outline[name] || []

    Shape {
        id: shape
        width: root.width
        height: root.height
        y: root.height
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer

        Instantiator {
            model: root.paths
            onObjectAdded: (index, object) => shape.data.push(object)
            onObjectRemoved: (index, object) => shape.data.splice(shape.data.indexOf(object), 1)
            ShapePath {
                strokeWidth: 0
                fillColor: root.color
                scale: Qt.size(root.width / 960, root.height / 960)
                PathSvg { path: modelData }
            }
        }
    }
}
