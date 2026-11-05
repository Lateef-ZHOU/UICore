pragma Singleton
import QtQuick

// 表单的视觉规格；业务页面选择布局，参数与状态不进入本对象。
QtObject {
    readonly property int compactInfoLabelWidth: 40
    readonly property int labelWidth: 120
    readonly property int wideLabelWidth: 160
    readonly property int fieldColumnWidth: 110
    readonly property int readoutColumnWidth: 64
    readonly property int rowSpacing: 6
    readonly property int columnSpacing: 8
    readonly property int captionSpacing: 2
    readonly property int sectionPadding: 8
}
