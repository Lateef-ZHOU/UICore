#pragma once
#include <HandleBase.h>
#include <QMetaType>
#include <QString>
#include <QtQml/qqmlregistration.h>
#include <string>

// 为 QML 静态工具声明原类型；不包装字符串，不增加字段或读口。
struct Utf8TextQml
{
    Q_GADGET
    QML_FOREIGN(std::string)
    QML_ANONYMOUS
};

// 随 Lidar.UI 类型登记初始化一次；设备名称属性与设备/任务日志使用 UTF-8 std::string，
// QML 的 string 属性和参数在此显示边界转换。无官邸包装信号或文本缓存。
inline const bool logTextRegistered = []()
{
    const bool registered = QMetaType::registerConverter<std::string, QString>(
        [](const std::string &text) {
            return QString::fromUtf8(text.data(), static_cast<qsizetype>(text.size()));
        });
    // UI 自身的提示也可能调用设备的同一信号，输入时统一编码为 UTF-8。
    const bool inputRegistered = QMetaType::registerConverter<QString, std::string>(
        [](const QString &text) { return text.toStdString(); });
    return registered && inputRegistered;
}();
