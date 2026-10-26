// BoolField —— 勾选框。
//
// 形制与 ValueField 同构，读法也一样：
//   · `checked` = 控件此刻的样子（**Qt 自己会写它**——点一下就翻）；
//   · `value`   = 已认可的值，由**持值方**说了算；
//   · `committed` = "用户想改成这样"这条通知，**它不替人改 value**。
//
// **checked 绝不能绑定**（凡是 Qt 自己也会写的量都不能用声明式绑定，道理见 ValueField.qml 头注）：
// 绑定不会被点击弄断，但持值方不认时它不重算，勾选框就停在用户点出来的样子上；而下面那一笔收口
// 是命令式赋值，一写绑定就没了，此后 C++ 那头再改就推不下来。故这里两头各自写一次：value 变了
// 刷 checked，用户点了发 committed。
//
// 提交后立刻 `checked = value` 收口：持值方若没认（拒绝 / 忙 / 越权），勾选框自己弹回去。
// 认了的话 value 已经变成新值，这一行是 no-op。
import QtQuick
import QtQuick.Controls

CheckBox {
    id: root
    property bool value: false
    signal committed(bool newValue)

    onToggled: {
        root.committed(root.checked)
        root.checked = root.value
    }
    onValueChanged: root.checked = root.value
    Component.onCompleted: root.checked = root.value
}
