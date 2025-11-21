; ===================================
; Language Converter: Hebrew ↔ English
; Auto-Detection Version
; Hotkey: Ctrl + Q
; For AutoHotkey v2
; ===================================

^q::  ; CTRL + Q hotkey
{
    ; Save current clipboard content
    ClipboardBackup := ClipboardAll()
    A_Clipboard := ""
    
    ; Copy the selected text
    Send("^c")
    
    ; Wait up to 0.5 seconds for clipboard to contain data
    if !ClipWait(0.5) {
        ; If nothing was copied (no text selected), exit silently
        A_Clipboard := ClipboardBackup
        return
    }
    
    ; If clipboard is empty, exit silently
    if (A_Clipboard = "") {
        A_Clipboard := ClipboardBackup
        return
    }
    
    ; ===================================
    ; AUTO-DETECT LANGUAGE
    ; ===================================
    
    text := A_Clipboard
    hasHebrew := false
    hasEnglish := false
    
    ; Check each character to detect language
    Loop Parse text
    {
        char := A_LoopField
        charCode := Ord(char)
        
        ; Hebrew characters range: א (1488) to ת (1514)
        if (charCode >= 1488 && charCode <= 1514) {
            hasHebrew := true
        }
        
        ; English letters (both upper and lower)
        if ((charCode >= 65 && charCode <= 90) || (charCode >= 97 && charCode <= 122)) {
            hasEnglish := true
        }
        
        ; If we found both, no need to continue
        if (hasHebrew && hasEnglish) {
            break
        }
    }
    
    ; ===================================
    ; KEYBOARD MAPPING
    ; ===================================
    
    ; Hebrew keyboard layout (letters only, no shared punctuation)
    he := "/'קראטוןםפשדגכעיחלךף,זסבהנמצתץ."
    
    ; English lowercase (matching positions)
    en := "qwertyuiopasdfghjkl;'zxcvbnm,./"
    
    ; English uppercase (matching positions)
    ENG := "QWERTYUIOPASDFGHJKL;'ZXCVBNM,./"
    
    ; ===================================
    ; CONVERT BASED ON DETECTED LANGUAGE
    ; ===================================
    
    newText := ""
    
    Loop Parse text
    {
        char := A_LoopField
        converted := false
        
        ; If text has Hebrew → Convert Hebrew to English
        if (hasHebrew) {
            pos := InStr(he, char)
            if (pos > 0) {
                newText .= SubStr(en, pos, 1)
                converted := true
            }
        }
        
        ; If text has English → Convert English to Hebrew
        if (hasEnglish && !converted) {
            ; Check lowercase English
            pos := InStr(en, char)
            if (pos > 0) {
                newText .= SubStr(he, pos, 1)
                converted := true
            }
            
            ; Check uppercase English
            if (!converted) {
                pos := InStr(ENG, char)
                if (pos > 0) {
                    newText .= SubStr(he, pos, 1)
                    converted := true
                }
            }
        }
        
        ; If not converted, keep original (punctuation, numbers, spaces)
        if (!converted) {
            newText .= char
        }
    }
    
    ; Put the converted text into clipboard
    A_Clipboard := newText
    
    ; Paste the converted text
    Send("^v")
    
    ; Wait a bit to ensure paste completed
    Sleep(200)
    
    ; Restore original clipboard content
    A_Clipboard := ClipboardBackup
    
    return
}