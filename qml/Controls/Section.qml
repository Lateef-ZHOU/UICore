// Section —— 右栏的一块可折叠分区：官邸的分区、任务页的分区、落盘、日志都以它为根。
//
// 标题长在 QML 自己身上（QML 官邸和任务业务提供内容）。点标题行收起或展开，
// 收起时标题行留着——看得见"这里有东西"。本件是纯壳：不认识设备——要注入什么由用的那份 QML 自己声明 required。
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property alias title: header.text
    default property alias content: body.data
    property bool expanded: true

    color: palette.base
    border.color: palette.mid
    border.width: 1
    radius: 4
    implicitHeight: column.implicitHeight + 2
    Layout.fillWidth: true

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 1
        spacing: 0

        ItemDelegate {
            id: header
            Layout.fillWidth: true
            font.bold: true
            text: ""
            onClicked: root.expanded = !root.expanded

            // 展开箭头（收起时指右）
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: root.expanded ? "▾" : "▸"
                color: palette.windowText
            }
        }

        ColumnLayout {
            id: body
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.bottomMargin: 8
            Layout.topMargin: 2
            spacing: 6
            visible: root.expanded
        }
    }
}
