using System;
using Microsoft.Win32;
using System.Threading;
using System.Runtime.InteropServices;
using System.Windows.Forms;

class CopyPath {
    private const string ChineseMenuText = "复制文件路径";
    private const string EnglishMenuText = "Copy File Path";
    private const uint CfUnicodeText = 13;
    private static readonly IntPtr HGlobalZero = new IntPtr(0x0040);

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

        string errorMessage;
        if (TryCopyPath(args[0], out errorMessage)) {
            return;
        }

        MessageBox.Show(
            "Failed to copy the path to the clipboard.\n\n" + errorMessage,
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

    private static bool TryCopyPath(string text, out string errorMessage) {
        Exception lastError = null;

        for (int i = 0; i < 25; i++) {
            try {
                CopyUnicodeTextToClipboard(text);
                errorMessage = string.Empty;
                return true;
            } catch (Exception ex) {
                lastError = ex;
                Thread.Sleep(100);
            }
        }

        errorMessage = lastError == null
            ? "The clipboard stayed unavailable."
            : lastError.Message;
        return false;
    }

    private static void CopyUnicodeTextToClipboard(string text) {
        IntPtr memoryHandle = IntPtr.Zero;
        IntPtr lockedHandle = IntPtr.Zero;

        try {
            if (!OpenClipboard(IntPtr.Zero)) {
                throw new InvalidOperationException("The clipboard is busy. Close clipboard managers or try again.");
            }

            if (!EmptyClipboard()) {
                throw new InvalidOperationException("Windows refused to clear the clipboard.");
            }

            memoryHandle = GlobalAlloc(HGlobalZero, (UIntPtr)((text.Length + 1) * 2));
            if (memoryHandle == IntPtr.Zero) {
                throw new InvalidOperationException("Failed to allocate clipboard memory.");
            }

            lockedHandle = GlobalLock(memoryHandle);
            if (lockedHandle == IntPtr.Zero) {
                throw new InvalidOperationException("Failed to lock clipboard memory.");
            }

            Marshal.Copy((text + "\0").ToCharArray(), 0, lockedHandle, text.Length + 1);
            GlobalUnlock(memoryHandle);
            lockedHandle = IntPtr.Zero;

            if (SetClipboardData(CfUnicodeText, memoryHandle) == IntPtr.Zero) {
                throw new InvalidOperationException("Windows refused the clipboard text payload.");
            }

            memoryHandle = IntPtr.Zero;
        } finally {
            if (lockedHandle != IntPtr.Zero) {
                GlobalUnlock(memoryHandle);
            }

            if (memoryHandle != IntPtr.Zero) {
                GlobalFree(memoryHandle);
            }

            CloseClipboard();
        }
    }

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool OpenClipboard(IntPtr hWndNewOwner);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool CloseClipboard();

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool EmptyClipboard();

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr SetClipboardData(uint uFormat, IntPtr hMem);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GlobalAlloc(IntPtr uFlags, UIntPtr dwBytes);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GlobalLock(IntPtr hMem);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool GlobalUnlock(IntPtr hMem);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GlobalFree(IntPtr hMem);
}
