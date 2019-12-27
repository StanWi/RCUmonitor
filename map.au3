Func map()
	Global $maplable, $map, $pic
	$posX = 2
	$posY = 5
	$mainWinPos = WinGetPos($mainWin)
	$maplable = GUICtrlCreateLabel("", $mainWinPos[2] - 500 - 11, 4, 502, 432, $SS_SUNKEN)
	GUICtrlSetResizing(-1, 4 + 32 + 256 + 512)
	$map = GUICtrlCreatePic("map.bmp", $mainWinPos[2] - 500 - 10, 5, 500, 430)
	GUICtrlSetResizing(-1, 4 + 32 + 256 + 512)
	GUICtrlSetState(-1, $GUI_DISABLE)
	Dim $pic[$COM[0]]
	Dim $lableAuto[$COM[0]]
	For $i = 0 To $COM[0] - 1
		$pic[$i] = GUICtrlCreatePic(@ScriptDir & "\img\disable.bmp", $mainWinPos[2] - 500 - 11 + $posX + $objX[$i] - 20 + 10, $posY + $objY[$i] - 20 - 3, 20, 20)
		GUICtrlSetResizing(-1, 4 + 32 + 256 + 512)
		If $auto[$i] = 1 Then
			GUICtrlSetImage(-1, @ScriptDir & "\img\normal.bmp")
		EndIf
		If $auto[$i] = 1 And $TC[$i] > $TP[$i] Then
			GUICtrlSetImage($pic[$i], @ScriptDir & "\img\critical.bmp")
		EndIf
		GUICtrlSetState($pic[$i], $GUI_SHOW)
	Next
EndFunc   ;==>map
