// CollectionTab —— 合集栏上的一个标签：状态点 + 主名称 + 副名称，可选中。
//
// 选中显示底色、细边与粗体；状态点和提示直接绑定各自的设备或任务。
// 官邸提供连接、占用和持有者信息；名称拼接及设备、任务的显示文案归本组件。
import QtQuick
import QtQuick.Controls

Rectangle {
    id: tab

    required property string name
    required property string subtitle
    required property string kind // device | task
    required property var statusSource // QML 官邸；绑定原业务状态，不保存另一份状态
    property bool current: false

    signal clicked

    // 报告内容需要的自然宽度；工作台取所有标签的最大值统一分配。
    // 名称按选中时的粗体计宽，切页不改变整排尺寸。
    implicitWidth: content.implicitWidth + 16
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
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        // 状态点：任务运行中任务色；设备被占用青、已连接绿、未连接灰（占用者名字在悬停提示里）。三个色取 Theme 单例。
        Rectangle {
            width: 6
            height: 6
            radius: 3
            anchors.verticalCenter: parent.verticalCenter
            color: tab.kind === "task" ? (tab.statusSource.running ? Theme.task : palette.mid)
                 : tab.statusSource.isLocked ? Theme.locked
                 : tab.statusSource.isOpen ? Theme.open : palette.mid
        }

        Column {
            width: Math.max(nameMetrics.advanceWidth, subText.implicitWidth)
            spacing: 1

            Text {
                id: nameText
                text: tab.name
                font.bold: tab.current
                color: palette.windowText
            }
            Text {
                id: subText
                text: tab.subtitle
                font.pointSize: 9
                color: palette.placeholderText
            }
        }
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: tab.clicked() }

    // **自家一个 ToolTip 实例，不走附加属性**：附加属性背后那只 ToolTip 是全局共享的，实机上
    // 气泡会赖在屏幕上不走（病根没有查清，见 ChoiceField.qml 那段）；各用各的实例之后正常。
    ToolTip {
        delay: 400
        timeout: -1
        visible: hover.hovered
        text: tab.name + " · " + (tab.kind === "task"
            ? (tab.statusSource.running ? qsTr("运行中") : qsTr("空闲"))
            : tab.subtitle + " · " + (tab.statusSource.isLocked
                ? qsTr("被「%1」占用").arg(tab.statusSource.holder)
                : tab.statusSource.isOpen ? qsTr("空闲") : qsTr("未连接")))
    }
}
