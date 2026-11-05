// CollectionTab —— 合集栏上的一个标签：状态点 + 主名称 + 副名称，可选中。
//
// 选中显示底色、细边与粗体；设备完成事件触发回读，任务仍订阅自己的运行通知。
// 官邸提供连接、占用和持有者信息；名称拼接及设备、任务的显示文案归本组件。
import QtQuick
import QtQuick.Controls

Rectangle {
    id: tab

    required property string name
    required property string subtitle
    required property string kind // device | task
    required property var statusSource // QML 官邸；绑定原业务状态，不保存另一份状态
    readonly property var deviceState: kind === "device" ? statusSource.deviceState : null
    property bool current: false

    signal clicked

    // 自然宽度最多 160；工作台等宽分配，窄窗口可继续压缩。
    // 名称按选中时的粗体计宽，切页不改变整排尺寸。
    implicitWidth: Math.min(160, Math.max(nameMetrics.advanceWidth, subText.implicitWidth) + 28)
    implicitHeight: nameText.implicitHeight + subText.implicitHeight + 14
    radius: 6
    color: tab.current ? palette.base : hover.hovered ? palette.midlight : "transparent"
    border.color: tab.current ? palette.mid : "transparent"
    border.width: 1

    TextMetrics {
        id: nameMetrics
        text: tab.name
        font.family: nameText.font.family
        font.pointSize: nameText.font.pointSize
        font.bold: true
    }

    Row {
        id: content
        x: 8
        width: Math.max(0, tab.width - 16)
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        // 状态点：任务运行中任务色；设备被占用青、已连接绿、未连接灰（占用者名字在悬停提示里）。三个色取 Theme 单例。
        Rectangle {
            id: statusDot
            objectName: "resourceStatusDot"
            width: 6
            height: 6
            radius: 3
            anchors.verticalCenter: parent.verticalCenter
            color: tab.kind === "task" && tab.statusSource.running ? Theme.task : palette.mid
        }

        Column {
            width: Math.max(0, content.width - statusDot.width - content.spacing)
            spacing: 1

            Text {
                id: nameText
                text: tab.name
                width: parent.width
                elide: Text.ElideRight
                font.bold: tab.current
                color: palette.windowText
            }
            Text {
                id: subText
                text: tab.subtitle
                width: parent.width
                elide: Text.ElideRight
                font.pointSize: 9
                color: palette.placeholderText
            }
        }
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: tab.clicked() }

    // **自家一个 ToolTip 实例，不走附加属性**：附加属性背后那只 ToolTip 是全局共享的，实机上
    // 气泡会赖在屏幕上不走（病根没有查清，见 ChoiceField.qml 那段）；各用各的实例之后正常。
    FormToolTip {
        id: statusTip
        visible: hover.hovered
        text: tab.name + " · " + tab.subtitle + (tab.kind === "task"
            ? " · " + (tab.statusSource.running ? qsTr("运行中") : qsTr("空闲")) : "")
    }
    // 只改显示结果，完成阶段同时回读连接和锁；不把事件参数另存为状态。
    function refreshDeviceStatus(): void {
        if (!deviceState) return
        const holder = deviceState.holder
        const occupied = holder !== undefined && holder !== null
        statusDot.color = occupied ? Theme.locked : deviceState.isOpen ? Theme.open : palette.mid
        statusTip.text = name + " · " + subtitle + " · " + (occupied
            ? qsTr("被「%1」占用").arg(holder) : deviceState.isOpen ? qsTr("空闲") : qsTr("未连接"))
    }
    Component.onCompleted: refreshDeviceStatus()
    Connections {
        target: tab.deviceState ? tab.deviceState : null
        function onConnectionChanged(phase): void {
            if (phase === ResourcePhase.Acquired || phase === ResourcePhase.Released)
                tab.refreshDeviceStatus()
        }
    }
    Connections {
        target: tab.deviceState
        function onLockChanged(phase): void {
            if (phase === ResourcePhase.Acquired || phase === ResourcePhase.Released)
                tab.refreshDeviceStatus()
        }
    }
}
