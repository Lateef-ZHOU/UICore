import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 单行省略并悬停全文；多行按可用宽度换行，不以整段自然宽度撑开表单。
Label {
    id: root
    property bool multiline: false
    Layout.fillWidth: true
    Layout.minimumWidth: 0
    Layout.preferredWidth: multiline ? 1 : -1
    wrapMode: multiline ? Text.Wrap : Text.NoWrap
    elide: multiline ? Text.ElideNone : Text.ElideRight

    HoverHandler { id: hover }
    ToolTip {
        delay: 400
        timeout: -1
        visible: hover.hovered && root.truncated
        text: root.text
    }
}
