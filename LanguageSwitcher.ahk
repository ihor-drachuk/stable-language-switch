#Requires AutoHotkey v2.0

; ==============================================================================
; Language Switcher Module
; ==============================================================================
; Shared module for keyboard language switching scripts.
; Reads language order from Windows registry (CTF\SortOrder\Language)
; to match the order shown in Windows Settings UI.
;
; Usage: #Include LanguageSwitcher.ahk
;        Then call SwitchToNextLayout() from your hotkey
;
; License: MIT
; Repository: https://github.com/ihor-drachuk/stable-language-switch
; ==============================================================================

global layouts := []

; ==============================================================================
; Load keyboard layouts from Windows registry in the correct order
; ==============================================================================
LoadLayoutOrder() {
    global layouts
    layouts := []

    count := DllCall("GetKeyboardLayoutList", "Int", 0, "Ptr", 0)
    if (count = 0)
        return

    bufferSize := count * A_PtrSize
    hklBuffer := Buffer(bufferSize)
    DllCall("GetKeyboardLayoutList", "Int", count, "Ptr", hklBuffer)

    ; Build a map of LanguageID -> HKL for quick lookup
    hklMap := Map()
    Loop count {
        offset := (A_Index - 1) * A_PtrSize
        hkl := NumGet(hklBuffer, offset, "Ptr")
        langId := hkl & 0xFFFF
        hklMap[langId] := hkl
    }

    ; Read the correct order from CTF\SortOrder\Language registry
    regPath := "HKEY_CURRENT_USER\Software\Microsoft\CTF\SortOrder\Language"

    index := 0
    Loop {
        regKey := Format("{:08d}", index)
        try {
            layoutIdStr := RegRead(regPath, regKey)
            layoutId := Integer("0x" . layoutIdStr)
            langId := layoutId & 0xFFFF
            if (hklMap.Has(langId))
                layouts.Push(hklMap[langId])
            index++
        } catch {
            break
        }
    }

    ; Fallback: if registry reading failed, use GetKeyboardLayoutList order
    if (layouts.Length = 0) {
        Loop count {
            offset := (A_Index - 1) * A_PtrSize
            layouts.Push(NumGet(hklBuffer, offset, "Ptr"))
        }
    }
}

; ==============================================================================
; Switch to the next keyboard layout according to Windows order
; ==============================================================================
SwitchToNextLayout() {
    global layouts

    ; Fallback to simple switching if no layouts loaded
    if (layouts.Length = 0) {
        PostMessage(0x50, 0x02, 0, , "A")
        return
    }

    hwnd := WinGetID("A")
    threadId := DllCall("GetWindowThreadProcessId", "Ptr", hwnd, "Ptr", 0, "UInt")
    currentHKL := DllCall("GetKeyboardLayout", "UInt", threadId, "Ptr")
    currentLangId := currentHKL & 0xFFFF

    ; Find current layout in our ordered array
    foundIndex := 0
    for index, hkl in layouts {
        if ((hkl & 0xFFFF) = currentLangId) {
            foundIndex := index
            break
        }
    }

    ; Calculate next layout index (circular)
    if (foundIndex > 0) {
        nextIndex := Mod(foundIndex, layouts.Length) + 1
    } else {
        nextIndex := 1
    }

    SendMessage(0x50, 0, layouts[nextIndex], , "ahk_id " . hwnd)
}

; Initialize on include
LoadLayoutOrder()
