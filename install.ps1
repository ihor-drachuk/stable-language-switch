# ==============================================================================
# Stable Language Switch - Installer
# ==============================================================================
# This script automatically installs the stable language switching solution
#
# What it does:
#   1. Detects your current Windows language switching hotkey
#   2. Downloads the matching AutoHotkey executable
#   3. Disables the Windows system hotkey
#   4. Adds the script to startup
#   5. Launches the script immediately
#
# Usage: irm URL | iex
# ==============================================================================

param(
    [string]$GitHubUsername = "ihor-drachuk",
    [string]$RepoName = "stable-language-switch"
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== Stable Language Switch - Installer ===" -ForegroundColor Cyan
Write-Host "Fixing unreliable Windows keyboard language switching...`n" -ForegroundColor Gray

# ==============================================================================
# 1. Check for Administrator Privileges
# ==============================================================================

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host "ERROR: This script requires administrator privileges to modify registry settings." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again.`n" -ForegroundColor Yellow

    $elevated = Read-Host "Would you like to restart this script as Administrator? (Y/n)"
    if ($elevated -ne 'n' -and $elevated -ne 'N') {
        # When run via "irm | iex", we need to download again in the elevated process
        # Using -EncodedCommand to avoid escaping issues with quotes and special characters
        $scriptUrl = "https://raw.githubusercontent.com/$GitHubUsername/$RepoName/master/install.ps1"
        $command = "Set-ExecutionPolicy Bypass -Scope Process -Force; irm '$scriptUrl' | iex"
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -EncodedCommand $encodedCommand"
    }
    exit 1
}

Write-Host "[✓] Running with administrator privileges" -ForegroundColor Green

# ==============================================================================
# 2. Detect Current Windows Keyboard Layout Switching Hotkey
# ==============================================================================

Write-Host "`nDetecting your current Windows keyboard layout switching hotkey..." -ForegroundColor Gray

$registryPath = "HKCU:\Keyboard Layout\Toggle"
$currentHotkey = $null
$hotkeyName = "Unknown"

try {
    if (Test-Path $registryPath) {
        $hotkeyValue = Get-ItemProperty -Path $registryPath -Name "Hotkey" -ErrorAction SilentlyContinue
        if ($hotkeyValue) {
            $currentHotkey = $hotkeyValue.Hotkey
        }

        # Also check "Language Hotkey" value
        $langHotkeyValue = Get-ItemProperty -Path $registryPath -Name "Language Hotkey" -ErrorAction SilentlyContinue
        if ($langHotkeyValue -and -not $currentHotkey) {
            $currentHotkey = $langHotkeyValue.'Language Hotkey'
        }
    }

    # Interpret hotkey value
    switch ($currentHotkey) {
        "1" { $hotkeyName = "Alt+Shift" }
        "2" { $hotkeyName = "Ctrl+Shift" }
        "3" { $hotkeyName = "None (disabled)" }
        default { $hotkeyName = "Unknown" }
    }

    if ($hotkeyName -ne "Unknown" -and $hotkeyName -ne "None (disabled)") {
        Write-Host "[✓] Detected: $hotkeyName" -ForegroundColor Green
    } else {
        Write-Host "[i] Could not detect current hotkey (may not be configured)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[!] Warning: Could not read registry settings" -ForegroundColor Yellow
}

# ==============================================================================
# 3. Ask User Which Script to Install
# ==============================================================================

Write-Host "`nWhich hotkey combination would you like to use?" -ForegroundColor Cyan

if ($hotkeyName -eq "Ctrl+Shift" -or $hotkeyName -eq "Alt+Shift") {
    Write-Host "We detected you're currently using: $hotkeyName" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "  [1] Ctrl+Shift" -ForegroundColor White
Write-Host "      WARNING: Blocks Ctrl+Shift+T, Ctrl+Shift+N, etc." -ForegroundColor Yellow
Write-Host "  [2] Alt+Shift (Recommended)" -ForegroundColor Green
Write-Host "      Fewer conflicts with existing shortcuts" -ForegroundColor Gray
Write-Host "  [3] F1" -ForegroundColor White
Write-Host "      Single key press, but overrides F1 (Help) in applications" -ForegroundColor Gray
Write-Host "  [4] CapsLock" -ForegroundColor White
Write-Host "      Single key press, but disables CapsLock functionality" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Enter your choice (1, 2, 3, or 4)"

switch ($choice) {
    "1" {
        $scriptName = "Ctrl+Shift"
        $fileName = "Ctrl+Shift.exe"
    }
    "2" {
        $scriptName = "Alt+Shift"
        $fileName = "Alt+Shift.exe"
    }
    "3" {
        $scriptName = "F1"
        $fileName = "F1.exe"
    }
    "4" {
        $scriptName = "CapsLock"
        $fileName = "CapsLock.exe"
    }
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host "[✓] Selected: $scriptName" -ForegroundColor Green

# ==============================================================================
# 4. Download Chosen Executable from GitHub
# ==============================================================================

Write-Host "`nDownloading $fileName..." -ForegroundColor Gray

$installDir = "$env:LOCALAPPDATA\StableLanguageSwitch"
$installPath = Join-Path $installDir $fileName
$downloadUrl = "https://raw.githubusercontent.com/$GitHubUsername/$RepoName/master/bin/$fileName"

# Create installation directory
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# Download file
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installPath -UseBasicParsing
    Write-Host "[✓] Downloaded to: $installPath" -ForegroundColor Green
} catch {
    Write-Host "[✗] ERROR: Failed to download file" -ForegroundColor Red
    Write-Host "URL: $downloadUrl" -ForegroundColor Gray
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "`nPlease check:" -ForegroundColor Yellow
    Write-Host "  1. The repository exists and is public" -ForegroundColor Gray
    Write-Host "  2. The file exists in the repository" -ForegroundColor Gray
    Write-Host "  3. Your internet connection is working" -ForegroundColor Gray
    exit 1
}

# ==============================================================================
# 5. Disable Windows System Hotkey in Registry
# ==============================================================================

Write-Host "`nDisabling Windows keyboard layout switching hotkey..." -ForegroundColor Gray

try {
    # Ensure registry path exists
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Set hotkey to 3 (disabled)
    Set-ItemProperty -Path $registryPath -Name "Hotkey" -Value "3" -Type String
    Set-ItemProperty -Path $registryPath -Name "Language Hotkey" -Value "3" -Type String

    Write-Host "[✓] Windows system hotkey disabled" -ForegroundColor Green
} catch {
    Write-Host "[✗] ERROR: Failed to modify registry" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "`nYou may need to disable the hotkey manually:" -ForegroundColor Yellow
    Write-Host "  Settings → Time & Language → Typing → Advanced keyboard settings" -ForegroundColor Gray
    Write-Host "  → Input language hot keys → Change Key Sequence → Not Assigned" -ForegroundColor Gray
}

# ==============================================================================
# 6. Apply Registry Changes Without Reboot
# ==============================================================================

Write-Host "`nApplying changes..." -ForegroundColor Gray

# METHOD 1 (ACTIVE): Restart ctfmon.exe (Text Services Framework)
try {
    $ctfmonProcess = Get-Process -Name "ctfmon" -ErrorAction SilentlyContinue
    if ($ctfmonProcess) {
        Stop-Process -Name "ctfmon" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500
    }
    Start-Process "ctfmon.exe"
    Write-Host "[✓] Changes applied (restarted Text Services Framework)" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not restart ctfmon.exe" -ForegroundColor Yellow
    Write-Host "    Changes will take effect after you log off and log back in." -ForegroundColor Gray
}

# METHOD 2 (COMMENTED OUT): Broadcast WM_SETTINGCHANGE message
<#
try {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern IntPtr SendMessageTimeout(
            IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
            uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
    }
"@
    $HWND_BROADCAST = [IntPtr]0xffff
    $WM_SETTINGCHANGE = 0x1a
    $result = [UIntPtr]::Zero
    [Win32]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", 2, 5000, [ref]$result)
    Write-Host "[✓] Broadcast WM_SETTINGCHANGE message" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not broadcast settings change" -ForegroundColor Yellow
}
#>

# METHOD 3 (COMMENTED OUT): Inform user about logoff/reboot
<#
Write-Host "`nNote: Changes will take effect after you:" -ForegroundColor Yellow
Write-Host "  - Log off and log back in, or" -ForegroundColor Gray
Write-Host "  - Restart Windows" -ForegroundColor Gray
$logoffNow = Read-Host "`nWould you like to log off now? (y/N)"
if ($logoffNow -eq 'y' -or $logoffNow -eq 'Y') {
    Write-Host "Logging off in 5 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    logoff
}
#>

# ==============================================================================
# 7. Create Startup Shortcut
# ==============================================================================

Write-Host "`nAdding to Windows startup..." -ForegroundColor Gray

$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$shortcutPath = Join-Path $startupPath "$scriptName.lnk"

try {
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $installPath
    $shortcut.WorkingDirectory = $installDir
    $shortcut.Description = "Stable Language Switch - $scriptName"
    $shortcut.Save()

    Write-Host "[✓] Added to startup: $shortcutPath" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not create startup shortcut" -ForegroundColor Yellow
    Write-Host "    You can manually add it by pressing Win+R, typing 'shell:startup'," -ForegroundColor Gray
    Write-Host "    and copying the .exe file there." -ForegroundColor Gray
}

# ==============================================================================
# 8. Launch the Script
# ==============================================================================

Write-Host "`nLaunching $scriptName script..." -ForegroundColor Gray

try {
    Start-Process -FilePath $installPath
    Start-Sleep -Seconds 1
    Write-Host "[✓] Script is now running (check system tray for AutoHotkey icon)" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not launch script automatically" -ForegroundColor Yellow
    Write-Host "    Please run it manually: $installPath" -ForegroundColor Gray
}

# ==============================================================================
# 9. Success Message
# ==============================================================================

Write-Host "`n=== Installation Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "✓ $scriptName hotkey is now active" -ForegroundColor White
Write-Host "✓ Windows system hotkey disabled" -ForegroundColor White
Write-Host "✓ Added to startup (will run automatically on boot)" -ForegroundColor White
Write-Host ""
Write-Host "Try pressing $scriptName now - language switching should be instant and reliable!" -ForegroundColor Cyan
Write-Host ""
Write-Host "The script is running in the background. Look for the AutoHotkey icon" -ForegroundColor Gray
Write-Host "in your system tray (bottom-right corner)." -ForegroundColor Gray
Write-Host ""
Write-Host "To uninstall, run:" -ForegroundColor Gray
Write-Host "  irm https://raw.githubusercontent.com/$GitHubUsername/$RepoName/master/uninstall.ps1 | iex" -ForegroundColor White
Write-Host ""
