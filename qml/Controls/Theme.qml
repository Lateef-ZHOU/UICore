// Theme —— 工作台的几个状态色 / 任务色的唯一出处（不随系统主题走；随主题走的一律用 palette.*，不在这儿）。
// 单例：CollectionTab / TaskPlanView 直接取，罗盘也从 TaskPlanView 绑进去（C++ 里不留颜色事实）。
pragma Singleton
import QtQuick

QtObject {
    readonly property color task: "#9A5B13"        // 任务色：合集栏"运行中"的点、任务页的运行指示与当前束、罗盘的束
    readonly property color locked: "#0B7A83"      // 设备被占用（合集栏状态点）
    readonly property color open: "#2B8653"        // 设备已连接（合集栏状态点）
    readonly property color unreachable: "#BF3A3A" // 够不着的束（罗盘）
}
