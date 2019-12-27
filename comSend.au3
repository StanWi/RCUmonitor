#include <Array.au3>

$data = "ID? " ;Чтение идентификатора
$data = "TP? " ;Контроль порога температуры
$data = "SW? " ;Опрос состояния контактов
$data = "OUT?" ;Чтение управления
$data = "TC? " ;Контроль температуры
$data = "END " ;Конец сеанса

$data = "TEL?" ;Чтение № телефона
$data = "TSM?" ;Чтение № SMS
$data = "ALRM?" ;Чтение состояния аварии передатчика
$data = "AM?  " ;Чтение маски аварии
$data = "RS?  " ;Чтение состояния передатчиков
$data = "WATCH? " ;Чтение системных часов
$data = "WREAD " & Chr(1) ;Чтение времени вкл./выкл. устройств
$data = "PS? " ;Чтение паузы опроса передатчиков
$data = "PC? " ;Чтение времени ожидания команды
$data = "NE? " ;Чтение заданного числа ошибочных комманд
$data = "NT? " ;Чтение заданного числа попыток связи
$data = "PT? " ;Чтение паузы между попытками связи
$data = "SN? " ;Чтение серийного номера

For $i = 1 To 4
	For $j = 1 To 10
		$data = "CR" & Chr($i) & Chr($j) ;Обращение к контроллеру передатчика (адрес) [1..31] (команда) [6,4,9,3,7,10]
		;comSend($data)
	Next
Next

;comSend($data)

$data = "END" & Chr(0x0D) & Chr(0x0A)
$data = "OK"
$data = "DS1820 ERROR"
$data = "REMOTE" & Chr(0x0D) & Chr(0x0A)

$data = "ID=" & Chr(0x01) & "\"
$data = "TEL=" & Chr(0x06) & Chr(0x07) & Chr(0x09) & Chr(0x03) & Chr(0x05) & Chr(0x00) & Chr(0x00) & "G"
$data = "TSM=" & Chr(0x0B) & Chr(0x08) & Chr(0x09) & Chr(0x01) & Chr(0x04) & Chr(0x08) & Chr(0x07) & Chr(0x05) & Chr(0x01) & Chr(0x01) & Chr(0x00) & Chr(0x09) & Chr(0x18)
$data = "TEMP=" & Chr(0x00) & Chr(0x37) & "ю"
$data = "TP=" & Chr(0x41) & "С"
$data = "ALARM=" & Chr(0x01) & Chr(1) & Chr(0x80)
$data = "AM=" & Chr(0x01) & Chr(0xFF) & Chr(0xCB)
$data = "RS=" & Chr(0x01) & Chr(0xFF) & "U" ;НЕ РЕАЛИЗОВАНО
$data = "TIME=" & Chr(0x31) & Chr(0x03) & Chr(0x11) & Chr(0x41) & Chr(0x14) & "я"
$data = "W:" & " Сбро" & "Щ" ;НЕ РЕАЛИЗОВАНО (ВАЩЕ:))
$data = "SW=" & Chr(0x3C) & "Е"
$data = "OUT=" & Chr(0x01) & ";"
$data = "PS=" & Chr(0x64) & Chr(0x1A)
$data = "PC=" & Chr(0x64) & "ц"
$data = "NE=" & Chr(0x64) & "в"
$data = "NT=" & Chr(0x64) & "К"
$data = "PT=" & Chr(0x64) & "t"
$data = "SN=" & Chr(0x30) & Chr(0x31) & Chr(0x9B)

$data = "TEMP=" & Chr(0x00) & Chr(0x37) & Chr(0xfe) ;"ю"

comRead($data)

Func comSend($tx)
	$chr = StringSplit($tx & Chr(0x00) & Chr(0x8C), "") ;00000000 & reverse polynom
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
	;	$crc = $tx & Chr($dec)

	$hex = Hex($dec, 2)
	MsgBox(0, "Result", "CRC: " & $hex)
EndFunc   ;==>comSend

Func comRead($data)
	$cmd = StringSplit($data, "=")
	If @error = 0 Then
		$chr = StringSplit($cmd[1] & "=" & StringRight($data, 1) & Chr(0x00) & Chr(0x8C), "") ;00000000 & reverse polynom
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
			MsgBox(0, "", "Правильно")
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
					MsgBox(0, "", $id)
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
					MsgBox(0, "", $sn)
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
					MsgBox(0, "", $temp)
				Case $cmd[1] = "TIME"
					$time = Hex(Asc($rxchr[1]), 2) & "-" & Hex(Asc($rxchr[2]), 2) & " " & Hex(Asc($rxchr[3]), 2) & ":" & Hex(Asc($rxchr[4]), 2) & ":" & Hex(Asc($rxchr[5]), 2)
					MsgBox(0, "", $time)
				Case $cmd[1] = "TP"
					$tp = Asc($rx)
					MsgBox(0, "", $tp)
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
		MsgBox(0, "", "Данные без CRC")
		Select
			Case $cmd[1] = "DS1820 ERROR"
				MsgBox(0, "", $cmd[1])
			Case $cmd[1] = "END" & Chr(0x0D) & Chr(0x0A)
				MsgBox(0, "", "Конец сеанса")
			Case $cmd[1] = "OK"
				MsgBox(0, "", $cmd[1])
			Case $cmd[1] = "REMOTE" & Chr(0x0D) & Chr(0x0A)
				MsgBox(0, "", "REMOTE")
		EndSelect
	EndIf
EndFunc   ;==>comRead
