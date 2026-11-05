import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtTest
import Lidar.UI

TestCase {
    id: test
    name: "DoubleButtonRow"
    when: windowShown
    visible: true
    width: 640
    height: 120
    property int firstCalls: 0
    property int secondCalls: 0
    ColumnLayout {
        id: column
        width: 400
        DoubleButtonRow {
            id: row
            firstAction: Action {
                id: first
                objectName: "first"
                text: "设置参数并出光"
                onTriggered: test.firstCalls++
            }
            secondAction: Action {
                objectName: "second"
                text: "关光"
                onTriggered: test.secondCalls++
            }
        }
    }
    function test_layoutAndActions() {
        const left = findChild(row, "first")
        const right = findChild(row, "second")
        verify(left instanceof Button)
        verify(right instanceof Button)
        for (const width of [400, 560]) {
            column.width = width
            tryCompare(row, "width", width)
            tryVerify(() => Math.abs(left.width - right.width) <= 1)
            compare(left.x, 0)
            compare(right.x - left.x - left.width, 8)
            compare(right.x + right.width, width)
        }
        verify(waitForRendering(row))
        mouseClick(left)
        compare(firstCalls, 1)
        compare(secondCalls, 0)
        mouseClick(right)
        compare(secondCalls, 1)
        first.enabled = false
        tryCompare(left, "enabled", false)
        mouseClick(left)
        compare(firstCalls, 1)
        verify(right.enabled)
    }
}
