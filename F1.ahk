#Requires AutoHotkey v2.0

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

F1:: {
    Send "#{Space}"
}
