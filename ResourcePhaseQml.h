#pragma once
#include <ResourcePhase.h>
#include <QtQml/qqmlregistration.h>

// 仅登记 HandleCore 的原枚举，不复制枚举或持有资源状态。
namespace ResourcePhaseQml
{
Q_NAMESPACE
QML_FOREIGN_NAMESPACE(HandleCore)
QML_NAMED_ELEMENT(ResourcePhase)
}
