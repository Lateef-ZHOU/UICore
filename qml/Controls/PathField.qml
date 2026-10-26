// PathField —— 本机路径：一行只读显示 + 「浏览…」弹系统对话框。选文件夹还是选文件由 `folder` 定。
//
// 形制与 ValueField 族同构，读法也一样，只有 `text` 例外（它不是输入框自己的 text，见第二条）：
//   · `value`     = 已认可的路径（**url**），持值方说了算；
//   · `text`      = 持值方提供的显示文字（本机路径或完整文件 URL）——纯显示量，可以绑；
//   · `committed` = "用户在对话框里选了这个"这条通知，**它不替人改 value**。
//
// **路径不能手敲**（用户定）：手敲或粘贴进来的串没法判断是不是一个合法路径——要判就得上正则，还判不全；
// 而对话框里选出来的一定是。故这里只显示，改路径只有「浏览…」这一条路。
//
// **跨界面的类型是 url，不是字符串**（用户定：字符串只保证自己是字符串，不保证是路径）。对话框交出来的
// 本来就是 url（selectedFolder / selectedFile），原样递给持值方，由 C++ 那头 `QUrl::toLocalFile()` 变成
// QDir / QFileInfo。**界面这边不对路径做任何字符串加工**。
// ⚠ 别再写「从 "file:///…" 里把路径抠出来」那种正则：空格与非 ASCII 字符在 url 的字符串形式里是
// 百分号编码，抠出来的不是路径。
//
// 没有行标签（让出宽度给路径）。路径比栏宽长时从中间省略（盘符与末级都留着），鼠标停上去看全文。
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

RowLayout {
    id: root
    property url value            // 已认可的路径；打开对话框时拿它当起点
    property string text          // 显示文字：本机写法的路径，空 = 还没选过
    property string placeholder   // 还没选过时显示什么
    property bool folder: true    // true = 选文件夹；false = 选文件
    property string title         // 对话框标题
    property var nameFilters: []  // 文件类型过滤（只在选文件时用）
    signal committed(url newValue)
    readonly property bool chosen: root.text !== "" // 选过了（text 空 = 还没选过）

    spacing: 6
    Layout.fillWidth: true

    Label {
        id: path
        Layout.fillWidth: true
        // **钉 preferredWidth**：不钉的话它的 implicitWidth 就是整条路径的文字宽，一条长路径能把所在的
        // 容器撑宽。钉住之后宽度全由宿主分配，超出的省略，不依赖页面采用哪种布局。
        Layout.preferredWidth: 1
        // 纯显示量：界面这头没有人会写它，声明式绑定正合适（与输入框的 text 不是一回事）。
        text: root.chosen ? root.text : root.placeholder
        color: root.chosen ? palette.windowText : palette.placeholderText
        elide: Text.ElideMiddle

        HoverHandler { id: hover }
        // 自家一个 ToolTip 实例，不走附加属性（为什么见 ChoiceField.qml 那段）。只在真被省略时才出。
        ToolTip {
            delay: 400
            timeout: -1
            visible: hover.hovered && path.truncated
            text: path.text
        }
    }
    Button {
        text: qsTr("浏览…")
        // 打开之前把当前值交给对话框当起点。**命令式地写这一次，不绑定**：对话框的「当前位置」是它自己
        // 也会写的量（用户一路点进去就在写）。
        onClicked: {
            const known = root.value.toString() !== ""
            if (root.folder) {
                if (known)
                    dirDialog.currentFolder = root.value
                dirDialog.open()
            } else {
                if (known)
                    fileDialog.selectedFile = root.value
                fileDialog.open()
            }
        }
    }

    // 两个对话框都摆着，一个实例只会用到其中一个（系统对话框到 open() 才真正创建）。
    FolderDialog {
        id: dirDialog
        title: root.title
        onAccepted: root.committed(selectedFolder)
    }
    FileDialog {
        id: fileDialog
        title: root.title
        nameFilters: root.nameFilters
        onAccepted: root.committed(selectedFile)
    }
}
