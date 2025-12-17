#Requires AutoHotkey v2.0
#Include LanguageSwitcher.ahk

; ==============================================================================
; Stable Language Switch - F1
; ==============================================================================
; Purpose: Reliable keyboard language switching using F1 key
;
; Features:
;   - Single key press (F1) for language switching
;   - Respects the language order from Windows settings
;
; Note: This will override F1's default function (Help) in most applications.
;
; License: MIT
; Repository: https://github.com/ihor-drachuk/stable-language-switch
; ==============================================================================

F1:: {
    SwitchToNextLayout()
}
