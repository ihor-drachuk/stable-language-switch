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
# 1.5. Determine Logged-In User's Registry Path
# ==============================================================================
# When running as admin, HKCU may point to a different user's registry.
# We need to find the actual logged-in user and access their registry directly.

$loggedInUser = $null
$userSID = $null

try {
    # Get the currently logged-in user (the one with the active desktop session)
    $loggedInUser = (Get-WmiObject -Class Win32_ComputerSystem).UserName

    if ($loggedInUser) {
        # Convert username to SID
        $userSID = (New-Object System.Security.Principal.NTAccount($loggedInUser)).Translate(
            [System.Security.Principal.SecurityIdentifier]
        ).Value
        Write-Host "[✓] Detected logged-in user: $loggedInUser" -ForegroundColor Green
    }
} catch {
    Write-Host "[!] Could not detect logged-in user, using current context" -ForegroundColor Yellow
}

# Build registry path - use HKU with SID if available, otherwise fall back to HKCU
if ($userSID) {
    $registryPath = "Registry::HKEY_USERS\$userSID\Keyboard Layout\Toggle"
} else {
    $registryPath = "HKCU:\Keyboard Layout\Toggle"
}

# ==============================================================================
# 2. Detect Current Windows Keyboard Layout Switching Hotkey
# ==============================================================================

Write-Host "`nDetecting your current Windows keyboard layout switching hotkey..." -ForegroundColor Gray
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
    Write-Host "Detected current hotkey: $hotkeyName" -ForegroundColor Gray
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
# 3.5. Stop and Remove Previous Installation
# ==============================================================================

$installDir = "$env:LOCALAPPDATA\StableLanguageSwitch"

# Stop any running scripts from previous installation
$stoppedCount = 0
$allProcesses = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path }

foreach ($process in $allProcesses) {
    try {
        if ($process.Path -like "$installDir\*") {
            Stop-Process -Id $process.Id -Force -ErrorAction Stop
            $stoppedCount++
        }
    } catch {
        # Process might have already exited
    }
}

# Also try known names
$knownNames = @("Ctrl+Shift", "Alt+Shift")
foreach ($name in $knownNames) {
    try {
        $proc = Get-Process -Name $name -ErrorAction SilentlyContinue
        if ($proc) {
            Stop-Process -Name $name -Force -ErrorAction SilentlyContinue
            $stoppedCount++
        }
    } catch { }
}

if ($stoppedCount -gt 0) {
    Start-Sleep -Milliseconds 500
    Write-Host "[i] Stopped $stoppedCount previous script(s)" -ForegroundColor Gray
}

# Remove old executables
if (Test-Path $installDir) {
    $oldFiles = Get-ChildItem -Path $installDir -Filter "*.exe" -ErrorAction SilentlyContinue
    foreach ($file in $oldFiles) {
        try {
            Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
        } catch { }
    }
}

# Remove old startup shortcuts
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$oldShortcuts = @("Ctrl+Shift.lnk", "Alt+Shift.lnk", "F1.lnk", "CapsLock.lnk")
foreach ($shortcut in $oldShortcuts) {
    $shortcutPath = Join-Path $startupPath $shortcut
    if (Test-Path $shortcutPath) {
        Remove-Item -Path $shortcutPath -Force -ErrorAction SilentlyContinue
    }
}

# ==============================================================================
# 4. Download Chosen Executable from GitHub
# ==============================================================================

Write-Host "`nDownloading $fileName..." -ForegroundColor Gray
$installPath = Join-Path $installDir $fileName
$downloadUrl = "https://raw.githubusercontent.com/$GitHubUsername/$RepoName/master/bin/$fileName"

# Create installation directory
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# Save original hotkey for later restoration during uninstall
# Don't overwrite if file already exists (reinstall scenario)
$originalHotkeyFile = Join-Path $installDir "original_hotkey.txt"
if (-not (Test-Path $originalHotkeyFile)) {
    if ($currentHotkey -and $currentHotkey -ne "3") {
        # Only save if we detected a valid hotkey (not disabled)
        try {
            $currentHotkey | Out-File -FilePath $originalHotkeyFile -Encoding UTF8 -NoNewline
        } catch {
            Write-Host "[!] Warning: Could not save original hotkey setting" -ForegroundColor Yellow
        }
    }
}

# Download executable
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installPath -UseBasicParsing
    Write-Host "[✓] Downloaded: $fileName" -ForegroundColor Green
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

# Download uninstall script (for Add/Remove Programs)
# Use DownloadFile to preserve exact bytes (assuming file has BOM)
$uninstallScriptPath = Join-Path $installDir "uninstall.ps1"
$uninstallScriptUrl = "https://raw.githubusercontent.com/$GitHubUsername/$RepoName/master/uninstall.ps1"
try {
    (New-Object System.Net.WebClient).DownloadFile($uninstallScriptUrl, $uninstallScriptPath)
    Write-Host "[✓] Downloaded: uninstall.ps1" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not download uninstall script" -ForegroundColor Yellow
}

# ==============================================================================
# 5. Disable Windows System Hotkey in Registry
# ==============================================================================

Write-Host "`nDisabling Windows keyboard layout switching hotkey..." -ForegroundColor Gray

try {
    # Ensure registry path exists
    if (-not (Test-Path $registryPath)) {
        # For Registry:: paths, we need to create parent path first
        if ($userSID) {
            $parentPath = "Registry::HKEY_USERS\$userSID\Keyboard Layout"
            if (-not (Test-Path $parentPath)) {
                New-Item -Path $parentPath -Force | Out-Null
            }
            New-Item -Path $registryPath -Force | Out-Null
        } else {
            New-Item -Path $registryPath -Force | Out-Null
        }
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
# 7. Create Startup Shortcut
# ==============================================================================

Write-Host "`nAdding to Windows startup..." -ForegroundColor Gray

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
# 8. Register in Add/Remove Programs
# ==============================================================================

Write-Host "`nRegistering in Add/Remove Programs..." -ForegroundColor Gray

$uninstallRegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\StableLanguageSwitch"
$uninstallScriptPath = Join-Path $installDir "uninstall.ps1"

# Simple approach: run PowerShell
# The script will handle its own elevation via the built-in elevation prompt
$uninstallCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$uninstallScriptPath`""

try {
    # Create registry key
    if (-not (Test-Path $uninstallRegPath)) {
        New-Item -Path $uninstallRegPath -Force | Out-Null
    }

    # Set values
    Set-ItemProperty -Path $uninstallRegPath -Name "DisplayName" -Value "Stable Language Switch" -Type String
    Set-ItemProperty -Path $uninstallRegPath -Name "UninstallString" -Value $uninstallCommand -Type String
    Set-ItemProperty -Path $uninstallRegPath -Name "DisplayIcon" -Value $installPath -Type String
    Set-ItemProperty -Path $uninstallRegPath -Name "Publisher" -Value "Ihor Drachuk" -Type String
    Set-ItemProperty -Path $uninstallRegPath -Name "DisplayVersion" -Value "1.1" -Type String
    Set-ItemProperty -Path $uninstallRegPath -Name "InstallLocation" -Value $installDir -Type String
    Set-ItemProperty -Path $uninstallRegPath -Name "URLInfoAbout" -Value "https://github.com/$GitHubUsername/$RepoName" -Type String
    Set-ItemProperty -Path $uninstallRegPath -Name "HelpLink" -Value "https://github.com/$GitHubUsername/$RepoName" -Type String
    Set-ItemProperty -Path $uninstallRegPath -Name "NoModify" -Value 1 -Type DWord
    Set-ItemProperty -Path $uninstallRegPath -Name "NoRepair" -Value 1 -Type DWord

    Write-Host "[✓] Registered in Add/Remove Programs" -ForegroundColor Green
} catch {
    Write-Host "[!] Warning: Could not register in Add/Remove Programs" -ForegroundColor Yellow
}

# ==============================================================================
# 9. Launch the Script
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
# 10. Success Message
# ==============================================================================

Write-Host "`n=== Installation Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "✓ $scriptName hotkey is now active" -ForegroundColor White
Write-Host "✓ Windows system hotkey disabled" -ForegroundColor White
Write-Host "✓ Added to startup (will run automatically on boot)" -ForegroundColor White
Write-Host "✓ Can be uninstalled via Settings → Apps" -ForegroundColor White
Write-Host ""
Write-Host "Try pressing $scriptName now - language switching should be instant and reliable!" -ForegroundColor Cyan
Write-Host ""
Write-Host "The script is running in the background. Look for the AutoHotkey icon" -ForegroundColor Gray
Write-Host "in your system tray (bottom-right corner)." -ForegroundColor Gray
Write-Host ""
Write-Host "To uninstall, go to Settings → Apps → Installed apps" -ForegroundColor Gray
Write-Host "and search for 'Stable Language Switch'." -ForegroundColor White
Write-Host ""
Write-Host "Press Enter to close this window..." -ForegroundColor DarkGray
Read-Host | Out-Null
