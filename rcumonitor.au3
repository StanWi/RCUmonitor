#include <Array.au3>
#include <string.au3>
#include <CommMG.au3>
#include <comConnection.au3>
#include <comObject.au3>

$fileNetwork = @ScriptDir & "\network.ini"
$fileOptions = @ScriptDir & "\options.ini"
$fileRX = @ScriptDir & "\rx.log"
$fileTX = @ScriptDir & "\tx.log"
$com = IniReadSectionNames($fileNetwork)

Dim $addr[$com[0]][32]
For $i = 1 To $com[0]
	For $k = 1 To 31
		$addr[$i - 1][$k] = IniRead($fileNetwork, $com[$i], "addr" & $k, "")
	Next
Next

While 1
	If ProcessExists("rcu.exe") Then
		If FileExists($fileNetwork) Then
			For $i = 1 To $com[0]
				If IniRead($fileOptions, "main", "auto", 0) = 1 Then
					If IniRead($fileNetwork, $com[$i], "auto", 0) = 1 Then
						comConnect($com[$i])
						comSend("ID? ")
						readByte()
						comSend("ID? ")
						readByte()
						For $k = 1 To 31
							If $addr[$i - 1][$k] <> "" Then
								command_06($addr[$i - 1][$k], $k, $com[$i]) ;Мод.,каналы
								command_04($addr[$i - 1][$k], $k, $com[$i]) ;Сер. №
								command_09($addr[$i - 1][$k], $k, $com[$i]) ;Статус
								command_03($addr[$i - 1][$k], $k, $com[$i]) ;Данные
								command_07($addr[$i - 1][$k], $k, $com[$i]) ;Отказы
								command_0a($addr[$i - 1][$k], $k, $com[$i]) ;Пороги
							EndIf
						Next
						comSend("END ")
						readByte()
						comDisconnect()
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

Func command_06($addr, $k, $com) ;Мод.,каналы
	$data = "CR" & Chr($addr) & Chr(0x06)
	comSend($data)
	Sleep(2000)
	$rx = readByte()
	If StringLeft($rx, 4) = "41FF" Then
		$n = StringLen($rx) / 2
		Dim $dataarray[$n]
		For $i = 0 To $n - 1
			$dataarray[$i] = Chr(Dec(StringMid($rx, $i * 2 + 1, 2)))
		Next
		$rx = _ArrayToString($dataarray, "", 2, $n - 10)
		;MsgBox(0,$com & " " & $k,$rx)
	Else
		;MsgBox(0,"Ошибка чтения параметров устройства",$com & " " & $k)
	EndIf
	IniWrite($fileNetwork, $com, "mode" & $k, $rx)
EndFunc   ;==>command_06

Func command_04($addr, $k, $com) ;Сер. №
	$data = "CR" & Chr($addr) & Chr(0x04)
	comSend($data)
	Sleep(500)
	$rx = readByte()
	If StringLeft($rx, 4) = "41FF" Then
		$n = StringLen($rx) / 2
		Dim $dataarray[$n]
		For $i = 0 To $n - 1
			$dataarray[$i] = StringMid($rx, $i * 2 + 1, 2)
		Next
		$sn = ""
		For $i = 2 To 8
			$sn = $sn & Number($dataarray[$i])
		Next
		;MsgBox(0,"",$com & " " & "snum" & $k & " " & $sn)
		IniWrite($fileNetwork, $com, "snum" & $k, $sn)
	Else
		;MsgBox(0,"Ошибка чтения SN устройства",$com & " " & "snum" & $k)
	EndIf
EndFunc   ;==>command_04

Func command_09($addr, $k, $com) ;Статус
	$data = "CR" & Chr($addr) & Chr(0x09)
	comSend($data)
	Sleep(500)
	$rx = readByte()
	If StringLeft($rx, 4) = "41FF" Then
		$n = StringLen($rx) / 2
		Dim $dataarray[$n]
		For $i = 0 To $n - 1
			$dataarray[$i] = StringMid($rx, $i * 2 + 1, 2)
		Next
		$sn = ""
		For $i = 2 To 7
			$sn = $sn & Number($dataarray[$i])
		Next
		;MsgBox(0,"",$com & " " & "snum" & $k & " " & $sn)
		IniWrite($fileNetwork, $com, "stat" & $k, $sn)
	Else
		;MsgBox(0,"Ошибка чтения SN устройства",$com & " " & "snum" & $k)
	EndIf
EndFunc   ;==>command_09

Func command_03($addr, $k, $com) ;Данные
	$data = "CR" & Chr($addr) & Chr(0x03)
	comSend($data)
	Sleep(1000)
	$rx = readByte()
	If StringLeft($rx, 4) = "41FF" Then
		$rx = StringTrimLeft($rx, 4)
		$rx = StringTrimRight($rx, 16)
		IniWrite($fileNetwork, $com, "data" & $k, $rx)
	Else
		;MsgBox(0,"Ошибка чтения данных устройства",$com & " " & "data" & $k)
	EndIf
EndFunc   ;==>command_03

Func command_07($addr, $k, $com) ;Отказы
	$data = "CR" & Chr($addr) & Chr(0x07)
	comSend($data)
	Sleep(1000)
	$rx = readByte()
	If StringLeft($rx, 4) = "41FF" Then
		$rx = StringTrimLeft($rx, 4)
		$rx = StringTrimRight($rx, 16)
		IniWrite($fileNetwork, $com, "list" & $k, $rx)
	Else
		;MsgBox(0,"Ошибка чтения отказов устройства",$com & " " & "data" & $k)
	EndIf
EndFunc   ;==>command_07

Func command_0a($addr, $k, $com) ;Пороги
	$data = "CR" & Chr($addr) & Chr(0x0a)
	comSend($data)
	Sleep(1000)
	$rx = readByte()
	If StringLeft($rx, 4) = "41FF" Then
		$rx = StringTrimLeft($rx, 4)
		$rx = StringTrimRight($rx, 16)
		IniWrite($fileNetwork, $com, "lmts" & $k, $rx)
	Else
		;MsgBox(0,"Ошибка чтения порогов устройства",$com & " " & "data" & $k)
	EndIf
EndFunc   ;==>command_0a
