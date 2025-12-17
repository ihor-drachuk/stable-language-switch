# ==============================================================================
# Stable Language Switch - Uninstaller
# ==============================================================================
# This script removes the stable language switching solution
#
# What it does:
#   1. Stops any running language switch scripts
#   2. Removes installed files
#   3. Removes startup shortcuts
#   4. Optionally restores Windows system hotkey
#
# Usage: irm URL | iex
# ==============================================================================

param(
    [string]$GitHubUsername = "ihor-drachuk",
    [string]$RepoName = "stable-language-switch"
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== Stable Language Switch - Uninstaller ===" -ForegroundColor Cyan
Write-Host "Removing the language switching solution...`n" -ForegroundColor Gray

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
        # Using -EncodedCommand to avoid escaping issues with quotes and special characters
        $scriptUrl = "https://raw.githubusercontent.com/$GitHubUsername/$RepoName/master/uninstall.ps1"
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

$loggedInUser = $null
$userSID = $null

try {
    $loggedInUser = (Get-WmiObject -Class Win32_ComputerSystem).UserName

    if ($loggedInUser) {
        $userSID = (New-Object System.Security.Principal.NTAccount($loggedInUser)).Translate(
            [System.Security.Principal.SecurityIdentifier]
        ).Value
        Write-Host "[✓] Detected logged-in user: $loggedInUser" -ForegroundColor Green
    }
} catch {
    Write-Host "[!] Could not detect logged-in user, using current context" -ForegroundColor Yellow
}

# Build registry path
if ($userSID) {
    $registryPath = "Registry::HKEY_USERS\$userSID\Keyboard Layout\Toggle"
} else {
    $registryPath = "HKCU:\Keyboard Layout\Toggle"
}

# ==============================================================================
# 2. Stop Running Scripts
# ==============================================================================

Write-Host "`nStopping any running language switch scripts..." -ForegroundColor Gray

$stoppedCount = 0
$installDir = "$env:LOCALAPPDATA\StableLanguageSwitch"

# Read original hotkey file BEFORE deleting files
$savedOriginalHotkey = $null
$originalHotkeyFile = Join-Path $installDir "original_hotkey.txt"
if (Test-Path $originalHotkeyFile) {
    try {
        $savedOriginalHotkey = (Get-Content -Path $originalHotkeyFile -Raw).Trim()
    } catch { }
}

# Get all processes and check if they're running from our install directory
$allProcesses = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path }

foreach ($process in $allProcesses) {
    try {
        if ($process.Path -like "$installDir\*") {
            Stop-Process -Id $process.Id -Force -ErrorAction Stop
            $stoppedCount++
            Write-Host "    Stopped: $($process.Name)" -ForegroundColor Gray
        }
    } catch {
        # Process might have already exited or access denied
    }
}

# Also try to stop by known executable names (in case path detection fails)
$knownNames = @("Ctrl+Shift", "Alt+Shift", "CapsLock", "F1")
foreach ($name in $knownNames) {
    try {
        $proc = Get-Process -Name $name -ErrorAction SilentlyContinue
        if ($proc) {
            Stop-Process -Name $name -Force -ErrorAction SilentlyContinue
            $stoppedCount++
            Write-Host "    Stopped: $name" -ForegroundColor Gray
        }
    } catch {
        # Ignore
    }
}

# Give Windows time to release file handles
if ($stoppedCount -gt 0) {
    Start-Sleep -Milliseconds 500
    Write-Host "[✓] Stopped $stoppedCount running script(s)" -ForegroundColor Green
} else {
    Write-Host "[i] No running scripts found" -ForegroundColor Gray
}

# ==============================================================================
# 3. Remove Installed Files
# ==============================================================================

Write-Host "`nRemoving installed files..." -ForegroundColor Gray

$removedFiles = 0

if (Test-Path $installDir) {
    try {
        $files = Get-ChildItem -Path $installDir -File
        foreach ($file in $files) {
            Remove-Item -Path $file.FullName -Force
            $removedFiles++
        }

        # Remove directory if empty
        if ((Get-ChildItem -Path $installDir).Count -eq 0) {
            Remove-Item -Path $installDir -Force
        }

        Write-Host "[✓] Removed $removedFiles file(s) from: $installDir" -ForegroundColor Green
    } catch {
        Write-Host "[!] Warning: Could not remove some files" -ForegroundColor Yellow
        Write-Host "    Error: $_" -ForegroundColor Gray
    }
} else {
    Write-Host "[i] Installation directory not found" -ForegroundColor Gray
}

# ==============================================================================
# 4. Remove Startup Shortcuts
# ==============================================================================

Write-Host "`nRemoving startup shortcuts..." -ForegroundColor Gray

$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$shortcuts = @("Ctrl+Shift.lnk", "Alt+Shift.lnk", "F1.lnk", "CapsLock.lnk")
$removedShortcuts = 0

foreach ($shortcut in $shortcuts) {
    $shortcutPath = Join-Path $startupPath $shortcut
    if (Test-Path $shortcutPath) {
        try {
            Remove-Item -Path $shortcutPath -Force
            $removedShortcuts++
        } catch {
            Write-Host "[!] Warning: Could not remove: $shortcut" -ForegroundColor Yellow
        }
    }
}

if ($removedShortcuts -gt 0) {
    Write-Host "[✓] Removed $removedShortcuts startup shortcut(s)" -ForegroundColor Green
} else {
    Write-Host "[i] No startup shortcuts found" -ForegroundColor Gray
}

# ==============================================================================
# 5. Restore Windows Hotkey
# ==============================================================================

Write-Host "`nRestoring Windows keyboard layout switching hotkey..." -ForegroundColor Gray

$hotkeyValue = $null
$hotkeyName = $null

# Use previously read original hotkey value
if ($savedOriginalHotkey -eq "1" -or $savedOriginalHotkey -eq "2") {
    $hotkeyValue = $savedOriginalHotkey
    switch ($savedOriginalHotkey) {
        "1" { $hotkeyName = "Alt+Shift" }
        "2" { $hotkeyName = "Ctrl+Shift" }
    }
    Write-Host "[i] Found saved original hotkey: $hotkeyName" -ForegroundColor Gray
}

# If we couldn't determine the original hotkey, ask the user
if (-not $hotkeyValue) {
    Write-Host "[!] Could not determine your original hotkey setting." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Which hotkey would you like to restore?" -ForegroundColor Cyan
    Write-Host "  [1] Alt+Shift (most common)" -ForegroundColor White
    Write-Host "  [2] Ctrl+Shift" -ForegroundColor White
    Write-Host "  [3] Keep disabled (not recommended)" -ForegroundColor DarkGray
    Write-Host ""

    do {
        $choice = Read-Host "Enter your choice (1, 2, or 3)"

        switch ($choice) {
            "1" {
                $hotkeyValue = "1"
                $hotkeyName = "Alt+Shift"
            }
            "2" {
                $hotkeyValue = "2"
                $hotkeyName = "Ctrl+Shift"
            }
            "3" {
                $hotkeyValue = "3"
                $hotkeyName = "None (disabled)"
            }
            default {
                Write-Host "Invalid choice. Please enter 1, 2, or 3." -ForegroundColor Yellow
            }
        }
    } while (-not $hotkeyValue)
}

# ==============================================================================
# 6. Update Registry
# ==============================================================================

if ($hotkeyName -ne "None (disabled)") {
    Write-Host "Restoring Windows hotkey to: $hotkeyName..." -ForegroundColor Gray

    try {
        # Ensure registry path exists
        if (-not (Test-Path $registryPath)) {
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

        # Set hotkey value
        Set-ItemProperty -Path $registryPath -Name "Hotkey" -Value $hotkeyValue -Type String
        Set-ItemProperty -Path $registryPath -Name "Language Hotkey" -Value $hotkeyValue -Type String

        Write-Host "[✓] Windows hotkey restored to: $hotkeyName" -ForegroundColor Green
    } catch {
        Write-Host "[✗] ERROR: Failed to modify registry" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        Write-Host "`nYou can restore the hotkey manually:" -ForegroundColor Yellow
        Write-Host "  Settings → Time & Language → Typing → Advanced keyboard settings" -ForegroundColor Gray
        Write-Host "  → Input language hot keys → Change Key Sequence" -ForegroundColor Gray
    }
} else {
    Write-Host "[i] Windows hotkey left disabled" -ForegroundColor Gray
}

# ==============================================================================
# 7. Success Message
# ==============================================================================

Write-Host "`n=== Uninstallation Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "✓ Scripts stopped and removed" -ForegroundColor White
Write-Host "✓ Startup shortcuts removed" -ForegroundColor White
Write-Host "✓ Windows hotkey restored to: $hotkeyName" -ForegroundColor White
Write-Host ""
Write-Host "Thank you for trying Stable Language Switch!" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you experienced any issues or have feedback, please let us know:" -ForegroundColor Gray
Write-Host "  https://github.com/$GitHubUsername/$RepoName/issues" -ForegroundColor White
Write-Host ""
