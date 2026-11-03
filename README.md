# UICore

基础输入控件、收缩栏、子标签页和带日志的公共页面。Windows / Linux，C++20，CMake ≥ 3.28。

## 边界与依赖

- Qt ≥ 6.11.2；Qt 由使用环境提供，不在仓库中打包。
- 上游：HandleCore 基础目标，仅复用 ResourcePhase 原类型的 Qt 元对象并注册到 Lidar.UI；不启用任何 Handle 可选模块。已有目标时复用，否则按完整提交获取。
- 本仓库不依赖 LiDAR_DataACQ 源码、应用目录或设备型号；不包含第三方二进制。
- 使用 Qt Quick/QML/Controls；不认识 Device、Task 或 Chart。ModulePage 只排列已有页面/分区、维护公共布局与日志，不改变子对象的 QObject 所有权。

## 独立构建和验证

安装对应 Qt 开发包，然后执行（将路径替换为本机 Qt 前缀）：

```sh
cmake -S . -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.11.2/platform -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel 2
ctest --test-dir build -C Release --output-on-failure
```

Windows 在安装 MSVC 的环境运行以上命令，Qt 选择对应 MSVC 构建；Linux 使用 GCC 与 OpenMP 开发环境。
Linux 还需 Qt Quick 运行依赖；ChartCore 需 GuiPrivate 头和 ShaderTools/qsb。GitHub Actions 使用 Qt 6.11.2，执行构建、QML 检查和无窗口组件装配。

## 接入应用

```cmake
include(FetchContent)
FetchContent_Declare(lidar_uicore
    GIT_REPOSITORY https://github.com/Lateef-ZHOU/UICore.git
    GIT_TAG <经过验证的完整提交号>)
FetchContent_MakeAvailable(lidar_uicore)
target_link_libraries(my_app PRIVATE Lidar::UICore)
```

从仓库提交列表选择固定版本；示例占位值必须替换，不使用浮动分支保证可复现。多个模块共用已有上游目标，应用若需覆盖上游版本应先统一声明并创建它们。标准 `FETCHCONTENT_SOURCE_DIR_LIDAR_模块名`（模块名大写无分隔）可用于本地开发，发布验证应取消覆盖并实际拉取远端。

界面是静态 QML 插件；应用还须链接 `LidarUICoreplugin`，并在一个 C++ 源文件包含 `<QtQml/QQmlExtensionPlugin>`，分别写 `Q_IMPORT_QML_PLUGIN(LidarUIPlugin)`。QML 使用 `import Lidar.UI`。完整最小示例见 tests/smoke.cpp。

构建工具/部署工具的 QML 导入根目录，由目标的 `QT_QML_MODULE_OUTPUT_DIRECTORY` 向上两级取得；不要假定上游仓库与本仓库相邻。

## 公共下拉控件

`ChoiceBox` 保留 Qt 原生的 model、currentIndex/currentValue、textRole/valueRole 和 activated 接口，适用于由控件自身持有选项的输入。`ChoiceField` 在其上保留原有 value/committed 确认规则和逐项提示，适用于由业务持值方接受或拒绝选择的输入；两者不互存第二份选择状态。

弹出列表优先放在控件下方，放不下时选择空间较大的一侧；超过可用高度则在这一侧滚动，面板不覆盖选择框。位置在每次展开时按窗口坐标重算，适用于滚动侧栏。列表为空时不挂接弹出面板，不禁用控件、不产生空白弹层；重新收到候选后恢复正常选择。颜色跟随 palette，不依赖 Windows 专用样式实现。

2026-10-29 Windows Qt 6.11.2 / MSVC 验证：Release 增量构建及 qmllint 通过，无编译/QML 警告。CTest 3/3 通过：原组件装配，以及 Basic、FluentWinUI3 各 9 个交互场景（QtTest 含初始化/收尾各 11 项）。覆盖上下展开、长列表滚动至末项、初始空表、空表鼠标/键盘、补入候选、展开中清空、持值方拒绝、原生选值及父容器移动后重定位；测试遇到 QML 警告即失败。上下弹出截图已查看，离屏截图只验证布局，Fluent 原生控件背景不作为离屏画质依据。仅本地修改，未重跑 Linux、未推送。

证据：build/build-choice-final.log、build/test-choice-final.log、build/tests/choice-below.png、build/tests/choice-above.png。初轮发现 Qt 替换 popup 会解绑可视父项，重新接入时已恢复；首次延迟创建与 Fluent 样式计算的绑定警告已通过提前初始化解决，没有新增业务状态或延迟重试。

## 来源与许可

从 [LiDAR_DataACQ](https://github.com/Lateef-ZHOU/LiDAR_DataACQ) 的模块分离提交 `94ad6f8` 提取；初始分仓保持运行逻辑，独立整理构建、验证与发布入口。

自有代码采用 [MIT](LICENSE)，Copyright (c) 2026 周涛 (ZHOU TAO)。第三方依赖不随本仓库改为 MIT，参见 [依赖说明](THIRD_PARTY_NOTICES.md)。

## 通用工作台

`WorkbenchWindow` 接收 `devicePages` / `taskPages` 两组 `list<ModulePage>`，只装配现有页面，不创建业务后端或持有设备清单。页面须提供名称、副名称及对应状态供标签展示；分组由输入列表确定。保持原布局、等宽标签、最小宽度与常驻页面，切换不重建图窗。实际型号和任务由消费应用静态声明。

## 资源状态显示

设备页向标签提供只读 `deviceState` 机制引用，标签监听其 `logSource.connectionChanged(phase)` 与 `lockChanged(phase)`。仅在 Acquired / Released 回读 isOpen、isLocked、holder 并生成颜色和文案，不保存另一份业务状态。AboutToRelease 留给同步业务收尾，不提前展示已关闭；迟到的 Released 也回读当前事实。任务标签继续监听任务自身 running/runChanged。ResourcePhase 的唯一 C++ 定义及 Qt 元对象登记位于 HandleCore 的 HandleBase.h，本库通过 ResourcePhaseQml.h 只作 QML 登记，不复制枚举或元对象。

2026-11-02 本地验证：Windows Qt 6.11.2 Release 和 CTest 3/3 通过，Basic/Fluent 两种样式均增加资源完成事件回读测试，覆盖迟到 Released 不覆盖当前连接/锁事实。Linux 界面本轮未重测。本轮依赖提交尚未推送；本地联调通过 FetchContent 源目录覆盖供入对应 HandleCore。


2026-11-03 用户定：枚举定义合入 HandleBase.h 后，QML 登记头同步改为包含该头；固定 HandleCore 753f884cd2644ac423e1feb4004bdcb14b233ad9，本地验证通过源目录覆盖接入未推送提交。Windows/MSVC/Qt 6.11.2 Release 构建及 CTest 3/3（1.88 秒）通过，涵盖 QML 枚举登记、完成阶段状态回读和 Basic/Fluent 控件测试。证据 build-phase-header/{configure,build,test}.log。未测 Linux、ARM 或硬件，未推送。

## 2026-11-04：设备日志直接接线（用户定）

CollectionTab 直接监听 deviceState 的 connectionChanged，与 lockChanged 一样从具体设备接收；不再读取 deviceState.logSource。LogSection/Rail 的 logSource 是日志组件实际输入，仍保留，不与设备的冗余自引用属性混淆。 本轮仅本地整理，未推送；Windows 集成验证记录见主程序维护操作。
