using System;
using System.Collections.Generic;
using System.IO;
using Microsoft.Win32;
using System.Text;
using System.Threading;
using System.Runtime.InteropServices;
using System.Windows.Forms;

class CopyPath {
    private const string ChineseMenuText = "复制文件路径";
    private const string EnglishMenuText = "Copy File Path";
    private const uint CfUnicodeText = 13;
    private const uint GmemMoveableZeroInit = 0x0042;
    private const int MultiSelectQuietMs = 350;
    private const int MultiSelectMaxWaitMs = 3000;
    private const int StalePendingFileSeconds = 10;
    private static readonly string PendingPathsFile = Path.Combine(
        Path.GetTempPath(),
        "CopyFilePath.pending.txt"
    );

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
        if (TryCopyPaths(args, out errorMessage)) {
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
            shellKey.SetValue("MultiSelectModel", "Player", RegistryValueKind.String);
        }

        using (RegistryKey commandKey = Registry.CurrentUser.CreateSubKey(keyPath + "\\command")) {
            if (commandKey == null) throw new InvalidOperationException("Failed to create registry command key: " + keyPath);
            commandKey.SetValue(string.Empty, command, RegistryValueKind.String);
        }
    }

    private static bool TryCopyPaths(string[] paths, out string errorMessage) {
        string textToCopy = JoinPaths(paths);

        if (paths.Length == 1) {
            try {
                textToCopy = CollectPathsForThisSelection(paths);
            } catch (Exception ex) {
                errorMessage = "Failed to prepare the selected paths.\n\n" + ex.Message;
                return false;
            }
        }

        if (string.IsNullOrEmpty(textToCopy)) {
            errorMessage = string.Empty;
            return true;
        }

        Exception lastError = null;

        for (int i = 0; i < 25; i++) {
            try {
                CopyUnicodeTextToClipboard(textToCopy);
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

    private static string CollectPathsForThisSelection(string[] paths) {
        bool shouldCopy;

        using (Mutex mutex = new Mutex(false, @"Local\CopyFilePathPendingPaths")) {
            WaitForMutex(mutex);
            try {
                DeleteStalePendingPathsFile();
                File.AppendAllLines(PendingPathsFile, paths, Encoding.UTF8);
            } finally {
                mutex.ReleaseMutex();
            }

            WaitForPendingFileToSettle();

            WaitForMutex(mutex);
            try {
                shouldCopy = File.Exists(PendingPathsFile);
                if (!shouldCopy) return string.Empty;
                string[] pendingPaths = File.ReadAllLines(PendingPathsFile, Encoding.UTF8);
                File.Delete(PendingPathsFile);
                return JoinPaths(pendingPaths);
            } finally {
                mutex.ReleaseMutex();
            }
        }
    }

    private static void WaitForPendingFileToSettle() {
        DateTime deadline = DateTime.UtcNow.AddMilliseconds(MultiSelectMaxWaitMs);
        DateTime lastWriteTime = File.GetLastWriteTimeUtc(PendingPathsFile);

        while (DateTime.UtcNow < deadline) {
            Thread.Sleep(MultiSelectQuietMs);

            if (!File.Exists(PendingPathsFile)) return;

            DateTime currentWriteTime = File.GetLastWriteTimeUtc(PendingPathsFile);
            if (currentWriteTime == lastWriteTime) return;
            lastWriteTime = currentWriteTime;
        }
    }

    private static void DeleteStalePendingPathsFile() {
        if (!File.Exists(PendingPathsFile)) return;

        DateTime staleBefore = DateTime.UtcNow.AddSeconds(-StalePendingFileSeconds);
        if (File.GetLastWriteTimeUtc(PendingPathsFile) < staleBefore) {
            File.Delete(PendingPathsFile);
        }
    }

    private static void WaitForMutex(Mutex mutex) {
        if (!mutex.WaitOne(5000)) {
            throw new TimeoutException("Timed out while waiting for another copy operation to finish.");
        }
    }

    private static string JoinPaths(string[] paths) {
        List<string> result = new List<string>();

        foreach (string path in paths) {
            if (string.IsNullOrWhiteSpace(path)) continue;
            result.Add(path);
        }

        return string.Join(Environment.NewLine, result.ToArray());
    }

    private static void CopyUnicodeTextToClipboard(string text) {
        IntPtr memoryHandle = IntPtr.Zero;
        IntPtr lockedHandle = IntPtr.Zero;
        bool clipboardOpened = false;

        try {
            if (!OpenClipboard(IntPtr.Zero)) {
                throw new InvalidOperationException("The clipboard is busy. Close clipboard managers or try again.");
            }
            clipboardOpened = true;

            if (!EmptyClipboard()) {
                throw new InvalidOperationException("Windows refused to clear the clipboard.");
            }

            memoryHandle = GlobalAlloc(GmemMoveableZeroInit, (UIntPtr)((text.Length + 1) * 2));
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

            if (clipboardOpened) {
                CloseClipboard();
            }
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
    private static extern IntPtr GlobalAlloc(uint uFlags, UIntPtr dwBytes);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GlobalLock(IntPtr hMem);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool GlobalUnlock(IntPtr hMem);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GlobalFree(IntPtr hMem);
}
