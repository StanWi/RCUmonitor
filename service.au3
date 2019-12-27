;Меню -> Сервис

Func serviceoption() ;Меню -> Сервис -> Настройка...
	$mainWinPos = WinGetPos($mainWin)
	$optionWinWidth = 404 - 6
	$optionWinHeight = 448 - 25
	$optionWinPosX = $mainWinPos[0] + $mainWinPos[2] / 2 - $optionWinWidth / 2
	$optionWinPosY = $mainWinPos[1] + $mainWinPos[3] / 2 - $optionWinHeight / 2
	$optionWin = GUICreate("Настройка - " & $programmName, $optionWinWidth, $optionWinHeight, $optionWinPosX, $optionWinPosY, 0x84C820C4, 0x00010501, $mainWin) ;Окно "Настройка"
	$tab = GUICtrlCreateTab(6, 7, 386, 380)
	$tabMain = GUICtrlCreateTabItem("Общее") ;Вкладка "Общее"
	GUICtrlCreateLabel("Имя сети:", 21, 43, 100, 21, 0x50020000, 0x00000004)
	$input1 = GUICtrlCreateInput(IniRead($fileOptions, "main", "name", "Без имени"), 121, 40, 100, 21)
	GUICtrlSetLimit(-1, 255)
	$maskIP = IniRead($fileOptions, "main", "mask", "0.0.0.0")
	;Проверка IP-адреса маски
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
	;Конец проверки IP-адреса маски
	$maskIPpart = StringSplit($maskIP, ".")
	GUICtrlCreateLabel("Маска подсети:", 21, 71, 100, 21, 0x50020000, 0x00000004)
	$inputIP1 = GUICtrlCreateInput($maskIPpart[1], 121, 68, 30, 21, 0x2001)
	GUICtrlSetLimit(-1, 3)
	GUICtrlCreateLabel(".", 154, 71, 7, 21, 0x50020000, 0x00000004)
	$inputIP2 = GUICtrlCreateInput($maskIPpart[2], 161, 68, 30, 21, 0x2001)
	GUICtrlSetLimit(-1, 3)
	GUICtrlCreateLabel(".", 194, 71, 7, 21, 0x50020000, 0x00000004)
	$inputIP3 = GUICtrlCreateInput($maskIPpart[3], 201, 68, 30, 21, 0x2001)
	GUICtrlSetLimit(-1, 3)
	GUICtrlCreateLabel(".", 234, 71, 7, 21, 0x50020000, 0x00000004)
	GUICtrlCreateInput("0", 241, 68, 30, 21, 0x2801)
	GUICtrlCreateLabel("Макс. пинг (мс):", 21, 99, 100, 21, 0x50020000, 0x00000004)
	$input2 = GUICtrlCreateInput(IniRead($fileOptions, "main", "ping", 250), 121, 96, 40, 21, 0x2000)
	GUICtrlSetLimit(-1, 5)
	;	$tabPath = GUICtrlCreateTabitem("Пути") ;Вкладка "Пути"
	$tabFrsh = GUICtrlCreateTabItem("Обновление") ;Вкладка "Обновление"
	$frsh = IniRead($fileOptions, "main", "refresh", 0)
	If $frsh > 63 Then
		MsgBox(8208, "Микротек RCU-1 (Ethernet)", "Файл настроек поврежден!" & @CRLF & @CRLF _
				 & "Проверьте все настройки заново.", 5)
	EndIf
	$tabFrshX1 = 30
	$tabFrshX2 = 120
	$tabFrshY1 = 60
	$tabFrshY2 = 90
	$tabFrshY3 = 120
	Dim $frshEx[6]
	For $i = 5 To 0 Step -1
		If $frsh >= 2 ^ $i Then
			$frshEx[$i] = 1
			$frsh = $frsh - 2 ^ $i
		Else
			$frshEx[$i] = 0
		EndIf
	Next
	$tabFrshData = GUICtrlCreateCheckbox("Данные", $tabFrshX1, $tabFrshY1)
	If $frshEx[0] = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
	$tabFrshStat = GUICtrlCreateCheckbox("Статус", $tabFrshX1, $tabFrshY2)
	If $frshEx[1] = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
	$tabFrshAlrm = GUICtrlCreateCheckbox("Отказы", $tabFrshX1, $tabFrshY3)
	If $frshEx[2] = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
	$tabFrshLmts = GUICtrlCreateCheckbox("Пороги", $tabFrshX2, $tabFrshY1)
	If $frshEx[3] = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
	$tabFrshSnum = GUICtrlCreateCheckbox("Сер. №", $tabFrshX2, $tabFrshY2)
	If $frshEx[4] = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
	$tabFrshMode = GUICtrlCreateCheckbox("Мод.,каналы", $tabFrshX2, $tabFrshY3)
	If $frshEx[5] = 1 Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlCreateTabItem("")
	$ok = GUICtrlCreateButton("OK", 155, 393, 75, 23, 0x50030001, 0x00000004)
	$cancel = GUICtrlCreateButton("Отмена", 236, 393, 75, 23, 0x50030000, 0x00000004)
	$apply = GUICtrlCreateButton("При&менить", 317, 393, 75, 23, 0x50030000, 0x00000004)
	GUISetState(@SW_SHOW)
	GUISwitch($optionWin)
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
			Case $msg[0] = $ok And $msg[1] = $optionWin ;ОК
				Select
					Case GUICtrlRead($inputIP1) > 255 Or GUICtrlRead($inputIP2) > 255 Or GUICtrlRead($inputIP3) > 255
						GUISetState(@SW_DISABLE)
						MsgBox(0x40000, "Подсказка", "Некорректная маска подсети.")
						GUISetState(@SW_ENABLE)
					Case Else
						IniWrite($fileOptions, "main", "name", GUICtrlRead($input1))
						GUISwitch($mainWin)
						GUICtrlSetData($treeview, GUICtrlRead($input1))
						GUISwitch($optionWin)
						$mask = GUICtrlRead($inputIP1) & "." & GUICtrlRead($inputIP2) & "." & GUICtrlRead($inputIP3) & ".0"
						IniWrite($fileOptions, "main", "mask", $mask)
						IniWrite($fileOptions, "main", "ping", GUICtrlRead($input2))
						;Вкладка "Обновление"
						$frsh = 0
						If GUICtrlRead($tabFrshData) = $GUI_CHECKED Then $frsh = $frsh + 1
						If GUICtrlRead($tabFrshStat) = $GUI_CHECKED Then $frsh = $frsh + 2
						If GUICtrlRead($tabFrshAlrm) = $GUI_CHECKED Then $frsh = $frsh + 4
						If GUICtrlRead($tabFrshLmts) = $GUI_CHECKED Then $frsh = $frsh + 8
						If GUICtrlRead($tabFrshSnum) = $GUI_CHECKED Then $frsh = $frsh + 16
						If GUICtrlRead($tabFrshMode) = $GUI_CHECKED Then $frsh = $frsh + 32
						IniWrite($fileOptions, "main", "refresh", $frsh)
						GUIDelete()
						ExitLoop
				EndSelect
			Case $msg[0] = $cancel And $msg[1] = $optionWin ;Отмена
				GUISwitch($optionWin)
				GUIDelete()
				ExitLoop
			Case $msg[0] = $apply And $msg[1] = $optionWin ;Применить
				Select
					Case GUICtrlRead($inputIP1) > 255 Or GUICtrlRead($inputIP2) > 255 Or GUICtrlRead($inputIP3) > 255
						GUISetState(@SW_DISABLE)
						MsgBox(0x40000, "Подсказка", "Некорректная маска подсети.")
						GUISetState(@SW_ENABLE)
					Case Else
						IniWrite($fileOptions, "main", "name", GUICtrlRead($input1))
						GUISwitch($mainWin)
						GUICtrlSetData($treeview, GUICtrlRead($input1))
						GUISwitch($optionWin)
						$mask = GUICtrlRead($inputIP1) & "." & GUICtrlRead($inputIP2) & "." & GUICtrlRead($inputIP3) & ".0"
						IniWrite($fileOptions, "main", "mask", $mask)
						IniWrite($fileOptions, "main", "ping", GUICtrlRead($input2))
						;Вкладка "Обновление"
						$frsh = 0
						If GUICtrlRead($tabFrshData) = $GUI_CHECKED Then $frsh = $frsh + 1
						If GUICtrlRead($tabFrshStat) = $GUI_CHECKED Then $frsh = $frsh + 2
						If GUICtrlRead($tabFrshAlrm) = $GUI_CHECKED Then $frsh = $frsh + 4
						If GUICtrlRead($tabFrshLmts) = $GUI_CHECKED Then $frsh = $frsh + 8
						If GUICtrlRead($tabFrshSnum) = $GUI_CHECKED Then $frsh = $frsh + 16
						If GUICtrlRead($tabFrshMode) = $GUI_CHECKED Then $frsh = $frsh + 32
						IniWrite($fileOptions, "main", "refresh", $frsh)
				EndSelect
		EndSelect
	WEnd
EndFunc   ;==>serviceoption

Func serviceping() ;Меню -> Сервис -> Пинг...
	$mainWinPos = WinGetPos($mainWin)
	$optionWinWidth = 404 - 6
	$optionWinHeight = 130 + $COM[0] * 19 - 25
	$optionWinPosX = $mainWinPos[0] + $mainWinPos[2] / 2 - $optionWinWidth / 2
	$optionWinPosY = $mainWinPos[1] + $mainWinPos[3] / 2 - $optionWinHeight / 2
	$optionWin = GUICreate("Пинг - " & $programmName, $optionWinWidth, $optionWinHeight, $optionWinPosX, $optionWinPosY, 0x94C820C4, 0x00010501, $mainWin) ;Окно "Настройка"
	GUICtrlCreateGroup("Время отклика УУ в сети " & IniRead($fileOptions, "main", "name", "Без имени"), 6, 13, 386, 56 + $COM[0] * 19)
	Dim $ping[$COM[0]], $checkIPfail[$COM[0]]
	GUICtrlCreateLabel("Объект", 21, 33, 150, 21, 0x50020000, 0x00000004)
	GUICtrlSetFont(-1, 8.5, 800)
	GUICtrlCreateLabel("IP-адрес", 211, 33, 90, 21, 0x50020000, 0x00000004)
	GUICtrlSetFont(-1, 8.5, 800)
	GUICtrlCreateLabel("Пинг", 311, 33, 70, 33, 0x50020000, 0x00000004)
	GUICtrlSetFont(-1, 8.5, 800)
	For $i = 0 To $COM[0] - 1
		GUICtrlCreateLabel($name[$i] & " (" & $COM[$i + 1] & ")", 21, 61 + $i * 19, 150, 21, 0x50020000, 0x00000004)
		GUICtrlCreateLabel($IP[$i], 211, 61 + $i * 19, 90, 21, 0x50020000, 0x00000004)
		;Проверка IP-адреса
		$checkIP = StringSplit($IP[$i], ".")
		$checkIPfail[$i] = 0
		If $checkIP[0] <> 4 Then
			$checkIPfail[$i] = 1
		Else
			For $j = 1 To 4
				If $checkIP[$j] > 255 Or $checkIP[$j] < 0 Then
					$checkIPfail[$i] = 1
					ExitLoop
				EndIf
				$checkIPchar = StringSplit($checkIP[$j], "")
				For $k = 1 To $checkIPchar[0]
					If Asc($checkIPchar[$k]) < 48 Or Asc($checkIPchar[$k]) > 57 Then
						$checkIPfail[$i] = 1
						ExitLoop (2)
					EndIf
				Next
			Next
		EndIf
		;Конец проверки IP-адреса
		If $IP[$i] <> "N/A" And $checkIPfail[$i] <> 1 Then
			$ping[$i] = GUICtrlCreateLabel("Ждите...", 311, 61 + $i * 19, 70, 21, 0x50020000, 0x00000004)
		Else
			$ping[$i] = GUICtrlCreateLabel("Ошибка", 311, 61 + $i * 19, 70, 21, 0x50020000, 0x00000004)
			GUICtrlSetTip(-1, "Неверный IP-адрес: """ & $IP[$i] & """")
		EndIf
	Next
	$close = GUICtrlCreateButton("&Закрыть", 317, 75 + $COM[0] * 19, 75, 23, 0x50030000, 0x00000004)
	GUISetState(@SW_SHOW)
	GUISwitch($optionWin)
	While 1
		For $i = 0 To $COM[0] - 1
			$msg = GUIGetMsg(1)
			Select
				Case $msg[0] = $GUI_EVENT_CLOSE ;X
					If $msg[1] = $optionWin Then
						GUISwitch($optionWin)
						GUIDelete()
						ExitLoop (2)
					ElseIf $msg[1] = $mainWin Then
						GUISwitch($mainWin)
						GUIDelete()
						Exit
					EndIf
				Case $msg[0] = $close And $msg[1] = $optionWin ;Закрыть
					GUISwitch($optionWin)
					GUIDelete()
					ExitLoop (2)
			EndSelect
			If $IP[$i] <> "N/A" And $checkIPfail[$i] <> 1 Then
				$ms = Ping($IP[$i], $sysPing)
				$error = @error
				If $ms <> 0 Then
					GUICtrlSetData($ping[$i], $ms & " мс")
				Else
					GUICtrlSetData($ping[$i], "Не отвечает")
					Select
						Case $error = 1
							GUICtrlSetTip($ping[$i], "Хост в автономном режиме")
						Case $error = 2
							GUICtrlSetTip($ping[$i], "Хост недостижим")
						Case $error = 3
							GUICtrlSetTip($ping[$i], "Хост неверно указан")
						Case $error = 4
							GUICtrlSetTip($ping[$i], "Неизвестная ошибка")
					EndSelect
				EndIf
			EndIf
		Next
	WEnd
EndFunc   ;==>serviceping
