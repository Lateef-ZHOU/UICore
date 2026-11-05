import QtQuick.Controls
import QtQuick.Layouts

// 成对操作共用布局；动作及其可用条件由业务页面提供。
RowLayout {
    id: root
    required property Action firstAction
    required property Action secondAction

    Layout.fillWidth: true
    uniformCellSizes: true
    spacing: 8

    Button {
        Layout.fillWidth: true
        action: root.firstAction
        objectName: action.objectName
    }
    Button {
        Layout.fillWidth: true
        action: root.secondAction
        objectName: action.objectName
    }
}
