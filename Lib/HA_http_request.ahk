http_request_post_ha(command)
{
	HOME_ASSISTENT_ETHERNET_HOST := "http://192.168.50.185:8123/api/webhook/"
	HOME_ASSISTENT_ERROR		 := 0

	; http://msdn.microsoft.com/en-us/library/windows/desktop/aa384106(v=vs.85).aspx
	WebRequest := ComObject("WinHttp.WinHttpRequest.5.1")
	;ComObjError(false)

	url := HOME_ASSISTENT_ETHERNET_HOST . command

	;Set time-outs. If time-outs are set, they must be set before open.
	;http://www.autohotkey.com/board/topic/41127-ping-function-without-pingexe-formerly-a-ping/
	WebRequest.SetTimeouts(1000, 1000,1000, 1000)  ;ms
	WebRequest.Open("POST", url , false)
	;WebRequest.SetRequestHeader("Content-Type", "text/json")
	WebRequest.SetRequestHeader("somekey", "1")
	WebRequest.Send()
	WebRequest.WaitForResponse(1000)   ;ms
	result := HOME_ASSISTENT_ERROR
	if(WebRequest.Status == 200)
		result := WebRequest.ResponseText

	;ObjRelease(WebRequest)

	return (result)
}