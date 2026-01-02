#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; Stable Language Switch - CapsLock
; ==============================================================================
; Purpose: Reliable keyboard language switching using CapsLock key
;
; Note: This will override CapsLock's default function (toggle caps).
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

CapsLock:: {
    Send "#{Space}"
}
