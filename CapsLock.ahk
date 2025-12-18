#Requires AutoHotkey v2.0

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

CapsLock:: {
    Send "#{Space}"
}
