Func autorefresh($i)
	If BitAND(GUICtrlRead($refreshstatusitem[$i]), $GUI_CHECKED) = $GUI_CHECKED Then
		IniWrite($fileNetwork, $COM[$i + 1], "auto", 0)
		GUICtrlSetState($refreshstatusitem[$i], $GUI_UNCHECKED)
		GUICtrlSetImage($pic[$i], @ScriptDir & "\img\disable.bmp")
		GUICtrlSetColor($territory[$i], 0xc0c0c0)
		GUICtrlSetData($lableAuto[$i], "")
		newevent($name[$i] & " (" & $COM[$i + 1] & ")|Автообновление выключено")
	Else
		GUICtrlSetState($refreshstatusitem[$i], $GUI_CHECKED)
		IniWrite($fileNetwork, $COM[$i + 1], "auto", 1)
		GUICtrlSetImage($pic[$i], @ScriptDir & "\img\normal.bmp")
		GUICtrlSetColor($territory[$i], 0x000000)
		GUICtrlSetData($lableAuto[$i], "Автообновление")
		newevent($name[$i] & " (" & $COM[$i + 1] & ")|Автообновление включено")
	EndIf
EndFunc   ;==>autorefresh
