// Installer.cs —— CopyFilePath 一键安装/卸载器
// 编译（在用户本机，无需 VS，用系统自带 csc 即可）：
//   C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /target:winexe /r:System.Windows.Forms.dll /out:Setup.exe Installer.cs
// 用法：
//   双击 Setup.exe            -> 安装（复制 exe 到 %APPDATA% + 写 HKCU 右键菜单）
//   Setup.exe /uninstall      -> 卸载（清 HKCU/HKLM/32位视图整键 + 删运行文件 + 刷新资源管理器）
//
// 设计要点（踩坑经验）：
// 1. 写入用户级 HKCU，免管理员即可安装、普通权限即可卸载，从根上避开 HKLM 权限坑。
// 2. 卸载删整键（DeleteSubKeyTree），不删 command 子键留空父键——否则右键残留报错按钮。
// 3. 运行文件常驻 %APPDATA%\CopyFilePath\，是右键真正执行的程序，卸载时才删。

using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;
using Microsoft.Win32;

class Installer
{
    const string AppName = "CopyFilePath";
    const string ExeName = "CopyPath.exe";
    static readonly string AppDir = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), AppName);
    static readonly string ExeDest = Path.Combine(AppDir, ExeName);

    // HKCU 下三个触发位置：文件(*)、文件夹(Directory)、文件夹空白处(Background)
    static readonly string[] Roots = new[]
    {
        @"Software\Classes\*\shell\CopyFilePath",
        @"Software\Classes\Directory\shell\CopyFilePath",
        @"Software\Classes\Directory\Background\shell\CopyFilePath"
    };

    [STAThread]
    static void Main(string[] args)
    {
        bool uninstall = args.Length > 0 &&
            (args[0].Equals("/uninstall", StringComparison.OrdinalIgnoreCase) ||
             args[0].Equals("-uninstall", StringComparison.OrdinalIgnoreCase) ||
             args[0].Equals("uninstall", StringComparison.OrdinalIgnoreCase));

        try
        {
            if (uninstall) DoUninstall();
            else DoInstall();
        }
        catch (Exception ex)
        {
            MessageBox.Show("操作失败：\n" + ex.Message, "CopyFilePath",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    static void DoInstall()
    {
        // 1) 把与本安装器同目录的 CopyPath.exe 复制到 %APPDATA% 常驻
        string src = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, ExeName);
        if (!File.Exists(src))
        {
            MessageBox.Show("未在同目录下找到 " + ExeName + "，无法安装。\n请保持整个文件夹完整。",
                "CopyFilePath", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }
        Directory.CreateDirectory(AppDir);
        File.Copy(src, ExeDest, true);

        // 2) 写入用户级 HKCU 三项右键菜单
        foreach (var root in Roots)
        {
            using (var k = Registry.CurrentUser.CreateSubKey(root))
            {
                k.SetValue(null, "Copy File Path");
                k.SetValue("Icon", "imageres.dll,-5302");
            }
            string cmdKey = root + "\\command";
            string arg = root.Contains("Background") ? "%V" : "%1";
            using (var ck = Registry.CurrentUser.CreateSubKey(cmdKey))
            {
                // 注意引号转义： "C:\...\CopyPath.exe" "%1"
                ck.SetValue(null, "\"" + ExeDest + "\" \"" + arg + "\"");
            }
        }

        MessageBox.Show("CopyFilePath 安装成功！\n\n右键任意文件 / 文件夹 / 文件夹空白处，\n菜单里会出现「Copy File Path」。",
            "CopyFilePath", MessageBoxButtons.OK, MessageBoxIcon.Information);
    }

    static void DoUninstall()
    {
        bool hklmOk = true;

        // 用户级（普通权限即可）
        foreach (var root in Roots) hklmOk &= DeleteTree(Registry.CurrentUser, root);

        // 机器级（需管理员；失败则记录，稍后提示）
        foreach (var root in Roots) hklmOk &= DeleteTree(Registry.LocalMachine, root);
        foreach (var root in Roots)
        {
            string wow = @"Software\WOW6432Node\Classes" + root.Substring(@"Software\Classes".Length);
            hklmOk &= DeleteTree(Registry.LocalMachine, wow);
        }

        // 删除常驻运行文件
        try { if (File.Exists(ExeDest)) File.Delete(ExeDest); } catch { }
        try
        {
            if (Directory.Exists(AppDir) && Directory.GetFiles(AppDir).Length == 0)
                Directory.Delete(AppDir);
        }
        catch { }

        // 重启资源管理器刷新右键菜单缓存
        try
        {
            foreach (var p in Process.GetProcessesByName("explorer"))
                p.Kill();
        }
        catch { }

        string msg = "CopyFilePath 卸载完成，右键菜单已清除。";
        if (!hklmOk)
            msg += "\n\n注意：HKLM 残留项需要以「管理员身份运行」Setup.exe /uninstall 才能清除。";
        MessageBox.Show(msg, "CopyFilePath", MessageBoxButtons.OK, MessageBoxIcon.Information);
    }

    // 返回 true=已删除/本不存在；false=无权限（需管理员）
    static bool DeleteTree(RegistryKey baseKey, string subKey)
    {
        try
        {
            baseKey.DeleteSubKeyTree(subKey, false);
            return true;
        }
        catch (UnauthorizedAccessException) { return false; }
        catch (System.Security.SecurityException) { return false; }
        catch (ArgumentException) { return true; } // 键不存在，视为已清
    }
}
