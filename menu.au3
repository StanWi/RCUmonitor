Func menu()

	Global $additem, $edititem, $delitem, $exititem, $servicepingitem, $serviceoptionitem, $servicemonitoritem, $infoitem
	Global $start, $expand, $deexpand

	$filemenu = GUICtrlCreateMenu("&Файл")
	$additem = GUICtrlCreateMenuItem("&Добавить...", $filemenu)
	$edititem = GUICtrlCreateMenuItem("&Редактировать...", $filemenu)
	GUICtrlSetState(-1, $GUI_Disable)
	$delitem = GUICtrlCreateMenuItem("&Удалить...", $filemenu)
	$exititem = GUICtrlCreateMenuItem("В&ыход", $filemenu)

	$servmenu = GUICtrlCreateMenu("С&ервис")
	$servicepingitem = GUICtrlCreateMenuItem("&Пинг...", $servmenu)
	$serviceoptionitem = GUICtrlCreateMenuItem("&Настройка...", $servmenu)
	$servicemonitoritem = GUICtrlCreateMenuItem("&Мониторинг", $servmenu)
	If IniRead($fileOptions, "main", "auto", 0) = 1 Then
		GUICtrlSetState(-1, $GUI_CHECKED)
	Else
		GUICtrlSetState(-1, $GUI_UNCHECKED)
	EndIf

	$helpmenu = GUICtrlCreateMenu("&Справка")
	$infoitem = GUICtrlCreateMenuItem("&О программе", $helpmenu)

	$mainWinPos = WinGetPos($mainWin)
	GUICtrlCreateLabel("", 1, 0, $mainWinPos[2] - 10, 2, $SS_SUNKEN)
	GUICtrlSetResizing(-1, 2 + 4 + 32 + 512)

	$start = GUICtrlCreateButton("Start", 1, 4, 28, 28, $BS_BITMAP, 0)
	GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)
	If IniRead($fileOptions, "main", "auto", 0) = 1 Then
		GUICtrlSetImage(-1, @ScriptDir & "/img/btn_stop.bmp")
	Else
		GUICtrlSetImage(-1, @ScriptDir & "/img/btn_start.bmp")
	EndIf
	GUICtrlCreateLabel("", 31, 4, 2, 28, $SS_SUNKEN)
	GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)
	$expand = GUICtrlCreateButton("+", 35, 4, 28, 28, $BS_BITMAP, 0)
	GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)
	GUICtrlSetImage(-1, @ScriptDir & "/img/btn_expand.bmp")
	$deexpand = GUICtrlCreateButton("-", 65, 4, 28, 28, $BS_BITMAP, 0)
	GUICtrlSetResizing(-1, 2 + 32 + 256 + 512)
	GUICtrlSetImage(-1, @ScriptDir & "/img/btn_deexpand.bmp")

	GUICtrlCreateLabel("", 1, 34, $mainWinPos[2] - 514, 2, $SS_SUNKEN)
	GUICtrlSetResizing(-1, 2 + 4 + 32 + 512)
EndFunc   ;==>menu
