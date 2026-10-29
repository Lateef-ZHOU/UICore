// 只持 Qt 原生选择状态；需由持值方确认的输入使用 ChoiceField。
import QtQuick
import QtQuick as Quick
import QtQuick.Controls

ComboBox {
    id: root

    // 空表不提供弹出对象，不改变控件 enabled 或业务层的发令条件。
    popup: count > 0 ? menu : null
    down: count > 0 && (pressed || menu.opened)
    // Qt 在移除 popup 时解除可视父项；列表恢复后重新挂接同一个面板。
    onPopupChanged: if (popup) popup.parent = root
    // 提前完成 Qt 的延迟创建，避免首次按下时与主题的开合样式计算互相触发。
    Component.onCompleted: if (popup) popup.parent = root

    Popup {
        id: menu
        parent: root
        popupType: Popup.Item
        width: root.width
        padding: 4
        margins: 8
        topInset: 0
        bottomInset: 0
        leftInset: 0
        rightInset: 0
        enter: null
        exit: null
        font: root.font
        palette: root.palette

        // 每次展开读取当前位置，包含侧栏滚动后的位移。
        property point controlPosition: Qt.point(0, 0)
        readonly property real roomAbove: Math.max(0, controlPosition.y - margins - 2)
        readonly property real roomBelow: Math.max(0, root.Quick.Window.height - controlPosition.y - root.height - margins - 2)
        readonly property bool below: implicitHeight <= roomBelow || roomBelow >= roomAbove
        implicitHeight: choices.contentHeight + topPadding + bottomPadding
        height: Math.min(implicitHeight, below ? roomBelow : roomAbove)
        y: below ? root.height + 2 : -height - 2
        onAboutToShow: controlPosition = root.mapToItem(root.Quick.Window.contentItem, 0, 0)

        contentItem: ListView {
            id: choices
            clip: true
            model: root.delegateModel
            currentIndex: root.highlightedIndex
            highlightMoveDuration: 0
            ScrollIndicator.vertical: ScrollIndicator { }
        }
        background: Rectangle {
            color: root.palette.window
            border.color: root.palette.mid
            radius: 4
        }
    }
}
