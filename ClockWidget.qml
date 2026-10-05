import QtQuick
import QtQuick.Effects
import "lockLayout.js" as LockLayout

Item {
    id: root

    property var _currentTime: new Date()

    Timer {
        interval: clockRoot._layoutMode === 3 ? 50 : 500
        running: true
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            const now = new Date();
            if (clockRoot._layoutMode === 1) {
                if (now.getMinutes() !== root._currentTime.getMinutes())
                    root._currentTime = now;
            } else {
                root._currentTime = now;
            }
        }
    }

    Item {
        id: clockRoot

        readonly property var _lockCenter: LockLayout.clockCenter(Config.lockscreen.layout, root.width, root.height, implicitWidth, implicitHeight)

        x: _lockCenter.x - width / 2
        y: _lockCenter.y - height / 2

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: Config.clock.showShadow ?? true
            shadowBlur: ((Config.clock.shadowBlur ?? 16) / 32)
            shadowColor: Qt.alpha("black", Config.clock.shadowOpacity ?? 0.2)
            shadowHorizontalOffset: Config.clock.shadowX ?? 0
            shadowVerticalOffset: Config.clock.shadowY ?? 0
        }

        readonly property string _font: Config.clock.fontFamily !== "" ? Config.clock.fontFamily : Config.fontFamily
        readonly property color _textColor: Colors.md3[Config.clock.colorRole] ?? Colors.md3.on_surface
        readonly property color _subColor: Colors.md3[Config.clock.subColorRole] ?? Colors.md3.on_surface_variant

        readonly property int _autoHalign: {
            const third = root.width / 3;
            if (_lockCenter.x < third) return Text.AlignLeft;
            if (_lockCenter.x > third * 2) return Text.AlignRight;
            return Text.AlignHCenter;
        }
        readonly property int _halign: Config.clock.align === "left" ? Text.AlignLeft
            : Config.clock.align === "right" ? Text.AlignRight
            : Config.clock.align === "auto" ? _autoHalign
            : Text.AlignHCenter
        readonly property int _layoutMode: Config.clock.layout === "horizontal" ? 0 : Config.clock.layout === "vertical" ? 1 : Config.clock.layout === "word" ? 2 : Config.clock.layout === "analog" ? 3 : 0

        implicitWidth: styleLoader.item?.implicitWidth ?? 0
        implicitHeight: styleLoader.item?.implicitHeight ?? 0

        onImplicitHeightChanged: LockscreenService.clockHeight = implicitHeight

        Loader {
            id: styleLoader
            sourceComponent: [horizontalComp, verticalComp, wordComp, analogComp][clockRoot._layoutMode]
        }

        Component {
            id: horizontalComp
            ClockHorizontal { currentTime: root._currentTime; immediateShapes: true; clockFont: clockRoot._font; textColor: clockRoot._textColor; subColor: clockRoot._subColor; halign: clockRoot._halign; showSeconds: Config.clock.showSeconds ?? false; is12h: Config.hourFormat !== 0; analogSize: (Config.clock.size ?? 100) * 2 }
        }
        Component {
            id: verticalComp
            ClockVertical { currentTime: root._currentTime; immediateShapes: true; clockFont: clockRoot._font; textColor: clockRoot._textColor; subColor: clockRoot._subColor; halign: clockRoot._halign; showSeconds: Config.clock.showSeconds ?? false; is12h: Config.hourFormat !== 0; analogSize: (Config.clock.size ?? 100) * 2 }
        }
        Component {
            id: wordComp
            ClockWord { currentTime: root._currentTime; clockFont: clockRoot._font; textColor: clockRoot._textColor; subColor: clockRoot._subColor; halign: clockRoot._halign; showSeconds: Config.clock.showSeconds ?? false; is12h: Config.hourFormat !== 0; analogSize: (Config.clock.size ?? 100) * 2 }
        }
        Component {
            id: analogComp
            ClockAnalog { currentTime: root._currentTime; immediateShapes: true; clockFont: clockRoot._font; textColor: clockRoot._textColor; subColor: clockRoot._subColor; halign: clockRoot._halign; showSeconds: Config.clock.showSeconds ?? false; is12h: Config.hourFormat !== 0; analogSize: (Config.clock.size ?? 100) * 2 }
        }
    }
}
