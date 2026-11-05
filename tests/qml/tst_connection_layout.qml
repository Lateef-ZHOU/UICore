import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtTest
import Lidar.UI

TestCase {
    id: test
    name: "ConnectionLayout"
    when: windowShown
    visible: true
    width: 600
    height: 500
    property int submitted: -1
    property int closes: 0
    FormLabel { id: styleReference; visible: false }
    ColumnLayout {
        id: column
        width: 382
        ConnectionSection {
            id: section
            title: "设备连接"
            label: "端口"
            ChoiceField {
                id: choice
                Layout.fillWidth: true
                model: ["A", "B"]
                value: 1
            }
            firstAction: Action {
                objectName: "open"
                text: "连接"
                onTriggered: test.submitted = choice.value
            }
            secondAction: Action {
                objectName: "close"
                text: "断开"
                onTriggered: test.closes++
            }
        }
        InfoRow {
            id: info
            caption: "型号"
            text: "Model"
        }
        InfoRow {
            id: compact
            compact: true
            caption: "SN"
            text: "123456789012345678901234567890123456789012345678901234567890"
        }
        HintText {
            id: hint
            text: "说明文字保持在侧栏宽度内，并随可用宽度自动换行。说明文字保持在侧栏宽度内，并随可用宽度自动换行。"
        }
    }
    function test_externalActionsAndGeometry() {
        const infoLabels = info.children.filter(child => child instanceof Label);
        const compactLabels = compact.children.filter(child => child instanceof Label);
        compare(infoLabels.length, 2);
        compare(compactLabels.length, 2);
        for (const label of infoLabels)
            compare(label.font.pixelSize, styleReference.font.pixelSize);
        for (const label of compactLabels)
            compare(label.font.pixelSize, 12);
        const first = findChild(section, "open");
        const second = findChild(section, "close");
        verify(first instanceof Button);
        for (const width of [382, 480]) {
            column.width = width;
            tryCompare(section, "width", width);
            tryVerify(() => Math.abs(first.width - second.width) <= 1);
            compare(second.x - first.x - first.width, FormStyle.columnSpacing);
            verify(choice.mapToItem(section, choice.width, 0).x <= width);
            tryCompare(info, "width", width);
            tryCompare(compact, "width", width);
            verify(hint.width <= width);
            verify(hint.lineCount > 1);
        }
        verify(waitForRendering(section));
        mouseClick(first);
        compare(test.submitted, 1);
        mouseClick(second);
        compare(test.closes, 1);
        section.expanded = false;
        tryCompare(choice, "visible", false);
    }
}
