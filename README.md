# Stable Language Switch

Fix unreliable Windows keyboard language switching with instant, dependable hotkeys.

Built with [AutoHotkey](https://www.autohotkey.com/) v2.0

## The Problem

Windows built-in keyboard layout switching hotkeys (Ctrl+Shift, Alt+Shift) have a critical flaw: **they sometimes skip or miss your key presses**. You press the combination, but nothing happens. You have to press it again, disrupting your typing flow and causing constant frustration.

## The Solution

Replace Windows system hotkeys with AutoHotkey scripts that use direct `PostMessage` calls. These scripts intercept the key combinations and switch languages immediately, without Windows' unreliable handling.

## Choosing Your Hotkey

These scripts may override other hotkeys, so pick the one that works best for you:

- **Alt+Shift** (Recommended) - Popular choice with minimal conflicts. Works great for most users.
- **Ctrl+Shift** - Not recommended. Will block common shortcuts like Ctrl+Shift+T, Ctrl+Shift+S, Ctrl+Shift+F.
- **CapsLock** - Great option if you rarely use Caps Lock functionality.
- **F1** - Good choice if you don't rely on F1 for Help menus in applications.

## Benefits

1. ✅ **Reliable, instant language switching** - Never miss a hotkey press again
2. ✅ **Eliminates input lag** - Natural, responsive typing experience without fear or hesitation
3. ✅ **Multiple options** - Choose between Ctrl+Shift, Alt+Shift, F1, or CapsLock

## Quick Start

### Automatic Installation (Recommended)

One-line PowerShell command for automated setup.

```powershell
irm https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/main/install.ps1 | iex
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

   - **Recommended:** Download [`Alt+Shift.exe`](https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/main/Alt%2BShift.exe) (fewer conflicts with existing shortcuts)
   - Alternative: Download [`Ctrl+Shift.exe`](https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/main/Ctrl%2BShift.exe) (blocks Ctrl+Shift+[key] combinations)
   - Alternative: Download [`F1.exe`](https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/main/F1.exe) (single key press, but overrides F1 Help function)
   - Alternative: Download [`CapsLock.exe`](https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/main/CapsLock.exe) (single key press, but disables CapsLock functionality)

3. **Run the executable:**

   - Double-click the downloaded `.exe` file
   - You should see an AutoHotkey icon in your system tray

4. **Add to startup** (optional but recommended):

   - Press **Win+R**, type `shell:startup`, press **Enter**
   - Copy downloaded `.exe` file to the opened **Startup** folder
   - The script will now run automatically when Windows starts

## Uninstall

### Automatic Uninstall (recommended)

```powershell
irm https://raw.githubusercontent.com/ihor-drachuk/stable-language-switch/main/uninstall.ps1 | iex
```

### Manual Uninstall

1. Press **Win+R**, type `shell:startup`, press **Enter**
2. Remove downloaded `.exe` file from your Startup folder
3. Stop the running script (right-click green tray icon → Exit)
4. Re-enable Windows keyboard layout switching hotkey in Settings (reverse the steps from installation)

## How It Works

The scripts use AutoHotkey to capture key presses and send direct language switching commands.

**For key combinations** (Ctrl+Shift or Alt+Shift), the `&` operator captures all possible variants:

```autohotkey
LControl & LShift:: {
    PostMessage(0x50, 0x02, 0, , "A")  ; WM_INPUTLANGCHANGEREQUEST
}
```

**For single keys** (F1 or CapsLock), a simple hotkey definition:

```autohotkey
F1:: {
    PostMessage(0x50, 0x02, 0, , "A")  ; WM_INPUTLANGCHANGEREQUEST
}

CapsLock:: {
    PostMessage(0x50, 0x02, 0, , "A")  ; WM_INPUTLANGCHANGEREQUEST
}
```

Parameters:
- `0x50` = WM_INPUTLANGCHANGEREQUEST message
- `0x02` = INPUTLANGCHANGE_FORWARD (switch to next language)
- `"A"` = Send to active window

This bypasses Windows' language switching system entirely, eliminating both the unreliability and the input lag.

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contacts

Email: ihor-drachuk-libs@pm.me

## Acknowledgments

This project wouldn't exist without [AutoHotkey](https://www.autohotkey.com/), an amazing tool for Windows automation and scripting.
