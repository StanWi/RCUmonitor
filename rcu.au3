#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=img\rcu.ico
#AutoIt3Wrapper_Outfile=rcu.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=for support mail to 
#AutoIt3Wrapper_Res_Description=Microtech RCU-1 (Ethernet)
#AutoIt3Wrapper_Res_Fileversion=0.0.1.0
#AutoIt3Wrapper_Res_LegalCopyright=
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

$licYear = 2025
$licMon = 01
$licDay = 01
If @YEAR >= $licYear Then
	Exit
EndIf

; Threshold Low Pre-warning Low Pre-warining High High

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <TreeViewConstants.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <GuiListView.au3>
#include <Array.au3>
#include <string.au3>
#include <CommMG.au3>
#include <EzMySql.au3>
#include <secret.au3>

; =====External Files=====
;~ $fileOptions = @ScriptDir & "\options.ini"
;~ $fileNetwork = @ScriptDir & "\network.ini"
;~ $fileEvents = @ScriptDir & "\events.log" ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Delete
$fileIcon = @ScriptDir & "\img\rcu.ico"
$fileMapPic = @ScriptDir & "\map.bmp"
$fileMapIconNormal = @ScriptDir & "\img\normal.bmp"
$fileMapIconMinor = @ScriptDir & "\img\minor.bmp"
$fileMapIconCritical = @ScriptDir & "\img\critical.bmp"
$fileMapIconDisable = @ScriptDir & "\img\disable.bmp"
$fileAboutLogo = @ScriptDir & "\img\logo.bmp"
$file_monitor = @ScriptDir & "\rcumonitor.exe"
$file_commg = @ScriptDir & "\commg.dll"

If Not _EzMySql_Startup() Then
	MsgBox(0, 'Error Starting MySql', 'Error: ' & @error & @CR & 'Error string: ' & _EzMySql_ErrMsg())
	Exit
EndIf

If Not _EzMySql_Open($host, $user, $password, 'rcu', 3306) Then
	$error = @error
	MsgBox(0, 'Error - RCU', 'Error: ' & $error & @CR & 'Description: ' & _EzMySql_ErrMsg())
	Exit
EndIf
_EzMySql_Exec("SET NAMES 'cp1251'")
_EzMySql_Exec("SET CHARACTER SET 'cp1251'")

_EzMySql_Query("SELECT company FROM main WHERE main_id = 1;")
$aResult = _EzMySql_FetchData()
Global $COMPANY = $aResult[0]

; =====Start=====
Select
	Case Not (FileExists($fileMapIconNormal))
		Exit
	Case Not (FileExists($fileMapPic))
		Exit
EndSelect

$programmName = "Microtech RCU-1 (Ethernet)"
$loadWin = GUICreate($programmName, 297, 60, -1, -1, $WS_POPUP)
GUISetIcon($fileIcon)
$loadPro = GUICtrlCreateProgress(10, 10, 277, 18)
$loadLab = GUICtrlCreateLabel("Загрузка данных...", 10, 35, 277, 20, $SS_CENTER)
GUISetState(@SW_SHOW, $loadWin)
GUICtrlSetData($loadPro, 0)

Global $programmName
Global $COM, $name, $IP, $auto, $posIcon
;~ Global $unit
Global $unit_name_list
Global $territory, $territoryMenu, $territoryMenuAuto, $territoryMenuRefresh, $territoryMenuData
Global $territoryUni
Global $maintreeview, $treeview
Global $mapPic, $mapLable, $mapIcon, $alarmStatus
Global $rcuGroup, $rcuInfo, $rcuInfoIDlable, $rcuInfoID, $rcuInfoSNlable, $rcuInfoSN
Global $rcuTemp, $rcuTempTPlable, $rcuTempTP, $rcuTempLMlable, $rcuTempLM, $rcuAuto, $rcuAutoOn, $rcuAutoOff, $rcuProgress
Global $uniGroup, $uniInfo, $uniInfoIDlable, $uniInfoID, $uniInfoSNlable, $uniInfoSN, $uniInfoDElable, $uniInfoDE, $uniList
Global $statusBarAlarm
Global $port
Global $lineList, $nList

; =====Constants=====
$dwinw = 8 ;погрешность определения ширины окна ($win[2] - $dwinw)
$dwinh = 27 ;погрешность определения высоты окна ($win[3] - $dwinh)
;$WS_MINIMIZEBOX	 = 0x00020000	;WindowsConstants.au3
;$WS_CAPTION		 = 0x00C00000	;WindowsConstants.au3
;$WS_POPUP			 = 0x80000000	;WindowsConstants.au3
;$WS_SYSMENU		 = 0x00080000	;WindowsConstants.au3
;$GUI_SS_DEFAULT_GUI = BitOR($WS_MINIMIZEBOX,$WS_CAPTION,$WS_POPUP,$WS_SYSMENU)	;WindowsConstants.au3
;$WS_MAXIMIZEBOX	 = 0x00010000	;WindowsConstants.au3
;$WS_SIZEBOX		 = 0x00040000	;WindowsConstants.au3
;ws_all = 0x00CF0000
;$SS_SUNKEN			 = 0x00001000	;StaticConstants.au3
;$TVS_HASBUTTONS	 = 0x00000001	;TreeViewConstants.au3
;$TVS_HASLINES		 = 0x00000002	;TreeViewConstants.au3
;$TVS_DISABLEDRAGDROP= 0x00000010	;TreeViewConstants.au3
;$TVS_SHOWSELALWAYS	 = 0x00000020	;TreeViewConstants.au3
;tvs_all = 0x00000033
;$WS_EX_CLIENTEDGE	 = 0x00000200	;WindowsConstants.au3
;$GUI_DEFBUTTON		 = 0x00000200	;GUIConstantsEx.au3
;$GUI_EXPAND		 = 0x00000400	;GUIConstantsEx.au3
;$ES_READONLY		 = 0x00000800	;EditConstants.au3
;$GUI_EVENT_CLOSE	 = -3			;GUIConstantsEx.au3
$btnw = 23 ;button width
$btnh = 22 ;button height
$mapw = 500 ;map height (min 300)
$maph = 430 ;map height (min 350)
$dy = 0
$dh = 0

; =====COM=====
Global $fPortOpen = False
Global $hDll

; =====Load=====
load()

;=====GUI start=====
GUICtrlSetData($loadPro, 10)
; ~~~~~Main~~~~~
Dim $win[4]
$win[2] = 1000
$win[3] = 800
$win[0] = Round((@DesktopWidth - $win[2]) / 2)
$win[1] = Round((@DesktopHeight - $win[3]) / 2)
$winz = DECtoBIN(Number('14'), 4)
If $win[2] > @DesktopWidth Then $win[2] = @DesktopWidth
If $win[3] > @DesktopHeight Then $win[3] = @DesktopHeight
If $win[0] < 0 Then $win[0] = 0
If $win[0] + $win[2] > @DesktopWidth Then $win[0] = @DesktopWidth - $win[2]
If $win[1] < 0 Then $win[1] = 0
If $win[1] + $win[3] > @DesktopHeight Then $win[1] = @DesktopHeight - $win[3]
If $winz[1] = 0 Then $dy = -28
If $winz[2] = 0 Then $dh = 20
$mainWin = GUICreate($programmName, ($win[2] - $dwinw), ($win[3] - $dwinh), $win[0], $win[1], BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX))
GUISetIcon($fileIcon)
GUICtrlSetData($loadPro, 20)
; ~~~~~Menu~~~~~
$menuFile = GUICtrlCreateMenu("&Файл")
$menuFileExit = GUICtrlCreateMenuItem("В&ыход", $menuFile)
$menuView = GUICtrlCreateMenu("&Вид")
$menuViewStyle = GUICtrlCreateMenu("&Оформление", $menuView)
$menuViewStyleClassic = GUICtrlCreateMenuItem("Классический стиль", $menuViewStyle)
$menuViewStyleWinXP = GUICtrlCreateMenuItem("Стиль Windows XP", $menuViewStyle)
If $winz[3] = 0 Then
	GUICtrlSetState($menuViewStyleClassic, $GUI_CHECKED)
	GUICtrlSetState($menuViewStyleWinXP, $GUI_UNCHECKED)
Else
	GUICtrlSetState($menuViewStyleClassic, $GUI_UNCHECKED)
	GUICtrlSetState($menuViewStyleWinXP, $GUI_CHECKED)
EndIf
$menuViewToolBar = GUICtrlCreateMenuItem("&Панель инструментов", $menuView)
If $winz[1] = 0 Then
	GUICtrlSetState($menuViewToolBar, $GUI_UNCHECKED)
Else
	GUICtrlSetState($menuViewToolBar, $GUI_CHECKED)
EndIf
$menuViewStatusBar = GUICtrlCreateMenuItem("&Строка состояния", $menuView)
If $winz[2] = 0 Then
	GUICtrlSetState($menuViewStatusBar, $GUI_UNCHECKED)
Else
	GUICtrlSetState($menuViewStatusBar, $GUI_CHECKED)
EndIf
$menuService = GUICtrlCreateMenu("С&ервис")
$menuServiceMonitoring = GUICtrlCreateMenuItem("&Мониторинг", $menuService)
If Not FileExists($file_monitor) Then
	GUICtrlSetState(-1, $GUI_DISABLE)
EndIf
$menuServiceHistory = GUICtrlCreateMenuItem("&История", $menuService)
$menuServicePing = GUICtrlCreateMenuItem("&Пинг...", $menuService)
;~ $menuServiceRefreshAll = GUICtrlCreateMenuItem("Обновить всю &сеть", $menuService)
;~ GUICtrlSetState(-1, $GUI_DISABLE)
;~ $menuServiceRefreshData = GUICtrlCreateMenuItem("Обновить данные всех &УУ", $menuService)
;~ GUICtrlSetState(-1, $GUI_DISABLE)
$menuHelp = GUICtrlCreateMenu("&Справка")
$menuHelpAbout = GUICtrlCreateMenuItem("&О программе", $menuHelp)
$menuLine = GUICtrlCreateLabel("", 0, 0, ($win[2] - $dwinw), 2, $SS_SUNKEN)
GUICtrlSetResizing(-1, 550)
GUICtrlSetData($loadPro, 30)
; ~~~~~ToolBar~~~~~
$toolBarBtn1 = GUICtrlCreateButton("Запустить мониторинг", 2, 4, $btnw + 150, $btnh)
$monitoring = 0
GUICtrlSetResizing(-1, 802)
If Not FileExists($file_monitor) Then
	GUICtrlSetState(-1, $GUI_DISABLE)
Else
	GUICtrlSetBkColor($toolBarBtn1, 0xFF0000)
EndIf
GUICtrlSetTip(-1, "Старт/Стоп")
$toolBarLine1 = GUICtrlCreateLabel("", 177, 4, 2, $btnh, $SS_SUNKEN)
GUICtrlSetResizing(-1, 802)
$toolBarBtn2 = GUICtrlCreateButton("+", 181, 4, $btnw, $btnh)
GUICtrlSetResizing(-1, 802)
GUICtrlSetTip(-1, "Развернуть")
$toolBarBtn3 = GUICtrlCreateButton("--", 206, 4, $btnw, $btnh)
GUICtrlSetResizing(-1, 802)
GUICtrlSetTip(-1, "Свернуть")
$toolBarLine = GUICtrlCreateLabel("", 0, 28, ($win[2] - $dwinw), 2, $SS_SUNKEN)
GUICtrlSetResizing(-1, 550)
If $winz[1] = 0 Then stateToolBar($GUI_HIDE)
GUICtrlSetData($loadPro, 40)
; ~~~~~Tree~~~~~
tree($dy)
setTree()
GUICtrlSetData($loadPro, 50)
; ~~~~~Map~~~~~
map($dy)
$treeLevel = 0
GUICtrlSetData($loadPro, 60)
; ~~~~~RCU-1~~~~~
$rcuGroup = GUICtrlCreateGroup("", $win[2] - $mapw - 12, 34 + $dy, $mapw + 4, $maph + 2)
GUICtrlSetResizing(-1, 804)
; Информация о УУ
$rcuInfo = GUICtrlCreateGroup("Информация об УУ", $win[2] - $mapw - 4, 50 + $dy, $mapw - 12, 80)
GUICtrlSetResizing(-1, 804)
$rcuInfoIDlable = GUICtrlCreateLabel("ID", $win[2] - $mapw + 16, 75 + $dy, 12, 15)
GUICtrlSetResizing(-1, 804)
$rcuInfoID = GUICtrlCreateInput("", $win[2] - $mapw + 60, 72 + $dy, 30, 20, $ES_READONLY)
GUICtrlSetResizing(-1, 804)
$rcuInfoSNlable = GUICtrlCreateLabel("SN", $win[2] - $mapw + 16, 99 + $dy, 16, 15)
GUICtrlSetResizing(-1, 804)
$rcuInfoSN = GUICtrlCreateInput("", $win[2] - $mapw + 60, 96 + $dy, 30, 20, $ES_READONLY)
GUICtrlSetResizing(-1, 804)
; Температура
$rcuTemp = GUICtrlCreateGroup("Температура, " & Chr(0xB0) & "C", $win[2] - $mapw - 4, 138 + $dy, $mapw - 12, 80)
GUICtrlSetResizing(-1, 804)
$rcuTempTPlable = GUICtrlCreateLabel("Датчик", $win[2] - $mapw + 16, 163 + $dy, 38, 15)
GUICtrlSetResizing(-1, 804)
$rcuTempTP = GUICtrlCreateInput("", $win[2] - $mapw + 60, 160 + $dy, 30, 20, $ES_READONLY)
GUICtrlSetResizing(-1, 804)
$rcuTempLMlable = GUICtrlCreateLabel("Порог", $win[2] - $mapw + 16, 187 + $dy, 33, 15)
GUICtrlSetResizing(-1, 804)
$rcuTempLM = GUICtrlCreateInput("", $win[2] - $mapw + 60, 184 + $dy, 30, 20, $ES_READONLY)
GUICtrlSetResizing(-1, 804)
; Автообновление
$rcuAuto = GUICtrlCreateGroup("Автообновление", $win[2] - $mapw - 4, 226 + $dy, $mapw - 12, 80)
GUICtrlSetResizing(-1, 804)
$rcuAutoOn = GUICtrlCreateRadio("Вкл.", $win[2] - $mapw + 16, 251 + $dy, 41, 15)
GUICtrlSetResizing(-1, 804)
$rcuAutoOff = GUICtrlCreateRadio("Выкл.", $win[2] - $mapw + 16, 275 + $dy, 49, 15)
GUICtrlSetResizing(-1, 804)
; Прогресс
$rcuProgress = GUICtrlCreateProgress($win[2] - $mapw - 4, $maph + 2 + $dy, $mapw - 12, 18)
GUICtrlSetResizing(-1, 804)
GUICtrlSetState(-1, $GUI_HIDE)
stateRcu($GUI_HIDE)
GUICtrlSetData($loadPro, 70)
;~~~~~Unit~~~~~
$uniGroup = GUICtrlCreateGroup("", $win[2] - $mapw - 12, 34 + $dy, $mapw + 4, $maph + 2)
GUICtrlSetResizing(-1, 804)
; Информация о устройстве
$uniInfo = GUICtrlCreateGroup("Информация об устройстве", $win[2] - $mapw - 4, 50 + $dy, $mapw - 12, 80)
GUICtrlSetResizing(-1, 804)
$uniInfoIDlable = GUICtrlCreateLabel("Модель:", $win[2] - $mapw + 16, 67 + $dy, 43, 15)
GUICtrlSetResizing(-1, 804)
$uniInfoID = GUICtrlCreateLabel("", $win[2] - $mapw + 61, 67 + $dy, $mapw - 219, 15)
GUICtrlSetResizing(-1, 804)
$uniInfoSNlable = GUICtrlCreateLabel("Серийный номер:", $win[2] - 156, 67 + $dy, 90, 15)
GUICtrlSetResizing(-1, 804)
$uniInfoSN = GUICtrlCreateLabel("", $win[2] - 64, 67 + $dy, 44, 15)
GUICtrlSetResizing(-1, 804)
$uniInfoDElable = GUICtrlCreateLabel("Описание:", $win[2] - $mapw + 16, 83 + $dy, 54, 15)
GUICtrlSetResizing(-1, 804)
$uniInfoDE = GUICtrlCreateLabel("", $win[2] - $mapw + 72, 83 + $dy, $mapw - 92, 41)
GUICtrlSetResizing(-1, 804)
; Список отказов
$uniList = GUICtrlCreateListView("N|Параметр|Значение|Ед.изм.|Ниж.пор.|Верх.пор.|НК|НП|ВП|ВК|Зн. обновлялось", $win[2] - $mapw - 4, 144 + $dy, $mapw - 12, $maph - 116)
_GUICtrlListView_SetExtendedListViewStyle($uniList, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, $LVS_EX_DOUBLEBUFFER))
GUICtrlSetResizing(-1, 804)
stateUni($GUI_HIDE)
GUICtrlSetData($loadPro, 80)
; ~~~~~List~~~~~
$list = GUICtrlCreateListView("Время события|Время очистки|Узел|Блок|Параметр|Тип|Событие", 0, 38 + $dy + $maph, ($win[2] - $dwinw), ($win[3] - $dwinh) - $maph - 77 - $dy + $dh, $LVS_SORTDESCENDING)
GUICtrlSetResizing(-1, 102)
_GUICtrlListView_SetExtendedListViewStyle($list, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES, $LVS_EX_DOUBLEBUFFER))
_GUICtrlListView_SetColumnWidth($list, 0, 120)
_GUICtrlListView_SetColumnWidth($list, 1, 120)
_GUICtrlListView_SetColumnWidth($list, 2, 100)
_GUICtrlListView_SetColumnWidth($list, 3, 100)
_GUICtrlListView_SetColumnWidth($list, 4, 100)
_GUICtrlListView_SetColumnWidth($list, 5, 150)
_GUICtrlListView_SetColumnWidth($list, 6, 300)
GUICtrlSetData($loadLab, "Загрузка списка аварий...")

load_event_log()

$SQL = "SELECT update_time FROM last_update WHERE last_update_id = 1;"
_EzMySql_Query($SQL)
$aResult = _EzMySql_FetchData()
$update_time = $aResult[0]

;~~~~~StatusBar~~~~~
$statusBarState = GUICtrlCreateLabel("", 0, ($win[3] - $dwinh) - 37, ($win[2] - $dwinw) - 109, 18, $SS_SUNKEN)
GUICtrlSetResizing(-1, 582)
$statusBarAlarm = GUICtrlCreateLabel("", ($win[2] - $dwinw) - 107, ($win[3] - $dwinh) - 37, 50, 18, BitOR($SS_SUNKEN, $SS_RIGHT))
GUICtrlSetResizing(-1, 772)
$statusBarTimer = GUICtrlCreateLabel("", ($win[2] - $dwinw) - 55, ($win[3] - $dwinh) - 37, 55, 18, BitOR($SS_SUNKEN, $SS_RIGHT))
GUICtrlSetResizing(-1, 772)
If $winz[2] = 0 Then stateStatusBar($GUI_HIDE)

;=====Обновление Списка аварий===== + Индикация
;~ $dateEvents = FileGetTime($fileEvents) ;время последнего изменения Списка аварий
;~ $dateNetwork = FileGetTime($fileNetwork) ;время последнего изменения Данных о сети
Dim $alarm_rcu[$COM[0]][20]
For $i = 0 To $COM[0] - 1
	For $j = 0 To 19
		$alarm_rcu[$i][$j] = 0
	Next
Next
$active_rcu = 0

;=====SetData=====
$timer = TimerInit()
GUICtrlSetData($statusBarState, "Готово")
GUICtrlSetData($statusBarAlarm, $nList & " ")
;~ GUICtrlSetData($statusBarTimer, "0:00:00 ")
alarm_log("Вход в систему " & @ComputerName)

GUISetState(@SW_HIDE, $loadWin)
GUICtrlDelete($loadLab)
GUICtrlDelete($loadPro)
GUICtrlDelete($loadWin)

GUISetState(@SW_SHOW, $mainWin)
If $winz[0] = 1 Then GUISetState(@SW_MAXIMIZE)

While 1
	$msg = GUIGetMsg()
;~ 	If $msg Then ConsoleWrite($msg & @CRLF)
	$sec = @SEC
	If Mod(@SEC, 10) = 0 Then
		$SQL = "SELECT update_time FROM last_update WHERE last_update_id = 1;"
		_EzMySql_Query($SQL)
		$aResult = _EzMySql_FetchData()
		$new_time = $aResult[0]
		If $new_time <> $update_time Then
			$update_time = $new_time
			load_event_log()
		EndIf
		Sleep(1000)
	EndIf
;~ 	$newEvents = FileGetTime($fileEvents)
;~ 	$newNetwork = FileGetTime($fileNetwork)
	$eventNetwork = 0 ;Флаг отсутствя изменений сети
	Select
		;=====Обновление Списка аварий=====
;~ 		Case $newEvents[3] <> $dateEvents[3] Or $newEvents[4] <> $dateEvents[4] Or $newEvents[5] <> $dateEvents[5]
;~ 			$dateEvents = $newEvents
;~ 			$nListNew = _FileCountLines($fileEvents)
;~ 			$nListChange = $nListNew - $nListNew
;~ 			If $nListChange > 0 Then
;~ 				$fileList = FileOpen($fileEvents, 0)
;~ 				For $i = 1 To $nListChange
;~ 					GUICtrlCreateListViewItem(FileReadLine($fileList, $nListNew - $nListChange + $i), $list)
;~ 				Next
;~ 				FileClose($fileList)
;~ 				$nList = $nList + $nListChange
;~ 				GUICtrlSetData($statusBarAlarm, $nList & " ")
;~ 				$nListReal = $nListNew
;~ 			EndIf
;~ 		Case $newNetwork[3] <> $dateNetwork[3] Or $newNetwork[4] <> $dateNetwork[4] Or $newNetwork[5] <> $dateNetwork[5]
;~ 			$dateNetwork = $newNetwork
;~ 			$eventNetwork = 1 ;Флаг наличия изменений сети
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $menuFileExit
			close()
			ExitLoop
		Case $msg = $menuViewToolBar
			$win = WinGetPos($programmName)
			If BitAND(GUICtrlRead($menuViewToolBar), $GUI_CHECKED) = $GUI_CHECKED Then
				$dy = -28
				If BitAND(GUICtrlRead($menuViewStatusBar), $GUI_CHECKED) = $GUI_CHECKED Then
					$dh = 0
					GUICtrlSetState($menuViewToolBar, $GUI_UNCHECKED)
					stateToolBar($GUI_HIDE)
					posTree($dy)
					posMap($dy)
					posRcu($dy)
					posUni($dy)
					posList($dy, $dh)
				Else
					$dh = 20
					GUICtrlSetState($menuViewToolBar, $GUI_UNCHECKED)
					stateToolBar($GUI_HIDE)
					posTree($dy)
					posMap($dy)
					posRcu($dy)
					posUni($dy)
					posList($dy, $dh)
				EndIf
			Else
				$dy = 0
				If BitAND(GUICtrlRead($menuViewStatusBar), $GUI_CHECKED) = $GUI_CHECKED Then
					$dh = 0
					GUICtrlSetState($menuViewToolBar, $GUI_CHECKED)
					stateToolBar($GUI_SHOW)
					posTree($dy)
					posMap($dy)
					posRcu($dy)
					posUni($dy)
					posList($dy, $dh)
				Else
					$dh = 20
					GUICtrlSetState($menuViewToolBar, $GUI_CHECKED)
					stateToolBar($GUI_SHOW)
					posTree($dy)
					posMap($dy)
					posRcu($dy)
					posUni($dy)
					posList($dy, $dh)
				EndIf
			EndIf
		Case $msg = $menuViewStatusBar
			$win = WinGetPos($programmName)
			If BitAND(GUICtrlRead($menuViewStatusBar), $GUI_CHECKED) = $GUI_CHECKED Then
				$dh = 20
				If BitAND(GUICtrlRead($menuViewToolBar), $GUI_CHECKED) = $GUI_CHECKED Then
					$dy = 0
					GUICtrlSetState($menuViewStatusBar, $GUI_UNCHECKED)
					stateStatusBar($GUI_HIDE)
					posList($dy, $dh)
				Else
					$dy = -28
					GUICtrlSetState($menuViewStatusBar, $GUI_UNCHECKED)
					stateStatusBar($GUI_HIDE)
					posList($dy, $dh)
				EndIf
			Else
				$dh = 0
				If BitAND(GUICtrlRead($menuViewToolBar), $GUI_CHECKED) = $GUI_CHECKED Then
					$dy = 0
					GUICtrlSetState($menuViewStatusBar, $GUI_CHECKED)
					stateStatusBar($GUI_SHOW)
					posList($dy, $dh)
				Else
					$dy = -28
					GUICtrlSetState($menuViewStatusBar, $GUI_CHECKED)
					stateStatusBar($GUI_SHOW)
					posList($dy, $dh)
				EndIf
			EndIf
		Case $msg = $menuViewStyleClassic
			$win = WinGetPos($programmName)
			If BitAND(GUICtrlRead($menuViewStyleWinXP), $GUI_CHECKED) = $GUI_CHECKED Then
				GUICtrlSetState($menuViewStyleClassic, $GUI_CHECKED)
				GUICtrlSetState($menuViewStyleWinXP, $GUI_UNCHECKED)
				$user = MsgBox(0x40144, $programmName, "Внесенные изменения вступят в силу только после перезапуска программы." & @CRLF _
						 & "Перезапустить сейчас?", 5)
				If $user = 6 Then
					close()
					GUIDelete()
					Sleep(2000)
					Run(@ScriptDir & "/rcu.exe")
					Exit
				EndIf
			EndIf
		Case $msg = $menuViewStyleWinXP
			$win = WinGetPos($programmName)
			If BitAND(GUICtrlRead($menuViewStyleClassic), $GUI_CHECKED) = $GUI_CHECKED Then
				GUICtrlSetState($menuViewStyleWinXP, $GUI_CHECKED)
				GUICtrlSetState($menuViewStyleClassic, $GUI_UNCHECKED)
				$user = MsgBox(0x40144, $programmName, "Внесенные изменения вступят в силу только после перезапуска программы." & @CRLF _
						 & "Перезапустить сейчас?", 5)
				If $user = 6 Then
					close()
					GUIDelete()
					Sleep(2000)
					Run(@ScriptDir & "/rcu.exe")
					Exit
				EndIf
			EndIf
			;=====Menu=====
		Case $msg = $menuServicePing
			menuServicePing()
		Case $msg = $menuServiceHistory
			menu_service_history()
;~ 		Case $msg = $menuServiceRefreshAll
;~ 			$user = MsgBox(0x40124, $programmName, "Внимание! Данная операция займет некоторое время." & @CRLF _
;~ 					 & "Продолжить?", 5)
;~ 			If $user = 6 Then
;~ 				stateMap($GUI_HIDE)
;~ 				stateRcu($GUI_SHOW)
;~ 				$treeLevel = 1
;~ 				For $i = 0 To $COM[0] - 1
;~ 					setRcu($i)
;~ 					unitRefresh($i)
;~ 				Next
;~ 				GUICtrlSetState($treeview, $GUI_FOCUS)
;~ 				GUICtrlSetState($treeview, BitOR($GUI_EXPAND, $GUI_DEFBUTTON))
;~ 			EndIf
;~ 		Case $msg = $menuServiceRefreshData
;~ 			$user = MsgBox(0x40124, $programmName, "Внимание! Данная операция займет некоторое время." & @CRLF _
;~ 					 & "Продолжить?", 5)
;~ 			If $user = 6 Then
;~ 				stateMap($GUI_HIDE)
;~ 				stateRcu($GUI_SHOW)
;~ 				$treeLevel = 1
;~ 				For $i = 0 To $COM[0] - 1
;~ 					setRcu($i)
;~ 					rcuRefresh($i)
;~ 				Next
;~ 				GUICtrlSetState($treeview, $GUI_FOCUS)
;~ 				GUICtrlSetState($treeview, BitOR($GUI_EXPAND, $GUI_DEFBUTTON))
;~ 			EndIf
		Case $msg = $menuHelpAbout
			menuHelpAbout()
			;==============
			;=====ToolBar=====
		Case $msg = $toolBarBtn1 Or $msg = $menuServiceMonitoring
			If $monitoring = 1 Then
;~ 				IniWrite($fileOptions, "main", "auto", "0")
				$SQL = "UPDATE main SET auto = 0 WHERE main_id = 1;"
				_EzMySql_Exec($SQL)
				alarm_log("Мониторинг остановлен")
				$monitoring = 0
				GUICtrlSetState($menuServiceMonitoring, $GUI_UNCHECKED)
				GUICtrlSetData($toolBarBtn1, "Запустить мониторинг")
				GUICtrlSetBkColor($toolBarBtn1, 0xFF0000)
			Else
;~ 				IniWrite($fileOptions, "main", "auto", "1")
				$SQL = "UPDATE main SET auto = 1 WHERE main_id = 1;"
				_EzMySql_Exec($SQL)
				alarm_log("Мониторинг запущен")
				GUICtrlSetState($menuServiceMonitoring, $GUI_CHECKED)
				GUICtrlSetData($toolBarBtn1, "Остановить мониторинг")
				$monitoring = 1
				GUICtrlSetBkColor($toolBarBtn1, 0x00FF00)
				If Not ProcessExists("rcumonitor.exe") Then
					Run(@ScriptDir & "/rcumonitor.exe")
				EndIf
			EndIf
			statusBarState()
		Case $msg = $toolBarBtn2
			For $z = 0 To $COM[0] - 1
				GUICtrlSetState($territory[$z], $GUI_EXPAND)
			Next
		Case $msg = $toolBarBtn3
			delTree()
			Sleep(20)
			$win = WinGetPos($programmName)
			tree($dy)
			setTree()
			;=================
		Case $msg = $treeview
			Select
				Case $treeLevel = 0
					delMap()
					$win = WinGetPos($programmName)
					loadMap()
					map($dy)
					stateMap($GUI_SHOW)
				Case $treeLevel = 1
					stateRcu($GUI_HIDE)
					stateMap($GUI_SHOW)
				Case $treeLevel = 2
					stateUni($GUI_HIDE)
					stateMap($GUI_SHOW)
			EndSelect
			$treeLevel = 0
		Case $msg = $rcuAutoOn
			If $auto[$port] <> 1 Then
				$auto[$port] = 1
;~ 				IniWrite($fileNetwork, $COM[$port + 1], "auto", "1")
				$SQL = StringFormat("UPDATE ne SET auto = 1 WHERE com = '%s';", $COM[$port + 1])
				_EzMySql_Exec($SQL)
				GUICtrlSetColor($territory[$port], 0x000000)
				GUICtrlSetImage($mapIcon[$port], $fileMapIconNormal)
				GUICtrlSetState($territoryMenuAuto[$port], $GUI_CHECKED)
				alarm_log("Автообновление включено", $COM[$port + 1])
			EndIf
		Case $msg = $rcuAutoOff
			If $auto[$port] <> 0 Then
				$auto[$port] = 0
;~ 				IniWrite($fileNetwork, $COM[$port + 1], "auto", "0")
				$SQL = StringFormat("UPDATE ne SET auto = 0 WHERE com = '%s';", $COM[$port + 1])
				_EzMySql_Exec($SQL)
				GUICtrlSetImage($mapIcon[$port], $fileMapIconDisable)
				GUICtrlSetColor($territory[$port], 0xc0c0c0)
				GUICtrlSetState($territoryMenuAuto[$port], $GUI_UNCHECKED)
				alarm_log("Автообновление выключено", $COM[$port + 1])
			EndIf
	EndSelect
	For $i = 0 To $COM[0] - 1
		Select
			Case $msg = $territory[$i]
				Select
					Case $treeLevel = 0
						stateMap($GUI_HIDE)
						stateRcu($GUI_SHOW)
						setRcu($i)
					Case $treeLevel = 1
						setRcu($i)
					Case $treeLevel = 2
						stateUni($GUI_HIDE)
						stateRcu($GUI_SHOW)
						setRcu($i)
				EndSelect
				$treeLevel = 1
				$active_rcu = $i
			Case $msg = $territoryMenuAuto[$i]
				If $treeLevel = 1 Then GUICtrlSetState($territory[$i], $GUI_FOCUS)
				If $auto[$i] <> 1 Then
					$auto[$i] = 1
;~ 					IniWrite($fileNetwork, $COM[$i + 1], "auto", "1")
					$SQL = StringFormat("UPDATE ne SET auto = 1 WHERE com = '%s';", $COM[$port + 1])
					_EzMySql_Exec($SQL)
					GUICtrlSetState($rcuAutoOn, $GUI_CHECKED)
					GUICtrlSetImage($mapIcon[$i], $fileMapIconNormal)
					GUICtrlSetColor($territory[$i], 0x000000)
					GUICtrlSetState($territoryMenuAuto[$i], $GUI_CHECKED)
					alarm_log("Автообновление включено", $COM[$port + 1])
				Else
					$auto[$i] = 0
;~ 					IniWrite($fileNetwork, $COM[$i + 1], "auto", "0")
					$SQL = StringFormat("UPDATE ne SET auto = 0 WHERE com = '%s';", $COM[$port + 1])
					_EzMySql_Exec($SQL)
					GUICtrlSetState($rcuAutoOff, $GUI_CHECKED)
					GUICtrlSetImage($mapIcon[$i], $fileMapIconDisable)
					GUICtrlSetColor($territory[$i], 0xc0c0c0)
					GUICtrlSetState($territoryMenuAuto[$i], $GUI_UNCHECKED)
					alarm_log("Автообновление выключено", $COM[$port + 1])
				EndIf
			Case $msg = $territoryMenuRefresh[$i]
				Select
					Case $treeLevel = 0
						stateMap($GUI_HIDE)
						stateRcu($GUI_SHOW)
						setRcu($i)
					Case $treeLevel = 1
						setRcu($i)
					Case $treeLevel = 2
						stateUni($GUI_HIDE)
						stateRcu($GUI_SHOW)
						setRcu($i)
				EndSelect
				$treeLevel = 1
				unitRefresh($i)
				print(StringFormat('unitRefresh(%s) OK!', $i))
				$msg = 0
;~ 			Case $msg = $territoryMenuData[$i]
;~ 				Select
;~ 					Case $treeLevel = 0
;~ 						stateMap($GUI_HIDE)
;~ 						stateRcu($GUI_SHOW)
;~ 						setRcu($i)
;~ 					Case $treeLevel = 1
;~ 						setRcu($i)
;~ 					Case $treeLevel = 2
;~ 						stateUni($GUI_HIDE)
;~ 						stateRcu($GUI_SHOW)
;~ 						setRcu($i)
;~ 				EndSelect
;~ 				$treeLevel = 1
;~ 				rcuRefresh($i)
			Case $msg = $mapIcon[$i]
				GUICtrlSetState($territory[$i], $GUI_EXPAND)
				GUICtrlSetState($territory[$i], $GUI_FOCUS)
				stateMap($GUI_HIDE)
				stateRcu($GUI_SHOW)
				setRcu($i)
				$treeLevel = 1
				#cs
					Case $eventNetwork = 1
					$tempNetwork = comData(IniRead($fileNetwork, $COM[$i + 1], "temp", "52454D4F54450D0A"))
					$tpuuNetwork = comData(IniRead($fileNetwork, $COM[$i + 1], "tpuu", "52454D4F54450D0A"))
					If $tempNetwork <> "N/A" And $tpuuNetwork <> "N/A" And $tempNetwork >= $tpuuNetwork And $alarm_rcu[$i][0] = 0 Then
					GUICtrlSetColor($territory[$i], 0xFF0000)
					GUICtrlSetImage($mapIcon[$i], $fileMapIconCritical)
					alarm_log("Повышенная температура УУ", $COM[$port + 1])
					$alarm_rcu[$i][0] = 1
					If $active_rcu = $i Then setRcu($i)
					ElseIf $tempNetwork <> "N/A" And $tpuuNetwork <> "N/A" And $tempNetwork < $tpuuNetwork And $alarm_rcu[$i][0] = 1 Then
					alarm_log("Температура УУ в норме", $COM[$port + 1])
					$alarm_rcu[$i][0] = 0
					setMapNormal($i)
					If $active_rcu = $i Then setRcu($i)
					EndIf
					If GUICtrlRead($rcuTempTP) <> $tempNetwork And $active_rcu = $i Then
					GUICtrlSetData($rcuTempTP, $tempNetwork)
					EndIf
				#ce
		EndSelect
		For $j = 1 To 31
			Select
				Case $msg = $territoryUni[$i][$j]
					Select
						Case $treeLevel = 0
							stateMap($GUI_HIDE)
							stateUni($GUI_SHOW)
							setUni($i, $j)
						Case $treeLevel = 1
							stateRcu($GUI_HIDE)
							stateUni($GUI_SHOW)
							setUni($i, $j)
						Case $treeLevel = 2
							setUni($i, $j)
					EndSelect
					$treeLevel = 2
			EndSelect
		Next
	Next
;~ 	If $sec <> @SEC Then ;Время работы
;~ 		ConsoleWrite($sec & " " & @SEC & @CRLF)
;~ 		GUICtrlSetData($statusBarTimer, timer($timer))
;~ 	EndIf
WEnd ;MainLoopEnd
GUIDelete()
Exit

Func load_event_log()
	$SQL = "SELECT log.event_time, ne.name, equipment.name, network.address, param.name, severity.name, log.event " & _
			"FROM log, network, ne, equipment, param, severity " & _
			"WHERE cleared = 0 " & _
			"AND log.network_id = network.network_id " & _
			"AND (select equipment_id from network where network_id = log.network_id) = equipment.equipment_id " & _
			"AND (select ne_id from network where network_id = log.network_id) = ne.ne_id " & _
			"AND log.param_id = param.param_id " & _
			"AND log.severity_id = severity.severity_id " & _
			"ORDER BY log.log_id DESC LIMIT 100;"
	$l = _EzMySql_GetTable2d($SQL)
	_GUICtrlListView_DeleteAllItems($list)
	For $i = 1 To UBound($l) - 1
		GUICtrlCreateListViewItem(StringFormat('%s||%s|%s (адрес %s)|%s|%s|%s', _
				$l[$i][0], $l[$i][1], $l[$i][2], $l[$i][3], $l[$i][4], $l[$i][5], $l[$i][6]), $list)
	Next
EndFunc   ;==>load_event_log

Func stateToolBar($state) ; Состояние "Панели управления"
	GUICtrlSetState($toolBarBtn1, $state)
	GUICtrlSetState($toolBarLine1, $state)
	GUICtrlSetState($toolBarBtn2, $state)
	GUICtrlSetState($toolBarBtn3, $state)
	GUICtrlSetState($toolBarLine, $state)
EndFunc   ;==>stateToolBar

Func menuServicePing() ; Меню -> Сервис -> Пинг...
	GUICtrlSetData($statusBarState, "Пинг")
	Dim $ping[$COM[0]]
	$win = WinGetPos($programmName)
	$pingWinW = 381
	$pingWinH = $COM[0] * 16 + 130
	$pingWinX = $win[0] + Int(($win[2] - $pingWinW) / 2)
	$pingWinY = $win[1] + Int(($win[3] - $pingWinH) / 2)
	If $pingWinX < 0 Then $pingWinX = 0
	If $pingWinX + $pingWinW > @DesktopWidth Then $pingWinX = @DesktopWidth - $pingWinW
	If $pingWinY < 0 Then $pingWinY = 0
	If $pingWinY + $pingWinH > @DesktopHeight Then $pingWinY = @DesktopHeight - $pingWinH
	$pingWin = GUICreate("Пинг - " & $programmName, $pingWinW, $pingWinH, $pingWinX, $pingWinY, 0x00080000, 0x00000000, $mainWin)
	GUISetIcon($fileIcon)
	GUICtrlCreateGroup("Время отклика УУ в сети " & $COMPANY, 5, 3, $pingWinW - 16, $COM[0] * 16 + 56)
	GUICtrlCreateLabel("Объект", 25, 28, 40, 15)
	GUICtrlCreateLabel("IP-адрес", 193, 28, 45, 15)
	GUICtrlCreateLabel("Пинг", 294, 28, 27, 15)
	For $i = 0 To $COM[0] - 1
		GUICtrlCreateLabel($name[$i] & " (" & $COM[$i + 1] & ")", 25, $i * 16 + 52, 150, 15)
		GUICtrlCreateLabel($IP[$i], 193, $i * 16 + 52, 83, 15)
		$ping[$i] = GUICtrlCreateLabel("Ждите...", 294, $i * 16 + 52, 64, 15)
	Next
	$pingClose = GUICtrlCreateButton("Закрыть", 292, $COM[0] * 16 + 72, 75, 23)
	GUICtrlSetState(-1, $GUI_DEFBUTTON)
	GUISetState(@SW_SHOW)
	While 1
		For $i = 0 To $COM[0] - 1
			$sec = @SEC
			$msg = GUIGetMsg(1)
			Select
				Case $msg[0] = $GUI_EVENT_CLOSE And $msg[1] = $pingWin
					ExitLoop (2)
				Case $msg[0] = $pingClose And $msg[1] = $pingWin
					ExitLoop (2)
			EndSelect
			$ms = Ping($IP[$i], 500)
			$error11 = @error
			If $ms <> 0 Then
				GUICtrlSetData($ping[$i], $ms & " мс")
			Else
				GUICtrlSetData($ping[$i], "Не отвечает")
			EndIf
;~ 			If $sec <> @SEC Then
;~ 				GUICtrlSetData($statusBarTimer, timer($timer))
;~ 			EndIf
		Next
	WEnd
	GUIDelete()
	statusBarState()
EndFunc   ;==>menuServicePing

Func menu_service_history()
	$SQL = "SELECT log.event_time AS 'Время события', log.clear_time AS 'Время очистки', ne.name AS 'Узел', equipment.name AS 'Блок', param.name AS 'Параметр', severity.name AS 'Тип', log.event AS 'Событие'" & _
			"FROM log, network, ne, equipment, param, severity " & _
			"WHERE (select ne_id from network where network_id = log.network_id) = ne.ne_id " & _
			"AND (select equipment_id from network where network_id = log.network_id) = equipment.equipment_id " & _
			"AND log.network_id = network.network_id " & _
			"AND log.param_id = param.param_id " & _
			"AND log.severity_id = severity.severity_id " & _
			"ORDER BY log.log_id DESC LIMIT 500;"
	$h = _EzMySql_GetTable2d($SQL)
	For $i = 1 To UBound($h) - 1
		If $h[$i][0] = $h[$i][1] Then
			$h[$i][1] = ''
		EndIf
	Next
	_ArrayDisplay($h, "История - " & $programmName)
EndFunc   ;==>menu_service_history

Func rcuRefresh($i) ; Обновить данные
	GUICtrlSetState($territory[$i], $GUI_FOCUS)
	GUICtrlSetData($statusBarState, "Обновление данных УУ...")
	GUICtrlSetColor($rcuInfoID, 0x808080)
	GUICtrlSetColor($rcuInfoSN, 0x808080)
	GUICtrlSetColor($rcuTempTP, 0x808080)
	GUICtrlSetColor($rcuTempLM, 0x808080)
	$portState = comConnect($i)
	If $portState <> 0 Then
		comSend("ID? ")
		$getState = comGet($i)
		If $getState <> "" And $getState <> "END" & @CRLF Then
			GUICtrlSetData($rcuProgress, 0)
			GUICtrlSetState($rcuProgress, $GUI_SHOW)
			comSend("ID? ")
			$iduu = comGetByte()
			GUICtrlSetData($rcuProgress, 20)
			comSend("SN? ")
			$snuu = comGetByte()
			GUICtrlSetData($rcuProgress, 40)
			comSend("TC? ")
			$temp = comGetByte()
			GUICtrlSetData($rcuProgress, 60)
			comSend("TP? ")
			$tpuu = comGetByte()
			GUICtrlSetData($rcuProgress, 80)
			comSend("END ")
			If comGet($i) <> "END" & @CRLF Then
				comSend("END ")
				ConsoleWrite(comGet($i))
			EndIf
			comDisConnect()
			GUICtrlSetData($rcuProgress, 90)
;~ 			IniDelete($fileNetwork, $COM[$i + 1], "iduu")
;~ 			IniDelete($fileNetwork, $COM[$i + 1], "snuu")
;~ 			IniDelete($fileNetwork, $COM[$i + 1], "temp")
;~ 			IniDelete($fileNetwork, $COM[$i + 1], "tpuu")
;~ 			IniWrite($fileNetwork, $COM[$i + 1], "iduu", $iduu)
;~ 			IniWrite($fileNetwork, $COM[$i + 1], "snuu", $snuu)
;~ 			IniWrite($fileNetwork, $COM[$i + 1], "temp", $temp)
;~ 			IniWrite($fileNetwork, $COM[$i + 1], "tpuu", $tpuu)
			GUICtrlSetData($rcuProgress, 100)
			load()
			setRcu($i)
			GUICtrlSetState($rcuProgress, $GUI_HIDE)
		EndIf
	EndIf
	GUICtrlSetColor($rcuInfoID, 0x000000)
	GUICtrlSetColor($rcuInfoSN, 0x000000)
	GUICtrlSetColor($rcuTempTP, 0x000000)
	GUICtrlSetColor($rcuTempLM, 0x000000)
	statusBarState()
EndFunc   ;==>rcuRefresh

Func print($str)
	ConsoleWrite($str & @CRLF)
EndFunc   ;==>print

Func unitRefresh($i) ; Обновить устройства
	GUICtrlSetState($territory[$i], $GUI_FOCUS)
	GUICtrlSetData($statusBarState, "Обновление списка оборудования...")
	$portState = comConnect($i)
	If $portState <> 0 Then
		comSend("ID? ")
		$getState = comGet($i)
		If $getState <> "" And $getState <> "END" & @CRLF Then
			For $z = 1 To 31
				GUICtrlDelete($territoryUni[$i][$z])
			Next
			GUICtrlSetData($rcuProgress, 0)
			GUICtrlSetState($rcuProgress, $GUI_SHOW)
			Dim $unitTmp[32]
			Dim $snumTmp[32]
			Dim $dataTmp[32]
			Dim $statTmp[32]
			Dim $lmtsTmp[32]
			Dim $lsteTmp[32]
			$k = 0
			For $z = 1 To 31 ; Test 1. Production 31.
				; Limit for 1 answer 128 bytes
				$unitTmp[$z] = ''
				While StringRight($unitTmp[$z], 6) <> "20FF41" And StringRight($unitTmp[$z], 6) <> "414459" ; ' яA' 'ADY'
					comSend("CR" & Chr($z) & Chr(0x06))
					$unitTmp[$z] &= comGetByte()
;~ 					print($unitTmp[$z])
				WEnd
				If StringRight($unitTmp[$z], 6) = "414459" Then
					$unitTmp[$z] = ''
					While StringRight($unitTmp[$z], 6) <> "20FF41" And StringRight($unitTmp[$z], 6) <> "414459" ; ' яA' 'ADY'
						comSend("CR" & Chr($z) & Chr(0x06))
						$unitTmp[$z] &= comGetByte()
;~ 						print($unitTmp[$z])
					WEnd
				EndIf
				GUICtrlSetData($rcuProgress, $z * 100 / 33)
				If StringLeft($unitTmp[$z], 4) = "41FF" Then
					$k = $k + 1
					GUICtrlSetData($statusBarState, "Обновление списка оборудования... (Найдено устройств: " & $k & ")")
					$snumTmp[$z] = ''
					comSend("CR" & Chr($z) & Chr(0x04))
					$snumTmp[$z] = comGetByte()
					comSend("CR" & Chr($z) & Chr(0x03))
					$dataTmp[$z] = comGetByte()
					comSend("CR" & Chr($z) & Chr(0x09))
					$statTmp[$z] = comGetByte()
					While StringRight($lmtsTmp[$z], 4) <> "FF41"
						comSend("CR" & Chr($z) & Chr(0x0a))
						$lmtsTmp[$z] = comGetByte()
					WEnd
;~ 					comSend("CR" & Chr($z) & Chr(0x0a))
;~ 					$lmtsTmp[$z] = comGetByte()
					comSend("CR" & Chr($z) & Chr(0x07))
					$lsteTmp[$z] = comGetByte()
				EndIf
			Next
			comSend("END ")
			If comGet($i) <> "END" & @CRLF Then
				comSend("END ")
				ConsoleWrite(comGet($i))
			EndIf
			comDisConnect()
			GUICtrlSetData($rcuProgress, 32 * 100 / 33)
;~ 			For $k = 1 To 31
;~ 				IniDelete($fileNetwork, $COM[$i + 1], "unit" & $k)
;~ 				IniDelete($fileNetwork, $COM[$i + 1], "addr" & $k) ; number
;~ 				IniDelete($fileNetwork, $COM[$i + 1], "snum" & $k) ; empty
;~ 				IniDelete($fileNetwork, $COM[$i + 1], "data" & $k)
;~ 				IniDelete($fileNetwork, $COM[$i + 1], "stat" & $k) ; empty
;~ 				IniDelete($fileNetwork, $COM[$i + 1], "lmts" & $k)
;~ 				IniDelete($fileNetwork, $COM[$i + 1], "lste" & $k) ; empty
;~ 			Next
			$k = 1
			For $z = 1 To 31
				If StringLeft($unitTmp[$z], 4) = "41FF" Then
;~ 					IniWrite($fileNetwork, $COM[$i + 1], "unit" & $k, $unitTmp[$z])
;~ 					IniWrite($fileNetwork, $COM[$i + 1], "addr" & $k, "41FF" & Hex($z, 2) & "FF41FF5245414459") ; A.(N).A.READY
;~ 					IniWrite($fileNetwork, $COM[$i + 1], "snum" & $k, $snumTmp[$z])
;~ 					IniWrite($fileNetwork, $COM[$i + 1], "data" & $k, $dataTmp[$z])
;~ 					IniWrite($fileNetwork, $COM[$i + 1], "stat" & $k, $statTmp[$z])
;~ 					IniWrite($fileNetwork, $COM[$i + 1], "lmts" & $k, $lmtsTmp[$z])
;~ 					IniWrite($fileNetwork, $COM[$i + 1], "lste" & $k, $lsteTmp[$z])
					$k = $k + 1
					; New
					$unit_name = unit_name_param_to_db($COM[$i + 1], $unitTmp[$z], $z)
					unit_values_to_db($COM[$i + 1], $unit_name, $z, $dataTmp[$z])
					unit_limits_to_db($unit_name, $lmtsTmp[$z])
				EndIf
			Next
			GUICtrlSetData($rcuProgress, 100)
			print('Start load()')
			load()
			print('Start delTree()')
			delTree()
			print('Start $win = WinGetPos($programmName)')
			$win = WinGetPos($programmName)
			print('Start tree($dy)')
			tree($dy)
			print('Start setTree()')
			setTree()
			print('Start GUICtrlSetState($rcuProgress, $GUI_HIDE)')
			GUICtrlSetState($rcuProgress, $GUI_HIDE)
			print('Start GUICtrlSetState($territory[$i], $GUI_EXPAND)')
			GUICtrlSetState($territory[$i], $GUI_EXPAND)
			print('Start GUICtrlSetState($territory[$i], $GUI_FOCUS)')
			GUICtrlSetState($territory[$i], $GUI_FOCUS)
		EndIf
	EndIf
	print('Start statusBarState()')
	statusBarState()
	print('statusBarState() OK!')
EndFunc   ;==>unitRefresh

Func unit_name_param_to_db($COM, $str, $address)
	; $str = "41FF...20FF41"
	Local $unit, $unit_name, $SQL, $result
	$unit = StringSplit(BinaryToString("0x" & $str), " ")
	$unit_name = StringReplace(StringTrimLeft($unit[1], 2), Chr(22), "_")

	; Check $unit_name in DB
	$SQL = StringFormat("SELECT equipment_id FROM equipment WHERE name = '%s';", $unit_name)
	_EzMySql_Query($SQL)
	Local $equipment = _EzMySql_FetchData()
	If Not IsArray($equipment) Then
		$SQL = StringFormat("INSERT INTO equipment (name, description) " & _
				"VALUES ('%s', 'Discovered %s-%s-%s %s:%s:%s')", _
				$unit_name, @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)
		_EzMySql_Exec($SQL)
	EndIf

	; Check network record already in DB and update active equipment
	$SQL = StringFormat("SELECT network_id, act FROM network " & _
			"WHERE ne_id = (SELECT ne_id FROM ne WHERE com = '%s') " & _
			"AND equipment_id = (SELECT equipment_id FROM equipment WHERE name = '%s') " & _
			"AND address = '%u';", $COM, $unit_name, $address)
	_EzMySql_Query($SQL)
	Local $network = _EzMySql_FetchData()
	If Not IsArray($network) Then
		$result = False
	Else
		$result = True
		If $network[1] = 0 Then
			$SQL = StringFormat("UPDATE network SET act = 1 WHERE network_id = %u", $network[0])
		EndIf
	EndIf

	; Insert new network record
	If Not $result Then
		$SQL = StringFormat("INSERT INTO network " & _
				"(ne_id, equipment_id, address, serial, act) " & _
				"VALUES (" & _
				"(SELECT ne_id FROM ne WHERE com = '%s'), " & _
				"(SELECT equipment_id FROM equipment WHERE name = '%s'), " & _
				"%u, '', 1);", $COM, $unit_name, $address)
		_EzMySql_Exec($SQL)
	EndIf

	; Parameters
	Local $param[1], $i, $j = 1
	For $i = 2 To $unit[0] - 1
		_ArrayAdd($param, $unit[$i])
		If StringInStr($unit[$i], "{") <> 0 Then
			$i += 1
			For $i = $i To $unit[0] - 1
				$param[$j] &= " " & $unit[$i]
				If StringInStr($unit[$i], "}") <> 0 Then
					$j += 1
					ExitLoop
				EndIf
			Next
		Else
			$j += 1
		EndIf
	Next
	$param[0] = UBound($param) - 1

	Local $param_2d[$unit[0] - 1][3]
	$j = 1
	For $i = 1 To $param[0]
		$tmp = StringSplit($param[$i], "}-")
		If StringLeft($tmp[1], 1) = "{" Then
			$complex = StringSplit(StringTrimLeft($tmp[1], 1), " ")
			For $k = 1 To $complex[0]
				$param_2d[$j][0] = $complex[$k]
				$param_2d[$j][1] = $tmp[2]
				$param_2d[$j][2] = $tmp[3]
				$j += 1
			Next
		Else
			If $tmp[0] = 3 Then
				For $k = 0 To 2
					$param_2d[$j][$k] = $tmp[$k + 1]
				Next
			EndIf
			$j += 1
		EndIf
	Next
	$param_2d[0][0] = UBound($param_2d) - 1

	For $i = 1 To $param_2d[0][0]
		$SQL = StringFormat("SELECT param_id FROM param " & _
				"WHERE equipment_id = (SELECT equipment_id FROM equipment WHERE name = '%s') " & _
				"AND name = '%s';", $unit_name, $param_2d[$i][0])
		_EzMySql_Query($SQL)
		Local $param = _EzMySql_FetchData()
		If Not IsArray($param) Then
			$SQL = StringFormat("INSERT INTO param (equipment_id, name, multiplicator, measurement, low, prelow, prehigh, high, deflow, defhigh) " & _
					"VALUES ((SELECT equipment_id FROM equipment WHERE name = '%s'), '%s', '%s', '%s', -1000, -999, 999, 1000, '0', '0');", _
					$unit_name, $param_2d[$i][0], $param_2d[$i][1], $param_2d[$i][2])
			_EzMySql_Exec($SQL)
		EndIf
	Next
	Return $unit_name
EndFunc   ;==>unit_name_param_to_db

Func unit_values_to_db($COM, $unit_name, $address, $data)
	Local $i
	$data = StringTrimLeft($data, 4)
	$data = StringTrimRight($data, 4)
	$data = '0x' & $data
	$len = BinaryLen($data)
	If $len > 0 Then
		Local $value[$len]
		For $i = 0 To $len - 1
			$value[$i] = StringTrimLeft(BinaryMid($data, $i + 1, 1), 2)
		Next
;~ 		_ArrayDisplay($value)
	EndIf
	$SQL = StringFormat("SELECT name, multiplicator FROM param " & _
			"WHERE equipment_id = (SELECT equipment_id FROM equipment WHERE name = '%s') " & _
			"ORDER BY param_id;", $unit_name)
	$param = _EzMySql_GetTable2d($SQL)
;~ 	_ArrayDisplay($param)
	Dim $var[UBound($param)]
	$j = 0
	For $i = 1 To UBound($param) - 1
		Select
			Case $param[$i][1] = "AF2L1"
				$var[$i] = Dec($value[$j]) * 1 + Dec($value[$j + 1]) * 0.1
				$j += 2
			Case $param[$i][1] = "AOL0"
				$var[$i] = Dec($value[$j]) * 1
				$j += 1
			Case $param[$i][1] = "AOL1"
				$var[$i] = Dec($value[$j]) * 0.1
				$j += 1
			Case $param[$i][1] = "AVL0"
				$var[$i] = Dec($value[$j] & $value[$j + 1]) * 1
				$j += 2
			Case $param[$i][1] = "AVL1"
				$var[$i] = Dec($value[$j] & $value[$j + 1]) * 0.1
				$j += 2
			Case $param[$i][1] = "AVL2"
				$var[$i] = Dec($value[$j] & $value[$j + 1]) * 0.01
				$j += 2
			Case $param[$i][1] = "AVL3"
				$var[$i] = Dec($value[$j] & $value[$j + 1]) * 0.001
				$j += 2
			Case $param[$i][1] = "AVR0"
				$var[$i] = Dec($value[$j] & $value[$j + 1]) * 1
				$j += 2
			Case $param[$i][1] = "AVR1"
				$var[$i] = Dec($value[$j] & $value[$j + 1]) * 10
				$j += 2
			Case $param[$i][1] = "C"
				$var[$i] = Dec($value[$j])
				$j += 1
			Case Else
				$var[$i] = 9999
		EndSelect
	Next
;~ 	_ArrayDisplay($var)
	$var[0] = UBound($var) - 1

	; Insert values to DB
	For $i = 1 To $var[0]
		$SQL = StringFormat("SELECT value FROM data " & _
				"WHERE network_id = (SELECT network_id FROM network WHERE ne_id = (SELECT ne_id FROM ne WHERE com = '%s') AND address = %u) " & _
				"AND param_id = (" & _
				"SELECT param_id FROM param WHERE name = '%s' AND equipment_id = (SELECT equipment_id FROM equipment WHERE name = '%s')" & _
				") " & _
				"ORDER BY date DESC " & _
				"LIMIT 1;", $COM, $address, $param[$i][0], $unit_name)
		_EzMySql_Query($SQL)
		Local $last_value = _EzMySql_FetchData()
		If Not IsArray($last_value) Or (Round($var[$i], 5) <> Round($last_value[0], 5)) Then
			$timestamp = @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
			$SQL = StringFormat("INSERT INTO data " & _
					"(date, network_id, param_id, value) " & _
					"VALUES (" & _
					"'%s', " & _
					"(SELECT network_id FROM network WHERE ne_id = (SELECT ne_id FROM ne WHERE com = '%s') AND address = %u), " & _
					"(SELECT param_id FROM param WHERE name = '%s' AND equipment_id = (SELECT equipment_id FROM equipment WHERE name = '%s')), " & _
					"%f" & _
					");", $timestamp, $COM, $address, $param[$i][0], $unit_name, $var[$i])
			_EzMySql_Exec($SQL)
		EndIf
	Next
EndFunc   ;==>unit_values_to_db

Func unit_limits_to_db($unit_name, $data)
	Local $i
	Local $lmts = StringSplit(StringTrimRight(StringTrimLeft(BinaryToString("0x" & $data), 2), 2), ' ')
	Local $limits[1][2]
	Local $j = 0
	For $i = 1 To $lmts[0]
		$chr = StringSplit($lmts[$i], "")
		Switch $chr[0]
			Case 1
				_ArrayAdd($limits, '-|-')
				$j += 1
			Case 4
				$n = Asc($chr[3])
				For $m = 0 To $n - 1
					_ArrayAdd($limits, '-|-')
				Next
				$j += $n
			Case 5
				Switch $chr[4]
					Case "*"
						$lim = Asc($chr[3]) * Asc($chr[5])
					Case "/"
						$lim = Asc($chr[3]) / Asc($chr[5])
				EndSwitch
				Switch $chr[2]
					Case "B"
						$lim = '-|' & $lim
					Case "H"
						$lim = $lim & '|-'
				EndSwitch
				_ArrayAdd($limits, $lim)
				$j += 1
			Case 8
				Switch $chr[4]
					Case "*"
						$lim = Asc($chr[3]) * Asc($chr[5])
					Case "/"
						$lim = Asc($chr[3]) / Asc($chr[5])
				EndSwitch
				Switch $chr[2]
					Case "B"
						$lim = '-|' & $lim
					Case "H"
						$lim = $lim & '|-'
				EndSwitch
				$n = Asc($chr[7])
				For $m = 0 To $n - 1
					_ArrayAdd($limits, $lim)
				Next
				$j += $n
			Case 9
				Switch $chr[4]
					Case "*"
						$limB = Asc($chr[3]) * Asc($chr[5])
					Case "/"
						$limB = Asc($chr[3]) / Asc($chr[5])
				EndSwitch
				Switch $chr[8]
					Case "*"
						$limH = Asc($chr[7]) * Asc($chr[9])
					Case "/"
						$limH = Asc($chr[7]) / Asc($chr[9])
				EndSwitch
				_ArrayAdd($limits, $limH & '|' & $limB)
				$j += 1
		EndSwitch
	Next
	$SQL = StringFormat("SELECT name FROM param " & _
			"WHERE equipment_id = (SELECT equipment_id FROM equipment WHERE name = '%s') " & _
			"ORDER BY param_id;", $unit_name)
	Local $param = _EzMySql_GetTable2d($SQL)
;~ 	_ArrayDisplay($param)
;~ 	_ArrayDisplay($limits)
	For $i = 1 To UBound($param) - 1
		$SQL = StringFormat("UPDATE param SET deflow = '%s', defhigh = '%s' " & _
				"WHERE equipment_id = (SELECT equipment_id FROM equipment WHERE name = '%s') AND name = '%s';", _
				$limits[$i][0], $limits[$i][1], $unit_name, $param[$i][0])
		_EzMySql_Exec($SQL)
	Next
EndFunc   ;==>unit_limits_to_db

Func menuHelpAbout() ; Меню -> Справка -> О программе
	GUICtrlSetData($statusBarState, "О программе")
	$win = WinGetPos($programmName)
	$aboutWinW = 419
	$aboutWinH = 347
	$aboutWinX = $win[0] + Int(($win[2] - $aboutWinW) / 2)
	$aboutWinY = $win[1] + Int(($win[3] - $aboutWinH) / 2)
	If $aboutWinX < 0 Then $aboutWinX = 0
	If $aboutWinX + $aboutWinW > @DesktopWidth Then $aboutWinX = @DesktopWidth - $aboutWinW
	If $aboutWinY < 0 Then $aboutWinY = 0
	If $aboutWinY + $aboutWinH > @DesktopHeight Then $aboutWinY = @DesktopHeight - $aboutWinH
	$aboutWin = GUICreate("О программе """ & $programmName & """", $aboutWinW, $aboutWinH, $aboutWinX, $aboutWinY, 0x00000000, 0x00000000, $mainWin)
	GUICtrlCreatePic($fileAboutLogo, 0, 0, 413, 77)
	GUICtrlCreateIcon($fileIcon, -1, 11, 90)
	GUICtrlCreateLabel($programmName, 52, 89, 133, 15)
	GUICtrlCreateLabel("Версия 0.0.1.0", 52, 106, 93, 15)
	GUICtrlCreateLabel("ООО , 2008-2019", 52, 122, 176, 15)
	GUICtrlCreateLabel("", 52, 138, 126, 15)
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetCursor(-1, 0)
	GUICtrlCreateLabel("Срок действия лицензии: " & $licDay & "." & $licMon & "." & $licYear, 52, 170, 187, 15)
	GUICtrlSetColor(-1, 0x808080)
	GUICtrlCreateLabel("", 53, 239, 351, 2, $SS_SUNKEN)
	$aboutOK = GUICtrlCreateButton("OK", 330, 289, 75, 23)
	GUICtrlSetState(-1, $GUI_DEFBUTTON)
	GUISetState(@SW_SHOW)
	While 1
		$sec = @SEC
		$msg = GUIGetMsg(1)
		Select
			Case $msg[0] = $GUI_EVENT_CLOSE And $msg[1] = $aboutWin
				ExitLoop
			Case $msg[0] = $aboutOK And $msg[1] = $aboutWin
				ExitLoop
		EndSelect
;~ 		If $sec <> @SEC Then
;~ 			GUICtrlSetData($statusBarTimer, timer($timer))
;~ 		EndIf
	WEnd
	GUIDelete()
	statusBarState()
EndFunc   ;==>menuHelpAbout

;~~~~~ Tree ~~~~~

Func tree($dy)
	$maintreeview = GUICtrlCreateTreeView(0, 32 + $dy, ($win[2] - $dwinw) - $mapw - 6, $maph + 4, BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS), $WS_EX_CLIENTEDGE)
	GUICtrlSetResizing(-1, 550)
EndFunc   ;==>tree

Func posTree($dy)
	GUICtrlSetPos($maintreeview, 0, 32 + $dy, ($win[2] - $dwinw) - $mapw - 6, $maph + 4)
EndFunc   ;==>posTree

Func setTree()
	Local $i
	$treeview = GUICtrlCreateTreeViewItem($COMPANY, $maintreeview)
	Dim $territory[$COM[0]], $territoryMenu[$COM[0]], $territoryMenuAuto[$COM[0]], $territoryMenuRefresh[$COM[0]], $territoryMenuData[$COM[0]]
	Dim $territoryUni[$COM[0]][32]
	For $i = 0 To $COM[0] - 1
		$territory[$i] = GUICtrlCreateTreeViewItem($name[$i], $treeview)
		GUICtrlSetColor(-1, 0xc0c0c0)
		$territoryMenu[$i] = GUICtrlCreateContextMenu($territory[$i])
;~ 		$territoryMenuData[$i] = GUICtrlCreateMenuItem("Обновить данные", $territoryMenu[$i])
;~ 		GUICtrlSetState(-1, $GUI_DISABLE)
		$territoryMenuRefresh[$i] = GUICtrlCreateMenuItem("Обновить устройства", $territoryMenu[$i])
		If Not FileExists($file_commg) Then
			GUICtrlSetState(-1, $GUI_DISABLE)
		EndIf
		$territoryMenuAuto[$i] = GUICtrlCreateMenuItem("Автообновление", $territoryMenu[$i])
		If $auto[$i] = 1 Then
			GUICtrlSetState(-1, $GUI_CHECKED)
			GUICtrlSetColor($territory[$i], 0x000000)
		EndIf
		For $j = 1 To 31
			$territoryUni[$i][$j] = -1
			If $unit_name_list[$i][$j] <> "" Then
				$territoryUni[$i][$j] = GUICtrlCreateTreeViewItem($unit_name_list[$i][$j], $territory[$i])
			EndIf
		Next
	Next
	GUICtrlSetState($treeview, BitOR($GUI_EXPAND, $GUI_DEFBUTTON))
EndFunc   ;==>setTree

Func delTree()
	GUICtrlDelete($maintreeview)
EndFunc   ;==>delTree

;~~~~~ Map ~~~~~

Func map($dy)
	$mapLable = GUICtrlCreateLabel("", ($win[2] - $dwinw) - $mapw - 4, 32 + $dy, $mapw + 4, $maph + 4, $SS_SUNKEN)
	GUICtrlSetResizing(-1, 804)
	GUICtrlSetState(-1, $GUI_DISABLE)
	$mapPic = GUICtrlCreatePic($fileMapPic, ($win[2] - $dwinw) - $mapw - 2, 34 + $dy, $mapw, $maph)
	GUICtrlSetResizing(-1, 804)
	GUICtrlSetState(-1, $GUI_DISABLE)
	Dim $mapIcon[$COM[0]]
	For $i = 0 To $COM[0] - 1
		$mapIcon[$i] = GUICtrlCreatePic($fileMapIconDisable, $win[2] - $mapw + $posIcon[$i][0] - 10, 34 + $dy + $posIcon[$i][1], 20, 20)
		GUICtrlSetResizing(-1, 804)
		GUICtrlSetCursor(-1, 0)
		If $auto[$i] = 1 Then
			GUICtrlSetImage(-1, $fileMapIconNormal)
		EndIf
	Next
EndFunc   ;==>map

Func stateMap($state)
	Local $i
	GUICtrlSetState($mapLable, $state)
	GUICtrlSetState($mapPic, $state)
	For $i = 0 To $COM[0] - 1
		GUICtrlSetState($mapIcon[$i], $state)
	Next
EndFunc   ;==>stateMap

Func posMap($dy) ; x								y			w			h
	GUICtrlSetPos($mapLable, ($win[2] - $dwinw) - $mapw - 4, 32 + $dy, $mapw + 4, $maph + 4)
	GUICtrlSetPos($mapPic, ($win[2] - $dwinw) - $mapw - 2, 34 + $dy, $mapw, $maph)
	For $i = 0 To $COM[0] - 1
		GUICtrlSetPos($mapIcon[$i], $win[2] - $mapw + $posIcon[$i][0] - 10, 34 + $dy + $posIcon[$i][1], 20, 20)
	Next
EndFunc   ;==>posMap

Func delMap()
	For $i = 0 To $COM[0] - 1
		GUICtrlDelete($mapIcon[$i])
	Next
	GUICtrlDelete($mapPic)
	GUICtrlDelete($mapLable)
EndFunc   ;==>delMap

Func setMapNormal($i) ; Установка зеленого индикатора
	$k = 0
	For $j = 0 To 19
		If $alarm_rcu[$i][$j] = 1 Then
			$k = 1
			ExitLoop
		EndIf
	Next
	If $k = 0 Then
		GUICtrlSetColor($territory[$i], 0x000000)
		GUICtrlSetImage($mapIcon[$i], $fileMapIconNormal)
	EndIf
EndFunc   ;==>setMapNormal

;~~~~~ RCU-1 ~~~~~

Func stateRcu($state)
	GUICtrlSetState($rcuGroup, $state)
	GUICtrlSetState($rcuInfo, $state)
	GUICtrlSetState($rcuInfoIDlable, $state)
	GUICtrlSetState($rcuInfoID, $state)
	GUICtrlSetState($rcuInfoSNlable, $state)
	GUICtrlSetState($rcuInfoSN, $state)
	GUICtrlSetState($rcuTemp, $state)
	GUICtrlSetState($rcuTempTPlable, $state)
	GUICtrlSetState($rcuTempTP, $state)
	GUICtrlSetState($rcuTempLMlable, $state)
	GUICtrlSetState($rcuTempLM, $state)
	GUICtrlSetState($rcuAuto, $state)
	GUICtrlSetState($rcuAutoOn, $state)
	GUICtrlSetState($rcuAutoOff, $state)
EndFunc   ;==>stateRcu

Func posRcu($dy) ; x						y				w			h
	GUICtrlSetPos($rcuGroup, $win[2] - $mapw - 12, 34 + $dy, $mapw + 4, $maph + 2)
	;Информация о УУ
	GUICtrlSetPos($rcuInfo, $win[2] - $mapw - 4, 50 + $dy, $mapw - 12, 80)
	GUICtrlSetPos($rcuInfoIDlable, $win[2] - $mapw + 16, 75 + $dy, 12, 15)
	GUICtrlSetPos($rcuInfoID, $win[2] - $mapw + 60, 72 + $dy, 30, 20)
	GUICtrlSetPos($rcuInfoSNlable, $win[2] - $mapw + 16, 99 + $dy, 16, 15)
	GUICtrlSetPos($rcuInfoSN, $win[2] - $mapw + 60, 96 + $dy, 30, 20)
	;Температура
	GUICtrlSetPos($rcuTemp, $win[2] - $mapw - 4, 138 + $dy, $mapw - 12, 80)
	GUICtrlSetPos($rcuTempTPlable, $win[2] - $mapw + 16, 163 + $dy, 38, 15)
	GUICtrlSetPos($rcuTempTP, $win[2] - $mapw + 60, 160 + $dy, 30, 20)
	GUICtrlSetPos($rcuTempLMlable, $win[2] - $mapw + 16, 187 + $dy, 33, 15)
	GUICtrlSetPos($rcuTempLM, $win[2] - $mapw + 60, 184 + $dy, 30, 20)
	;Автообновление
	GUICtrlSetPos($rcuAuto, $win[2] - $mapw - 4, 226 + $dy, $mapw - 12, 80)
	GUICtrlSetPos($rcuAutoOn, $win[2] - $mapw + 16, 251 + $dy, 41, 15)
	GUICtrlSetPos($rcuAutoOff, $win[2] - $mapw + 16, 275 + $dy, 49, 15)
	;Прогресс
	GUICtrlSetPos($rcuProgress, $win[2] - $mapw - 4, $maph + 2 + $dy, $mapw - 12, 18)
EndFunc   ;==>posRcu

Func setRcu($i)
	GUICtrlSetData($rcuGroup, $name[$i] & " (" & $COM[$i + 1] & ")")
	$SQL = StringFormat("SELECT iduu, snuu, tpuu FROM ne WHERE ne_id = (SELECT ne_id FROM ne WHERE com = '%s');", $COM[$i + 1])
	_EzMySql_Query($SQL)
	$tmp = _EzMySql_FetchData()
	GUICtrlSetData($rcuInfoID, $tmp[0])
	GUICtrlSetData($rcuInfoSN, $tmp[1])
	If $tmp[2] = 0 Then
		$tmp[2] = 'N/A'
	EndIf
	GUICtrlSetData($rcuTempLM, $tmp[2])
	$SQL = StringFormat("SELECT value FROM data " & _
			"WHERE network_id = (SELECT network_id FROM network WHERE ne_id = (SELECT ne_id FROM ne WHERE com = '%s') AND address = 0) " & _
			"AND param_id = (SELECT param_id FROM param WHERE name = '%s' AND equipment_id = (SELECT equipment_id FROM equipment WHERE name = '%s')) " & _
			"ORDER BY data_id DESC LIMIT 1;", $COM[$i + 1], 'T', 'RCU')
	_EzMySql_Query($SQL)
	$tmp = _EzMySql_FetchData() ;Array[0]
	If Not IsArray($tmp) Then
		Dim $tmp[1]
		$tmp[0] = 'N/A'
	EndIf
	GUICtrlSetData($rcuTempTP, $tmp[0])
	If Number(GUICtrlRead($rcuTempTP)) > Number(GUICtrlRead($rcuTempLM)) Then
		GUICtrlSetBkColor($rcuTempTP, 0xFF0000)
	Else
		GUICtrlSetBkColor($rcuTempTP, -1)
	EndIf
	If $auto[$i] = 1 Then
		GUICtrlSetState($rcuAutoOn, $GUI_CHECKED)
	Else
		GUICtrlSetState($rcuAutoOff, $GUI_CHECKED)
	EndIf
	$port = $i
EndFunc   ;==>setRcu

;~~~~~ Unit ~~~~~

Func stateUni($state)
	GUICtrlSetState($uniGroup, $state)
	GUICtrlSetState($uniInfo, $state)
	GUICtrlSetState($uniInfoIDlable, $state)
	GUICtrlSetState($uniInfoID, $state)
	GUICtrlSetState($uniInfoSNlable, $state)
	GUICtrlSetState($uniInfoSN, $state)
	GUICtrlSetState($uniInfoDElable, $state)
	GUICtrlSetState($uniInfoDE, $state)
	GUICtrlSetState($uniList, $state)
EndFunc   ;==>stateUni

Func posUni($dy) ; x						y			w			h
	GUICtrlSetPos($uniGroup, $win[2] - $mapw - 12, 34 + $dy, $mapw + 4, $maph + 2)
	;Информация о устройстве
	GUICtrlSetPos($uniInfo, $win[2] - $mapw - 4, 50 + $dy, $mapw - 12, 80)
	GUICtrlSetPos($uniInfoIDlable, $win[2] - $mapw + 16, 67 + $dy, 43, 15)
	GUICtrlSetPos($uniInfoID, $win[2] - $mapw + 61, 67 + $dy, $mapw - 219, 15)
	GUICtrlSetPos($uniInfoSNlable, $win[2] - 156, 67 + $dy, 90, 15)
	GUICtrlSetPos($uniInfoSN, $win[2] - 64, 67 + $dy, 44, 15)
	GUICtrlSetPos($uniInfoDElable, $win[2] - $mapw + 16, 83 + $dy, 54, 15)
	GUICtrlSetPos($uniInfoDE, $win[2] - $mapw + 72, 83 + $dy, $mapw - 92, 41)
	GUICtrlSetPos($uniList, $win[2] - $mapw - 4, 144 + $dy, $mapw - 12, $maph - 116)
EndFunc   ;==>posUni

Func setUni($i, $j)
	GUICtrlSetData($uniGroup, $name[$i] & " (" & $COM[$i + 1] & ", адрес " & $j & ")")
	GUICtrlSetData($uniInfoID, $unit_name_list[$i][$j])
	GUICtrlSetData($uniInfoSN, "N/A")
	$SQL = StringFormat("SELECT description FROM equipment WHERE name = '%s'", $unit_name_list[$i][$j])
	_EzMySql_Query($SQL)
	$description = _EzMySql_FetchData()
	GUICtrlSetData($uniInfoDE, $description[0])
	_GUICtrlListView_DeleteAllItems($uniList)
	If $auto[$i] <> 0 Then ; Автообновление
		$SQL = StringFormat("SELECT name, measurement, deflow, defhigh, low, prelow, prehigh, high FROM param WHERE equipment_id = (SELECT equipment_id FROM equipment WHERE name = '%s' ORDER BY param_id);", $unit_name_list[$i][$j])
		$param = _EzMySql_GetTable2d($SQL)
		Local $value[UBound($param)][2]
		For $k = 1 To UBound($param) - 1
			$SQL = StringFormat("SELECT value, date FROM data " & _
					"WHERE param_id = (SELECT param_id FROM param WHERE name = '%s' AND equipment_id = (SELECT equipment_id FROM equipment WHERE name = '%s')) " & _
					"AND network_id = (SELECT network_id FROM network WHERE ne_id = (SELECT ne_id FROM ne WHERE com = '%s') AND address = %u) " & _
					"ORDER BY data_id DESC LIMIT 1;", $param[$k][0], $unit_name_list[$i][$j], $COM[$i + 1], $j)
			_EzMySql_Query($SQL)
			$val = _EzMySql_FetchData()
			If IsArray($val) Then
				$value[$k][0] = $val[0]
				$value[$k][1] = $val[1]
			Else
				$value[$k][0] = ''
			EndIf
		Next
		For $k = 1 To UBound($param) - 1
			If $value[$k][0] <> "" Then
				GUICtrlCreateListViewItem(StringFormat("%u|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s", $k, $param[$k][0], $value[$k][0], $param[$k][1], $param[$k][2], $param[$k][3], $param[$k][4], $param[$k][5], $param[$k][6], $param[$k][7], $value[$k][1]), $uniList)
			Else
				GUICtrlCreateListViewItem("-|-|-|-|-|-|-|-|-|-|-", $uniList)
			EndIf
		Next
;~ 		_ArrayDisplay($param)
;~ 		_ArrayDisplay($value)
		#cs
			Dim $channel[1]
			$uniListData = _HexToStringRCU($unit[$i][$j])
			;~ 		ConsoleWrite($uniListData & @CRLF)
			$uniListData = StringSplit($uniListData, " ")
			$z = 1
			For $k = 2 To $uniListData[0] - 1 ; AяACU30TV Рвых-AOL1-Db Возбуд-AOL0-= яA
			If StringInStr($uniListData[$k], "{") <> 0 Then
			_ArrayAdd($channel, $uniListData[$k])
			$k = $k + 1
			For $k = $k To $uniListData[0] - 1
			If StringInStr($uniListData[$k], "}") <> 0 Then
			$channel[$z] = $channel[$z] & " " & $uniListData[$k]
			$z = $z + 1
			ExitLoop
			Else
			$channel[$z] = $channel[$z] & " " & $uniListData[$k]
			EndIf
			Next
			Else
			_ArrayAdd($channel, $uniListData[$k])
			$z = $z + 1
			EndIf
			Next
			$channel[0] = $z - 1
			;~ 		_ArrayDisplay($channel)
			Dim $ch2D[$uniListData[0] - 1][4] ; channel 2D
			$z = 1
			For $k = 0 To $channel[0] - 1
			;~ 			ConsoleWrite($channel[$k + 1] & @CRLF)
			$tmp = StringSplit($channel[$k + 1], "}-")
			If StringInStr($tmp[1], "{") <> 0 Then
			$tmp2 = StringSplit(StringTrimLeft($tmp[1], 1), " ")
			For $m = 1 To $tmp2[0]
			$ch2D[$z][0] = $tmp[0]
			$ch2D[$z][1] = $tmp2[$m]
			$ch2D[$z][2] = $tmp[2]
			$tmp[3] = StringReplace($tmp[3], "0", "-")
			$tmp[3] = StringReplace($tmp[3], "1", "-")
			$ch2D[$z][3] = $tmp[3]
			$z += 1
			Next
			Else
			If $tmp[0] = 3 Then ;добавлено 160816: ошибка в получении порогов
			For $m = 0 To 3
			$ch2D[$z][$m] = $tmp[$m]
			Next
			EndIf
			$z += 1
			EndIf
			Next
			$ch2D[0][0] = $z - 1
			;~ 		_ArrayDisplay($ch2D)
			;Значение
			If $z > 0 Then
			$ch2D[0][1] = $z - 1
			If StringLeft($data[$i][$j], 4) = "41FF" Then
			;~ 				print($data[$i][$j])
			$unitData = StringTrimLeft($data[$i][$j], 4)
			$unitData = StringTrimRight($unitData, 4) ; 191125 was 16
			$n = StringLen($unitData) / 2
			If $n > 0 Then
			Dim $dataarray[$n]
			For $k = 0 To $n - 1
			$dataarray[$k] = StringMid($unitData, $k * 2 + 1, 2)
			Next
			;~ 					_ArrayDisplay($dataarray)
			Dim $var[$ch2D[0][1]]
			$z = 0
			For $k = 1 To $ch2D[0][1]
			Select
			Case $ch2D[$k][2] = "AF2L1"
			$var[$k - 1] = Dec($dataarray[$z]) * 1 + Dec($dataarray[$z + 1]) * 0.1
			$z = $z + 2
			Case $ch2D[$k][2] = "AOL0"
			$var[$k - 1] = Dec($dataarray[$z]) * 1
			$z = $z + 1
			Case $ch2D[$k][2] = "AOL1"
			$var[$k - 1] = Dec($dataarray[$z]) * 0.1
			$z = $z + 1
			Case $ch2D[$k][2] = "AVL0"
			$var[$k - 1] = Dec($dataarray[$z] & $dataarray[$z + 1]) * 1
			$z = $z + 2
			Case $ch2D[$k][2] = "AVL1"
			$var[$k - 1] = Dec($dataarray[$z] & $dataarray[$z + 1]) * 0.1
			$z = $z + 2
			Case $ch2D[$k][2] = "AVL2"
			$var[$k - 1] = Dec($dataarray[$z] & $dataarray[$z + 1]) * 0.01
			$z = $z + 2
			Case $ch2D[$k][2] = "AVL3"
			$var[$k - 1] = Dec($dataarray[$z] & $dataarray[$z + 1]) * 0.001
			$z = $z + 2
			Case $ch2D[$k][2] = "AVR0"
			$var[$k - 1] = Dec($dataarray[$z] & $dataarray[$z + 1]) * 1
			$z = $z + 2
			Case $ch2D[$k][2] = "AVR1"
			$var[$k - 1] = Dec($dataarray[$z] & $dataarray[$z + 1]) * 10
			$z = $z + 2
			Case $ch2D[$k][2] = "C"
			If $dataarray[$z] = "00" Then
			$var[$k - 1] = "норма"
			Else
			$var[$k - 1] = "-"
			EndIf
			$z = $z + 1
			Case Else
			;MsgBox(0,"","Не знаю такого")
			$var[$k - 1] = "N/A"
			EndSelect
			Next
			EndIf
			;Пределы
			;~ 				_ArrayDisplay($var)
			$limits = limUni($i, $j, $ch2D[0][1])
			;~ 				_ArrayDisplay($limits)
			For $k = 1 To $ch2D[0][1]
			;~ 					GUICtrlCreateListViewItem($k & "|" & $ch2D[$k][1] & "|" & $var[$k - 1] & "|" & $ch2D[$k][3] & "|" & $limits[$k - 1][0] & "|" & $limits[$k - 1][1], $uniList)
			If $ch2D[$k][1] = "T" Or $ch2D[$k][1] = "T1" Or $ch2D[$k][1] = "T2" Or $ch2D[$k][1] = "Uбат" Then
			If $limits[$k - 1][0] <> "-" And $var[$k - 1] < $limits[$k - 1][0] Then ;critical
			GUICtrlSetBkColor(-1, 0xFF0000)
			EndIf
			If $limits[$k - 1][1] <> "-" And $var[$k - 1] > $limits[$k - 1][1] Then ;critical
			GUICtrlSetBkColor(-1, 0xFF0000)
			EndIf
			Else
			If $limits[$k - 1][0] <> "-" And $var[$k - 1] > $limits[$k - 1][0] Then ;minor
			GUICtrlSetBkColor(-1, 0xffba75)
			EndIf
			If $limits[$k - 1][1] <> "-" And $var[$k - 1] > $limits[$k - 1][1] Then ;critical
			GUICtrlSetBkColor(-1, 0xFF0000)
			EndIf
			EndIf
			Next
			Else
			;~ 				GUICtrlCreateListViewItem("-|-|-|-|-|-", $uniList)
			EndIf
			EndIf
		#ce
	EndIf
EndFunc   ;==>setUni

#cs
	Func limUni($i, $j, $n) ; Пределы
	$error11 = "Ошибка в определении пределов."
	Dim $limits[$n][2]
	If $lmts[$i][$j] <> "" Then
	$z = 0
	$unitLmts = StringTrimLeft($lmts[$i][$j], 4)
	$unitLmts = StringTrimRight($unitLmts, 4) ; 191125 was 16
	$strlmts = StringSplit(_HexToStringRCU($unitLmts), " ")
	For $k = 1 To $strlmts[0]
	If $strlmts[$k] <> "" Then
	$chrlmts = StringSplit($strlmts[$k], "")
	Select
	Case $chrlmts[0] = 5 And $chrlmts[1] = "1"
	Select
	Case $chrlmts[2] = "B"
	Select
	Case $chrlmts[4] = "*"
	$lim = Asc($chrlmts[3]) * Asc($chrlmts[5])
	Case $chrlmts[4] = "/"
	$lim = Asc($chrlmts[3]) / Asc($chrlmts[5])
	Case Else
	error($error11, $COM[$i + 1], $unit[$i][$j])
	EndSelect
	$limits[$z][0] = "-"
	$limits[$z][1] = $lim
	$z = $z + 1
	;MsgBox(0,"Один предел","Верхний = " & $lim)
	Case $chrlmts[2] = "H"
	Select
	Case $chrlmts[4] = "*"
	$lim = Asc($chrlmts[3]) * Asc($chrlmts[5])
	Case $chrlmts[4] = "/"
	$lim = Asc($chrlmts[3]) / Asc($chrlmts[5])
	Case Else
	error($error11, $COM[$i + 1], $unit[$i][$j])
	EndSelect
	$limits[$z][0] = $lim
	$limits[$z][1] = "-"
	$z = $z + 1
	;MsgBox(0,"Один предел","Нижний = " & $lim)
	Case Else
	error($error11, $COM[$i + 1], $unit[$i][$j])
	EndSelect
	Case $chrlmts[0] = 8 And $chrlmts[1] = "1"
	Select
	Case $chrlmts[2] = "B"
	Select
	Case $chrlmts[4] = "*"
	$lim = Asc($chrlmts[3]) * Asc($chrlmts[5])
	Case $chrlmts[4] = "/"
	$lim = Asc($chrlmts[3]) / Asc($chrlmts[5])
	Case Else
	error($error11, $COM[$i + 1], $unit[$i][$j])
	EndSelect
	$n = Asc($chrlmts[7])
	For $m = 0 To $n - 1
	$limits[$z + $m][0] = "-"
	$limits[$z + $m][1] = $lim
	Next
	$z = $z + $n
	;MsgBox(0,"Один повторяющийся предел","Верхний = " & $lim & @CRLF & "Повторяется " & $n & " раз(а)")
	Case $chrlmts[2] = "H"
	Select
	Case $chrlmts[4] = "*"
	$lim = Asc($chrlmts[3]) * Asc($chrlmts[5])
	Case $chrlmts[4] = "/"
	$lim = Asc($chrlmts[3]) / Asc($chrlmts[5])
	Case Else
	error($error11, $COM[$i + 1], $unit[$i][$j])
	EndSelect
	$n = Asc($chrlmts[7])
	For $m = 0 To $n - 1
	$limits[$z + $m][0] = $lim
	$limits[$z + $m][1] = "-"
	Next
	$z = $z + $n
	;MsgBox(0,"Один повторяющийся предел","Нижний = " & $lim & @CRLF & "Повторяется " & $n & " раз(а)")
	Case Else
	error($error11, $COM[$i + 1], $unit[$i][$j])
	EndSelect
	Case $chrlmts[0] = 9 And $chrlmts[1] = "2"
	Select
	Case $chrlmts[4] = "*"
	$limB = Asc($chrlmts[3]) * Asc($chrlmts[5])
	Case $chrlmts[4] = "/"
	$limB = Asc($chrlmts[3]) / Asc($chrlmts[5])
	EndSelect
	Select
	Case $chrlmts[8] = "*"
	$limH = Asc($chrlmts[7]) * Asc($chrlmts[9])
	Case $chrlmts[8] = "/"
	$limH = Asc($chrlmts[7]) / Asc($chrlmts[9])
	EndSelect
	$limits[$z][0] = $limH
	$limits[$z][1] = $limB
	$z = $z + 1
	;MsgBox(0,"Два предела","Верхний = " & $limB & @CRLF & "Нижний = " & $limH)
	Case $chrlmts[0] = 1 And $chrlmts[1] = "P"
	;$n = 1
	$limits[$z][0] = "-"
	$limits[$z][1] = "-"
	$z = $z + 1
	;MsgBox(0,"Пропуск","Количество = " & $n)
	Case $chrlmts[0] = 4 And $chrlmts[1] = "P"
	$n = Asc($chrlmts[3])
	For $m = 0 To $n - 1
	$limits[$z + $m][0] = "-"
	$limits[$z + $m][1] = "-"
	Next
	$z = $z + $n
	;MsgBox(0,"Пропуск","Количество = " & $n)
	Case Else
	error($error11, $COM[$i + 1], $unit[$i][$j])
	EndSelect
	EndIf
	Next
	EndIf
	;_ArrayDisplay($limits)
	Return $limits
	EndFunc   ;==>limUni

	Func error($error11, $COM, $unit)
	$unitName = _HexToString($unit)
	$unitName = StringSplit($unitName, " ")
	If $unitName[1] <> "" Then $unitName[1] = StringTrimLeft($unitName[1], 2)
	$unitName[1] = StringReplace($unitName[1], Chr(22), "_")
	MsgBox(8208, $programmName, $error11 & @CRLF & @CRLF _
	& "Порт: " & $COM & @CRLF _
	& "Устройство: " & $unitName[1], 5)
	EndFunc   ;==>error
#ce

;~~~~~ List ~~~~~

Func posList($dy, $dh)
	If BitAND(GUICtrlRead($menuViewStyleWinXP), $GUI_CHECKED) = $GUI_CHECKED Then $dh = $dh - 7
	GUICtrlSetPos($list, 0, 38 + $dy + $maph, ($win[2] - $dwinw), ($win[3] - $dwinh) - $maph - 77 - $dy + $dh)
EndFunc   ;==>posList

Func alarm_log($event, $ne = 'COM0', $address = 0, $param = '', $severity = 5, $cleared = 1, $ack = 0)
	$timestamp = @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
	$SQL = StringFormat("INSERT INTO log (event_time, clear_time, network_id, param_id, severity_id, event, cleared, ack) " & _
			"VALUES ('%s', '%s', " & _
			"(SELECT network_id FROM network WHERE ne_id = (SELECT ne_id FROM ne WHERE com = '%s') AND address = %u), " & _
			"(SELECT param_id FROM param WHERE name = '%s'), " & _
			"%u, '%s', %u, %u);", $timestamp, $timestamp, $ne, $address, $param, $severity, $event, $cleared, $ack)
	_EzMySql_Exec($SQL)
EndFunc   ;==>alarm_log

;~~~~~ StatusBar ~~~~~

Func stateStatusBar($state)
	GUICtrlSetState($statusBarState, $state)
	GUICtrlSetState($statusBarAlarm, $state)
	GUICtrlSetState($statusBarTimer, $state)
EndFunc   ;==>stateStatusBar

;~~~~~ Timer ~~~~~

Func timer($timer)
	$uptime = TimerDiff($timer)
	$uph = Int($uptime / 3600000)
	$upm = Int($uptime / 60000) - Int($uptime / 3600000) * 60
	If $upm < 10 Then $upm = "0" & $upm
	$ups = Int($uptime / 1000) - Int($uptime / 60000) * 60
	If $ups < 10 Then $ups = "0" & $ups
	Return $uph & ":" & $upm & ":" & $ups & " "
EndFunc   ;==>timer

;~~~~~ Close ~~~~~

Func close() ; сохранение размеров и позиции главного окна
	$win = WinGetPos($programmName)
	;_ArrayDisplay($win)
	$winWH = 0
	$winTB = 0
	$winSB = 0
	$winStyle = 0
	;ConsoleWrite($win[2] & ' ' & @DesktopWidth + $dwinw & @CRLF)
	If $win[2] >= @DesktopWidth + $dwinw Then
		$winWH = 1
	Else
;~ 		IniWrite($fileOptions, "main", "winw", $win[2])
;~ 		_EzMySql_Exec(StringFormat("UPDATE main SET winw = %u WHERE main_id = 1;", $win[2])
		If BitAND(GUICtrlRead($menuViewStyleWinXP), $GUI_CHECKED) = $GUI_CHECKED Then $win[3] = $win[3] - 7
;~ 		IniWrite($fileOptions, "main", "winh", $win[3])
;~ 		IniWrite($fileOptions, "main", "winx", $win[0])
;~ 		IniWrite($fileOptions, "main", "winy", $win[1])
	EndIf
	If BitAND(GUICtrlRead($menuViewToolBar), $GUI_CHECKED) = $GUI_CHECKED Then $winTB = 2
	If BitAND(GUICtrlRead($menuViewStatusBar), $GUI_CHECKED) = $GUI_CHECKED Then $winSB = 4
	If BitAND(GUICtrlRead($menuViewStyleWinXP), $GUI_CHECKED) = $GUI_CHECKED Then $winStyle = 8
;~ 	IniWrite($fileOptions, "main", "winz", $winWH + $winTB + $winSB + $winStyle)
	alarm_log("Выход из системы " & @ComputerName)
	If FileExists($file_monitor) Then
		$SQL = "UPDATE main SET auto = 0 WHERE main_id = 1;"
		_EzMySql_Exec($SQL)
	EndIf
	_EzMySql_Close()
	_EzMySql_ShutDown()
	Exit
EndFunc   ;==>close

;~~~~~ DECtoBIN ~~~~~

Func DECtoBIN($number, $n) ; преобразование десятичного параметра в бинарный вид
	Dim $result[$n]
	Local $i
	For $i = $n - 1 To 0 Step -1
		If $number >= 2 ^ $i Then
			$result[$i] = 1
			$number -= 2 ^ $i
		Else
			$result[$i] = 0
		EndIf
	Next
	Return $result
EndFunc   ;==>DECtoBIN

;~~~~~ Готово/Мониторинг ~~~~~

Func statusBarState()
	If $monitoring = 0 Then
		GUICtrlSetData($statusBarState, "Стоп")
	Else
		GUICtrlSetData($statusBarState, "Мониторинг")
	EndIf
EndFunc   ;==>statusBarState

;~~~~~ Load ~~~~~

Func load()
	Local $i
	$SQL = "SELECT com, name, ip, auto, mapx, mapy FROM ne WHERE name != '';"
	$c = _EzMySql_GetTable2d($SQL)
	Dim $COM[UBound($c)]
	$COM[0] = UBound($c) - 1
	Dim $name[$COM[0]]
	Dim $IP[$COM[0]]
	Dim $auto[$COM[0]]
	Dim $posIcon[$COM[0]][2]
	For $i = 1 To $COM[0]
		$COM[$i] = $c[$i][0]
		$name[$i - 1] = $c[$i][1]
		$IP[$i - 1] = $c[$i][2]
		$auto[$i - 1] = $c[$i][3]
		$posIcon[$i - 1][0] = $c[$i][4]
		$posIcon[$i - 1][1] = $c[$i][5]
	Next

	Dim $unit_name_list[$COM[0]][32]
	For $i = 0 To $COM[0] - 1
		For $j = 1 To 31
			$SQL = StringFormat("SELECT equipment.name FROM equipment, network WHERE network.ne_id = (SELECT ne_id FROM ne WHERE com = '%s') AND network.address = %u AND network.equipment_id = equipment.equipment_id;", $COM[$i + 1], $j)
			_EzMySql_Query($SQL)
			$name_tmp = _EzMySql_FetchData()
			If IsArray($name_tmp) Then
				$unit_name_list[$i][$j] = $name_tmp[0]
			EndIf
		Next
	Next
;~ 	_ArrayDisplay($unit_name_list)

;~ 	Dim $unit[$COM[0]][32]
;~ 	Dim $data[$COM[0]][32]
;~ 	Dim $lmts[$COM[0]][32]
;~ 	For $i = 0 To $COM[0] - 1
;~ 		For $j = 1 To 31
;~ 			$unit[$i][$j] = IniRead($fileNetwork, $COM[$i + 1], "unit" & $j, "")
;~ 			$data[$i][$j] = IniRead($fileNetwork, $COM[$i + 1], "data" & $j, "")
;~ 			$lmts[$i][$j] = IniRead($fileNetwork, $COM[$i + 1], "lmts" & $j, "")
;~ 		Next
;~ 	Next
;~ 	_ArrayDisplay($unit)
EndFunc   ;==>load

Func loadMap()
	$SQL = "SELECT com, auto, mapx, mapy FROM ne WHERE name != '';"
	$c = _EzMySql_GetTable2d($SQL)
	Dim $COM[UBound($c)]
	$COM[0] = UBound($c) - 1
	Dim $auto[$COM[0]]
	Dim $posIcon[$COM[0]][2]
	For $i = 1 To $COM[0]
		$COM[$i] = $c[$i][0]
		$auto[$i - 1] = $c[$i][1]
		$posIcon[$i - 1][0] = $c[$i][2]
		$posIcon[$i - 1][1] = $c[$i][3]
	Next
EndFunc   ;==>loadMap

;~~~~~ COM ~~~~~

Func comConnect($i)
	$sErr = 2
	$portState = _CommSetPort(StringTrimLeft($COM[$i + 1], 3), $sErr, 19200, 8, 0, 1, 0)
	If $portState = 0 Then
		GUICtrlSetData($statusBarState, "Ошибка!")
		alarm_log($sErr, $COM[$port + 1])
		MsgBox(8208, $programmName, "Ошибка соединения с COM-портом." & @CRLF & @CRLF _
				 & "Порт: " & $COM[$i + 1] & @CRLF _
				 & "Ошибка: " & $sErr & ".", 5)
	EndIf
	Return $portState
EndFunc   ;==>comConnect

Func comDisConnect()
	_CommClosePort()
EndFunc   ;==>comDisConnect

Func comSend($tx) ; Add to string crc checksum
	Local $i
	$chr = StringSplit($tx & Chr(0x00) & Chr(0x8C), "")
	Dim $dec[$chr[0]], $bin[$chr[0]][8]
	For $i = 1 To $chr[0]
		$dec[$i - 1] = Asc($chr[$i])
		For $j = 7 To 0 Step -1
			If $dec[$i - 1] - 2 ^ $j + 1 > 0 Then
				$bin[$i - 1][$j] = 1
				$dec[$i - 1] = $dec[$i - 1] - 2 ^ $j
			Else
				$bin[$i - 1][$j] = 0
			EndIf
		Next
	Next
	Dim $msg[1]
	For $i = 1 To $chr[0] - 1
		For $j = 0 To 7
			_ArrayAdd($msg, $bin[$i - 1][$j])
		Next
	Next
	Dim $reg[8], $regtmp[8]
	For $i = 0 To 7
		$reg[$i] = $msg[$i + 1]
	Next
	For $k = 1 To ($chr[0] - 2) * 8
		If $reg[0] = 1 Then
			For $i = 0 To 6
				$reg[$i] = $reg[$i + 1]
			Next
			$reg[7] = $msg[$k + 8]
			For $i = 0 To 7
				If ($reg[$i] = 0) And ($bin[$chr[0] - 1][$i] = 0) Then
					$regtmp[$i] = 0
				ElseIf ($reg[$i] = 1) And ($bin[$chr[0] - 1][$i] = 1) Then
					$regtmp[$i] = 0
				Else
					$regtmp[$i] = 1
				EndIf
			Next
			For $i = 0 To 7
				$reg[$i] = $regtmp[$i]
			Next
		Else
			For $i = 0 To 6
				$reg[$i] = $reg[$i + 1]
			Next
			$reg[7] = $msg[$k + 8]
		EndIf
	Next
	$dec = 0
	For $i = 7 To 0 Step -1
		$dec = $dec + $reg[$i] * 2 ^ $i
	Next
	$crc = $tx & Chr($dec)
	_CommSendString($crc, 1) ; 1 = wait till sent
EndFunc   ;==>comSend

Func comGet($i)
	Local $wait = 10
	While $wait > 0
		$rx = _CommGetString()
		If StringLen($rx) <> 0 Then ExitLoop
		Sleep(100)
		$wait -= 0.1
	WEnd
	If $rx = "" Then
		GUICtrlSetData($statusBarState, "Ошибка!")
		alarm_log("УУ не отвечает", $COM[$port + 1])
		MsgBox(8208, $programmName, "УУ не отвечает, возможно нет подключения.", 5)
	EndIf
	Return $rx
EndFunc   ;==>comGet

Func comGetByte()
	$chr = _CommReadByte(1) ; does not return until a byte has been read
	$rx = Hex($chr, 2)
	While 1
		$chr = _CommReadByte(0) ; if no data to read then return -1 and set @error to 1
		If $chr = "" Then
			ExitLoop
		EndIf
		$rx &= Hex($chr, 2)
	WEnd
	Return $rx
EndFunc   ;==>comGetByte

Func comData($hexData) ; Извлечение данных из строки в шестнадцатиричной форме. Ред. 160812. Обновление компилятора.
	Local $result = "Error"
	Local $strData = _HexToStringRCU($hexData)
	;ConsoleWrite('Строка на входе  "' & $hexData & '" версия ' & @AutoItVersion & @CRLF)
	;ConsoleWrite('Строка как текст "' & $strData & '"' & @CRLF)
	;ConsoleWrite('hex last symbol = ' & Asc(StringRight($strData,1)) & @CRLF)
	$cmd = StringSplit($strData, "=")
	;_ArrayDisplay($cmd,'Разделение текстовой строки знаком =')
	If $cmd[0] = 3 Then $cmd[2] = $cmd[2] & "="
	If $cmd[0] = 4 Then $cmd[2] = $cmd[2] & $cmd[3]
	If $cmd[0] > 1 Then ;@error = 0
		$chr = StringSplit($cmd[1] & "=" & StringRight($strData, 1) & Chr(0x00) & Chr(0x8C), "") ;00000000 & reverse polynom
		;_ArrayDisplay($chr,'Массив символов')

		Dim $dec[$chr[0]], $bin[$chr[0]][8]
		For $i = 1 To $chr[0]
			$dec[$i - 1] = Asc($chr[$i])
			;условие ниже добавлено 15.08.2016. Байт CRC в конце строки неправильно обрабатывается функцией Asc()
			;If $i = $chr[0] - 2 Then
			;	$dec[$i - 1] = Dec(StringRight($hexData,2))
			;EndIf
			;<===
			;ConsoleWrite('Десятичное значение символа ' & $dec[$i - 1] & @CRLF)
			For $j = 7 To 0 Step -1 ;ИСПРАВИТЬ
				;ConsoleWrite('Шаг ' & $j & ': если ' &  $dec[$i - 1] & ' - ' & 2^$j & ' + 1 больше 0 (' & $dec[$i - 1] - 2^$j + 1 & ')' & @CRLF)
				If $dec[$i - 1] >= 2 ^ $j Then ;If $dec[$i - 1] - 2^$j + 1 > 0 Then
					;ConsoleWrite('True' & @CRLF)
					$bin[$i - 1][$j] = 1
					$dec[$i - 1] -= 2 ^ $j ;$dec[$i - 1] = $dec[$i - 1] - 2^$j
				Else
					;ConsoleWrite('False' & @CRLF)
					$bin[$i - 1][$j] = 0
				EndIf
			Next
		Next
		;_ArrayDisplay($bin,'Бинарное представление')
		Dim $msg[1]
		For $i = 1 To $chr[0] - 1
			For $j = 0 To 7
				_ArrayAdd($msg, $bin[$i - 1][$j])
			Next
		Next
		;_ArrayDisplay($msg,'Сообщение')
		Dim $reg[8], $regtmp[8]
		For $i = 0 To 7
			$reg[$i] = $msg[$i + 1]
		Next
		For $k = 1 To ($chr[0] - 2) * 8
			If $reg[0] = 1 Then
				For $i = 0 To 6
					$reg[$i] = $reg[$i + 1]
				Next
				$reg[7] = $msg[$k + 8]
				For $i = 0 To 7
					If ($reg[$i] = 0) And ($bin[$chr[0] - 1][$i] = 0) Then
						$regtmp[$i] = 0
					ElseIf ($reg[$i] = 1) And ($bin[$chr[0] - 1][$i] = 1) Then
						$regtmp[$i] = 0
					Else
						$regtmp[$i] = 1
					EndIf
				Next
				For $i = 0 To 7
					$reg[$i] = $regtmp[$i]
				Next
			Else
				For $i = 0 To 6
					$reg[$i] = $reg[$i + 1]
				Next
				$reg[7] = $msg[$k + 8]
			EndIf
		Next
		$crc = 0
		;_ArrayDisplay($reg,'Массив $reg')
		For $i = 7 To 0 Step -1
			$crc += $reg[$i] * 2 ^ $i
		Next
		;ConsoleWrite('$crc = ' & $crc & @CRLF)
		If $crc = 0 Then
			;MsgBox(0,"","Правильно")
			$rx = StringTrimRight($cmd[2], 1)
			$rxchr = StringSplit($cmd[2], "")
			Select
				Case $cmd[1] = "ALARM"
					If Asc($rxchr[1]) = 0 Then
						MsgBox(0, "", "Ошибки нет")
					Else
						MsgBox(0, "", "Ошибка передатчика №" & Asc($rxchr[2]))
					EndIf
				Case $cmd[1] = "AM"
					Dim $dec[2], $bin[2][8], $am[2][8]
					For $i = 1 To 2
						$dec[$i - 1] = Asc($rxchr[$i])
						For $j = 7 To 0 Step -1
							If $dec[$i - 1] - 2 ^ $j + 1 > 0 Then
								$bin[$i - 1][$j] = 1
								$dec[$i - 1] = $dec[$i - 1] - 2 ^ $j
							Else
								$bin[$i - 1][$j] = 0
							EndIf
						Next
					Next
					For $i = 0 To 1
						For $j = 0 To 7
							If $bin[$i][$j] = 0 Then
								$am[$i][$j] = "Выкл"
							Else
								$am[$i][$j] = "Вкл"
							EndIf
						Next
					Next
					MsgBox(0, "", "Сработал внешний датчик №1 " & $am[1][0] & @CRLF & _
							"Сработал внешний датчик №2 " & $am[1][1] & @CRLF & _
							"Авария одного из подключенных блоков Микротек " & $am[1][2] & @CRLF & _
							"Пропала связь с одним из подключенных блоков Микротек " & $am[1][3] & @CRLF & _
							"Нет видеосигнала на входах контроля видеосигнала №1 " & $am[1][4] & @CRLF & _
							"Нет видеосигнала на входах контроля видеосигнала №2 " & $am[1][5] & @CRLF & _
							"Нет видеосигнала на входах контроля видеосигнала №3 " & $am[1][6] & @CRLF & _
							"Нет видеосигнала на входах контроля видеосигнала №4 " & $am[1][7] & @CRLF & _
							"Превышен порог датчика температуры" & $am[0][0] & @CRLF & _
							"Зарезервировано " & $am[0][1] & @CRLF & _
							"Зарезервировано " & $am[0][2] & @CRLF & _
							"Зарезервировано " & $am[0][3] & @CRLF & _
							"Зарезервировано " & $am[0][4] & @CRLF & _
							"Зарезервировано " & $am[0][5] & @CRLF & _
							"Зарезервировано " & $am[0][6] & @CRLF & _
							"Зарезервировано " & $am[0][7])
				Case $cmd[1] = "ID"
					$id = Asc($rx)
					;MsgBox(0,"",$id)
					$result = $id
				Case $cmd[1] = "NE"
					$ne = Asc($rx)
					MsgBox(0, "", $ne)
				Case $cmd[1] = "NT"
					$nt = Asc($rx)
					MsgBox(0, "", $nt)
				Case $cmd[1] = "OUT"
					$out = Asc($rx)
					MsgBox(0, "", $out)
				Case $cmd[1] = "PC"
					$pc = Asc($rx)
					MsgBox(0, "", $pc)
				Case $cmd[1] = "PS"
					$ps = Asc($rx)
					MsgBox(0, "", $ps)
				Case $cmd[1] = "PT"
					$pt = Asc($rx)
					MsgBox(0, "", $pt)
				Case $cmd[1] = "RS"
					MsgBox(0, "", "Чтение состояния передатчиков (Не реализовано)")
				Case $cmd[1] = "SN"
					$sn = $rxchr[1] & $rxchr[2]
					;MsgBox(0,"",$sn)
					$result = $sn
				Case $cmd[1] = "TEL"
					$tel = ""
					For $i = 1 To Asc($rxchr[1])
						$tel = $tel & Asc($rxchr[$i + 1])
					Next
					MsgBox(0, "", $tel)
				Case $cmd[1] = "SW"
					Dim $bin[8], $sw[8]
					$dec = Asc($cmd[2])
					For $j = 7 To 0 Step -1
						If $dec - 2 ^ $j + 1 > 0 Then
							$bin[$j] = 1
							$dec = $dec - 2 ^ $j
						Else
							$bin[$j] = 0
						EndIf
					Next
					For $j = 0 To 7
						If $bin[$j] = 0 Then
							$sw[$j] = "Замкнут"
						Else
							$sw[$j] = "Разомкнут"
						EndIf
					Next
					MsgBox(0, "", "Состояние контакта №1: " & $sw[2] & @CRLF & _
							"Состояние контакта №2: " & $sw[3] & @CRLF & _
							"Состояние контакта №3: " & $sw[4] & @CRLF & _
							"Состояние контакта №4: " & $sw[5] & @CRLF & _
							"Состояние контакта №5: " & $sw[6] & @CRLF & _
							"Состояние контакта №6: " & $sw[7])
				Case $cmd[1] = "TEMP"
					$temp = (Asc($rxchr[1]) + Asc($rxchr[2])) / 2
					;MsgBox(0,"",$temp)
					$result = $temp
				Case $cmd[1] = "TIME"
					$time = Hex(Asc($rxchr[1]), 2) & "-" & Hex(Asc($rxchr[2]), 2) & " " & Hex(Asc($rxchr[3]), 2) & ":" & Hex(Asc($rxchr[4]), 2) & ":" & Hex(Asc($rxchr[5]), 2)
					MsgBox(0, "", $time)
				Case $cmd[1] = "TP"
					$tp = Asc($rx)
					;MsgBox(0,"",$tp)
					$result = $tp
				Case $cmd[1] = "TSM"
					$tsm = ""
					For $i = 1 To Asc($rxchr[1])
						$tsm = $tsm & Asc($rxchr[$i + 1])
					Next
					MsgBox(0, "", $tsm)
			EndSelect
		Else
			MsgBox(0, "Ошибка CRC", $hexData, 1)
		EndIf
	Else
		;MsgBox(0,"","Данные без CRC")
		Select
			Case $cmd[1] = "DS1820 ERROR"
				MsgBox(0, "", $cmd[1])
			Case $cmd[1] = "END" & Chr(0x0D) & Chr(0x0A)
				MsgBox(0, "", "Конец сеанса")
			Case $cmd[1] = "OK"
				MsgBox(0, "", $cmd[1])
			Case $cmd[1] = "REMOTE" & Chr(0x0D) & Chr(0x0A)
				;MsgBox(0,"","REMOTE")
				$result = "N/A"
		EndSelect
	EndIf
	Return $result
EndFunc   ;==>comData

; #FUNCTION# ====================================================================================================================
; Author ........: Jarvis Stubblefield
; Modified.......: SmOke_N - (Re-write using BinaryToString for speed)
; Modified.......: Stan Syrosenko - (ANSI)
; ===============================================================================================================================
Func _HexToStringRCU($sHex)
	If Not (StringLeft($sHex, 2) == "0x") Then $sHex = "0x" & $sHex
	Return BinaryToString($sHex);, $SB_UTF8)
EndFunc   ;==>_HexToStringRCU
