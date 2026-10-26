// MacField —— MAC 地址输入框。
// **本件零判断**：严格正则就能表达全部合法性（半截输入靠 Intermediate 打得出来）。
// 冒号与连字符都收，parseText 规范化成连字符大写——那是格式化，不是校验。
// 值是字符串，理由同 IPv4Field。
import QtQuick

ValueField {
    id: root

    placeholderText: "AA-BB-CC-DD-EE-FF"
    validator: RegularExpressionValidator { regularExpression: /^[0-9A-Fa-f]{2}([:\-][0-9A-Fa-f]{2}){5}$/ }

    formatValue: function (v) { return String(v) }
    parseText: function (s) { return s.replace(/:/g, "-").toUpperCase() }
}
