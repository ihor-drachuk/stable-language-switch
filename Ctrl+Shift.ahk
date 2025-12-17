#Requires AutoHotkey v2.0
#Include LanguageSwitcher.ahk

; ==============================================================================
; Stable Language Switch - Ctrl+Shift
; ==============================================================================
; Purpose: Reliable keyboard language switching using Ctrl+Shift
;
; Features:
;   - Handles all 8 possible key combinations
;   - Respects the language order from Windows settings
;
; IMPORTANT LIMITATION:
;   - This script blocks Ctrl+Shift+[key] combinations (e.g., Ctrl+Shift+T)
;   - If you need these shortcuts, use Alt+Shift script instead
;
; License: MIT
; Repository: https://github.com/ihor-drachuk/stable-language-switch
; ==============================================================================

; Ctrl pressed first, then Shift
LControl & LShift:: {
    SwitchToNextLayout()
}

LControl & RShift:: {
    SwitchToNextLayout()
}

RControl & LShift:: {
    SwitchToNextLayout()
}

RControl & RShift:: {
    SwitchToNextLayout()
}

; Shift pressed first, then Ctrl
LShift & LControl:: {
    SwitchToNextLayout()
}

LShift & RControl:: {
    SwitchToNextLayout()
}

RShift & LControl:: {
    SwitchToNextLayout()
}

RShift & RControl:: {
    SwitchToNextLayout()
}
