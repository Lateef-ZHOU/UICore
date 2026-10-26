// Rail —— 模块页面的右栏：分区自上而下 + 日志垫底，整栏一起滚。
// 由 ModulePage 装配，设备/任务模块继承公共布局。
// 用法：Rail { logSource: …; Section {…} Section {…} } —— 子项按声明顺序排进栏里，日志由本件垫底。
// 日志源只需提供 logMessage(text) 信号，缓存与显示都由 LogSection 管理。
//
// ── **右栏是定宽刚体**（min == preferred == max）──────────────────────────────
// 用户的两条原则：① 本栏不被压 ⇒ 不切控件；② 压到头由窗口拒绝。
// ① 靠本栏定宽；② 靠窗口的最小宽度 = 留白 + max(标签栏, 各页的 minimumPageWidth)，那一笔
// 由 Workbench.qml 显式写（Qt Quick 的 layout 不碰 Window 的最小尺寸，见那边的长注）；页面算
// minimumPageWidth 时读本件的 railWidth。
// ⚠ 别让本栏的宽度跟着内容走（column.implicitWidth）：文本元件不钉 preferredWidth 时，它的
// implicitWidth 就是整段文字的宽——一条长路径能把本栏撑出屏幕（路径那块怎么钉见 PathField.qml）。
//
// 400 是个**设计决定**而非测量值：本栏是表单列，栏内每个元件都得能在 400 里收得住
// （fillWidth + preferredWidth + elide / 折行）。收不住的是那个元件的 bug，一眼就能看见。
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {
    id: rail

    required property var logSource // 模块自身或内部业务信号源
    readonly property real railWidth: 400
    // 分区按声明顺序排进 host；日志在 host 下面垫底（故不直接 alias 到 column.data，否则日志会排在最上）。
    default property alias sections: host.data

    Layout.fillHeight: true
    Layout.minimumWidth: rail.railWidth
    Layout.preferredWidth: rail.railWidth
    Layout.maximumWidth: rail.railWidth
    // 内容正好等于视口宽 ⇒ 不需要横向滚，也不会有东西越界。
    contentWidth: availableWidth
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    ColumnLayout {
        id: column
        // **不是 parent.width**：ScrollView 里的 parent 是 Flickable，它的宽**含**竖直
        // 滚动条那一条；按它铺，最右边一竖条内容就压在滚动条底下看不见了。
        width: rail.availableWidth
        // 高度随内容走（可滚容器里没有"剩余高度"这个量，见 LogSection.qml 头注）。
        height: implicitHeight
        spacing: 8

        ColumnLayout {
            id: host
            Layout.fillWidth: true
            spacing: 8
        }

        // 高度随内容走（环有界，见 LogSection.qml 头注）。
        LogSection { Layout.fillWidth: true; logSource: rail.logSource }
    }
}
