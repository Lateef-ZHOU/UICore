#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QDebug>
#include <memory>
#include <QtQml/QQmlExtensionPlugin>
Q_IMPORT_QML_PLUGIN(LidarUIPlugin)
int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);
    QQmlEngine engine;
    QQmlComponent component(&engine);
    component.setData(R"QML(import QtQuick
import Lidar.UI
ModulePage { width: 800; height: 600 })QML", QUrl());
    std::unique_ptr<QObject> object(component.create());
    if (!object) { qCritical() << component.errors(); return 1; }
    return 0;
}
