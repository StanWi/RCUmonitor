Func read()
	;Sleep(500)
	While 1
		$rx = _CommGetString()
		;$rx = $rx & _CommGetString()
		If StringLen($rx) <> 0 Then
			ExitLoop
		EndIf
	WEnd
	;Sleep(500)
	$hex = StringSplit($rx, "")
	$fileList = FileOpen($fileRX, 1)
	For $i = 1 To $hex[0]
		;$hex[$i] = _StringToHex($hex[$i])
		FileWrite($fileList, $hex[$i])
	Next
	FileWrite($fileList, @CRLF)
	FileClose($fileList)
	Return $rx
EndFunc   ;==>read

Func readByte()
	$chr = _CommReadByte(1)
	$rx = Hex($chr, 2)
	While 1
		$chr = _CommReadByte(0)
		If $chr = "" Then
			ExitLoop
		EndIf
		$rx = $rx & Hex($chr, 2)
	WEnd
	$fileList = FileOpen($fileRX, 1)
	FileWrite($fileList, $rx)
	FileWrite($fileList, @CRLF)
	FileClose($fileList)
	Return $rx
EndFunc   ;==>readByte


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
	$fileList = FileOpen($fileTX, 1)
	$buffer = StringSplit($crc, "")
	For $i = 1 To $buffer[0]
		FileWrite($fileList, Hex(Asc($buffer[$i]), 2))
		FileWrite($fileList, " ")
	Next
	FileWrite($fileList, @CRLF)
	FileClose($fileList)
	_CommSendString($crc, 0)
EndFunc   ;==>comSend

Func comReadOld($data)
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
			;MsgBox(0,"","Правильно")
			$rx = StringTrimRight($cmd[2], 1)
			$rxchr = StringSplit($cmd[2], "")
			Select
				Case $cmd[1] = "ID"
					$id = Asc($rx)
					;MsgBox(0,"",$id)
					Dim $var[2]
					$var[0] = $cmd[1]
					$var[1] = $id
				Case $cmd[1] = "SN"
					$sn = $rxchr[1] & $rxchr[2]
					;MsgBox(0,"",$sn)
					Dim $var[2]
					$var[0] = $cmd[1]
					$var[1] = $sn
				Case $cmd[1] = "TEMP"
					$temp = (Asc($rxchr[1]) + Asc($rxchr[2])) / 2
					;MsgBox(0,"",$temp)
					Dim $var[2]
					$var[0] = $cmd[1]
					$var[1] = $temp
				Case $cmd[1] = "TP"
					$tp = Asc($rx)
					;MsgBox(0,"",$tp)
					Dim $var[2]
					$var[0] = $cmd[1]
					$var[1] = $tp
			EndSelect
		Else
			;MsgBox(0,"","Ошибка CRC")
			Select
				Case $cmd[1] = "TEMP"
					$temp = "Error"
					;MsgBox(0,"",$temp)
					Dim $var[2]
					$var[0] = "TC"
					$var[1] = $temp
			EndSelect
		EndIf
	Else
		;MsgBox(0,"","Данные без CRC")
		Select
			Case $cmd[1] = "DS1820 ERROR"
				;MsgBox(0,"",$cmd[1])
				Dim $var[2]
				$var[0] = "TEMP"
				$var[1] = "DS1820 ERROR"
			Case $cmd[1] = "END" & Chr(0x0D) & Chr(0x0A)
				;MsgBox(0,"","Конец сеанса")
				Dim $var[2]
				$var[0] = "END"
				$var[1] = "1"
			Case $cmd[1] = "OK"
				;MsgBox(0,"",$cmd[1])
			Case $cmd[1] = "REMOTE" & Chr(0x0D) & Chr(0x0A)
				;MsgBox(0,"","REMOTE")
				Dim $var[2]
				$var[0] = "REMOTE"
				$var[1] = "1"
		EndSelect
	EndIf
	Return $var
EndFunc   ;==>comReadOld

Func comRead($dat)
	$ndat = StringSplit($dat, "")
	$n = $ndat[0] / 2
	Dim $dataarray[$n]
	For $i = 0 To $n - 1
		$dataarray[$i] = StringMid($dat, $i * 2 + 1, 2)
		;$detaarray[$i] = Hex(Dec(StringMid($data,$i * 2 + 1,2)),2)
	Next
	$data = ""
	For $i = 0 To $n - 1
		$data = $data & Chr(Dec($dataarray[$i]))
	Next
	;MsgBox(0,"",$data)
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
			;MsgBox(0,"","Правильно")
			$rx = StringTrimRight($cmd[2], 1)
			$rxchr = StringSplit($cmd[2], "")
			Select
				Case $cmd[1] = "ID"
					$id = Asc($rx)
					;MsgBox(0,"",$id)
					Dim $var[2]
					$var[0] = $cmd[1]
					$var[1] = $id
				Case $cmd[1] = "SN"
					$sn = $rxchr[1] & $rxchr[2]
					;MsgBox(0,"",$sn)
					Dim $var[2]
					$var[0] = $cmd[1]
					$var[1] = $sn
				Case $cmd[1] = "TEMP"
					$temp = (Asc($rxchr[1]) + Asc($rxchr[2])) / 2
					;MsgBox(0,"",$temp)
					Dim $var[2]
					$var[0] = $cmd[1]
					$var[1] = $temp
				Case $cmd[1] = "TP"
					$tp = Asc($rx)
					;MsgBox(0,"",$tp)
					Dim $var[2]
					$var[0] = $cmd[1]
					$var[1] = $tp
			EndSelect
		Else
			MsgBox(0, "", "Ошибка CRC")
			Select
				Case $cmd[1] = "TEMP"
					$temp = "Error"
					;MsgBox(0,"",$temp)
					Dim $var[2]
					$var[0] = "TC"
					$var[1] = $temp
			EndSelect
		EndIf
	Else
		;MsgBox(0,"","Данные без CRC")
		Select
			Case $cmd[1] = "DS1820 ERROR"
				;MsgBox(0,"",$cmd[1])
				Dim $var[2]
				$var[0] = "TEMP"
				$var[1] = "DS1820 ERROR"
			Case $cmd[1] = "END" & Chr(0x0D) & Chr(0x0A)
				;MsgBox(0,"","Конец сеанса")
				Dim $var[2]
				$var[0] = "END"
				$var[1] = "1"
			Case $cmd[1] = "OK"
				;MsgBox(0,"",$cmd[1])
			Case $cmd[1] = "REMOTE" & Chr(0x0D) & Chr(0x0A)
				;MsgBox(0,"","REMOTE")
				Dim $var[2]
				$var[0] = "REMOTE"
				$var[1] = "1"
		EndSelect
	EndIf
	Return $var
	;MsgBox(0,"",$var[0] & "=" & $var[1])
EndFunc   ;==>comRead
