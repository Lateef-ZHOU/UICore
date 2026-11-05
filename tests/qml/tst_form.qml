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
    ColumnLayout {
        id: paragraphs
        width: 260
        FormLabel { id: reference; text: "正常正文" }
        FormLabel {
            id: errorText
            multiline: true
            text: "设备返回的错误信息应完整换行显示，不能挤宽右侧栏或变成浅色说明文字。设备返回的错误信息应完整换行显示。"
        }
        InfoRow {
            id: scope
            caption: "拿锁范围"
            multiline: true
            text: "采集·国实双光子、采集·国实CDL5、转台·铭辰机电；长名称在值列内换行。"
        }
    }
    function test_multilineBoundsAndStyle() {
        const value = scope.children.filter(child => child instanceof Label)[1];
        for (const width of [260, 382, 480]) {
            paragraphs.width = width;
            tryCompare(errorText, "width", width);
            tryCompare(scope, "width", width);
            tryVerify(() => errorText.lineCount > 1 && value.lineCount > 1);
            verify(!errorText.truncated && !value.truncated);
            verify(value.x + value.width <= width + 1);
            compare(value.x, FormStyle.labelWidth + FormStyle.columnSpacing);
            compare(errorText.font.pixelSize, reference.font.pixelSize);
            compare(errorText.color, reference.color);
        }
        errorText.multiline = false;
        tryCompare(errorText, "lineCount", 1);
        tryCompare(errorText, "truncated", true);
        errorText.multiline = true;
        tryVerify(() => errorText.lineCount > 1);
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

