# 日济 / Dayford

手机里的日记。界面中文名是日济，其他语言是 Dayford。0.1 只在这一台手机上写、存、封存，本机 AI 用假实现把每一种状态走通，不联网，也不下载真正的模型。

## 运行

```bash
flutter pub get
flutter run
```

Android `minSdk` 26，iOS 17。调试包里长按日期，可以打开 23 个界面状态。

## 结构

- `lib/domain` 日记日：本地时间 4:00 切日，周一到周日为一周。
- `lib/data` SQLite：正文、补写、封存后的回应。输入停一秒后自动保存，离开前台时再写一次。
- `lib/services` `AiService` 与 `ModelManager`。现在的实现不打开网络。
- `lib/ui` 只读主题 token。浅色默认素白，深色默认墨夜，跟随系统，切换颜色 300 毫秒。
- `lib/constants/model_catalog.dart` 集中放模型名字、体积和 6 GB 门槛，这些都是占位。

## 字体

界面文字用系统的 Noto Sans CJK（Android）或 PingFang（iOS）。日记正文打包 Noto Serif SC，许可证是 OFL，文件在 `assets/fonts/`。截图测试在 Android 平台上加载 `third_party/fonts/noto-sans-sc/`，不依赖机器里有没有这套字。

## 安卓

删除模型时，iOS 仍是系统操作菜单，Android 是 Material 底部弹窗，删除用主题里的砖红色。左上角返回保留，系统返回键和返回手势也能回去。状态栏颜色跟页面底色一致，图标深浅跟随主题。「写好了」那一排让出底部手势条的 inset。

## 测试

```bash
flutter analyze
flutter test
python3 tool/compare_shots.py
```

截图在 `docs/screenshots/0.1/`，和原型并排的图在 `docs/screenshots/0.1/compare/`。
