// 页面内的子标签容器；所有内容常驻，切换只改变可见性。
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: pane
    required property list<Page> pages
    spacing: 0
    TabBar {
        id: bar
        visible: pane.pages.length > 1
        Layout.fillWidth: true
        Repeater {
            model: pane.pages
            delegate: TabButton {
                required property Page modelData
                text: modelData.title
            }
        }
    }
    StackLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: bar.currentIndex
        Repeater {
            model: pane.pages
            delegate: Item {
                id: host
                required property Page modelData
                Component.onCompleted: {
                    modelData.parent = host
                    modelData.anchors.fill = host
                }
            }
        }
    }
}
