#Requires AutoHotkey v2.0

; ==============================================================================
; Stable Language Switch - Alt+Shift
; ==============================================================================
; Purpose: Reliable keyboard language switching using Alt+Shift
;
; Problem: Windows built-in language switching hotkeys sometimes skip or miss
;          key combinations, causing frustration during typing.
;
; Solution: This script replaces the Windows system hotkey with a direct
;           PostMessage call (WM_INPUTLANGCHANGEREQUEST) that never misses.
;
; Features:
;   - Handles all 8 possible key combinations:
;     * Left Alt + Left Shift
;     * Left Alt + Right Shift
;     * Right Alt + Left Shift
;     * Right Alt + Right Shift
;     * Works regardless of which key is pressed first
;   - No input lag compared to Windows built-in switching
;   - Instant, reliable language switching
;
; Installation:
;   1. Disable Windows keyboard layout switching hotkey in Settings
;   2. Run this script or its compiled .exe
;   3. Add to startup folder for automatic startup
;
; License: MIT
; Repository: https://github.com/ihor-drachuk/stable-language-switch
; ==============================================================================

; Alt pressed first, then Shift
LAlt & LShift:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

LAlt & RShift:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

RAlt & LShift:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

RAlt & RShift:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

; Shift pressed first, then Alt
LShift & LAlt:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

LShift & RAlt:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

RShift & LAlt:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

RShift & RAlt:: {
    PostMessage(0x50, 0x02, 0, , "A")
}
