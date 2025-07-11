;MsgBox % A_WorkingDir
;MsgBox % A_ScriptDir

RunAsAdmin() 
{
    full_command_line := DllCall("GetCommandLine", "str")

    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
    {
        try
        {
            if A_IsCompiled
                Run '*RunAs "' A_ScriptFullPath '" /restart'
            else
                Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
        }
        ExitApp
    }

    ;MsgBox "A_IsAdmin: " A_IsAdmin "`nCommand line: " full_command_line
}