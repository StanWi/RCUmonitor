Func comConnect($COM)
	$sErr = 2
	$port = _CommSetPort(StringTrimLeft($COM, 3), $sErr, 19200, 8, 0, 1, 0)
	If $port = 0 Then
		MsgBox(8208, "Микротек RCU-1 (Ethernet)", "Ошибка соединения с COM-портом." & @CRLF & @CRLF _
				 & "Порт: " & $COM & @CRLF _
				 & "Ошибка: " & $sErr & @CRLF & @CRLF _
				 & "Пожалуйста, свяжитесь с разработчиком.", 5)
		Exit
	EndIf
EndFunc   ;==>comConnect

Func comDisconnect()
	_CommClosePort()
EndFunc   ;==>comDisconnect
