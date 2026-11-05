import QtQuick
import QtQuick.Layouts

// 并排输入列，上标签、下输入。默认等权重，双输入列可显式选择较大权重。
RowLayout {
    Layout.fillWidth: true
    spacing: FormStyle.columnSpacing

    component Col: ColumnLayout {
        id: column
        property alias label: name.text
        property int weight: 1
        default property alias field: slot.data
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.preferredWidth: FormStyle.fieldColumnWidth * weight
        Layout.horizontalStretchFactor: weight
        Layout.alignment: Qt.AlignTop
        spacing: FormStyle.captionSpacing

        FormLabel { id: name }
        RowLayout { id: slot; Layout.fillWidth: true; spacing: FormStyle.columnSpacing }
    }
}
