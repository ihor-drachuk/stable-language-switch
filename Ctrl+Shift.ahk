#Requires AutoHotkey v2.0

; ==============================================================================
; Stable Language Switch - Ctrl+Shift
; ==============================================================================
; Purpose: Reliable keyboard language switching using Ctrl+Shift
;
; IMPORTANT LIMITATION:
;   - This script blocks Ctrl+Shift+[key] combinations
;   - This includes: Ctrl+Shift+C, Ctrl+Shift+V, Ctrl+Shift+T, Ctrl+Shift+S, Ctrl+Shift+F, etc.
;   - If you need these shortcuts, use Alt+Shift script instead
;
; License: MIT
; Repository: https://github.com/ihor-drachuk/stable-language-switch
; ==============================================================================

; Ctrl pressed first, then Shift
LControl & LShift:: {
    Send "#{Space}"
}

LControl & RShift:: {
    Send "#{Space}"
}

RControl & LShift:: {
    Send "#{Space}"
}

RControl & RShift:: {
    Send "#{Space}"
}

; Shift pressed first, then Ctrl
LShift & LControl:: {
    Send "#{Space}"
}

LShift & RControl:: {
    Send "#{Space}"
}

RShift & LControl:: {
    Send "#{Space}"
}

RShift & RControl:: {
    Send "#{Space}"
}
