import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 只排列选择内容和动作；不持设备、选中值，不执行枚举或连接。
Section {
    id: root
    property alias label: selector.label
    default property alias fields: selector.field
    required property Action firstAction
    required property Action secondAction
    property real actionTopMargin: 0

    content: [
        FieldRow {
            id: selector
        },
        DoubleButtonRow {
            Layout.topMargin: root.actionTopMargin
            firstAction: root.firstAction
            secondAction: root.secondAction
        }
    ]
}
