import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 段落说明统一换行，不用整段的自然宽度撑开侧栏。
Label {
    Layout.fillWidth: true
    Layout.minimumWidth: 0
    Layout.preferredWidth: 1
    color: palette.placeholderText
    font.pointSize: 9
    wrapMode: Text.Wrap
}
