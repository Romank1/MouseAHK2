; Translates selected text HE<>EN, cycles input language


;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;http://www.autohotkey.com/board/topic/24666-keyboard-layout-switcher/?hl=%20switching%20%20language
;http://www.autohotkey.com/board/topic/70019-keyboard-layout-switcher-for-many-layouts/?hl=%2Bswitching+%2Blanguage#entry546265
;http://www.autohotkey.com/board/topic/65500-traytip-showing-keyboard-layout-when-switchinghow/?hl=%2Bswitching+%2Blanguage#entry413723
;http://www.autohotkey.com/board/topic/113185-problems-with-recursive-sendinput/?hl=%2Bget+%2Bline

global KeyboardLayoutHeb := DllCall("LoadKeyboardLayout", "Str", "0000040d", "Int", 1)
global KeyboardLayoutEng := DllCall("LoadKeyboardLayout", "Str", "00000409", "Int", 1)


Translate()
{
	global KeyboardLayoutHeb, KeyboardLayoutEng
	
	Eng:="qwertyuiopasdfghjkl;'zxcvbnm,./"
	Heb:="/'קראטוןםפשדגכעיחלךף,זסבהנמצתץ."
		
	A_Clipboard := ""
	Send "{End}{Shift down}{HOME}{Shift Up}" ;select the current line
	sleep 50
	send "^{Insert}"
	sleep 50
	if !ClipWait(1)
	{
		MsgBox "The attempt to copy text onto the clipboard failed."
		return
	}
	
	detectHiddenWindowsPre := A_DetectHiddenWindows
	DetectHiddenWindows true

	;Get current Keyboard Layout
	w 		:= DllCall("GetForegroundWindow")
	pid 	:= DllCall("GetWindowThreadProcessId", "UInt", w, "Ptr", 0)
	lang 	:= DllCall("GetKeyboardLayout", "UInt", pid)
	
	if(detectHiddenWindowsPre == 0)
	{
		DetectHiddenWindows false
	}
	
	r := ""
	Loop parse, A_Clipboard
	{
		if(lang == KeyboardLayoutEng)
		{
			p := InStr(Eng, A_LoopField, false)
			if p > 0
				r := r . SubStr(Heb, p, 1)
			else
				r := r . A_LoopField
		}		
		else
		{		
			p := InStr(Heb, A_LoopField, false)
			if p > 0
				r := r . SubStr(Eng, p, 1)
			else
				r := r . A_LoopField
		}
	}
	
	;PostMessage, 0x50, 2, 0,, A ; Switch lang to next
	if (lang == KeyboardLayoutEng)
    {
		Send "{RCtrl Down}{RShift Down}{RShift Up}{RCtrl Up}"
		sleep 50
		PostMessage 0x50, 0, KeyboardLayoutHeb,, "A"
    }
	else
    {
		PostMessage 0x50, 0, KeyboardLayoutEng,, "A"
		sleep 50
		Send "{LCtrl Down}{LShift Down}{LShift Up}{LCtrl Up}"
    }
	
	A_Clipboard := r
	sleep 50
	send "+{Insert}"
	sleep 50
}

