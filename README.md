# Stable Language Switch

Fix unreliable Windows keyboard language switching with instant, dependable hotkeys.

Built with [AutoHotkey](https://www.autohotkey.com/) v2.0

## The Problem

Windows built-in keyboard layout switching hotkeys (Ctrl+Shift, Alt+Shift) have a critical flaw: **they sometimes skip or miss your key presses**. You press the combination, but nothing happens. You have to press it again, disrupting your typing flow and causing constant frustration.

## The Solution

Replace Windows system hotkeys with AutoHotkey scripts that remap your preferred hotkey to `Win+Space`, Windows' built-in language switching shortcut which works more stable in combination with this solution.

## Choosing Your Hotkey

These scripts may override other hotkeys, so pick the one that works best for you:

- **Alt+Shift** (Recommended) - Popular choice with minimal conflicts. Works great for most users.
- **Ctrl+Shift** - Not recommended. Will block common shortcuts like Ctrl+Shift+C, Ctrl+Shift+V, Ctrl+Shift+T, Ctrl+Shift+S, Ctrl+Shift+F.
- **CapsLock** - Great option if you rarely use Caps Lock functionality.
- **F1** - Good choice if you don't rely on F1 for Help menus in applications.

## Benefits

1. ✅ **Reliable, instant language switching** - Never miss a hotkey press again
2. ✅ **Multiple options** - Choose between Ctrl+Shift, Alt+Shift, F1, or CapsLock

## Quick Start

### Automatic Installation (Recommended)

One-line PowerShell command for automated setup.

```powershell
irm https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/master/install.ps1 | iex
```

### Manual Installation

1. **Disable Windows keyboard layout switching hotkey:**
   - Open **Settings** → **Time & Language** → **Typing** → **Advanced keyboard settings**
   - Click **"Input language hot keys"**
   - Select **"Between input languages"** and click **"Change Key Sequence..."**
   - Select **"Not Assigned"** for both options
   - Click **OK**

   *Note: Path may vary slightly between Windows 10/11 versions*

2. **Download your preferred hotkey script:**

   - **Recommended:** Download [`Alt+Shift.exe`](https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/master/bin/Alt%2BShift.exe) (fewer conflicts with existing shortcuts)
   - Alternative: Download [`Ctrl+Shift.exe`](https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/master/bin/Ctrl%2BShift.exe) (blocks Ctrl+Shift+[key] combinations like Ctrl+Shift+C, Ctrl+Shift+V, Ctrl+Shift+T, etc.)
   - Alternative: Download [`F1.exe`](https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/master/bin/F1.exe) (single key press, but overrides F1 Help function)
   - Alternative: Download [`CapsLock.exe`](https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/master/bin/CapsLock.exe) (single key press, but disables CapsLock functionality)

3. **Run the executable:**

   - Double-click the downloaded `.exe` file
   - You should see an AutoHotkey icon in your system tray

4. **Add to startup** (optional but recommended):

   - Press **Win+R**, type `shell:startup`, press **Enter**
   - Copy downloaded `.exe` file to the opened **Startup** folder
   - The script will now run automatically when Windows starts

## Uninstall

### If Installed via Automatic Script

Go to **Settings** → **Apps** → **Installed apps** and search for **"Stable Language Switch"**.

### If Installed Manually

Uninstall manually by reversing the installation steps:

1. **Stop the running script:**
   - Right-click the AutoHotkey icon in the system tray and select **Exit**

2. **Remove from startup:**
   - Press **Win+R**, type `shell:startup`, press **Enter**
   - Delete the `.exe` file from the **Startup** folder

3. **Re-enable Windows hotkey** (optional):
   - Open **Settings** → **Time & Language** → **Typing** → **Advanced keyboard settings**
   - Click **"Input language hot keys"**
   - Select **"Between input languages"** and click **"Change Key Sequence..."**
   - Select your preferred hotkey (Alt+Shift or Ctrl+Shift)
   - Click **OK**

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contacts

Email: ihor-drachuk-libs@pm.me

## Acknowledgments

This project wouldn't exist without [AutoHotkey](https://www.autohotkey.com/), an amazing tool for Windows automation and scripting.
