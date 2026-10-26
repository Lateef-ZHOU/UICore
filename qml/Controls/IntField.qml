// IntField —— 整数输入框。
// **本件零判断**：范围全在 IntValidator 里，两个数由使用处绑进来（说明见 ValueField.qml 头注）。
import QtQuick

ValueField {
    id: root
    required property int minimum
    required property int maximum

    placeholderText: "[" + root.minimum + ", " + root.maximum + "]"
    validator: IntValidator { bottom: root.minimum; top: root.maximum }

    formatValue: function (v) { return String(v) }
    parseText: function (s) { return parseInt(s, 10) }
}
