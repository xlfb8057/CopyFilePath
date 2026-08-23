# Copy File Path —— Windows 右键复制绝对路径

在 Windows 资源管理器里，右键点击任意**文件 / 文件夹 / 文件夹空白处**，菜单中会出现 **`复制文件路径`**，点击即可把该对象的**绝对路径**复制到剪贴板。毫秒级响应，无需联网，不依赖任何第三方库。

适合直接放到 GitHub 仓库或 Releases 给别人下载使用：解压后双击 `install.bat` 即可安装到当前用户，无需管理员权限。若个别机器中文菜单名显示异常，还可以改用 `install-en.bat` 安装英文菜单名版本。

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
双击 **`install.bat`**。它会自动检查 **.NET Framework 4.x**、把 `CopyPath.exe` 复制到 `%APPDATA%\CopyFilePath\CopyPath.exe`（右键真正调用的运行文件），并向注册表写入用户级右键菜单，无需管理员、无需联网。

> `install.bat` / `install-en.bat` / `uninstall.bat` 都可以直接双击运行。安装脚本本身保持 ASCII 内容，中文菜单名由 `CopyPath.exe` 负责写入注册表，这样可以尽量避开批处理文件编码导致的乱码问题。
>
> 若双击 `.bat` 提示「没有与之关联的应用」（个别机器 `.bat` 文件关联损坏），请用 `Win+R` 打开 `cmd`，输入 `"完整路径\install.bat"` 回车执行，或改用方式二手动安装。

> Windows 11 提醒：右键菜单可能默认折叠，`复制文件路径` 往往在 **“显示更多选项”** 里。

### 方式一-B：一键安装英文菜单名版本
双击 **`install-en.bat`**。它的安装逻辑与 `install.bat` 相同，但菜单名会显示为 **`Copy File Path`**。如果个别机器显示中文菜单名异常，可以直接改用这个版本。

### 方式二：手动安装（无脚本）
1. 把 `CopyPath.exe` 复制到 `%APPDATA%\CopyFilePath\CopyPath.exe`（`%APPDATA%` 即 `C:\Users\<你的用户名>\AppData\Roaming`）；
2. 用 `regedit` 手动在 `HKCU:\Software\Classes\*\shell\CopyFilePath`（及 `Directory`、`Directory\Background` 两处）下建项，`command` 默认值设为 `"%APPDATA%\CopyFilePath\CopyPath.exe" "%1"`。

> 安装后无需重启，直接右键即可看到菜单。

---

## 使用

在资源管理器中：
- 右键**文件** → `复制文件路径` → 复制该文件绝对路径；
- 右键**文件夹** → `复制文件路径` → 复制该文件夹绝对路径；
- 在文件夹内**空白处右键** → `复制文件路径` → 复制当前文件夹路径。

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
| `install.bat` | 一键安装脚本（中文菜单名） | ✅ 推荐 |
| `install-en.bat` | 一键安装脚本（英文菜单名保底版） | 可选 |
| `uninstall.bat` | 一键卸载脚本（免管理员，纯 reg 清理） | ✅ 必需 |
| `README.md` | 本说明 | — |
| `LICENSE` | MIT 许可 | — |

---

## 工作原理

1. 安装时，`install.bat` 或 `install-en.bat` 会先检查 `.NET Framework 4.x`，再把 `CopyPath.exe` 复制到 `%APPDATA%\CopyFilePath\`；
2. 然后 `CopyPath.exe` 以安装模式写入三类右键菜单注册表项，并设置中文或英文菜单名；
3. 真正点击右键菜单时，`CopyPath.exe` 收到目标路径参数后，调用系统剪贴板 API 将其写入剪贴板并退出。

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
- **建议同时保留 `install.bat` 和 `install-en.bat`**：前者默认中文，后者是英文保底版本，适合排查个别机器的显示问题。

---

## 常见问题

### 1. 安装成功了，但右键菜单里看不到“复制文件路径”

先确认你右键的是文件、文件夹，或者文件夹空白处。

如果你使用的是 **Windows 11**，请先点击 **“显示更多选项”**，或者直接按 `Shift+F10`。当前版本使用的是传统桌面右键菜单接入方式，在 Windows 11 上通常显示在扩展菜单里，这是兼容行为，不是安装失败。

### 2. 右键菜单有了，但点击后没有复制成功

常见原因有这些：

- **剪贴板正被别的程序占用**：当前版本会自动短暂重试，仍然失败时会弹出错误提示。
- **系统缺少 .NET Framework 4.x**：安装脚本会直接弹出明确提示并停止安装。你可以安装 [.NET Framework 4.8 Runtime](https://dotnet.microsoft.com/download/dotnet-framework/net48) 后再试。
- **`CopyPath.exe` 被删除了**：右键菜单真正调用的是 `%APPDATA%\CopyFilePath\CopyPath.exe`，如果这个文件不在了，菜单会显示但无法工作。

### 3. 双击 `install.bat` 没反应，或者提示没有关联应用

这通常不是本工具本身的问题，而是你的系统里 `.bat` 文件关联损坏了。

可以这样安装：

1. 按 `Win + R`
2. 输入 `cmd`
3. 把 `install.bat` 拖进窗口，或手动输入它的完整路径
4. 回车执行

### 4. Windows 提示“不受信任的应用”或 SmartScreen 警告

这是因为仓库里的 `CopyPath.exe` 是未签名的本地小工具。对很多从 GitHub 下载的 Windows 可执行文件来说，这是常见现象，不代表程序本身一定有问题。

如果你是仓库维护者，后续可以考虑：

- 给 exe 做代码签名
- 在 GitHub Releases 里附带 SHA256 校验值
- 在 README 里解释工具用途和源码位置，降低用户顾虑

### 5. 中文菜单名显示成乱码

当前仓库已经把菜单名默认改成 **`复制文件路径`**，并且把中文写注册表的逻辑移到了 `CopyPath.exe` 里，尽量绕开了批处理编码问题。

建议：

- 直接使用仓库原版文件
- 如果个别机器仍然出现乱码，直接改用 `install-en.bat`
- 如果你自己二次修改过安装脚本，尽量不要随手改变文件编码

---

## 许可

[MIT License](LICENSE) —— 可自由使用、修改、再分发。

## 致谢

实现思路参考了 [steelswing/copy-explorer-path](https://github.com/steelswing/copy-explorer-path)（纯原生 C++ 直写剪贴板的方案）。
