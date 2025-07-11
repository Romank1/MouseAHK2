;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Recommended for catching common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Requires AutoHotkey v2.0

#include  <Socket>

;-------------------------- EventGhost Constants -------------------------------------
; DENON request xml constants
global TCPClient								:= ""
global DENON_ETHERNET_TCP_HOST					:= "192.168.50.175"
global DENON_ETHERNET_TCP_PORT					:= "23"
global DENON_ETHERNET_GET_STATUS    			:= "MV?"
global DENON_ETHERNET_SET_VOLUME    			:= "MV"
global DENON_ETHERNET_GET_MUTE_STATUS    		:= "MU?"
global DENON_ETHERNET_SET_VOLUME_MUTE    		:= "MU"
global DENON_ETHERNET_MINIMAL_VOLUME			:= 0
global DENON_ETHERNET_MAXIMAL_VOLUME			:= 70
global FloatVolume 								:= False
;-------------------------------------------------------------------------------------

;--------------------------- includes -------------------------------------------

;--------------------------------------------------------------------------------

DenonEthernet_Connect()
{
	global 

	TCPClient := SocketTCP()
	TCPClient.Connect([DENON_ETHERNET_TCP_HOST, DENON_ETHERNET_TCP_PORT])
}

DenonEthernet_Disconnect()
{
	global

	TCPClient.Disconnect()
	TCPClient := ""
}

DenonEthernet_Get()
{
	global

	if(TCPClient == "")
	{
		MsgBox "Not connected"
	}

    result := TCPClient.RecvText(1024)


	DenonEthernet_Disconnect()
	return (result)
}

DenonEthernet_Send(command)
{
	global

	if(TCPClient == "")
	{
		DenonEthernet_Connect()
	}

	TCPClient.SendText(command)
}

DenonEthernet_GetBasicStatus(var)
{
	DenonEthernet_Send(var)
	return DenonEthernet_Get()
}

DenonEthernet_ChangeVolume(Diff)
{
	static Volume 			:= 0
	static VolumeTimeStamp 	:= 0

	if(Volume != 0 && VolumeTimeStamp != 0 && (A_TickCount - VolumeTimeStamp) < 1000)   ;500ms from last run
	{
		oldVolume := Volume
	}
	else
	{
		oldVolume := DenonEthernet_GetVolume()
	}

	if(oldVolume == "")
	{
		oldVolume := Volume
	}

	Volume := oldVolume + Diff

	if(Volume < DENON_ETHERNET_MINIMAL_VOLUME)
		Volume := DENON_ETHERNET_MINIMAL_VOLUME
	else if(Volume > DENON_ETHERNET_MAXIMAL_VOLUME)
		Volume := DENON_ETHERNET_MAXIMAL_VOLUME

	VolumeToSend := Volume
	if(VolumeToSend < 10)
	{
		VolumeToSend := '0' . VolumeToSend
	}
	
	if(FloatVolume == True)
	{
		VolumeToSend := VolumeToSend . '5'
	}

	command := DENON_ETHERNET_SET_VOLUME . VolumeToSend

	DENONEthernet_Send(command)
	DenonEthernet_Disconnect()

	VolumeTimeStamp := A_TickCount
	return (Volume)
}

DenonEthernet_GetVolume()
{
	Res := DenonEthernet_GetBasicStatus(DENON_ETHERNET_GET_STATUS)
	;MsgBox(Res)
	NeedleRegEx :="MV(\d+)"
	;Ungreedy. Makes the quantifiers *+?{} consume only those characters absolutely necessary to form a match, leaving the remaining ones available for the next part of the pattern.
	;When the "U" option is not in effect, an individual quantifier can be made non-greedy by following it with a question mark.
	;Conversely, when "U" is in effect, the question mark makes an individual quantifier greedy.
	FoundPos := RegExMatch(Res, NeedleRegEx, &Match,1)
	
	try
	{
		volume := Match[1]
	}
	catch  
	{
		return ""
	}

	if (StrLen(volume) > 2)
	{
		FloatVolume := True
		volume := SubStr(volume, 1, StrLen(volume) -1)
	}
	else
	{
		FloatVolume := False
	}

	return volume
}

DenonEthernet_GetMaxVolume()
{
	return (DENON_ETHERNET_MAXIMAL_VOLUME)
}

DenonEthernet_GetMinVolume()
{
	return (DENON_ETHERNET_MINIMAL_VOLUME)
}


DenonEthernet_MuteToggle()
{
    res := DenonEthernet_GetBasicStatus(DENON_ETHERNET_GET_MUTE_STATUS)

	if InStr(res, "MUOFF")
	{
        command := "ON"
	}
    else if InStr(res, "MUON")
	{
        command := "OFF"
	}

    DenonEthernet_Mute(command)
	
	return command
}

DenonEthernet_Mute(var)
{   
	command := DENON_ETHERNET_SET_VOLUME_MUTE . var

	DenonEthernet_Send(command)
	DenonEthernet_Disconnect()
}

/*
!i::
{
	fff := DenonEthernet_GetVolume()
	MsgBox(fff)
	return
}

!u::
{
	fff := DenonEthernet_ChangeVolume(1)
	MsgBox(fff)
	return
}

!o::
{
	fff := DenonEthernet_MuteToggle()
	MsgBox(fff)
	return
}
*/
