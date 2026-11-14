#pragma once
#include <HandleBase.h>
#include <QMetaType>
#include <QString>
#include <string>

// 随 Lidar.UI 类型登记初始化一次；设备/任务信号保持 UTF-8 std::string，
// QML 的 string 参数只在此显示边界转换。无官邸包装信号或文本缓存。
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
