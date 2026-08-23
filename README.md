# Copy File Path —— Windows 右键复制绝对路径

在 Windows 资源管理器里，右键点击任意**文件 / 文件夹 / 文件夹空白处**，菜单中会出现 **「Copy File Path」**，点击即可把该对象的**绝对路径**复制到剪贴板。毫秒级响应，无需联网，不依赖任何第三方库。

---

## 功能特性

- **三处触发**：文件、文件夹、文件夹空白处（空白处复制的是当前文件夹路径）。
- **绝对路径**：直接得到 `C:\Users\A\Projects\doc.txt` 这样的完整路径，方便粘贴到终端、IDE、聊天框。
- **零运行时开销**：路径由编译后的小程序直接写入系统剪贴板，不经过 `wscript` / `clip.exe` 等中间进程。
- **仅当前用户**：写入 `HKEY_CURRENT_USER`，安装**不需要管理员权限**。

---

## 环境要求 / 依赖

| 项目 | 说明 |
|------|------|
| 操作系统 | Windows 7 SP1 / 8 / 10 / 11（x64） |
| 运行库 | **.NET Framework 4.x**（Windows 自带，通常无需安装） |
| 第三方库 / 插件 | **无** |
| 网络 | **不需要**（完全离线） |
| 剪贴板 | 使用系统自带剪贴板 API（`System.Windows.Forms.Clipboard`） |
| 图标 | 使用系统内置资源 `imageres.dll,-5302`，无需额外文件 |

> 说明：`CopyPath.exe` 是一个 .NET Framework 的 Windows 程序（`winexe`）。现代 Windows 已预装 .NET Framework 4.x，因此下载后**双击即用**，无需任何前置安装。若极少数精简系统缺少 .NET Framework，需先安装 [.NET Framework 4.8](https://dotnet.microsoft.com/download/dotnet-framework)。

---

## 安装

### 方式一（最无脑，推荐）：一键安装脚本
双击 **`install.bat`**。它会自动把 `CopyPath.exe` 复制到 `%APPDATA%\CopyFilePath\CopyPath.exe`（右键真正调用的运行文件），并向注册表写入用户级右键菜单，无需管理员、无需联网。

> 若双击 `.bat` 提示「没有与之关联的应用」（个别机器 `.bat` 文件关联损坏），请用 `Win+R` 打开 `cmd`，输入 `"完整路径\install.bat"` 回车执行，或改用方式二手动安装。

### 方式二：手动安装
1. 把 `CopyPath.exe` 复制到 `%APPDATA%\CopyFilePath\CopyPath.exe`（`%APPDATA%` 即 `C:\Users\<你的用户名>\AppData\Roaming`）；
2. 双击 **`install.reg`** 合并到注册表（右键「合并」）。

> 安装后无需重启，直接右键即可看到菜单。

---

## 使用

在资源管理器中：
- 右键**文件** → `Copy File Path` → 复制该文件绝对路径；
- 右键**文件夹** → `Copy File Path` → 复制该文件夹绝对路径；
- 在文件夹内**空白处右键** → `Copy File Path` → 复制当前文件夹路径。

复制后即可 `Ctrl+V` 粘贴到任意需要路径的地方。

---

## 卸载

### 方式一（推荐）：一键卸载脚本
右键 **`uninstall.bat`** → **「以管理员身份运行」**。它会删除右键菜单（同时清理本机 `HKCU` 安装项与旧版可能残留的 `HKLM` / 32 位视图整键，不留空父键）、删除运行文件 `%APPDATA%\CopyFilePath`、重启资源管理器刷新菜单。

### 方式二：手动卸载
双击 **`uninstall.reg`** 合并（删注册表项，无需管理员即可清除本机 `HKCU` 项）。如需连运行文件一起删，手动删掉 `%APPDATA%\CopyFilePath` 文件夹即可。

> 若卸载后右键仍显示旧菜单，是资源管理器缓存，注销或重启电脑即可刷新。

---

## ⚠️ 重要：运行文件必须保留

安装后 `CopyPath.exe` 会常驻在 `%APPDATA%\CopyFilePath\`。**它是右键菜单实际调用的程序**，请勿删除该文件——否则菜单项仍会显示，但点击会报错（找不到程序）。正常卸载会一并清理它。

---

## 仓库文件清单

| 文件 | 作用 | 是否必须 |
|------|------|----------|
| `CopyPath.exe` | 右键菜单调用的运行程序（预编译） | ✅ 必需 |
| `CopyPath.cs` | `CopyPath.exe` 的对应源码 | 可选（重编译用） |
| `install.bat` | 一键安装脚本（推荐，免管理员） | ✅ 必需 |
| `uninstall.bat` | 一键卸载脚本（需管理员） | ✅ 必需 |
| `install.reg` | 注册表安装文件（手动备用） | 可选 |
| `uninstall.reg` | 注册表卸载文件（手动备用） | 可选 |
| `README.md` | 本说明 | — |
| `LICENSE` | MIT 许可 | — |

---

## 工作原理

1. 注册表在三类对象的上下文菜单下挂接 `CopyFilePath` 项，其 `command` 指向 `%APPDATA%\CopyFilePath\CopyPath.exe`，并把目标路径作为参数（`%1` 或 `%V`）传给它；
2. `CopyPath.exe` 收到路径参数后，调用系统剪贴板 API 将其写入剪贴板并退出。

整个过程是「注册表挂接 + 小程序直写剪贴板」，没有临时文件、没有管道、没有子进程轮询，因此响应很快。

---

## 从源码重新编译（可选）

如果你修改了 `CopyPath.cs`，可用系统自带的 C# 编译器重新生成 `CopyPath.exe`：

```
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe -nologo -target:winexe -out:CopyPath.exe CopyPath.cs
```

或使用任意 .NET SDK（`dotnet build`）。

---

## 许可

[MIT License](LICENSE) —— 可自由使用、修改、再分发。

## 致谢

实现思路参考了 [steelswing/copy-explorer-path](https://github.com/steelswing/copy-explorer-path)（纯原生 C++ 直写剪贴板的方案）。
