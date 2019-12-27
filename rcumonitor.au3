#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=img\rcumonitor.ico
#AutoIt3Wrapper_outfile=rcumonitor.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=for support mail to:
#AutoIt3Wrapper_Res_Description=Microtech RCU-1 (Ethernet)
#AutoIt3Wrapper_Res_Fileversion=0.0.0.19
#AutoIt3Wrapper_Res_LegalCopyright=
#AutoIt3Wrapper_Run_After=ResHacker.exe -delete %out%, %out%, DIALOG, 1000,
#AutoIt3Wrapper_Run_After=ResHacker.exe -delete %out%, %out%, MENU, 166,
#AutoIt3Wrapper_Run_After=upx.exe --best --compress-resources=0 "%out%"
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

$licYear = 2009
$licMon = 12
$licDay = 31
If @YEAR >= $licYear Then
	If @MON >= $licMon Then
		If @MDAY > $licDay Then
			Exit
		EndIf
	EndIf
EndIf

#include <Array.au3>
#include <string.au3>

Global $fPortOpen = False
Global $hDll

$programmName = "Microtech RCU-1 (Ethernet)" ;header
$fileNetwork = @ScriptDir & "/network.ini"
$fileOptions = @ScriptDir & "/options.ini"
$fileEvents = @ScriptDir & "/events.log"
$COM = IniReadSectionNames($fileNetwork)
Dim $name[$COM[0]]
Dim $IP[$COM[0]]
Dim $auto[$COM[0]]
Dim $posIcon[$COM[0]][2]
Dim $unit[$COM[0]][32]
Dim $addr[$COM[0]][32]
Dim $snum[$COM[0]][32]
Dim $data[$COM[0]][32]
Dim $stat[$COM[0]][32]
Dim $lmts[$COM[0]][32]
Dim $lste[$COM[0]][32]
For $i = 0 To $COM[0] - 1
	$name[$i] = IniRead($fileNetwork, $COM[$i + 1], "name", $COM[$i + 1])
	$IP[$i] = IniRead($fileNetwork, $COM[$i + 1], "IP", "N/A")
	$auto[$i] = IniRead($fileNetwork, $COM[$i + 1], "auto", 0)
	$posIcon[$i][0] = IniRead($fileNetwork, $COM[$i + 1], "mapX", 0)
	$posIcon[$i][1] = IniRead($fileNetwork, $COM[$i + 1], "mapY", 0)
	For $j = 1 To 31
		$unit[$i][$j] = IniRead($fileNetwork, $COM[$i + 1], "unit" & $j, "")
		$addr[$i][$j] = IniRead($fileNetwork, $COM[$i + 1], "addr" & $j, "")
		$snum[$i][$j] = IniRead($fileNetwork, $COM[$i + 1], "snum" & $j, "")
		$data[$i][$j] = IniRead($fileNetwork, $COM[$i + 1], "data" & $j, "")
		$stat[$i][$j] = IniRead($fileNetwork, $COM[$i + 1], "stat" & $j, "")
		$lmts[$i][$j] = IniRead($fileNetwork, $COM[$i + 1], "lmts" & $j, "")
		$lste[$i][$j] = IniRead($fileNetwork, $COM[$i + 1], "lste" & $j, "")
	Next
Next

While 1
	If ProcessExists("rcu.exe") Then
		If FileExists($fileNetwork) Then
			For $i = 0 To $COM[0] - 1
				If IniRead($fileOptions, "main", "auto", 0) = 1 Then
					If IniRead($fileNetwork, $COM[$i + 1], "auto", 0) = 1 Then
						$portState = comConnect($i)
						If $portState <> 0 Then
							comSend("ID? ")
							$getState = comGet($i)
							If $getState <> "" Then
								comSend("ID? ")
								comGet($i)
								Dim $unitTmp[32]
								Dim $snumTmp[32]
								Dim $dataTmp[32]
								Dim $statTmp[32]
								Dim $lmtsTmp[32]
								Dim $lsteTmp[32]
								$k = 0
								For $z = 1 To 31
									$sendData = "CR" & Chr($z) & Chr(0x06)
									comSend($sendData)
									Sleep(1000)
									$unitTmp[$z] = comGetByte()
									If StringLeft($unitTmp[$z], 4) = "41FF" Then
										$k = $k + 1
										$sendData = "CR" & Chr($z) & Chr(0x04)
										comSend($sendData)
										Sleep(500)
										$snumTmp[$z] = comGetByte()
										$sendData = "CR" & Chr($z) & Chr(0x03)
										comSend($sendData)
										Sleep(500)
										$dataTmp[$z] = comGetByte()
										$sendData = "CR" & Chr($z) & Chr(0x09)
										comSend($sendData)
										Sleep(500)
										$statTmp[$z] = comGetByte()
										$sendData = "CR" & Chr($z) & Chr(0x0a)
										comSend($sendData)
										Sleep(500)
										$lmtsTmp[$z] = comGetByte()
										$sendData = "CR" & Chr($z) & Chr(0x07)
										comSend($sendData)
										Sleep(500)
										$lsteTmp[$z] = comGetByte()
									EndIf
								Next
								comSend("END ")
								comGet($i)
								comSend("END ")
								comGet($i)
								comDisConnect()
								$k = 1
								For $z = 1 To 31
									If StringLeft($unitTmp[$z], 4) = "41FF" Then
										IniWrite($fileNetwork, $COM[$i + 1], "unit" & $k, $unitTmp[$z])
										IniWrite($fileNetwork, $COM[$i + 1], "addr" & $k, "41FF" & Hex($z, 2) & "FF41FF5245414459")
										IniWrite($fileNetwork, $COM[$i + 1], "snum" & $k, $snumTmp[$z])
										IniWrite($fileNetwork, $COM[$i + 1], "data" & $k, $dataTmp[$z])
										IniWrite($fileNetwork, $COM[$i + 1], "stat" & $k, $statTmp[$z])
										IniWrite($fileNetwork, $COM[$i + 1], "lmts" & $k, $lmtsTmp[$z])
										IniWrite($fileNetwork, $COM[$i + 1], "lste" & $k, $lsteTmp[$z])
										$k = $k + 1
									EndIf
								Next
							EndIf
						EndIf
					EndIf
				Else
					ExitLoop (2)
				EndIf
			Next
		Else
			Exit
		EndIf
	Else
		Exit
	EndIf
WEnd
Exit

Func newEvent($event)
	$newEvent = date() & "|" & $event
	$fileList = FileOpen($fileEvents, 1)
	FileWriteLine($fileList, $newEvent)
	FileClose($fileList)
EndFunc   ;==>newEvent

Func date()
;~ 	Select
;~ 	Case @MON = 1
;~ 		$mon = "Янв"
;~ 	Case @MON = 2
;~ 		$mon = "Фев"
;~ 	Case @MON = 3
;~ 		$mon = "Мар"
;~ 	Case @MON = 4
;~ 		$mon = "Апр"
;~ 	Case @MON = 5
;~ 		$mon = "Май"
;~ 	Case @MON = 6
;~ 		$mon = "Июн"
;~ 	Case @MON = 7
;~ 		$mon = "Июл"
;~ 	Case @MON = 8
;~ 		$mon = "Авг"
;~ 	Case @MON = 9
;~ 		$mon = "Сен"
;~ 	Case @MON = 10
;~ 		$mon = "Окт"
;~ 	Case @MON = 11
;~ 		$mon = "Ноя"
;~ 	Case @MON = 12
;~ 		$mon = "Дек"
;~ 	EndSelect
	$date = @YEAR & "." & @MON & "." & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
	Return $date
EndFunc   ;==>date

;~~~~~~~~~~~~~~~~
;~~~~~ Load ~~~~~
;~~~~~~~~~~~~~~~~

Func load()

EndFunc   ;==>load

;*************************************************************************************
;********** COM ********** COM ********** COM ********** COM ********** COM **********
;*************************************************************************************

Func comConnect($i)
	$sErr = 2
	$portState = _CommSetPort(StringTrimLeft($COM[$i + 1], 3), $sErr, 19200, 8, 0, 1, 0)
	If $portState = 0 Then
		newEvent($name[$i] & " (" & $COM[$i + 1] & ")|" & $sErr)
		MsgBox(8208, $programmName, "Ошибка соединения с COM-портом." & @CRLF & @CRLF _
				 & "Порт: " & $COM[$i + 1] & @CRLF _
				 & "Ошибка: " & $sErr & ".", 5)
	EndIf
	Return $portState
EndFunc   ;==>comConnect

Func comDisConnect()
	_CommClosePort()
EndFunc   ;==>comDisConnect

Func comSend($tx)
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
	_CommSendString($crc, 0)
EndFunc   ;==>comSend

Func comGet($i)
	$sec = @SEC
	$wait = 10
	While $wait > 0
		$rx = _CommGetString()
		If StringLen($rx) <> 0 Then ExitLoop
		If $sec <> @SEC Then
			$wait = $wait - 1
		EndIf
		$sec = @SEC
	WEnd
	If $rx = "" Then
		newEvent($name[$i] & " (" & $COM[$i + 1] & ")|УУ не отвечает")
		MsgBox(8208, $programmName, "УУ не отвечает, возможно нет подключения.", 5)
	EndIf
	Return $rx
EndFunc   ;==>comGet

Func comGetByte()
	$chr = _CommReadByte(1)
	$rx = Hex($chr, 2)
	While 1
		$chr = _CommReadByte(0)
		If $chr = "" Then
			ExitLoop
		EndIf
		$rx = $rx & Hex($chr, 2)
	WEnd
	Return $rx
EndFunc   ;==>comGetByte

Func comData($hexData)
	$result = "Error"
	$strData = _HexToString($hexData)
	$cmd = StringSplit($strData, "=")
	If $cmd[0] = 3 Then $cmd[2] = $cmd[2] & "="
	If $cmd[0] = 4 Then $cmd[2] = $cmd[2] & $cmd[3]
	If @error = 0 Then
		$chr = StringSplit($cmd[1] & "=" & StringRight($strData, 1) & Chr(0x00) & Chr(0x8C), "") ;00000000 & reverse polynom
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
		$crc = 0
		For $i = 7 To 0 Step -1
			$crc = $crc + $reg[$i] * 2 ^ $i
		Next
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
			MsgBox(0, "", "Ошибка CRC")
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

;****************************************
;********** CommMG.au3 V2.1 my **********
;****************************************

Func _CommSetPort($iPort, ByRef $sErr, $iBaud = 19200, $iBits = 8, $iPar = 0, $iStop = 1, $iFlow = 0)
	Local $vDllAns
	$sMGBuffer = ""
	$sErr = ""
	If Not $fPortOpen Then
		$hDll = DllOpen("commg.dll")
		If $hDll = -1 Then
			SetError(2)
			$sErr = "Ошибка при открытии commg.dll"
			Return 0
		EndIf
		$fPortOpen = True
	EndIf
	ConsoleWrite("Последовательный порт (COM" & $iPort & ")" & @CRLF _
			 & "Скорость (бит/с): " & $iBaud & @CRLF _
			 & "Биты данных: " & $iBits & @CRLF _
			 & "Четность: " & $iPar & @CRLF _
			 & "Стоповые биты: " & $iStop & @CRLF _
			 & "Управление потоком: " & $iFlow & @CRLF)
	$vDllAns = DllCall($hDll, "int", "SetPort", "int", $iPort, "int", $iBaud, "int", $iBits, "int", $iPar, "int", $iStop, "int", $iFlow)
	If @error <> 0 Then
		$sErr = "Невозможно настроить пераметры порта"
		SetError(1)
		Return 0
	EndIf
	If $vDllAns[0] < 0 Then
		SetError($vDllAns[0])
		Switch $vDllAns[0]
			Case -1
				$sErr = "Неверно задана скорость порта"
			Case -2
				$sErr = "Неверно заданы параметры порта"
			Case -4
				$sErr = "Undefined data size"
			Case -8
				$sErr = "Port 0 not allowed"
			Case -16
				$sErr = "Порт не существует"
			Case -32
				$sErr = "Доступ запрещен, возможно порт уже используется"
			Case -64
				$sErr = "Unknown error accessing port"
		EndSwitch
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>_CommSetPort

Func _CommClosePort()
	DllCall($hDll, "int", "CloseDown")
	DllClose($hDll)
	$fPortOpen = False
EndFunc   ;==>_CommClosePort

Func _CommSendString($sMGString, $iWaitComplete = 0)
	Local $vDllAns
	$vDllAns = DllCall($hDll, "int", "SendString", "str", $sMGString, "int", $iWaitComplete)
	If @error <> 0 Then
		SetError(@error)
		Return ""
	Else
		Return $vDllAns[0]
	EndIf
EndFunc   ;==>_CommSendString

Func _CommGetString()
	Local $vDllAns
	$vDllAns = DllCall($hDll, "str", "GetString")
	If @error <> 0 Then
		SetError(1)
		Return ""
	EndIf
	Return $vDllAns[0]
EndFunc   ;==>_CommGetString

Func _CommReadByte($wait = 0)
	Local $iCount, $vDllAns
	If Not $wait Then
		$iCount = _CommGetInputCount()
		If $iCount = 0 Then
			SetError(1)
			Return ""
		EndIf
	EndIf
	$vDllAns = DllCall($hDll, "str", "GetByte")
	If @error <> 0 Then
		SetError(2)
		Return ""
	EndIf
	Return $vDllAns[0]
EndFunc   ;==>_CommReadByte

Func _CommGetInputCount()
	Local $vDllAns
	$vDllAns = DllCall($hDll, "str", "GetInputCount")
	If @error <> 0 Then
		SetError(1)
		Return 0
	Else
		Return $vDllAns[0]
	EndIf
EndFunc   ;==>_CommGetInputCount
