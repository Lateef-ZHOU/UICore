#include <HandleBase.h>
#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QDebug>
#include <QtQml/QQmlExtensionPlugin>
#include <format>
#include <memory>
#include <string>
#include <thread>
Q_IMPORT_QML_PLUGIN(LidarUIPlugin)

class Source final : public QObject
{
    Q_OBJECT
Q_SIGNALS:
    void logMessage(const std::string &text);
};
int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData(R"QML(
import QtQuick
import Lidar.UI
ModulePage {
    id: root
    required property QtObject source
    property string last: ""
    property int count: 0
    property Connections connection: Connections {
        target: root.source
        function onLogMessage(text: string) { root.logMessage(text) }
    }
    onLogMessage: text => { last = text; ++count }
    function fromUi() { source.logMessage("界面输入：温度 28 °C") }
})QML", QUrl());
    Source source;
    std::unique_ptr<QObject> page(component.createWithInitialProperties({{"source", QVariant::fromValue(&source)}}));
    if (!page) { qCritical() << component.errors(); return 1; }
    const auto expected = std::format("中文日志：温度 {:.2f} °C，编号 0x{:08x}", 26.5, 42);
    std::thread worker([&] {
        auto message = expected;
        Q_EMIT source.logMessage(message);
        message.assign(4096, 'x'); // 发射后复用并销毁原字符串，排队消息须独立持有。
    });
    worker.join();
    if (page->property("count").toInt() != 0) return 2;
    app.processEvents();
    if (page->property("count").toInt() != 1 || page->property("last").toString().toStdString() != expected) return 3;
    bool correctThread = false;
    std::string received;
    QObject::connect(&source, &Source::logMessage, &app, [&](const std::string &text) {
        correctThread = QThread::currentThread() == app.thread(); received = text;
    });
    if (!QMetaObject::invokeMethod(page.get(), "fromUi")) return 4;
    if (!correctThread || received != "界面输入：温度 28 °C" || page->property("count").toInt() != 2) return 5;
    // 生产日志栏须显示同一文本；QML 操作日志仍然使用 UI string。
    bool displayed = false;
    for (auto *child : page->findChildren<QObject *>()) {
        const auto text = child->property("text").toString();
        if (text.contains(QString::fromStdString(expected)) && text.contains(QString::fromUtf8("界面输入：温度 28 °C"))) displayed = true;
    }
    if (!displayed) return 6;
    qInfo("UTF-8 queued ownership, format, QML conversion and production LogSection passed");
    return 0;
}
#include "log_utf8.moc"
