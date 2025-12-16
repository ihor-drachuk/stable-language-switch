#Requires AutoHotkey v2.0

; ==============================================================================
; Stable Language Switch - Ctrl+Shift
; ==============================================================================
; Purpose: Reliable keyboard language switching using Ctrl+Shift
;
; Problem: Windows built-in language switching hotkeys sometimes skip or miss
;          key combinations, causing frustration during typing.
;
; Solution: This script replaces the Windows system hotkey with a direct
;           PostMessage call (WM_INPUTLANGCHANGEREQUEST) that never misses.
;
; Features:
;   - Handles all 8 possible key combinations:
;     * Left Ctrl + Left Shift
;     * Left Ctrl + Right Shift
;     * Right Ctrl + Left Shift
;     * Right Ctrl + Right Shift
;     * Works regardless of which key is pressed first
;   - No input lag compared to Windows built-in switching
;   - Instant, reliable language switching
;
; IMPORTANT LIMITATION:
;   - This script blocks Ctrl+Shift+[key] combinations (e.g., Ctrl+Shift+T)
;   - If you need these shortcuts, use Alt+Shift script instead
;   - Alt+Shift has fewer conflicts with common application hotkeys
;
; Installation:
;   1. Disable Windows keyboard layout switching hotkey in Settings
;   2. Run this script or its compiled .exe
;   3. Add to startup folder for automatic startup
;
; License: MIT
; Repository: https://github.com/ihor-drachuk/stable-language-switch
; ==============================================================================

; Ctrl pressed first, then Shift
LControl & LShift:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

LControl & RShift:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

RControl & LShift:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

RControl & RShift:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

; Shift pressed first, then Ctrl
LShift & LControl:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

LShift & RControl:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

RShift & LControl:: {
    PostMessage(0x50, 0x02, 0, , "A")
}

RShift & RControl:: {
    PostMessage(0x50, 0x02, 0, , "A")
}
