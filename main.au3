Func main() ;создание главного окна программы
	Global $mainWin, $programmName
	$winw = IniRead($fileOptions, "main", "winw", 700)
	$winh = IniRead($fileOptions, "main", "winh", 700)
	$winx = IniRead($fileOptions, "main", "winx", Round((@DesktopWidth - $winw) / 2))
	$winy = IniRead($fileOptions, "main", "winy", Round((@DesktopHeight - $winh) / 2))
	If $winw > @DesktopWidth Then $winw = @DesktopWidth
	If $winh > @DesktopHeight Then $winh = @DesktopHeight
	If $winx < 0 Then $winx = 0
	If $winx + $winw > @DesktopWidth Then $winx = @DesktopWidth - $winw
	If $winy < 0 Then $winy = 0
	If $winy + $winh > @DesktopHeight Then $winy = @DesktopHeight - $winh
	$mainWin = GUICreate($programmName, $winw - 8, $winh - 27, $winx, $winy, BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX, $WS_SYSMENU))
EndFunc   ;==>main

Func close() ;сохранение размеров и позиции главного окна
	$pos = WinGetPos($programmName)
	IniWrite($fileOptions, "main", "winw", $pos[2])
	IniWrite($fileOptions, "main", "winh", $pos[3])
	IniWrite($fileOptions, "main", "winx", $pos[0])
	IniWrite($fileOptions, "main", "winy", $pos[1])
EndFunc   ;==>close
