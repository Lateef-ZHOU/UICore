#pragma once
#include <QObject>
#include <QDir>
#include <QUrl>
#include <QtQml/qqmlregistration.h>

// 只负责 URL 到本机显示路径的转换；业务与对话框继续传 QUrl。
class PathDisplay : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    Q_INVOKABLE QString localPath(const QUrl &url) const
    {
        return url.isLocalFile() ? QDir::toNativeSeparators(url.toLocalFile()) : url.toDisplayString();
    }
};
