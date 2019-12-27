Func menufileadd()
	$mainWinPos = WinGetPos($mainWin)
	$optionWinWidth = 504
	$optionWinHeight = 600
	$optionWinPosX = $mainWinPos[0] + $mainWinPos[2] / 2 - $optionWinWidth / 2
	$optionWinPosY = $mainWinPos[1] + $mainWinPos[3] / 2 - $optionWinHeight / 2
	$optionWin = GUICreate("Добавление объекта - " & $programmName, $optionWinWidth, $optionWinHeight, $optionWinPosX, $optionWinPosY, 0x94C820C4, 0x00010501, $mainWin) ;Окно "Добавление объекта"
	$addposobjX = 0
	$addposobjY = 0
	GUICtrlCreateLabel("COM порт:", 21, 12)
	$inputCom = GUICtrlCreateCombo("", 121, 8, 130, 20, $CBS_DROPDOWNLIST)
	For $i = 2 To 255
		$k = 0
		For $j = 1 To $COM[0]
			If String("COM" & $i) = $COM[$j] Then
				$k = 1
				ExitLoop
			EndIf
		Next
		If $k = 0 Then
			GUICtrlSetData(-1, "COM" & $i)
		EndIf
	Next
	$maskIP = IniRead($fileOptions, "main", "mask", "0.0.0.0")
	;Проверка IP-адреса
	$checkIP = StringSplit($maskIP, ".")
	$checkIPfail = 0
	If $checkIP[0] <> 4 Then
		$maskIP = "0.0.0.0"
	Else
		For $j = 1 To 3
			If $checkIP[$j] > 255 Or $checkIP[$j] < 0 Then
				$checkIP[$j] = 0
			EndIf
			$checkIPchar = StringSplit($checkIP[$j], "")
			For $k = 1 To $checkIPchar[0]
				If Asc($checkIPchar[$k]) < 48 Or Asc($checkIPchar[$k]) > 57 Then
					$checkIP[$j] = 0
					ExitLoop (2)
				EndIf
			Next
		Next
		$maskIP = $checkIP[1] & "." & $checkIP[2] & "." & $checkIP[3] & ".0"
	EndIf
	;Конец проверки IP-адреса
	$maskIPpart = StringSplit($maskIP, ".")
	GUICtrlCreateLabel("IP-адрес:", 21, 39, 100, 21, 0x50020000, 0x00000004)
	$inputIP1 = GUICtrlCreateInput($maskIPpart[1], 121, 36, 30, 21, 0x2001)
	GUICtrlSetLimit(-1, 3)
	GUICtrlCreateLabel(".", 154, 39, 7, 21, 0x50020000, 0x00000004)
	$inputIP2 = GUICtrlCreateInput($maskIPpart[2], 161, 36, 30, 21, 0x2001)
	GUICtrlSetLimit(-1, 3)
	GUICtrlCreateLabel(".", 194, 39, 7, 21, 0x50020000, 0x00000004)
	$inputIP3 = GUICtrlCreateInput($maskIPpart[3], 201, 36, 30, 21, 0x2001)
	GUICtrlSetLimit(-1, 3)
	GUICtrlCreateLabel(".", 234, 39, 7, 21, 0x50020000, 0x00000004)
	$inputIP4 = GUICtrlCreateInput("0", 241, 36, 30, 21, 0x2001)
	GUICtrlSetLimit(-1, 3)
	GUICtrlCreateLabel("Имя объекта:", 21, 67)
	$inputObj = GUICtrlCreateInput("", 121, 64, 130)
	GUICtrlCreateLabel("Укажите местоположение объекта на карте", 21, 91)
	$addmaplabel = GUICtrlCreateLabel("", 1, 110, 502, 432, $SS_SUNKEN)
	$addmap = GUICtrlCreatePic("map.bmp", 2, 111, 0, 0)
	GUICtrlSetState($addmap, $GUI_SHOW)
	$addmappic = GUICtrlCreatePic(@ScriptDir & "\img\normal.bmp", 2, 111, 0, 0)
	GUICtrlSetState($addmappic, $GUI_HIDE)
	$add = GUICtrlCreateButton("Добавить", 152, 557, 80)
	$cancel = GUICtrlCreateButton("Отмена", 272, 557, 80)
	GUISwitch($optionWin)
	GUISetState(@SW_SHOW)
	While 1
		$msg = GUIGetMsg(1)
		Select
			Case $msg[0] = $GUI_EVENT_CLOSE ;X
				If $msg[1] = $optionWin Then
					GUISwitch($optionWin)
					GUIDelete()
					ExitLoop
				ElseIf $msg[1] = $mainWin Then
					GUISwitch($mainWin)
					GUIDelete()
					Exit
				EndIf
			Case $msg[0] = $cancel And $msg[1] = $optionWin ;Отмена
				GUISwitch($optionWin)
				GUIDelete()
				ExitLoop
			Case $msg[0] = $addmaplabel And $msg[1] = $optionWin ;Положение объекта на карте
				$addposmap = WinGetPos("Добавление объекта - " & $programmName)
				;MsgBox(0,$addposmap[0],$addposmap[1])
				$addposmouse = MouseGetPos()
				$addposobjX = $addposmouse[0] - $addposmap[0] - 2 - 10
				$addposobjY = $addposmouse[1] - $addposmap[1] - 21 - 10
				If $addposobjX < 2 Then $addposobjX = 2
				If $addposobjX > 482 Then $addposobjX = 482
				If $addposobjY < 111 Then $addposobjY = 111
				If $addposobjY > 521 Then $addposobjY = 521
				GUICtrlSetPos($addmappic, $addposobjX, $addposobjY)
				GUICtrlSetState($addmappic, $GUI_SHOW)
			Case $msg[0] = $add And $msg[1] = $optionWin ;Добавить
				$addobj = GUICtrlRead($inputObj)
				$addCOM = GUICtrlRead($inputCom)
				$addrIP = GUICtrlRead($inputIP1) & "." & GUICtrlRead($inputIP2) & "." & GUICtrlRead($inputIP3) & "." & GUICtrlRead($inputIP4)
				Select
					Case $addCOM = ""
						GUISetState(@SW_DISABLE)
						MsgBox(0x40000, "Подсказка", "Выберите COM-порт для связи с объектом.")
						GUISetState(@SW_ENABLE)
					Case $addrIP = $maskIP
						GUISetState(@SW_DISABLE)
						MsgBox(0x40000, "Подсказка", "Некорректный IP-адрес.")
						GUISetState(@SW_ENABLE)
					Case GUICtrlRead($inputIP1) > 255 Or GUICtrlRead($inputIP2) > 255 Or GUICtrlRead($inputIP3) > 255 Or GUICtrlRead($inputIP4) > 255
						GUISetState(@SW_DISABLE)
						MsgBox(0x40000, "Подсказка", "Некорректный IP-адрес.")
						GUISetState(@SW_ENABLE)
					Case $addobj = ""
						GUISetState(@SW_DISABLE)
						MsgBox(0x40000, "Подсказка", "Введите название добовляемого объекта.")
						GUISetState(@SW_ENABLE)
					Case $addposobjX = 0 Or $addposobjY = 0
						GUISetState(@SW_DISABLE)
						MsgBox(0x40000, "Подсказка", "Укажите местоположение объекта на карте.")
						GUISetState(@SW_ENABLE)
					Case Else
						IniWriteSection($fileNetwork, $addCOM, "name=" & $addobj & @LF & "IP=" & $addrIP & @LF & "mapX=" & ($addposobjX - 2 + 9) & @LF & "mapY=" & ($addposobjY - 111 + 23))
						newevent($addobj & " (" & $addCOM & ")|Добавлен новый объект")
						GUIDelete()
						ExitLoop
				EndSelect
		EndSelect
	WEnd
EndFunc   ;==>menufileadd

Func menufiledel()
	$mainWinPos = WinGetPos($mainWin)
	$optionWinWidth = 300
	$optionWinHeight = 150
	$optionWinPosX = $mainWinPos[0] + $mainWinPos[2] / 2 - $optionWinWidth / 2
	$optionWinPosY = $mainWinPos[1] + $mainWinPos[3] / 2 - $optionWinHeight / 2
	$optionWin = GUICreate("Удаление объекта - " & $programmName, $optionWinWidth, $optionWinHeight, $optionWinPosX, $optionWinPosY, 0x94C820C4, 0x00010501, $mainWin) ;Окно "Удаление объекта"
	GUICtrlCreateLabel("Объект:", 50, 25)
	$combofiledel = GUICtrlCreateCombo("", 100, 20, 150, 20, $CBS_DROPDOWNLIST)
	For $i = 0 To $COM[0] - 1
		GUICtrlSetData(-1, $name[$i] & " (" & $COM[$i + 1] & ")")
	Next
	$del = GUICtrlCreateButton("Удалить", 50, 80, 80)
	$cancel = GUICtrlCreateButton("Отмена", 170, 80, 80)
	GUISwitch($optionWin)
	GUISetState(@SW_SHOW)
	While 1
		$msg = GUIGetMsg(1)
		Select
			Case $msg[0] = $GUI_EVENT_CLOSE ;X
				If $msg[1] = $optionWin Then
					GUISwitch($optionWin)
					GUIDelete()
					ExitLoop
				ElseIf $msg[1] = $mainWin Then
					GUISwitch($mainWin)
					GUIDelete()
					Exit
				EndIf
			Case $msg[0] = $cancel And $msg[1] = $optionWin ;Отмена
				GUISwitch($optionWin)
				GUIDelete()
				ExitLoop
			Case $msg[0] = $del And $msg[1] = $optionWin ;Удалить
				$delobj = GUICtrlRead($combofiledel)
				If $delobj = "" Then
					GUISetState(@SW_DISABLE)
					MsgBox(0x40000, "Подсказка", "Сначала выберите объект который необходимо удалить.")
					GUISetState(@SW_ENABLE)
				Else
					GUISetState(@SW_DISABLE)
					$user = MsgBox(0x40124, "Внимание!", "Вы действительно хотите удалить объект " & $delobj & "?")
					GUISetState(@SW_ENABLE)
					If $user = 6 Then
						$delCOM = StringSplit($delobj, " (", 1)
						$delCOMN = StringTrimRight($delCOM[2], 1)
						IniDelete($fileNetwork, $delCOMN)
						newevent($delobj & "|Объект удален")
						GUIDelete()
						ExitLoop
					EndIf
				EndIf
		EndSelect
	WEnd
EndFunc   ;==>menufiledel
