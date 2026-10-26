// 通用工作台只排列传入的两组页面，不创建设备或任务。
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: win

    required property list<ModulePage> devicePages
    required property list<ModulePage> taskPages
    readonly property list<ModulePage> pages: [...devicePages, ...taskPages]
    property int currentPage: 0

    visible: true

    // 默认大小：高度按**可用桌面区**夹一下（减掉任务栏），写死 900 会让窗口有一截压在任务栏
    // 底下。留 60 的余量，居中后上下各空 30。
    //
    // **`desktopAvailableWidth` 与 `desktopAvailableHeight` 不是一个尺度的东西**（本机实测：
    // 单屏 1707×960，avail 报 4267×912）：`desktopAvailable*` 是**整个虚拟桌面**可用区的并集
    // ——两块屏并排，宽跨了两块，高却因为等高而恰好等于单屏。所以**横向要用 `Screen.width`**，
    // 拿 avail 的宽去算居中会把窗口推到第二块屏上。
    width: Math.min(1440, Screen.width - 60)
    height: Math.min(900, Screen.desktopAvailableHeight - 60)

    // ── 窗口最小宽度：**必须自己写** ────────────
    // **Qt Quick 的 layout 不碰 Window 的最小尺寸**（那是 QWidget 那套 QLayout 的行为，QML 这边只在
    // Layout 与 Layout 之间传尺寸提示，传到窗口就断了）。实测：不写这一笔，窗口能一路压到 186 px。
    //
    // 两个来源取大：
    //   · 标签栏排满要多宽（bar.implicitWidth —— RowLayout 的 implicit 是各标签之和）；
    //   · 当前所有页面里要求最高的那个（各页自报 minimumPageWidth）。
    // 再加上 ColumnLayout 四周那圈留白。**单调取 max**：页面全部常驻、从不卸载。
    property real pageMinWidth: 0
    minimumWidth: 2 * col.anchors.margins + Math.max(bar.implicitWidth, pageMinWidth)
    // 不设 minimumHeight：右栏自己会滚，纵向压不出"吞控件"那种事。

    // **摆位只做一次，不能写成绑定**：x / y 若绑在 width / height 上，用户一最大化，
    // height 变了就把 y 重算一遍 —— 于是最大化之后顶上空出一条。看着像布局 bug，
    // 其实是那条绑定还活着，在跟窗口管理器抢位置。
    Component.onCompleted: {
        x = Screen.virtualX + (Screen.width - width) / 2
        y = Screen.virtualY + (Screen.desktopAvailableHeight - height) / 2
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        // **四周留白**（用户定）：控件不许贴着窗口边，上下左右各留一圈。
        // **只在这一处给**：页面那头（设备页 / 任务页）因此不必各自重复，将来新加的页也自动有；
        // 分隔线跟着一起缩进，看着才像是有意为之，而不是没画到头。
        anchors.margins: 10
        spacing: 6

        // ══ 合集栏：两组（设备 / 任务），点哪个切到哪一页 ═══════════════════════
        // 新增设备 / 任务的入口还没有——不留点了没反应的按钮。
        // **`Layout.fillHeight: false` 非写不可**：QQuickLayouts 里「Layout 套 Layout」时，
        // 内层那个的 fillWidth / fillHeight **默认就是 true**（普通 Item 默认才是 false）。
        // 不写这一行，合集栏会和下面的页面栈平分整扇窗的高度——实测它吃掉 873 px、页面栈只剩 14 px，
        // 表现是"合集栏浮在窗口正中、页面区一片空白"，**不报错、不警告**。
        RowLayout {
            id: bar
            Layout.fillWidth: true
            Layout.fillHeight: false
            spacing: 4

            // children 随委托创建更新；自然宽度不依赖分配宽度，避免尺寸反馈。
            readonly property real tabWidth: {
                let widest = 0
                for (const child of bar.children) {
                    if (child instanceof CollectionTab)
                        widest = Math.max(widest, child.implicitWidth)
                }
                return Math.ceil(widest)
            }

            // 两组标签分别使用传入名单；页面栈仍按设备、任务的顺序排列。
            component Group: Repeater {
                id: group
                required property string kind
                model: group.kind === "device" ? win.devicePages : win.taskPages
                delegate: CollectionTab {
                    required property int index
                    required property var modelData
                    Layout.minimumWidth: bar.tabWidth
                    Layout.preferredWidth: bar.tabWidth
                    Layout.maximumWidth: bar.tabWidth
                    name: modelData.name
                    subtitle: modelData.subtitle
                    kind: group.kind
                    statusSource: modelData
                    current: win.currentPage === index + (group.kind === "task" ? win.devicePages.length : 0)
                    onClicked: win.currentPage = index + (group.kind === "task" ? win.devicePages.length : 0)
                }
            }

            Label { text: qsTr("设备"); color: palette.placeholderText }
            Group { kind: "device" }

            Item { Layout.fillWidth: true; Layout.minimumWidth: 16 }

            Group { kind: "task" }
            Label { text: qsTr("任务"); color: palette.placeholderText }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: palette.mid }

        // 页面栈承载已创建的 QML 官邸页面；切页只改变可见性，保留历史、视角与任务计划。
        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: win.currentPage

            Repeater {
                model: win.pages
                delegate: Item {
                    id: pageHost
                    required property var modelData
                    readonly property real minimumPageWidth: modelData.minimumPageWidth
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: minimumPageWidth
                    onMinimumPageWidthChanged: win.pageMinWidth = Math.max(win.pageMinWidth, minimumPageWidth)
                    Component.onCompleted: {
                        modelData.parent = pageHost
                        modelData.anchors.fill = pageHost
                        win.pageMinWidth = Math.max(win.pageMinWidth, minimumPageWidth)
                    }
                }
            }
        }
    }
}
