#Requires AutoHotkey v2.0

; ==============================================================================
; Stable Language Switch - CapsLock
; ==============================================================================
; Purpose: Reliable keyboard language switching using CapsLock key
;
; Problem: Windows built-in language switching hotkeys sometimes skip or miss
;          key combinations, causing frustration during typing.
;
; Solution: This script replaces the Windows system hotkey with a direct
;           PostMessage call (WM_INPUTLANGCHANGEREQUEST) that never misses.
;
; Features:
;   - Single key press (CapsLock) for language switching
;   - No input lag compared to Windows built-in switching
;   - Instant, reliable language switching
;   - No conflicts with key combinations
;
; Note: This will override CapsLock's default function (toggle caps).
;       You won't be able to use CapsLock for uppercase typing.
;       Consider this trade-off before using this script.
;
; Installation:
;   1. Disable Windows keyboard layout switching hotkey in Settings
;   2. Run this script or its compiled .exe
;   3. Add to startup folder for automatic startup
;
; License: MIT
; Repository: https://github.com/ihor-drachuk/stable-language-switch
; ==============================================================================

CapsLock:: {
    PostMessage(0x50, 0x02, 0, , "A")
}
