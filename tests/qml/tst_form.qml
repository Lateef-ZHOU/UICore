import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtTest
import Lidar.UI

TestCase {
    id: test
    name: "FormLayout"
    when: windowShown
    visible: true
    width: 600
    height: 400
    ColumnLayout {
        id: form
        width: 382
        FieldRow {
            id: shortRow
            label: "网卡"
            ValueField { id: shortInput; Layout.fillWidth: true; value: "" }
        }
        FieldRow {
            id: longRow
            label: "很长的参数名称需要省略并允许查看全文"
            ValueField { id: longInput; Layout.fillWidth: true; value: "" }
        }
        FieldRow {
            id: wideRow
            wideLabel: true
            label: "任务参数"
            ValueField { id: wideInput; Layout.fillWidth: true; value: "" }
        }
        ReadoutRow {
            id: readings
            Readout { id: first; caption: "实际温度"; text: "26.93 °C" }
            Readout { caption: "输出电压"; text: "0.334 V" }
            Readout { caption: "输出电流"; text: "-0.001 A" }
            Readout { caption: "实际输出"; text: "关" }
            Readout { id: last; caption: "频率"; text: "10 kHz" }
        }
        FormLabel { id: longText; text: "Long model and serial number / Long model and serial number / Long model and serial number / Long model and serial number / Long model and serial number / Long model and serial number / Long model and serial number / Long model and serial number / Long model and serial number / Long model and serial number / Long model and serial number / Long model and serial number / " }
    }
    function test_alignmentAndBounds() {
        for (const width of [382, 480]) {
            form.width = width
            tryCompare(shortRow, "width", width)
            const x = shortInput.mapToItem(form, 0, 0).x
            compare(longInput.mapToItem(form, 0, 0).x, x)
            compare(x, FormStyle.labelWidth + FormStyle.columnSpacing)
            compare(wideInput.mapToItem(form, 0, 0).x, FormStyle.wideLabelWidth + FormStyle.columnSpacing)
            tryCompare(readings, "width", width)
            verify(Math.abs(first.width - last.width) <= 1)
            verify(last.x + last.width <= width + 1)
            verify(longText.width <= width)
            tryCompare(longText, "truncated", true)
        }
    }
}

