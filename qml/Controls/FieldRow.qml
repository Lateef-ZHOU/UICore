// FieldRow —— 一行：左提示词 + 右一个输入框。
//
// **它只是个摆放壳**：画什么由调用方自己写在里头，C++ 那侧只提供值与边界——C++ 不认识控件，
// 也不决定这一行画成什么（这条分工写在 PcapCard.qml 头注）。
//
// 提示词宽度在这里定一次。
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property alias label: name.text
    property int labelWidth: 120
    // 默认属性：`FieldRow { label: "…"; IntField { … } }` 里那个框直接落进右半边。
    default property alias field: holder.data

    Layout.fillWidth: true
    spacing: 8

    Label {
        id: name
        Layout.preferredWidth: root.labelWidth
        Layout.alignment: Qt.AlignVCenter
        elide: Text.ElideRight
    }
    RowLayout { id: holder; Layout.fillWidth: true; spacing: 6 }
}
