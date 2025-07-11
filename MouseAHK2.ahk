#Requires AutoHotkey v2.0
;#Requires UIAccess 1
;@Ahk2Exe-UpdateManifest 0, , , 1

#SingleInstance Force

SetTitleMatchMode(2)
#WinActivateForce   ; Fast window switch

A_HotkeyInterval := 2000  ; This is the default value (milliseconds).
A_MaxHotkeysPerInterval := 1000

A_IconTip := "MouseAHK v2.0,  Razer"

ListLines False

SetWorkingDir "E:\PROGRAMS\MouseAHK2"

;--------------------------AVR Ethernet Constants------------------------------
global AVR_ETHERNET_VOLUME_UP_STEP 			:= 3
global AVR_ETHERNET_VOLUME_DOWN_STEP 	    := -AVR_ETHERNET_VOLUME_UP_STEP
;--------------------------------------------------------------------------------

;--------------------------TOTALCMD Constants------------------------------------
global TOTALCMD64 					:= true
global TOTALCMD_WINDOW				:= "Total Commander ahk_class TTOTAL_CMD"
global TOTALCMD_COMMAND				:= "^{SC014}"
global TOTALCMD_PATH				:= "c:\Program Files\totalcmd\TOTALCMD64.exe"
global TOTALCMD_EXE					:= "TOTALCMD64.exe"
;--------------------------------------------------------------------------------

global cUIA							:= 0
global AltTab                       := false
global PRIMARY_MONITOR_WIDTH        := A_ScreenWidth
global PRIMARY_MONITOR_WIDTH_VALUE  := 5120

;-------------------------- MouseAHK running ------------------------------------
detectHiddenWindowsPre := A_DetectHiddenWindows
DetectHiddenWindows true
if(A_IsCompiled)
{
	if(WinExist("MouseAHK2.ahk - AutoHotkey ahk_class AutoHotkey"))
	{
        result := MsgBox("Warning, MouseAHK2.ahk script is running!`nRun anyway?",, "YesNo")
        if (result = "No")
            ExitApp
	}
}
else
{
	if(WinExist("MouseAHK2.exe ahk_class AutoHotkey"))
	{
        result := MsgBox("Warning, MouseAHK2.exe script is running!`nRun anyway?",, "YesNo")
        if (result = "No")
            ExitApp
	}
}
if(detectHiddenWindowsPre == 0)
{
    DetectHiddenWindows false
}

;-------------------------- MouseAHK menu --------------------------------
Tray := A_TrayMenu ; For convenience.
Tray.Add() ; separator
Tray.Add("AC Power", ACPower)
Tray.Add("TV Power", TVPower)
Tray.Add("AVR Power", AVRPower)
Tray.Add("AVR Source PC", AVRSourcePC)
Tray.Add("AVR 7ch", AVR7ch)
Tray.Add("AVR Dolby", AVRDolby)

;-------------------------- MouseAHK nemu  --------------------------------

#include <KeyboardLayoutSwitcher>
#include <VolumeOSD_V2_original>
#include <DenonTelnetVolume>
#include <YamahaMusicCast>
#include <HA_http_request>
http_request_post_ha("PC_LAMP_ON")
#include  %A_ScriptDir%\MPC_HC.ahk
#include <UIA>
#include <UIA_Browser>
return
;--------------------------------------------------------------------------------HA Tray menu------------------------------------------------------------------

ACPower(*)
{
  http_request_post_ha("Air_Conditioner_toggle")
  Return
}

TVPower(*)
{
  http_request_post_ha("TV_POWER_TOGGLE")
  Return
}

AVRPower(*)
{
  Return
}

AVRSourcePC(*)
{
  http_request_post_ha("avr_source_pc")
  Return
}

AVR7ch(*)
{
  http_request_post_ha("avr_mch_stereo")
  Return
}

AVRDolby(*)
{
  Return
}

HA_CMD_lamp_on()
{
  http_request_post_ha("PC_LAMP_ON")
  return
}
;------------------------------------------------------------------------------------------------------------------------------------------------------

;---------------------------------------------------------- KeyboardLayoutSwitcher ---------------------------------------------
;!VKC0::translate() ; hotkey - ctrl-`
#VKC0::translate() ; hotkey - win -`
;-------------------------------------------------------------------------------------------------------------------------------

;Button7
;XButton1 & F12::
;Send #{tab}
;return
;----------------------------------------------------- New AltTab Menu ---------------------------------------------------

;----------------------------------------------------- ALT TAB fixed---------------------------------------------------

#HotIf (AltTab)
    ; The * prefix fires the hotkey even if extra modifiers (in this case Alt) are being held down
    *WheelDown::Send "{Blind}+{Tab}" 
    *WheelUp::Send "{Blind}{Tab}"
#HotIf

XButton2 & RButton::  ;AltTab
{
    global

    AltTab := true
    Send("{blind}{alt Down}{Tab}")   ;Send {blind}{LAlt Down}{Tab}
    KeyWait "RButton", "Up"
    Send("{blind}{Alt Up}")
    AltTab := false
    Return
}
;----------------------------------------------------- ALT TAB fixed---------------------------------------------------

;=== overTray() ======================================================================================
; 	This is just a simple function that checks if the mouse if over the start bar. If it is, it will return 1
;=====================================================================================================
overTray()
{	    
    result := 0
    MouseGetPos &mX, &mY, &mWin
	
    wClass := WinGetClass("ahk_id " mWin)
   
    if(wClass == "Shell_TrayWnd")
    {
        result := 1
    }

	return result
}

;----------------------------------------------------- Dennon Ethernet Volume ----------------------------

;----------------------------------------------------- ControlMyMonitor_Laptop.lnk ----------------------------
#HotIf (PRIMARY_MONITOR_WIDTH == PRIMARY_MONITOR_WIDTH_VALUE)
!^F12::
{
    Run "E:\PROGRAMS\ControlMyMonitor\ControlMyMonitor.exe /SetValue Primary 60 16"
    return
}
#HotIf
;----------------------------------------------------- ControlMyMonitor_Laptop.lnk ----------------------------

;----------------------------------------------------- ControlMyMonitor_Mac.lnk ----------------------------
#HotIf (PRIMARY_MONITOR_WIDTH == PRIMARY_MONITOR_WIDTH_VALUE)
!^F11::
{
    Run "E:\PROGRAMS\ControlMyMonitor\ControlMyMonitor.exe /SetValue Primary 60 17"
    return
}
#HotIf
;----------------------------------------------------- ControlMyMonitor_MAC.lnk ----------------------------

;--------------------------------------------------------- SmartGIT ------------------------------------------------
MButton & RButton::
{
	if WinExist("SmartGit ahk_class SWT_Window0")
	{
        if WinActive("SmartGit ahk_class SWT_Window0")
        {
           ; Run "calc.exe"
        }
        else
        {
            WinActivate
        }
	}
    else
    {
        if not (PID := ProcessExist("smartgit.exe"))
        {
           Run "c:\Program Files\SmartGit\bin\smartgit.exe"
        }
    }
    return
}
;--------------------------------------------------------- SmartGIT ------------------------------------------------

;----------------------------------------------------- Monitor standby on ----------------------------
#HotIf false
!m::
{
  SendMessage 0x0112, 0xF170, 2,, "Program Manager"  ; -1=on, 2=off, 1=standby
  return
}
#HotIf
;-----------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------
#HotIf (PRIMARY_MONITOR_WIDTH == PRIMARY_MONITOR_WIDTH_VALUE)
Volume_Mute::
F15 & LButton::
{
    volDiff := DenonEthernet_GetMaxVolume() * (-1)
    volume  := DenonEthernet_ChangeVolume(volDiff)

    ;VolumeOSD_Show_OSD(volume, DenonEthernet_GetMinVolume(), DenonEthernet_GetMaxVolume())
    VolumeOSD(String(volume/(DenonEthernet_GetMaxVolume()-DenonEthernet_GetMinVolume())*100), 3000, "Denon AVR")
    return
}
#HotIf
;-----------------------------------------------------------------------------------------------------------

Volume_Up::
XButton2 & Wheelup::
F15 & Wheelup::
{
    global

    f_pressed := true
    if(GetKeyState("F15", "P"))
    {
        f_pressed := true
    }
    else if(GetKeyState("XButton2", "P"))
    {
        f_pressed := false
    }
    
    if(overTray() == 1 || f_pressed == true)
    {
        f_pressed := false
        volume := DenonEthernet_ChangeVolume(AVR_ETHERNET_VOLUME_UP_STEP)
        ;VolumeOSD_Show_OSD(volume, DenonEthernet_GetMinVolume(), DenonEthernet_GetMaxVolume())
        VolumeOSD(String(volume/(DenonEthernet_GetMaxVolume()-DenonEthernet_GetMinVolume())*100), 3000, "Denon AVR")

    }
    return
}

Volume_Down::
XButton2 & WheelDown::
F15 & WheelDown::

{
    global

    f_pressed := true
    if(GetKeyState("F15", "P"))
    {
        f_pressed := true
    }
    else if(GetKeyState("XButton2", "P"))
    {
        f_pressed := false
    }
    
    if(overTray() == 1 || f_pressed == true)
    {
        f_pressed := false
        volume := DenonEthernet_ChangeVolume(AVR_ETHERNET_VOLUME_DOWN_STEP)
        ;VolumeOSD_Show_OSD(volume, DenonEthernet_GetMinVolume(), DenonEthernet_GetMaxVolume())
        VolumeOSD(String(volume/(DenonEthernet_GetMaxVolume()-DenonEthernet_GetMinVolume())*100), 3000, "Denon AVR")
    }

    return
}
;----------------------------------------------------- Dennon Ethernet Volume ----------------------------

;---------------------------------------------------------Yamaha AVR----------------------------------

^Volume_Up::
{
    global

    volume := YamahaEthernet_ChangeVolume(AVR_ETHERNET_VOLUME_UP_STEP)
    ;VolumeOSD_Show_OSD(volume, DenonEthernet_GetMinVolume(), DenonEthernet_GetMaxVolume())
    VolumeOSD(String(volume/(YamahaEthernet_GetMaxVolume()-YamahaEthernet_GetMinVolume())*100), 3000, "Yamaha AVR")

    return
}

^Volume_Down::
{
    global

    volume := YamahaEthernet_ChangeVolume(AVR_ETHERNET_VOLUME_DOWN_STEP)
    ;VolumeOSD_Show_OSD(volume, DenonEthernet_GetMinVolume(), DenonEthernet_GetMaxVolume())
    VolumeOSD(String(volume/(YamahaEthernet_GetMaxVolume()-YamahaEthernet_GetMinVolume())*100), 3000, "Yamaha AVR")

    return
}
;---------------------------------------------------------Yamaha AVR----------------------------------

;---------------------------------------------------------- Notepad++  --------------------------------------------------------
XButton1 & RButton::
{
    if WinExist("Notepad++ ahk_class Notepad++")
    {
        if WinActive("Notepad++ ahk_class Notepad++")
        {
            Send "{F5}"
        }
        else
        {
            WinActivate
        }
    }
    else
    {
        if not (PID := ProcessExist("notepad++.exe"))
        {
            Run A_ProgramFiles . "\Notepad++\notepad++.exe"
        }            
    }
    return
}
;---------------------------------------------------------- Notepad++  --------------------------------------------------------

;---------------------------------------------------------- Edge --------------------------------------------------------

XButton1 & LButton::
{
    global cUIA
    static last_count_tab := 0, active_tab := 0
    
    if WinExist("Edge ahk_class Chrome_WidgetWin_1")
    {
        WinActivate
        WinWaitActive("Edge ahk_class Chrome_WidgetWin_1")
        if(cUIA == 0)
        {
            cUIA := UIA_Browser("Edge ahk_class Chrome_WidgetWin_1") ; Initialize UIA_Browser, which also initializes UIA_Interface
        }

        youtube_tabs := cUIA.GetTabs("youtube", 2, False)

        if(youtube_tabs.Length < 1)
        {
            return
        }

        if(last_count_tab != youtube_tabs.Length)
        {
            if (youtube_tabs.Length > 0)
            {
                active_tab := 0
            }
            else
            {
                active_tab := 0
                last_count_tab := youtube_tabs.Length
                return
            }
        }

        active_tab := active_tab + 1
        active_tab := Mod(active_tab, youtube_tabs.Length + 1)

        if(active_tab < 1)
        {
            active_tab := 1
        }
        
        last_count_tab := youtube_tabs.Length

        cUIA.SelectTab(youtube_tabs[active_tab].name, 2, False)
    }
    return
}

XButton1 Up::
{
    global

    if WinExist("Edge ahk_class Chrome_WidgetWin_1")
    {
        if WinActive("Edge ahk_class Chrome_WidgetWin_1")
        {
            Send "^{SC014}"
        }
        else
        {
            WinActivate
        }
    }
    else
    {
        if not (PID := ProcessExist("msedge.exe"))
        {
            Run "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
            WinWaitActive("Edge ahk_class Chrome_WidgetWin_1")
		    cUIA := UIA_Browser("Edge ahk_class Chrome_WidgetWin_1") ; Initialize UIA_Browser, which also initializes UIA_Interface
        }            
    }
    return
}
;---------------------------------------------------------- Edge --------------------------------------------------------

;---------------------------------------------------------- Total Commander --------------------------------------------------------
MButton::
{
    global 

    if WinExist(TOTALCMD_WINDOW)
    {
        if WinActive(TOTALCMD_WINDOW)
            Send TOTALCMD_COMMAND ; new tab
        else
            WinActivate
    }
    else
    {
        if not (PID := ProcessExist(TOTALCMD_EXE))
        {
            Run TOTALCMD_PATH
        }
    }
    return
}
;---------------------------------------------------------- Total Commander --------------------------------------------------------

;!VK31::MPC_HC_ShowMenu() ; hotkey - alt -1

;---------------------------------------------------------- Calculator --------------------------------------------------------
!VK4B::
{
    if WinExist("Calculator ahk_class ApplicationFrameWindow")
    {
        if WinActive("Calculator ahk_class ApplicationFrameWindow")
        {
            Run "calc.exe"
        }
        else
        {
            WinActivate
        }
    }
    else
    {
        if not (PID := ProcessExist("calc.exe"))
        {
            Run "calc.exe"
        }
    }
    return
}
;---------------------------------------------------------- Calculator --------------------------------------------------------

#HotIf false
;---------------------------------------------------------- Youtube music --------------------------------------------------------
XButton1 & LButton::
{
    if WinExist("YouTube Music ahk_class Chrome_WidgetWin_1")
    {
        if WinActive("YouTube Music ahk_class Chrome_WidgetWin_1")
        {
        
        }
        else
        {
            WinActivate
        }
    }
    else
    {
        if not (PID := ProcessExist("msedge.exe"))
        {
            Run "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
            WinWaitActive("Edge ahk_class Chrome_WidgetWin_1")
		    cUIA := UIA_Browser("Edge ahk_class Chrome_WidgetWin_1") ; Initialize UIA_Browser, which also initializes UIA_Interface
        }
    }
    return
}
;---------------------------------------------------------- Youtube music --------------------------------------------------------
#HotIf 

;---------------------------------------------------------- vs code --------------------------------------------------------
F15 & RButton::
{
    if WinExist("Visual Studio Code ahk_exe Code.exe")
    {
        if WinActive("Visual Studio Code ahk_exe Code.exe")
        {
        
        }
        else
        {
            WinActivate
        }
    }
    else
    {
        if not (PID := ProcessExist("Code.exe"))
        {
            Run("C:\Users\roman\AppData\Local\Programs\Microsoft VS Code\Code.exe")
        }
    }
    return
}
;---------------------------------------------------------- vs code --------------------------------------------------------

;---------------------------------------------------------- EveryLang --------------------------------------------------------
#HotIf not WinActive('ahk_class MPC-BE')
F15 Up::Send "^!{F1}"
#HotIf
;---------------------------------------------------------- EveryLang --------------------------------------------------------

;---------------------------------------------------------- Mute toggle MediaPlayer --------------------------------------------------------
#HotIf WinActive('ahk_class MPC-BE')
WheelLeft::Send "^{m}"
#HotIf
;---------------------------------------------------------- Mute toggle MediaPlayer --------------------------------------------------------

;---------------------------------------------------------- MediaPlayer --------------------------------------------------------
XButton2 Up::
{
    if WinExist("ahk_class PotPlayer64")
    || WinExist("ahk_class PotPlayer")
    || WinExist("Splash ahk_class DX_DISPLAY0")
    || WinExist("Splash ahk_class welcome_2d")
    || WinExist("AVer MediaCenter ahk_class AVer MediaCenter")
    || WinExist("ahk_class ShockwaveFlashFullScreen")
    || WinExist("ahk_class WMPTransition")
    || WinExist("ahk_class WMP Skin Host")
    || WinExist("NextPVR ahk_exe NextPVR.exe")
    || WinExist("ahk_class Chrome_RenderWidgetHostHWND")
    || WinExist("MediaPortal ahk_exe MediaPortal.exe")
    || WinExist("SMPlayer ahk_class Qt5QWindowIcon")
    || WinExist("VLC media player ahk_class Qt5QWindowIcon")
    || WinExist("mpv ahk_class mpv")
    || WinExist("Ace Player HD (VLC) ahk_class QWidget")
    || WinExist("Windows Media Player ahk_class WMPlayerApp")
    {

        WinActivate
    }
    else
    {
        if WinExist("ahk_class MPC-BE")
        {
            if WinActive("ahk_class MPC-BE")
            {
                MPC_HC_ShowMenu()
            }
            else
            {
                WinActivate("ahk_class MPC-BE")
            }
        }
        else
        {
            if not (PID := ProcessExist("mpc-be64.exe"))
            {
                Run "e:\PROGRAMS\MPC-BE-TV\mpc-be64.exe /device"
            }
        }
    }
    return
}
;---------------------------------------------------------- MediaPlayer --------------------------------------------------------

;---------------------------------------------------------- Shutdown --------------------------------------------------------

^!VK50::
{
   if "Yes" == MsgBox("Do you want to shut down the computer?", "Shutdown Confirmation", "YesNo 32")
   {
      Shutdown 5
   }
}
;---------------------------------------------------------- Shutdown --------------------------------------------------------
