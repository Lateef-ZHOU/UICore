// FieldStrip —— 几个输入框并排一行，每个一列「上提示词 + 下框」，等宽平分。
// 与 FieldRow 的区别只是提示词在上而不在左。
//
// **什么时候用它**：右栏挺宽，而一个角度框只要放得下 "0.00" —— 一参一行太浪费。
// 成组的量（标定三个角、目标位形两根轴、目标朝向的方位与高度）摆一行更省地方、也更像一组。
// 提示词改摆上方是因为它们通常比框里的数字长（「零位方位角（°）」），左栏塞不下。
//
// 各列**等宽平分**：列自己带 Layout.fillWidth + 相同的 preferredWidth。
// **别把 preferredWidth 报成 1 那种数**：等宽只要求各列彼此相等，不要求它们谎称只要一像素
// ——虚报会让上层算出的最小宽度偏小。
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// **不设 default property**：本件的根就是 RowLayout，子项本来就直接落进它，
// 再套一层 holder 只是白白多一级布局。
RowLayout {
    id: root
    spacing: 12
    Layout.fillWidth: true

    // 一列：上提示词 + 下框。用法：`FieldStrip { FieldStrip.Col { label: "…"; RealField {…} } }`
    component Col: ColumnLayout {
        property alias label: name.text
        default property alias field: slot.data
        Layout.fillWidth: true
        Layout.preferredWidth: 110
        Layout.alignment: Qt.AlignTop
        spacing: 2
        Label { id: name; Layout.fillWidth: true; elide: Text.ElideRight }
        RowLayout { id: slot; Layout.fillWidth: true; spacing: 6 }
    }
}
