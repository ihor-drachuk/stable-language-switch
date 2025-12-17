#Requires AutoHotkey v2.0
#Include LanguageSwitcher.ahk

; ==============================================================================
; Stable Language Switch - Alt+Shift
; ==============================================================================
; Purpose: Reliable keyboard language switching using Alt+Shift
;
; Features:
;   - Handles all 8 possible key combinations
;   - Respects the language order from Windows settings
;
; License: MIT
; Repository: https://github.com/ihor-drachuk/stable-language-switch
; ==============================================================================

; Alt pressed first, then Shift
LAlt & LShift:: {
    SwitchToNextLayout()
}

LAlt & RShift:: {
    SwitchToNextLayout()
}

RAlt & LShift:: {
    SwitchToNextLayout()
}

RAlt & RShift:: {
    SwitchToNextLayout()
}

; Shift pressed first, then Alt
LShift & LAlt:: {
    SwitchToNextLayout()
}

LShift & RAlt:: {
    SwitchToNextLayout()
}

RShift & LAlt:: {
    SwitchToNextLayout()
}

RShift & RAlt:: {
    SwitchToNextLayout()
}
