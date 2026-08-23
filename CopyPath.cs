using System;
using System.Threading;
using System.Windows.Forms;

class CopyPath {
    [STAThread]
    static void Main(string[] args) {
        if (args.Length == 0) return;

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
}
