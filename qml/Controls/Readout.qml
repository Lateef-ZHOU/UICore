import QtQuick
import QtQuick.Layouts

// 只显示调用方提供的文字，不保存设备状态或执行数值转换。
ColumnLayout {
    property alias caption: heading.text
    property alias text: result.text
    Layout.fillWidth: true
    Layout.minimumWidth: 0
    Layout.preferredWidth: FormStyle.readoutColumnWidth
    Layout.alignment: Qt.AlignTop
    spacing: FormStyle.captionSpacing

    FormLabel {
        id: heading
        color: palette.placeholderText
    }
    ReadoutValue {
        id: result
    }
}
