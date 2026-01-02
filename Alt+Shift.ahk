#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; Stable Language Switch - Alt+Shift
; ==============================================================================
; Purpose: Reliable keyboard language switching using Alt+Shift
;
; License: MIT
; Repository: https://github.com/ihor-drachuk/stable-language-switch
; ==============================================================================

; ==============================================================================
; Auto-elevate to Administrator
; ==============================================================================
; Required to work with windows of apps running as Administrator
;
if !A_IsAdmin {
    try {
        Run '*RunAs "' A_ScriptFullPath '"'
    }
    ExitApp
}

; Alt pressed first, then Shift
LAlt & LShift:: {
    Send "#{Space}"
}

LAlt & RShift:: {
    Send "#{Space}"
}

RAlt & LShift:: {
    Send "#{Space}"
}

RAlt & RShift:: {
    Send "#{Space}"
}

; Shift pressed first, then Alt
LShift & LAlt:: {
    Send "#{Space}"
}

LShift & RAlt:: {
    Send "#{Space}"
}

RShift & LAlt:: {
    Send "#{Space}"
}

RShift & RAlt:: {
    Send "#{Space}"
}
