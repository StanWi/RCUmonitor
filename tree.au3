Func tree()
	Global $maintreeview
	Global $treeview, $territory, $treeunit
	Global $refreshstatusitem, $refreshitem, $refreshdata
	Dim $territory[$COM[0]], $treeunit[$COM[0]][32]
	Dim $contextterritory[$COM[0]]
	Dim $refreshstatusitem[$COM[0]], $refreshitem[$COM[0]], $refreshdata[$COM[0]]
	$mainWinPos = WinGetPos($mainWin)
	$maintreeview = GUICtrlCreateTreeView(1, 38, $mainWinPos[2] - 500 - 14, 398, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
	GUICtrlSetResizing(-1, 2 + 4 + 32 + 512)
	$treeview = GUICtrlCreateTreeViewItem(IniRead($fileOptions, "main", "name", "Без имени"), $maintreeview)
	For $i = 0 To $COM[0] - 1
		$territory[$i] = GUICtrlCreateTreeViewItem($name[$i], $treeview)
		GUICtrlSetColor(-1, 0xc0c0c0)
		$contextterritory[$i] = GUICtrlCreateContextMenu($territory[$i])
		$refreshitem[$i] = GUICtrlCreateMenuItem("Обновить конфигурацию", $contextterritory[$i])
		$refreshdata[$i] = GUICtrlCreateMenuItem("Обновить данные", $contextterritory[$i])
		$refreshstatusitem[$i] = GUICtrlCreateMenuItem("Автообновление", $contextterritory[$i])
		If $auto[$i] = 1 Then
			GUICtrlSetState(-1, $GUI_CHECKED)
			GUICtrlSetColor($territory[$i], 0x000000)
			If $TC[$i] > $TP[$i] Then
				GUICtrlSetColor($territory[$i], 0xff0000)
			EndIf
		EndIf
		For $j = 1 To 31
			$treeunit[$i][$j] = -1
			If $unit[$i][$j] <> "" Then
				$treeunit[$i][$j] = GUICtrlCreateTreeViewItem($unit[$i][$j], $territory[$i])
			EndIf
		Next
	Next
	GUICtrlSetState($treeview, BitOR($GUI_EXPAND, $GUI_DEFBUTTON))
EndFunc   ;==>tree
