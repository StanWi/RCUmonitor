Func uu($i)
	Global $form, $groupInfo, $lableID, $inputID, $lableSN, $inputSN, $lableAuto
	Global $groupTemp, $lableTemp, $inputTemp, $lableLimit, $inputLimit, $progress
	Global $unitlist
	$mainWinPos = WinGetPos($mainWin)
	$deltaX = $mainWinPos[2] - 500 - 11 - 197
	$form = GUICtrlCreateGroup($name[$i] & " (" & $COM[$i + 1] & ")", $deltaX + 197, 6, 502, 430)
	GUICtrlSetResizing(-1, 4 + 32 + 256 + 512)
	$groupInfo = GUICtrlCreateGroup("Р
EndFunc   ;==>uu
