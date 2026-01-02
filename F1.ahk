#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; Stable Language Switch - F1
; ==============================================================================
; Purpose: Reliable keyboard language switching using F1 key
;
; Note: This will override F1's default function (Help) in most applications.
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

F1:: {
    Send "#{Space}"
}
