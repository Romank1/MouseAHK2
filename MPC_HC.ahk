#Requires AutoHotkey 2.0.13+
#SingleInstance Force

/*
 ***************************************************************************
 * Global Variables
 ***************************************************************************
*/

;-------------------------- SendMessage Constants -----------------------------------
global WM_USER           	 								:= 0x0400
global WM_COMMAND        	 								:= 0x0111
global WM_APP                      							:= 32768 ;0x8000
;------------------------------------------------------------------------------------

;-------------------------- PotPlayer Menu Lable Variables ---------------------
global MPC_HC_Menu_Mute_Toggle					      	:= "Mute Toggle"
global MPC_HC_Menu_HOT_Remote					      	:= "Remote"
global MPC_HC_Menu_Channel						      	:= "Channel"
;------------------------------------------------------------------------------
;global HOME_ASSISTENT_ETHERNET_HOST    					:= "http://192.168.50.185:8123/api/webhook/tv_remote_"
;global HOME_ASSISTENT_ERROR								:= 0

global MPC_HC_Channel_Arr 		:= Array()
global MPC_HC_Channel_Num_Arr 	:= Array()
global MPC_HC_Channel_Uid_Arr 	:= Array()

; -----------------------------------------------------------
;GUI Setup
MyGui := Gui(, "Remote")
MyGui.Opt("+AlwaysOnTop")  ; +Owner avoids a taskbar button.
MyGui.SetFont("s10")

;Buttons
MyBtnPower := MyGui.Add("Button", "x0 y0 w50 h40", "Power")
MyBtnPower.OnEvent("Click", BtnPower)
MyBtnUP := MyGui.Add("Button", "x85 y20 w40 h40", "Up")
MyBtnUP.OnEvent("Click", BtnUp)
MyBtnLeft := MyGui.Add("Button", "x45 y60 w40 h40", "Left")
MyBtnLeft.OnEvent("Click", BtnLeft)
MyBtnOk := MyGui.Add("Button", "x+1 y60 w40 h40", "Ok")
MyBtnOk.OnEvent("Click", BtnOk)
MyBtnRight := MyGui.Add("Button", "x+1 y60 w40 h40", "Right")
MyBtnRight.OnEvent("Click", BtnRight)
MyBtnBack := MyGui.Add("Button", "x45 y+1 w40 h40", "Back")
MyBtnBack.OnEvent("Click", BtnBack)
MyBtnDown := MyGui.Add("Button", "x+1 y100 w40 h40", "Down")
MyBtnDown.OnEvent("Click", BtnDown)
MyBtnHome := MyGui.Add("Button", "x+1 y101 w40 h40", "Home")
MyBtnHome.OnEvent("Click", BtnHome)
; Numbers
MyBtn1 := MyGui.Add("Button", "x45 y160 w40 h40", "1")
MyBtn1.OnEvent("Click", Btn1)
MyBtn2 := MyGui.Add("Button", "x85 y160 w40 h40", "2")
MyBtn2.OnEvent("Click", Btn2)
MyBtn3 := MyGui.Add("Button", "x+1 y160 w40 h40", "3")
MyBtn3.OnEvent("Click", Btn3)
MyBtn4 := MyGui.Add("Button", "x45 y200 w40 h40", "4")
MyBtn4.OnEvent("Click", Btn4)
MyBtn5 := MyGui.Add("Button", "x+1 y200 w40 h40", "5")
MyBtn5.OnEvent("Click", Btn5)
MyBtn6 := MyGui.Add("Button", "x+1 y200 w40 h40", "6")
MyBtn6.OnEvent("Click", Btn6)
MyBtn7 := MyGui.Add("Button", "x45 y+1 w40 h40", "7")
MyBtn7.OnEvent("Click", Btn7)
MyBtn8 := MyGui.Add("Button", "x+1 y240 w40 h40", "8")
MyBtn8.OnEvent("Click", Btn8)
MyBtn9 := MyGui.Add("Button", "x+1 y240 w40 h40", "9")
MyBtn9.OnEvent("Click", Btn9)
MyBtn0 := MyGui.Add("Button", "x85 y+1 w40 h40", "0")
MyBtn0.OnEvent("Click", Btn0)

BtnPower(*)
{
   http_request_post_ha("tv_remote_power")
}

BtnUp(*)
{
   http_request_post_ha("tv_remote_up")
}

BtnLeft(*)
{
   http_request_post_ha("tv_remote_left")
}

BtnOk(*)
{
   http_request_post_ha("tv_remote_ok")
}

BtnRight(*)
{
   http_request_post_ha("tv_remote_right")
}

BtnBack(*)
{
   http_request_post_ha("tv_remote_back")
}

BtnDown(*)
{
	http_request_post_ha("tv_remote_down")
}

BtnHome(*)
{
   http_request_post_ha("tv_remote_home")
}

Btn0(*)
{
   http_request_post_ha("tv_remote_0")
}

Btn1(*)
{
   http_request_post_ha("tv_remote_1")
}

Btn2(*)
{
   http_request_post_ha("tv_remote_2")
}

Btn3(*)
{
   http_request_post_ha("tv_remote_3")
}

Btn4(*)
{
   http_request_post_ha("tv_remote_4")
}

Btn5(*)
{
   http_request_post_ha("tv_remote_5")
}

Btn6(*)
{
   http_request_post_ha("tv_remote_6")
}

Btn7(*)
{
   http_request_post_ha("tv_remote_7")
}

Btn8(*)
{
   http_request_post_ha("tv_remote_8")
}

Btn9(*)
{
   http_request_post_ha("tv_remote_9")
}


; -----------------------------------------------
MPC_HC_Channel_Arr.Push("09")
MPC_HC_Channel_Num_Arr.Push("09")
MPC_HC_Channel_Uid_Arr.Push("09")
MPC_HC_Channel_Arr.Push("11")
MPC_HC_Channel_Num_Arr.Push("11")
MPC_HC_Channel_Uid_Arr.Push("11")
MPC_HC_Channel_Arr.Push("12")
MPC_HC_Channel_Num_Arr.Push("12")
MPC_HC_Channel_Uid_Arr.Push("12")
MPC_HC_Channel_Arr.Push("13")
MPC_HC_Channel_Num_Arr.Push("13")
MPC_HC_Channel_Uid_Arr.Push("13")
MPC_HC_Channel_Arr.Push("14")
MPC_HC_Channel_Num_Arr.Push("14")
MPC_HC_Channel_Uid_Arr.Push("14")
MPC_HC_Channel_Arr.Push("15")
MPC_HC_Channel_Num_Arr.Push("15")
MPC_HC_Channel_Uid_Arr.Push("15")
MPC_HC_Channel_Arr.Push("213")
MPC_HC_Channel_Num_Arr.Push("213")
MPC_HC_Channel_Uid_Arr.Push("213")
;-----------------------------------------------------------------------------------------------------
;------------------------------------------ MPC popup menu -------------------------------------
;-----------------------------------------------------------------------------------------------------
MPC_HC_Channel_Num_Arr2 := Array()
MPC_HC_Channel_Num_Arr2 := MPC_HC_Channel_Num_Arr.Clone()
MPC_HC_Channel_Index_Sorted_Arr := Array()

; Build sorted indexes array
Loop MPC_HC_Channel_Num_Arr.Length
{
	lower_value := 90000
	lower_index := -1
	; Find minimal channel value
	for index, element in MPC_HC_Channel_Num_Arr2
	{
		if((element < lower_value) && (element != -1))
		{
			lower_value := element
			lower_index := index
		}
	}

	if(lower_index != -1)
	{
		MPC_HC_Channel_Num_Arr2[lower_index] := -1
		MPC_HC_Channel_Index_Sorted_Arr.Push(lower_index)
	}
}

MyMenu := Menu()
SubmenuCh := Menu()
;http://www.autohotkey.com/board/topic/85789-menu-creator-easily-build-menus-for-your-scripts/
;https://autohotkey.com/board/topic/97722-some-array-functions/?hl=%252Bsort+%252Barray
; Iterate from 1 to the number of items:
; Add all analog Channels to PotPlayerChannelSubmenu
for index, element in MPC_HC_Channel_Index_Sorted_Arr
{
	channel_name := MPC_HC_Channel_Arr[element]
	SubmenuCh.Add(channel_name, MenuHandlerSub)
}

MyMenu.Add(MPC_HC_Menu_Mute_Toggle, MenuHandler)
MyMenu.Add()  ; Add a separator line
MyMenu.Add(MPC_HC_Menu_HOT_Remote, MenuHandler)
MyMenu.Add()
MyMenu.Add("Channels", SubmenuCh)


;-----------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------
;------------------------------------------ Menu Handler----------------------------------------------
;-----------------------------------------------------------------------------------------------------
MenuHandler(Item, *) 
{
	if(Item == "Mute Toggle")
	{
		Send "^{m}"
	}
	else if(Item == "Remote")
	{
		;Run GUI
		MyGui.Show("x1700 y1000 w210 h335 xCenter")
	}
	else if(Item == "Channel")
	{
	}
	return
}

MenuHandlerSub(channel_name, *) 
{
	channel_ind := 0
	for index, element in MPC_HC_Channel_Arr
	{
		if(channel_name == element)
		{
			channel_ind := index
			;MsgBox, % element
			break
		}
	}

	channel 	:= MPC_HC_Channel_Num_Arr[channel_ind]
	channel_len := StrLen(channel)

	channelNum0 := 0
	channelNum1 := 0
	channelNum2 := 0
	channelNum3 := 0

	if(channel_len == 1)
	{
		channelNum2 := SubStr(channel, 4, 3) ;
	}
	else if(channel_len == 2)
	{
		channelNum1 := SubStr(channel, 1, 1) ;
		channelNum2 := SubStr(channel, 2, 1) ;
	}
	else if(channel_len == 3)
	{
		channelNum0 := SubStr(channel, 1, 1)
		channelNum1 := SubStr(channel, 2, 1)
		channelNum2 := SubStr(channel, 3, 1) 
	}
	else
	{
		MsgBox "Erroe in channel number"
		return
	}

	http_request_post_ha("tv_remote_" . channelNum0)
	http_request_post_ha("tv_remote_" . channelNum1)
	http_request_post_ha("tv_remote_" . channelNum2)
	return
}


;------------------------------------------------------------------------------------------------------------------------------------------------------
;----------------------------------------------------- MPC_HC_ShowMenu ------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------------------------------
MPC_HC_ShowMenu()
{
	MyMenu.Show() 
	Return
}
;------------------------------------------------------------------------------------------------------------------------------------------------------

