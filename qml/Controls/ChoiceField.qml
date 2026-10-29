// ChoiceField —— 下拉框。
//
// 形制与 ValueField / BoolField 同构：
//   · `currentIndex` = 控件此刻的样子（**Qt 自己会写它**——选一项就变）；
//   · `value`        = 已认可的「第几项」，持值方说了算；
//   · `committed`    = "用户想选第 i 项"这条通知，**不替人改 value**。
//
// **currentIndex 绝不能绑定**（凡是 Qt 自己也会写的量都不能用声明式绑定）。
// 提交后立刻 `currentIndex = value` 收口：持值方没认就自己弹回去。
//
// **只传下标，不传枚举**：波特率 / 校验位 / 颜色图那些强类型从不跨到 QML 这边来，
// 界面拿到的是 C++ 交下来的一张字符串表（model），选中的是它的下标——一份账。
// `tips` 是可选的逐项说明（串口的设备描述、网卡的适配器描述），空表即无 tooltip。
import QtQuick
import QtQuick.Controls

ChoiceBox {
    id: root
    property int value: 0
    property var tips: []
    signal committed(int newIndex)

    // onActivated 只在**用户**选时发（程序改 currentIndex 不发），正是我们要的那一口。
    onActivated: function (i) {
        root.committed(i)
        root.currentIndex = root.value
    }
    onValueChanged: root.currentIndex = root.value
    Component.onCompleted: root.currentIndex = root.value

    // 气泡：**各自一个实例，不走 `ToolTip.xxx` 那套附加属性**——附加属性背后是一只**全局共享**的
    // ToolTip，实机上它在下拉框上会赖着不走（用户报：鼠标进出都没反应，要在外面点一下才收）。
    // 各用各的实例、`timeout: -1`（只听 visible 这一条）之后正常。**病根没有查清**：共享那只在离屏
    // 测试里复现不出这个症状，也不是「绑定被写断」（Qt 自己的写入弄不断绑定，见 ValueField.qml 头注）。
    // CollectionTab.qml / PathField.qml 的气泡同此。
    ToolTip {
        delay: 400
        timeout: -1
        visible: root.hovered && text !== ""
        text: (root.currentIndex >= 0 && root.currentIndex < root.tips.length)
              ? root.tips[root.currentIndex] : ""
    }
}
