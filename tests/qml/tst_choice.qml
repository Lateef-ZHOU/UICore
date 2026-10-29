import QtQuick
import QtQuick.Window
import QtTest
import Lidar.UI

Item {
    id: scene
    width: 640
    height: 480

    Item {
        id: container
        width: parent.width
        height: parent.height
        ChoiceField {
            id: choice
            x: 40; y: 30; width: 220; height: 40
            onCommitted: i => { if (tests.acceptSelection) value = i }
        }
        ChoiceBox {
            id: plain
            x: 340; y: 30; width: 220; height: 40
            model: [5, 8, 10]
        }
        ChoiceBox {
            id: empty
            x: 340; y: 300; width: 220; height: 40
            model: []
        }
    }
    TestCase {
        id: tests
        name: "ChoicePopup"
        when: windowShown
        property bool acceptSelection: true

        function init() {
            failOnWarning(/.*/)
            container.y = 0
            choice.y = 30
            choice.model = ["Ethernet 6", "Ethernet"]
            choice.value = 0
            choice.currentIndex = 0
            plain.model = [5, 8, 10]
            plain.currentIndex = 2
            acceptSelection = true
            wait(20)
        }
        function cleanup() {
            if (choice.popup) choice.popup.close()
            if (plain.popup) plain.popup.close()
            wait(20)
        }
        function open(control) {
            mouseClick(control, control.width / 2, control.height / 2)
            tryCompare(control.popup, "visible", true)
            wait(30)
        }
        function popupRect(control) {
            const popup = control.popup
            const p = popup.contentItem.mapToItem(scene, -popup.leftPadding, -popup.topPadding)
            return Qt.rect(p.x, p.y, popup.width, popup.height)
        }
        function test_below() {
            open(choice)
            const r = popupRect(choice)
            verify(r.y >= choice.y + choice.height)
            verify(r.y + r.height <= scene.height)
            compare(r.width, choice.width)
            grabImage(scene.Window.contentItem).save("choice-below.png")
        }
        function test_above() {
            choice.y = 410
            open(choice)
            const r = popupRect(choice)
            verify(r.y + r.height <= choice.y)
            verify(r.y >= 0)
            grabImage(scene.Window.contentItem).save("choice-above.png")
        }
        function test_long_list_scroll_and_select() {
            choice.model = Array.from({length: 100}, (_, i) => "Port " + i)
            choice.y = 190
            open(choice)
            const r = popupRect(choice)
            verify(r.y >= choice.y + choice.height || r.y + r.height <= choice.y)
            verify(r.y >= 0 && r.y + r.height <= scene.height)
            verify(choice.popup.contentItem.contentHeight > choice.popup.availableHeight)
            keyClick(Qt.Key_End)
            keyClick(Qt.Key_Return)
            compare(choice.value, 99)
            compare(choice.currentIndex, 99)
        }
        function test_empty_mouse_keyboard_and_refill() {
            choice.model = []
            tryCompare(choice, "count", 0)
            verify(choice.enabled)
            compare(choice.popup, null)
            mouseClick(choice, 40, 20)
            keyClick(Qt.Key_Space)
            compare(choice.popup, null)
            compare(choice.down, false)
            compare(choice.currentIndex, -1)
            choice.model = ["COM4", "COM7"]
            open(choice)
            keyClick(Qt.Key_Down)
            keyClick(Qt.Key_Return)
            compare(choice.value, 1)
            compare(choice.currentText, "COM7")
        }
        function test_initial_empty() {
            verify(empty.enabled)
            compare(empty.currentIndex, -1)
            compare(empty.popup, null)
            mouseClick(empty, 40, 20)
            keyClick(Qt.Key_Space)
            compare(empty.popup, null)
            compare(empty.down, false)
        }
        function test_clear_open_list() {
            open(choice)
            const oldPopup = choice.popup
            choice.model = []
            tryCompare(choice, "popup", null)
            tryCompare(oldPopup, "visible", false)
            compare(choice.down, false)
            choice.model = ["Restored"]
            open(choice)
        }
        function test_rejected_selection_keeps_owner_value() {
            acceptSelection = false
            open(choice)
            keyClick(Qt.Key_Down)
            keyClick(Qt.Key_Return)
            compare(choice.value, 0)
            compare(choice.currentIndex, 0)
        }
        function test_plain_selection_and_empty() {
            open(plain)
            keyClick(Qt.Key_Home)
            keyClick(Qt.Key_Return)
            compare(plain.currentIndex, 0)
            compare(plain.currentValue, 5)
            plain.model = []
            mouseClick(plain, 40, 20)
            compare(plain.popup, null)
            compare(plain.down, false)
        }
        function test_moved_parent_repositions_on_open() {
            open(choice)
            choice.popup.close()
            container.y = 370
            open(choice)
            const r = popupRect(choice)
            verify(r.y + r.height <= container.y + choice.y)
        }
    }
}
