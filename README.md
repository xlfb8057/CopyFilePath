# Copy File Path —— Windows 右键复制绝对路径

在 Windows 资源管理器里，右键点击任意**文件 / 文件夹 / 文件夹空白处**，菜单中会出现 **`Copy File Path`**，点击即可把该对象的**绝对路径**复制到剪贴板。毫秒级响应，无需联网，不依赖任何第三方库。

适合直接放到 GitHub 仓库或 Releases 给别人下载使用：解压后双击 `install.bat` 即可安装到当前用户，无需管理员权限。

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

> `install.bat` / `uninstall.bat` 使用 **GBK（中文 Windows 默认）编码**保存，可直接放在含中文的文件夹路径下双击运行。脚本仅调用系统自带的 `reg` 命令写入用户级注册表，**不依赖 PowerShell**。
>
> 若双击 `.bat` 提示「没有与之关联的应用」（个别机器 `.bat` 文件关联损坏），请用 `Win+R` 打开 `cmd`，输入 `"完整路径\install.bat"` 回车执行，或改用方式二手动安装。

> Windows 11 提醒：右键菜单可能默认折叠，`Copy File Path` 往往在 **“显示更多选项”** 里。

### 方式二：手动安装（无脚本）
1. 把 `CopyPath.exe` 复制到 `%APPDATA%\CopyFilePath\CopyPath.exe`（`%APPDATA%` 即 `C:\Users\<你的用户名>\AppData\Roaming`）；
2. 用 `regedit` 手动在 `HKCU:\Software\Classes\*\shell\CopyFilePath`（及 `Directory`、`Directory\Background` 两处）下建项，`command` 默认值设为 `"%APPDATA%\CopyFilePath\CopyPath.exe" "%1"`。

> 安装后无需重启，直接右键即可看到菜单。

---

## 使用

在资源管理器中：
- 右键**文件** → `Copy File Path` → 复制该文件绝对路径；
- 右键**文件夹** → `Copy File Path` → 复制该文件夹绝对路径；
- 在文件夹内**空白处右键** → `Copy File Path` → 复制当前文件夹路径。

复制后即可 `Ctrl+V` 粘贴到任意需要路径的地方。

如果点击菜单后没有立即复制成功，通常是剪贴板正被别的程序占用；当前版本会自动短暂重试几次，再失败时弹出提示框。

---

## 卸载

### 方式一（推荐）：一键卸载脚本
双击 **`uninstall.bat`** 即可（无需管理员，它只清理本机 `HKCU` 安装项与运行文件）。若你曾用旧版装过 `HKLM` 项，右键本文件「以管理员身份运行」可一并清除。

### 方式二：手动卸载（无脚本）
用 `regedit` 删除 `HKCU:\Software\Classes\*\shell\CopyFilePath`、`HKCU:\Software\Classes\Directory\Background\shell\CopyFilePath`、`HKCU:\Software\Classes\Directory\shell\CopyFilePath` 三项，再手动删掉 `%APPDATA%\CopyFilePath` 文件夹即可。

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
| `install.bat` | 一键安装脚本（推荐，免管理员，纯 reg 写入） | ✅ 必需 |
| `uninstall.bat` | 一键卸载脚本（免管理员，纯 reg 清理） | ✅ 必需 |
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

## 发布到 GitHub 前建议

如果你准备把这个仓库公开给别人直接下载使用，建议一起说明下面几点：

- **推荐发布 zip 包或 GitHub Release**：很多普通用户不会用 `git clone`，直接下载压缩包更省事。
- **Windows 11 用户要看“显示更多选项”**：否则容易误以为没安装成功。
- **未签名 exe 可能触发 SmartScreen 提示**：这是 Windows 对陌生二进制文件的常见提醒，不代表程序有问题，但会影响一部分用户的信任感。
- **依赖系统自带 .NET Framework 4.x**：绝大多数 Windows 10/11 都有，极少数精简系统可能需要单独安装。
- **`.bat` 文件关联损坏的机器无法直接双击脚本**：README 里已经给了备用安装方式。
- **上下文菜单名称目前固定为英文 `Copy File Path`**：如果目标用户以中文用户为主，可以考虑后续提供中英文两个发布分支或可切换文案。

---

## 许可

[MIT License](LICENSE) —— 可自由使用、修改、再分发。

## 致谢

实现思路参考了 [steelswing/copy-explorer-path](https://github.com/steelswing/copy-explorer-path)（纯原生 C++ 直写剪贴板的方案）。
