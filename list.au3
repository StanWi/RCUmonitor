Func list()
	Global $list
	If Not (FileExists(@ScriptDir & "\" & $fileEvents)) Then
		$user = MsgBox(0x40114, "Ошибка", "Отсутствует файл журнала." & @CRLF & "Создать новый?")
		If $user = 6 Then
			_FileCreate(@ScriptDir & "\" & $fileEvents)
			$fileList = FileOpen(@ScriptDir & "\" & $fileEvents, 1)
			FileWriteLine($fileList, date() & "||Создан новый файл журнала")
			FileClose($fileList)
		Else
			Exit
		EndIf
	EndIf
	$mainWinPos = WinGetPos($mainWin)
	$deltaX = $mainWinPos[2]
	$deltaY = $mainWinPos[3]
	$list = GUICtrlCreateListView("Время|Объект|Событие", 1, 438, $deltaX - 9, $deltaY - 484, $BS_FLAT, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
	GUICtrlSetResizing(-1, 2 + 4 + 32 + 64)
	_GUICtrlListView_SetColumnWidth($list, 0, 150)
	_GUICtrlListView_SetColumnWidth($list, 1, 200)
	_GUICtrlListView_SetColumnWidth($list, 2, 300)
	$fileList = FileOpen(@ScriptDir & "\" & $fileEvents, 0)
	$nLines = _FileCountLines(@ScriptDir & "\" & $fileEvents)
	Dim $line[$nLines]
	For $i = 0 To $nLines - 1
		$line[$i] = FileReadLine($fileList)
	Next
	For $i = $nLines - 1 To 0 Step -1
		GUICtrlCreateListViewItem($line[$i], $list)
	Next
	FileClose($fileList)
EndFunc   ;==>list

Func newevent($event)
	$newevent = date() & "|" & $event
	$fileList = FileOpen(@ScriptDir & "\" & $fileEvents, 1)
	FileWriteLine($fileList, $newevent)
	FileClose($fileList)
	GUICtrlCreateListViewItem($newevent, $list)
EndFunc   ;==>newevent

Func date()
	Select
		Case @MON = 1
			$mon = "Янв"
		Case @MON = 2
			$mon = "Фев"
		Case @MON = 3
			$mon = "Мар"
		Case @MON = 4
			$mon = "Апр"
		Case @MON = 5
			$mon = "Май"
		Case @MON = 6
			$mon = "Июн"
		Case @MON = 7
			$mon = "Июл"
		Case @MON = 8
			$mon = "Авг"
		Case @MON = 9
			$mon = "Сен"
		Case @MON = 10
			$mon = "Окт"
		Case @MON = 11
			$mon = "Ноя"
		Case @MON = 12
			$mon = "Дек"
	EndSelect
	$date = $mon & " " & @MDAY & " " & @YEAR & " " & @HOUR & ":" & @MIN & ":" & @SEC
	Return $date
EndFunc   ;==>date
