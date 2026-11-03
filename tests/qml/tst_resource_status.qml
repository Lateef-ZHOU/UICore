import QtQuick
import QtTest
import Lidar.UI

TestCase {
    id: test
    name: "ResourceStatus"
    when: windowShown
    width: 400
    height: 100
    QtObject {
        id: device
        property bool isOpen: false
        property bool isLocked: false
        property string holder: ""
        signal connectionChanged(int phase)
        signal lockChanged(int phase)
    }
    QtObject {
        id: page
        readonly property QtObject deviceState: device
    }
    CollectionTab {
        id: tab
        name: "测试设备"
        subtitle: "资源事件"
        kind: "device"
        statusSource: page
    }
    function test_completedEventsReadActualState() {
        const dot = findChild(tab, "resourceStatusDot")
        verify(dot !== null)
        const offline = dot.color
        device.isOpen = true
        device.connectionChanged(ResourcePhase.AboutToAcquire)
        compare(dot.color, offline)
        device.connectionChanged(ResourcePhase.Acquired)
        compare(dot.color, Theme.open)
        device.isLocked = true
        device.holder = "任务"
        device.lockChanged(ResourcePhase.AboutToAcquire)
        compare(dot.color, Theme.open)
        device.lockChanged(ResourcePhase.Acquired)
        compare(dot.color, Theme.locked)
        // 迟到的旧连接 Released 不能覆盖目前的连接/锁事实。
        device.connectionChanged(ResourcePhase.Released)
        compare(dot.color, Theme.locked)
        device.isLocked = false
        device.lockChanged(ResourcePhase.Released)
        compare(dot.color, Theme.open)
        device.isOpen = false
        device.connectionChanged(ResourcePhase.AboutToRelease)
        compare(dot.color, Theme.open)
        device.connectionChanged(ResourcePhase.Released)
        compare(dot.color, offline)
    }
}
