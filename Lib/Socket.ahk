;https://github.com/G33kDude/Socket.ahk
;AutoHotkey socket class based on Bentschi's
#Requires AutoHotkey v2.0

class Socket
{
	WM_SOCKET := 0x9987, MSG_PEEK := 2
	FD_READ := 1, FD_ACCEPT := 8, FD_CLOSE := 32
	Blocking := True, BlockSleep := 5

	__New(Socket:=-1)
	{
		static Init := false
		if (Init == false)
		{
			DllCall("LoadLibrary", "Str", "Ws2_32", "Ptr")
			WSAData := Buffer(394+A_PtrSize)
			if (Err := DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSAData.ptr))
            throw Error("Error starting Winsock",, Err)
			if (NumGet(WSAData, 2, "UShort") != 0x0202)
            throw Error("Winsock version 2.2 not available")
			Init := True
		}
		this.Socket := Socket
	}
	
	__Delete()
	{
		if (this.Socket != -1)
			this.Disconnect()
	}
	
	Connect(Address)
	{
		if (this.Socket != -1)
			throw Error("Socket already connected")
		Next := pAddrInfo := this.GetAddrInfo(Address)
		while Next
		{
			ai_addrlen := NumGet(Next+0, 16, "UPtr")
			ai_addr := NumGet(Next+0, 16+(2*A_PtrSize), "Ptr")
			if ((this.Socket := DllCall("Ws2_32\socket", "Int", NumGet(Next+0, 4, "Int")
				, "Int", this.SocketType, "Int", this.ProtocolId, "UInt")) != -1)
			{
				if (DllCall("Ws2_32\WSAConnect", "UInt", this.Socket, "Ptr", ai_addr
					, "UInt", ai_addrlen, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Int") == 0)
				{
					DllCall("Ws2_32\freeaddrinfo", "Ptr", pAddrInfo) ; TODO: Error Handling
					return this.EventProcRegister(this.FD_READ | this.FD_CLOSE)
				}
				this.Disconnect()
			}
			Next := NumGet(Next+0, 16+(3*A_PtrSize), "Ptr")
		}
		throw Error("Error connecting")
	}
	
	Bind(Address)
	{
		if (this.Socket != -1)
			throw Error("Socket already connected")
		Next := pAddrInfo := this.GetAddrInfo(Address)
		while Next
		{
			ai_addrlen := NumGet(Next+0, 16, "UPtr")
			ai_addr := NumGet(Next+0, 16+(2*A_PtrSize), "Ptr")
			if ((this.Socket := DllCall("Ws2_32\socket", "Int", NumGet(Next+0, 4, "Int")
				, "Int", this.SocketType, "Int", this.ProtocolId, "UInt")) != -1)
			{
				if (DllCall("Ws2_32\bind", "UInt", this.Socket, "Ptr", ai_addr
					, "UInt", ai_addrlen, "Int") == 0)
				{
					DllCall("Ws2_32\freeaddrinfo", "Ptr", pAddrInfo) ; TODO: ERROR HANDLING
					return this.EventProcRegister(this.FD_READ | this.FD_ACCEPT | this.FD_CLOSE)
				}
				this.Disconnect()
			}
			Next := NumGet(Next+0, 16+(3*A_PtrSize), "Ptr")
		}
		throw Error("Error binding")
	}
	
	Listen(backlog:=32)
	{
		return DllCall("Ws2_32\listen", "UInt", this.Socket, "Int", backlog) == 0
	}
	
	Accept()
	{
		if ((s := DllCall("Ws2_32\accept", "UInt", this.Socket, "Ptr", 0, "Ptr", 0, "Ptr")) == -1)
			throw Error("Error calling accept",, this.GetLastError())
		Sock := Socket(s)
		Sock.ProtocolId := this.ProtocolId
		Sock.SocketType := this.SocketType
		Sock.EventProcRegister(this.FD_READ | this.FD_CLOSE)
		return Sock
	}
	
	Disconnect()
	{
		; Return 0 if not connected
		if (this.Socket == -1)
			return 0
		
		; Unregister the socket event handler and close the socket
		this.EventProcUnregister()
		if (DllCall("Ws2_32\closesocket", "UInt", this.Socket, "Int") == -1)
			throw Error("Error closing socket",, this.GetLastError())
		this.Socket := -1
		return 1
	}
	
	MsgSize()
	{
		argp := 0
		static FIONREAD := 0x4004667F
		if (DllCall("Ws2_32\ioctlsocket", "UInt", this.Socket, "UInt", FIONREAD, "UInt*", &argp) == -1)
			throw Error("Error calling ioctlsocket",, this.GetLastError())
		return argp
	}
	
	Send(pBuffer, BufSize, Flags:=0)
	{
		if ((r := DllCall("Ws2_32\send", "UInt", this.Socket, "Ptr", pBuffer.ptr, "Int", BufSize, "Int", Flags)) == -1)
			throw Error("Error calling send",, this.GetLastError())
		return r
	}
	
	SendText(Text, Flags:=0, Encoding:="UTF-8")
	{
    	Buffer1 := Buffer(StrPut(Text,Encoding),0)
   		Length := StrPut(Text,Buffer1,Encoding)
		return this.Send(Buffer1, Length - 1)
	}
	
	Recv(Buffer_, BufSize:=0, Flags:=0)
	{
		while (!(Length := this.MsgSize()) && this.Blocking)
			Sleep this.BlockSleep
		if !Length
			return 0

	 	if !BufSize
	 		BufSize := Length

        VarSetStrCapacity(&Buffer_, BufSize)
		if ((r := DllCall("Ws2_32\recv", "UInt", this.Socket, "Ptr", StrPtr(Buffer_), "Int", BufSize, "Int", Flags)) == -1)
			throw Error("Error calling recv",, this.GetLastError())

		return r
	}
	
	RecvText(BufSize:=0, Flags:=0, Encoding:="UTF-8")
	{
		while (!(Length := this.MsgSize()) && this.Blocking)
			Sleep this.BlockSleep
		if !Length
			return 0

	 	if !BufSize
	 		BufSize := Length

        VarSetStrCapacity(&Buffer_, BufSize)
		if ((r := DllCall("Ws2_32\recv", "UInt", this.Socket, "Ptr", StrPtr(Buffer_), "Int", BufSize, "Int", Flags)) == -1)
			throw Error("Error calling recv",, this.GetLastError())

		if(r)
		{
			return StrGet(StrPtr(Buffer_), r, "UTF-8")
		}

		return ""
	} 
	
	RecvLine(BufSize:=0, Flags:=0, Encoding:="UTF-8", KeepEnd:=False)
	{
		while !(i := InStr(this.RecvText(BufSize, Flags|this.MSG_PEEK, Encoding), "`n"))
		{
			if !this.Blocking
				return ""
			Sleep this.BlockSleep
		}
		if KeepEnd
			return this.RecvText(i, Flags, Encoding)
		else
			return RTrim(this.RecvText(i, Flags, Encoding), "`r`n")
	}
	
	GetAddrInfo(Address) 
	{
		Host := Address[1], Port := Address[2]
        hints := Socket.addrinfo() 
		hints.protocol := this.ProtocolId
        hints.socktype := this.SocketType
		hints.family   := this.familyID

        if (err := DllCall("Ws2_32\GetAddrInfo",(Host?"Str":"UPtr"),Host
                                               ,(Port?"Str":"UPtr"),(Port?String(Port):0)
                                               ,"UPtr",hints.ptr
                                               ,"UPtr*",&result:=0)) 
		{
			throw Error("Error calling GetAddrInfo",, Error)
        }
        
		return Result
	}
	
	OnMessage(wParam, lParam, Msg, hWnd)
	{
		Critical
		if (Msg != this.WM_SOCKET || wParam != this.Socket)
			return
		if (lParam & this.FD_READ)
			this.onRecv()
		else if (lParam & this.FD_ACCEPT)
			this.onAccept()
		else if (lParam & this.FD_CLOSE)
			this.EventProcUnregister(), this.OnDisconnect()
	}
	
	EventProcRegister(lEvent)
	{
		if(this.AsyncMode == 0)
			return

		this.AsyncSelect(lEvent)
		if !this.Bound
		{
			this.Bound := this.OnMessage.Bind(this)
			OnMessage(this.WM_SOCKET, this.Bound)
		}
	}
	
	EventProcUnregister()
	{
		if(this.AsyncMode == 0)
			return

		this.AsyncSelect(0)
		if this.Bound
		{
			OnMessage(this.WM_SOCKET, this.Bound, 0)
			this.Bound := False
		}
	}
	
	AsyncSelect(lEvent)
	{
		if (DllCall("Ws2_32\WSAAsyncSelect"
			, "UInt", this.Socket    ; s
			, "Ptr", A_ScriptHwnd    ; hWnd
			, "UInt", this.WM_SOCKET ; wMsg
			, "UInt", lEvent) == -1) ; lEvent
			throw Error("Error calling WSAAsyncSelect",, this.GetLastError())
	}
	
	GetLastError()
	{
		return DllCall("Ws2_32\WSAGetLastError")
	}

	class addrinfo {
        Static __New() {
            off := {flags:     {off:0,   type:"Int"} ,addrlen:   {off:16,  type:"UPtr"}
                   ,family:    {off:4,   type:"Int"} ,cannonname:{off:16+(p:=A_PtrSize),type:"UPtr"}
                   ,socktype:  {off:8,   type:"Int"} ,addr:      {off:16+(p*2),type:"UPtr"}
                   ,protocol:  {off:12,  type:"Int"} ,next:      {off:16+(p*3),type:"UPtr"}}
            this.Prototype.DefineProp("s",{Value:off})
        }
        
        __New(buf := 0) {
            this.DefineProp("_struct",{Value:(!buf) ? Buffer(16 + (A_PtrSize*4),0) : {ptr:buf}})
            this.DefineProp("Ptr",{Get:(o)=>this._struct.ptr})
        }
        
        __Get(name,p) => NumGet(this.ptr, this.s.%name%.off, this.s.%name%.type)
        __Set(name,p,value) => NumPut(this.s.%name%.type, value, this.ptr, this.s.%name%.off)
    }
}

class SocketTCP extends Socket
{
    ProtocolId 	:= 6 ; IPPROTO_TCP
    SocketType 	:= 1 ; SOCK_STREAM
	Bound 		:= 0
	familyID 	:= 2
	AsyncMode 	:= 0
}

class SocketUDP extends Socket
{
    ProtocolId 	:= 17 ; IPPROTO_UDP
	SocketType 	:= 2  ; SOCK_DGRAM
	Bound 		:= 0
	familyID 	:= 2
    AsyncMode 	:= 0

	SetBroadcast(Enable)
	{
		SOL_SOCKET := 0xFFFF, SO_BROADCAST := 0x20
		if (DllCall("Ws2_32\setsockopt"
			, "UInt", this.Socket ; SOCKET s
			, "Int", SOL_SOCKET   ; int    level
			, "Int", SO_BROADCAST ; int    optname
			, "UInt*", !!Enable   ; *char  optval
			, "Int", 4) == -1)    ; int    optlen
			throw Error("Error calling setsockopt",, this.GetLastError())
	}
}
