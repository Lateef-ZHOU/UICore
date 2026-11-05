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

## 2026-11-04：设备身份与占用查询（用户定）

设备标签只回读 holder 空值或字符串及 isOpen；不再读取 isLocked，空名称仍表示占用，连接和锁完成阶段通知保持。

本轮仅本地整理；集成验证记录见主程序 docs/maintenance/validation.md，不推送。


2026-11-05 标签显示（用户定）：CollectionTab 自然宽度最多 160 个逻辑像素，工作台仍按最大自然宽度等宽分配；窄窗口允许等宽缩至 96，最小窗口宽度仍尊重业务页面要求。主副标题超长右侧省略，悬停显示完整主副标题及状态，不缓存另一份设备身份。

本次验证：Windows Release 构建及现有 CTest 3/3 通过（build-labels）；主程序增量构建、八秒离屏冒烟通过，字体提示保持既有基线。未推送。

## 双按钮行（2026-11-05）

`DoubleButtonRow` 接收两个必填的 Qt `Action`：`firstAction` 和 `secondAction`。统一使用 8 像素间距、等宽按钮并占满所在布局行；调用方只提供文字、enabled 和 onTriggered，不另设按钮宽度或间距。不持有设备或增加业务状态。

```qml
DoubleButtonRow {
    firstAction: Action { text: qsTr("连接"); onTriggered: device.open(port) }
    secondAction: Action { text: qsTr("断开"); onTriggered: device.close() }
}
```

Windows Release 独立构建通过，CTest 3/3 通过，包含 Basic/Fluent 两种主题下长短文案、400/560 像素行宽、等宽/间距、动作调用和单侧禁用验证。证据：`build-labels/build-double-button.log`、`build-labels/test-double-button.log`。仅本地提交，未推送。

## 表单与读数（2026-11-05）

- `FormStyle` 统一标签宽度（普通 120 / 宽标签 160）、行距 6、列距 8、标题到读数间距 2。业务页用 `FieldRow.wideLabel` 选择宽标签，不再重复写尺寸。
- `FieldStrip.Col` 默认等权重；复合输入列用 `weight` 分配相对宽度。
- `ReadoutRow` 等宽排列 `Readout`，后者只接收 `caption` 和格式化后的 `text`，使用普通字重、Consolas 13 pt。不持有设备数据。
- `FormLabel` 统一单行省略和悬停全文；段落说明使用 HintText 统一换行。`DoubleButtonRow` 可为两侧动作分别提供提示文字。
- 型号参数、回报转换、输入草稿和状态仍由官邸管理；方向键、脉宽更新按钮及明确的组间留白不收成通用业务框架。

验证：独立 Windows Release 构建、CTest 3/3 通过，覆盖 Basic/Fluent 的 382/480 像素表单对齐、五列读数边界及长文字省略。


## 说明、信息行与连接布局（2026-11-05）

- `HintText`：浅色 9 pt 段落说明，按可用宽度换行，不以整段自然宽度撑开侧栏。
- `Subheading`：小标题字体及长文处理；外侧组间距由调用方指定。
- `ReadoutValue`：只接收格式化文字，统一普通字重的 Consolas 13 pt；Readout 内部复用，已有标题列可单独使用。
- `InfoRow`：caption/text 信息行，长值省略并悬停全文。compact 使用 40 像素名称列和 12 像素字体，普通档沿用表单名称列和应用字体。
- `ConnectionSection`：继承 Section，label 与默认 fields 构成选择行，两个必填 Action 构成等宽按钮行；选择行与按钮行统一使用公共 FormStyle.rowSpacing，不提供局部间距覆盖入口。调用方持有设备、选择值及全部连接/日志业务，组件不反向查询官邸。

Windows Release 独立构建及 CTest 3/3 通过，Basic/Fluent 均覆盖连接布局、外部 Action、信息行宽度及段落换行。证据 build-labels/layout-cleanup-{build,test}.log；未推送。

## 多行文字（2026-11-05）

FormLabel 默认仍是单行省略与悬停全文；multiline=true 按可用宽度换行，使用最小宽度 0、期望宽度 1，不以整段自然宽度撑开表单。字体和颜色沿用控件主题。HintText 复用此规则，再叠加说明文字的浅色和 9 pt；InfoRow.multiline 仅控制值列，名称列仍沿用 FormStyle。

Windows Release 增量构建和 CTest 3/3 通过；Basic/Fluent 覆盖 260/382/480 像素下多行正文、信息行边界、正常字号/颜色和单行/多行切换，原有连接布局与按钮测试继续通过。证据：build-labels/multiline-{build,test}.log。未推送。

## 滑块与路径复用（2026-11-05）

SliderField 的右侧文字复用 ReadoutValue 的普通字重、Consolas 13 pt、长文字省略和悬停规则，保留紧凑宽度 46 与右对齐，不参与额外宽度拉伸。吸附、松手提交和回读值行为不变。PathField 复用 FormLabel，保留中间省略、期望宽度 1、占位色和路径选择逻辑，删除重复悬停实现。DoubleButtonRow 的提示策略本轮不改。

Windows Release 增量构建与现有 CTest 3/3 通过，主程序集成构建及八秒冒烟通过。证据：build-labels/readout-path-{build,test}.log；仅本地提交，未推送。


## 空分组标题（2026-11-05）

WorkbenchWindow 按设备/任务名单是否为空显示对应组名。空组不计入最小标签栏宽度，组间16像素最小空隙仅在两组都有页面时保留；弹性空白仍保证设备左对齐、任务右对齐。页面、状态及所有权不变。
验证：主程序 Windows Release 增量构建、桌面八秒冒烟和四窗口全页面装配检查通过，截图确认空任务组标题隐藏。未连接硬件，未推送。
## 路径禁用输入框（2026-11-05）

PathField 的路径显示改用禁用 TextField，保留随主题变化的输入框外观、中间省略、悬停全文和浏览按钮；仅对话框可提交新路径，URL 值和业务持有关系不变。主程序 Windows Release 增量构建、桌面八秒冒烟及四窗口装配检查通过，运行日志无异常；未推送。
## 本机路径显示（2026-11-05）

PathField 默认从 value 转为本机路径，不展示 file:///。PathDisplay 使用 QUrl::toLocalFile 和 QDir::toNativeSeparators，正确解码中文、空格、百分号和共享路径；URL 仍是业务与对话框的唯一参数。禁用输入框、中间省略、悬停全文和浏览动作保持。

验证：2026-11-05 Windows Qt 6.11.2 / MSVC 增量构建通过；UICore CTest 3/3、ChartCore nonuniform 1/1、主程序八秒桌面冒烟及四窗装配通过。装配检查覆盖三规格、三通道的18张初始风速/CNR图的内部及分段门位悬停。未连接硬件、未推送。


### 2026-11-05 连接间距、累积默认值与径向风页面整理

ConnectionSection 删除 actionTopMargin，选择行与按钮行统一使用公共行距；串口与网口不再各自调节。UICore CTest 3/3通过。

主程序 Windows Release 增量构建、八秒桌面冒烟及四窗口装配检查通过；运行 stderr 为空，保留既有 CDL5/Qt 生成代码 C4702 编译警告。仅本地验证，未连接硬件、未推送。


### 2026-11-05 按钮气泡与布局复用

DoubleButtonRow 的两颗按钮各自持有独立 ToolTip，与路径/下拉框/文字一致，悬停400 ms显示、移出隐藏、timeout=-1；空提示不显示。动作和启用条件仍由调用方提供。UICore CTest 3/3通过。

主程序Windows Release增量构建、八秒桌面冒烟与四窗口装配检查通过，运行stderr为空。未连接硬件，仅本地提交、未推送。

## 字段分类与公共布局（2026-11-05 用户定）

只读项使用 Readout/ReadoutRow；仅设定项沿用 FieldStrip.Col；有回报的设定项使用 ReadoutField，按标题、回报、输入/操作纵向排列，并与 Readout 共用读数字重、长文字省略和悬停全文。ReadoutField 只提供布局与默认内容槽，不持有业务值、草稿、协议或提交动作。

温控、激光参数及转台四角定位已接入；温控和激光的型号/SN 放首排纵向读数。动作和非易失存储含义由官邸负责。

验证：Windows Release增量构建、UICore CTest 3/3、温控页面与串口专项1/1、激光QML专项1/1（128项检查）、主程序四窗装配及八秒冒烟通过；运行stderr为空。仅本地验证，未连接硬件、未推送。
