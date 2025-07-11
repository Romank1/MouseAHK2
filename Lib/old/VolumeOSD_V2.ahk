#Requires AutoHotkey v2.0
#SingleInstance

VolumeOSD(NewSetting, Period := 3000, *)           ;  v0.12 by SKAN for ah2 on D48C/D7AR @ autohotkey.com/r?t=93666
{
    Static VOLUME_OSD_WIDTH     := A_ScreenWidth / 16
    Static VOLUME_OSD_HEIGHT    := 120
    Static VOLUME_OSD_X		    := A_ScreenWidth/2 - 400
    Static VOLUME_OSD_Y			:= A_ScreenHeight - 270
    
    Static MyGui := "",  MyGuiTitle := "VolumeOSD - AhkAlways2"
    Local  dwOldLong,    Vol

    Period := 0 - Min(Max(500, Abs(Period)), 5000) ; Forced range: -500ms to -5000ms

    If ( Type(MyGui) = "String" )
    {
        ;If ( IsFloat(NewSetting) = False )
        ;     SoundSetMute(NewSetting)

       ;Else
       ; If ( IsInteger(SubStr(NewSetting, 1, 1)) )
       ;      SoundSetVolume(NewSetting)

        MyGui :=  Gui("-MinimizeBox -Caption +Owner +Border +AlwaysOnTop +Disabled", MyGuiTitle)
        MyGui.MarginX  :=  16
        MyGui.MarginY  :=   8
        
        MyGui.SetFont("s16", "Trebuchet MS")
        MyGui.AddText("xm ym  w288 h28 Center 0x200", "AVR VOLUME")
        MyGui.Add("Progress", "xm y+m wp h20 vMyProgress")
        
        MyGui.SetFont("s24 Bold", "Trebuchet MS")
        MyGui.AddText("xm y+m wp  h32 vMyVolume Center 0x200")

        If ( IsSet(Status) )
             MyGui.SetFont("s9 Norm", "Trebuchet MS")
           , MyGui.AddStatusBar(, A_Tab Status) 

        WinSetTransparent(222, MyGui.Hwnd)
        UpdateProgress()
        
                    SetClassLong(Hwnd, nIndex, dwNewLong := 0)
                    {
                        Return (  dwNewLong = 0
                               ?  ( A_PtrSize=8  
                                      ? DllCall("User32\GetClassLongPtr", "ptr",Hwnd, "int",nIndex, "uint")
                                      : DllCall("User32\GetClassLong",    "ptr",Hwnd, "int",nIndex, "uint") 
                                  )
                    
                               :  ( A_PtrSize=8  
                                      ? DllCall("User32\SetClassLongPtr", "ptr",Hwnd, "int",nIndex, "ptr",dwNewLong, "uint")
                                      : DllCall("User32\SetClassLong",    "ptr",Hwnd, "int",nIndex, "ptr",dwNewLong, "uint") 
                                  )
                               )
                    }               

     ;  Thanks to @just me for demonstrating CS_DROPSHADOW @ autohotkey.com/r?p=264086
        dwOldLong := SetClassLong(MyGui.Hwnd, -26)           ; Save GCL_STYLE
        SetClassLong(MyGui.Hwnd, -26, dwOldLong | 0x20000)   ; Apply CS_DROPSHADOW
        MyGui.Show("NoActivate" " h" VOLUME_OSD_HEIGHT " w" VOLUME_OSD_WIDTH " x" VOLUME_OSD_X " y" VOLUME_OSD_Y)
        SetClassLong(MyGui.Hwnd, -26, dwOldLong)             ; Restore GCL_STYLE

        HotIfWinExist(MyGuiTitle " ahk_class AutoHotkeyGUI")
        Hotkey("Escape", OnEscape, "On")
        HotIfWinExist()

        SetTimer(OnEscape, Period)
        Return
    }

    Else IsFloat(NewSetting) 
            /*
           ? SoundSetVolume(NewSetting) 
           : SoundSetMute(NewSetting)
            */
                    UpdateProgress(*)
                    {
                        /*
                        SoundGetMute()  ?  MyGui["MyProgress"].Opt("cFF3000 Background5A1700") ; Bright red on Dark red
                                        :  MyGui["MyProgress"].Opt("cAAFF00 Background2E5500") ; Bright green on Dark green
                    
                        Vol := SoundGetVolume()
                        */
                        MyGui["MyProgress"].Value := Round(NewSetting)
                        MyGui["MyVolume"].Value   := Round(NewSetting)
                    }                  

    UpdateProgress()

                    OnEscape(*)
                    {
                        If (  MyGui  )
                              HotIfWinExist(MyGuiTitle " ahk_class AutoHotkeyGUI")
                           ,  Hotkey("Escape", OnEscape, "Off")
                           ,  HotIfWinExist()
                           ,  MyGui := MyGui.Destroy()
                    }

    SetTimer(OnEscape, Period)
} ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

;*ScriptEnd*VolumeOSD.ah2






F1::VolumeOSD("+1") ; Toggle mute
F2::VolumeOSD("-4.0") ; Decrease volume
F3::VolumeOSD("+4.0") ; Increase volume

F4::VolumeOSD("50.0") ; Half volume
F5::VolumeOSD("100.0") ; Full volume

