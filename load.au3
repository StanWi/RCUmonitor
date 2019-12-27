Func load()
	Global $COM, $name, $auto, $objX, $objY, $IP
	Global $ID, $SN, $TC, $TP
	Global $addr, $mode, $dataX, $lmts
	Global $unit ;удалить
	Global $snum ;удалить-преобразовать
	$COM = IniReadSectionNames($fileNetwork)
	Dim $auto[$COM[0]]
	Dim $objX[$COM[0]]
	Dim $objY[$COM[0]]
	Dim $name[$COM[0]]
	Dim $IP[$COM[0]]
	Dim $addr[$COM[0]][32]
	Dim $mode[$COM[0]][32]
	Dim $dataX[$COM[0]][32]
	Dim $lmts[$COM[0]][32]
	Dim $ID[$COM[0]], $SN[$COM[0]], $TC[$COM[0]], $TP[$COM[0]]
	Dim $unit[$COM[0]][32] ;удалить
	Dim $snum[$COM[0]][32] ;удалить-преобразовать
	For $i = 1 To $COM[0]
		$name[$i - 1] = IniRead($fileNetwork, $COM[$i], "name", $COM[$i])
		$IP[$i - 1] = IniRead($fileNetwork, $COM[$i], "IP", "N/A")
		$ID[$i - 1] = IniRead($fileNetwork, $COM[$i], "ID", "N/A")
		$SN[$i - 1] = IniRead($fileNetwork, $COM[$i], "SN", "N/A")
		$TC[$i - 1] = IniRead($fileNetwork, $COM[$i], "TEMP", "N/A")
		$TP[$i - 1] = IniRead($fileNetwork, $COM[$i], "TP", "N/A")
		$auto[$i - 1] = IniRead($fileNetwork, $COM[$i], "auto", 0)
		$objX[$i - 1] = IniRead($fileNetwork, $COM[$i], "mapX", 22)
		$objY[$i - 1] = IniRead($fileNetwork, $COM[$i], "mapY", 66)
		For $k = 1 To 31
			$addr[$i - 1][$k] = IniRead($fileNetwork, $COM[$i], "addr" & $k, "")
			$mode[$i - 1][$k] = IniRead($fileNetwork, $COM[$i], "mode" & $k, "")
			$dataX[$i - 1][$k] = IniRead($fileNetwork, $COM[$i], "data" & $k, "")
			$lmts[$i - 1][$k] = IniRead($fileNetwork, $COM[$i], "lmts" & $k, "")
			$unit[$i - 1][$k] = IniRead($fileNetwork, $COM[$i], "unit" & $k, "") ;удалить
			$snum[$i - 1][$k] = IniRead($fileNetwork, $COM[$i], "snum" & $k, "N/A") ;удалить-преобразовать
		Next
	Next
EndFunc   ;==>load
