// ValueField —— 输入框族的公共壳。
//
// ============================================================
// **核心语义**（用户定）
//
//   `editingFinished` == **一个新的合法值出现了**。
//
// 就这一句。TextField 只在 `acceptableInput` 为真时才发这一口 —— 那不是"残废"，那正是
// 我们要的判据：校验器把"这串字合不合法"直接答完，本族不需要"提交期再查一遍"那一层。
//
// 于是本族的分工只有两件：
//   · **校验** ⇒ 全在 `validator`。范围、格式、小数位、IPv4 每段 ≤255 —— 能用校验器表达的
//     一律交给它，本族**一个判断都不写**。范围由使用处绑进来（多数是 C++ 的 CONSTANT 边界），一份账。
//   · **转换** ⇒ `parseText`，把已经合法的文本变成值。那是取值，不是校验，没有失败支。
//
// **严格正则照样打得出来**：QRegularExpressionValidator 对"还能续成合法串"的半截输入返
// Intermediate，Intermediate 允许留在框里、只是不算 acceptable。所以 `192.168.` 打得出、
// 但不会被当成一个合法值提交——不需要另写一个"宽松校验器"。
//
// **值住哪儿，判据是寿命不是读写**：
//   · 页面重建后**该还在**的（连接参数、安装标定、任务设置、落盘目录）⇒ 住 C++，本件绑它；
//   · **一次性动作的入参**（前往某角、扇扫起止角）⇒ 就住本件自己，点按钮时当实参递下去。
// ⚠ 别拿"C++ 那头要读它"当理由说值必须在 C++ —— 那是**反摸**；该问的是寿命。
//
// **text 绝不用声明式绑定**（滑块 value / ComboBox currentIndex / 勾选框 checked 是同一个坑）——
// **凡是 Qt 或用户自己也会写的量都不能绑**。毛病不在「绑定会断」，实测（qmltestrunner）恰恰相反：
//   · 用户敲字 / 点击 / 拖动**不会**弄断绑定，它一直活着 ⇒ 数据源一变，敲到一半的字被整个冲掉；
//   · 持值方不认（拒绝，或钳回原值 ⇒ 不发 NOTIFY）时绑定不重算 ⇒ 控件停在用户弄出来的样子上，
//     **显示与事实分叉**，没人来拉；
//   · 要拉回来只能命令式地写一笔，而 **QML / JS 这边的赋值才真把绑定弄断**——此后程序改值，
//     界面再也不跟。
// 绑也不是、绑了再写也不是，故 text 一律**命令式**地写，共四处，各管一种局面：出生 / value 变了 /
// 提交完归一 / 半截输入下退出编辑（失焦 / 回车）。
//
// **半截输入必须拉回来，而且两条退出路都要管**：用户敲了 `192.168.` 就走，editingFinished
// 不会发（它只认合法值），框里那串半截货没人管、而 value 还是旧的 —— **显示与事实分叉**。
// 退出编辑有**两条**路：失焦、回车。只挡失焦的话，就会出现**"清空后点走会还原，清空后回车
// 不会"** —— 同一件事，走哪条门结局不同，正是最容易被当成玄学的那类 bug。两条都挡，口径
// 完全一致。
// 这是**显示卫生，不是校验** —— 别把它和校验混在一起（不需要 rejected 信号，也不需要自查）。
//
// **回车那一口的写法**：合格就把事件交回 TextField（由它去发 editingFinished），不合格才
// 自己还原。**两种顺序都对** —— 若本口先跑，不合格时 TextField 本来就不会做事；若 TextField
// 先跑，合格那支它已经发过 editingFinished 了。故不必关心谁先谁后。
//
// **打字期不拦越界是有意的**（实测：IntValidator(0,65535) 让 99999 打得进去）：越界但位数
// 相同的串是 Intermediate，而 **Intermediate 必须打得出来**，否则改数字会变成酷刑。
// 拦截发生在提交那一刻，不在按键那一刻。
//
// **使用方的信号处理器要写成函数形式**（弃用警告）：
//     onCommitted: function (newValue) { device.foo = newValue }
// ============================================================
import QtQuick
import QtQuick.Controls

TextField {
    id: root

    // 当前值。**唯一事实源**——界面只读它，不自己攒一份。
    required property var value
    // 把**已经合法**的文本转成值。没有失败支——校验归 validator。
    property var parseText: function (s) { return s }
    // 值 → 规范文字。
    property var formatValue: function (v) { return String(v) }

    // **新的合法值出现了。** 使用方接这一口去写 C++ 属性，或自己收下。
    signal committed(var newValue)

    selectByMouse: true

    // 退出编辑的两条路共用一套"显示拉回真值"。合格时无条件重写也顺带做了归一。
    function restore() { root.text = root.formatValue(root.value) }

    onEditingFinished: {
        root.committed(root.parseText(root.text))
        // 归一：committed 是同步的，此刻 value 已是最终值（可能被那头钳过）。
        // 顺带把 "45.2" 写成 "45.20"、"AA:BB:…" 写成 "AA-BB-…"。
        root.text = root.formatValue(root.value)
    }

    // 显示卫生（路一）：失焦。
    // **带 !acceptableInput 这一项非加不可**：合格时这一口与 editingFinished 谁先谁后不定，
    // 先跑就会在提交之前把用户刚敲的文本覆盖掉。限定成"只管不合格的"，两者便不可能打架。
    onActiveFocusChanged: if (!root.activeFocus && !root.acceptableInput) root.restore()

    // 显示卫生（路二）：回车 / 小键盘回车。合格就让开，由 TextField 去发 editingFinished。
    Keys.onReturnPressed: function (event) { root.finishByKey(event) }
    Keys.onEnterPressed: function (event) { root.finishByKey(event) }
    function finishByKey(event) {
        if (root.acceptableInput) {
            event.accepted = false // 让开：提交归 editingFinished 那一口，此处不重复
            return
        }
        event.accepted = true
        root.restore()
    }

    onValueChanged: if (!root.activeFocus) root.text = root.formatValue(root.value)
    Component.onCompleted: root.text = root.formatValue(root.value)
}
