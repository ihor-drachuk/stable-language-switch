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
    Write-Host "WARNING: Running without administrator privileges." -ForegroundColor Yellow
    Write-Host "Registry changes require administrator rights. Files will still be removed.`n" -ForegroundColor Gray
}

# ==============================================================================
# 2. Stop Running Scripts
# ==============================================================================

Write-Host "Stopping any running language switch scripts..." -ForegroundColor Gray

$stoppedCount = 0

# Look for AutoHotkey processes running our scripts
$ahkProcesses = Get-Process -Name "AutoHotkey*", "Ctrl+Shift", "Alt+Shift", "F1", "CapsLock" -ErrorAction SilentlyContinue

foreach ($process in $ahkProcesses) {
    try {
        # Check if it's our script by looking at the command line or window title
        $processPath = $process.Path
        if ($processPath -like "*StableLanguageSwitch*" -or
            $processPath -like "*Ctrl+Shift.exe*" -or
            $processPath -like "*Alt+Shift.exe*" -or
            $processPath -like "*F1.exe*" -or
            $processPath -like "*CapsLock.exe*") {

            Stop-Process -Id $process.Id -Force
            $stoppedCount++
        }
    } catch {
        # Process might have already exited
    }
}

if ($stoppedCount -gt 0) {
    Write-Host "[✓] Stopped $stoppedCount running script(s)" -ForegroundColor Green
} else {
    Write-Host "[i] No running scripts found" -ForegroundColor Gray
}

# ==============================================================================
# 3. Remove Installed Files
# ==============================================================================

Write-Host "`nRemoving installed files..." -ForegroundColor Gray

$installDir = "$env:LOCALAPPDATA\StableLanguageSwitch"
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
# 5. Ask User About Restoring Windows Hotkey
# ==============================================================================

Write-Host "`nDo you want to restore the Windows keyboard layout switching hotkey?" -ForegroundColor Cyan
$restore = Read-Host "Restore Windows hotkey? (Y/n)"

if ($restore -ne 'n' -and $restore -ne 'N') {
    if (-not (Test-Administrator)) {
        Write-Host "[✗] ERROR: Administrator privileges required to modify registry" -ForegroundColor Red
        Write-Host "Please run this uninstaller as Administrator to restore the Windows hotkey.`n" -ForegroundColor Yellow
        Write-Host "Alternatively, you can restore it manually:" -ForegroundColor Gray
        Write-Host "  Settings → Time & Language → Typing → Advanced keyboard settings" -ForegroundColor Gray
        Write-Host "  → Input language hot keys → Change Key Sequence" -ForegroundColor Gray
    } else {
        Write-Host "`nWhich hotkey would you like to restore?" -ForegroundColor Cyan
        Write-Host "  [1] Ctrl+Shift" -ForegroundColor White
        Write-Host "  [2] Alt+Shift" -ForegroundColor White
        Write-Host "  [3] Keep disabled" -ForegroundColor White
        Write-Host ""

        $choice = Read-Host "Enter your choice (1, 2, or 3)"

        $hotkeyValue = "3" # Default: disabled
        $hotkeyName = "None"

        switch ($choice) {
            "1" {
                $hotkeyValue = "2"
                $hotkeyName = "Ctrl+Shift"
            }
            "2" {
                $hotkeyValue = "1"
                $hotkeyName = "Alt+Shift"
            }
            "3" {
                $hotkeyValue = "3"
                $hotkeyName = "None (disabled)"
            }
            default {
                Write-Host "Invalid choice. Keeping disabled." -ForegroundColor Yellow
            }
        }

        # ==============================================================================
        # 6. Update Registry
        # ==============================================================================

        if ($hotkeyName -ne "None (disabled)") {
            Write-Host "`nRestoring Windows hotkey to: $hotkeyName..." -ForegroundColor Gray

            $registryPath = "HKCU:\Keyboard Layout\Toggle"

            try {
                # Ensure registry path exists
                if (-not (Test-Path $registryPath)) {
                    New-Item -Path $registryPath -Force | Out-Null
                }

                # Set hotkey value
                Set-ItemProperty -Path $registryPath -Name "Hotkey" -Value $hotkeyValue -Type String
                Set-ItemProperty -Path $registryPath -Name "Language Hotkey" -Value $hotkeyValue -Type String

                Write-Host "[✓] Windows hotkey restored to: $hotkeyName" -ForegroundColor Green

                # ==============================================================================
                # 7. Apply Registry Changes
                # ==============================================================================

                Write-Host "`nApplying changes..." -ForegroundColor Gray

                # METHOD 1 (ACTIVE): Restart ctfmon.exe
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
    }
} else {
    Write-Host "[i] Windows hotkey left disabled" -ForegroundColor Gray
}

# ==============================================================================
# 8. Success Message
# ==============================================================================

Write-Host "`n=== Uninstallation Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "✓ Scripts stopped and removed" -ForegroundColor White
Write-Host "✓ Startup shortcuts removed" -ForegroundColor White

if ($restore -ne 'n' -and $restore -ne 'N' -and (Test-Administrator)) {
    Write-Host "✓ Windows hotkey settings updated" -ForegroundColor White
}

Write-Host ""
Write-Host "Thank you for trying Stable Language Switch!" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you experienced any issues or have feedback, please let us know:" -ForegroundColor Gray
Write-Host "  https://github.com/$GitHubUsername/$RepoName/issues" -ForegroundColor White
Write-Host ""
