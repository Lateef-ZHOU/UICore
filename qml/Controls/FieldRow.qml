import QtQuick
import QtQuick.Layouts

// 左标签、右输入区；普通和长标签两档共用同一列宽规则。
RowLayout {
    id: root
    property alias label: name.text
    property bool wideLabel: false
    readonly property int labelWidth: wideLabel ? FormStyle.wideLabelWidth : FormStyle.labelWidth
    default property alias field: holder.data
    Layout.fillWidth: true
    spacing: FormStyle.columnSpacing

    FormLabel {
        id: name
        Layout.fillWidth: false
        Layout.minimumWidth: root.labelWidth
        Layout.preferredWidth: root.labelWidth
        Layout.maximumWidth: root.labelWidth
        Layout.alignment: Qt.AlignVCenter
    }
    RowLayout { id: holder; Layout.fillWidth: true; spacing: FormStyle.columnSpacing }
}
