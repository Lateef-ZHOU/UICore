// 公共业务页面：左侧子标签页、右侧收缩分区、末尾日志。只摆放实例，不认识业务计划。
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: page
    property list<Page> mainPages: []
    property list<Section> sections: []
    property real mainMinWidth: 480
    property real mainMargin: 0
    readonly property real minimumPageWidth: mainMinWidth + 1 + rail.railWidth

    // 派生页面共用此入口；历史与时间戳只由内部 LogSection 保存。
    signal logMessage(string text)

    RowLayout {
        anchors.fill: parent
        spacing: 0
        TabPane {
            pages: page.mainPages
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: page.mainMinWidth
            Layout.margins: page.mainMargin
        }
        Rectangle { Layout.fillHeight: true; implicitWidth: 1; color: palette.mid }
        Rail {
            id: rail
            logSource: page
            Repeater {
                model: page.sections
                delegate: Item {
                    id: host
                    required property Section modelData
                    implicitHeight: modelData.implicitHeight
                    Layout.fillWidth: true
                    Component.onCompleted: {
                        // 仅改变可视父项；QObject 所有权仍属于声明它的业务页面。
                        modelData.parent = host
                        modelData.width = Qt.binding(() => host.width)
                    }
                }
            }
        }
    }
}
