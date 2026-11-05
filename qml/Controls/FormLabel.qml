import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 长文字不撑宽表单；被省略时可悬停查看完整内容。
Label {
    id: root
    Layout.fillWidth: true
    Layout.minimumWidth: 0
    elide: Text.ElideRight

    HoverHandler { id: hover }
    ToolTip {
        delay: 400
        timeout: -1
        visible: hover.hovered && root.truncated
        text: root.text
    }
}
