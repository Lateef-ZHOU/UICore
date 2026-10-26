// RangeSliderField —— 双头滑块 + 右侧读数。
//
// 与 SliderField 同构（松手才提交 / 只认鼠标与触摸 / 控件值绝不绑定），
// 只是两头各一个值。两头不会互相越过——RangeSlider 自己就保证 first ≤ second。
//
// 本族只有整数客户（3D 谱的距离门与频率值下标），故读数不留小数。
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property int lower: 0
    property int upper: 1
    property int from: 0
    property int to: 1
    signal committed(int newLower, int newUpper)

    spacing: 6
    Layout.fillWidth: true

    function held() {
        return bar.first.pressed || bar.second.pressed
    }
    function commit() {
        root.committed(Math.round(bar.first.value), Math.round(bar.second.value))
        root.sync() // 收口：持值方没认就弹回去
    }
    // **先把下头退到底再摆**：RangeSlider 两头互不越位，直接按序赋值可能被对方当场夹住
    //（比如要把区间整体抬高时，first 先动就会顶在旧的 second 上）。退到量程下界腾出空间，
    // 三笔下来任何目标区间都摆得进去。
    function sync() {
        bar.first.value = root.from
        bar.second.value = root.upper
        bar.first.value = root.lower
    }

    RangeSlider {
        id: bar
        Layout.fillWidth: true
        from: root.from
        to: root.to
        focusPolicy: Qt.NoFocus
        first.onPressedChanged: if (!bar.first.pressed) root.commit()
        second.onPressedChanged: if (!bar.second.pressed) root.commit()
        Component.onCompleted: root.sync()
    }

    onLowerChanged: if (!root.held()) root.sync()
    onUpperChanged: if (!root.held()) root.sync()

    Label {
        text: Math.round(bar.first.value) + "–" + Math.round(bar.second.value)
        horizontalAlignment: Text.AlignRight
        Layout.preferredWidth: 72
        font.family: "Consolas" // 纯数字才用等宽（理由见 SliderField.qml 那句）
    }
}
