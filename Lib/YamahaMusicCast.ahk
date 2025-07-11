;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Recommended for catching common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Requires AutoHotkey v2
;-------------------------- EventGhost Constants -------------------------------------
; Yamaha request xml constants
global YAMAHA_ETHERNET_HOST    					:= "http://192.168.50.167/YamahaExtendedControl/v1/main/"
global YAMAHA_ETHERNET_MINIMAL_VOLUME_EXP_DB	:= -80
global YAMAHA_ETHERNET_MAXIMAL_VOLUME_EXP_DB	:= 0
global YAMAHA_ETHERNET_MAXIMAL_VOLUME_M			:= 80/161
global YAMAHA_ETHERNET_MAXIMAL_VOLUME_B			:= 80
global YAMAHA_ETHERNET_MINIMAL_VOLUME			:= 1
global YAMAHA_ETHERNET_MAXIMAL_VOLUME			:= 161
global YAMAHA_ETHERNET_ERROR					:= 0
;-------------------------------------------------------------------------------------

;--------------------------- includes -------------------------------------------

;--------------------------------------------------------------------------------

YamahaEthernet_Get(command)
{
	; http://msdn.microsoft.com/en-us/library/windows/desktop/aa384106(v=vs.85).aspx
	WebRequest := ComObject("WinHttp.WinHttpRequest.5.1")
	;ComObjError(false)

	url := YAMAHA_ETHERNET_HOST . command
	;Set time-outs. If time-outs are set, they must be set before open.
	;http://www.autohotkey.com/board/topic/41127-ping-function-without-pingexe-formerly-a-ping/
	WebRequest.SetTimeouts(1000, 1000,1000, 1000)  ;ms
	WebRequest.Open("GET", url , false)
	WebRequest.SetRequestHeader("Content-type", "text/json")
	WebRequest.Send()
	WebRequest.WaitForResponse(1000)   ;ms
	result := YAMAHA_ETHERNET_ERROR
	if(WebRequest.Status == 200)
		result := WebRequest.ResponseText

	;ObjRelease(WebRequest)

	return (result)
}

YamahaEthernet_Send(command)
{
	; http://msdn.microsoft.com/en-us/library/windows/desktop/aa384106(v=vs.85).aspx
	WebRequest := ComObject("WinHttp.WinHttpRequest.5.1")
	;ComObjError(false)
	
	url := YAMAHA_ETHERNET_HOST . command

	;Set time-outs. If time-outs are set, they must be set before open.
	WebRequest.SetTimeouts(1000, 1000,1000, 1000)  ;ms
	WebRequest.Open("GET", url, false)
	WebRequest.SetRequestHeader("Content-type", "text/json")
	WebRequest.Send()
	WebRequest.WaitForResponse(1000)   ;ms
	result := YAMAHA_ETHERNET_ERROR
	if(WebRequest.Status == 200)
		result := 200

	;ObjRelease(WebRequest)

	return (result)
}


YamahaEthernet_GetBasicStatus()
{
	command := "getStatus"
	return YamahaEthernet_Get(command)
}

YamahaEthernet_ChangeVolume(Diff)
{
	static Volume 			:= 0
	static VolumeTimeStamp 	:= 0

	if(Volume != 0 && VolumeTimeStamp != 0 && (A_TickCount - VolumeTimeStamp) < 1000)   ;500ms from last run
		oldVolume := Volume
	else
		oldVolume := YamahaEthernet_GetVolume()

	if(oldVolume != YAMAHA_ETHERNET_ERROR)
		Volume := oldVolume + Diff

	if(Volume < YAMAHA_ETHERNET_MINIMAL_VOLUME)
		Volume := YAMAHA_ETHERNET_MINIMAL_VOLUME
	else if(Volume > YAMAHA_ETHERNET_MAXIMAL_VOLUME)
		Volume := YAMAHA_ETHERNET_MAXIMAL_VOLUME

	command := "setVolume?volume=" . Volume

	result := YAMAHA_ETHERNET_ERROR ;error
	if(YamahaEthernet_Send(command) == 200)
		result := Volume

	VolumeTimeStamp := A_TickCount
	return (result)
}

YamahaEthernet_GetVolume()
{
	jsonRes := YamahaEthernet_GetBasicStatus()
	if(jsonRes == YAMAHA_ETHERNET_ERROR)
		return (YAMAHA_ETHERNET_ERROR) ;error

	;"volume":105,"mute"
	NeedleRegEx :='"volume":(.*),"mute"'
	;Ungreedy. Makes the quantifiers *+?{} consume only those characters absolutely necessary to form a match, leaving the remaining ones available for the next part of the pattern.
	;When the "U" option is not in effect, an individual quantifier can be made non-greedy by following it with a question mark.
	;Conversely, when "U" is in effect, the question mark makes an individual quantifier greedy.
	FoundPos := RegExMatch(jsonRes, NeedleRegEx, &Match,1)
	return (Match[1])
}

YamahaEthernet_GetMaxVolume()
{
	return (YAMAHA_ETHERNET_MAXIMAL_VOLUME)
}

YamahaEthernet_GetMinVolume()
{
	return (YAMAHA_ETHERNET_MINIMAL_VOLUME)
}


#HotIf false
!i::
{
fff := YamahaEthernet_GetVolume()
MsgBox(fff)
return
}

!u::
{
fff := YamahaEthernet_ChangeVolume(1)
MsgBox(fff)
return
}
#HotIf
