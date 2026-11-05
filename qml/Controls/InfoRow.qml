import QtQuick
import QtQuick.Layouts

// 单行名称和值；长值省略并悬停显示全文，格式化由调用方负责。
RowLayout {
    id: root
    property alias caption: heading.text
    property alias text: value.text
    property bool compact: false
    Layout.fillWidth: true
    Layout.minimumWidth: 0
    spacing: FormStyle.columnSpacing

    FormLabel {
        id: heading
        Layout.fillWidth: false
        Layout.minimumWidth: root.compact ? FormStyle.compactInfoLabelWidth : FormStyle.labelWidth
        Layout.preferredWidth: Layout.minimumWidth
        Layout.maximumWidth: Layout.minimumWidth
        Binding on font.pixelSize {
            when: root.compact
            value: 12
        }
        color: palette.placeholderText
    }
    FormLabel {
        id: value
        Binding on font.pixelSize {
            when: root.compact
            value: 12
        }
    }
}
