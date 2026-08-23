using System;
using System.Threading;
using System.Windows.Forms;

class CopyPath {
    [STAThread]
    static void Main(string[] args) {
        if (args.Length == 0) return;
        Clipboard.SetText(args[0]);
    }
}
