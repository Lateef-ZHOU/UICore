// 顶层专用的 Section：由页面侧栏创建并接入业务日志源，官邸不依赖本组件。
// 每个设备/任务页各有一份日志：QML 收到消息时计时，仅保留最近 50 条。
// 页面常驻，隐藏仍收报；组件销毁后历史随之释放，不接收创建前的消息。
// 内容由一个只读 TextArea 显示，可跨行选中复制；高度随内容变化，滚动由外层 Rail 负责。
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Section {
    id: root
    required property var logSource
    title: qsTr("日志")
    onLogSourceChanged: history.lines = []

    QtObject {
        id: history
        property list<string> lines: []
    }

    Connections {
        target: root.logSource
        function onLogMessage(message: string) {
            const line = Qt.formatTime(new Date(), "hh:mm:ss") + "  " + message
            history.lines = history.lines.slice(-49).concat([line])
        }
    }

    Rectangle {
        Layout.fillWidth: true
        // 高度 = 正文自然高度 + 上下各 4 的内边距。正文的 implicitHeight 由**宽度**与文字量
        // 算出（宽度来自本 Rectangle 的 fillWidth，先于高度定下），故这里没有回环。
        implicitHeight: body.implicitHeight + 8
        color: palette.base
        border.color: palette.mid
        border.width: 1

        TextArea {
            id: body
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 4 }
            readOnly: true
            selectByMouse: true                  // 可跨行选中，Ctrl+C 直接走
            wrapMode: TextArea.Wrap
            textFormat: TextEdit.PlainText
            verticalAlignment: TextEdit.AlignTop // 写死左上：不赌默认值
            horizontalAlignment: TextEdit.AlignLeft
            // **不指定等宽**：日志正文是中文，Consolas 没有中文字形（见 SliderField.qml 那句）。这里用界面默认字体（见 qtquickcontrols2.conf）。
            font.pointSize: 9
            color: palette.windowText
            background: null // 边框与底色归外面那个 Rectangle，别画两层
            padding: 0
            text: history.lines.join("\n")
        }
    }
}
