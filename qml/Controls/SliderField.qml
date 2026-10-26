// SliderField —— 单值滑块 + 右侧读数。
//
// 形制与 ValueField / BoolField / ChoiceField 同构：
//   · `bar.value` = 控件此刻的样子（**Qt 自己会写它**——一拖就变）；
//   · `value`     = 已认可的值，持值方说了算；
//   · `committed` = "用户把它拖到这儿了"，**不替人改 value**。
// **bar.value 绝不能绑定**（凡是 Qt 自己也会写的量都不能绑，道理见 ValueField.qml 头注）：拖动本身
// 弄不断绑定，但本件要在 onMoved 里把吸附值写回滑块——那一笔命令式赋值一落，绑定就没了，此后
// C++ 那头再改就推不下来。
//
// ── 三样机制 ──────────────────────────────────
// ① **松手才提交**：拖一次滑块会走过几十个像素，每一格都记一条日志就是刷屏。故跟手的只有读数，
//    `committed` 在 `pressed` 变假那一刻发一次——用事件自己的边界，不设计时器。
// ② **只认鼠标 / 触摸**（用户定）：方向键没有"松手"，一步一提交又回到刷屏，故不给焦点
//    （`focusPolicy: Qt.NoFocus`，键根本到不了它）。滚轮 Qt 默认就不接（`wheelEnabled` 假），
//    保持不开——滑块住在可滚动的页面里，接了就会把滚到一半的页面截住。
// ③ **按步长吸附，但不给 stepSize**：给了 stepSize，FluentWinUI3 只在 (to − from) / stepSize 恰为整数时
//    在轨道上下各画一排刻度（floor(steps)+1 个）——整数量程的那台会被画得密密麻麻、小数步长的那台压根
//    不画，两台云台的滑块就长得不一样。故自己在 onMoved 里吸附，视觉上照样一格一格走。
//
// 按住期间不把 value 同步回控件，免得跟手抖；松手那一笔收口会补上。
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property real value: 0
    property real from: 0
    property real to: 1
    property real stepSize: 1
    property int decimals: 0
    signal committed(real newValue)

    spacing: 6
    Layout.fillWidth: true

    function snap(v) {
        return Math.round(v / root.stepSize) * root.stepSize
    }
    function commit() {
        root.committed(root.snap(bar.value))
        bar.value = root.value // 收口：持值方没认（钳了 / 拒了）就弹回去
    }

    Slider {
        id: bar
        Layout.fillWidth: true
        from: root.from
        to: root.to
        focusPolicy: Qt.NoFocus
        onMoved: bar.value = root.snap(bar.value)
        onPressedChanged: if (!bar.pressed) root.commit()
        Component.onCompleted: bar.value = root.value
    }

    onValueChanged: if (!bar.pressed) bar.value = root.value

    Label {
        text: root.snap(bar.value).toFixed(root.decimals)
        horizontalAlignment: Text.AlignRight
        Layout.preferredWidth: 46
        font.family: "Consolas" // 纯数字才用等宽：Consolas 没有中文字形，一掺中文 Qt 就去回退表里捞，捞上来的往往是宋体
    }
}
