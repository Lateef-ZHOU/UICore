import QtQuick.Layouts

// 标题、设备回报、输入/操作三段排列；值、草稿和提交行为均由调用方持有。
ColumnLayout {
    property alias caption: reading.caption
    property alias text: reading.text
    default property alias controls: content.data
    Layout.fillWidth: true
    Layout.minimumWidth: 0
    Layout.preferredWidth: FormStyle.fieldColumnWidth
    Layout.alignment: Qt.AlignTop
    spacing: FormStyle.rowSpacing

    Readout { id: reading }
    ColumnLayout {
        id: content
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        spacing: FormStyle.rowSpacing
    }
}
