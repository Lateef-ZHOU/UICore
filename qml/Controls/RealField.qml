// RealField —— 实数输入框。
// **本件零判断**：范围与小数位全在 DoubleValidator 里。
// **locale 钉成 "C"**：不钉则小数分隔符随系统区域走，某些区域只认逗号——那是换台机器才
// 现形的坑。**notation 钉成 StandardNotation**：不收 1e3 这种写法。
import QtQuick

ValueField {
    id: root
    required property real minimum
    required property real maximum
    property int decimals: 2

    placeholderText: "[" + root.minimum.toFixed(root.decimals) + ", " + root.maximum.toFixed(root.decimals) + "]"
    validator: DoubleValidator {
        bottom: root.minimum
        top: root.maximum
        decimals: root.decimals
        notation: DoubleValidator.StandardNotation
        locale: "C"
    }

    formatValue: function (v) { return v.toFixed(root.decimals) }
    parseText: function (s) { return parseFloat(s) }
}
