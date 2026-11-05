import QtQuick.Controls
import QtQuick.Layouts

// 成对操作共用布局；动作及其可用条件由业务页面提供。
RowLayout {
    id: root
    required property Action firstAction
    required property Action secondAction
    property string firstToolTip: ""
    property string secondToolTip: ""

    Layout.fillWidth: true
    uniformCellSizes: true
    spacing: FormStyle.columnSpacing

    Button {
        Layout.fillWidth: true
        action: root.firstAction
        objectName: action.objectName
        ToolTip.text: root.firstToolTip
        ToolTip.visible: hovered && root.firstToolTip !== ""
    }
    Button {
        Layout.fillWidth: true
        action: root.secondAction
        objectName: action.objectName
        ToolTip.text: root.secondToolTip
        ToolTip.visible: hovered && root.secondToolTip !== ""
    }
}
