;константы
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <TreeViewConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
;дополнения
#include <file.au3>
#include <GuiListView.au3>
#include <string.au3>
#include <Array.au3>
;функции
#include <load.au3>
#include <list.au3>
#include <main.au3>
#include <map.au3>
#include <menu.au3>
#include <tree.au3>
#include <adddel.au3>
#include <unit.au3>
#include <autorefresh.au3>
#include <service.au3>
;COM-движок
#include <CommMG.au3>
#include <comConnection.au3>
#include <comObject.au3>
;константы
$programmName = "Микротек RCU-1 (Ethernet)"
$fileNetwork = @ScriptDir & "\network.ini"
$fileOptions = @ScriptDir & "\options.ini"
$fileEvents = "events.log"
$fileRX = @ScriptDir & "\rx.log"
$fileTX = @ScriptDir & "\tx.log"

;~ Select
;~ Case FileExists(IniRead($fileOptions,"path","map"))
;~ 	$fileMap = IniRead($fileOptions,"path","map")
;~ Case FileExists(@ScriptDir & "\map.bmp")
;~ 	$fileMap = @ScriptDir & "\map.bmp"
;~ EndSelect

$sysPing = IniRead($fileOptions, "main", "ping", 250)

$maplable = 0
$map = 0
$form = 0
$groupInfo = 0
$lableID = 0
$inputID = 0
$lableSN = 0
$inputSN = 0
$lableAuto = 0
$groupTemp = 0
$lableTemp = 0
$inputTemp = 0
$lableLimit = 0
$inputLimit = 0
$progress = 0
;unit
$unitForm = 0
$unitInfo = 0
$lableID = 0
$unitID = 0
$lableSN = 0
$unitSN = 0
$lableDE = 0
$unitDE = 0
$unitlist = 0
;Список Аварий
$list = 0

; ==================== Путь запуска автообновления ====================
;$pathRCUmonitor = @ScriptDir & "/distr/AutoIt3.exe" & " """ & @ScriptDir & "/rcumonitor.au3"""
;$pathRCUmonitor = @ScriptDir & "/rcumonitor.au3"
$pathRCUmonitor = @ScriptDir & "/rcumonitor.exe"

; ==================== Старт программы ====================
load()
main()
menu()
tree()
map()
list()

; ==================== Обновление Списка аварий ====================
$dateEvents = FileGetTime($fileEvents) ;время последнего изменения Списка аварий

GUISetState()
While 1
	$msg = GUIGetMsg()
	$newEvents = FileGetTime($fileEvents)
	Select
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $exititem
			close()
			ExitLoop
		Case $msg = $infoitem
			MsgBox(0x40000, "О программе Микротек RCU-1 (Ethernet)", "Версия 0.16 beta")
		Case $msg = $serviceoptionitem
			GUISetState(@SW_DISABLE)
			serviceoption()
			GUISetState(@SW_ENABLE)
		Case $msg = $servicepingitem
			GUISetState(@SW_DISABLE)
			serviceping()
			GUISetState(@SW_ENABLE)
		Case $msg = $servicemonitoritem Or $msg = $start
			If BitAND(GUICtrlRead($servicemonitoritem), $GUI_CHECKED) = $GUI_CHECKED Then
				GUICtrlSetState($servicemonitoritem, $GUI_UNCHECKED)
				GUICtrlSetImage($start, @ScriptDir & "/img/btn_start.bmp")
				IniWrite($fileOptions, "main", "auto", 0)
			Else
				GUICtrlSetState($servicemonitoritem, $GUI_CHECKED)
				GUICtrlSetImage($start, @ScriptDir & "/img/btn_stop.bmp")
				IniWrite($fileOptions, "main", "auto", 1)
				Run($pathRCUmonitor)
			EndIf
		Case $msg = $expand
			GUICtrlSetState($treeview, BitOR($GUI_EXPAND, $GUI_DEFBUTTON))
			For $i = 0 To $COM[0] - 1
				GUICtrlSetState($territory[$i], $GUI_EXPAND)
			Next
		Case $msg = $deexpand
			GUICtrlDelete($maintreeview)
			tree()
		Case $msg = $delitem
			GUISetState(@SW_DISABLE)
			menufiledel()
			delmap()
			load()
			GUICtrlDelete($maintreeview)
			tree()
			map()
			GUISetState(@SW_ENABLE)
		Case $msg = $additem
			GUISetState(@SW_DISABLE)
			menufileadd()
			delmap()
			load()
			GUICtrlDelete($maintreeview)
			tree()
			map()
			GUISetState(@SW_ENABLE)
		Case $msg = $treeview
			load()
			delmap()
			map()
			; ==================== Обновление Списка аварий ====================
		Case $newEvents[3] <> $dateEvents[3] Or $newEvents[4] <> $dateEvents[4] Or $newEvents[5] <> $dateEvents[5]
			$dateEvents = $newEvents
			list()
	EndSelect
	For $i = 0 To $COM[0] - 1
		Select
			Case $msg = $territory[$i]
				load()
				delmap()
				uu($i)
			Case $msg = $refreshstatusitem[$i]
				autorefresh($i)
			Case $msg = $refreshitem[$i]
				delmap()
				uu($i)
				$comN = $i
				For $k = 1 To 31
					IniDelete($fileNetwork, $COM[$comN + 1], "unit" & $k)
					IniDelete($fileNetwork, $COM[$comN + 1], "addr" & $k)
					IniDelete($fileNetwork, $COM[$comN + 1], "mode" & $k)
					IniDelete($fileNetwork, $COM[$comN + 1], "snum" & $k)
					IniDelete($fileNetwork, $COM[$comN + 1], "stat" & $k)
				Next
				GUICtrlSetState($progress, $GUI_SHOW)
				comConnect($COM[$i + 1])
				comSend("ID? ")
				read()
				comSend("ID? ")
				read()
				Dim $model[32]
				For $z = 1 To 31
					GUICtrlSetData($progress, $z * 100 / 32)
					$data = "CR" & Chr($z) & Chr(0x06)
					comSend($data)
					Sleep(1500)
					$model[$z] = read()
				Next
				comSend("END ")
				read()
				comSend("END ")
				read()
				comDisconnect()
				$n = 31
				$j = 1
				$k = 1
				For $z = 1 To $n
					$char = StringSplit($model[$z], "")
					If $char[1] = "A" Or $char[1] = "я" Then
						$var = StringSplit($model[$z], " ")
					Else
						$j = $j - 1
						$n = $n + 1
						$model[$z - 1] = $model[$z - 1] & $model[$z]
					EndIf
					If $var[0] > 1 And $char[2] = "я" Then
						IniWrite($fileNetwork, $COM[$comN + 1], "unit" & $k, StringTrimLeft($var[1], 2))
						IniWrite($fileNetwork, $COM[$comN + 1], "addr" & $k, $j)
						$k = $k + 1
					EndIf
					$j = $j + 1
				Next
				GUICtrlSetData($progress, 100)
				load()
				GUICtrlDelete($maintreeview)
				tree()
				GUICtrlSetState($progress, $GUI_HIDE)
			Case $msg = $refreshdata[$i]
				delmap()
				uu($i)
				GUICtrlSetState($progress, $GUI_SHOW)
				$comN = $i
				comConnect($COM[$i + 1])
				comSend("ID? ")
				$rx = readByte()
				$var = comRead($rx)
				GUICtrlSetData($progress, 1 * 100 / 6)
				IniWrite($fileNetwork, $COM[$comN + 1], $var[0], $var[1])
				comSend("ID? ")
				$rx = readByte()
				$var = comRead($rx)
				GUICtrlSetData($progress, 2 * 100 / 6)
				IniWrite($fileNetwork, $COM[$comN + 1], $var[0], $var[1])
				comSend("SN? ")
				$rx = readByte()
				$var = comRead($rx)
				GUICtrlSetData($progress, 3 * 100 / 6)
				IniWrite($fileNetwork, $COM[$comN + 1], $var[0], $var[1])
				comSend("TC? ")
				$rx = readByte()
				$var = comRead($rx)
				GUICtrlSetData($progress, 4 * 100 / 6)
				IniWrite($fileNetwork, $COM[$comN + 1], $var[0], $var[1])
				comSend("TP? ")
				$rx = readByte()
				$var = comRead($rx)
				GUICtrlSetData($progress, 5 * 100 / 6)
				IniWrite($fileNetwork, $COM[$comN + 1], $var[0], $var[1])
				comSend("END ")
				$rx = readByte()
				$var = comRead($rx)
				GUICtrlSetData($progress, 6 * 100 / 6)
				comDisconnect()
				load()
				delmap()
				uu($comN)
				GUICtrlSetState($progress, $GUI_HIDE)
		EndSelect
		For $j = 1 To 31
			Select
				Case $msg = $treeunit[$i][$j]
					unitdel()
					unit($i, $j)
			EndSelect
		Next
	Next
WEnd
GUIDelete()
Exit
