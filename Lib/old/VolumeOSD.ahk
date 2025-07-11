;#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;===================================================================================================
;====================================== Volume OSD =================================================
;===================================================================================================
; https://autohotkey.com/board/topic/94813-just-another-volume-osd/page-3
;===================================================================================================


;================================= User Variables ==================================================
global VOLUME_OSD_WIDTH             := A_ScreenWidth / 16
global VOLUME_OSD_HEIGHT            := 120
global VOLUME_OSD_X		            := A_ScreenWidth/2 - 400
global VOLUME_OSD_Y			        := A_ScreenHeight - 270

global VOLUME_OSD_AMOUNT		    := 5

global VOLUME_OSD_TRANS_SPEED       := 1
global VOLUME_OSD_TIMEOUT	        := 1000
global VOLUME_OSD_TIMEOUT_NEGATIVE	:= -1000
global VOLUME_OSD_MAX_TRANS		    := 180
global VOLUME_OSD_CONTROL_WIDTH	    := VOLUME_OSD_WIDTH - 30
global VOLUME_OSD_CONTROL_HEIGHT    := 15

global VOLUME_OSD_DEBUG             := 0
;============================== End of user variables ==============================================

;==================================  Variables =====================================================
global VolumeOSD_Trans              := 0
global VolumeOSD_TransFadeDisable   := false
global VolumeOSD_First_Time         := true
;===================================================================================================


VolumeOSD_Show_OSD(vol, volMin, volMax)
{
    global

    SetTimer VolumeOSD_Fade, 0
    VolumeOSD_TransFadeDisable := true

    if(VolumeOSD_First_Time == true)
    {
        VolumeOSD_First_Time := false
        MyGui :=  Gui("-MinimizeBox -Caption +Owner +Border +AlwaysOnTop +Disabled", "Vol_OSD")
        MyGui.MarginX  :=  16
        MyGui.MarginY  :=   8
        
        MyGui.SetFont("s16", "Trebuchet MS")
        MyGui.AddText("xm ym  w288 h28 Center 0x200", "AVR VOLUME")
        MyGui.Add("Progress", "xm y+m wp h20 vMyProgress")
        
        MyGui.SetFont("s24 Bold", "Trebuchet MS")
        MyGui.AddText("xm y+m wp  h32 vMyVolume Center 0x200")

        VolumeOSD_Calculate_vol(vol, volMin, volMax, &vol_out_percentage)

        MyGui.Show("NoActivate" " h" VOLUME_OSD_HEIGHT " w" VOLUME_OSD_WIDTH " x" VOLUME_OSD_X " y" VOLUME_OSD_Y)
    }

    VolumeOSD_Calculate_vol(vol, volMin, volMax, &vol_out_percentage)
    MyGui["MyProgress"].Value := Ceil(vol_out_percentage)
    MyGui["MyVolume"].Value   := Ceil(vol)

    WinSetTransparent VOLUME_OSD_MAX_TRANS, "Vol_OSD"
    VolumeOSD_Trans := VOLUME_OSD_MAX_TRANS

    SetTimer VolumeOSD_Fade, VOLUME_OSD_TIMEOUT_NEGATIVE
    return
}

;=== GUI fadeout =====================================================================================
; 	A simple GUI fadeout. That gets called when the GUI has been around for the amount of time you set.
; 	It uses A_Index to make the fade more dynamic, and add a speed up effect. It is only just visible
;	but still looks good.
;=====================================================================================================
VolumeOSD_Fade()
{
    global

    VolumeOSD_TransFadeDisable := false

    while(VolumeOSD_Trans > 0)
    {
        if(VolumeOSD_TransFadeDisable == true)
        {
            WinSetTransparent VOLUME_OSD_MAX_TRANS, "Vol_OSD"
            return
        }

        VolumeOSD_Trans -= A_Index/VOLUME_OSD_TRANS_SPEED
        if(VolumeOSD_Trans < 0)
        {
           VolumeOSD_Trans := 0
        }

        WinSetTransparent Integer(VolumeOSD_Trans), "Vol_OSD"
        
        Sleep 1
    }

    return
}



VolumeOSD_Calculate_vol(vol, volMin, volMax, &vol_out_percentage)
{
    m := 100/(volMax - volMin)
    b := volMin

    vol_out_percentage := m*(vol - b)
}

/*
#if (VOLUME_OSD_DEBUG == 1 && overTray())
;=== Wheel down ======================================================================================
WheelDown::
    SoundSet, -%VOLUME_OSD_AMOUNT%, MASTER
    SoundGet, vol
    vol := 100 - vol
    vol *= -1
    vol := vol > -10 ? -10 : vol
    vol := vol < -80 ? -80 : vol
	VolumeOSD_Show_OSD(vol, -80, -10)
return

;=== Wheel up ========================================================================================
WheelUp::
    SoundSet, +%VOLUME_OSD_AMOUNT%, MASTER
	SoundGet, vol
    vol := 100 - vol
    vol *= -1
    vol := vol > -10 ? -10 : vol
    vol := vol < -80 ? -80 : vol
	VolumeOSD_Show_OSD(vol, -80, -10)
return
#if




;=== overTray() ======================================================================================
; 	This is just a simple function that checks if the mouse if over the start bar. If it is, it will return 1
;=====================================================================================================
overTray()
{
    if (VOLUME_OSD_DEBUG == 0)
    {
        return 0
    }

    result := 0
    MouseGetPos, mX, mY, mWin

    ;WinGetClass, wClass, ahk_id %mWin%
    WinGetClass, wClass, ahk_id %mWin%


    if(wClass == "Shell_TrayWnd")
    {
        result := 1
    }

	Return result
}
*/