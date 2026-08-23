using System;
using Microsoft.Win32;
using System.Threading;
using System.Windows.Forms;

class CopyPath {
    private const string ChineseMenuText = "复制文件路径";
    private const string EnglishMenuText = "Copy File Path";

    [STAThread]
    static void Main(string[] args) {
        if (args.Length == 0) return;

        if (args[0] == "--install") {
            if (args.Length < 3) Environment.Exit(1);
            try {
                InstallContextMenu(args[1], GetMenuText(args[2]));
                return;
            } catch (Exception ex) {
                MessageBox.Show(
                    "Failed to install the context menu.\n\n" + ex.Message,
                    "Copy File Path",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
                Environment.Exit(1);
            }
        }

        for (int i = 0; i < 10; i++) {
            try {
                Clipboard.SetText(args[0]);
                return;
            } catch {
                Thread.Sleep(50);
            }
        }

        MessageBox.Show(
            "Failed to copy the path to the clipboard. Please try again.",
            "Copy File Path",
            MessageBoxButtons.OK,
            MessageBoxIcon.Error
        );
    }

    private static string GetMenuText(string language) {
        return string.Equals(language, "en", StringComparison.OrdinalIgnoreCase)
            ? EnglishMenuText
            : ChineseMenuText;
    }

    private static void InstallContextMenu(string exePath, string menuText) {
        WriteVerb(@"Software\Classes\*\shell\CopyFilePath", menuText, "\"" + exePath + "\" \"%1\"");
        WriteVerb(@"Software\Classes\Directory\shell\CopyFilePath", menuText, "\"" + exePath + "\" \"%1\"");
        WriteVerb(@"Software\Classes\Directory\Background\shell\CopyFilePath", menuText, "\"" + exePath + "\" \"%V\"");
    }

    private static void WriteVerb(string keyPath, string menuText, string command) {
        using (RegistryKey shellKey = Registry.CurrentUser.CreateSubKey(keyPath)) {
            if (shellKey == null) throw new InvalidOperationException("Failed to create registry key: " + keyPath);

            shellKey.SetValue(string.Empty, menuText, RegistryValueKind.String);
            shellKey.SetValue("Icon", "imageres.dll,-5302", RegistryValueKind.String);
        }

        using (RegistryKey commandKey = Registry.CurrentUser.CreateSubKey(keyPath + "\\command")) {
            if (commandKey == null) throw new InvalidOperationException("Failed to create registry command key: " + keyPath);
            commandKey.SetValue(string.Empty, command, RegistryValueKind.String);
        }
    }
}
