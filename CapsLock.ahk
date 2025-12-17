#Requires AutoHotkey v2.0
#Include LanguageSwitcher.ahk

; ==============================================================================
; Stable Language Switch - CapsLock (Modified)
; ==============================================================================
; Purpose: Reliable keyboard language switching using CapsLock key
;          This version respects the language order from Windows settings
;
; Note: This will override CapsLock's default function (toggle caps).
;
; License: MIT
; Repository: https://github.com/ihor-drachuk/stable-language-switch
; ==============================================================================

CapsLock:: {
    SwitchToNextLayout()
}
