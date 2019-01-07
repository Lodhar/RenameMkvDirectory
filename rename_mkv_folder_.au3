
Func _filecountlines($sfilepath)
	Local $hfile, $sfilecontent, $atmp
	$hfile = FileOpen($sfilepath, 0)
	If $hfile = -1 Then Return SetError(1, 0, 0)
	$sfilecontent = StringStripWS(FileRead($hfile), 2)
	FileClose($hfile)
	If StringInStr($sfilecontent, @LF) Then
		$atmp = StringSplit(StringStripCR($sfilecontent), @LF)
	ElseIf StringInStr($sfilecontent, @CR) Then
		$atmp = StringSplit($sfilecontent, @CR)
	Else
		If StringLen($sfilecontent) Then
			Return 1
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf
	Return $atmp[0]
EndFunc

Func _filecreate($sfilepath)
	Local $hopenfile
	Local $hwritefile
	$hopenfile = FileOpen($sfilepath, 2)
	If $hopenfile = -1 Then
		SetError(1)
		Return 0
	EndIf
	$hwritefile = FileWrite($hopenfile, "")
	If $hwritefile = -1 Then
		SetError(2)
		Return 0
	EndIf
	FileClose($hopenfile)
	Return 1
EndFunc

Func _filelisttoarray($spath, $sfilter = "*", $iflag = 0)
	Local $hsearch, $sfile, $asfilelist[1]
	If NOT FileExists($spath) Then Return SetError(1, 1, "")
	If (StringInStr($sfilter, "\")) OR (StringInStr($sfilter, "/")) OR (StringInStr($sfilter, ":")) OR (StringInStr($sfilter, ">")) OR (StringInStr($sfilter, "<")) OR (StringInStr($sfilter, "|")) OR (StringStripWS($sfilter, 8) = "") Then Return SetError(2, 2, "")
	If NOT ($iflag = 0 OR $iflag = 1 OR $iflag = 2) Then Return SetError(3, 3, "")
	If (StringMid($spath, StringLen($spath), 1) = "\") Then $spath = StringTrimRight($spath, 1)
	$hsearch = FileFindFirstFile($spath & "\" & $sfilter)
	If $hsearch = -1 Then Return SetError(4, 4, "")
	While 1
		$sfile = FileFindNextFile($hsearch)
		If @error Then
			SetError(0)
			ExitLoop
		EndIf
		If $iflag = 1 AND StringInStr(FileGetAttrib($spath & "\" & $sfile), "D") <> 0 Then ContinueLoop
		If $iflag = 2 AND StringInStr(FileGetAttrib($spath & "\" & $sfile), "D") = 0 Then ContinueLoop
		$asfilelist[0] += 1
		If UBound($asfilelist) <= $asfilelist[0] Then ReDim $asfilelist[UBound($asfilelist) * 2]
		$asfilelist[$asfilelist[0]] = $sfile
	WEnd
	FileClose($hsearch)
	ReDim $asfilelist[$asfilelist[0] + 1]
	Return $asfilelist
EndFunc

Func _fileprint($s_file, $i_show = @SW_HIDE)
	Local $a_ret = DllCall("shell32.dll", "long", "ShellExecute", "hwnd", 0, "string", "print", "string", $s_file, "string", "", "string", "", "int", $i_show)
	If $a_ret[0] > 32 AND NOT @error Then
		Return 1
	Else
		SetError($a_ret[0])
		Return 0
	EndIf
EndFunc

Func _filereadtoarray($sfilepath, ByRef $aarray)
	Local $hfile, $afile
	$hfile = FileOpen($sfilepath, 0)
	If $hfile = -1 Then Return SetError(1, 0, 0)
	$afile = FileRead($hfile, FileGetSize($sfilepath))
	$afile = StringStripWS($afile, 2)
	FileClose($hfile)
	If StringInStr($afile, @LF) Then
		$aarray = StringSplit(StringStripCR($afile), @LF)
	ElseIf StringInStr($afile, @CR) Then
		$aarray = StringSplit($afile, @CR)
	Else
		If StringLen($afile) Then
			Dim $aarray[2] = [1, $afile]
		Else
			Return SetError(2, 0, 0)
		EndIf
	EndIf
	Return 1
EndFunc

Func _filewritefromarray($file, $a_array, $i_base = 0, $i_ubound = 0)
	If NOT IsArray($a_array) Then Return SetError(2, 0, 0)
	Local $last = UBound($a_array) - 1
	If $i_ubound < 1 OR $i_ubound > $last Then $i_ubound = $last
	If $i_base < 0 OR $i_base > $last Then $i_base = 0
	Local $hfile
	If IsString($file) Then
		$hfile = FileOpen($file, 2)
	Else
		$hfile = $file
	EndIf
	If $hfile = -1 Then Return SetError(1, 0, 0)
	Local $errorsav = 0
	For $x = $i_base To $i_ubound
		If FileWrite($hfile, $a_array[$x] & @CRLF) = 0 Then
			$errorsav = 3
			ExitLoop
		EndIf
	Next
	If IsString($file) Then FileClose($hfile)
	If $errorsav Then
		Return SetError($errorsav, 0, 0)
	Else
		Return 1
	EndIf
EndFunc

Func _filewritelog($slogpath, $slogmsg, $iflag = -1)
	Local $sdatenow, $stimenow, $smsg, $iwritefile, $hopenfile, $iopenmode = 1
	$sdatenow = @YEAR & "-" & @MON & "-" & @MDAY
	$stimenow = @HOUR & ":" & @MIN & ":" & @SEC
	$smsg = $sdatenow & " " & $stimenow & " : " & $slogmsg
	If $iflag <> -1 Then
		$smsg &= @CRLF & FileRead($slogpath)
		$iopenmode = 2
	EndIf
	$hopenfile = FileOpen($slogpath, $iopenmode)
	If $hopenfile = -1 Then Return SetError(1, 0, 0)
	$iwritefile = FileWriteLine($hopenfile, $smsg)
	If $iwritefile = -1 Then Return SetError(2, 0, 0)
	Return FileClose($hopenfile)
EndFunc

Func _filewritetoline($sfile, $iline, $stext, $foverwrite = 0)
	If $iline <= 0 Then Return SetError(4, 0, 0)
	If NOT IsString($stext) Then Return SetError(6, 0, 0)
	If $foverwrite <> 0 AND $foverwrite <> 1 Then Return SetError(5, 0, 0)
	If NOT FileExists($sfile) Then Return SetError(2, 0, 0)
	Local $filtxt = FileRead($sfile, FileGetSize($sfile))
	$filtxt = StringSplit($filtxt, @CRLF, 1)
	If UBound($filtxt, 1) < $iline Then Return SetError(1, 0, 0)
	Local $fil = FileOpen($sfile, 2)
	If $fil = -1 Then Return SetError(3, 0, 0)
	For $i = 1 To UBound($filtxt) - 1
		If $i = $iline Then
			If $foverwrite = 1 Then
				If $stext <> "" Then
					FileWrite($fil, $stext & @CRLF)
				Else
					FileWrite($fil, $stext)
				EndIf
			EndIf
			If $foverwrite = 0 Then
				FileWrite($fil, $stext & @CRLF)
				FileWrite($fil, $filtxt[$i] & @CRLF)
			EndIf
		ElseIf $i < UBound($filtxt, 1) - 1 Then
			FileWrite($fil, $filtxt[$i] & @CRLF)
		ElseIf $i = UBound($filtxt, 1) - 1 Then
			FileWrite($fil, $filtxt[$i])
		EndIf
	Next
	FileClose($fil)
	Return 1
EndFunc

Func _pathfull($srelativepath, $sbasepath = @WorkingDir)
	If NOT $srelativepath OR $srelativepath = "." Then Return $sbasepath
	Local $sfullpath = StringReplace($srelativepath, "/", "\")
	Local Const $sfullpathconst = $sfullpath
	Local $spath
	Local $brootonly = StringLeft($sfullpath, 1) = "\" AND StringMid($sfullpath, 2, 1) <> "\"
	For $i = 1 To 2
		$spath = StringLeft($sfullpath, 2)
		If $spath = "\\" Then
			$sfullpath = StringTrimLeft($sfullpath, 2)
			$spath &= StringLeft($sfullpath, StringInStr($sfullpath, "\") - 1)
			ExitLoop
		ElseIf StringRight($spath, 1) = ":" Then
			$sfullpath = StringTrimLeft($sfullpath, 2)
			ExitLoop
		Else
			$sfullpath = $sbasepath & "\" & $sfullpath
		EndIf
	Next
	If $i = 3 Then Return ""
	Local $atemp = StringSplit($sfullpath, "\")
	Local $apathparts[$atemp[0]], $j = 0
	For $i = 2 To $atemp[0]
		If $atemp[$i] = ".." Then
			If $j Then $j -= 1
		ElseIf NOT ($atemp[$i] = "" AND $i <> $atemp[0]) AND $atemp[$i] <> "." Then
			$apathparts[$j] = $atemp[$i]
			$j += 1
		EndIf
	Next
	$sfullpath = $spath
	If NOT $brootonly Then
		For $i = 0 To $j - 1
			$sfullpath &= "\" & $apathparts[$i]
		Next
	Else
		$sfullpath &= $sfullpathconst
		If StringInStr($sfullpath, "..") Then $sfullpath = _pathfull($sfullpath)
	EndIf
	While StringInStr($sfullpath, ".\")
		$sfullpath = StringReplace($sfullpath, ".\", "\")
	WEnd
	Return $sfullpath
EndFunc

Func _pathgetrelative($sfrom, $sto)
	Local $asfrom, $asto, $idiff, $srelpath, $i
	If StringRight($sfrom, 1) <> "\" Then $sfrom &= "\"
	If StringRight($sto, 1) <> "\" Then $sto &= "\"
	If $sfrom = $sto Then Return SetError(1, 0, StringTrimRight($sto, 1))
	$asfrom = StringSplit($sfrom, "\")
	$asto = StringSplit($sto, "\")
	If $asfrom[1] <> $asto[1] Then Return SetError(2, 0, StringTrimRight($sto, 1))
	$i = 2
	$idiff = 1
	While 1
		If $asfrom[$i] <> $asto[$i] Then
			$idiff = $i
			ExitLoop
		EndIf
		$i += 1
	WEnd
	$i = 1
	$srelpath = ""
	For $j = 1 To $asto[0]
		If $i >= $idiff Then
			$srelpath &= "\" & $asto[$i]
		EndIf
		$i += 1
	Next
	$srelpath = StringTrimLeft($srelpath, 1)
	$i = 1
	For $j = 1 To $asfrom[0]
		If $i > $idiff Then
			$srelpath = "..\" & $srelpath
		EndIf
		$i += 1
	Next
	If StringRight($srelpath, 1) == "\" Then $srelpath = StringTrimRight($srelpath, 1)
	Return $srelpath
EndFunc

Func _pathmake($szdrive, $szdir, $szfname, $szext)
	Local $szfullpath
	If StringLen($szdrive) Then
		If NOT (StringLeft($szdrive, 2) = "\\") Then $szdrive = StringLeft($szdrive, 1) & ":"
	EndIf
	If StringLen($szdir) Then
		If NOT (StringRight($szdir, 1) = "\") AND NOT (StringRight($szdir, 1) = "/") Then $szdir = $szdir & "\"
	EndIf
	If StringLen($szext) Then
		If NOT (StringLeft($szext, 1) = ".") Then $szext = "." & $szext
	EndIf
	$szfullpath = $szdrive & $szdir & $szfname & $szext
	Return $szfullpath
EndFunc

Func _pathsplit($szpath, ByRef $szdrive, ByRef $szdir, ByRef $szfname, ByRef $szext)
	Local $drive = ""
	Local $dir = ""
	Local $fname = ""
	Local $ext = ""
	Local $pos
	Local $array[5]
	$array[0] = $szpath
	If StringMid($szpath, 2, 1) = ":" Then
		$drive = StringLeft($szpath, 2)
		$szpath = StringTrimLeft($szpath, 2)
	ElseIf StringLeft($szpath, 2) = "\\" Then
		$szpath = StringTrimLeft($szpath, 2)
		$pos = StringInStr($szpath, "\")
		If $pos = 0 Then $pos = StringInStr($szpath, "/")
		If $pos = 0 Then
			$drive = "\\" & $szpath
			$szpath = ""
		Else
			$drive = "\\" & StringLeft($szpath, $pos - 1)
			$szpath = StringTrimLeft($szpath, $pos - 1)
		EndIf
	EndIf
	Local $nposforward = StringInStr($szpath, "/", 0, -1)
	Local $nposbackward = StringInStr($szpath, "\", 0, -1)
	If $nposforward >= $nposbackward Then
		$pos = $nposforward
	Else
		$pos = $nposbackward
	EndIf
	$dir = StringLeft($szpath, $pos)
	$fname = StringRight($szpath, StringLen($szpath) - $pos)
	If StringLen($dir) = 0 Then $fname = $szpath
	$pos = StringInStr($fname, ".", 0, -1)
	If $pos Then
		$ext = StringRight($fname, StringLen($fname) - ($pos - 1))
		$fname = StringLeft($fname, $pos - 1)
	EndIf
	$szdrive = $drive
	$szdir = $dir
	$szfname = $fname
	$szext = $ext
	$array[1] = $drive
	$array[2] = $dir
	$array[3] = $fname
	$array[4] = $ext
	Return $array
EndFunc

Func _replacestringinfile($szfilename, $szsearchstring, $szreplacestring, $fcaseness = 0, $foccurance = 1)
	Local $iretval = 0
	Local $hwritehandle, $afilelines, $ncount, $sendswith, $hfile
	If StringInStr(FileGetAttrib($szfilename), "R") Then Return SetError(6, 0, -1)
	$hfile = FileOpen($szfilename, 0)
	If $hfile = -1 Then Return SetError(1, 0, -1)
	Local $s_totfile = FileRead($hfile, FileGetSize($szfilename))
	If StringRight($s_totfile, 2) = @CRLF Then
		$sendswith = @CRLF
	ElseIf StringRight($s_totfile, 1) = @CR Then
		$sendswith = @CR
	ElseIf StringRight($s_totfile, 1) = @LF Then
		$sendswith = @LF
	Else
		$sendswith = ""
	EndIf
	$afilelines = StringSplit(StringStripCR($s_totfile), @LF)
	FileClose($hfile)
	$hwritehandle = FileOpen($szfilename, 2)
	If $hwritehandle = -1 Then Return SetError(2, 0, -1)
	For $ncount = 1 To $afilelines[0]
		If StringInStr($afilelines[$ncount], $szsearchstring, $fcaseness) Then
			$afilelines[$ncount] = StringReplace($afilelines[$ncount], $szsearchstring, $szreplacestring, 1 - $foccurance, $fcaseness)
			$iretval = $iretval + 1
			If $foccurance = 0 Then
				$iretval = 1
				ExitLoop
			EndIf
		EndIf
	Next
	For $ncount = 1 To $afilelines[0] - 1
		If FileWriteLine($hwritehandle, $afilelines[$ncount]) = 0 Then
			SetError(3)
			FileClose($hwritehandle)
			Return -1
		EndIf
	Next
	If $afilelines[$ncount] <> "" Then FileWrite($hwritehandle, $afilelines[$ncount] & $sendswith)
	FileClose($hwritehandle)
	Return $iretval
EndFunc

Func _tempfile($s_directoryname = @TempDir, $s_fileprefix = "~", $s_fileextension = ".tmp", $i_randomlength = 7)
	Local $s_tempname
	If NOT FileExists($s_directoryname) Then $s_directoryname = @TempDir
	If NOT FileExists($s_directoryname) Then $s_directoryname = @ScriptDir
	If StringRight($s_directoryname, 1) <> "\" Then $s_directoryname = $s_directoryname & "\"
	Do
		$s_tempname = ""
		While StringLen($s_tempname) < $i_randomlength
			$s_tempname = $s_tempname & Chr(Random(97, 122, 1))
		WEnd
		$s_tempname = $s_directoryname & $s_fileprefix & $s_tempname & $s_fileextension
	Until NOT FileExists($s_tempname)
	Return ($s_tempname)
EndFunc

Func _arrayadd(ByRef $avarray, $vvalue)
	If NOT IsArray($avarray) Then Return SetError(1, 0, -1)
	If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, -1)
	Local $iubound = UBound($avarray)
	ReDim $avarray[$iubound + 1]
	$avarray[$iubound] = $vvalue
	Return $iubound
EndFunc

Func _arraybinarysearch(Const ByRef $avarray, $vvalue, $istart = 0, $iend = 0)
	If NOT IsArray($avarray) Then Return SetError(1, 0, -1)
	If UBound($avarray, 0) <> 1 Then Return SetError(5, 0, -1)
	Local $iubound = UBound($avarray) - 1
	If $iend < 1 OR $iend > $iubound Then $iend = $iubound
	If $istart < 0 Then $istart = 0
	If $istart > $iend Then Return SetError(4, 0, -1)
	Local $imid = Int(($iend + $istart) / 2)
	If $avarray[$istart] > $vvalue OR $avarray[$iend] < $vvalue Then Return SetError(2, 0, -1)
	While $istart <= $imid AND $vvalue <> $avarray[$imid]
		If $vvalue < $avarray[$imid] Then
			$iend = $imid - 1
		Else
			$istart = $imid + 1
		EndIf
		$imid = Int(($iend + $istart) / 2)
	WEnd
	If $istart > $iend Then Return SetError(3, 0, -1)
	Return $imid
EndFunc

Func _arraycombinations(ByRef $avarray, $iset, $sdelim = "")
	Local $i, $aidx[1], $aresult[1], $in = 0, $ir = 0, $ileft = 0, $itotal = 0, $icount = 1
	If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
	If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, 0)
	$in = UBound($avarray)
	$ir = $iset
	Dim $aidx[$ir]
	For $i = 0 To $ir - 1
		$aidx[$i] = $i
	Next
	$itotal = _array_combinations($in, $ir)
	$ileft = $itotal
	ReDim $aresult[$itotal + 1]
	$aresult[0] = $itotal
	While $ileft > 0
		_array_getnext($in, $ir, $ileft, $itotal, $aidx)
		For $i = 0 To $iset - 1
			$aresult[$icount] &= $avarray[$aidx[$i]] & $sdelim
		Next
		If $sdelim <> "" Then $aresult[$icount] = StringTrimRight($aresult[$icount], 1)
		$icount += 1
	WEnd
	Return $aresult
EndFunc

Func _arrayconcatenate(ByRef $avarraytarget, Const ByRef $avarraysource)
	If NOT IsArray($avarraytarget) Then Return SetError(1, 0, 0)
	If NOT IsArray($avarraysource) Then Return SetError(2, 0, 0)
	If UBound($avarraytarget, 0) <> 1 Then
		If UBound($avarraysource, 0) <> 1 Then Return SetError(5, 0, 0)
		Return SetError(3, 0, 0)
	EndIf
	If UBound($avarraysource, 0) <> 1 Then Return SetError(4, 0, 0)
	Local $iuboundtarget = UBound($avarraytarget), $iuboundsource = UBound($avarraysource)
	ReDim $avarraytarget[$iuboundtarget + $iuboundsource]
	For $i = 0 To $iuboundsource - 1
		$avarraytarget[$iuboundtarget + $i] = $avarraysource[$i]
	Next
	Return $iuboundtarget + $iuboundsource
EndFunc

Func _arraycreate($v_0, $v_1 = 0, $v_2 = 0, $v_3 = 0, $v_4 = 0, $v_5 = 0, $v_6 = 0, $v_7 = 0, $v_8 = 0, $v_9 = 0, $v_10 = 0, $v_11 = 0, $v_12 = 0, $v_13 = 0, $v_14 = 0, $v_15 = 0, $v_16 = 0, $v_17 = 0, $v_18 = 0, $v_19 = 0, $v_20 = 0)
	Local $av_array[21] = [$v_0, $v_1, $v_2, $v_3, $v_4, $v_5, $v_6, $v_7, $v_8, $v_9, $v_10, $v_11, $v_12, $v_13, $v_14, $v_15, $v_16, $v_17, $v_18, $v_19, $v_20]
	ReDim $av_array[@NumParams]
	Return $av_array
EndFunc

Func _arraydelete(ByRef $avarray, $ielement)
	If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
	Local $iubound = UBound($avarray, 1) - 1
	If NOT $iubound Then
		$avarray = ""
		Return 0
	EndIf
	If $ielement < 0 Then $ielement = 0
	If $ielement > $iubound Then $ielement = $iubound
	Switch UBound($avarray, 0)
		Case 1
			For $i = $ielement To $iubound - 1
				$avarray[$i] = $avarray[$i + 1]
			Next
			ReDim $avarray[$iubound]
		Case 2
			Local $isubmax = UBound($avarray, 2) - 1
			For $i = $ielement To $iubound - 1
				For $j = 0 To $isubmax
					$avarray[$i][$j] = $avarray[$i + 1][$j]
				Next
			Next
			ReDim $avarray[$iubound][$isubmax + 1]
		Case Else
			Return SetError(3, 0, 0)
	EndSwitch
	Return $iubound
EndFunc

Func _arraydisplay(Const ByRef $avarray, $stitle = "Array: ListView Display", $iitemlimit = -1, $itranspose = 0, $sseparator = "", $sreplace = "|")
	If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
	Local $idimension = UBound($avarray, 0), $iubound = UBound($avarray, 1) - 1, $isubmax = UBound($avarray, 2) - 1
	If $idimension > 2 Then Return SetError(2, 0, 0)
	If $sseparator = "" Then $sseparator = Chr(124)
	Local $i, $j, $vtmp, $aitem, $avarraytext, $sheader = "Row", $ibuffer = 64
	Local $icollimit = 250, $ilviaddudfthreshold = 4000, $iwidth = 640, $iheight = 480
	Local $ioneventmode = Opt("GUIOnEventMode", 0), $sdataseparatorchar = Opt("GUIDataSeparatorChar", $sseparator)
	If $isubmax < 0 Then $isubmax = 0
	If $itranspose Then
		$vtmp = $iubound
		$iubound = $isubmax
		$isubmax = $vtmp
	EndIf
	If $isubmax > $icollimit Then $isubmax = $icollimit
	If $iitemlimit = 1 Then $iitemlimit = $ilviaddudfthreshold
	If $iitemlimit < 1 Then $iitemlimit = $iubound
	If $iubound > $iitemlimit Then $iubound = $iitemlimit
	If $ilviaddudfthreshold > $iubound Then $ilviaddudfthreshold = $iubound
	For $i = 0 To $isubmax
		$sheader &= $sseparator & "Col " & $i
	Next
	Local $avarraytext[$iubound + 1]
	For $i = 0 To $iubound
		$avarraytext[$i] = "[" & $i & "]"
		For $j = 0 To $isubmax
			If $idimension = 1 Then
				If $itranspose Then
					$vtmp = $avarray[$j]
				Else
					$vtmp = $avarray[$i]
				EndIf
			Else
				If $itranspose Then
					$vtmp = $avarray[$j][$i]
				Else
					$vtmp = $avarray[$i][$j]
				EndIf
			EndIf
			$vtmp = StringReplace($vtmp, $sseparator, $sreplace, 0, 1)
			$avarraytext[$i] &= $sseparator & $vtmp
			$vtmp = StringLen($vtmp)
			If $vtmp > $ibuffer Then $ibuffer = $vtmp
		Next
	Next
	$ibuffer += 1
	Local Const $_arrayconstant_gui_dockborders = 102
	Local Const $_arrayconstant_gui_dockbottom = 64
	Local Const $_arrayconstant_gui_dockheight = 512
	Local Const $_arrayconstant_gui_dockleft = 2
	Local Const $_arrayconstant_gui_dockright = 4
	Local Const $_arrayconstant_gui_event_close = -3
	Local Const $_arrayconstant_lvif_param = 4
	Local Const $_arrayconstant_lvif_text = 1
	Local Const $_arrayconstant_lvm_getcolumnwidth = (4096 + 29)
	Local Const $_arrayconstant_lvm_getitemcount = (4096 + 4)
	Local Const $_arrayconstant_lvm_getitemstate = (4096 + 44)
	Local Const $_arrayconstant_lvm_insertitema = (4096 + 7)
	Local Const $_arrayconstant_lvm_setextendedlistviewstyle = (4096 + 54)
	Local Const $_arrayconstant_lvm_setitema = (4096 + 6)
	Local Const $_arrayconstant_lvs_ex_fullrowselect = 32
	Local Const $_arrayconstant_lvs_ex_gridlines = 1
	Local Const $_arrayconstant_lvs_showselalways = 8
	Local Const $_arrayconstant_ws_ex_clientedge = 512
	Local Const $_arrayconstant_ws_maximizebox = 65536
	Local Const $_arrayconstant_ws_minimizebox = 131072
	Local Const $_arrayconstant_ws_sizebox = 262144
	Local Const $_arrayconstant_taglvitem = "int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns"
	Local $iaddmask = BitOR($_arrayconstant_lvif_text, $_arrayconstant_lvif_param)
	Local $tbuffer = DllStructCreate("char Text[" & $ibuffer & "]"), $pbuffer = DllStructGetPtr($tbuffer)
	Local $titem = DllStructCreate($_arrayconstant_taglvitem), $pitem = DllStructGetPtr($titem)
	DllStructSetData($titem, "Param", 0)
	DllStructSetData($titem, "Text", $pbuffer)
	DllStructSetData($titem, "TextMax", $ibuffer)
	Local $hgui = GUICreate($stitle, $iwidth, $iheight, Default, Default, BitOR($_arrayconstant_ws_sizebox, $_arrayconstant_ws_minimizebox, $_arrayconstant_ws_maximizebox))
	Local $aiguisize = WinGetClientSize($hgui)
	Local $hlistview = GUICtrlCreateListView($sheader, 0, 0, $aiguisize[0], $aiguisize[1] - 26, $_arrayconstant_lvs_showselalways)
	Local $hcopy = GUICtrlCreateButton("Copy Selected", 3, $aiguisize[1] - 23, $aiguisize[0] - 6, 20)
	GUICtrlSetResizing($hlistview, $_arrayconstant_gui_dockborders)
	GUICtrlSetResizing($hcopy, $_arrayconstant_gui_dockleft + $_arrayconstant_gui_dockright + $_arrayconstant_gui_dockbottom + $_arrayconstant_gui_dockheight)
	GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_setextendedlistviewstyle, $_arrayconstant_lvs_ex_gridlines, $_arrayconstant_lvs_ex_gridlines)
	GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_setextendedlistviewstyle, $_arrayconstant_lvs_ex_fullrowselect, $_arrayconstant_lvs_ex_fullrowselect)
	GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_setextendedlistviewstyle, $_arrayconstant_ws_ex_clientedge, $_arrayconstant_ws_ex_clientedge)
	For $i = 0 To $ilviaddudfthreshold
		GUICtrlCreateListViewItem($avarraytext[$i], $hlistview)
	Next
	For $i = ($ilviaddudfthreshold + 1) To $iubound
		$aitem = StringSplit($avarraytext[$i], $sseparator)
		DllStructSetData($tbuffer, "Text", $aitem[1])
		DllStructSetData($titem, "Item", $i)
		DllStructSetData($titem, "SubItem", 0)
		DllStructSetData($titem, "Mask", $iaddmask)
		GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_insertitema, 0, $pitem)
		DllStructSetData($titem, "Mask", $_arrayconstant_lvif_text)
		For $j = 2 To $aitem[0]
			DllStructSetData($tbuffer, "Text", $aitem[$j])
			DllStructSetData($titem, "SubItem", $j - 1)
			GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_setitema, 0, $pitem)
		Next
	Next
	$iwidth = 0
	For $i = 0 To $isubmax + 1
		$iwidth += GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_getcolumnwidth, $i, 0)
	Next
	If $iwidth < 250 Then $iwidth = 230
	WinMove($hgui, "", Default, Default, $iwidth + 20)
	GUISetState(@SW_SHOW, $hgui)
	While 1
		Switch GUIGetMsg()
			Case $_arrayconstant_gui_event_close
				ExitLoop
			Case $hcopy
				Local $sclip = ""
				Local $aicuritems[1] = [0]
				For $i = 0 To GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_getitemcount, 0, 0)
					If GUICtrlSendMsg($hlistview, $_arrayconstant_lvm_getitemstate, $i, 2) Then
						$aicuritems[0] += 1
						ReDim $aicuritems[$aicuritems[0] + 1]
						$aicuritems[$aicuritems[0]] = $i
					EndIf
				Next
				If NOT $aicuritems[0] Then
					For $sitem In $avarraytext
						$sclip &= $sitem & @CRLF
					Next
				Else
					For $i = 1 To UBound($aicuritems) - 1
						$sclip &= $avarraytext[$aicuritems[$i]] & @CRLF
					Next
				EndIf
				ClipPut($sclip)
		EndSwitch
	WEnd
	GUIDelete($hgui)
	Opt("GUIOnEventMode", $ioneventmode)
	Opt("GUIDataSeparatorChar", $sdataseparatorchar)
	Return 1
EndFunc

Func _arrayfindall(Const ByRef $avarray, $vvalue, $istart = 0, $iend = 0, $icase = 0, $ipartial = 0, $isubitem = 0)
	$istart = _arraysearch($avarray, $vvalue, $istart, $iend, $icase, $ipartial, 1, $isubitem)
	If @error Then Return SetError(@error, 0, -1)
	Local $iindex = 0, $avresult[UBound($avarray)]
	Do
		$avresult[$iindex] = $istart
		$iindex += 1
		$istart = _arraysearch($avarray, $vvalue, $istart + 1, $iend, $icase, $ipartial, 1, $isubitem)
	Until @error
	ReDim $avresult[$iindex]
	Return $avresult
EndFunc

Func _arrayinsert(ByRef $avarray, $ielement, $vvalue = "")
	If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
	If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, 0)
	Local $iubound = UBound($avarray) + 1
	ReDim $avarray[$iubound]
	For $i = $iubound - 1 To $ielement + 1 Step -1
		$avarray[$i] = $avarray[$i - 1]
	Next
	$avarray[$ielement] = $vvalue
	Return $iubound
EndFunc

Func _arraymax(Const ByRef $avarray, $icompnumeric = 0, $istart = 0, $iend = 0)
	Local $iresult = _arraymaxindex($avarray, $icompnumeric, $istart, $iend)
	If @error Then Return SetError(@error, 0, "")
	Return $avarray[$iresult]
EndFunc

Func _arraymaxindex(Const ByRef $avarray, $icompnumeric = 0, $istart = 0, $iend = 0)
	If NOT IsArray($avarray) OR UBound($avarray, 0) <> 1 Then Return SetError(1, 0, -1)
	If UBound($avarray, 0) <> 1 Then Return SetError(3, 0, -1)
	Local $iubound = UBound($avarray) - 1
	If $iend < 1 OR $iend > $iubound Then $iend = $iubound
	If $istart < 0 Then $istart = 0
	If $istart > $iend Then Return SetError(2, 0, -1)
	Local $imaxindex = $istart
	If $icompnumeric Then
		For $i = $istart To $iend
			If Number($avarray[$imaxindex]) < Number($avarray[$i]) Then $imaxindex = $i
		Next
	Else
		For $i = $istart To $iend
			If $avarray[$imaxindex] < $avarray[$i] Then $imaxindex = $i
		Next
	EndIf
	Return $imaxindex
EndFunc

Func _arraymin(Const ByRef $avarray, $icompnumeric = 0, $istart = 0, $iend = 0)
	Local $iresult = _arrayminindex($avarray, $icompnumeric, $istart, $iend)
	If @error Then Return SetError(@error, 0, "")
	Return $avarray[$iresult]
EndFunc

Func _arrayminindex(Const ByRef $avarray, $icompnumeric = 0, $istart = 0, $iend = 0)
	If NOT IsArray($avarray) Then Return SetError(1, 0, -1)
	If UBound($avarray, 0) <> 1 Then Return SetError(3, 0, -1)
	Local $iubound = UBound($avarray) - 1
	If $iend < 1 OR $iend > $iubound Then $iend = $iubound
	If $istart < 0 Then $istart = 0
	If $istart > $iend Then Return SetError(2, 0, -1)
	Local $iminindex = $istart
	If $icompnumeric Then
		For $i = $istart To $iend
			If Number($avarray[$iminindex]) > Number($avarray[$i]) Then $iminindex = $i
		Next
	Else
		For $i = $istart To $iend
			If $avarray[$iminindex] > $avarray[$i] Then $iminindex = $i
		Next
	EndIf
	Return $iminindex
EndFunc

Func _arraypermute(ByRef $avarray, $sdelim = "")
	If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
	If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, 0)
	Local $i, $isize = UBound($avarray), $ifactorial = 1, $aidx[$isize], $aresult[1], $icount = 1
	For $i = 0 To $isize - 1
		$aidx[$i] = $i
	Next
	For $i = $isize To 1 Step -1
		$ifactorial *= $i
	Next
	ReDim $aresult[$ifactorial + 1]
	$aresult[0] = $ifactorial
	_array_exeterinternal($avarray, 0, $isize, $sdelim, $aidx, $aresult, $icount)
	Return $aresult
EndFunc

Func _arraypop(ByRef $avarray)
	If (NOT IsArray($avarray)) Then Return SetError(1, 0, "")
	If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, "")
	Local $iubound = UBound($avarray) - 1, $slastval = $avarray[$iubound]
	If NOT $iubound Then
		$avarray = ""
	Else
		ReDim $avarray[$iubound]
	EndIf
	Return $slastval
EndFunc

Func _arraypush(ByRef $avarray, $vvalue, $idirection = 0)
	If (NOT IsArray($avarray)) Then Return SetError(1, 0, 0)
	If UBound($avarray, 0) <> 1 Then Return SetError(3, 0, 0)
	Local $iubound = UBound($avarray) - 1
	If IsArray($vvalue) Then
		Local $iubounds = UBound($vvalue)
		If ($iubounds - 1) > $iubound Then Return SetError(2, 0, 0)
		If $idirection Then
			For $i = $iubound To $iubounds Step -1
				$avarray[$i] = $avarray[$i - $iubounds]
			Next
			For $i = 0 To $iubounds - 1
				$avarray[$i] = $vvalue[$i]
			Next
		Else
			For $i = 0 To $iubound - $iubounds
				$avarray[$i] = $avarray[$i + $iubounds]
			Next
			For $i = 0 To $iubounds - 1
				$avarray[$i + $iubound - $iubounds + 1] = $vvalue[$i]
			Next
		EndIf
	Else
		If $idirection Then
			For $i = $iubound To 1 Step -1
				$avarray[$i] = $avarray[$i - 1]
			Next
			$avarray[0] = $vvalue
		Else
			For $i = 0 To $iubound - 1
				$avarray[$i] = $avarray[$i + 1]
			Next
			$avarray[$iubound] = $vvalue
		EndIf
	EndIf
	Return 1
EndFunc

Func _arrayreverse(ByRef $avarray, $istart = 0, $iend = 0)
	If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
	If UBound($avarray, 0) <> 1 Then Return SetError(3, 0, 0)
	Local $vtmp, $iubound = UBound($avarray) - 1
	If $iend < 1 OR $iend > $iubound Then $iend = $iubound
	If $istart < 0 Then $istart = 0
	If $istart > $iend Then Return SetError(2, 0, 0)
	For $i = $istart To Int(($istart + $iend - 1) / 2)
		$vtmp = $avarray[$i]
		$avarray[$i] = $avarray[$iend]
		$avarray[$iend] = $vtmp
		$iend -= 1
	Next
	Return 1
EndFunc

Func _arraysearch(Const ByRef $avarray, $vvalue, $istart = 0, $iend = 0, $icase = 0, $ipartial = 0, $iforward = 1, $isubitem = 0)
	If NOT IsArray($avarray) Then Return SetError(1, 0, -1)
	If UBound($avarray, 0) > 2 OR UBound($avarray, 0) < 1 Then Return SetError(2, 0, 0)
	Local $iubound = UBound($avarray) - 1
	If $iend < 1 OR $iend > $iubound Then $iend = $iubound
	If $istart < 0 Then $istart = 0
	If $istart > $iend Then Return SetError(4, 0, -1)
	Local $istep = 1
	If NOT $iforward Then
		Local $itmp = $istart
		$istart = $iend
		$iend = $itmp
		$istep = -1
	EndIf
	Switch UBound($avarray, 0)
		Case 1
			If NOT $ipartial Then
				If NOT $icase Then
					For $i = $istart To $iend Step $istep
						If $avarray[$i] = $vvalue Then Return $i
					Next
				Else
					For $i = $istart To $iend Step $istep
						If $avarray[$i] == $vvalue Then Return $i
					Next
				EndIf
			Else
				For $i = $istart To $iend Step $istep
					If StringInStr($avarray[$i], $vvalue, $icase) > 0 Then Return $i
				Next
			EndIf
		Case 2
			Local $iuboundsub = UBound($avarray, 2) - 1
			If $isubitem < 0 Then $isubitem = 0
			If $isubitem > $iuboundsub Then $isubitem = $iuboundsub
			If NOT $ipartial Then
				If NOT $icase Then
					For $i = $istart To $iend Step $istep
						If $avarray[$i][$isubitem] = $vvalue Then Return $i
					Next
				Else
					For $i = $istart To $iend Step $istep
						If $avarray[$i][$isubitem] == $vvalue Then Return $i
					Next
				EndIf
			Else
				For $i = $istart To $iend Step $istep
					If StringInStr($avarray[$i][$isubitem], $vvalue, $icase) > 0 Then Return $i
				Next
			EndIf
		Case Else
			Return SetError(7, 0, -1)
	EndSwitch
	Return SetError(6, 0, -1)
EndFunc

Func _arraysort(ByRef $avarray, $idescending = 0, $istart = 0, $iend = 0, $isubitem = 0)
	If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
	Local $iubound = UBound($avarray) - 1
	If $iend < 1 OR $iend > $iubound Then $iend = $iubound
	If $istart < 0 Then $istart = 0
	If $istart > $iend Then Return SetError(2, 0, 0)
	Switch UBound($avarray, 0)
		Case 1
			__arrayquicksort1d($avarray, $istart, $iend)
			If $idescending Then _arrayreverse($avarray, $istart, $iend)
		Case 2
			Local $isubmax = UBound($avarray, 2) - 1
			If $isubitem > $isubmax Then Return SetError(3, 0, 0)
			If $idescending Then
				$idescending = -1
			Else
				$idescending = 1
			EndIf
			__arrayquicksort2d($avarray, $idescending, $istart, $iend, $isubitem, $isubmax)
		Case Else
			Return SetError(4, 0, 0)
	EndSwitch
	Return 1
EndFunc

Func __arrayquicksort1d(ByRef $avarray, ByRef $istart, ByRef $iend)
	If $iend <= $istart Then Return 
	Local $vtmp
	If ($iend - $istart) < 15 Then
		Local $i, $j, $vcur
		For $i = $istart + 1 To $iend
			$vtmp = $avarray[$i]
			If IsNumber($vtmp) Then
				For $j = $i - 1 To $istart Step -1
					$vcur = $avarray[$j]
					If ($vtmp >= $vcur AND IsNumber($vcur)) OR (NOT IsNumber($vcur) AND StringCompare($vtmp, $vcur) >= 0) Then ExitLoop
					$avarray[$j + 1] = $vcur
				Next
			Else
				For $j = $i - 1 To $istart Step -1
					If (StringCompare($vtmp, $avarray[$j]) >= 0) Then ExitLoop
					$avarray[$j + 1] = $avarray[$j]
				Next
			EndIf
			$avarray[$j + 1] = $vtmp
		Next
		Return 
	EndIf
	Local $l = $istart, $r = $iend, $vpivot = $avarray[Int(($istart + $iend) / 2)], $fnum = IsNumber($vpivot)
	Do
		If $fnum Then
			While ($avarray[$l] < $vpivot AND IsNumber($avarray[$l])) OR (NOT IsNumber($avarray[$l]) AND StringCompare($avarray[$l], $vpivot) < 0)
				$l += 1
			WEnd
			While ($avarray[$r] > $vpivot AND IsNumber($avarray[$r])) OR (NOT IsNumber($avarray[$r]) AND StringCompare($avarray[$r], $vpivot) > 0)
				$r -= 1
			WEnd
		Else
			While (StringCompare($avarray[$l], $vpivot) < 0)
				$l += 1
			WEnd
			While (StringCompare($avarray[$r], $vpivot) > 0)
				$r -= 1
			WEnd
		EndIf
		If $l <= $r Then
			$vtmp = $avarray[$l]
			$avarray[$l] = $avarray[$r]
			$avarray[$r] = $vtmp
			$l += 1
			$r -= 1
		EndIf
	Until $l > $r
	__arrayquicksort1d($avarray, $istart, $r)
	__arrayquicksort1d($avarray, $l, $iend)
EndFunc

Func __arrayquicksort2d(ByRef $avarray, ByRef $istep, ByRef $istart, ByRef $iend, ByRef $isubitem, ByRef $isubmax)
	If $iend <= $istart Then Return 
	Local $i, $vtmp, $l = $istart, $r = $iend, $vpivot = $avarray[Int(($istart + $iend) / 2)][$isubitem], $fnum = IsNumber($vpivot)
	Do
		If $fnum Then
			While ($istep * ($avarray[$l][$isubitem] - $vpivot) < 0 AND IsNumber($avarray[$l][$isubitem])) OR (NOT IsNumber($avarray[$l][$isubitem]) AND $istep * StringCompare($avarray[$l][$isubitem], $vpivot) < 0)
				$l += 1
			WEnd
			While ($istep * ($avarray[$r][$isubitem] - $vpivot) > 0 AND IsNumber($avarray[$r][$isubitem])) OR (NOT IsNumber($avarray[$r][$isubitem]) AND $istep * StringCompare($avarray[$r][$isubitem], $vpivot) > 0)
				$r -= 1
			WEnd
		Else
			While ($istep * StringCompare($avarray[$l][$isubitem], $vpivot) < 0)
				$l += 1
			WEnd
			While ($istep * StringCompare($avarray[$r][$isubitem], $vpivot) > 0)
				$r -= 1
			WEnd
		EndIf
		If $l <= $r Then
			For $i = 0 To $isubmax
				$vtmp = $avarray[$l][$i]
				$avarray[$l][$i] = $avarray[$r][$i]
				$avarray[$r][$i] = $vtmp
			Next
			$l += 1
			$r -= 1
		EndIf
	Until $l > $r
	__arrayquicksort2d($avarray, $istep, $istart, $r, $isubitem, $isubmax)
	__arrayquicksort2d($avarray, $istep, $l, $iend, $isubitem, $isubmax)
EndFunc

Func _arrayswap(ByRef $vitem1, ByRef $vitem2)
	Local $vtmp = $vitem1
	$vitem1 = $vitem2
	$vitem2 = $vtmp
EndFunc

Func _arraytoclip(Const ByRef $avarray, $istart = 0, $iend = 0)
	Local $sresult = _arraytostring($avarray, @CR, $istart, $iend)
	If @error Then Return SetError(@error, 0, 0)
	Return ClipPut($sresult)
EndFunc

Func _arraytostring(Const ByRef $avarray, $sdelim = "|", $istart = 0, $iend = 0)
	If NOT IsArray($avarray) Then Return SetError(1, 0, "")
	If UBound($avarray, 0) <> 1 Then Return SetError(3, 0, "")
	Local $sresult, $iubound = UBound($avarray) - 1
	If $iend < 1 OR $iend > $iubound Then $iend = $iubound
	If $istart < 0 Then $istart = 0
	If $istart > $iend Then Return SetError(2, 0, "")
	For $i = $istart To $iend
		$sresult &= $avarray[$i] & $sdelim
	Next
	Return StringTrimRight($sresult, StringLen($sdelim))
EndFunc

Func _arraytrim(ByRef $avarray, $itrimnum, $idirection = 0, $istart = 0, $iend = 0)
	If NOT IsArray($avarray) Then Return SetError(1, 0, 0)
	If UBound($avarray, 0) <> 1 Then Return SetError(2, 0, 0)
	Local $iubound = UBound($avarray) - 1
	If $iend < 1 OR $iend > $iubound Then $iend = $iubound
	If $istart < 0 Then $istart = 0
	If $istart > $iend Then Return SetError(5, 0, 0)
	If $idirection Then
		For $i = $istart To $iend
			$avarray[$i] = StringTrimRight($avarray[$i], $itrimnum)
		Next
	Else
		For $i = $istart To $iend
			$avarray[$i] = StringTrimLeft($avarray[$i], $itrimnum)
		Next
	EndIf
	Return 1
EndFunc

Func _arrayunique($aarray, $idimension = 1, $ibase = 0, $icase = 0, $vdelim = "|")
	Local $iubounddim
	If $vdelim = "|" Then $vdelim = Chr(1)
	If NOT IsArray($aarray) Then Return SetError(1, 0, 0)
	If NOT $idimension > 0 Then
		Return SetError(3, 0, 0)
	Else
		$iubounddim = UBound($aarray, 1)
		If @error Then Return SetError(3, 0, 0)
		If $idimension > 1 Then
			Local $aarraytmp[1]
			For $i = 0 To $iubounddim - 1
				_arrayadd($aarraytmp, $aarray[$i][$idimension - 1])
			Next
			_arraydelete($aarraytmp, 0)
		Else
			If UBound($aarray, 0) = 1 Then
				Dim $aarraytmp[1]
				For $i = 0 To $iubounddim - 1
					_arrayadd($aarraytmp, $aarray[$i])
				Next
				_arraydelete($aarraytmp, 0)
			Else
				Dim $aarraytmp[1]
				For $i = 0 To $iubounddim - 1
					_arrayadd($aarraytmp, $aarray[$i][$idimension - 1])
				Next
				_arraydelete($aarraytmp, 0)
			EndIf
		EndIf
	EndIf
	Local $shold
	For $icc = $ibase To UBound($aarraytmp) - 1
		If NOT StringInStr($vdelim & $shold, $vdelim & $aarraytmp[$icc] & $vdelim, $icase) Then $shold &= $aarraytmp[$icc] & $vdelim
	Next
	If $shold Then
		$aarraytmp = StringSplit(StringTrimRight($shold, StringLen($vdelim)), $vdelim, 1)
		Return $aarraytmp
	EndIf
	Return SetError(2, 0, 0)
EndFunc

Func _array_exeterinternal(ByRef $avarray, $istart, $isize, $sdelim, ByRef $aidx, ByRef $aresult, ByRef $icount)
	Local $i, $itemp
	If $istart == $isize - 1 Then
		For $i = 0 To $isize - 1
			$aresult[$icount] &= $avarray[$aidx[$i]] & $sdelim
		Next
		If $sdelim <> "" Then $aresult[$icount] = StringTrimRight($aresult[$icount], 1)
		$icount += 1
	Else
		For $i = $istart To $isize - 1
			$itemp = $aidx[$i]
			$aidx[$i] = $aidx[$istart]
			$aidx[$istart] = $itemp
			_array_exeterinternal($avarray, $istart + 1, $isize, $sdelim, $aidx, $aresult, $icount)
			$aidx[$istart] = $aidx[$i]
			$aidx[$i] = $itemp
		Next
	EndIf
EndFunc

Func _array_combinations($in, $ir)
	Local $i, $infact = 1, $irfact = 1, $inrfact = 1
	For $i = $in To 2 Step -1
		$infact *= $i
	Next
	For $i = $ir To 2 Step -1
		$irfact *= $i
	Next
	For $i = $in - $ir To 2 Step -1
		$inrfact *= $i
	Next
	Return $infact / ($irfact * $inrfact)
EndFunc

Func _array_getnext($in, $ir, ByRef $ileft, $itotal, ByRef $aidx)
	Local $i, $j
	If $ileft == $itotal Then
		$ileft -= 1
		Return 
	EndIf
	$i = $ir - 1
	While $aidx[$i] == $in - $ir + $i
		$i -= 1
	WEnd
	$aidx[$i] += 1
	For $j = $i + 1 To $ir - 1
		$aidx[$j] = $aidx[$i] + $j - $i
	Next
	$ileft -= 1
EndFunc

Global Const $gui_event_close = -3
Global Const $gui_event_minimize = -4
Global Const $gui_event_restore = -5
Global Const $gui_event_maximize = -6
Global Const $gui_event_primarydown = -7
Global Const $gui_event_primaryup = -8
Global Const $gui_event_secondarydown = -9
Global Const $gui_event_secondaryup = -10
Global Const $gui_event_mousemove = -11
Global Const $gui_event_resized = -12
Global Const $gui_event_dropped = -13
Global Const $gui_rundefmsg = "GUI_RUNDEFMSG"
Global Const $gui_avistop = 0
Global Const $gui_avistart = 1
Global Const $gui_aviclose = 2
Global Const $gui_checked = 1
Global Const $gui_indeterminate = 2
Global Const $gui_unchecked = 4
Global Const $gui_dropaccepted = 8
Global Const $gui_nodropaccepted = 4096
Global Const $gui_acceptfiles = $gui_dropaccepted
Global Const $gui_show = 16
Global Const $gui_hide = 32
Global Const $gui_enable = 64
Global Const $gui_disable = 128
Global Const $gui_focus = 256
Global Const $gui_nofocus = 8192
Global Const $gui_defbutton = 512
Global Const $gui_expand = 1024
Global Const $gui_ontop = 2048
Global Const $gui_fontitalic = 2
Global Const $gui_fontunder = 4
Global Const $gui_fontstrike = 8
Global Const $gui_dockauto = 1
Global Const $gui_dockleft = 2
Global Const $gui_dockright = 4
Global Const $gui_dockhcenter = 8
Global Const $gui_docktop = 32
Global Const $gui_dockbottom = 64
Global Const $gui_dockvcenter = 128
Global Const $gui_dockwidth = 256
Global Const $gui_dockheight = 512
Global Const $gui_docksize = 768
Global Const $gui_dockmenubar = 544
Global Const $gui_dockstatebar = 576
Global Const $gui_dockall = 802
Global Const $gui_dockborders = 102
Global Const $gui_gr_close = 1
Global Const $gui_gr_line = 2
Global Const $gui_gr_bezier = 4
Global Const $gui_gr_move = 6
Global Const $gui_gr_color = 8
Global Const $gui_gr_rect = 10
Global Const $gui_gr_ellipse = 12
Global Const $gui_gr_pie = 14
Global Const $gui_gr_dot = 16
Global Const $gui_gr_pixel = 18
Global Const $gui_gr_hint = 20
Global Const $gui_gr_refresh = 22
Global Const $gui_gr_pensize = 24
Global Const $gui_gr_nobkcolor = -2
Global Const $gui_bkcolor_default = -1
Global Const $gui_bkcolor_transparent = -2
Global Const $gui_bkcolor_lv_alternate = -33554432
Global Const $gui_ws_ex_parentdrag = 1048576
Global Const $ws_tiled = 0
Global Const $ws_overlapped = 0
Global Const $ws_maximizebox = 65536
Global Const $ws_minimizebox = 131072
Global Const $ws_tabstop = 65536
Global Const $ws_group = 131072
Global Const $ws_sizebox = 262144
Global Const $ws_thickframe = 262144
Global Const $ws_sysmenu = 524288
Global Const $ws_hscroll = 1048576
Global Const $ws_vscroll = 2097152
Global Const $ws_dlgframe = 4194304
Global Const $ws_border = 8388608
Global Const $ws_caption = 12582912
Global Const $ws_overlappedwindow = 13565952
Global Const $ws_tiledwindow = 13565952
Global Const $ws_maximize = 16777216
Global Const $ws_clipchildren = 33554432
Global Const $ws_clipsiblings = 67108864
Global Const $ws_disabled = 134217728
Global Const $ws_visible = 268435456
Global Const $ws_minimize = 536870912
Global Const $ws_child = 1073741824
Global Const $ws_popup = -2147483648
Global Const $ws_popupwindow = -2138570752
Global Const $ds_modalframe = 128
Global Const $ds_setforeground = 512
Global Const $ds_contexthelp = 8192
Global Const $ws_ex_acceptfiles = 16
Global Const $ws_ex_mdichild = 64
Global Const $ws_ex_appwindow = 262144
Global Const $ws_ex_clientedge = 512
Global Const $ws_ex_contexthelp = 1024
Global Const $ws_ex_dlgmodalframe = 1
Global Const $ws_ex_leftscrollbar = 16384
Global Const $ws_ex_overlappedwindow = 768
Global Const $ws_ex_right = 4096
Global Const $ws_ex_staticedge = 131072
Global Const $ws_ex_toolwindow = 128
Global Const $ws_ex_topmost = 8
Global Const $ws_ex_transparent = 32
Global Const $ws_ex_windowedge = 256
Global Const $ws_ex_layered = 524288
Global Const $ws_ex_controlparent = 65536
Global Const $ws_ex_layoutrtl = 4194304
Global Const $ws_ex_rtlreading = 8192
Global Const $wm_gettextlength = 14
Global Const $wm_gettext = 13
Global Const $wm_size = 5
Global Const $wm_sizing = 532
Global Const $wm_user = 1024
Global Const $wm_create = 1
Global Const $wm_destroy = 2
Global Const $wm_move = 3
Global Const $wm_activate = 6
Global Const $wm_setfocus = 7
Global Const $wm_killfocus = 8
Global Const $wm_enable = 10
Global Const $wm_setredraw = 11
Global Const $wm_settext = 12
Global Const $wm_paint = 15
Global Const $wm_close = 16
Global Const $wm_quit = 18
Global Const $wm_erasebkgnd = 20
Global Const $wm_syscolorchange = 21
Global Const $wm_showwindow = 24
Global Const $wm_wininichange = 26
Global Const $wm_devmodechange = 27
Global Const $wm_activateapp = 28
Global Const $wm_fontchange = 29
Global Const $wm_timechange = 30
Global Const $wm_cancelmode = 31
Global Const $wm_setcursor = 32
Global Const $wm_mouseactivate = 33
Global Const $wm_childactivate = 34
Global Const $wm_queuesync = 35
Global Const $wm_getminmaxinfo = 36
Global Const $wm_painticon = 38
Global Const $wm_iconerasebkgnd = 39
Global Const $wm_nextdlgctl = 40
Global Const $wm_spoolerstatus = 42
Global Const $wm_drawitem = 43
Global Const $wm_measureitem = 44
Global Const $wm_deleteitem = 45
Global Const $wm_vkeytoitem = 46
Global Const $wm_chartoitem = 47
Global Const $wm_setfont = 48
Global Const $wm_getfont = 49
Global Const $wm_sethotkey = 50
Global Const $wm_gethotkey = 51
Global Const $wm_querydragicon = 55
Global Const $wm_compareitem = 57
Global Const $wm_getobject = 61
Global Const $wm_compacting = 65
Global Const $wm_commnotify = 68
Global Const $wm_windowposchanging = 70
Global Const $wm_windowposchanged = 71
Global Const $wm_power = 72
Global Const $wm_notify = 78
Global Const $wm_copydata = 74
Global Const $wm_canceljournal = 75
Global Const $wm_inputlangchangerequest = 80
Global Const $wm_inputlangchange = 81
Global Const $wm_tcard = 82
Global Const $wm_help = 83
Global Const $wm_userchanged = 84
Global Const $wm_notifyformat = 85
Global Const $wm_cut = 768
Global Const $wm_copy = 769
Global Const $wm_paste = 770
Global Const $wm_clear = 771
Global Const $wm_undo = 772
Global Const $wm_contextmenu = 123
Global Const $wm_stylechanging = 124
Global Const $wm_stylechanged = 125
Global Const $wm_displaychange = 126
Global Const $wm_geticon = 127
Global Const $wm_seticon = 128
Global Const $wm_nccreate = 129
Global Const $wm_ncdestroy = 130
Global Const $wm_nccalcsize = 131
Global Const $wm_nchittest = 132
Global Const $wm_ncpaint = 133
Global Const $wm_ncactivate = 134
Global Const $wm_getdlgcode = 135
Global Const $wm_syncpaint = 136
Global Const $wm_ncmousemove = 160
Global Const $wm_nclbuttondown = 161
Global Const $wm_nclbuttonup = 162
Global Const $wm_nclbuttondblclk = 163
Global Const $wm_ncrbuttondown = 164
Global Const $wm_ncrbuttonup = 165
Global Const $wm_ncrbuttondblclk = 166
Global Const $wm_ncmbuttondown = 167
Global Const $wm_ncmbuttonup = 168
Global Const $wm_ncmbuttondblclk = 169
Global Const $wm_keydown = 256
Global Const $wm_keyup = 257
Global Const $wm_char = 258
Global Const $wm_deadchar = 259
Global Const $wm_syskeydown = 260
Global Const $wm_syskeyup = 261
Global Const $wm_syschar = 262
Global Const $wm_sysdeadchar = 263
Global Const $wm_initdialog = 272
Global Const $wm_command = 273
Global Const $wm_syscommand = 274
Global Const $wm_timer = 275
Global Const $wm_hscroll = 276
Global Const $wm_vscroll = 277
Global Const $wm_initmenu = 278
Global Const $wm_initmenupopup = 279
Global Const $wm_menuselect = 287
Global Const $wm_menuchar = 288
Global Const $wm_enteridle = 289
Global Const $wm_menurbuttonup = 290
Global Const $wm_menudrag = 291
Global Const $wm_menugetobject = 292
Global Const $wm_uninitmenupopup = 293
Global Const $wm_menucommand = 294
Global Const $wm_changeuistate = 295
Global Const $wm_updateuistate = 296
Global Const $wm_queryuistate = 297
Global Const $wm_ctlcolormsgbox = 306
Global Const $wm_ctlcoloredit = 307
Global Const $wm_ctlcolorlistbox = 308
Global Const $wm_ctlcolorbtn = 309
Global Const $wm_ctlcolordlg = 310
Global Const $wm_ctlcolorscrollbar = 311
Global Const $wm_ctlcolorstatic = 312
Global Const $wm_ctlcolor = 25
Global Const $mn_gethmenu = 481
Global Const $nm_first = 0
Global Const $nm_outofmemory = $nm_first - 1
Global Const $nm_click = $nm_first - 2
Global Const $nm_dblclk = $nm_first - 3
Global Const $nm_return = $nm_first - 4
Global Const $nm_rclick = $nm_first - 5
Global Const $nm_rdblclk = $nm_first - 6
Global Const $nm_setfocus = $nm_first - 7
Global Const $nm_killfocus = $nm_first - 8
Global Const $nm_customdraw = $nm_first - 12
Global Const $nm_hover = $nm_first - 13
Global Const $nm_nchittest = $nm_first - 14
Global Const $nm_keydown = $nm_first - 15
Global Const $nm_releasedcapture = $nm_first - 16
Global Const $nm_setcursor = $nm_first - 17
Global Const $nm_char = $nm_first - 18
Global Const $nm_tooltipscreated = $nm_first - 19
Global Const $nm_ldown = $nm_first - 20
Global Const $nm_rdown = $nm_first - 21
Global Const $nm_themechanged = $nm_first - 22
Global Const $wm_lbuttonup = 514
Global Const $wm_mousemove = 512
Global Const $ps_solid = 0
Global Const $ps_dash = 1
Global Const $ps_dot = 2
Global Const $ps_dashdot = 3
Global Const $ps_dashdotdot = 4
Global Const $ps_null = 5
Global Const $ps_insideframe = 6
Global Const $rgn_and = 1
Global Const $rgn_or = 2
Global Const $rgn_xor = 3
Global Const $rgn_diff = 4
Global Const $rgn_copy = 5
Global Const $error = 0
Global Const $nullregion = 1
Global Const $simpleregion = 2
Global Const $complexregion = 3
Global Const $transparent = 1
Global Const $opaque = 2
Global Const $ccm_first = 8192
Global Const $ccm_getunicodeformat = ($ccm_first + 6)
Global Const $ccm_setunicodeformat = ($ccm_first + 5)
Global Const $ccm_setbkcolor = $ccm_first + 1
Global Const $ccm_setcolorscheme = $ccm_first + 2
Global Const $ccm_getcolorscheme = $ccm_first + 3
Global Const $ccm_getdroptarget = $ccm_first + 4
Global Const $ccm_setwindowtheme = $ccm_first + 11
Global Const $ga_parent = 1
Global Const $ga_root = 2
Global Const $ga_rootowner = 3
Global Const $sm_cxscreen = 0
Global Const $sm_cyscreen = 1
Global Const $sm_cxvscroll = 2
Global Const $sm_cyhscroll = 3
Global Const $sm_cycaption = 4
Global Const $sm_cxborder = 5
Global Const $sm_cyborder = 6
Global Const $sm_cxdlgframe = 7
Global Const $sm_cydlgframe = 8
Global Const $sm_cyvthumb = 9
Global Const $sm_cxhthumb = 10
Global Const $sm_cxicon = 11
Global Const $sm_cyicon = 12
Global Const $sm_cxcursor = 13
Global Const $sm_cycursor = 14
Global Const $sm_cymenu = 15
Global Const $sm_cxfullscreen = 16
Global Const $sm_cyfullscreen = 17
Global Const $sm_cykanjiwindow = 18
Global Const $sm_mousepresent = 19
Global Const $sm_cyvscroll = 20
Global Const $sm_cxhscroll = 21
Global Const $sm_debug = 22
Global Const $sm_swapbutton = 23
Global Const $sm_reserved1 = 24
Global Const $sm_reserved2 = 25
Global Const $sm_reserved3 = 26
Global Const $sm_reserved4 = 27
Global Const $sm_cxmin = 28
Global Const $sm_cymin = 29
Global Const $sm_cxsize = 30
Global Const $sm_cysize = 31
Global Const $sm_cxframe = 32
Global Const $sm_cyframe = 33
Global Const $sm_cxmintrack = 34
Global Const $sm_cymintrack = 35
Global Const $sm_cxdoubleclk = 36
Global Const $sm_cydoubleclk = 37
Global Const $sm_cxiconspacing = 38
Global Const $sm_cyiconspacing = 39
Global Const $sm_menudropalignment = 40
Global Const $sm_penwindows = 41
Global Const $sm_dbcsenabled = 42
Global Const $sm_cmousebuttons = 43
Global Const $sm_secure = 44
Global Const $sm_cxedge = 45
Global Const $sm_cyedge = 46
Global Const $sm_cxminspacing = 47
Global Const $sm_cyminspacing = 48
Global Const $sm_cxsmicon = 49
Global Const $sm_cysmicon = 50
Global Const $sm_cysmcaption = 51
Global Const $sm_cxsmsize = 52
Global Const $sm_cysmsize = 53
Global Const $sm_cxmenusize = 54
Global Const $sm_cymenusize = 55
Global Const $sm_arrange = 56
Global Const $sm_cxminimized = 57
Global Const $sm_cyminimized = 58
Global Const $sm_cxmaxtrack = 59
Global Const $sm_cymaxtrack = 60
Global Const $sm_cxmaximized = 61
Global Const $sm_cymaximized = 62
Global Const $sm_network = 63
Global Const $sm_cleanboot = 67
Global Const $sm_cxdrag = 68
Global Const $sm_cydrag = 69
Global Const $sm_showsounds = 70
Global Const $sm_cxmenucheck = 71
Global Const $sm_cymenucheck = 72
Global Const $sm_slowmachine = 73
Global Const $sm_mideastenabled = 74
Global Const $sm_mousewheelpresent = 75
Global Const $sm_xvirtualscreen = 76
Global Const $sm_yvirtualscreen = 77
Global Const $sm_cxvirtualscreen = 78
Global Const $sm_cyvirtualscreen = 79
Global Const $sm_cmonitors = 80
Global Const $sm_samedisplayformat = 81
Global Const $sm_immenabled = 82
Global Const $sm_cxfocusborder = 83
Global Const $sm_cyfocusborder = 84
Global Const $sm_tabletpc = 86
Global Const $sm_mediacenter = 87
Global Const $sm_starter = 88
Global Const $sm_serverr2 = 89
Global Const $sm_cmetrics = 90
Global Const $sm_remotesession = 4096
Global Const $sm_shuttingdown = 8192
Global Const $sm_remotecontrol = 8193
Global Const $sm_caretblinkingenabled = 8194
Global Const $blackness = 66
Global Const $captureblt = 1073741824
Global Const $dstinvert = 5570569
Global Const $mergecopy = 12583114
Global Const $mergepaint = 12255782
Global Const $nomirrorbitmap = -2147483648
Global Const $notsrccopy = 3342344
Global Const $notsrcerase = 1114278
Global Const $patcopy = 15728673
Global Const $patinvert = 5898313
Global Const $patpaint = 16452105
Global Const $srcand = 8913094
Global Const $srccopy = 13369376
Global Const $srcerase = 4457256
Global Const $srcinvert = 6684742
Global Const $srcpaint = 15597702
Global Const $whiteness = 16711778
Global Const $dt_bottom = 8
Global Const $dt_calcrect = 1024
Global Const $dt_center = 1
Global Const $dt_editcontrol = 8192
Global Const $dt_end_ellipsis = 32768
Global Const $dt_expandtabs = 64
Global Const $dt_externalleading = 512
Global Const $dt_hideprefix = 1048576
Global Const $dt_internal = 4096
Global Const $dt_left = 0
Global Const $dt_modifystring = 65536
Global Const $dt_noclip = 256
Global Const $dt_nofullwidthcharbreak = 524288
Global Const $dt_noprefix = 2048
Global Const $dt_path_ellipsis = 16384
Global Const $dt_prefixonly = 2097152
Global Const $dt_right = 2
Global Const $dt_rtlreading = 131072
Global Const $dt_singleline = 32
Global Const $dt_tabstop = 128
Global Const $dt_top = 0
Global Const $dt_vcenter = 4
Global Const $dt_wordbreak = 16
Global Const $dt_word_ellipsis = 262144
Global Const $rdw_erase = 4
Global Const $rdw_frame = 1024
Global Const $rdw_internalpaint = 2
Global Const $rdw_invalidate = 1
Global Const $rdw_noerase = 32
Global Const $rdw_noframe = 2048
Global Const $rdw_nointernalpaint = 16
Global Const $rdw_validate = 8
Global Const $rdw_erasenow = 512
Global Const $rdw_updatenow = 256
Global Const $rdw_allchildren = 128
Global Const $rdw_nochildren = 64
Global Const $wm_renderformat = 773
Global Const $wm_renderallformats = 774
Global Const $wm_destroyclipboard = 775
Global Const $wm_drawclipboard = 776
Global Const $wm_paintclipboard = 777
Global Const $wm_vscrollclipboard = 778
Global Const $wm_sizeclipboard = 779
Global Const $wm_askcbformatname = 780
Global Const $wm_changecbchain = 781
Global Const $wm_hscrollclipboard = 782
Global Const $hterror = -2
Global Const $httransparent = -1
Global Const $htnowhere = 0
Global Const $htclient = 1
Global Const $htcaption = 2
Global Const $htsysmenu = 3
Global Const $htgrowbox = 4
Global Const $htsize = $htgrowbox
Global Const $htmenu = 5
Global Const $hthscroll = 6
Global Const $htvscroll = 7
Global Const $htminbutton = 8
Global Const $htmaxbutton = 9
Global Const $htleft = 10
Global Const $htright = 11
Global Const $httop = 12
Global Const $httopleft = 13
Global Const $httopright = 14
Global Const $htbottom = 15
Global Const $htbottomleft = 16
Global Const $htbottomright = 17
Global Const $htborder = 18
Global Const $htreduce = $htminbutton
Global Const $htzoom = $htmaxbutton
Global Const $htsizefirst = $htleft
Global Const $htsizelast = $htbottomright
Global Const $htobject = 19
Global Const $htclose = 20
Global Const $hthelp = 21
Global Const $color_scrollbar = 0
Global Const $color_background = 1
Global Const $color_activecaption = 2
Global Const $color_inactivecaption = 3
Global Const $color_menu = 4
Global Const $color_window = 5
Global Const $color_windowframe = 6
Global Const $color_menutext = 7
Global Const $color_windowtext = 8
Global Const $color_captiontext = 9
Global Const $color_activeborder = 10
Global Const $color_inactiveborder = 11
Global Const $color_appworkspace = 12
Global Const $color_highlight = 13
Global Const $color_highlighttext = 14
Global Const $color_btnface = 15
Global Const $color_btnshadow = 16
Global Const $color_graytext = 17
Global Const $color_btntext = 18
Global Const $color_inactivecaptiontext = 19
Global Const $color_btnhighlight = 20
Global Const $color_3ddkshadow = 21
Global Const $color_3dlight = 22
Global Const $color_infotext = 23
Global Const $color_infobk = 24
Global Const $color_hotlight = 26
Global Const $color_gradientactivecaption = 27
Global Const $color_gradientinactivecaption = 28
Global Const $color_menuhilight = 29
Global Const $color_menubar = 30
Global Const $color_desktop = 1
Global Const $color_3dface = 15
Global Const $color_3dshadow = 16
Global Const $color_3dhighlight = 20
Global Const $color_3dhilight = 20
Global Const $color_btnhilight = 20
Global Const $hinst_commctrl = -1
Global Const $idb_std_small_color = 0
Global Const $idb_std_large_color = 1
Global Const $idb_view_small_color = 4
Global Const $idb_view_large_color = 5
Global Const $idb_hist_small_color = 8
Global Const $idb_hist_large_color = 9
Global Const $startf_forceofffeedback = 128
Global Const $startf_forceonfeedback = 64
Global Const $startf_runfullscreen = 32
Global Const $startf_usecountchars = 8
Global Const $startf_usefillattribute = 16
Global Const $startf_usehotkey = 512
Global Const $startf_useposition = 4
Global Const $startf_useshowwindow = 1
Global Const $startf_usesize = 2
Global Const $startf_usestdhandles = 256
Global Const $cdds_prepaint = 1
Global Const $cdds_postpaint = 2
Global Const $cdds_preerase = 3
Global Const $cdds_posterase = 4
Global Const $cdds_item = 65536
Global Const $cdds_itemprepaint = 65537
Global Const $cdds_itempostpaint = 65538
Global Const $cdds_itempreerase = 65539
Global Const $cdds_itemposterase = 65540
Global Const $cdds_subitem = 131072
Global Const $cdis_selected = 1
Global Const $cdis_grayed = 2
Global Const $cdis_disabled = 4
Global Const $cdis_checked = 8
Global Const $cdis_focus = 16
Global Const $cdis_default = 32
Global Const $cdis_hot = 64
Global Const $cdis_marked = 128
Global Const $cdis_indeterminate = 256
Global Const $cdis_showkeyboardcues = 512
Global Const $cdis_nearhot = 1024
Global Const $cdis_othersidehot = 2048
Global Const $cdis_drophilited = 4096
Global Const $cdrf_dodefault = 0
Global Const $cdrf_newfont = 2
Global Const $cdrf_skipdefault = 4
Global Const $cdrf_notifypostpaint = 16
Global Const $cdrf_notifyitemdraw = 32
Global Const $cdrf_notifysubitemdraw = 32
Global Const $cdrf_notifyposterase = 64
Global Const $cdrf_doerase = 8
Global Const $cdrf_skippostpaint = 256
Global Const $gui_ss_default_gui = BitOR($ws_minimizebox, $ws_caption, $ws_popup, $ws_sysmenu)
Global Const $es_left = 0
Global Const $es_center = 1
Global Const $es_right = 2
Global Const $es_multiline = 4
Global Const $es_uppercase = 8
Global Const $es_lowercase = 16
Global Const $es_password = 32
Global Const $es_autovscroll = 64
Global Const $es_autohscroll = 128
Global Const $es_nohidesel = 256
Global Const $es_oemconvert = 1024
Global Const $es_readonly = 2048
Global Const $es_wantreturn = 4096
Global Const $es_number = 8192
Global Const $ec_err = -1
Global Const $ecm_first = 5376
Global Const $em_canundo = 198
Global Const $em_charfrompos = 215
Global Const $em_emptyundobuffer = 205
Global Const $em_fmtlines = 200
Global Const $em_getcuebanner = ($ecm_first + 2)
Global Const $em_getfirstvisibleline = 206
Global Const $em_gethandle = 189
Global Const $em_getimestatus = 217
Global Const $em_getlimittext = 213
Global Const $em_getline = 196
Global Const $em_getlinecount = 186
Global Const $em_getmargins = 212
Global Const $em_getmodify = 184
Global Const $em_getpasswordchar = 210
Global Const $em_getrect = 178
Global Const $em_getsel = 176
Global Const $em_getthumb = 190
Global Const $em_getwordbreakproc = 209
Global Const $em_hideballoontip = ($ecm_first + 4)
Global Const $em_limittext = 197
Global Const $em_linefromchar = 201
Global Const $em_lineindex = 187
Global Const $em_linelength = 193
Global Const $em_linescroll = 182
Global Const $em_posfromchar = 214
Global Const $em_replacesel = 194
Global Const $em_scroll = 181
Global Const $em_scrollcaret = 183
Global Const $em_setcuebanner = ($ecm_first + 1)
Global Const $em_sethandle = 188
Global Const $em_setimestatus = 216
Global Const $em_setlimittext = $em_limittext
Global Const $em_setmargins = 211
Global Const $em_setmodify = 185
Global Const $em_setpasswordchar = 204
Global Const $em_setreadonly = 207
Global Const $em_setrect = 179
Global Const $em_setrectnp = 180
Global Const $em_setsel = 177
Global Const $em_settabstops = 203
Global Const $em_setwordbreakproc = 208
Global Const $em_showballoontip = ($ecm_first + 3)
Global Const $em_undo = 199
Global Const $ec_leftmargin = 1
Global Const $ec_rightmargin = 2
Global Const $ec_usefontinfo = 65535
Global Const $emsis_compositionstring = 1
Global Const $eimes_getcompstratonce = 1
Global Const $eimes_cancelcompstrinfocus = 2
Global Const $eimes_completecompstrkillfocus = 4
Global Const $en_align_ltr_ec = 1792
Global Const $en_align_rtl_ec = 1793
Global Const $en_change = 768
Global Const $en_errspace = 1280
Global Const $en_hscroll = 1537
Global Const $en_killfocus = 512
Global Const $en_maxtext = 1281
Global Const $en_setfocus = 256
Global Const $en_update = 1024
Global Const $en_vscroll = 1538
Global Const $tti_none = 0
Global Const $tti_info = 1
Global Const $tti_warning = 2
Global Const $tti_error = 3
Global Const $tti_info_large = 4
Global Const $tti_warning_large = 5
Global Const $tti_error_large = 6
Global Const $__editconstant_ws_vscroll = 2097152
Global Const $__editconstant_ws_hscroll = 1048576
Global Const $gui_ss_default_edit = BitOR($es_wantreturn, $__editconstant_ws_vscroll, $__editconstant_ws_hscroll, $es_autovscroll, $es_autohscroll)
Global Const $gui_ss_default_input = BitOR($es_left, $es_autohscroll)
Global Const $ss_left = 0
Global Const $ss_center = 1
Global Const $ss_right = 2
Global Const $ss_icon = 3
Global Const $ss_blackrect = 4
Global Const $ss_grayrect = 5
Global Const $ss_whiterect = 6
Global Const $ss_blackframe = 7
Global Const $ss_grayframe = 8
Global Const $ss_whiteframe = 9
Global Const $ss_simple = 11
Global Const $ss_leftnowordwrap = 12
Global Const $ss_bitmap = 15
Global Const $ss_etchedhorz = 16
Global Const $ss_etchedvert = 17
Global Const $ss_etchedframe = 18
Global Const $ss_noprefix = 128
Global Const $ss_notify = 256
Global Const $ss_centerimage = 512
Global Const $ss_rightjust = 1024
Global Const $ss_sunken = 4096
Global Const $gui_ss_default_label = 0
Global Const $gui_ss_default_graphic = 0
Global Const $gui_ss_default_icon = $ss_notify
Global Const $gui_ss_default_pic = $ss_notify
Global Const $cb_err = -1
Global Const $cb_errattribute = -3
Global Const $cb_errrequired = -4
Global Const $cb_errspace = -2
Global Const $cb_okay = 0
Global Const $state_system_invisible = 32768
Global Const $state_system_pressed = 8
Global Const $cb_ddl_archive = 32
Global Const $cb_ddl_directory = 16
Global Const $cb_ddl_drives = 16384
Global Const $cb_ddl_exclusive = 32768
Global Const $cb_ddl_hidden = 2
Global Const $cb_ddl_readonly = 1
Global Const $cb_ddl_readwrite = 0
Global Const $cb_ddl_system = 4
Global Const $cbs_autohscroll = 64
Global Const $cbs_disablenoscroll = 2048
Global Const $cbs_dropdown = 2
Global Const $cbs_dropdownlist = 3
Global Const $cbs_hasstrings = 512
Global Const $cbs_lowercase = 16384
Global Const $cbs_nointegralheight = 1024
Global Const $cbs_oemconvert = 128
Global Const $cbs_ownerdrawfixed = 16
Global Const $cbs_ownerdrawvariable = 32
Global Const $cbs_simple = 1
Global Const $cbs_sort = 256
Global Const $cbs_uppercase = 8192
Global Const $cbm_first = 5888
Global Const $cb_addstring = 323
Global Const $cb_deletestring = 324
Global Const $cb_dir = 325
Global Const $cb_findstring = 332
Global Const $cb_findstringexact = 344
Global Const $cb_getcomboboxinfo = 356
Global Const $cb_getcount = 326
Global Const $cb_getcuebanner = ($cbm_first + 4)
Global Const $cb_getcursel = 327
Global Const $cb_getdroppedcontrolrect = 338
Global Const $cb_getdroppedstate = 343
Global Const $cb_getdroppedwidth = 351
Global Const $cb_geteditsel = 320
Global Const $cb_getextendedui = 342
Global Const $cb_gethorizontalextent = 349
Global Const $cb_getitemdata = 336
Global Const $cb_getitemheight = 340
Global Const $cb_getlbtext = 328
Global Const $cb_getlbtextlen = 329
Global Const $cb_getlocale = 346
Global Const $cb_getminvisible = 5890
Global Const $cb_gettopindex = 347
Global Const $cb_initstorage = 353
Global Const $cb_limittext = 321
Global Const $cb_resetcontent = 331
Global Const $cb_insertstring = 330
Global Const $cb_selectstring = 333
Global Const $cb_setcuebanner = ($cbm_first + 3)
Global Const $cb_setcursel = 334
Global Const $cb_setdroppedwidth = 352
Global Const $cb_seteditsel = 322
Global Const $cb_setextendedui = 341
Global Const $cb_sethorizontalextent = 350
Global Const $cb_setitemdata = 337
Global Const $cb_setitemheight = 339
Global Const $cb_setlocale = 21
Global Const $cb_setminvisible = 5889
Global Const $cb_settopindex = 348
Global Const $cb_showdropdown = 335
Global Const $cbn_closeup = 8
Global Const $cbn_dblclk = 2
Global Const $cbn_dropdown = 7
Global Const $cbn_editchange = 5
Global Const $cbn_editupdate = 6
Global Const $cbn_errspace = (-1)
Global Const $cbn_killfocus = 4
Global Const $cbn_selchange = 1
Global Const $cbn_selendcancel = 10
Global Const $cbn_selendok = 9
Global Const $cbn_setfocus = 3
Global Const $cbes_ex_casesensitive = 16
Global Const $cbes_ex_noeditimage = 1
Global Const $cbes_ex_noeditimageindent = 2
Global Const $cbes_ex_nosizelimit = 8
Global Const $cbes_ex_pathwordbreakproc = 4
Global Const $__comboboxconstant_wm_user = 1024
Global Const $cbem_deleteitem = $cb_deletestring
Global Const $cbem_getcombocontrol = ($__comboboxconstant_wm_user + 6)
Global Const $cbem_geteditcontrol = ($__comboboxconstant_wm_user + 7)
Global Const $cbem_getexstyle = ($__comboboxconstant_wm_user + 9)
Global Const $cbem_getextendedstyle = ($__comboboxconstant_wm_user + 9)
Global Const $cbem_getimagelist = ($__comboboxconstant_wm_user + 3)
Global Const $cbem_getitema = ($__comboboxconstant_wm_user + 4)
Global Const $cbem_getitemw = ($__comboboxconstant_wm_user + 13)
Global Const $cbem_getunicodeformat = 8192 + 6
Global Const $cbem_haseditchanged = ($__comboboxconstant_wm_user + 10)
Global Const $cbem_insertitema = ($__comboboxconstant_wm_user + 1)
Global Const $cbem_insertitemw = ($__comboboxconstant_wm_user + 11)
Global Const $cbem_setexstyle = ($__comboboxconstant_wm_user + 8)
Global Const $cbem_setextendedstyle = ($__comboboxconstant_wm_user + 14)
Global Const $cbem_setimagelist = ($__comboboxconstant_wm_user + 2)
Global Const $cbem_setitema = ($__comboboxconstant_wm_user + 5)
Global Const $cbem_setitemw = ($__comboboxconstant_wm_user + 12)
Global Const $cbem_setunicodeformat = 8192 + 5
Global Const $cbem_setwindowtheme = 8192 + 11
Global Const $cben_first = (-800)
Global Const $cben_last = (-830)
Global Const $cben_beginedit = ($cben_first - 4)
Global Const $cben_deleteitem = ($cben_first - 2)
Global Const $cben_dragbegina = ($cben_first - 8)
Global Const $cben_dragbeginw = ($cben_first - 9)
Global Const $cben_endedita = ($cben_first - 5)
Global Const $cben_endeditw = ($cben_first - 6)
Global Const $cben_getdispinfo = ($cben_first - 0)
Global Const $cben_getdispinfoa = ($cben_first - 0)
Global Const $cben_getdispinfow = ($cben_first - 7)
Global Const $cben_insertitem = ($cben_first - 1)
Global Const $cbeif_di_setitem = 268435456
Global Const $cbeif_image = 2
Global Const $cbeif_indent = 16
Global Const $cbeif_lparam = 32
Global Const $cbeif_overlay = 8
Global Const $cbeif_selectedimage = 4
Global Const $cbeif_text = 1
Global Const $__comboboxconstant_ws_vscroll = 2097152
Global Const $gui_ss_default_combo = BitOR($cbs_dropdown, $cbs_autohscroll, $__comboboxconstant_ws_vscroll)
Global Const $error_no_token = 1008
Global Const $se_assignprimarytoken_name = "SeAssignPrimaryTokenPrivilege"
Global Const $se_audit_name = "SeAuditPrivilege"
Global Const $se_backup_name = "SeBackupPrivilege"
Global Const $se_change_notify_name = "SeChangeNotifyPrivilege"
Global Const $se_create_global_name = "SeCreateGlobalPrivilege"
Global Const $se_create_pagefile_name = "SeCreatePagefilePrivilege"
Global Const $se_create_permanent_name = "SeCreatePermanentPrivilege"
Global Const $se_create_token_name = "SeCreateTokenPrivilege"
Global Const $se_debug_name = "SeDebugPrivilege"
Global Const $se_enable_delegation_name = "SeEnableDelegationPrivilege"
Global Const $se_impersonate_name = "SeImpersonatePrivilege"
Global Const $se_inc_base_priority_name = "SeIncreaseBasePriorityPrivilege"
Global Const $se_increase_quota_name = "SeIncreaseQuotaPrivilege"
Global Const $se_load_driver_name = "SeLoadDriverPrivilege"
Global Const $se_lock_memory_name = "SeLockMemoryPrivilege"
Global Const $se_machine_account_name = "SeMachineAccountPrivilege"
Global Const $se_manage_volume_name = "SeManageVolumePrivilege"
Global Const $se_prof_single_process_name = "SeProfileSingleProcessPrivilege"
Global Const $se_remote_shutdown_name = "SeRemoteShutdownPrivilege"
Global Const $se_restore_name = "SeRestorePrivilege"
Global Const $se_security_name = "SeSecurityPrivilege"
Global Const $se_shutdown_name = "SeShutdownPrivilege"
Global Const $se_sync_agent_name = "SeSyncAgentPrivilege"
Global Const $se_system_environment_name = "SeSystemEnvironmentPrivilege"
Global Const $se_system_profile_name = "SeSystemProfilePrivilege"
Global Const $se_systemtime_name = "SeSystemtimePrivilege"
Global Const $se_take_ownership_name = "SeTakeOwnershipPrivilege"
Global Const $se_tcb_name = "SeTcbPrivilege"
Global Const $se_unsolicited_input_name = "SeUnsolicitedInputPrivilege"
Global Const $se_undock_name = "SeUndockPrivilege"
Global Const $se_privilege_enabled_by_default = 1
Global Const $se_privilege_enabled = 2
Global Const $se_privilege_removed = 4
Global Const $se_privilege_used_for_access = -2147483648
Global Const $tokenuser = 1
Global Const $tokengroups = 2
Global Const $tokenprivileges = 3
Global Const $tokenowner = 4
Global Const $tokenprimarygroup = 5
Global Const $tokendefaultdacl = 6
Global Const $tokensource = 7
Global Const $tokentype = 8
Global Const $tokenimpersonationlevel = 9
Global Const $tokenstatistics = 10
Global Const $tokenrestrictedsids = 11
Global Const $tokensessionid = 12
Global Const $tokengroupsandprivileges = 13
Global Const $tokensessionreference = 14
Global Const $tokensandboxinert = 15
Global Const $tokenauditpolicy = 16
Global Const $tokenorigin = 17
Global Const $tokenelevationtype = 18
Global Const $tokenlinkedtoken = 19
Global Const $tokenelevation = 20
Global Const $tokenhasrestrictions = 21
Global Const $tokenaccessinformation = 22
Global Const $tokenvirtualizationallowed = 23
Global Const $tokenvirtualizationenabled = 24
Global Const $tokenintegritylevel = 25
Global Const $tokenuiaccess = 26
Global Const $tokenmandatorypolicy = 27
Global Const $tokenlogonsid = 28
Global Const $tagnmhdr = "hwnd hWndFrom;int IDFrom;int Code"
Global Const $tagcomboboxinfo = "dword Size;int EditLeft;int EditTop;int EditRight;int EditBottom;int BtnLeft;int BtnTop;" & "int BtnRight;int BtnBottom;dword BtnState;hwnd hCombo;hwnd hEdit;hwnd hList"
Global Const $tagcomboboxexitem = "int Mask;int Item;ptr Text;int TextMax;int Image;int SelectedImage;int OverlayImage;" & "int Indent;int Param"
Global Const $tagnmcbedragbegin = $tagnmhdr & ";int ItemID;char Text[1024]"
Global Const $tagnmcbeendedit = $tagnmhdr & ";int fChanged;int NewSelection;char Text[1024];int Why"
Global Const $tagnmcomboboxex = $tagnmhdr & ";int Mask;int Item;ptr Text;int TextMax;int Image;" & "int SelectedImage;int OverlayImage;int Indent;int Param"
Global Const $tagdtprange = "short MinYear;short MinMonth;short MinDOW;short MinDay;short MinHour;short MinMinute;" & "short MinSecond;short MinMSecond;short MaxYear;short MaxMonth;short MaxDOW;short MaxDay;short MaxHour;" & "short MaxMinute;short MaxSecond;short MaxMSecond;int MinValid;int MaxValid"
Global Const $tagdtptime = "short Year;short Month;short DOW;short Day;short Hour;short Minute;short Second;short MSecond"
Global Const $tagnmdatetimechange = $tagnmhdr & ";int Flag;short Year;short Month;short DOW;short Day;" & "short Hour;short Minute;short Second;short MSecond"
Global Const $tagnmdatetimeformat = $tagnmhdr & ";ptr Format;short Year;short Month;short DOW;short Day;" & "short Hour;short Minute;short Second;short MSecond;ptr pDisplay;char Display[64]"
Global Const $tagnmdatetimeformatquery = $tagnmhdr & ";ptr Format;int SizeX;int SizeY"
Global Const $tagnmdatetimekeydown = $tagnmhdr & ";int VirtKey;ptr Format;short Year;short Month;short DOW;" & "short Day;short Hour;short Minute;short Second;short MSecond"
Global Const $tagnmdatetimestring = $tagnmhdr & ";ptr UserString;short Year;short Month;short DOW;short Day;" & "short Hour;short Minute;short Second;short MSecond;int Flags"
Global Const $tageditballoontip = "dword Size;ptr Title;ptr Text;int Icon"
Global Const $tageventlogrecord = "int Length;int Reserved;int RecordNumber;int TimeGenerated;int TimeWritten;int EventID;" & "short EventType;short NumStrings;short EventCategory;short ReservedFlags;int ClosingRecordNumber;int StringOffset;" & "int UserSidLength;int UserSidOffset;int DataLength;int DataOffset"
Global Const $tageventread = "byte Buffer[4096];int BytesRead;int BytesMin"
Global Const $taggdipbitmapdata = "uint Width;uint Height;int Stride;uint Format;ptr Scan0;ptr Reserved"
Global Const $taggdipencoderparam = "byte GUID[16];dword Count;dword Type;ptr Values"
Global Const $taggdipencoderparams = "dword Count;byte Params[0]"
Global Const $taggdiprectf = "float X;float Y;float Width;float Height"
Global Const $taggdipstartupinput = "int Version;ptr Callback;int NoThread;int NoCodecs"
Global Const $taggdipstartupoutput = "ptr HookProc;ptr UnhookProc"
Global Const $taggdipimagecodecinfo = "byte CLSID[16];byte FormatID[16];ptr CodecName;ptr DllName;ptr FormatDesc;ptr FileExt;" & "ptr MimeType;dword Flags;dword Version;dword SigCount;dword SigSize;ptr SigPattern;ptr SigMask"
Global Const $taggdippencoderparams = "dword Count;byte Params[0]"
Global Const $taghdhittestinfo = "int X;int Y;int Flags;int Item"
Global Const $taghditem = "int Mask;int XY;ptr Text;hwnd hBMP;int TextMax;int Fmt;int Param;int Image;int Order;int Type;ptr pFilter;int State"
Global Const $taghdlayout = "ptr Rect;ptr WindowPos"
Global Const $taghdtextfilter = "ptr Text;int TextMax"
Global Const $tagnmhddispinfo = "hwnd WndFrom;int IDFrom;int Code;int Item;int Mask;ptr Text;int TextMax;int Image;int lParam"
Global Const $tagnmhdfilterbtnclick = $tagnmhdr & ";int Item;int Left;int Top;int Right;int Bottom"
Global Const $tagnmheader = $tagnmhdr & ";int Item;int Button;ptr pItem"
Global Const $taggetipaddress = "ubyte Field4;ubyte Field3;ubyte Field2;ubyte Field1"
Global Const $tagnmipaddress = $tagnmhdr & ";int Field;int Value"
Global Const $taglvbkimage = "int Flags;hwnd hBmp;int Image;int ImageMax;int XOffPercent;int YOffPercent"
Global Const $taglvcolumn = "int Mask;int Fmt;int CX;ptr Text;int TextMax;int SubItem;int Image;int Order"
Global Const $taglvfindinfo = "int Flags;ptr Text;int Param;int X;int Y;int Direction"
Global Const $taglvgroup = "int Size;int Mask;ptr Header;int HeaderMax;ptr Footer;int FooterMax;int GroupID;int StateMask;int State;int Align"
Global Const $taglvhittestinfo = "int X;int Y;int Flags;int Item;int SubItem"
Global Const $taglvinsertmark = "uint Size;dword Flags;int Item;dword Reserved"
Global Const $taglvitem = "int Mask;int Item;int SubItem;int State;int StateMask;ptr Text;int TextMax;int Image;int Param;" & "int Indent;int GroupID;int Columns;ptr pColumns"
Global Const $tagnmlistview = $tagnmhdr & ";int Item;int SubItem;int NewState;int OldState;int Changed;" & "int ActionX;int ActionY;int Param"
Global Const $tagnmlvcustomdraw = $tagnmhdr & ";dword dwDrawStage;hwnd hdc;int Left;int Top;int Right;int Bottom;" & "dword dwItemSpec;uint uItemState;long lItemlParam;int clrText;int clrTextBk;int iSubItem;dword dwItemType;int clrFace;int iIconEffect;" & "int iIconPhase;int iPartId;int iStateId;int TextLeft;int TextTop;int TextRight;int TextBottom;uint uAlign"
Global Const $tagnmlvdispinfo = $tagnmhdr & ";int Mask;int Item;int SubItem;int State;int StateMask;" & "ptr Text;int TextMax;int Image;int Param;int Indent;int GroupID;int Columns;ptr pColumns"
Global Const $tagnmlvfinditem = $tagnmhdr & ";int Start;int Flags;ptr Text;int Param;int X;int Y;int Direction"
Global Const $tagnmlvgetinfotip = $tagnmhdr & ";int Flags;ptr Text;int TextMax;int Item;int SubItem;int lParam"
Global Const $tagnmitemactivate = $tagnmhdr & ";int Index;int SubItem;int NewState;int OldState;" & "int Changed;int X;int Y;int lParam;int KeyFlags"
Global Const $tagnmlvkeydown = $tagnmhdr & ";int VKey;int Flags"
Global Const $tagnmlvscroll = $tagnmhdr & ";int DX;int DY"
Global Const $taglvsetinfotip = "int Size;int Flags;ptr Text;int Item;int SubItem"
Global Const $tagmchittestinfo = "int Size;int X;int Y;int Hit;short Year;short Month;short DOW;short Day;short Hour;" & "short Minute;short Second;short MSeconds"
Global Const $tagmcmonthrange = "short MinYear;short MinMonth;short MinDOW;short MinDay;short MinHour;short MinMinute;short MinSecond;" & "short MinMSeconds;short MaxYear;short MaxMonth;short MaxDOW;short MaxDay;short MaxHour;short MaxMinute;short MaxSecond;" & "short MaxMSeconds;short Span"
Global Const $tagmcrange = "short MinYear;short MinMonth;short MinDOW;short MinDay;short MinHour;short MinMinute;short MinSecond;" & "short MinMSeconds;short MaxYear;short MaxMonth;short MaxDOW;short MaxDay;short MaxHour;short MaxMinute;short MaxSecond;" & "short MaxMSeconds;short MinSet;short MaxSet"
Global Const $tagmcselrange = "short MinYear;short MinMonth;short MinDOW;short MinDay;short MinHour;short MinMinute;short MinSecond;" & "short MinMSeconds;short MaxYear;short MaxMonth;short MaxDOW;short MaxDay;short MaxHour;short MaxMinute;short MaxSecond;" & "short MaxMSeconds"
Global Const $tagnmdaystate = $tagnmhdr & ";short Year;short Month;short DOW;short Day;short Hour;" & "short Minute;short Second;short MSeconds;int DayState;ptr pDayState"
Global Const $tagnmselchange = $tagnmhdr & ";short BegYear;short BegMonth;short BegDOW;short BegDay;" & "short BegHour;short BegMinute;short BegSecond;short BegMSeconds;short EndYear;short EndMonth;short EndDOW;" & "short EndDay;short EndHour;short EndMinute;short EndSecond;short EndMSeconds"
Global Const $tagnmobjectnotify = $tagnmhdr & ";int Item;ptr piid;ptr pObject;int Result"
Global Const $tagnmtckeydown = $tagnmhdr & ";int VKey;int Flags"
Global Const $tagtcitem = "int Mask;int State;int StateMask;ptr Text;int TextMax;int Image;int Param"
Global Const $tagtchittestinfo = "int X;int Y;int Flags"
Global Const $tagtvitemex = "int Mask;int hItem;int State;int StateMask;ptr Text;int TextMax;int Image;int SelectedImage;" & "int Children;int Param;int Integral"
Global Const $tagnmtreeview = $tagnmhdr & ";int Action;int OldMask;int OldhItem;int OldState;int OldStateMask;" & "ptr OldText;int OldTextMax;int OldImage;int OldSelectedImage;int OldChildren;int OldParam;int NewMask;int NewhItem;" & "int NewState;int NewStateMask;ptr NewText;int NewTextMax;int NewImage;int NewSelectedImage;int NewChildren;" & "int NewParam;int PointX; int PointY"
Global Const $tagnmtvcustomdraw = $tagnmhdr & ";uint DrawStage;hwnd HDC;int Left;int Top;int Right;int Bottom;" & "ptr ItemSpec;uint ItemState;int ItemParam;int ClrText;int ClrTextBk;int Level"
Global Const $tagnmtvdispinfo = $tagnmhdr & ";int Mask;int hItem;int State;int StateMask;" & "ptr Text;int TextMax;int Image;int SelectedImage;int Children;int Param"
Global Const $tagnmtvgetinfotip = $tagnmhdr & ";ptr Text;int TextMax;hwnd hItem;int lParam"
Global Const $tagtvhittestinfo = "int X;int Y;int Flags;int Item"
Global Const $tagtvinsertstruct = "hwnd Parent;int InsertAfter;int Mask;hwnd hItem;int State;int StateMask;ptr Text;int TextMax;" & "int Image;int SelectedImage;int Children;int Param"
Global Const $tagnmtvkeydown = $tagnmhdr & ";int VKey;int Flags"
Global Const $tagnmttdispinfo = $tagnmhdr & ";ptr pText;char aText[80];hwnd Instance;int Flags;int Param"
Global Const $tagtoolinfo = "int Size;int Flags;hwnd hWnd;int ID;int Left;int Top;int Right;int Bottom;hwnd hInst;ptr Text;int Param;ptr Reserved"
Global Const $tagttgettitle = "int Size;int Bitmap;int TitleMax;ptr Title"
Global Const $tagtthittestinfo = "hwnd Tool;int X;int Y;int Size;int Flags;hwnd hWnd;int ID;int Left;int Top;int Right;int Bottom;" & "hwnd hInst;ptr Text;int Param;ptr Reserved"
Global Const $tagnmmouse = $tagnmhdr & ";dword ItemSpec;dword ItemData;int X;int Y;dword HitInfo"
Global Const $tagpoint = "int X;int Y"
Global Const $tagrect = "int Left;int Top;int Right;int Bottom"
Global Const $tagmargins = "int cxLeftWidth;int cxRightWidth;int cyTopHeight;int cyBottomHeight"
Global Const $tagsize = "int X;int Y"
Global Const $tagtoken_privileges = "int Count;int64 LUID;int Attributes"
Global Const $tagimageinfo = "hwnd hBitmap;hwnd hMask;int Unused1;int Unused2;int Left;int Top;int Right;int Bottom"
Global Const $tagimagelistdrawparams = "int Size;hwnd hWnd;int Image;hwnd hDC;int X;int Y;int CX;int CY;int XBitmap;int YBitmap;" & "int BK;int FG;int Style;int ROP;int State;int Frame;int Effect"
Global Const $tagmemmap = "hwnd hProc;int Size;ptr Mem"
Global Const $tagmdinextmenu = "hwnd hMenuIn;hwnd hMenuNext;hwnd hWndNext"
Global Const $tagmenubarinfo = "int Size;int Left;int Top;int Right;int Bottom;int hMenu;int hWndMenu;int Focused"
Global Const $tagmenuex_template_header = "short Version;short Offset;int HelpID"
Global Const $tagmenuex_template_item = "int HelpID;int Type;int State;int MenuID;short ResInfo;ptr Text"
Global Const $tagmenugetobjectinfo = "int Flags;int Pos;hwnd hMenu;ptr RIID;ptr Obj"
Global Const $tagmenuinfo = "int Size;int Mask;int Style;int YMax;int hBack;int ContextHelpID;ptr MenuData"
Global Const $tagmenuiteminfo = "int Size;int Mask;int Type;int State;int ID;int SubMenu;int BmpChecked;int BmpUnchecked;" & "int ItemData;ptr TypeData;int CCH;int BmpItem"
Global Const $tagmenuitemtemplate = "short Option;short ID;ptr String"
Global Const $tagmenuitemtemplateheader = "short Version;short Offset"
Global Const $tagtpmparams = "short Version;short Offset"
Global Const $tagconnection_info_1 = "int ID;int Type;int Opens;int Users;int Time;ptr Username;ptr NetName"
Global Const $tagfile_info_3 = "int ID;int Permissions;int Locks;ptr Pathname;ptr Username"
Global Const $tagsession_info_2 = "ptr CName;ptr Username;int Opens;int Time;int Idle;int Flags;ptr TypeName"
Global Const $tagsession_info_502 = "ptr CName;ptr Username;int Opens;int Time;int Idle;int Flags;ptr TypeName;ptr Transport"
Global Const $tagshare_info_2 = "ptr NetName;int Type;ptr Remark;int Permissions;int MaxUses;int CurrentUses;ptr Path;ptr Password"
Global Const $tagstat_server_0 = "int Start;int FOpens;int DevOpens;int JobsQueued;int SOpens;int STimedOut;int SErrorOut;" & "int PWErrors;int PermErrors;int SysErrors;int64 ByteSent;int64 ByteRecv;int AvResponse;int ReqBufNeed;int BigBufNeed"
Global Const $tagstat_workstation_0 = "int64 StartTime;int64 BytesRecv;int64 SMBSRecv;int64 PageRead;int64 NonPageRead;" & "int64 CacheRead;int64 NetRead;int64 BytesTran;int64 SMBSTran;int64 PageWrite;int64 NonPageWrite;int64 CacheWrite;" & "int64 NetWrite;int InitFailed;int FailedComp;int ReadOp;int RandomReadOp;int ReadSMBS;int LargeReadSMBS;" & "int SmallReadSMBS;int WriteOp;int RandomWriteOp;int WriteSMBS;int LargeWriteSMBS;int SmallWriteSMBS;" & "int RawReadsDenied;int RawWritesDenied;int NetworkErrors;int Sessions;int FailedSessions;int Reconnects;" & "int CoreConnects;int LM20Connects;int LM21Connects;int LMNTConnects;int ServerDisconnects;int HungSessions;" & "int UseCount;int FailedUseCount;int CurrentCommands"
Global Const $tagfiletime = "dword Lo;dword Hi"
Global Const $tagsystemtime = "short Year;short Month;short Dow;short Day;short Hour;short Minute;short Second;short MSeconds"
Global Const $tagtime_zone_information = "long Bias;byte StdName[64];ushort StdDate[8];long StdBias;byte DayName[64];ushort DayDate[8];long DayBias"
Global Const $tagpbrange = "int Low;int High"
Global Const $tagrebarbandinfo = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;hwnd hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;int lParam;uint cxHeader"
Global Const $tagnmrebarautobreak = $tagnmhdr & ";uint uBand;uint wID;int lParam;uint uMsg;uint fStyleCurrent;int fAutoBreak"
Global Const $tagnmrbautosize = $tagnmhdr & ";int fChanged;int TargetLeft;int TargetTop;int TargetRight;int TargetBottom;" & "int ActualLeft;int ActualTop;int ActualRight;int ActualBottom"
Global Const $tagnmrebar = $tagnmhdr & ";dword dwMask;uint uBand;uint fStyle;uint wID;int lParam"
Global Const $tagnmrebarchevron = $tagnmhdr & ";uint uBand;uint wID;int lParam;int Left;int Top;int Right;int Bottom;int lParamNM"
Global Const $tagnmrebarchildsize = $tagnmhdr & ";uint uBand;uint wID;int CLeft;int CTop;int CRight;int CBottom;" & "int BLeft;int BTop;int BRight;int BBottom"
Global Const $tagrebarinfo = "uint cbSize;uint fMask;hwnd himl"
Global Const $tagrbhittestinfo = "int X;int Y;uint flags;int iBand"
Global Const $tagcolorscheme = "int Size;int BtnHighlight;int BtnShadow"
Global Const $tagtbaddbitmap = "int hInst;int ID"
Global Const $tagnmtoolbar = $tagnmhdr & ";int iItem;int iBitmap;int idCommand;" & "byte fsState;byte fsStyle;byte bReserved1;byte bReserved2;dword dwData;int iString;int cchText;" & "ptr pszText;int Left;int Top;int Right;int Bottom"
Global Const $tagnmtbhotitem = $tagnmhdr & ";int idOld;int idNew;dword dwFlags"
Global Const $tagtbbutton = "int Bitmap;int Command;byte State;byte Style;short Reserved;int Param;int String"
Global Const $tagtbbuttoninfo = "int Size;int Mask;int Command;int Image;byte State;byte Style;short CX;int Param;ptr Text;int TextMax"
Global Const $tagtbinsertmark = "int Button;int Flags"
Global Const $tagtbmetrics = "int Size;int Mask;int XPad;int YPad;int XBarPad;int YBarPad;int XSpacing;int YSpacing"
Global Const $tagconnectdlgstruct = "int Size;hwnd hWnd;ptr Resource;int Flags;int DevNum"
Global Const $tagdiscdlgstruct = "int Size;hwnd hWnd;ptr LocalName;ptr RemoteName;int Flags"
Global Const $tagnetconnectinfostruct = "int Size;int Flags;int Speed;int Delay;int OptDataSize"
Global Const $tagnetinfostruct = "int Size;int Version;int Status;int Char;int Handle;short NetType;int Printers;int Drives;short Reserved"
Global Const $tagnetresource = "int Scope;int Type;int DisplayType;int Usage;ptr LocalName;ptr RemoteName;ptr Comment;ptr Provider"
Global Const $tagremotenameinfo = "ptr Universal;ptr Connection;ptr Remaining"
Global Const $tagoverlapped = "int Internal;int InternalHigh;int Offset;int OffsetHigh;int hEvent"
Global Const $tagopenfilename = "dword StructSize;hwnd hwndOwner;hwnd hInstance;ptr lpstrFilter;ptr lpstrCustomFilter;" & "dword nMaxCustFilter;dword nFilterIndex;ptr lpstrFile;dword nMaxFile;ptr lpstrFileTitle;int nMaxFileTitle;" & "ptr lpstrInitialDir;ptr lpstrTitle;dword Flags;short nFileOffset;short nFileExtension;ptr lpstrDefExt;ptr lCustData;" & "ptr lpfnHook;ptr lpTemplateName;ptr pvReserved;dword dwReserved;dword FlagsEx"
Global Const $tagbitmapinfo = "dword Size;long Width;long Height;ushort Planes;ushort BitCount;dword Compression;dword SizeImage;" & "long XPelsPerMeter;long YPelsPerMeter;dword ClrUsed;dword ClrImportant;dword RGBQuad"
Global Const $tagblendfunction = "byte Op;byte Flags;byte Alpha;byte Format"
Global Const $tagborders = "int BX;int BY;int RX"
Global Const $tagchoosecolor = "dword Size;hwnd hWndOwnder;hwnd hInstance;int rgbResult;int_ptr CustColors;dword Flags;int_ptr lCustData;" & "ptr lpfnHook;ptr lpTemplateName"
Global Const $tagchoosefont = "dword Size;hwnd hWndOwner;hwnd hDC;ptr LogFont;int PointSize;dword Flags;int rgbColors;int_ptr CustData;" & "ptr fnHook;ptr TemplateName;hwnd hInstance;ptr szStyle;ushort FontType;int SizeMin;int SizeMax"
Global Const $tagtextmetric = "long tmHeight;long tmAscent;long tmDescent;long tmInternalLeading;long tmExternalLeading;" & "long tmAveCharWidth;long tmMaxCharWidth;long tmWeight;long tmOverhang;long tmDigitizedAspectX;long tmDigitizedAspectY;" & "char tmFirstChar;char tmLastChar;char tmDefaultChar;char tmBreakChar;byte tmItalic;byte tmUnderlined;byte tmStruckOut;" & "byte tmPitchAndFamily;byte tmCharSet"
Global Const $tagcursorinfo = "int Size;int Flags;hwnd hCursor;int X;int Y"
Global Const $tagdisplay_device = "int Size;char Name[32];char String[128];int Flags;char ID[128];char Key[128]"
Global Const $tagflashwindow = "int Size;hwnd hWnd;int Flags;int Count;int TimeOut"
Global Const $tagguid = "int Data1;short Data2;short Data3;byte Data4[8]"
Global Const $tagiconinfo = "int Icon;int XHotSpot;int YHotSpot;hwnd hMask;hwnd hColor"
Global Const $tagwindowplacement = "UINT length; UINT flags; UINT showCmd; int ptMinPosition[2]; int ptMaxPosition[2]; int rcNormalPosition[4]"
Global Const $tagwindowpos = "hwnd hWnd;int InsertAfter;int X;int Y;int CX;int CY;int Flags"
Global Const $tagscrollinfo = "uint cbSize;uint fMask;int  nMin;int  nMax;uint nPage;int  nPos;int  nTrackPos"
Global Const $tagscrollbarinfo = "dword cbSize;int Left;int Top;int Right;int Bottom;int dxyLineButton;int xyThumbTop;" & "int xyThumbBottom;int reserved;dword rgstate[6]"
Global Const $taglogfont = "int Height;int Width;int Escapement;int Orientation;int Weight;byte Italic;byte Underline;" & "byte Strikeout;byte CharSet;byte OutPrecision;byte ClipPrecision;byte Quality;byte PitchAndFamily;char FaceName[32]"
Global Const $tagkbdllhookstruct = "dword vkCode;dword scanCode;dword flags;dword time;ulong_ptr dwExtraInfo"
Global Const $tagprocess_information = "hwnd hProcess;hwnd hThread;int ProcessID;int ThreadID"
Global Const $tagstartupinfo = "int Size;ptr Reserved1;ptr Desktop;ptr Title;int X;int Y;int XSize;int YSize;int XCountChars;" & "int YCountChars;int FillAttribute;int Flags;short ShowWindow;short Reserved2;ptr Reserved3;int StdInput;" & "int StdOutput;int StdError"
Global Const $tagsecurity_attributes = "int Length;ptr Descriptor;int InheritHandle"
Global Const $__securitycontant_format_message_from_system = 4096

Func _security__adjusttokenprivileges($htoken, $fdisableall, $pnewstate, $ibufferlen, $pprevstate = 0, $prequired = 0)
	Local $aresult
	$aresult = DllCall("Advapi32.dll", "int", "AdjustTokenPrivileges", "hwnd", $htoken, "int", $fdisableall, "ptr", $pnewstate, "int", $ibufferlen, "ptr", $pprevstate, "ptr", $prequired)
	Return SetError($aresult[0] = 0, 0, $aresult[0] <> 0)
EndFunc

Func _security__getaccountsid($saccount, $ssystem = "")
	Local $aacct
	$aacct = _security__lookupaccountname($saccount, $ssystem)
	If @error Then Return SetError(@error, 0, 0)
	Return _security__stringsidtosid($aacct[0])
EndFunc

Func _security__getlengthsid($psid)
	Local $aresult
	If NOT _security__isvalidsid($psid) Then Return SetError(-1, 0, 0)
	$aresult = DllCall("AdvAPI32.dll", "int", "GetLengthSid", "ptr", $psid)
	Return $aresult[0]
EndFunc

Func _security__gettokeninformation($htoken, $iclass)
	Local $pbuffer, $tbuffer, $aresult
	$aresult = DllCall("Advapi32.dll", "int", "GetTokenInformation", "hwnd", $htoken, "int", $iclass, "ptr", 0, "int", 0, "int*", 0)
	$tbuffer = DllStructCreate("byte[" & $aresult[5] & "]")
	$pbuffer = DllStructGetPtr($tbuffer)
	$aresult = DllCall("Advapi32.dll", "int", "GetTokenInformation", "hwnd", $htoken, "int", $iclass, "ptr", $pbuffer, "int", $aresult[5], "int*", 0)
	If $aresult[0] = 0 Then Return SetError(-1, 0, 0)
	Return SetError(0, 0, $tbuffer)
EndFunc

Func _security__impersonateself($ilevel = 2)
	Local $aresult
	$aresult = DllCall("Advapi32.dll", "int", "ImpersonateSelf", "int", $ilevel)
	Return SetError($aresult[0] = 0, 0, $aresult[0] <> 0)
EndFunc

Func _security__isvalidsid($psid)
	Local $aresult
	$aresult = DllCall("AdvAPI32.dll", "int", "IsValidSid", "ptr", $psid)
	Return $aresult[0] <> 0
EndFunc

Func _security__lookupaccountname($saccount, $ssystem = "")
	Local $tdata, $pdomain, $psid, $psize1, $psize2, $psnu, $aresult, $aacct[3]
	$tdata = DllStructCreate("byte SID[256];char Domain[256];int SNU;int Size1;int Size2")
	$psid = DllStructGetPtr($tdata, "SID")
	$pdomain = DllStructGetPtr($tdata, "Domain")
	$psnu = DllStructGetPtr($tdata, "SNU")
	$psize1 = DllStructGetPtr($tdata, "Size1")
	$psize2 = DllStructGetPtr($tdata, "Size2")
	DllStructSetData($tdata, "Size1", 256)
	DllStructSetData($tdata, "Size2", 256)
	$aresult = DllCall("AdvAPI32.dll", "int", "LookupAccountName", "str", $ssystem, "str", $saccount, "ptr", $psid, "ptr", $psize1, "ptr", $pdomain, "ptr", $psize2, "ptr", $psnu)
	If $aresult[0] <> 0 Then
		$aacct[0] = _security__sidtostringsid($psid)
		$aacct[1] = DllStructGetData($tdata, "Domain")
		$aacct[2] = DllStructGetData($tdata, "SNU")
	EndIf
	Return SetError($aresult[0] = 0, 0, $aacct)
EndFunc

Func _security__lookupaccountsid($vsid)
	Local $tdata, $pdomain, $pname, $psid, $tsid, $psize1, $psize2, $psnu, $aresult, $aacct[3]
	If IsString($vsid) Then
		$tsid = _security__stringsidtosid($vsid)
		$psid = DllStructGetPtr($tsid)
	Else
		$psid = $vsid
	EndIf
	If NOT _security__isvalidsid($psid) Then Return SetError(-1, 0, 0)
	$tdata = DllStructCreate("char Name[256];char Domain[256];int SNU;int Size1;int Size2")
	$pname = DllStructGetPtr($tdata, "Name")
	$pdomain = DllStructGetPtr($tdata, "Domain")
	$psnu = DllStructGetPtr($tdata, "SNU")
	$psize1 = DllStructGetPtr($tdata, "Size1")
	$psize2 = DllStructGetPtr($tdata, "Size2")
	DllStructSetData($tdata, "Size1", 256)
	DllStructSetData($tdata, "Size2", 256)
	$aresult = DllCall("AdvAPI32.dll", "int", "LookupAccountSid", "int", 0, "ptr", $psid, "ptr", $pname, "ptr", $psize1, "ptr", $pdomain, "ptr", $psize2, "ptr", $psnu)
	$aacct[0] = DllStructGetData($tdata, "Name")
	$aacct[1] = DllStructGetData($tdata, "Domain")
	$aacct[2] = DllStructGetData($tdata, "SNU")
	Return SetError($aresult[0] = 0, 0, $aacct)
EndFunc

Func _security__lookupprivilegevalue($ssystem, $sname)
	Local $tdata, $aresult
	$tdata = DllStructCreate("int64 LUID")
	$aresult = DllCall("Advapi32.dll", "int", "LookupPrivilegeValue", "str", $ssystem, "str", $sname, "ptr", DllStructGetPtr($tdata))
	Return SetError($aresult[0] = 0, 0, DllStructGetData($tdata, "LUID"))
EndFunc

Func _security__openprocesstoken($hprocess, $iaccess)
	Local $aresult
	$aresult = DllCall("Advapi32.dll", "int", "OpenProcessToken", "hwnd", $hprocess, "dword", $iaccess, "int*", 0)
	Return SetError($aresult[0], 0, $aresult[3])
EndFunc

Func _security__openthreadtoken($iaccess, $hthread = 0, $fopenasself = False)
	Local $tdata, $ptoken, $aresult
	If $hthread = 0 Then $hthread = _winapi_getcurrentthread()
	$tdata = DllStructCreate("int Token")
	$ptoken = DllStructGetPtr($tdata, "Token")
	$aresult = DllCall("Advapi32.dll", "int", "OpenThreadToken", "int", $hthread, "int", $iaccess, "int", $fopenasself, "ptr", $ptoken)
	Return SetError($aresult[0] = 0, 0, DllStructGetData($tdata, "Token"))
EndFunc

Func _security__openthreadtokenex($iaccess, $hthread = 0, $fopenasself = False)
	Local $htoken
	$htoken = _security__openthreadtoken($iaccess, $hthread, $fopenasself)
	If $htoken = 0 Then
		If _winapi_getlasterror() = $error_no_token Then
			If NOT _security__impersonateself() Then Return SetError(-1, _winapi_getlasterror(), 0)
			$htoken = _security__openthreadtoken($iaccess, $hthread, $fopenasself)
			If $htoken = 0 Then Return SetError(-2, _winapi_getlasterror(), 0)
		Else
			Return SetError(-3, _winapi_getlasterror(), 0)
		EndIf
	EndIf
	Return SetError(0, 0, $htoken)
EndFunc

Func _security__setprivilege($htoken, $sprivilege, $fenable)
	Local $prequired, $trequired, $iluid, $iattributes, $icurrstate, $pcurrstate, $tcurrstate, $iprevstate, $pprevstate, $tprevstate
	$iluid = _security__lookupprivilegevalue("", $sprivilege)
	If $iluid = 0 Then Return SetError(-1, 0, False)
	$tcurrstate = DllStructCreate($tagtoken_privileges)
	$pcurrstate = DllStructGetPtr($tcurrstate)
	$icurrstate = DllStructGetSize($tcurrstate)
	$tprevstate = DllStructCreate($tagtoken_privileges)
	$pprevstate = DllStructGetPtr($tprevstate)
	$iprevstate = DllStructGetSize($tprevstate)
	$trequired = DllStructCreate("int Data")
	$prequired = DllStructGetPtr($trequired)
	DllStructSetData($tcurrstate, "Count", 1)
	DllStructSetData($tcurrstate, "LUID", $iluid)
	If NOT _security__adjusttokenprivileges($htoken, False, $pcurrstate, $icurrstate, $pprevstate, $prequired) Then
		Return SetError(-2, @error, False)
	EndIf
	DllStructSetData($tprevstate, "Count", 1)
	DllStructSetData($tprevstate, "LUID", $iluid)
	$iattributes = DllStructGetData($tprevstate, "Attributes")
	If $fenable Then
		$iattributes = BitOR($iattributes, $se_privilege_enabled)
	Else
		$iattributes = BitAND($iattributes, BitNOT($se_privilege_enabled))
	EndIf
	DllStructSetData($tprevstate, "Attributes", $iattributes)
	If NOT _security__adjusttokenprivileges($htoken, False, $pprevstate, $iprevstate, $pcurrstate, $prequired) Then
		Return SetError(-3, @error, False)
	EndIf
	Return SetError(0, 0, True)
EndFunc

Func _security__sidtostringsid($psid)
	Local $tptr, $tbuffer, $ssid, $aresult
	If NOT _security__isvalidsid($psid) Then Return SetError(-1, 0, "")
	$tptr = DllStructCreate("ptr Buffer")
	$aresult = DllCall("AdvAPI32.dll", "int", "ConvertSidToStringSid", "ptr", $psid, "ptr", DllStructGetPtr($tptr))
	If $aresult[0] = 0 Then Return SetError(-2, 0, "")
	$tbuffer = DllStructCreate("char Text[256]", DllStructGetData($tptr, "Buffer"))
	$ssid = DllStructGetData($tbuffer, "Text")
	_winapi_localfree(DllStructGetData($tptr, "Buffer"))
	Return $ssid
EndFunc

Func _security__sidtypestr($itype)
	Switch $itype
		Case 1
			Return "User"
		Case 2
			Return "Group"
		Case 3
			Return "Domain"
		Case 4
			Return "Alias"
		Case 5
			Return "Well Known Group"
		Case 6
			Return "Deleted Account"
		Case 7
			Return "Invalid"
		Case 8
			Return "Invalid"
		Case 9
			Return "Computer"
		Case Else
			Return "Unknown SID Type"
	EndSwitch
EndFunc

Func _security__stringsidtosid($ssid)
	Local $tptr, $isize, $tbuffer, $tsid, $aresult
	$tptr = DllStructCreate("ptr Buffer")
	$aresult = DllCall("AdvAPI32.dll", "int", "ConvertStringSidToSid", "str", $ssid, "ptr", DllStructGetPtr($tptr))
	If $aresult = 0 Then Return SetError(-1, 0, 0)
	$isize = _security__getlengthsid(DllStructGetData($tptr, "Buffer"))
	$tbuffer = DllStructCreate("byte Data[" & $isize & "]", DllStructGetData($tptr, "Buffer"))
	$tsid = DllStructCreate("byte Data[" & $isize & "]")
	DllStructSetData($tsid, "Data", DllStructGetData($tbuffer, "Data"))
	_winapi_localfree(DllStructGetData($tptr, "Buffer"))
	Return $tsid
EndFunc

Func _sendmessage($hwnd, $imsg, $wparam = 0, $lparam = 0, $ireturn = 0, $wparamtype = "wparam", $lparamtype = "lparam", $sreturntype = "lparam")
	Local $aresult = DllCall("user32.dll", $sreturntype, "SendMessage", "hwnd", $hwnd, "int", $imsg, $wparamtype, $wparam, $lparamtype, $lparam)
	If @error Then Return SetError(@error, @extended, "")
	If $ireturn >= 0 AND $ireturn <= 4 Then Return $aresult[$ireturn]
	Return $aresult
EndFunc

Func _sendmessagea($hwnd, $imsg, $wparam = 0, $lparam = 0, $ireturn = 0, $wparamtype = "wparam", $lparamtype = "lparam", $sreturntype = "lparam")
	Local $aresult = DllCall("user32.dll", $sreturntype, "SendMessageA", "hwnd", $hwnd, "int", $imsg, $wparamtype, $wparam, $lparamtype, $lparam)
	If @error Then Return SetError(@error, @extended, "")
	If $ireturn >= 0 AND $ireturn <= 4 Then Return $aresult[$ireturn]
	Return $aresult
EndFunc

Global $winapi_gainprocess[64][2] = [[0, 0]]
Global $winapi_gawinlist[64][2] = [[0, 0]]
Global Const $__winapconstant_wm_setfont = 48
Global Const $__winapconstant_fw_normal = 400
Global Const $__winapconstant_default_charset = 1
Global Const $__winapconstant_out_default_precis = 0
Global Const $__winapconstant_clip_default_precis = 0
Global Const $__winapconstant_default_quality = 0
Global Const $__winapconstant_format_message_from_system = 4096
Global Const $__winapconstant_invalid_set_file_pointer = -1
Global Const $__winapconstant_token_adjust_privileges = 32
Global Const $__winapconstant_token_query = 8
Global Const $__winapconstant_logpixelsx = 88
Global Const $__winapconstant_logpixelsy = 90
Global Const $__winapconstant_flashw_caption = 1
Global Const $__winapconstant_flashw_tray = 2
Global Const $__winapconstant_flashw_timer = 4
Global Const $__winapconstant_flashw_timernofg = 12
Global Const $__winapconstant_gw_hwndnext = 2
Global Const $__winapconstant_gw_child = 5
Global Const $__winapconstant_di_mask = 1
Global Const $__winapconstant_di_image = 2
Global Const $__winapconstant_di_normal = 3
Global Const $__winapconstant_di_compat = 4
Global Const $__winapconstant_di_defaultsize = 8
Global Const $__winapconstant_di_nomirror = 16
Global Const $__winapconstant_display_device_attached_to_desktop = 1
Global Const $__winapconstant_display_device_primary_device = 4
Global Const $__winapconstant_display_device_mirroring_driver = 8
Global Const $__winapconstant_display_device_vga_compatible = 16
Global Const $__winapconstant_display_device_removable = 32
Global Const $__winapconstant_display_device_modespruned = 134217728
Global Const $__winapconstant_create_new = 1
Global Const $__winapconstant_create_always = 2
Global Const $__winapconstant_open_existing = 3
Global Const $__winapconstant_open_always = 4
Global Const $__winapconstant_truncate_existing = 5
Global Const $__winapconstant_file_attribute_readonly = 1
Global Const $__winapconstant_file_attribute_hidden = 2
Global Const $__winapconstant_file_attribute_system = 4
Global Const $__winapconstant_file_attribute_archive = 32
Global Const $__winapconstant_file_share_read = 1
Global Const $__winapconstant_file_share_write = 2
Global Const $__winapconstant_file_share_delete = 4
Global Const $__winapconstant_generic_execute = 536870912
Global Const $__winapconstant_generic_write = 1073741824
Global Const $__winapconstant_generic_read = -2147483648
Global Const $null_brush = 5
Global Const $null_pen = 8
Global Const $black_brush = 4
Global Const $dkgray_brush = 3
Global Const $dc_brush = 18
Global Const $gray_brush = 2
Global Const $hollow_brush = $null_brush
Global Const $ltgray_brush = 1
Global Const $white_brush = 0
Global Const $black_pen = 7
Global Const $dc_pen = 19
Global Const $white_pen = 6
Global Const $ansi_fixed_font = 11
Global Const $ansi_var_font = 12
Global Const $device_default_font = 14
Global Const $default_gui_font = 17
Global Const $oem_fixed_font = 10
Global Const $system_font = 13
Global Const $system_fixed_font = 16
Global Const $default_palette = 15
Global Const $mb_precomposed = 1
Global Const $mb_composite = 2
Global Const $mb_useglyphchars = 4
Global Const $ulw_alpha = 2
Global Const $ulw_colorkey = 1
Global Const $ulw_opaque = 4
Global Const $wh_callwndproc = 4
Global Const $wh_callwndprocret = 12
Global Const $wh_cbt = 5
Global Const $wh_debug = 9
Global Const $wh_foregroundidle = 11
Global Const $wh_getmessage = 3
Global Const $wh_journalplayback = 1
Global Const $wh_journalrecord = 0
Global Const $wh_keyboard = 2
Global Const $wh_keyboard_ll = 13
Global Const $wh_mouse = 7
Global Const $wh_mouse_ll = 14
Global Const $wh_msgfilter = -1
Global Const $wh_shell = 10
Global Const $wh_sysmsgfilter = 6
Global Const $wpf_asyncwindowplacement = 4
Global Const $wpf_restoretomaximized = 2
Global Const $wpf_setminposition = 1
Global Const $kf_extended = 256
Global Const $kf_altdown = 8192
Global Const $kf_up = 32768
Global Const $llkhf_extended = BitShift($kf_extended, 8)
Global Const $llkhf_injected = 16
Global Const $llkhf_altdown = BitShift($kf_altdown, 8)
Global Const $llkhf_up = BitShift($kf_up, 8)
Global Const $ofn_allowmultiselect = 512
Global Const $ofn_createprompt = 8192
Global Const $ofn_dontaddtorecent = 33554432
Global Const $ofn_enablehook = 32
Global Const $ofn_enableincludenotify = 4194304
Global Const $ofn_enablesizing = 8388608
Global Const $ofn_enabletemplate = 64
Global Const $ofn_enabletemplatehandle = 128
Global Const $ofn_explorer = 524288
Global Const $ofn_extensiondifferent = 1024
Global Const $ofn_filemustexist = 4096
Global Const $ofn_forceshowhidden = 268435456
Global Const $ofn_hidereadonly = 4
Global Const $ofn_longnames = 2097152
Global Const $ofn_nochangedir = 8
Global Const $ofn_nodereferencelinks = 1048576
Global Const $ofn_nolongnames = 262144
Global Const $ofn_nonetworkbutton = 131072
Global Const $ofn_noreadonlyreturn = 32768
Global Const $ofn_notestfilecreate = 65536
Global Const $ofn_novalidate = 256
Global Const $ofn_overwriteprompt = 2
Global Const $ofn_pathmustexist = 2048
Global Const $ofn_readonly = 1
Global Const $ofn_shareaware = 16384
Global Const $ofn_showhelp = 16
Global Const $ofn_ex_noplacesbar = 1

Func _winapi_attachconsole($iprocessid = -1)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "AttachConsole", "dword", $iprocessid)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_attachthreadinput($iattach, $iattachto, $fattach)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "AttachThreadInput", "int", $iattach, "int", $iattachto, "int", $fattach)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_beep($ifreq = 500, $iduration = 1000)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "Beep", "dword", $ifreq, "dword", $iduration)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_bitblt($hdestdc, $ixdest, $iydest, $iwidth, $iheight, $hsrcdc, $ixsrc, $iysrc, $irop)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "int", "BitBlt", "hwnd", $hdestdc, "int", $ixdest, "int", $iydest, "int", $iwidth, "int", $iheight, "hwnd", $hsrcdc, "int", $ixsrc, "int", $iysrc, "int", $irop)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_callnexthookex($hhk, $icode, $wparam, $lparam)
	Local $iresult = DllCall("user32.dll", "lparam", "CallNextHookEx", "hwnd", $hhk, "int", $icode, "wparam", $wparam, "lparam", $lparam)
	If @error Then Return SetError(@error, @extended, -1)
	Return $iresult[0]
EndFunc

Func _winapi_callwindowproc($lpprevwndfunc, $hwnd, $msg, $wparam, $lparam)
	Local $aresult
	$aresult = DllCall("user32.dll", "int", "CallWindowProc", "ptr", $lpprevwndfunc, "hwnd", $hwnd, "uint", $msg, "wparam", $wparam, "lparam", $lparam)
	If @error Then Return SetError(-1, 0, -1)
	Return $aresult[0]
EndFunc

Func _winapi_check($sfunction, $ferror, $verror, $ftranslate = False)
	If $ferror Then
		If $ftranslate Then $verror = _winapi_getlasterrormessage()
		_winapi_showerror($sfunction & ": " & $verror)
	EndIf
EndFunc

Func _winapi_clienttoscreen($hwnd, ByRef $tpoint)
	Local $ppoint, $aresult
	$ppoint = DllStructGetPtr($tpoint)
	$aresult = DllCall("User32.dll", "int", "ClientToScreen", "hwnd", $hwnd, "ptr", $ppoint)
	If @error Then Return SetError(@error, 0, $tpoint)
	Return SetError($aresult[0] <> 0, 0, $tpoint)
EndFunc

Func _winapi_closehandle($hobject)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "CloseHandle", "int", $hobject)
	_winapi_check("_WinAPI_CloseHandle", ($aresult[0] = 0), 0, True)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_combinergn($hrgndest, $hrgnsrc1, $hrgnsrc2, $icombinemode)
	Local $aresult = DllCall("gdi32.dll", "int", "CombineRgn", "hwnd", $hrgndest, "hwnd", $hrgnsrc1, "hwnd", $hrgnsrc2, "int", $icombinemode)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_commdlgextendederror()
	Local Const $cderr_dialogfailure = 65535
	Local Const $cderr_findresfailure = 6
	Local Const $cderr_initialization = 2
	Local Const $cderr_loadresfailure = 7
	Local Const $cderr_loadstrfailure = 5
	Local Const $cderr_lockresfailure = 8
	Local Const $cderr_memallocfailure = 9
	Local Const $cderr_memlockfailure = 10
	Local Const $cderr_nohinstance = 4
	Local Const $cderr_nohook = 11
	Local Const $cderr_notemplate = 3
	Local Const $cderr_registermsgfail = 12
	Local Const $cderr_structsize = 1
	Local Const $fnerr_buffertoosmall = 12291
	Local Const $fnerr_invalidfilename = 12290
	Local Const $fnerr_subclassfailure = 12289
	Local $iresult = DllCall("comdlg32.dll", "dword", "CommDlgExtendedError")
	If @error Then Return SetError(@error, @extended, "")
	SetError($iresult[0])
	Switch @error
		Case $cderr_dialogfailure
			Return SetError(@error, 0, "The dialog box could not be created." & @LF & "The common dialog box function's call to the DialogBox function failed." & @LF & "For example, this error occurs if the common dialog box call specifies an invalid window handle.")
		Case $cderr_findresfailure
			Return SetError(@error, 0, "The common dialog box function failed to find a specified resource.")
		Case $cderr_initialization
			Return SetError(@error, 0, "The common dialog box function failed during initialization." & @LF & "This error often occurs when sufficient memory is not available.")
		Case $cderr_loadresfailure
			Return SetError(@error, 0, "The common dialog box function failed to load a specified resource.")
		Case $cderr_loadstrfailure
			Return SetError(@error, 0, "The common dialog box function failed to load a specified string.")
		Case $cderr_lockresfailure
			Return SetError(@error, 0, "The common dialog box function failed to lock a specified resource.")
		Case $cderr_memallocfailure
			Return SetError(@error, 0, "The common dialog box function was unable to allocate memory for internal structures.")
		Case $cderr_memlockfailure
			Return SetError(@error, 0, "The common dialog box function was unable to lock the memory associated with a handle.")
		Case $cderr_nohinstance
			Return SetError(@error, 0, "The ENABLETEMPLATE flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & "but you failed to provide a corresponding instance handle.")
		Case $cderr_nohook
			Return SetError(@error, 0, "The ENABLEHOOK flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & "but you failed to provide a pointer to a corresponding hook procedure.")
		Case $cderr_notemplate
			Return SetError(@error, 0, "The ENABLETEMPLATE flag was set in the Flags member of the initialization structure for the corresponding common dialog box," & @LF & "but you failed to provide a corresponding template.")
		Case $cderr_registermsgfail
			Return SetError(@error, 0, "The RegisterWindowMessage function returned an error code when it was called by the common dialog box function.")
		Case $cderr_structsize
			Return SetError(@error, 0, "The lStructSize member of the initialization structure for the corresponding common dialog box is invalid")
		Case $fnerr_buffertoosmall
			Return SetError(@error, 0, "The buffer pointed to by the lpstrFile member of the OPENFILENAME structure is too small for the file name specified by the user." & @LF & "The first two bytes of the lpstrFile buffer contain an integer value specifying the size, in TCHARs, required to receive the full name.")
		Case $fnerr_invalidfilename
			Return SetError(@error, 0, "A file name is invalid.")
		Case $fnerr_subclassfailure
			Return SetError(@error, 0, "An attempt to subclass a list box failed because sufficient memory was not available.")
	EndSwitch
EndFunc

Func _winapi_copyicon($hicon)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "CopyIcon", "hwnd", $hicon)
	_winapi_check("_WinAPI_CopyIcon", ($aresult[0] = 0), 0, True)
	Return $aresult[0]
EndFunc

Func _winapi_createbitmap($iwidth, $iheight, $iplanes = 1, $ibitsperpel = 1, $pbits = 0)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "hwnd", "CreateBitmap", "int", $iwidth, "int", $iheight, "int", $iplanes, "int", $ibitsperpel, "ptr", $pbits)
	_winapi_check("_WinAPI_CreateBitmap", ($aresult[0] = 0), 0, True)
	Return $aresult[0]
EndFunc

Func _winapi_createcompatiblebitmap($hdc, $iwidth, $iheight)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "hwnd", "CreateCompatibleBitmap", "hwnd", $hdc, "int", $iwidth, "int", $iheight)
	_winapi_check("_WinAPI_CreateCompatibleBitmap", ($aresult[0] = 0), 0, True)
	Return $aresult[0]
EndFunc

Func _winapi_createcompatibledc($hdc)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "hwnd", "CreateCompatibleDC", "hwnd", $hdc)
	_winapi_check("_WinAPI_CreateCompatibleDC", ($aresult[0] = 0), 0, True)
	Return $aresult[0]
EndFunc

Func _winapi_createevent($pattributes = 0, $fmanualreset = True, $finitialstate = True, $sname = "")
	Local $aresult
	If $sname = "" Then $sname = 0
	$aresult = DllCall("Kernel32.dll", "int", "CreateEvent", "ptr", $pattributes, "int", $fmanualreset, "int", $finitialstate, "str", $sname)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_createfile($sfilename, $icreation, $iaccess = 4, $ishare = 0, $iattributes = 0, $psecurity = 0)
	Local $ida = 0, $ism = 0, $icd = 0, $ifa = 0, $aresult
	If BitAND($iaccess, 1) <> 0 Then $ida = BitOR($ida, $__winapconstant_generic_execute)
	If BitAND($iaccess, 2) <> 0 Then $ida = BitOR($ida, $__winapconstant_generic_read)
	If BitAND($iaccess, 4) <> 0 Then $ida = BitOR($ida, $__winapconstant_generic_write)
	If BitAND($ishare, 1) <> 0 Then $ism = BitOR($ism, $__winapconstant_file_share_delete)
	If BitAND($ishare, 2) <> 0 Then $ism = BitOR($ism, $__winapconstant_file_share_read)
	If BitAND($ishare, 4) <> 0 Then $ism = BitOR($ism, $__winapconstant_file_share_write)
	Switch $icreation
		Case 0
			$icd = $__winapconstant_create_new
		Case 1
			$icd = $__winapconstant_create_always
		Case 2
			$icd = $__winapconstant_open_existing
		Case 3
			$icd = $__winapconstant_open_always
		Case 4
			$icd = $__winapconstant_truncate_existing
	EndSwitch
	If BitAND($iattributes, 1) <> 0 Then $ifa = BitOR($ifa, $__winapconstant_file_attribute_archive)
	If BitAND($iattributes, 2) <> 0 Then $ifa = BitOR($ifa, $__winapconstant_file_attribute_hidden)
	If BitAND($iattributes, 4) <> 0 Then $ifa = BitOR($ifa, $__winapconstant_file_attribute_readonly)
	If BitAND($iattributes, 8) <> 0 Then $ifa = BitOR($ifa, $__winapconstant_file_attribute_system)
	$aresult = DllCall("Kernel32.dll", "hwnd", "CreateFile", "str", $sfilename, "int", $ida, "int", $ism, "ptr", $psecurity, "int", $icd, "int", $ifa, "int", 0)
	If @error Then Return SetError(@error, 0, 0)
	If $aresult[0] = -1 Then Return 0
	Return $aresult[0]
EndFunc

Func _winapi_createfont($nheight, $nwidth, $nescape = 0, $norientn = 0, $fnweight = $__winapconstant_fw_normal, $bitalic = False, $bunderline = False, $bstrikeout = False, $ncharset = $__winapconstant_default_charset, $noutputprec = $__winapconstant_out_default_precis, $nclipprec = $__winapconstant_clip_default_precis, $nquality = $__winapconstant_default_quality, $npitch = 0, $szface = "Arial")
	Local $tbuffer = DllStructCreate("char FontName[" & StringLen($szface) + 1 & "]")
	Local $pbuffer = DllStructGetPtr($tbuffer)
	Local $afont
	DllStructSetData($tbuffer, "FontName", $szface)
	$afont = DllCall("gdi32.dll", "hwnd", "CreateFont", "int", $nheight, "int", $nwidth, "int", $nescape, "int", $norientn, "int", $fnweight, "long", $bitalic, "long", $bunderline, "long", $bstrikeout, "long", $ncharset, "long", $noutputprec, "long", $nclipprec, "long", $nquality, "long", $npitch, "ptr", $pbuffer)
	If @error Then Return SetError(@error, 0, 0)
	Return $afont[0]
EndFunc

Func _winapi_createfontindirect($tlogfont)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "hwnd", "CreateFontIndirect", "ptr", DllStructGetPtr($tlogfont))
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_createpen($ipenstyle, $iwidth, $ncolor)
	Local $hpen = DllCall("gdi32.dll", "hwnd", "CreatePen", "int", $ipenstyle, "int", $iwidth, "int", $ncolor)
	If @error Then Return SetError(@error, 0, 0)
	Return $hpen[0]
EndFunc

Func _winapi_createprocess($sappname, $scommand, $psecurity, $pthread, $finherit, $iflags, $penviron, $sdir, $pstartupinfo, $pprocess)
	Local $pappname, $tappname, $pcommand, $tcommand, $pdir, $tdir, $aresult
	If $sappname <> "" Then
		$tappname = DllStructCreate("char Text[" & StringLen($sappname) + 1 & "]")
		$pappname = DllStructGetPtr($tappname)
		DllStructSetData($tappname, "Text", $sappname)
	EndIf
	If $scommand <> "" Then
		$tcommand = DllStructCreate("char Text[" & StringLen($scommand) + 1 & "]")
		$pcommand = DllStructGetPtr($tcommand)
		DllStructSetData($tcommand, "Text", $scommand)
	EndIf
	If $sdir <> "" Then
		$tdir = DllStructCreate("char Text[" & StringLen($sdir) + 1 & "]")
		$pdir = DllStructGetPtr($tdir)
		DllStructSetData($tdir, "Text", $sdir)
	EndIf
	$aresult = DllCall("Kernel32.dll", "int", "CreateProcess", "ptr", $pappname, "ptr", $pcommand, "ptr", $psecurity, "ptr", $pthread, "int", $finherit, "int", $iflags, "ptr", $penviron, "ptr", $pdir, "ptr", $pstartupinfo, "ptr", $pprocess)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_createrectrgn($ileftrect, $itoprect, $irightrect, $ibottomrect)
	Local $hrgn = DllCall("gdi32.dll", "hwnd", "CreateRectRgn", "int", $ileftrect, "int", $itoprect, "int", $irightrect, "int", $ibottomrect)
	If @error Then Return SetError(@error, 0, 0)
	Return $hrgn[0]
EndFunc

Func _winapi_createroundrectrgn($ileftrect, $itoprect, $irightrect, $ibottomrect, $iwidthellipse, $iheightellipse)
	Local $hrgn = DllCall("gdi32.dll", "hwnd", "CreateRoundRectRgn", "int", $ileftrect, "int", $itoprect, "int", $irightrect, "int", $ibottomrect, "int", $iwidthellipse, "int", $iheightellipse)
	If @error Then Return SetError(@error, 0, 0)
	Return $hrgn[0]
EndFunc

Func _winapi_createsolidbitmap($hwnd, $icolor, $iwidth, $iheight)
	Local $ii, $isize, $tbits, $tbmi, $hdc, $hbmp
	$isize = $iwidth * $iheight
	$tbits = DllStructCreate("int[" & $isize & "]")
	For $ii = 1 To $isize
		DllStructSetData($tbits, 1, $icolor, $ii)
	Next
	$tbmi = DllStructCreate($tagbitmapinfo)
	DllStructSetData($tbmi, "Size", DllStructGetSize($tbmi) - 4)
	DllStructSetData($tbmi, "Planes", 1)
	DllStructSetData($tbmi, "BitCount", 32)
	DllStructSetData($tbmi, "Width", $iwidth)
	DllStructSetData($tbmi, "Height", $iheight)
	$hdc = _winapi_getdc($hwnd)
	$hbmp = _winapi_createcompatiblebitmap($hdc, $iwidth, $iheight)
	_winapi_setdibits(0, $hbmp, 0, $iheight, DllStructGetPtr($tbits), DllStructGetPtr($tbmi))
	_winapi_releasedc($hwnd, $hdc)
	Return $hbmp
EndFunc

Func _winapi_createsolidbrush($ncolor)
	Local $hbrush = DllCall("gdi32.dll", "hwnd", "CreateSolidBrush", "int", $ncolor)
	If @error Then Return SetError(@error, 0, 0)
	Return $hbrush[0]
EndFunc

Func _winapi_createwindowex($iexstyle, $sclass, $sname, $istyle, $ix, $iy, $iwidth, $iheight, $hparent, $hmenu = 0, $hinstance = 0, $pparam = 0)
	Local $aresult
	If $hinstance = 0 Then $hinstance = _winapi_getmodulehandle("")
	$aresult = DllCall("User32.dll", "hwnd", "CreateWindowEx", "int", $iexstyle, "str", $sclass, "str", $sname, "int", $istyle, "int", $ix, "int", $iy, "int", $iwidth, "int", $iheight, "hwnd", $hparent, "hwnd", $hmenu, "hwnd", $hinstance, "ptr", $pparam)
	_winapi_check("_WinAPI_CreateWindowEx", ($aresult[0] = 0), 0, True)
	Return $aresult[0]
EndFunc

Func _winapi_defwindowproc($hwnd, $imsg, $iwparam, $ilparam)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "DefWindowProc", "hwnd", $hwnd, "int", $imsg, "int", $iwparam, "int", $ilparam)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_deletedc($hdc)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "int", "DeleteDC", "hwnd", $hdc)
	_winapi_check("_WinAPI_DeleteDC", ($aresult[0] = 0), 0, True)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_deleteobject($hobject)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "int", "DeleteObject", "int", $hobject)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_destroyicon($hicon)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "DestroyIcon", "hwnd", $hicon)
	_winapi_check("_WinAPI_DestroyIcon", ($aresult[0] = 0), 0, True)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_destroywindow($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "DestroyWindow", "hwnd", $hwnd)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_drawedge($hdc, $ptrrect, $nedgetype, $grfflags)
	Local $bresult = DllCall("user32.dll", "int", "DrawEdge", "hwnd", $hdc, "ptr", $ptrrect, "int", $nedgetype, "int", $grfflags)
	If @error Then Return SetError(@error, 0, False)
	Return $bresult[0] <> 0
EndFunc

Func _winapi_drawframecontrol($hdc, $ptrrect, $ntype, $nstate)
	Local $bresult = DllCall("user32.dll", "int", "DrawFrameControl", "hwnd", $hdc, "ptr", $ptrrect, "int", $ntype, "int", $nstate)
	If @error Then Return SetError(@error, 0, False)
	Return $bresult[0] <> 0
EndFunc

Func _winapi_drawicon($hdc, $ix, $iy, $hicon)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "DrawIcon", "hwnd", $hdc, "int", $ix, "int", $iy, "hwnd", $hicon)
	_winapi_check("_WinAPI_DrawIcon", ($aresult[0] = 0), 0, True)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_drawiconex($hdc, $ix, $iy, $hicon, $iwidth = 0, $iheight = 0, $istep = 0, $hbrush = 0, $iflags = 3)
	Local $ioptions, $aresult
	Switch $iflags
		Case 1
			$ioptions = $__winapconstant_di_mask
		Case 2
			$ioptions = $__winapconstant_di_image
		Case 3
			$ioptions = $__winapconstant_di_normal
		Case 4
			$ioptions = $__winapconstant_di_compat
		Case 5
			$ioptions = $__winapconstant_di_defaultsize
		Case Else
			$ioptions = $__winapconstant_di_nomirror
	EndSwitch
	$aresult = DllCall("User32.dll", "int", "DrawIconEx", "hwnd", $hdc, "int", $ix, "int", $iy, "hwnd", $hicon, "int", $iwidth, "int", $iheight, "uint", $istep, "hwnd", $hbrush, "uint", $ioptions)
	_winapi_check("_WinAPI_DrawIconEx", ($aresult[0] = 0), 0, True)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_drawline($hdc, $ix1, $iy1, $ix2, $iy2)
	_winapi_moveto($hdc, $ix1, $iy1)
	If @error Then Return SetError(@error, 0, False)
	_winapi_lineto($hdc, $ix2, $iy2)
	If @error Then Return SetError(@error, 0, False)
	Return True
EndFunc

Func _winapi_drawtext($hdc, $stext, ByRef $trect, $iflags)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "DrawText", "hwnd", $hdc, "str", $stext, "int", -1, "ptr", DllStructGetPtr($trect), "int", $iflags)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_enablewindow($hwnd, $fenable = True)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "EnableWindow", "hwnd", $hwnd, "int", $fenable)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0]
EndFunc

Func _winapi_enumdisplaydevices($sdevice, $idevnum)
	Local $pname, $tname, $idevice, $pdevice, $tdevice, $in, $iflags, $aresult, $adevice[5]
	If $sdevice <> "" Then
		$tname = DllStructCreate("char Text[128]")
		$pname = DllStructGetPtr($tname)
		DllStructSetData($tname, "Text", $sdevice)
	EndIf
	$tdevice = DllStructCreate($tagdisplay_device)
	$pdevice = DllStructGetPtr($tdevice)
	$idevice = DllStructGetSize($tdevice)
	DllStructSetData($tdevice, "Size", $idevice)
	$aresult = DllCall("User32.dll", "int", "EnumDisplayDevices", "ptr", $pname, "int", $idevnum, "ptr", $pdevice, "int", 1)
	If @error Then Return SetError(@error, 0, $adevice)
	$in = DllStructGetData($tdevice, "Flags")
	If BitAND($in, $__winapconstant_display_device_attached_to_desktop) <> 0 Then $iflags = BitOR($iflags, 1)
	If BitAND($in, $__winapconstant_display_device_primary_device) <> 0 Then $iflags = BitOR($iflags, 2)
	If BitAND($in, $__winapconstant_display_device_mirroring_driver) <> 0 Then $iflags = BitOR($iflags, 4)
	If BitAND($in, $__winapconstant_display_device_vga_compatible) <> 0 Then $iflags = BitOR($iflags, 8)
	If BitAND($in, $__winapconstant_display_device_removable) <> 0 Then $iflags = BitOR($iflags, 16)
	If BitAND($in, $__winapconstant_display_device_modespruned) <> 0 Then $iflags = BitOR($iflags, 32)
	$adevice[0] = $aresult[0] <> 0
	$adevice[1] = DllStructGetData($tdevice, "Name")
	$adevice[2] = DllStructGetData($tdevice, "String")
	$adevice[3] = $iflags
	$adevice[4] = DllStructGetData($tdevice, "ID")
	Return $adevice
EndFunc

Func _winapi_enumwindows($fvisible = True)
	_winapi_enumwindowsinit()
	_winapi_enumwindowschild(_winapi_getdesktopwindow(), $fvisible)
	Return $winapi_gawinlist
EndFunc

Func _winapi_enumwindowsadd($hwnd, $sclass = "")
	Local $icount
	If $sclass = "" Then $sclass = _winapi_getclassname($hwnd)
	$winapi_gawinlist[0][0] += 1
	$icount = $winapi_gawinlist[0][0]
	If $icount >= $winapi_gawinlist[0][1] Then
		ReDim $winapi_gawinlist[$icount + 64][2]
		$winapi_gawinlist[0][1] += 64
	EndIf
	$winapi_gawinlist[$icount][0] = $hwnd
	$winapi_gawinlist[$icount][1] = $sclass
EndFunc

Func _winapi_enumwindowschild($hwnd, $fvisible = True)
	$hwnd = _winapi_getwindow($hwnd, $__winapconstant_gw_child)
	While $hwnd <> 0
		If (NOT $fvisible) OR _winapi_iswindowvisible($hwnd) Then
			_winapi_enumwindowschild($hwnd, $fvisible)
			_winapi_enumwindowsadd($hwnd)
		EndIf
		$hwnd = _winapi_getwindow($hwnd, $__winapconstant_gw_hwndnext)
	WEnd
EndFunc

Func _winapi_enumwindowsinit()
	ReDim $winapi_gawinlist[64][2]
	$winapi_gawinlist[0][0] = 0
	$winapi_gawinlist[0][1] = 64
EndFunc

Func _winapi_enumwindowspopup()
	Local $hwnd, $sclass
	_winapi_enumwindowsinit()
	$hwnd = _winapi_getwindow(_winapi_getdesktopwindow(), $__winapconstant_gw_child)
	While $hwnd <> 0
		If _winapi_iswindowvisible($hwnd) Then
			$sclass = _winapi_getclassname($hwnd)
			If $sclass = "#32768" Then
				_winapi_enumwindowsadd($hwnd)
			ElseIf $sclass = "ToolbarWindow32" Then
				_winapi_enumwindowsadd($hwnd)
			ElseIf $sclass = "ToolTips_Class32" Then
				_winapi_enumwindowsadd($hwnd)
			ElseIf $sclass = "BaseBar" Then
				_winapi_enumwindowschild($hwnd)
			EndIf
		EndIf
		$hwnd = _winapi_getwindow($hwnd, $__winapconstant_gw_hwndnext)
	WEnd
	Return $winapi_gawinlist
EndFunc

Func _winapi_enumwindowstop()
	Local $hwnd
	_winapi_enumwindowsinit()
	$hwnd = _winapi_getwindow(_winapi_getdesktopwindow(), $__winapconstant_gw_child)
	While $hwnd <> 0
		If _winapi_iswindowvisible($hwnd) Then _winapi_enumwindowsadd($hwnd)
		$hwnd = _winapi_getwindow($hwnd, $__winapconstant_gw_hwndnext)
	WEnd
	Return $winapi_gawinlist
EndFunc

Func _winapi_expandenvironmentstrings($sstring)
	Local $ttext, $aresult
	$ttext = DllStructCreate("char Text[4096]")
	$aresult = DllCall("Kernel32.dll", "int", "ExpandEnvironmentStringsA", "str", $sstring, "ptr", DllStructGetPtr($ttext), "int", 4096)
	_winapi_check("_WinAPI_ExpandEnvironmentStrings", ($aresult[0] = 0), 0, True)
	Return DllStructGetData($ttext, "Text")
EndFunc

Func _winapi_extracticonex($sfile, $iindex, $plarge, $psmall, $iicons)
	Local $aresult
	$aresult = DllCall("Shell32.dll", "int", "ExtractIconEx", "str", $sfile, "int", $iindex, "ptr", $plarge, "ptr", $psmall, "int", $iicons)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_fatalappexit($smessage)
	DllCall("Kernel32.dll", "none", "FatalAppExit", "uint", 0, "str", $smessage)
EndFunc

Func _winapi_fillrect($hdc, $ptrrect, $hbrush)
	Local $bresult
	If IsHWnd($hbrush) Then
		$bresult = DllCall("user32.dll", "int", "FillRect", "hwnd", $hdc, "ptr", $ptrrect, "hwnd", $hbrush)
	Else
		$bresult = DllCall("user32.dll", "int", "FillRect", "hwnd", $hdc, "ptr", $ptrrect, "int", $hbrush)
	EndIf
	If @error Then Return SetError(@error, 0, False)
	Return $bresult[0] <> 0
EndFunc

Func _winapi_findexecutable($sfilename, $sdirectory = "")
	Local $ttext
	$ttext = DllStructCreate("char Text[4096]")
	DllCall("Shell32.dll", "hwnd", "FindExecutable", "str", $sfilename, "str", $sdirectory, "ptr", DllStructGetPtr($ttext))
	If @error Then Return SetError(@error, 0, 0)
	Return DllStructGetData($ttext, "Text")
EndFunc

Func _winapi_findwindow($sclassname, $swindowname)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "FindWindow", "str", $sclassname, "str", $swindowname)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_flashwindow($hwnd, $finvert = True)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "FlashWindow", "hwnd", $hwnd, "int", $finvert)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_flashwindowex($hwnd, $iflags = 3, $icount = 3, $itimeout = 0)
	Local $imode = 0, $iflash, $pflash, $tflash, $aresult
	$tflash = DllStructCreate($tagflashwindow)
	$pflash = DllStructGetPtr($tflash)
	$iflash = DllStructGetSize($tflash)
	If BitAND($iflags, 1) <> 0 Then $imode = BitOR($imode, $__winapconstant_flashw_caption)
	If BitAND($iflags, 2) <> 0 Then $imode = BitOR($imode, $__winapconstant_flashw_tray)
	If BitAND($iflags, 4) <> 0 Then $imode = BitOR($imode, $__winapconstant_flashw_timer)
	If BitAND($iflags, 8) <> 0 Then $imode = BitOR($imode, $__winapconstant_flashw_timernofg)
	DllStructSetData($tflash, "Size", $iflash)
	DllStructSetData($tflash, "hWnd", $hwnd)
	DllStructSetData($tflash, "Flags", $imode)
	DllStructSetData($tflash, "Count", $icount)
	DllStructSetData($tflash, "Timeout", $itimeout)
	$aresult = DllCall("User32.dll", "int", "FlashWindowEx", "ptr", $pflash)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_floattoint($nfloat)
	Local $tfloat, $tint
	$tfloat = DllStructCreate("float")
	$tint = DllStructCreate("int", DllStructGetPtr($tfloat))
	DllStructSetData($tfloat, 1, $nfloat)
	Return DllStructGetData($tint, 1)
EndFunc

Func _winapi_flushfilebuffers($hfile)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "FlushFileBuffers", "hwnd", $hfile)
	If @error Then Return SetError(@error, 0, False)
	Return SetError(_winapi_getlasterror(), 0, $aresult[0] <> 0)
EndFunc

Func _winapi_formatmessage($iflags, $psource, $imessageid, $ilanguageid, $pbuffer, $isize, $varguments)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "FormatMessageA", "int", $iflags, "hwnd", $psource, "int", $imessageid, "int", $ilanguageid, "ptr", $pbuffer, "int", $isize, "ptr", $varguments)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_framerect($hdc, $ptrrect, $hbrush)
	Local $bresult = DllCall("user32.dll", "int", "FrameRect", "hwnd", $hdc, "ptr", $ptrrect, "hwnd", $hbrush)
	If @error Then Return SetError(@error, 0, False)
	Return $bresult[0] <> 0
EndFunc

Func _winapi_freelibrary($hmodule)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "hwnd", "FreeLibrary", "hwnd", $hmodule)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_getancestor($hwnd, $iflags = 1)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "GetAncestor", "hwnd", $hwnd, "uint", $iflags)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getasynckeystate($ikey)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "GetAsyncKeyState", "int", $ikey)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getbkmode($hdc)
	Local $aresult = DllCall("gdi32.dll", "int", "GetBkMode", "ptr", $hdc)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getclassname($hwnd)
	Local $aresult
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	$aresult = DllCall("User32.dll", "int", "GetClassName", "hwnd", $hwnd, "str", "", "int", 4096)
	If @error Then Return SetError(@error, 0, "")
	Return $aresult[2]
EndFunc

Func _winapi_getclientheight($hwnd)
	Local $trect
	$trect = _winapi_getclientrect($hwnd)
	Return DllStructGetData($trect, "Bottom") - DllStructGetData($trect, "Top")
EndFunc

Func _winapi_getclientwidth($hwnd)
	Local $trect
	$trect = _winapi_getclientrect($hwnd)
	Return DllStructGetData($trect, "Right") - DllStructGetData($trect, "Left")
EndFunc

Func _winapi_getclientrect($hwnd)
	Local $trect, $aresult
	$trect = DllStructCreate($tagrect)
	$aresult = DllCall("User32.dll", "int", "GetClientRect", "hwnd", $hwnd, "ptr", DllStructGetPtr($trect))
	_winapi_check("_WinAPI_GetClientRect", ($aresult[0] = 0), 0, True)
	Return $trect
EndFunc

Func _winapi_getcurrentprocess()
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "hwnd", "GetCurrentProcess")
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getcurrentprocessid()
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "GetCurrentProcessId")
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getcurrentthread()
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "GetCurrentThread")
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getcurrentthreadid()
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "GetCurrentThreadId")
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getcursorinfo()
	Local $icursor, $tcursor, $aresult, $acursor[5]
	$tcursor = DllStructCreate($tagcursorinfo)
	$icursor = DllStructGetSize($tcursor)
	DllStructSetData($tcursor, "Size", $icursor)
	$aresult = DllCall("User32.dll", "int", "GetCursorInfo", "ptr", DllStructGetPtr($tcursor))
	_winapi_check("_WinAPI_GetCursorInfo", ($aresult[0] = 0), 0, True)
	$acursor[0] = $aresult[0] <> 0
	$acursor[1] = DllStructGetData($tcursor, "Flags") <> 0
	$acursor[2] = DllStructGetData($tcursor, "hCursor")
	$acursor[3] = DllStructGetData($tcursor, "X")
	$acursor[4] = DllStructGetData($tcursor, "Y")
	Return $acursor
EndFunc

Func _winapi_getdc($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "GetDC", "hwnd", $hwnd)
	_winapi_check("_WinAPI_GetDC", ($aresult[0] = 0), -1)
	Return $aresult[0]
EndFunc

Func _winapi_getdesktopwindow()
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "GetDesktopWindow")
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getdevicecaps($hdc, $iindex)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "int", "GetDeviceCaps", "hwnd", $hdc, "int", $iindex)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getdibits($hdc, $hbmp, $istartscan, $iscanlines, $pbits, $pbi, $iusage)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "int", "GetDIBits", "hwnd", $hdc, "hwnd", $hbmp, "int", $istartscan, "int", $iscanlines, "ptr", $pbits, "ptr", $pbi, "int", $iusage)
	_winapi_check("_WinAPI_GetDIBits", ($aresult[0] = 0), 0, True)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_getdlgctrlid($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "GetDlgCtrlID", "hwnd", $hwnd)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getdlgitem($hwnd, $iitemid)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "GetDlgItem", "hwnd", $hwnd, "int", $iitemid)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getfocus()
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "GetFocus")
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getforegroundwindow()
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "GetForegroundWindow")
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_geticoninfo($hicon)
	Local $tinfo, $aresult, $aicon[6]
	$tinfo = DllStructCreate($tagiconinfo)
	$aresult = DllCall("User32.dll", "int", "GetIconInfo", "hwnd", $hicon, "ptr", DllStructGetPtr($tinfo))
	_winapi_check("_WinAPI_GetIconInfo", ($aresult[0] = 0), 0, True)
	$aicon[0] = $aresult[0] <> 0
	$aicon[1] = DllStructGetData($tinfo, "Icon") <> 0
	$aicon[2] = DllStructGetData($tinfo, "XHotSpot")
	$aicon[3] = DllStructGetData($tinfo, "YHotSpot")
	$aicon[4] = DllStructGetData($tinfo, "hMask")
	$aicon[5] = DllStructGetData($tinfo, "hColor")
	Return $aicon
EndFunc

Func _winapi_getfilesizeex($hfile)
	Local $tsize
	$tsize = DllStructCreate("int64 Size")
	DllCall("Kernel32.dll", "int", "GetFileSizeEx", "hwnd", $hfile, "ptr", DllStructGetPtr($tsize))
	Return SetError(_winapi_getlasterror(), 0, DllStructGetData($tsize, "Size"))
EndFunc

Func _winapi_getlasterror()
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "GetLastError")
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getlasterrormessage()
	Local $ttext
	$ttext = DllStructCreate("char Text[4096]")
	_winapi_formatmessage($__winapconstant_format_message_from_system, 0, _winapi_getlasterror(), 0, DllStructGetPtr($ttext), 4096, 0)
	Return DllStructGetData($ttext, "Text")
EndFunc

Func _winapi_getmodulehandle($smodulename)
	Local $ttext, $aresult
	If $smodulename <> "" Then
		$ttext = DllStructCreate("char Text[4096]")
		DllStructSetData($ttext, "Text", $smodulename)
		$aresult = DllCall("Kernel32.dll", "hwnd", "GetModuleHandle", "ptr", DllStructGetPtr($ttext))
	Else
		$aresult = DllCall("Kernel32.dll", "hwnd", "GetModuleHandle", "ptr", 0)
	EndIf
	_winapi_check("_WinAPI_GetModuleHandle", ($aresult[0] = 0), 0, True)
	Return $aresult[0]
EndFunc

Func _winapi_getmousepos($ftoclient = False, $hwnd = 0)
	Local $imode, $apos, $tpoint
	$imode = Opt("MouseCoordMode", 1)
	$apos = MouseGetPos()
	Opt("MouseCoordMode", $imode)
	$tpoint = DllStructCreate($tagpoint)
	DllStructSetData($tpoint, "X", $apos[0])
	DllStructSetData($tpoint, "Y", $apos[1])
	If $ftoclient Then _winapi_screentoclient($hwnd, $tpoint)
	Return $tpoint
EndFunc

Func _winapi_getmouseposx($ftoclient = False, $hwnd = 0)
	Local $tpoint
	$tpoint = _winapi_getmousepos($ftoclient, $hwnd)
	Return DllStructGetData($tpoint, "X")
EndFunc

Func _winapi_getmouseposy($ftoclient = False, $hwnd = 0)
	Local $tpoint
	$tpoint = _winapi_getmousepos($ftoclient, $hwnd)
	Return DllStructGetData($tpoint, "Y")
EndFunc

Func _winapi_getobject($hobject, $isize, $pobject)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "int", "GetObject", "int", $hobject, "int", $isize, "ptr", $pobject)
	_winapi_check("_WinAPI_GetObject", ($aresult[0] = 0), 0, True)
	Return $aresult[0]
EndFunc

Func _winapi_getopenfilename($stitle = "", $sfilter = "All files (*.*)", $sinitaldir = ".", $sdefaultfile = "", $sdefaultext = "", $ifilterindex = 1, $iflags = 0, $iflagsex = 0, $hwndowner = 0)
	Local $ipathlen = 4096
	Local $inulls = 0
	Local $tofn = DllStructCreate($tagopenfilename)
	Local $afiles[1]
	Local $iflag = $iflags
	Local $asflines = StringSplit($sfilter, "|")
	Local $asfilter[$asflines[0] * 2 + 1]
	Local $i, $istart, $ifinal, $stfilter
	$asfilter[0] = $asflines[0] * 2
	For $i = 1 To $asflines[0]
		$istart = StringInStr($asflines[$i], "(", 0, 1)
		$ifinal = StringInStr($asflines[$i], ")", 0, -1)
		$asfilter[$i * 2 - 1] = StringStripWS(StringLeft($asflines[$i], $istart - 1), 3)
		$asfilter[$i * 2] = StringStripWS(StringTrimRight(StringTrimLeft($asflines[$i], $istart), StringLen($asflines[$i]) - $ifinal + 1), 3)
		$stfilter &= "char[" & StringLen($asfilter[$i * 2 - 1]) + 1 & "];char[" & StringLen($asfilter[$i * 2]) + 1 & "];"
	Next
	Local $ttitle = DllStructCreate("char Title[" & StringLen($stitle) + 1 & "]")
	Local $tinitialdir = DllStructCreate("char InitDir[" & StringLen($sinitaldir) + 1 & "]")
	Local $tfilter = DllStructCreate($stfilter & "char")
	Local $tpath = DllStructCreate("char Path[" & $ipathlen & "]")
	Local $textn = DllStructCreate("char Extension[" & StringLen($sdefaultext) + 1 & "]")
	For $i = 1 To $asfilter[0]
		DllStructSetData($tfilter, $i, $asfilter[$i])
	Next
	Local $iresult
	DllStructSetData($ttitle, "Title", $stitle)
	DllStructSetData($tinitialdir, "InitDir", $sinitaldir)
	DllStructSetData($tpath, "Path", $sdefaultfile)
	DllStructSetData($textn, "Extension", $sdefaultext)
	DllStructSetData($tofn, "StructSize", DllStructGetSize($tofn))
	DllStructSetData($tofn, "hwndOwner", $hwndowner)
	DllStructSetData($tofn, "lpstrFilter", DllStructGetPtr($tfilter))
	DllStructSetData($tofn, "nFilterIndex", $ifilterindex)
	DllStructSetData($tofn, "lpstrFile", DllStructGetPtr($tpath))
	DllStructSetData($tofn, "nMaxFile", $ipathlen)
	DllStructSetData($tofn, "lpstrInitialDir", DllStructGetPtr($tinitialdir))
	DllStructSetData($tofn, "lpstrTitle", DllStructGetPtr($ttitle))
	DllStructSetData($tofn, "Flags", $iflag)
	DllStructSetData($tofn, "lpstrDefExt", DllStructGetPtr($textn))
	DllStructSetData($tofn, "FlagsEx", $iflagsex)
	$iresult = DllCall("comdlg32.dll", "int", "GetOpenFileName", "ptr", DllStructGetPtr($tofn))
	If @error OR $iresult[0] = 0 Then Return SetError(@error, @extended, $afiles)
	If BitAND($iflags, $ofn_allowmultiselect) = $ofn_allowmultiselect AND BitAND($iflags, $ofn_explorer) = $ofn_explorer Then
		For $x = 1 To $ipathlen
			If DllStructGetData($tpath, "Path", $x) = Chr(0) Then
				DllStructSetData($tpath, "Path", "|", $x)
				$inulls += 1
			Else
				$inulls = 0
			EndIf
			If $inulls = 2 Then ExitLoop
		Next
		DllStructSetData($tpath, "Path", Chr(0), $x - 1)
		$afiles = StringSplit(DllStructGetData($tpath, "Path"), "|")
		If $afiles[0] = 1 Then Return _winapi_parsefiledialogpath(DllStructGetData($tpath, "Path"))
		Return StringSplit(DllStructGetData($tpath, "Path"), "|")
	ElseIf BitAND($iflags, $ofn_allowmultiselect) = $ofn_allowmultiselect Then
		$afiles = StringSplit(DllStructGetData($tpath, "Path"), " ")
		If $afiles[0] = 1 Then Return _winapi_parsefiledialogpath(DllStructGetData($tpath, "Path"))
		Return StringSplit(StringReplace(DllStructGetData($tpath, "Path"), " ", "|"), "|")
	Else
		Return _winapi_parsefiledialogpath(DllStructGetData($tpath, "Path"))
	EndIf
EndFunc

Func _winapi_getoverlappedresult($hfile, $poverlapped, ByRef $ibytes, $fwait = False)
	Local $pread, $tread, $aresult
	$tread = DllStructCreate("int Read")
	$pread = DllStructGetPtr($tread)
	$aresult = DllCall("Kernel32.dll", "int", "GetOverlappedResult", "int", $hfile, "ptr", $poverlapped, "ptr", $pread, "int", $fwait)
	$ibytes = DllStructGetData($tread, "Read")
	Return SetError(_winapi_getlasterror(), 0, $aresult[0] <> 0)
EndFunc

Func _winapi_getparent($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "GetParent", "hwnd", $hwnd)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getprocessaffinitymask($hprocess)
	Local $pprocess, $tprocess, $psystem, $tsystem, $aresult, $amask[3]
	$tprocess = DllStructCreate("int Data")
	$pprocess = DllStructGetPtr($tprocess)
	$tsystem = DllStructCreate("int Data")
	$psystem = DllStructGetPtr($tsystem)
	$aresult = DllCall("Kernel32.dll", "int", "GetProcessAffinityMask", "hwnd", $hprocess, "ptr", $pprocess, "ptr", $psystem)
	If @error Then Return SetError(@error, 0, $amask)
	$amask[0] = $aresult[0] <> 0
	$amask[1] = DllStructGetData($tprocess, "Data")
	$amask[2] = DllStructGetData($tsystem, "Data")
	Return $amask
EndFunc

Func _winapi_getsavefilename($stitle = "", $sfilter = "All files (*.*)", $sinitaldir = ".", $sdefaultfile = "", $sdefaultext = "", $ifilterindex = 1, $iflags = 0, $iflagsex = 0, $hwndowner = 0)
	Local $ipathlen = 4096
	Local $tofn = DllStructCreate($tagopenfilename)
	Local $afiles[1]
	Local $iflag = $iflags
	Local $asflines = StringSplit($sfilter, "|")
	Local $asfilter[$asflines[0] * 2 + 1]
	Local $i, $istart, $ifinal, $stfilter
	$asfilter[0] = $asflines[0] * 2
	For $i = 1 To $asflines[0]
		$istart = StringInStr($asflines[$i], "(", 0, 1)
		$ifinal = StringInStr($asflines[$i], ")", 0, -1)
		$asfilter[$i * 2 - 1] = StringStripWS(StringLeft($asflines[$i], $istart - 1), 3)
		$asfilter[$i * 2] = StringStripWS(StringTrimRight(StringTrimLeft($asflines[$i], $istart), StringLen($asflines[$i]) - $ifinal + 1), 3)
		$stfilter &= "char[" & StringLen($asfilter[$i * 2 - 1]) + 1 & "];char[" & StringLen($asfilter[$i * 2]) + 1 & "];"
	Next
	Local $ttitle = DllStructCreate("char Title[" & StringLen($stitle) + 1 & "]")
	Local $tinitialdir = DllStructCreate("char InitDir[" & StringLen($sinitaldir) + 1 & "]")
	Local $tfilter = DllStructCreate($stfilter & "char")
	Local $tpath = DllStructCreate("char Path[" & $ipathlen & "]")
	Local $textn = DllStructCreate("char Extension[" & StringLen($sdefaultext) + 1 & "]")
	For $i = 1 To $asfilter[0]
		DllStructSetData($tfilter, $i, $asfilter[$i])
	Next
	Local $iresult
	DllStructSetData($ttitle, "Title", $stitle)
	DllStructSetData($tinitialdir, "InitDir", $sinitaldir)
	DllStructSetData($tpath, "Path", $sdefaultfile)
	DllStructSetData($textn, "Extension", $sdefaultext)
	DllStructSetData($tofn, "StructSize", DllStructGetSize($tofn))
	DllStructSetData($tofn, "hwndOwner", $hwndowner)
	DllStructSetData($tofn, "lpstrFilter", DllStructGetPtr($tfilter))
	DllStructSetData($tofn, "nFilterIndex", $ifilterindex)
	DllStructSetData($tofn, "lpstrFile", DllStructGetPtr($tpath))
	DllStructSetData($tofn, "nMaxFile", $ipathlen)
	DllStructSetData($tofn, "lpstrInitialDir", DllStructGetPtr($tinitialdir))
	DllStructSetData($tofn, "lpstrTitle", DllStructGetPtr($ttitle))
	DllStructSetData($tofn, "Flags", $iflag)
	DllStructSetData($tofn, "lpstrDefExt", DllStructGetPtr($textn))
	DllStructSetData($tofn, "FlagsEx", $iflagsex)
	$iresult = DllCall("comdlg32.dll", "int", "GetSaveFileName", "ptr", DllStructGetPtr($tofn))
	If @error OR $iresult[0] = 0 Then Return SetError(@error, @extended, $afiles)
	Return _winapi_parsefiledialogpath(DllStructGetData($tpath, "Path"))
EndFunc

Func _winapi_getstockobject($iobject)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "hwnd", "GetStockObject", "int", $iobject)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getstdhandle($istdhandle)
	Local $ahandle[3] = [-10, -11, -12], $aresult
	$aresult = DllCall("Kernel32.dll", "int", "GetStdHandle", "int", $ahandle[$istdhandle])
	Return SetError(_winapi_getlasterror(), 0, $aresult[0])
EndFunc

Func _winapi_getsyscolor($iindex)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "GetSysColor", "int", $iindex)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getsyscolorbrush($iindex)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "GetSysColorBrush", "int", $iindex)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getsystemmetrics($iindex)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "GetSystemMetrics", "int", $iindex)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_gettextextentpoint32($hdc, $stext)
	Local $tsize, $isize, $aresult
	$tsize = DllStructCreate($tagsize)
	$isize = StringLen($stext)
	$aresult = DllCall("GDI32.dll", "int", "GetTextExtentPoint32", "hwnd", $hdc, "str", $stext, "int", $isize, "ptr", DllStructGetPtr($tsize))
	_winapi_check("_WinAPI_GetTextExtentPoint32", ($aresult[0] = 0), 0, True)
	Return $tsize
EndFunc

Func _winapi_getwindow($hwnd, $icmd)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "GetWindow", "hwnd", $hwnd, "int", $icmd)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getwindowdc($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "GetWindowDC", "hwnd", $hwnd)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getwindowheight($hwnd)
	Local $trect
	$trect = _winapi_getwindowrect($hwnd)
	Return DllStructGetData($trect, "Bottom") - DllStructGetData($trect, "Top")
EndFunc

Func _winapi_getwindowlong($hwnd, $iindex)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "GetWindowLong", "hwnd", $hwnd, "int", $iindex)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getwindowplacement($hwnd)
	Local $twindowplacement = DllStructCreate($tagwindowplacement)
	DllStructSetData($twindowplacement, "length", DllStructGetSize($twindowplacement))
	Local $pwindowplacement = DllStructGetPtr($twindowplacement)
	Local $avret = DllCall("user32.dll", "int", "GetWindowPlacement", "hwnd", $hwnd, "ptr", $pwindowplacement)
	If @error Then Return SetError(@error, 0, 0)
	If $avret[0] Then
		Return $twindowplacement
	Else
		Return SetError(1, _winapi_getlasterror(), 0)
	EndIf
EndFunc

Func _winapi_getwindowrect($hwnd)
	Local $trect
	$trect = DllStructCreate($tagrect)
	DllCall("User32.dll", "int", "GetWindowRect", "hwnd", $hwnd, "ptr", DllStructGetPtr($trect))
	If @error Then Return SetError(@error, 0, $trect)
	Return $trect
EndFunc

Func _winapi_getwindowrgn($hwnd, $hrgn)
	Local $aresult = DllCall("user32.dll", "int", "GetWindowRgn", "hwnd", $hwnd, "hwnd", $hrgn)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_getwindowtext($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "GetWindowText", "hwnd", $hwnd, "str", "", "int", 4096)
	If @error Then Return SetError(@error, 0, "")
	Return $aresult[2]
EndFunc

Func _winapi_getwindowthreadprocessid($hwnd, ByRef $ipid)
	Local $ppid, $tpid, $aresult
	$tpid = DllStructCreate("int ID")
	$ppid = DllStructGetPtr($tpid)
	$aresult = DllCall("User32.dll", "int", "GetWindowThreadProcessId", "hwnd", $hwnd, "ptr", $ppid)
	If @error Then Return SetError(@error, 0, 0)
	$ipid = DllStructGetData($tpid, "ID")
	Return $aresult[0]
EndFunc

Func _winapi_getwindowwidth($hwnd)
	Local $trect
	$trect = _winapi_getwindowrect($hwnd)
	Return DllStructGetData($trect, "Right") - DllStructGetData($trect, "Left")
EndFunc

Func _winapi_getxyfrompoint(ByRef $tpoint, ByRef $ix, ByRef $iy)
	$ix = DllStructGetData($tpoint, "X")
	$iy = DllStructGetData($tpoint, "Y")
EndFunc

Func _winapi_globalmemstatus()
	Local $imem, $pmem, $tmem, $amem[7]
	$tmem = DllStructCreate("int;int;int;int;int;int;int;int;int")
	$pmem = DllStructGetPtr($tmem)
	$imem = DllStructGetSize($tmem)
	DllStructSetData($tmem, 1, $imem)
	DllCall("Kernel32.dll", "none", "GlobalMemStatus", "ptr", $pmem)
	If @error Then Return SetError(@error, 0, $amem)
	$amem[0] = DllStructGetData($tmem, 2)
	$amem[1] = DllStructGetData($tmem, 3)
	$amem[2] = DllStructGetData($tmem, 4)
	$amem[3] = DllStructGetData($tmem, 5)
	$amem[4] = DllStructGetData($tmem, 6)
	$amem[5] = DllStructGetData($tmem, 7)
	$amem[6] = DllStructGetData($tmem, 8)
	Return $amem
EndFunc

Func _winapi_guidfromstring($sguid)
	Local $tguid
	$tguid = DllStructCreate($tagguid)
	_winapi_guidfromstringex($sguid, DllStructGetPtr($tguid))
	Return SetError(@error, 0, $tguid)
EndFunc

Func _winapi_guidfromstringex($sguid, $pguid)
	Local $tdata, $aresult
	$tdata = _winapi_multibytetowidechar($sguid)
	$aresult = DllCall("Ole32.dll", "int", "CLSIDFromString", "ptr", DllStructGetPtr($tdata), "ptr", $pguid)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_hiword($ilong)
	Return BitShift($ilong, 16)
EndFunc

Func _winapi_inprocess($hwnd, ByRef $hlastwnd)
	Local $ii, $icount, $iprocessid
	If $hwnd = $hlastwnd Then Return True
	For $ii = $winapi_gainprocess[0][0] To 1 Step -1
		If $hwnd = $winapi_gainprocess[$ii][0] Then
			If $winapi_gainprocess[$ii][1] Then
				$hlastwnd = $hwnd
				Return True
			Else
				Return False
			EndIf
		EndIf
	Next
	_winapi_getwindowthreadprocessid($hwnd, $iprocessid)
	$icount = $winapi_gainprocess[0][0] + 1
	If $icount >= 64 Then $icount = 1
	$winapi_gainprocess[0][0] = $icount
	$winapi_gainprocess[$icount][0] = $hwnd
	$winapi_gainprocess[$icount][1] = ($iprocessid = @AutoItPID)
	Return $winapi_gainprocess[$icount][1]
EndFunc

Func _winapi_inttofloat($iint)
	Local $tfloat, $tint
	$tint = DllStructCreate("int")
	$tfloat = DllStructCreate("float", DllStructGetPtr($tint))
	DllStructSetData($tint, 1, $iint)
	Return DllStructGetData($tfloat, 1)
EndFunc

Func _winapi_isclassname($hwnd, $sclassname)
	Local $sseperator, $aclassname, $sclasscheck
	$sseperator = Opt("GUIDataSeparatorChar")
	$aclassname = StringSplit($sclassname, $sseperator)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	$sclasscheck = _winapi_getclassname($hwnd)
	For $x = 1 To UBound($aclassname) - 1
		If StringUpper(StringMid($sclasscheck, 1, StringLen($aclassname[$x]))) = StringUpper($aclassname[$x]) Then
			Return True
		EndIf
	Next
	Return False
EndFunc

Func _winapi_iswindow($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "IsWindow", "hwnd", $hwnd)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_iswindowvisible($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "IsWindowVisible", "hwnd", $hwnd)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_invalidaterect($hwnd, $trect = 0, $ferase = True)
	Local $prect, $aresult
	If $trect <> 0 Then $prect = DllStructGetPtr($trect)
	$aresult = DllCall("User32.dll", "int", "InvalidateRect", "hwnd", $hwnd, "ptr", $prect, "int", $ferase)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_lineto($hdc, $ix, $iy)
	Local $aresult = DllCall("gdi32.dll", "int", "LineTo", "int", $hdc, "int", $ix, "int", $iy)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_loadbitmap($hinstance, $sbitmap)
	Local $aresult, $stype = "int"
	If IsString($sbitmap) Then $stype = "str"
	$aresult = DllCall("User32.dll", "hwnd", "LoadBitmap", "hwnd", $hinstance, $stype, $sbitmap)
	_winapi_check("_WinAPI_LoadBitmap", ($aresult[0] = 0), 0, True)
	Return $aresult[0]
EndFunc

Func _winapi_loadimage($hinstance, $simage, $itype, $ixdesired, $iydesired, $iload)
	Local $aresult, $stype = "int"
	If IsString($simage) Then $stype = "str"
	$aresult = DllCall("User32.dll", "hwnd", "LoadImage", "hwnd", $hinstance, $stype, $simage, "int", $itype, "int", $ixdesired, "int", $iydesired, "int", $iload)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_loadlibrary($sfilename)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "hwnd", "LoadLibraryA", "str", $sfilename)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_loadlibraryex($sfilename, $iflags = 0)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "hwnd", "LoadLibraryExA", "str", $sfilename, "hwnd", 0, "int", $iflags)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_loadshell32icon($iiconid)
	Local $iicons, $ticons, $picons
	$ticons = DllStructCreate("int Data")
	$picons = DllStructGetPtr($ticons)
	$iicons = _winapi_extracticonex("Shell32.dll", $iiconid, 0, $picons, 1)
	_winapi_check("_Lib_GetShell32Icon", ($iicons = 0), -1)
	Return DllStructGetData($ticons, "Data")
EndFunc

Func _winapi_loadstring($hinstance, $istringid)
	Local $iresult, $ibuffermax = 4096
	$iresult = DllCall("user32.dll", "int", "LoadString", "hwnd", $hinstance, "uint", $istringid, "str", "", "int", $ibuffermax)
	If @error OR NOT IsArray($iresult) OR $iresult[0] = 0 Then Return SetError(-1, -1, "")
	Return SetError(0, $iresult[0], $iresult[3])
EndFunc

Func _winapi_localfree($hmem)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "hwnd", "LocalFree", "hwnd", $hmem)
	_winapi_check("_WinAPI_LocalFree", ($aresult[0] <> 0), 0, True)
	Return $aresult[0] = 0
EndFunc

Func _winapi_loword($ilong)
	Return BitAND($ilong, 65535)
EndFunc

Func _winapi_makedword($hiword, $loword)
	Return BitOR($loword * 65536, BitAND($hiword, 65535))
EndFunc

Func _winapi_makelangid($lgidprimary, $lgidsub)
	Return BitOR(BitShift($lgidsub, -10), $lgidprimary)
EndFunc

Func _winapi_makelcid($lgid, $srtid)
	Return BitOR(BitShift($srtid, -16), $lgid)
EndFunc

Func _winapi_makelong($ilo, $ihi)
	Return BitOR(BitShift($ihi, -16), BitAND($ilo, 65535))
EndFunc

Func _winapi_messagebeep($itype = 1)
	Local $isound, $aresult
	Switch $itype
		Case 1
			$isound = 0
		Case 2
			$isound = 16
		Case 3
			$isound = 32
		Case 4
			$isound = 48
		Case 5
			$isound = 64
		Case Else
			$isound = -1
	EndSwitch
	$aresult = DllCall("User32.dll", "int", "MessageBeep", "uint", $isound)
	Return SetError(_winapi_getlasterror(), 0, $aresult[0] <> 0)
EndFunc

Func _winapi_msgbox($iflags, $stitle, $stext)
	BlockInput(0)
	MsgBox($iflags, $stitle, $stext & "      ")
EndFunc

Func _winapi_mouse_event($iflags, $ix = 0, $iy = 0, $idata = 0, $iextrainfo = 0)
	DllCall("User32.dll", "none", "mouse_event", "int", $iflags, "int", $ix, "int", $iy, "int", $idata, "int", $iextrainfo)
EndFunc

Func _winapi_moveto($hdc, $ix, $iy)
	Local $aresult = DllCall("gdi32.dll", "int", "MoveToEx", "int", $hdc, "int", $ix, "int", $iy, "ptr", 0)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_movewindow($hwnd, $ix, $iy, $iwidth, $iheight, $frepaint = True)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "MoveWindow", "hwnd", $hwnd, "int", $ix, "int", $iy, "int", $iwidth, "int", $iheight, "int", $frepaint)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_muldiv($inumber, $inumerator, $idenominator)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "MulDiv", "int", $inumber, "int", $inumerator, "int", $idenominator)
	_winapi_check("_MultDiv", ($aresult[0] = -1), -1)
	Return $aresult[0]
EndFunc

Func _winapi_multibytetowidechar($stext, $icodepage = 0, $iflags = 0)
	Local $itext, $ptext, $ttext
	$itext = StringLen($stext) + 1
	$ttext = DllStructCreate("byte[" & $itext * 2 & "]")
	$ptext = DllStructGetPtr($ttext)
	DllCall("Kernel32.dll", "int", "MultiByteToWideChar", "int", $icodepage, "int", $iflags, "str", $stext, "int", $itext, "ptr", $ptext, "int", $itext * 2)
	If @error Then Return SetError(@error, 0, $ttext)
	Return $ttext
EndFunc

Func _winapi_multibytetowidecharex($stext, $ptext, $icodepage = 0, $iflags = 0)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "MultiByteToWideChar", "int", $icodepage, "int", $iflags, "str", $stext, "int", -1, "ptr", $ptext, "int", (StringLen($stext) + 1) * 2)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_openprocess($iaccess, $finherit, $iprocessid, $fdebugpriv = False)
	Local $htoken, $aresult
	$aresult = DllCall("Kernel32.dll", "int", "OpenProcess", "int", $iaccess, "int", $finherit, "int", $iprocessid)
	If NOT $fdebugpriv OR ($aresult[0] <> 0) Then
		_winapi_check("_WinAPI_OpenProcess:Standard", ($aresult[0] = 0), 0, True)
		Return $aresult[0]
	EndIf
	$htoken = _security__openthreadtokenex(BitOR($__winapconstant_token_adjust_privileges, $__winapconstant_token_query))
	_winapi_check("_WinAPI_OpenProcess:OpenThreadTokenEx", @error, @extended)
	_security__setprivilege($htoken, "SeDebugPrivilege", True)
	_winapi_check("_WinAPI_OpenProcess:SetPrivilege:Enable", @error, @extended)
	$aresult = DllCall("Kernel32.dll", "int", "OpenProcess", "int", $iaccess, "int", $finherit, "int", $iprocessid)
	_winapi_check("_WinAPI_OpenProcess:Priviliged", ($aresult[0] = 0), 0, True)
	_security__setprivilege($htoken, "SeDebugPrivilege", False)
	_winapi_check("_WinAPI_OpenProcess:SetPrivilege:Disable", @error, @extended)
	_winapi_closehandle($htoken)
	Return $aresult[0]
EndFunc

Func _winapi_parsefiledialogpath($spath)
	Local $afiles[3], $stemp
	$afiles[0] = 2
	$stemp = StringMid($spath, 1, StringInStr($spath, "\", 0, -1) - 1)
	$afiles[1] = $stemp
	$afiles[2] = StringMid($spath, StringInStr($spath, "\", 0, -1) + 1)
	Return $afiles
EndFunc

Func _winapi_pointfromrect(ByRef $trect, $fcenter = True)
	Local $ix1, $iy1, $ix2, $iy2, $tpoint
	$ix1 = DllStructGetData($trect, "Left")
	$iy1 = DllStructGetData($trect, "Top")
	$ix2 = DllStructGetData($trect, "Right")
	$iy2 = DllStructGetData($trect, "Bottom")
	If $fcenter Then
		$ix1 = $ix1 + (($ix2 - $ix1) / 2)
		$iy1 = $iy1 + (($iy2 - $iy1) / 2)
	EndIf
	$tpoint = DllStructCreate($tagpoint)
	DllStructSetData($tpoint, "X", $ix1)
	DllStructSetData($tpoint, "Y", $iy1)
	Return $tpoint
EndFunc

Func _winapi_postmessage($hwnd, $imsg, $iwparam, $ilparam)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "PostMessageA", "hwnd", $hwnd, "int", $imsg, "int", $iwparam, "int", $ilparam)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_primarylangid($lgid)
	Return BitAND($lgid, 1023)
EndFunc

Func _winapi_ptinrect(ByRef $trect, ByRef $tpoint)
	Local $ix, $iy, $aresult
	$ix = DllStructGetData($tpoint, "X")
	$iy = DllStructGetData($tpoint, "Y")
	$aresult = DllCall("User32.dll", "int", "PtInRect", "ptr", DllStructGetPtr($trect), "int", $ix, "int", $iy)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_readfile($hfile, $pbuffer, $itoread, ByRef $iread, $poverlapped = 0)
	Local $aresult, $pread, $tread
	$tread = DllStructCreate("int Read")
	$pread = DllStructGetPtr($tread)
	$aresult = DllCall("Kernel32.dll", "int", "ReadFile", "hwnd", $hfile, "ptr", $pbuffer, "int", $itoread, "ptr", $pread, "ptr", $poverlapped)
	$iread = DllStructGetData($tread, "Read")
	Return SetError(_winapi_getlasterror(), 0, $aresult[0] <> 0)
EndFunc

Func _winapi_readprocessmemory($hprocess, $pbaseaddress, $pbuffer, $isize, ByRef $iread)
	Local $pread, $tread, $aresult
	$tread = DllStructCreate("int Read")
	$pread = DllStructGetPtr($tread)
	$aresult = DllCall("Kernel32.dll", "int", "ReadProcessMemory", "int", $hprocess, "int", $pbaseaddress, "ptr", $pbuffer, "int", $isize, "ptr", $pread)
	_winapi_check("_WinAPI_ReadProcessMemory", ($aresult[0] = 0), 0, True)
	$iread = DllStructGetData($tread, "Read")
	Return $aresult[0]
EndFunc

Func _winapi_rectisempty(ByRef $trect)
	Return (DllStructGetData($trect, "Left") = 0) AND (DllStructGetData($trect, "Top") = 0) AND (DllStructGetData($trect, "Right") = 0) AND (DllStructGetData($trect, "Bottom") = 0)
EndFunc

Func _winapi_redrawwindow($hwnd, $trect = 0, $hregion = 0, $iflags = 5)
	Local $prect, $aresult
	If $trect <> 0 Then $prect = DllStructGetPtr($trect)
	$aresult = DllCall("User32.dll", "int", "RedrawWindow", "hwnd", $hwnd, "ptr", $prect, "int", $hregion, "int", $iflags)
	If @error Then Return SetError(@error, 0, False)
	Return ($aresult[0] <> 0)
EndFunc

Func _winapi_registerwindowmessage($smessage)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "RegisterWindowMessage", "str", $smessage)
	_winapi_check("_WinAPI_RegisterWindowMessage", ($aresult[0] = 0), 0, True)
	Return $aresult[0]
EndFunc

Func _winapi_releasecapture()
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "ReleaseCapture")
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_releasedc($hwnd, $hdc)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "ReleaseDC", "hwnd", $hwnd, "hwnd", $hdc)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_screentoclient($hwnd, ByRef $tpoint)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "ScreenToClient", "hwnd", $hwnd, "ptr", DllStructGetPtr($tpoint))
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_selectobject($hdc, $hgdiobj)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "hwnd", "SelectObject", "hwnd", $hdc, "hwnd", $hgdiobj)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_setbkcolor($hdc, $icolor)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "int", "SetBkColor", "hwnd", $hdc, "int", $icolor)
	If @error Then Return SetError(@error, 0, 65535)
	Return $aresult[0]
EndFunc

Func _winapi_setbkmode($hdc, $ibkmode)
	Local $aresult = DllCall("gdi32.dll", "int", "SetBkMode", "ptr", $hdc, "int", $ibkmode)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_setcapture($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "SetCapture", "hwnd", $hwnd)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_setcursor($hcursor)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "SetCursor", "hwnd", $hcursor)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_setdefaultprinter($sprinter)
	Local $aresult
	$aresult = DllCall("WinSpool.drv", "int", "SetDefaultPrinterA", "str", $sprinter)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aresult[0] = 0, 0, $aresult[0] <> 0)
EndFunc

Func _winapi_setdibits($hdc, $hbmp, $istartscan, $iscanlines, $pbits, $pbmi, $icoloruse = 0)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "int", "SetDIBits", "hwnd", $hdc, "hwnd", $hbmp, "uint", $istartscan, "uint", $iscanlines, "ptr", $pbits, "ptr", $pbmi, "uint", $icoloruse)
	If @error Then Return SetError(@error, 0, False)
	Return SetError($aresult[0] = 0, _winapi_getlasterror(), $aresult[0] <> 0)
EndFunc

Func _winapi_setendoffile($hfile)
	Local $aresult
	$aresult = DllCall("kernel32.dll", "int", "SetEndOfFile", "hwnd", $hfile)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_setevent($hevent)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "SetEvent", "hwnd", $hevent)
	Return SetError(_winapi_getlasterror(), 0, $aresult[0] <> 0)
EndFunc

Func _winapi_setfilepointer($hfile, $ipos, $imethod = 0)
	Local $aresult
	$aresult = DllCall("kernel32.dll", "long", "SetFilePointer", "hwnd", $hfile, "long", $ipos, "long_ptr", 0, "long", $imethod)
	If @error Then Return SetError(1, 0, -1)
	If $aresult[0] = $__winapconstant_invalid_set_file_pointer Then Return SetError(2, 0, -1)
	Return $aresult[0]
EndFunc

Func _winapi_setfocus($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "SetFocus", "hwnd", $hwnd)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_setfont($hwnd, $hfont, $fredraw = True)
	_sendmessage($hwnd, $__winapconstant_wm_setfont, $hfont, $fredraw, 0, "hwnd")
EndFunc

Func _winapi_sethandleinformation($hobject, $imask, $iflags)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "SetHandleInformation", "hwnd", $hobject, "uint", $imask, "uint", $iflags)
	_winapi_check("_WinAPI_SetHandleInformation", $aresult[0] = 0, 0, True)
	Return $aresult[0]
EndFunc

Func _winapi_setlasterror($ierrcode)
	DllCall("Kernel32.dll", "none", "SetLastError", "dword", $ierrcode)
EndFunc

Func _winapi_setparent($hwndchild, $hwndparent)
	Local $aresult
	$aresult = DllCall("User32.dll", "hwnd", "SetParent", "hwnd", $hwndchild, "hwnd", $hwndparent)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_setprocessaffinitymask($hprocess, $imask)
	Local $iresult
	$iresult = DllCall("Kernel32.dll", "int", "SetProcessAffinityMask", "hwnd", $hprocess, "int", $imask)
	_winapi_check("_WinAPI_SetProcessAffinityMask", ($iresult[0] = 0), 0, True)
	Return $iresult[0] <> 0
EndFunc

Func _winapi_setsyscolors($velements, $vcolors)
	Local $isearray = IsArray($velements), $iscarray = IsArray($vcolors)
	Local $ielementnum
	If NOT $iscarray AND NOT $isearray Then
		$ielementnum = 1
	ElseIf $iscarray OR $isearray Then
		If NOT $iscarray OR NOT $isearray Then Return SetError(-1, -1, False)
		If UBound($velements) <> UBound($vcolors) Then Return SetError(-1, -1, False)
		$ielementnum = UBound($velements)
	EndIf
	Local $telements = DllStructCreate("int Element[" & $ielementnum & "]")
	Local $tcolors = DllStructCreate("int NewColor[" & $ielementnum & "]")
	Local $pelements = DllStructGetPtr($telements)
	Local $pcolors = DllStructGetPtr($tcolors)
	If NOT $isearray Then
		DllStructSetData($telements, "Element", $velements, 1)
	Else
		For $x = 0 To $ielementnum - 1
			DllStructSetData($telements, "Element", $velements[$x], $x + 1)
		Next
	EndIf
	If NOT $iscarray Then
		DllStructSetData($tcolors, "NewColor", $vcolors, 1)
	Else
		For $x = 0 To $ielementnum - 1
			DllStructSetData($tcolors, "NewColor", $vcolors[$x], $x + 1)
		Next
	EndIf
	Local $iresults = DllCall("user32.dll", "int", "SetSysColors", "int", $ielementnum, "ptr", $pelements, "ptr", $pcolors)
	If @error Then Return SetError(-1, -1, False)
	Return $iresults[0] <> 0
EndFunc

Func _winapi_settextcolor($hdc, $icolor)
	Local $aresult
	$aresult = DllCall("GDI32.dll", "int", "SetTextColor", "hwnd", $hdc, "int", $icolor)
	If @error Then Return SetError(@error, 0, 65535)
	Return $aresult[0]
EndFunc

Func _winapi_setwindowlong($hwnd, $iindex, $ivalue)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "SetWindowLong", "hwnd", $hwnd, "int", $iindex, "int", $ivalue)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_setwindowplacement($hwnd, $pwindowplacement)
	Local $avret = DllCall("user32.dll", "int", "SetWindowPlacement", "hwnd", $hwnd, "ptr", $pwindowplacement)
	If @error Then Return SetError(@error, _winapi_getlasterror(), 0)
	If $avret[0] Then
		Return $avret[0]
	Else
		Return SetError(1, _winapi_getlasterror(), 0)
	EndIf
EndFunc

Func _winapi_setwindowpos($hwnd, $hafter, $ix, $iy, $icx, $icy, $iflags)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "SetWindowPos", "hwnd", $hwnd, "hwnd", $hafter, "int", $ix, "int", $iy, "int", $icx, "int", $icy, "int", $iflags)
	_winapi_check("_WinAPI_SetWindowPos", ($aresult[0] = 0), 0, True)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_setwindowrgn($hwnd, $hrgn, $bredraw = True)
	Local $aresult = DllCall("user32.dll", "int", "SetWindowRgn", "hwnd", $hwnd, "hwnd", $hrgn, "int", $bredraw)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_setwindowshookex($idhook, $lpfn, $hmod, $dwthreadid = 0)
	Local $hwndhook = DllCall("user32.dll", "hwnd", "SetWindowsHookEx", "int", $idhook, "ptr", $lpfn, "hwnd", $hmod, "dword", $dwthreadid)
	If @error Then Return SetError(@error, @extended, 0)
	Return $hwndhook[0]
EndFunc

Func _winapi_setwindowtext($hwnd, $stext)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "SetWindowText", "hwnd", $hwnd, "str", $stext)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_showcursor($fshow)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "ShowCursor", "int", $fshow)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_showerror($stext, $fexit = True)
	_winapi_msgbox(266256, "Error", $stext)
	If $fexit Then Exit
EndFunc

Func _winapi_showmsg($stext)
	_winapi_msgbox(64 + 4096, "Information", $stext)
EndFunc

Func _winapi_showwindow($hwnd, $icmdshow = 5)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "ShowWindow", "hwnd", $hwnd, "int", $icmdshow)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_stringfromguid($pguid)
	Local $aresult
	$aresult = DllCall("Ole32.dll", "int", "StringFromGUID2", "ptr", $pguid, "wstr", "", "int", 40)
	If @error Then Return SetError(@error, 0, 0)
	Return SetError($aresult[0] <> 0, 0, $aresult[2])
EndFunc

Func _winapi_sublangid($lgid)
	Return BitShift($lgid, 10)
EndFunc

Func _winapi_systemparametersinfo($iaction, $iparam = 0, $vparam = 0, $iwinini = 0)
	Local $aresult
	$aresult = DllCall("user32.dll", "int", "SystemParametersInfo", "int", $iaction, "int", $iparam, "int", $vparam, "int", $iwinini)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_twipsperpixelx()
	Local $lngdc, $twipsperpixelx
	$lngdc = _winapi_getdc(0)
	$twipsperpixelx = 1440 / _winapi_getdevicecaps($lngdc, $__winapconstant_logpixelsx)
	_winapi_releasedc(0, $lngdc)
	Return $twipsperpixelx
EndFunc

Func _winapi_twipsperpixely()
	Local $lngdc, $twipsperpixely
	$lngdc = _winapi_getdc(0)
	$twipsperpixely = 1440 / _winapi_getdevicecaps($lngdc, $__winapconstant_logpixelsy)
	_winapi_releasedc(0, $lngdc)
	Return $twipsperpixely
EndFunc

Func _winapi_unhookwindowshookex($hhk)
	Local $iresult = DllCall("user32.dll", "int", "UnhookWindowsHookEx", "hwnd", $hhk)
	If @error Then Return SetError(@error, @extended, 0)
	Return $iresult[0] <> 0
EndFunc

Func _winapi_updatelayeredwindow($hwnd, $hdcdest, $pptdest, $psize, $hdcsrce, $pptsrce, $irgb, $pblend, $iflags)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "UpdateLayeredWindow", "hwnd", $hwnd, "hwnd", $hdcdest, "ptr", $pptdest, "ptr", $psize, "hwnd", $hdcsrce, "ptr", $pptsrce, "int", $irgb, "ptr", $pblend, "int", $iflags)
	If @error Then Return SetError(1, 0, False)
	Return SetError($aresult[0] = 0, 0, $aresult[0] <> 0)
EndFunc

Func _winapi_updatewindow($hwnd)
	Local $aresult
	$aresult = DllCall("User32.dll", "int", "UpdateWindow", "hwnd", $hwnd)
	If @error Then Return SetError(@error, 0, False)
	Return $aresult[0] <> 0
EndFunc

Func _winapi_waitforinputidle($hprocess, $itimeout = -1)
	Local $aresult
	$aresult = DllCall("User32.dll", "dword", "WaitForInputIdle", "hwnd", $hprocess, "dword", $itimeout)
	Return SetError(_winapi_getlasterror(), 0, $aresult[0] = 0)
EndFunc

Func _winapi_waitformultipleobjects($icount, $phandles, $fwaitall = False, $itimeout = -1)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "WaitForMultipleObjects", "int", $icount, "ptr", $phandles, "int", $fwaitall, "int", $itimeout)
	Return SetError(_winapi_getlasterror(), 0, $aresult[0])
EndFunc

Func _winapi_waitforsingleobject($hhandle, $itimeout = -1)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "WaitForSingleObject", "hwnd", $hhandle, "int", $itimeout)
	Return SetError(_winapi_getlasterror(), 0, $aresult[0])
EndFunc

Func _winapi_widechartomultibyte($punicode, $icodepage = 0)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "WideCharToMultiByte", "int", $icodepage, "int", 0, "ptr", $punicode, "int", -1, "str", "", "int", 0, "int", 0, "int", 0)
	If @error Then Return SetError(@error, 0, "")
	$aresult = DllCall("Kernel32.dll", "int", "WideCharToMultiByte", "int", $icodepage, "int", 0, "ptr", $punicode, "int", -1, "str", "", "int", $aresult[0], "int", 0, "int", 0)
	If @error Then Return SetError(@error, 0, "")
	Return $aresult[5]
EndFunc

Func _winapi_windowfrompoint(ByRef $tpoint)
	Local $ix, $iy, $aresult
	$ix = DllStructGetData($tpoint, "X")
	$iy = DllStructGetData($tpoint, "Y")
	$aresult = DllCall("User32.dll", "hwnd", "WindowFromPoint", "int", $ix, "int", $iy)
	If @error Then Return SetError(@error, 0, 0)
	Return $aresult[0]
EndFunc

Func _winapi_writeconsole($hconsole, $stext)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "WriteConsole", "int", $hconsole, "str", $stext, "int", StringLen($stext), "int*", 0, "int", 0)
	Return SetError(_winapi_getlasterror(), 0, $aresult[0] <> 0)
EndFunc

Func _winapi_writefile($hfile, $pbuffer, $itowrite, ByRef $iwritten, $poverlapped = 0)
	Local $pwritten, $twritten, $aresult
	$twritten = DllStructCreate("int Written")
	$pwritten = DllStructGetPtr($twritten)
	$aresult = DllCall("Kernel32.dll", "int", "WriteFile", "hwnd", $hfile, "ptr", $pbuffer, "uint", $itowrite, "ptr", $pwritten, "ptr", $poverlapped)
	$iwritten = DllStructGetData($twritten, "Written")
	Return SetError(_winapi_getlasterror(), 0, $aresult[0] <> 0)
EndFunc

Func _winapi_writeprocessmemory($hprocess, $pbaseaddress, $pbuffer, $isize, ByRef $iwritten, $sbuffer = "ptr")
	Local $pwritten, $twritten, $aresult
	$twritten = DllStructCreate("int Written")
	$pwritten = DllStructGetPtr($twritten)
	$aresult = DllCall("Kernel32.dll", "int", "WriteProcessMemory", "int", $hprocess, "int", $pbaseaddress, $sbuffer, $pbuffer, "int", $isize, "int", $pwritten)
	_winapi_check("_WinAPI_WriteProcessMemory", ($aresult[0] = 0), 0, True)
	$iwritten = DllStructGetData($twritten, "Written")
	Return $aresult[0]
EndFunc

Func _winapi_validateclassname($hwnd, $sclassnames)
	Local $aclassnames, $sseperator = Opt("GUIDataSeparatorChar"), $stext
	If NOT _winapi_isclassname($hwnd, $sclassnames) Then
		$aclassnames = StringSplit($sclassnames, $sseperator)
		For $x = 1 To $aclassnames[0]
			$stext &= $aclassnames[$x] & ", "
		Next
		$stext = StringTrimRight($stext, 2)
		_winapi_showerror("Invalid Class Type(s):" & @LF & @TAB & "Expecting Type(s): " & $stext & @LF & @TAB & "Received Type : " & _winapi_getclassname($hwnd))
	EndIf
EndFunc

Global Const $gmem_fixed = 0
Global Const $gmem_moveable = 2
Global Const $gmem_nocompact = 16
Global Const $gmem_nodiscard = 32
Global Const $gmem_zeroinit = 64
Global Const $gmem_modify = 128
Global Const $gmem_discardable = 256
Global Const $gmem_not_banked = 4096
Global Const $gmem_share = 8192
Global Const $gmem_ddeshare = 8192
Global Const $gmem_notify = 16384
Global Const $gmem_lower = 4096
Global Const $gmem_valid_flags = 32626
Global Const $gmem_invalid_handle = 32768
Global Const $gptr = 64
Global Const $ghnd = 66
Global Const $mem_commit = 4096
Global Const $mem_reserve = 8192
Global Const $mem_top_down = 1048576
Global Const $mem_shared = 134217728
Global Const $page_noaccess = 1
Global Const $page_readonly = 2
Global Const $page_readwrite = 4
Global Const $page_execute = 16
Global Const $page_execute_read = 32
Global Const $page_execute_readwrite = 64
Global Const $page_guard = 256
Global Const $page_nocache = 512
Global Const $mem_decommit = 16384
Global Const $mem_release = 32768
Global Const $__memoryconstant_process_vm_operation = 8
Global Const $__memoryconstant_process_vm_read = 16
Global Const $__memoryconstant_process_vm_write = 32

Func _memfree(ByRef $tmemmap)
	Local $hprocess, $pmemory, $bresult
	$pmemory = DllStructGetData($tmemmap, "Mem")
	$hprocess = DllStructGetData($tmemmap, "hProc")
	If @OSType = "WIN32_WINDOWS" Then
		$bresult = _memvirtualfree($pmemory, 0, $mem_release)
	Else
		$bresult = _memvirtualfreeex($hprocess, $pmemory, 0, $mem_release)
	EndIf
	_winapi_closehandle($hprocess)
	Return $bresult
EndFunc

Func _memglobalalloc($ibytes, $iflags = 0)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "hwnd", "GlobalAlloc", "int", $iflags, "int", $ibytes)
	Return $aresult[0]
EndFunc

Func _memglobalfree($hmem)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "GlobalFree", "hwnd", $hmem)
	Return $aresult[0] = 0
EndFunc

Func _memgloballock($hmem)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "ptr", "GlobalLock", "hwnd", $hmem)
	Return $aresult[0]
EndFunc

Func _memglobalsize($hmem)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "GlobalSize", "hwnd", $hmem)
	Return $aresult[0]
EndFunc

Func _memglobalunlock($hmem)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "int", "GlobalUnlock", "hwnd", $hmem)
	Return $aresult[0]
EndFunc

Func _meminit($hwnd, $isize, ByRef $tmemmap)
	Local $iaccess, $ialloc, $pmemory, $hprocess, $iprocessid
	_winapi_getwindowthreadprocessid($hwnd, $iprocessid)
	If $iprocessid = 0 Then _memshowerror("_MemInit: Invalid window handle [0x" & Hex($hwnd) & "]")
	$iaccess = BitOR($__memoryconstant_process_vm_operation, $__memoryconstant_process_vm_read, $__memoryconstant_process_vm_write)
	$hprocess = _winapi_openprocess($iaccess, False, $iprocessid, True)
	If @OSType = "WIN32_WINDOWS" Then
		$ialloc = BitOR($mem_reserve, $mem_commit, $mem_shared)
		$pmemory = _memvirtualalloc(0, $isize, $ialloc, $page_readwrite)
	Else
		$ialloc = BitOR($mem_reserve, $mem_commit)
		$pmemory = _memvirtualallocex($hprocess, 0, $isize, $ialloc, $page_readwrite)
	EndIf
	If $pmemory = 0 Then _memshowerror("_MemInit: Unable to allocate memory")
	$tmemmap = DllStructCreate($tagmemmap)
	DllStructSetData($tmemmap, "hProc", $hprocess)
	DllStructSetData($tmemmap, "Size", $isize)
	DllStructSetData($tmemmap, "Mem", $pmemory)
	Return $pmemory
EndFunc

Func _memmsgbox($iflags, $stitle, $stext)
	BlockInput(0)
	MsgBox($iflags, $stitle, $stext & "      ")
EndFunc

Func _memmovememory($psource, $pdest, $ilength)
	DllCall("Kernel32.dll", "none", "RtlMoveMemory", "ptr", $pdest, "ptr", $psource, "dword", $ilength)
EndFunc

Func _memread(ByRef $tmemmap, $psrce, $pdest, $isize)
	Local $iread
	Return _winapi_readprocessmemory(DllStructGetData($tmemmap, "hProc"), $psrce, $pdest, $isize, $iread)
EndFunc

Func _memshowerror($stext, $fexit = True)
	_memmsgbox(16 + 4096, "Error", $stext)
	If $fexit Then Exit
EndFunc

Func _memwrite(ByRef $tmemmap, $psrce, $pdest = 0, $isize = 0, $ssrce = "ptr")
	Local $iwritten
	If $pdest = 0 Then $pdest = DllStructGetData($tmemmap, "Mem")
	If $isize = 0 Then $isize = DllStructGetData($tmemmap, "Size")
	Return _winapi_writeprocessmemory(DllStructGetData($tmemmap, "hProc"), $pdest, $psrce, $isize, $iwritten, $ssrce)
EndFunc

Func _memvirtualalloc($paddress, $isize, $iallocation, $iprotect)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "ptr", "VirtualAlloc", "ptr", $paddress, "int", $isize, "int", $iallocation, "int", $iprotect)
	Return SetError($aresult[0] = 0, 0, $aresult[0])
EndFunc

Func _memvirtualallocex($hprocess, $paddress, $isize, $iallocation, $iprotect)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "ptr", "VirtualAllocEx", "int", $hprocess, "ptr", $paddress, "int", $isize, "int", $iallocation, "int", $iprotect)
	Return SetError($aresult[0] = 0, 0, $aresult[0])
EndFunc

Func _memvirtualfree($paddress, $isize, $ifreetype)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "ptr", "VirtualFree", "ptr", $paddress, "int", $isize, "int", $ifreetype)
	Return $aresult[0]
EndFunc

Func _memvirtualfreeex($hprocess, $paddress, $isize, $ifreetype)
	Local $aresult
	$aresult = DllCall("Kernel32.dll", "ptr", "VirtualFreeEx", "hwnd", $hprocess, "ptr", $paddress, "int", $isize, "int", $ifreetype)
	Return $aresult[0]
EndFunc

Global Const $_udf_globalids_offset = 2
Global Const $_udf_globalid_max_win = 16
Global Const $_udf_startid = 10000
Global Const $_udf_globalid_max_ids = 55535
Global $_udf_globalids_used[$_udf_globalid_max_win][$_udf_globalid_max_ids + $_udf_globalids_offset + 1]

Func _udf_getnextglobalid($hwnd)
	Local $nctrlid, $iusedindex = -1, $fallused = True
	If NOT WinExists($hwnd) Then Return SetError(-1, -1, 0)
	For $iindex = 0 To $_udf_globalid_max_win - 1
		If $_udf_globalids_used[$iindex][0] <> 0 Then
			If NOT WinExists($_udf_globalids_used[$iindex][0]) Then
				For $x = 0 To UBound($_udf_globalids_used, 2) - 1
					$_udf_globalids_used[$iindex][$x] = 0
				Next
				$_udf_globalids_used[$iindex][1] = $_udf_startid
				$fallused = False
			EndIf
		EndIf
	Next
	For $iindex = 0 To $_udf_globalid_max_win - 1
		If $_udf_globalids_used[$iindex][0] = $hwnd Then
			$iusedindex = $iindex
			ExitLoop
		EndIf
	Next
	If $iusedindex = -1 Then
		For $iindex = 0 To $_udf_globalid_max_win - 1
			If $_udf_globalids_used[$iindex][0] = 0 Then
				$_udf_globalids_used[$iindex][0] = $hwnd
				$_udf_globalids_used[$iindex][1] = $_udf_startid
				$fallused = False
				$iusedindex = $iindex
				ExitLoop
			EndIf
		Next
	EndIf
	If $iusedindex = -1 AND $fallused Then Return SetError(16, 0, 0)
	If $_udf_globalids_used[$iusedindex][1] = $_udf_startid + $_udf_globalid_max_ids Then
		For $iidindex = $_udf_globalids_offset To UBound($_udf_globalids_used, 2) - 1
			If $_udf_globalids_used[$iusedindex][$iidindex] = 0 Then
				$nctrlid = ($iidindex - $_udf_globalids_offset) + 10000
				$_udf_globalids_used[$iusedindex][$iidindex] = $nctrlid
				Return $nctrlid
			EndIf
		Next
		Return SetError(-1, $_udf_globalid_max_ids, 0)
	EndIf
	$nctrlid = $_udf_globalids_used[$iusedindex][1]
	$_udf_globalids_used[$iusedindex][1] += 1
	$_udf_globalids_used[$iusedindex][($nctrlid - 10000) + $_udf_globalids_offset] = $nctrlid
	Return $nctrlid
EndFunc

Func _udf_freeglobalid($hwnd, $iglobalid)
	If $iglobalid - $_udf_startid < 0 OR $iglobalid - $_udf_startid > $_udf_globalid_max_ids Then Return SetError(-1, 0, False)
	For $iindex = 0 To $_udf_globalid_max_win - 1
		If $_udf_globalids_used[$iindex][0] = $hwnd Then
			For $x = $_udf_globalids_offset To UBound($_udf_globalids_used, 2) - 1
				If $_udf_globalids_used[$iindex][$x] = $iglobalid Then
					$_udf_globalids_used[$iindex][$x] = 0
					Return True
				EndIf
			Next
			Return SetError(-3, 0, False)
		EndIf
	Next
	Return SetError(-2, 0, False)
EndFunc

Global $_ghcblastwnd
Global $debug_cb = False
Global Const $__comboboxconstant_classname = "ComboBox"
Global Const $__comboboxconstant_em_getline = 196
Global Const $__comboboxconstant_em_lineindex = 187
Global Const $__comboboxconstant_em_linelength = 193
Global Const $__comboboxconstant_em_replacesel = 194
Global Const $__comboboxconstant_wm_setredraw = 11
Global Const $__comboboxconstant_ws_tabstop = 65536
Global Const $__comboboxconstant_ws_visible = 268435456
Global Const $__comboboxconstant_ws_child = 1073741824
Global Const $__comboboxconstant_default_gui_font = 17
Global Const $__comboboxconstant_ddl_drives = 16384

Func _guictrlcombobox_adddir($hwnd, $sfile, $iattributes = 0, $fbrackets = True)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If BitAND($iattributes, $__comboboxconstant_ddl_drives) = $__comboboxconstant_ddl_drives AND NOT $fbrackets Then
		Local $stext, $v_ret
		Local $gui_no_brackets = GUICreate("no brackets")
		Local $combo_no_brackets = GUICtrlCreateCombo("", 240, 40, 120, 120)
		$v_ret = GUICtrlSendMsg($combo_no_brackets, $cb_dir, $iattributes, $sfile)
		For $i = 0 To _guictrlcombobox_getcount($combo_no_brackets) - 1
			_guictrlcombobox_getlbtext($combo_no_brackets, $i, $stext)
			$stext = StringReplace(StringReplace(StringReplace($stext, "[", ""), "]", ":"), "-", "")
			_guictrlcombobox_insertstring($hwnd, $stext)
		Next
		GUIDelete($gui_no_brackets)
		Return $v_ret
	Else
		Return _sendmessage($hwnd, $cb_dir, $iattributes, $sfile, 0, "wparam", "str")
	EndIf
EndFunc

Func _guictrlcombobox_addstring($hwnd, $stext)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_addstring, 0, $stext, 0, "wparam", "str")
EndFunc

Func _guictrlcombobox_autocomplete($hwnd)
	Local $ret, $sinputtext, $sedittext
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If NOT _guictrlcombobox_ispressed("08") AND NOT _guictrlcombobox_ispressed("2E") Then
		$sedittext = _guictrlcombobox_getedittext($hwnd)
		If StringLen($sedittext) Then
			$ret = _guictrlcombobox_findstring($hwnd, $sedittext)
			If ($ret <> $cb_err) Then
				_guictrlcombobox_getlbtext($hwnd, $ret, $sinputtext)
				_guictrlcombobox_setedittext($hwnd, $sinputtext)
				_guictrlcombobox_seteditsel($hwnd, StringLen($sedittext), StringLen($sinputtext))
			EndIf
		EndIf
	EndIf
EndFunc

Func _guictrlcombobox_beginupdate($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $__comboboxconstant_wm_setredraw) = 0
EndFunc

Func _guictrlcombobox_create($hwnd, $stext, $ix, $iy, $iwidth = 100, $iheight = 120, $istyle = 2097218, $iexstyle = 0)
	If NOT IsHWnd($hwnd) Then _winapi_showerror("Invalid Window handle for _GUICtrlComboBox_Create 1st parameter")
	If NOT IsString($stext) Then _winapi_showerror("2nd parameter not a string for _GUICtrlComboBox_Create")
	Local $hcombo, $atext, $sdelimiter = Opt("GUIDataSeparatorChar"), $nctrlid
	If $iwidth = -1 Then $iwidth = 100
	If $iheight = -1 Then $iheight = 120
	If $istyle = -1 Then $istyle = 2097218
	If $iexstyle = -1 Then $iexstyle = 0
	$istyle = BitOR($istyle, $__comboboxconstant_ws_child, $__comboboxconstant_ws_tabstop, $__comboboxconstant_ws_visible)
	$nctrlid = _udf_getnextglobalid($hwnd)
	If @error Then Return SetError(@error, @extended, 0)
	$hcombo = _winapi_createwindowex($iexstyle, $__comboboxconstant_classname, "", $istyle, $ix, $iy, $iwidth, $iheight, $hwnd, $nctrlid)
	_winapi_setfont($hcombo, _winapi_getstockobject($__comboboxconstant_default_gui_font))
	If StringLen($stext) Then
		$atext = StringSplit($stext, $sdelimiter)
		For $x = 1 To $atext[0]
			_guictrlcombobox_addstring($hcombo, $atext[$x])
		Next
	EndIf
	Return $hcombo
EndFunc

Func _guictrlcombobox_debugprint($stext, $iline = @ScriptLineNumber)
	ConsoleWrite("!===========================================================" & @LF & "+======================================================" & @LF & "-->Line(" & StringFormat("%04d", $iline) & "):" & @TAB & $stext & @LF & "+======================================================" & @LF)
EndFunc

Func _guictrlcombobox_deletestring($hwnd, $iindex)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_deletestring, $iindex)
EndFunc

Func _guictrlcombobox_destroy(ByRef $hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	Local $destroyed, $iresult
	If _winapi_isclassname($hwnd, $__comboboxconstant_classname) Then
		If IsHWnd($hwnd) Then
			If _winapi_inprocess($hwnd, $_ghcblastwnd) Then
				Local $nctrlid = _winapi_getdlgctrlid($hwnd)
				Local $hparent = _winapi_getparent($hwnd)
				$destroyed = _winapi_destroywindow($hwnd)
				$iresult = _udf_freeglobalid($hparent, $nctrlid)
				If NOT $iresult Then
				EndIf
			Else
				_winapi_showmsg("Not Allowed to Destroy Other Applications ListView(s)")
				Return SetError(1, 1, False)
			EndIf
		Else
			$destroyed = GUICtrlDelete($hwnd)
		EndIf
		If $destroyed Then $hwnd = 0
		Return $destroyed <> 0
	EndIf
	Return SetError(2, 2, False)
EndFunc

Func _guictrlcombobox_endupdate($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $__comboboxconstant_wm_setredraw, 1) = 0
EndFunc

Func _guictrlcombobox_findstring($hwnd, $stext, $iindex = -1)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If _winapi_inprocess($hwnd, $_ghcblastwnd) Then
		Return _sendmessage($hwnd, $cb_findstring, $iindex, $stext, 0, "int", "str")
	Else
		Local $struct_string = DllStructCreate("char Text[" & StringLen($stext) + 1 & "]")
		Local $sbuffer_pointer = DllStructGetPtr($struct_string)
		DllStructSetData($struct_string, "Text", $stext)
		Local $rmemmap
		_meminit($hwnd, StringLen($stext) + 1, $rmemmap)
		_memwrite($rmemmap, $sbuffer_pointer)
		Local $iresult = _sendmessage($hwnd, $cb_findstring, $iindex, $sbuffer_pointer, 0, "wparam", "ptr")
		_memfree($rmemmap)
		Return $iresult
	EndIf
EndFunc

Func _guictrlcombobox_findstringexact($hwnd, $stext, $iindex = -1)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If _winapi_inprocess($hwnd, $_ghcblastwnd) Then
		Return _sendmessage($hwnd, $cb_findstringexact, $iindex, $stext, 0, "wparam", "str")
	Else
		Local $struct_string = DllStructCreate("char Text[" & StringLen($stext) + 1 & "]")
		Local $sbuffer_pointer = DllStructGetPtr($struct_string)
		DllStructSetData($struct_string, "Text", $stext)
		Local $rmemmap
		_meminit($hwnd, StringLen($stext) + 1, $rmemmap)
		_memwrite($rmemmap, $sbuffer_pointer)
		Local $iresult = _sendmessage($hwnd, $cb_findstringexact, $iindex, $sbuffer_pointer, 0, "wparam", "ptr")
		_memfree($rmemmap)
		Return $iresult
	EndIf
EndFunc

Func _guictrlcombobox_getcomboboxinfo($hwnd, ByRef $tinfo)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $pinfo, $iinfo
	$tinfo = DllStructCreate($tagcomboboxinfo)
	$pinfo = DllStructGetPtr($tinfo)
	$iinfo = DllStructGetSize($tinfo)
	DllStructSetData($tinfo, "Size", $iinfo)
	Return _sendmessage($hwnd, $cb_getcomboboxinfo, 0, $pinfo, 0, "wparam", "ptr") <> 0
EndFunc

Func _guictrlcombobox_getcount($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_getcount)
EndFunc

Func _guictrlcombobox_getcuebanner($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $ttext = DllStructCreate("wchar[4096]")
	If _sendmessage($hwnd, $cb_getcuebanner, DllStructGetPtr($ttext), 4096) <> 1 Then Return SetError(-1, 0, "")
	Return _winapi_widechartomultibyte(DllStructGetPtr($ttext))
EndFunc

Func _guictrlcombobox_getcursel($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_getcursel)
EndFunc

Func _guictrlcombobox_getdroppedcontrolrect($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $trect, $arect[4]
	$trect = _guictrlcombobox_getdroppedcontrolrectex($hwnd)
	$arect[0] = DllStructGetData($trect, "Left")
	$arect[1] = DllStructGetData($trect, "Top")
	$arect[2] = DllStructGetData($trect, "Right")
	$arect[3] = DllStructGetData($trect, "Bottom")
	Return $arect
EndFunc

Func _guictrlcombobox_getdroppedcontrolrectex($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $trect = DllStructCreate($tagrect)
	_sendmessage($hwnd, $cb_getdroppedcontrolrect, 0, DllStructGetPtr($trect), 0, "wparam", "ptr")
	Return $trect
EndFunc

Func _guictrlcombobox_getdroppedstate($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_getdroppedstate) <> 0
EndFunc

Func _guictrlcombobox_getdroppedwidth($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_getdroppedwidth)
EndFunc

Func _guictrlcombobox_geteditsel($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $tstart, $tend, $iresult, $asel[2]
	$tstart = DllStructCreate("dword Start")
	$tend = DllStructCreate("dword End")
	$iresult = _sendmessage($hwnd, $cb_geteditsel, DllStructGetPtr($tstart), DllStructGetPtr($tend), 0, "ptr", "ptr")
	If (NOT $iresult) Then Return SetError($cb_err, $cb_err, $cb_err)
	$asel[0] = DllStructGetData($tstart, "Start")
	$asel[1] = DllStructGetData($tend, "End")
	Return $asel
EndFunc

Func _guictrlcombobox_getedittext($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $iline = 0, $iindex = 0, $ilength, $iresult
	Local $struct_string, $struct_buffer, $tinfo, $hedit
	If _guictrlcombobox_getcomboboxinfo($hwnd, $tinfo) Then
		$hedit = DllStructGetData($tinfo, "hEdit")
		$iindex = _sendmessage($hedit, $__comboboxconstant_em_lineindex, $iline)
		$ilength = _sendmessage($hedit, $__comboboxconstant_em_linelength, $iindex)
		$struct_buffer = DllStructCreate("short Len;char Text[" & $ilength + 2 & "]")
		DllStructSetData($struct_buffer, "Len", $ilength + 2)
		$iresult = _sendmessagea($hedit, $__comboboxconstant_em_getline, $iline, DllStructGetPtr($struct_buffer), 0, "wparam", "ptr")
		If $iresult = -1 Then Return SetError(-1, -1, "")
		$struct_string = DllStructCreate("char Text[" & $ilength + 1 & "]", DllStructGetPtr($struct_buffer))
		Return DllStructGetData($struct_string, "Text")
	Else
		Return SetError(-1, -1, "")
	EndIf
EndFunc

Func _guictrlcombobox_getextendedui($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_getextendedui) <> 0
EndFunc

Func _guictrlcombobox_gethorizontalextent($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_gethorizontalextent)
EndFunc

Func _guictrlcombobox_getitemheight($hwnd, $iindex = -1)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_getitemheight, $iindex)
EndFunc

Func _guictrlcombobox_getlbtext($hwnd, $iindex, ByRef $stext)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $iresult, $ilen, $tbuffer
	$ilen = _guictrlcombobox_getlbtextlen($hwnd, $iindex)
	$tbuffer = DllStructCreate("char Text[" & $ilen + 1 & "]")
	$iresult = _sendmessagea($hwnd, $cb_getlbtext, $iindex, DllStructGetPtr($tbuffer), 0, "wparam", "ptr")
	If ($iresult == $cb_err) Then Return SetError($cb_err, $cb_err, $cb_err)
	$stext = DllStructGetData($tbuffer, "Text")
	Return $iresult
EndFunc

Func _guictrlcombobox_getlbtextlen($hwnd, $iindex)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_getlbtextlen, $iindex)
EndFunc

Func _guictrlcombobox_getlist($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $sdelimiter = Opt("GUIDataSeparatorChar")
	Local $sresult, $sitem
	For $i = 0 To _guictrlcombobox_getcount($hwnd) - 1
		_guictrlcombobox_getlbtext($hwnd, $i, $sitem)
		$sresult &= $sitem & $sdelimiter
	Next
	Return StringTrimRight($sresult, StringLen($sdelimiter))
EndFunc

Func _guictrlcombobox_getlistarray($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $sdelimiter = Opt("GUIDataSeparatorChar")
	Return StringSplit(_guictrlcombobox_getlist($hwnd), $sdelimiter)
EndFunc

Func _guictrlcombobox_getlocale($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_getlocale)
EndFunc

Func _guictrlcombobox_getlocalecountry($hwnd)
	Return _winapi_hiword(_guictrlcombobox_getlocale($hwnd))
EndFunc

Func _guictrlcombobox_getlocalelang($hwnd)
	Return _winapi_loword(_guictrlcombobox_getlocale($hwnd))
EndFunc

Func _guictrlcombobox_getlocaleprimlang($hwnd)
	Return _winapi_primarylangid(_guictrlcombobox_getlocalelang($hwnd))
EndFunc

Func _guictrlcombobox_getlocalesublang($hwnd)
	Return _winapi_sublangid(_guictrlcombobox_getlocalelang($hwnd))
EndFunc

Func _guictrlcombobox_getminvisible($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_getminvisible)
EndFunc

Func _guictrlcombobox_gettopindex($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_gettopindex)
EndFunc

Func _guictrlcombobox_initstorage($hwnd, $inum, $ibytes)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_initstorage, $inum, $ibytes)
EndFunc

Func _guictrlcombobox_insertstring($hwnd, $stext, $iindex = -1)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If _winapi_inprocess($hwnd, $_ghcblastwnd) Then
		Return _sendmessage($hwnd, $cb_insertstring, $iindex, $stext, 0, "wparam", "str")
	Else
		Local $struct_string = DllStructCreate("char Text[" & StringLen($stext) + 1 & "]")
		Local $sbuffer_pointer = DllStructGetPtr($struct_string)
		DllStructSetData($struct_string, "Text", $stext)
		Local $rmemmap
		_meminit($hwnd, StringLen($stext) + 1, $rmemmap)
		_memwrite($rmemmap, $sbuffer_pointer)
		Local $iresult = _sendmessage($hwnd, $cb_insertstring, $iindex, $sbuffer_pointer, 0, "wparam", "ptr")
		_memfree($rmemmap)
		Return $iresult
	EndIf
EndFunc

Func _guictrlcombobox_limittext($hwnd, $ilimit = 0)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	_sendmessage($hwnd, $cb_limittext, $ilimit)
EndFunc

Func _guictrlcombobox_replaceeditsel($hwnd, $stext)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $struct_memmap, $struct_string, $sbuffer_pointer
	Local $tinfo, $hedit
	$struct_string = DllStructCreate("char Text[" & StringLen($stext) + 1 & "]")
	$sbuffer_pointer = DllStructGetPtr($struct_string)
	DllStructSetData($struct_string, "Text", $stext)
	If _guictrlcombobox_getcomboboxinfo($hwnd, $tinfo) Then
		$hedit = DllStructGetData($tinfo, "hEdit")
		_meminit($hedit, StringLen($stext) + 1, $struct_memmap)
		_memwrite($struct_memmap, $sbuffer_pointer)
		_sendmessage($hedit, $__comboboxconstant_em_replacesel, True, $sbuffer_pointer, 0, "wparam", "ptr")
		_memfree($struct_memmap)
		If @error Then Return SetError(-1, -1, 0)
	EndIf
EndFunc

Func _guictrlcombobox_resetcontent($hwnd)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	_sendmessage($hwnd, $cb_resetcontent)
EndFunc

Func _guictrlcombobox_selectstring($hwnd, $stext, $iindex = -1)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_selectstring, $iindex, $stext, 0, "wparam", "str")
EndFunc

Func _guictrlcombobox_setcuebanner($hwnd, $stext)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $ttext = _winapi_multibytetowidechar($stext)
	Return _sendmessage($hwnd, $cb_setcuebanner, 0, DllStructGetPtr($ttext)) = 1
EndFunc

Func _guictrlcombobox_setcursel($hwnd, $iindex = -1)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_setcursel, $iindex)
EndFunc

Func _guictrlcombobox_setdroppedwidth($hwnd, $iwidth)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_setdroppedwidth, $iwidth)
EndFunc

Func _guictrlcombobox_seteditsel($hwnd, $istart, $istop)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT HWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_seteditsel, 0, _winapi_makelong($istart, $istop)) <> -1
EndFunc

Func _guictrlcombobox_setedittext($hwnd, $stext)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	_guictrlcombobox_seteditsel($hwnd, 0, -1)
	_guictrlcombobox_replaceeditsel($hwnd, $stext)
EndFunc

Func _guictrlcombobox_setextendedui($hwnd, $fextended = False)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_setextendedui, $fextended) = 0
EndFunc

Func _guictrlcombobox_sethorizontalextent($hwnd, $iwidth)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	_sendmessage($hwnd, $cb_sethorizontalextent, $iwidth)
EndFunc

Func _guictrlcombobox_setitemheight($hwnd, $iheight, $icomponent = -1)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_setitemheight, $icomponent, $iheight)
EndFunc

Func _guictrlcombobox_setlocale($hwnd, $ilocal)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_setlocale, $ilocal)
EndFunc

Func _guictrlcombobox_setminvisible($hwnd, $iminimum)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_setminvisible, $iminimum) <> 0
EndFunc

Func _guictrlcombobox_settopindex($hwnd, $iindex)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $cb_settopindex, $iindex) = 0
EndFunc

Func _guictrlcombobox_showdropdown($hwnd, $fshow = False)
	If $debug_cb Then _guictrlcombobox_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	_sendmessage($hwnd, $cb_showdropdown, $fshow)
EndFunc

Func _guictrlcombobox_validateclassname($hwnd, $stype = $__comboboxconstant_classname)
	_guictrlcombobox_debugprint("This is for debugging only, set the debug variable to false before submitting")
	_winapi_validateclassname($hwnd, $stype)
EndFunc

Func _guictrlcombobox_ispressed($shexkey, $vdll = "user32.dll")
	Local $a_r = DllCall($vdll, "int", "GetAsyncKeyState", "int", "0x" & $shexkey)
	If NOT @error AND BitAND($a_r[0], 32768) = 32768 Then Return 1
	Return 0
EndFunc

Global Const $opt_coordsrelative = 0
Global Const $opt_coordsabsolute = 1
Global Const $opt_coordsclient = 2
Global Const $opt_errorsilent = 0
Global Const $opt_errorfatal = 1
Global Const $opt_capsnostore = 0
Global Const $opt_capsstore = 1
Global Const $opt_matchstart = 1
Global Const $opt_matchany = 2
Global Const $opt_matchexact = 3
Global Const $opt_matchadvanced = 4
Global Const $ccs_top = 1
Global Const $ccs_nomovey = 2
Global Const $ccs_bottom = 3
Global Const $ccs_noresize = 4
Global Const $ccs_noparentalign = 8
Global Const $ccs_nohilite = 16
Global Const $ccs_adjustable = 32
Global Const $ccs_nodivider = 64
Global Const $ccs_vert = 128
Global Const $ccs_left = 129
Global Const $ccs_nomovex = 130
Global Const $ccs_right = 131
Global Const $di_mask = 1
Global Const $di_image = 2
Global Const $di_normal = 3
Global Const $di_compat = 4
Global Const $di_defaultsize = 8
Global Const $di_nomirror = 16
Global Const $display_device_attached_to_desktop = 1
Global Const $display_device_multi_driver = 2
Global Const $display_device_primary_device = 4
Global Const $display_device_mirroring_driver = 8
Global Const $display_device_vga_compatible = 16
Global Const $display_device_removable = 32
Global Const $display_device_disconnect = 33554432
Global Const $display_device_remote = 67108864
Global Const $display_device_modespruned = 134217728
Global Const $ddl_archive = 32
Global Const $ddl_directory = 16
Global Const $ddl_drives = 16384
Global Const $ddl_exclusive = 32768
Global Const $ddl_hidden = 2
Global Const $ddl_readonly = 1
Global Const $ddl_readwrite = 0
Global Const $ddl_system = 4
Global Const $fc_nooverwrite = 0
Global Const $fc_overwrite = 1
Global Const $ft_modified = 0
Global Const $ft_created = 1
Global Const $ft_accessed = 2
Global Const $fo_read = 0
Global Const $fo_append = 1
Global Const $fo_overwrite = 2
Global Const $fo_binary = 16
Global Const $fo_unicode = 32
Global Const $fo_utf16_le = 32
Global Const $fo_utf16_be = 64
Global Const $fo_utf8 = 128
Global Const $eof = -1
Global Const $fd_filemustexist = 1
Global Const $fd_pathmustexist = 2
Global Const $fd_multiselect = 4
Global Const $fd_promptcreatenew = 8
Global Const $fd_promptoverwrite = 16
Global Const $create_new = 1
Global Const $create_always = 2
Global Const $open_existing = 3
Global Const $open_always = 4
Global Const $truncate_existing = 5
Global Const $invalid_set_file_pointer = -1
Global Const $file_begin = 0
Global Const $file_current = 1
Global Const $file_end = 2
Global Const $file_attribute_readonly = 1
Global Const $file_attribute_hidden = 2
Global Const $file_attribute_system = 4
Global Const $file_attribute_directory = 16
Global Const $file_attribute_archive = 32
Global Const $file_attribute_device = 64
Global Const $file_attribute_normal = 128
Global Const $file_attribute_temporary = 256
Global Const $file_attribute_sparse_file = 512
Global Const $file_attribute_reparse_point = 1024
Global Const $file_attribute_compressed = 2048
Global Const $file_attribute_offline = 4096
Global Const $file_attribute_not_content_indexed = 8192
Global Const $file_attribute_encrypted = 16384
Global Const $file_share_read = 1
Global Const $file_share_write = 2
Global Const $file_share_delete = 4
Global Const $generic_all = 268435456
Global Const $generic_execute = 536870912
Global Const $generic_write = 1073741824
Global Const $generic_read = -2147483648
Global Const $flashw_caption = 1
Global Const $flashw_tray = 2
Global Const $flashw_timer = 4
Global Const $flashw_timernofg = 12
Global Const $format_message_allocate_buffer = 256
Global Const $format_message_ignore_inserts = 512
Global Const $format_message_from_string = 1024
Global Const $format_message_from_hmodule = 2048
Global Const $format_message_from_system = 4096
Global Const $format_message_argument_array = 8192
Global Const $gw_hwndfirst = 0
Global Const $gw_hwndlast = 1
Global Const $gw_hwndnext = 2
Global Const $gw_hwndprev = 3
Global Const $gw_owner = 4
Global Const $gw_child = 5
Global Const $gwl_wndproc = -4
Global Const $gwl_hinstance = -6
Global Const $gwl_hwndparent = -8
Global Const $gwl_id = -12
Global Const $gwl_style = -16
Global Const $gwl_exstyle = -20
Global Const $gwl_userdata = -21
Global Const $std_cut = 0
Global Const $std_copy = 1
Global Const $std_paste = 2
Global Const $std_undo = 3
Global Const $std_redow = 4
Global Const $std_delete = 5
Global Const $std_filenew = 6
Global Const $std_fileopen = 7
Global Const $std_filesave = 8
Global Const $std_printpre = 9
Global Const $std_properties = 10
Global Const $std_help = 11
Global Const $std_find = 12
Global Const $std_replace = 13
Global Const $std_print = 14
Global Const $lr_defaultcolor = 0
Global Const $lr_monochrome = 1
Global Const $lr_color = 2
Global Const $lr_copyreturnorg = 4
Global Const $lr_copydeleteorg = 8
Global Const $lr_loadfromfile = 16
Global Const $lr_loadtransparent = 32
Global Const $lr_defaultsize = 64
Global Const $lr_vgacolor = 128
Global Const $lr_loadmap3dcolors = 4096
Global Const $lr_createdibsection = 8192
Global Const $lr_copyfromresource = 16384
Global Const $lr_shared = 32768
Global Const $image_bitmap = 0
Global Const $image_icon = 1
Global Const $image_cursor = 2
Global Const $kb_sendspecial = 0
Global Const $kb_sendraw = 1
Global Const $kb_capsoff = 0
Global Const $kb_capson = 1
Global Const $dont_resolve_dll_references = 1
Global Const $load_library_as_datafile = 2
Global Const $load_with_altered_search_path = 8
Global Const $objid_window = 0
Global Const $objid_sysmenu = -1
Global Const $objid_titlebar = -2
Global Const $objid_menu = -3
Global Const $objid_sizegrip = -7
Global Const $objid_caret = -8
Global Const $objid_cursor = -9
Global Const $objid_alert = -10
Global Const $objid_sound = -11
Global Const $vk_down = 40
Global Const $vk_end = 35
Global Const $vk_home = 36
Global Const $vk_left = 37
Global Const $vk_next = 34
Global Const $vk_prior = 33
Global Const $vk_right = 39
Global Const $vk_up = 38
Global Const $mb_ok = 0
Global Const $mb_okcancel = 1
Global Const $mb_abortretryignore = 2
Global Const $mb_yesnocancel = 3
Global Const $mb_yesno = 4
Global Const $mb_retrycancel = 5
Global Const $mb_iconhand = 16
Global Const $mb_iconquestion = 32
Global Const $mb_iconexclamation = 48
Global Const $mb_iconasterisk = 64
Global Const $mb_defbutton1 = 0
Global Const $mb_defbutton2 = 256
Global Const $mb_defbutton3 = 512
Global Const $mb_applmodal = 0
Global Const $mb_systemmodal = 4096
Global Const $mb_taskmodal = 8192
Global Const $mb_topmost = 262144
Global Const $mb_rightjustified = 524288
Global Const $idtimeout = -1
Global Const $idok = 1
Global Const $idcancel = 2
Global Const $idabort = 3
Global Const $idretry = 4
Global Const $idignore = 5
Global Const $idyes = 6
Global Const $idno = 7
Global Const $idtryagain = 10
Global Const $idcontinue = 11
Global Const $dlg_notitle = 1
Global Const $dlg_notontop = 2
Global Const $dlg_textleft = 4
Global Const $dlg_textright = 8
Global Const $dlg_moveable = 16
Global Const $dlg_textvcenter = 32
Global Const $tip_iconnone = 0
Global Const $tip_iconasterisk = 1
Global Const $tip_iconexclamation = 2
Global Const $tip_iconhand = 3
Global Const $tip_nosound = 16
Global Const $idc_unknown = 0
Global Const $idc_appstarting = 1
Global Const $idc_arrow = 2
Global Const $idc_cross = 3
Global Const $idc_hand = 32649
Global Const $idc_help = 4
Global Const $idc_ibeam = 5
Global Const $idc_icon = 6
Global Const $idc_no = 7
Global Const $idc_size = 8
Global Const $idc_sizeall = 9
Global Const $idc_sizenesw = 10
Global Const $idc_sizens = 11
Global Const $idc_sizenwse = 12
Global Const $idc_sizewe = 13
Global Const $idc_uparrow = 14
Global Const $idc_wait = 15
Global Const $idi_application = 32512
Global Const $idi_asterisk = 32516
Global Const $idi_exclamation = 32515
Global Const $idi_hand = 32513
Global Const $idi_question = 32514
Global Const $idi_winlogo = 32517
Global Const $sd_logoff = 0
Global Const $sd_shutdown = 1
Global Const $sd_reboot = 2
Global Const $sd_force = 4
Global Const $sd_powerdown = 8
Global Const $process_terminate = 1
Global Const $process_create_thread = 2
Global Const $process_set_sessionid = 4
Global Const $process_vm_operation = 8
Global Const $process_vm_read = 16
Global Const $process_vm_write = 32
Global Const $process_dup_handle = 64
Global Const $process_create_process = 128
Global Const $process_set_quota = 256
Global Const $process_set_information = 512
Global Const $process_query_information = 1024
Global Const $process_suspend_resume = 2048
Global Const $process_all_access = 2035711
Global Const $str_nocasesense = 0
Global Const $str_casesense = 1
Global Const $str_stripleading = 1
Global Const $str_striptrailing = 2
Global Const $str_stripspaces = 4
Global Const $str_stripall = 8
Global Const $token_assign_primary = 1
Global Const $token_duplicate = 2
Global Const $token_impersonate = 4
Global Const $token_query = 8
Global Const $token_query_source = 16
Global Const $token_adjust_privileges = 32
Global Const $token_adjust_groups = 64
Global Const $token_adjust_default = 128
Global Const $token_adjust_sessionid = 256
Global Const $tray_item_exit = 3
Global Const $tray_item_pause = 4
Global Const $tray_item_first = 7
Global Const $tray_checked = 1
Global Const $tray_unchecked = 4
Global Const $tray_enable = 64
Global Const $tray_disable = 128
Global Const $tray_focus = 256
Global Const $tray_default = 512
Global Const $tray_event_showicon = -3
Global Const $tray_event_hideicon = -4
Global Const $tray_event_flashicon = -5
Global Const $tray_event_noflashicon = -6
Global Const $tray_event_primarydown = -7
Global Const $tray_event_primaryup = -8
Global Const $tray_event_secondarydown = -9
Global Const $tray_event_secondaryup = -10
Global Const $tray_event_mouseover = -11
Global Const $tray_event_mouseout = -12
Global Const $tray_event_primarydouble = -13
Global Const $tray_event_secondarydouble = -14
Global Const $stdin_child = 1
Global Const $stdout_child = 2
Global Const $stderr_child = 4
Global Const $stderr_merged = 8
Global Const $stdio_inherit_parent = 16
Global Const $run_create_new_console = 65536
Global Const $color_aqua = 65535
Global Const $color_black = 0
Global Const $color_blue = 255
Global Const $color_cream = 16776176
Global Const $color_fuchsia = 16711935
Global Const $color_gray = 8421504
Global Const $color_green = 32768
Global Const $color_lime = 65280
Global Const $color_maroon = 9116770
Global Const $color_medblue = 708
Global Const $color_medgray = 10526884
Global Const $color_moneygreen = 12639424
Global Const $color_navy = 128
Global Const $color_olive = 8421376
Global Const $color_purple = 8388736
Global Const $color_red = 16711680
Global Const $color_silver = 12632256
Global Const $color_skyblue = 10930928
Global Const $color_teal = 32896
Global Const $color_white = 16777215
Global Const $color_yellow = 16776960
Global Const $clr_none = -1
Global Const $clr_aqua = 16776960
Global Const $clr_black = 0
Global Const $clr_blue = 16711680
Global Const $clr_cream = 15793151
Global Const $clr_default = -16777216
Global Const $clr_fuchsia = 16711935
Global Const $clr_gray = 8421504
Global Const $clr_green = 32768
Global Const $clr_lime = 65280
Global Const $clr_maroon = 6429835
Global Const $clr_medblue = 12845568
Global Const $clr_medgray = 10789024
Global Const $clr_moneygreen = 12639424
Global Const $clr_navy = 8388608
Global Const $clr_olive = 32896
Global Const $clr_purple = 8388736
Global Const $clr_red = 255
Global Const $clr_silver = 12632256
Global Const $clr_skyblue = 15780518
Global Const $clr_teal = 8421376
Global Const $clr_white = 16777215
Global Const $clr_yellow = 65535
Global Const $cc_anycolor = 256
Global Const $cc_fullopen = 2
Global Const $cc_rgbinit = 1
Global Const $mouseeventf_absolute = 32768
Global Const $mouseeventf_move = 1
Global Const $mouseeventf_leftdown = 2
Global Const $mouseeventf_leftup = 4
Global Const $mouseeventf_rightdown = 8
Global Const $mouseeventf_rightup = 16
Global Const $mouseeventf_middledown = 32
Global Const $mouseeventf_middleup = 64
Global Const $mouseeventf_wheel = 2048
Global Const $mouseeventf_xdown = 128
Global Const $mouseeventf_xup = 256
Global Const $reg_none = 0
Global Const $reg_sz = 1
Global Const $reg_expand_sz = 2
Global Const $reg_binary = 3
Global Const $reg_dword = 4
Global Const $reg_dword_big_endian = 5
Global Const $reg_link = 6
Global Const $reg_multi_sz = 7
Global Const $reg_resource_list = 8
Global Const $reg_full_resource_descriptor = 9
Global Const $reg_resource_requirements_list = 10
Global Const $hwnd_bottom = 1
Global Const $hwnd_notopmost = -2
Global Const $hwnd_top = 0
Global Const $hwnd_topmost = -1
Global Const $swp_nosize = 1
Global Const $swp_nomove = 2
Global Const $swp_nozorder = 4
Global Const $swp_noredraw = 8
Global Const $swp_noactivate = 16
Global Const $swp_framechanged = 32
Global Const $swp_drawframe = 32
Global Const $swp_showwindow = 64
Global Const $swp_hidewindow = 128
Global Const $swp_nocopybits = 256
Global Const $swp_noownerzorder = 512
Global Const $swp_noreposition = 512
Global Const $swp_nosendchanging = 1024
Global Const $swp_defererase = 8192
Global Const $swp_asyncwindowpos = 16384
Global Const $lang_afrikaans = 54
Global Const $lang_albanian = 28
Global Const $lang_arabic = 1
Global Const $lang_armenian = 43
Global Const $lang_assamese = 77
Global Const $lang_azeri = 44
Global Const $lang_basque = 45
Global Const $lang_belarusian = 35
Global Const $lang_bengali = 69
Global Const $lang_bulgarian = 2
Global Const $lang_catalan = 3
Global Const $lang_chinese = 4
Global Const $lang_croatian = 26
Global Const $lang_czech = 5
Global Const $lang_danish = 6
Global Const $lang_dutch = 19
Global Const $lang_english = 9
Global Const $lang_estonian = 37
Global Const $lang_faeroese = 56
Global Const $lang_farsi = 41
Global Const $lang_finnish = 11
Global Const $lang_french = 12
Global Const $lang_georgian = 55
Global Const $lang_german = 7
Global Const $lang_greek = 8
Global Const $lang_gujarati = 71
Global Const $lang_hebrew = 13
Global Const $lang_hindi = 57
Global Const $lang_hungarian = 14
Global Const $lang_icelandic = 15
Global Const $lang_indonesian = 33
Global Const $lang_italian = 16
Global Const $lang_japanese = 17
Global Const $lang_kannada = 75
Global Const $lang_kashmiri = 96
Global Const $lang_kazak = 63
Global Const $lang_konkani = 87
Global Const $lang_korean = 18
Global Const $lang_latvian = 38
Global Const $lang_lithuanian = 39
Global Const $lang_macedonian = 47
Global Const $lang_malay = 62
Global Const $lang_malayalam = 76
Global Const $lang_manipuri = 88
Global Const $lang_marathi = 78
Global Const $lang_nepali = 97
Global Const $lang_neutral = 0
Global Const $lang_norwegian = 20
Global Const $lang_oriya = 72
Global Const $lang_polish = 21
Global Const $lang_portuguese = 22
Global Const $lang_punjabi = 70
Global Const $lang_romanian = 24
Global Const $lang_russian = 25
Global Const $lang_sanskrit = 79
Global Const $lang_serbian = 26
Global Const $lang_sindhi = 89
Global Const $lang_slovak = 27
Global Const $lang_slovenian = 36
Global Const $lang_spanish = 10
Global Const $lang_swahili = 65
Global Const $lang_swedish = 29
Global Const $lang_tamil = 73
Global Const $lang_tatar = 68
Global Const $lang_telugu = 74
Global Const $lang_thai = 30
Global Const $lang_turkish = 31
Global Const $lang_ukrainian = 34
Global Const $lang_urdu = 32
Global Const $lang_uzbek = 67
Global Const $lang_vietnamese = 42
Global Const $sublang_arabic_algeria = 5
Global Const $sublang_arabic_bahrain = 15
Global Const $sublang_arabic_egypt = 3
Global Const $sublang_arabic_iraq = 2
Global Const $sublang_arabic_jordan = 11
Global Const $sublang_arabic_kuwait = 13
Global Const $sublang_arabic_lebanon = 12
Global Const $sublang_arabic_libya = 4
Global Const $sublang_arabic_morocco = 6
Global Const $sublang_arabic_oman = 8
Global Const $sublang_arabic_qatar = 16
Global Const $sublang_arabic_saudi_arabia = 1
Global Const $sublang_arabic_syria = 10
Global Const $sublang_arabic_tunisia = 7
Global Const $sublang_arabic_uae = 14
Global Const $sublang_arabic_yemen = 9
Global Const $sublang_azeri_cyrillic = 2
Global Const $sublang_azeri_latin = 1
Global Const $sublang_chinese_hongkong = 3
Global Const $sublang_chinese_macau = 5
Global Const $sublang_chinese_simplified = 2
Global Const $sublang_chinese_singapore = 4
Global Const $sublang_chinese_traditional = 1
Global Const $sublang_default = 1
Global Const $sublang_dutch = 1
Global Const $sublang_dutch_belgian = 2
Global Const $sublang_english_aus = 3
Global Const $sublang_english_belize = 10
Global Const $sublang_english_can = 4
Global Const $sublang_english_caribbean = 9
Global Const $sublang_english_eire = 6
Global Const $sublang_english_jamaica = 8
Global Const $sublang_english_nz = 5
Global Const $sublang_english_philippines = 13
Global Const $sublang_english_south_africa = 7
Global Const $sublang_english_trinidad = 11
Global Const $sublang_english_uk = 2
Global Const $sublang_english_us = 1
Global Const $sublang_english_zimbabwe = 12
Global Const $sublang_french = 1
Global Const $sublang_french_belgian = 2
Global Const $sublang_french_canadian = 3
Global Const $sublang_french_luxembourg = 5
Global Const $sublang_french_monaco = 6
Global Const $sublang_french_swiss = 4
Global Const $sublang_german = 1
Global Const $sublang_german_austrian = 3
Global Const $sublang_german_liechtenstein = 5
Global Const $sublang_german_luxembourg = 4
Global Const $sublang_german_swiss = 2
Global Const $sublang_italian = 1
Global Const $sublang_italian_swiss = 2
Global Const $sublang_kashmiri_india = 2
Global Const $sublang_korean = 1
Global Const $sublang_lithuanian = 1
Global Const $sublang_malay_brunei_darussalam = 2
Global Const $sublang_malay_malaysia = 1
Global Const $sublang_nepali_india = 2
Global Const $sublang_neutral = 0
Global Const $sublang_norwegian_bokmal = 1
Global Const $sublang_norwegian_nynorsk = 2
Global Const $sublang_portuguese = 2
Global Const $sublang_portuguese_brazilian = 1
Global Const $sublang_serbian_cyrillic = 3
Global Const $sublang_serbian_latin = 2
Global Const $sublang_spanish = 1
Global Const $sublang_spanish_argentina = 11
Global Const $sublang_spanish_bolivia = 16
Global Const $sublang_spanish_chile = 13
Global Const $sublang_spanish_colombia = 9
Global Const $sublang_spanish_costa_rica = 5
Global Const $sublang_spanish_dominican_republic = 7
Global Const $sublang_spanish_ecuador = 12
Global Const $sublang_spanish_el_salvador = 17
Global Const $sublang_spanish_guatemala = 4
Global Const $sublang_spanish_honduras = 18
Global Const $sublang_spanish_mexican = 2
Global Const $sublang_spanish_modern = 3
Global Const $sublang_spanish_nicaragua = 19
Global Const $sublang_spanish_panama = 6
Global Const $sublang_spanish_paraguay = 15
Global Const $sublang_spanish_peru = 10
Global Const $sublang_spanish_puerto_rico = 20
Global Const $sublang_spanish_uruguay = 14
Global Const $sublang_spanish_venezuela = 8
Global Const $sublang_swedish = 1
Global Const $sublang_swedish_finland = 2
Global Const $sublang_sys_default = 2
Global Const $sublang_urdu_india = 2
Global Const $sublang_urdu_pakistan = 1
Global Const $sublang_uzbek_cyrillic = 2
Global Const $sort_default = 0
Global Const $sort_japanese_xjis = 0
Global Const $sort_japanese_unicode = 1
Global Const $sort_chinese_big5 = 0
Global Const $sort_chinese_prcp = 0
Global Const $sort_chinese_unicode = 1
Global Const $sort_chinese_prc = 2
Global Const $sort_korean_ksc = 0
Global Const $sort_korean_unicode = 1
Global Const $sort_german_phone_book = 1
Global Const $sort_hungarian_default = 0
Global Const $sort_hungarian_technical = 1
Global Const $sort_georgian_traditional = 0
Global Const $sort_georgian_modern = 1
Global Const $bs_groupbox = 7
Global Const $bs_bottom = 2048
Global Const $bs_center = 768
Global Const $bs_defpushbutton = 1
Global Const $bs_left = 256
Global Const $bs_multiline = 8192
Global Const $bs_pushbox = 10
Global Const $bs_pushlike = 4096
Global Const $bs_right = 512
Global Const $bs_rightbutton = 32
Global Const $bs_top = 1024
Global Const $bs_vcenter = 3072
Global Const $bs_flat = 32768
Global Const $bs_icon = 64
Global Const $bs_bitmap = 128
Global Const $bs_notify = 16384
Global Const $bs_splitbutton = 12
Global Const $bs_defsplitbutton = 13
Global Const $bs_commandlink = 14
Global Const $bs_defcommandlink = 15
Global Const $bcsif_glyph = 1
Global Const $bcsif_image = 2
Global Const $bcsif_style = 4
Global Const $bcsif_size = 8
Global Const $bcss_nosplit = 1
Global Const $bcss_stretch = 2
Global Const $bcss_alignleft = 4
Global Const $bcss_image = 8
Global Const $button_imagelist_align_left = 0
Global Const $button_imagelist_align_right = 1
Global Const $button_imagelist_align_top = 2
Global Const $button_imagelist_align_bottom = 3
Global Const $button_imagelist_align_center = 4
Global Const $bs_3state = 5
Global Const $bs_auto3state = 6
Global Const $bs_autocheckbox = 3
Global Const $bs_checkbox = 2
Global Const $bs_radiobutton = 4
Global Const $bs_autoradiobutton = 9
Global Const $bs_ownerdraw = 11
Global Const $gui_ss_default_button = 0
Global Const $gui_ss_default_checkbox = 0
Global Const $gui_ss_default_group = 0
Global Const $gui_ss_default_radio = 0
Global Const $bcm_first = 5632
Global Const $bcm_getidealsize = ($bcm_first + 1)
Global Const $bcm_getimagelist = ($bcm_first + 3)
Global Const $bcm_getnote = ($bcm_first + 10)
Global Const $bcm_getnotelength = ($bcm_first + 11)
Global Const $bcm_getsplitinfo = ($bcm_first + 8)
Global Const $bcm_gettextmargin = ($bcm_first + 5)
Global Const $bcm_setdropdownstate = ($bcm_first + 6)
Global Const $bcm_setimagelist = ($bcm_first + 2)
Global Const $bcm_setnote = ($bcm_first + 9)
Global Const $bcm_setshield = ($bcm_first + 12)
Global Const $bcm_setsplitinfo = ($bcm_first + 7)
Global Const $bcm_settextmargin = ($bcm_first + 4)
Global Const $bm_click = 245
Global Const $bm_getcheck = 240
Global Const $bm_getimage = 246
Global Const $bm_getstate = 242
Global Const $bm_setcheck = 241
Global Const $bm_setdontclick = 248
Global Const $bm_setimage = 247
Global Const $bm_setstate = 243
Global Const $bm_setstyle = 244
Global Const $bcn_first = -1250
Global Const $bcn_dropdown = ($bcn_first + 2)
Global Const $bcn_hotitemchange = ($bcn_first + 1)
Global Const $bn_clicked = 0
Global Const $bn_paint = 1
Global Const $bn_hilite = 2
Global Const $bn_unhilite = 3
Global Const $bn_disable = 4
Global Const $bn_doubleclicked = 5
Global Const $bn_setfocus = 6
Global Const $bn_killfocus = 7
Global Const $bn_pushed = $bn_hilite
Global Const $bn_unpushed = $bn_unhilite
Global Const $bn_dblclk = $bn_doubleclicked
Global Const $bst_checked = 1
Global Const $bst_indeterminate = 2
Global Const $bst_unchecked = 0
Global Const $bst_focus = 8
Global Const $bst_pushed = 4
Global Const $bst_dontclick = 128
Global Const $tagbutton_imagelist = "hwnd ImageList;int Left;int Top;int Right;int Bottom;uint Align"
Global Const $tagbutton_splitinfo = "uint mask;hwnd himlGlyph;uint uSplitStyle;int X;int Y"
Global $_ghbuttonlastwnd
Global $debug_btn = False
Global Const $_buttonconstants_classname = "Button"
Global Const $_buttonconstants_gwl_style = -16
Global Const $_buttonconstants_lr_loadfromfile = 16
Global Const $_buttonconstants_lr_createdibsection = 8192
Global Const $__buttonconstant_ws_visible = 268435456
Global Const $__buttonconstant_ws_child = 1073741824
Global Const $__buttonconstant_ws_tabstop = 65536
Global Const $__buttonconstant_wm_setfont = 48
Global Const $__buttonconstant_default_gui_font = 17

Func _guictrlbutton_click($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	_sendmessage($hwnd, $bm_click)
EndFunc

Func _guictrlbutton_create($hwnd, $stext, $ix, $iy, $iwidth, $iheight, $istyle = -1, $iexstyle = -1)
	If NOT IsHWnd($hwnd) Then _winapi_showerror("Invalid Window handle for _GUICtrlButton_Create 1st parameter")
	If NOT IsString($stext) Then _winapi_showerror("2nd parameter not a string for _GUICtrlButton_Create")
	Local $iforcedstyle, $hbutton, $nctrlid
	$iforcedstyle = BitOR($__buttonconstant_ws_tabstop, $__buttonconstant_ws_visible, $__buttonconstant_ws_child, $bs_notify)
	If $istyle = -1 Then
		$istyle = $iforcedstyle
	Else
		$istyle = BitOR($istyle, $iforcedstyle)
	EndIf
	If $iexstyle = -1 Then $iexstyle = 0
	$nctrlid = _udf_getnextglobalid($hwnd)
	If @error Then Return SetError(@error, @extended, 0)
	$hbutton = _winapi_createwindowex($iexstyle, $_buttonconstants_classname, $stext, $istyle, $ix, $iy, $iwidth, $iheight, $hwnd, $nctrlid)
	_sendmessage($hbutton, $__buttonconstant_wm_setfont, _winapi_getstockobject($__buttonconstant_default_gui_font), True)
	Return $hbutton
EndFunc

Func _guictrlbutton_debugprint($stext, $iline = @ScriptLineNumber)
	ConsoleWrite("!===========================================================" & @LF & "+======================================================" & @LF & "-->Line(" & StringFormat("%04d", $iline) & "):" & @TAB & $stext & @LF & "+======================================================" & @LF)
EndFunc

Func _guictrlbutton_destroy(ByRef $hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	Local $iresult, $destroyed
	If _winapi_isclassname($hwnd, $_buttonconstants_classname) Then
		If IsHWnd($hwnd) Then
			If _winapi_inprocess($hwnd, $_ghbuttonlastwnd) Then
				Local $nctrlid = _winapi_getdlgctrlid($hwnd)
				Local $hparent = _winapi_getparent($hwnd)
				$destroyed = _winapi_destroywindow($hwnd)
				$iresult = _udf_freeglobalid($hparent, $nctrlid)
				If NOT $iresult Then
				EndIf
			Else
				_winapi_showmsg("Not Allowed to Destroy Other Applications Control(s)")
				Return SetError(1, 1, False)
			EndIf
		Else
			$destroyed = GUICtrlDelete($hwnd)
		EndIf
		If $destroyed Then $hwnd = 0
		Return $destroyed <> 0
	EndIf
	Return SetError(2, 2, False)
EndFunc

Func _guictrlbutton_enable($hwnd, $fenable = True)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If _winapi_isclassname($hwnd, $_buttonconstants_classname) Then Return _winapi_enablewindow($hwnd, $fenable) = $fenable
EndFunc

Func _guictrlbutton_getcheck($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $bm_getcheck)
EndFunc

Func _guictrlbutton_getfocus($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If _winapi_isclassname($hwnd, $_buttonconstants_classname) Then Return _winapi_getfocus() = $hwnd
EndFunc

Func _guictrlbutton_getidealsize($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $tsize = DllStructCreate($tagsize), $asize[2], $iresult
	$iresult = _sendmessage($hwnd, $bcm_getidealsize, 0, DllStructGetPtr($tsize))
	If NOT $iresult Then Return SetError(-1, -1, $asize)
	$asize[0] = DllStructGetData($tsize, "X")
	$asize[1] = DllStructGetData($tsize, "Y")
	Return $asize
EndFunc

Func _guictrlbutton_getimage($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $iresult = _sendmessage($hwnd, $bm_getimage, 0, 0, 0, "wparam", "lparam", "hwnd")
	If $iresult <> 0 Then Return $iresult
	$iresult = _sendmessage($hwnd, $bm_getimage, 1, 0, 0, "wparam", "lparam", "hwnd")
	If $iresult = 0 Then Return 0
	Return $iresult
EndFunc

Func _guictrlbutton_getimagelist($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $tbutton_imagelist = DllStructCreate($tagbutton_imagelist), $aimagelist[6]
	If NOT _sendmessage($hwnd, $bcm_getimagelist, 0, DllStructGetPtr($tbutton_imagelist)) Then Return SetError(-1, -1, $aimagelist)
	$aimagelist[0] = DllStructGetData($tbutton_imagelist, "ImageList")
	$aimagelist[1] = DllStructGetData($tbutton_imagelist, "Left")
	$aimagelist[2] = DllStructGetData($tbutton_imagelist, "Right")
	$aimagelist[3] = DllStructGetData($tbutton_imagelist, "Top")
	$aimagelist[4] = DllStructGetData($tbutton_imagelist, "Bottom")
	$aimagelist[5] = DllStructGetData($tbutton_imagelist, "Align")
	Return $aimagelist
EndFunc

Func _guictrlbutton_getnote($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $tnote, $ilen, $tlen
	$ilen = _guictrlbutton_getnotelength($hwnd) + 1
	$tnote = DllStructCreate("wchar Note[" & $ilen & "]")
	$tlen = DllStructCreate("dword")
	DllStructSetData($tlen, 1, $ilen)
	If NOT _sendmessage($hwnd, $bcm_getnote, DllStructGetPtr($tlen), DllStructGetPtr($tnote)) Then Return SetError(-1, 0, "")
	Return _winapi_widechartomultibyte(DllStructGetPtr($tnote))
EndFunc

Func _guictrlbutton_getnotelength($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $bcm_getnotelength)
EndFunc

Func _guictrlbutton_getsplitinfo($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $tsplitinfo = DllStructCreate($tagbutton_splitinfo), $ainfo[4]
	DllStructSetData($tsplitinfo, "mask", BitOR($bcsif_glyph, $bcsif_image, $bcsif_size, $bcsif_style))
	If NOT _sendmessage($hwnd, $bcm_getsplitinfo, 0, DllStructGetPtr($tsplitinfo)) Then Return SetError(-1, 0, $ainfo)
	$ainfo[0] = DllStructGetData($tsplitinfo, "himlGlyph")
	$ainfo[1] = DllStructGetData($tsplitinfo, "uSplitStyle")
	$ainfo[2] = DllStructGetData($tsplitinfo, "X")
	$ainfo[3] = DllStructGetData($tsplitinfo, "Y")
	Return $ainfo
EndFunc

Func _guictrlbutton_getstate($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $bm_getstate)
EndFunc

Func _guictrlbutton_gettext($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If _winapi_isclassname($hwnd, $_buttonconstants_classname) Then Return _winapi_getwindowtext($hwnd)
	Return ""
EndFunc

Func _guictrlbutton_gettextmargin($hwnd)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $trect = DllStructCreate("int Left;int Top;int Right;int Bottom"), $arect[4]
	If NOT _sendmessage($hwnd, $bcm_gettextmargin, 0, DllStructGetPtr($trect)) Then Return SetError(-1, -1, $arect)
	$arect[0] = DllStructGetData($trect, "Left")
	$arect[1] = DllStructGetData($trect, "Top")
	$arect[2] = DllStructGetData($trect, "Right")
	$arect[3] = DllStructGetData($trect, "Bottom")
	Return $arect
EndFunc

Func _guictrlbutton_setcheck($hwnd, $istate = $bst_checked)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	_sendmessage($hwnd, $bm_setcheck, $istate)
EndFunc

Func _guictrlbutton_setdontclick($hwnd, $fstate = True)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	_sendmessage($hwnd, $bm_setdontclick, $fstate)
EndFunc

Func _guictrlbutton_setdropdownstate($hwnd, $fstate = True)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $bcm_setdropdownstate, $fstate) <> 0
EndFunc

Func _guictrlbutton_setfocus($hwnd, $ffocus = True)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If _winapi_isclassname($hwnd, $_buttonconstants_classname) Then
		If $ffocus Then
			Return _winapi_setfocus($hwnd) <> 0
		Else
			Return _winapi_setfocus(_winapi_getparent($hwnd)) <> 0
		EndIf
	EndIf
EndFunc

Func _guictrlbutton_setimage($hwnd, $simagefile, $niconid = -1, $flarge = False)
	Local $himage, $hprevimage
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If StringUpper(StringMid($simagefile, StringLen($simagefile) - 2)) = "BMP" Then
		If BitAND(_winapi_getwindowlong($hwnd, $_buttonconstants_gwl_style), $bs_bitmap) = $bs_bitmap Then
			$himage = _winapi_loadimage(0, $simagefile, 0, 0, 0, BitOR($_buttonconstants_lr_loadfromfile, $_buttonconstants_lr_createdibsection))
			If NOT $himage Then Return SetError(-1, -1, False)
			$hprevimage = _sendmessage($hwnd, $bm_setimage, 0, $himage)
			If $hprevimage Then
				If NOT _winapi_deleteobject($hprevimage) Then _winapi_destroyicon($hprevimage)
			EndIf
			_winapi_updatewindow($hwnd)
			Return True
		EndIf
	Else
		If $niconid = -1 Then
			$himage = _winapi_loadimage(0, $simagefile, 1, 0, 0, BitOR($_buttonconstants_lr_loadfromfile, $_buttonconstants_lr_createdibsection))
			If NOT $himage Then Return SetError(-1, -1, False)
			$hprevimage = _sendmessage($hwnd, $bm_setimage, 1, $himage)
			If $hprevimage Then
				If NOT _winapi_deleteobject($hprevimage) Then _winapi_destroyicon($hprevimage)
			EndIf
			_winapi_updatewindow($hwnd)
			Return True
		Else
			Local $ticon, $iresult
			$ticon = DllStructCreate("hwnd Handle")
			If $flarge Then
				$iresult = _winapi_extracticonex($simagefile, $niconid, DllStructGetPtr($ticon), 0, 1)
			Else
				$iresult = _winapi_extracticonex($simagefile, $niconid, 0, DllStructGetPtr($ticon), 1)
			EndIf
			If NOT $iresult Then Return SetError(-1, -1, False)
			$hprevimage = _sendmessage($hwnd, $bm_setimage, 1, DllStructGetData($ticon, "Handle"))
			If $hprevimage Then
				If NOT _winapi_deleteobject($hprevimage) Then _winapi_destroyicon($hprevimage)
			EndIf
			_winapi_updatewindow($hwnd)
			Return True
		EndIf
	EndIf
	Return False
EndFunc

Func _guictrlbutton_setimagelist($hwnd, $himage, $nalign = 0, $ileft = 1, $itop = 1, $iright = 1, $ibottom = 1)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If $nalign < 0 OR $nalign > 4 Then $nalign = 0
	Local $tbutton_imagelist = DllStructCreate($tagbutton_imagelist), $iresult, $fenabled
	DllStructSetData($tbutton_imagelist, "ImageList", $himage)
	DllStructSetData($tbutton_imagelist, "Left", $ileft)
	DllStructSetData($tbutton_imagelist, "Top", $itop)
	DllStructSetData($tbutton_imagelist, "Right", $iright)
	DllStructSetData($tbutton_imagelist, "Bottom", $ibottom)
	DllStructSetData($tbutton_imagelist, "Align", $nalign)
	$fenabled = _guictrlbutton_enable($hwnd, False)
	$iresult = _sendmessage($hwnd, $bcm_setimagelist, 0, DllStructGetPtr($tbutton_imagelist)) <> 0
	_guictrlbutton_enable($hwnd)
	If NOT $fenabled Then _guictrlbutton_enable($hwnd, False)
	Return $iresult
EndFunc

Func _guictrlbutton_setnote($hwnd, $snote)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $tnote = _winapi_multibytetowidechar($snote)
	Return _sendmessage($hwnd, $bcm_setnote, 0, DllStructGetPtr($tnote)) <> 0
EndFunc

Func _guictrlbutton_setshield($hwnd, $frequired = True)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $bcm_setshield, 0, $frequired) = 1
EndFunc

Func _guictrlbutton_setsize($hwnd, $iwidth, $iheight)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If _winapi_isclassname($hwnd, $_buttonconstants_classname) Then
		Local $hparent = _winapi_getparent($hwnd), $iresult
		If NOT $hparent Then Return SetError(-1, -1, False)
		Local $apos = WinGetPos($hwnd)
		If NOT IsArray($apos) Then Return SetError(-1, -1, False)
		Local $tpoint = DllStructCreate($tagpoint)
		DllStructSetData($tpoint, "X", $apos[0])
		DllStructSetData($tpoint, "Y", $apos[1])
		If NOT _winapi_screentoclient($hparent, $tpoint) Then Return SetError(-1, -1, False)
		$iresult = WinMove($hwnd, "", DllStructGetData($tpoint, "X"), DllStructGetData($tpoint, "Y"), $iwidth, $iheight)
		Return SetError($iresult - 1, $iresult - 1, $iresult <> 0)
	EndIf
EndFunc

Func _guictrlbutton_setsplitinfo($hwnd, $himlglyph = -1, $isplitstyle = $bcss_alignleft, $iwidth = 0, $iheight = 0)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $tsplitinfo = DllStructCreate($tagbutton_splitinfo), $imask = 0
	If $himlglyph <> -1 Then
		$imask = BitOR($imask, $bcsif_glyph)
		DllStructSetData($tsplitinfo, "himlGlyph", $himlglyph)
	EndIf
	$imask = BitOR($imask, $bcsif_style)
	If BitAND($isplitstyle, $bcss_image) = $bcss_image Then $imask = BitOR($imask, $bcsif_image)
	DllStructSetData($tsplitinfo, "uSplitStyle", $isplitstyle)
	If $iwidth > 0 OR $iheight > 0 Then
		$imask = BitOR($imask, $bcsif_size)
		DllStructSetData($tsplitinfo, "X", $iwidth)
		DllStructSetData($tsplitinfo, "Y", $iheight)
	EndIf
	DllStructSetData($tsplitinfo, "mask", $imask)
	Return _sendmessage($hwnd, $bcm_setsplitinfo, 0, DllStructGetPtr($tsplitinfo)) <> 0
EndFunc

Func _guictrlbutton_setstate($hwnd, $fhighlighted = True)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	_sendmessage($hwnd, $bm_setstate, $fhighlighted)
EndFunc

Func _guictrlbutton_setstyle($hwnd, $istyle)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	_sendmessage($hwnd, $bm_setstyle, $istyle, True)
	_winapi_updatewindow($hwnd)
EndFunc

Func _guictrlbutton_settext($hwnd, $stext)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If _winapi_isclassname($hwnd, $_buttonconstants_classname) Then Return _winapi_setwindowtext($hwnd, $stext)
EndFunc

Func _guictrlbutton_settextmargin($hwnd, $ileft = 1, $itop = 1, $iright = 1, $ibottom = 1)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $trect = DllStructCreate("int Left;int Top;int Right;int Bottom")
	DllStructSetData($trect, "Left", $ileft)
	DllStructSetData($trect, "Top", $itop)
	DllStructSetData($trect, "Right", $iright)
	DllStructSetData($trect, "Bottom", $ibottom)
	Return _sendmessage($hwnd, $bcm_settextmargin, 0, DllStructGetPtr($trect)) <> 0
EndFunc

Func _guictrlbutton_show($hwnd, $fshow = True)
	If $debug_btn Then _guictrlbutton_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	If _winapi_isclassname($hwnd, $_buttonconstants_classname) Then
		If $fshow Then
			Return _winapi_showwindow($hwnd, @SW_SHOW)
		Else
			Return _winapi_showwindow($hwnd, @SW_HIDE)
		EndIf
	EndIf
EndFunc

Func _guictrlbutton_validateclassname($hwnd)
	_guictrlbutton_debugprint("This is for debugging only, set the debug variable to false before submitting")
	_winapi_validateclassname($hwnd, $_buttonconstants_classname)
EndFunc

Global Const $lvs_alignleft = 2048
Global Const $lvs_alignmask = 3072
Global Const $lvs_aligntop = 0
Global Const $lvs_autoarrange = 256
Global Const $lvs_default = 13
Global Const $lvs_editlabels = 512
Global Const $lvs_icon = 0
Global Const $lvs_list = 3
Global Const $lvs_nocolumnheader = 16384
Global Const $lvs_nolabelwrap = 128
Global Const $lvs_noscroll = 8192
Global Const $lvs_nosortheader = 32768
Global Const $lvs_ownerdata = 4096
Global Const $lvs_ownerdrawfixed = 1024
Global Const $lvs_report = 1
Global Const $lvs_shareimagelists = 64
Global Const $lvs_showselalways = 8
Global Const $lvs_singlesel = 4
Global Const $lvs_smallicon = 2
Global Const $lvs_sortascending = 16
Global Const $lvs_sortdescending = 32
Global Const $lvs_typemask = 3
Global Const $lvs_typestylemask = 64512
Global Const $lvs_ex_autoautoarrange = 16777216
Global Const $lvs_ex_autocheckselect = 134217728
Global Const $lvs_ex_autosizecolumns = 268435456
Global Const $lvs_ex_borderselect = 32768
Global Const $lvs_ex_checkboxes = 4
Global Const $lvs_ex_columnoverflow = -2147483648
Global Const $lvs_ex_columnsnappoints = 1073741824
Global Const $lvs_ex_doublebuffer = 65536
Global Const $lvs_ex_flatsb = 256
Global Const $lvs_ex_fullrowselect = 32
Global Const $lvs_ex_gridlines = 1
Global Const $lvs_ex_headerdragdrop = 16
Global Const $lvs_ex_headerinallviews = 33554432
Global Const $lvs_ex_hidelabels = 131072
Global Const $lvs_ex_infotip = 1024
Global Const $lvs_ex_justifycolumns = 2097152
Global Const $lvs_ex_labeltip = 16384
Global Const $lvs_ex_multiworkareas = 8192
Global Const $lvs_ex_oneclickactivate = 64
Global Const $lvs_ex_regional = 512
Global Const $lvs_ex_simpleselect = 1048576
Global Const $lvs_ex_snaptogrid = 524288
Global Const $lvs_ex_subitemimages = 2
Global Const $lvs_ex_trackselect = 8
Global Const $lvs_ex_transparentbkgnd = 4194304
Global Const $lvs_ex_transparentshadowtext = 8388608
Global Const $lvs_ex_twoclickactivate = 128
Global Const $lvs_ex_underlinecold = 4096
Global Const $lvs_ex_underlinehot = 2048
Global Const $lvgs_normal = 0
Global Const $lvgs_collapsed = 1
Global Const $lvgs_hidden = 2
Global Const $lvgs_noheader = 4
Global Const $lvgs_collapsible = 8
Global Const $lvgs_focused = 16
Global Const $lvgs_selected = 32
Global Const $lvgs_subseted = 64
Global Const $lvgs_subsetlinkfocused = 128
Global Const $lvggr_group = 0
Global Const $lvggr_header = 1
Global Const $lvggr_label = 2
Global Const $lvggr_subsetlink = 3
Global Const $lv_err = -1
Global Const $lvm_first = 4096
Global Const $lvbkif_source_none = 0
Global Const $lvbkif_source_hbitmap = 1
Global Const $lvbkif_source_url = 2
Global Const $lvbkif_source_mask = 3
Global Const $lvbkif_style_normal = 0
Global Const $lvbkif_style_tile = 16
Global Const $lvbkif_style_mask = 16
Global Const $lvbkif_flag_tileoffset = 256
Global Const $lvbkif_type_watermark = 268435456
Global Const $lv_view_details = 1
Global Const $lv_view_icon = 0
Global Const $lv_view_list = 3
Global Const $lv_view_smallicon = 2
Global Const $lv_view_tile = 4
Global Const $lva_alignleft = 1
Global Const $lva_aligntop = 2
Global Const $lva_default = 0
Global Const $lva_snaptogrid = 5
Global Const $lvcdi_item = 0
Global Const $lvcdi_group = 1
Global Const $lvcf_alldata = 63
Global Const $lvcf_fmt = 1
Global Const $lvcf_image = 16
Global Const $lvcfmt_justifymask = 3
Global Const $lvcf_text = 4
Global Const $lvcf_width = 2
Global Const $lvcfmt_bitmap_on_right = 4096
Global Const $lvcfmt_center = 2
Global Const $lvcfmt_col_has_images = 32768
Global Const $lvcfmt_image = 2048
Global Const $lvcfmt_left = 0
Global Const $lvcfmt_right = 1
Global Const $lvfi_nearestxy = 64
Global Const $lvfi_param = 1
Global Const $lvfi_partial = 8
Global Const $lvfi_string = 2
Global Const $lvfi_wrap = 32
Global Const $lvga_footer_left = 8
Global Const $lvga_footer_center = 16
Global Const $lvga_footer_right = 32
Global Const $lvga_header_left = 1
Global Const $lvga_header_center = 2
Global Const $lvga_header_right = 4
Global Const $lvgf_align = 8
Global Const $lvgf_descriptiontop = 1024
Global Const $lvgf_descriptionbottom = 2048
Global Const $lvgf_extendedimage = 8192
Global Const $lvgf_footer = 2
Global Const $lvgf_groupid = 16
Global Const $lvgf_header = 1
Global Const $lvgf_items = 16384
Global Const $lvgf_none = 0
Global Const $lvgf_state = 4
Global Const $lvgf_subset = 32768
Global Const $lvgf_subsetitems = 65536
Global Const $lvgf_subtitle = 256
Global Const $lvgf_task = 512
Global Const $lvgf_titleimage = 4096
Global Const $lvht_above = 8
Global Const $lvht_below = 16
Global Const $lvht_nowhere = 1
Global Const $lvht_onitemicon = 2
Global Const $lvht_onitemlabel = 4
Global Const $lvht_onitemstateicon = 8
Global Const $lvht_toleft = 64
Global Const $lvht_toright = 32
Global Const $lvht_onitem = BitOR($lvht_onitemicon, $lvht_onitemlabel, $lvht_onitemstateicon)
Global Const $lvif_colfmt = 65536
Global Const $lvif_columns = 512
Global Const $lvif_groupid = 256
Global Const $lvif_image = 2
Global Const $lvif_indent = 16
Global Const $lvif_norecompute = 2048
Global Const $lvif_param = 4
Global Const $lvif_state = 8
Global Const $lvif_text = 1
Global Const $lvim_after = 1
Global Const $lvir_bounds = 0
Global Const $lvir_icon = 1
Global Const $lvir_label = 2
Global Const $lvir_selectbounds = 3
Global Const $lvis_cut = 4
Global Const $lvis_drophilited = 8
Global Const $lvis_focused = 1
Global Const $lvis_overlaymask = 3840
Global Const $lvis_selected = 2
Global Const $lvis_stateimagemask = 61440
Global Const $lvm_approximateviewrect = ($lvm_first + 64)
Global Const $lvm_arrange = ($lvm_first + 22)
Global Const $lvm_canceleditlabel = ($lvm_first + 179)
Global Const $lvm_createdragimage = ($lvm_first + 33)
Global Const $lvm_deleteallitems = ($lvm_first + 9)
Global Const $lvm_deletecolumn = ($lvm_first + 28)
Global Const $lvm_deleteitem = ($lvm_first + 8)
Global Const $lvm_editlabela = ($lvm_first + 23)
Global Const $lvm_editlabelw = ($lvm_first + 118)
Global Const $lvm_editlabel = $lvm_editlabela
Global Const $lvm_enablegroupview = ($lvm_first + 157)
Global Const $lvm_ensurevisible = ($lvm_first + 19)
Global Const $lvm_finditem = ($lvm_first + 13)
Global Const $lvm_getbkcolor = ($lvm_first + 0)
Global Const $lvm_getbkimagea = ($lvm_first + 69)
Global Const $lvm_getbkimagew = ($lvm_first + 139)
Global Const $lvm_getcallbackmask = ($lvm_first + 10)
Global Const $lvm_getcolumna = ($lvm_first + 25)
Global Const $lvm_getcolumnw = ($lvm_first + 95)
Global Const $lvm_getcolumnorderarray = ($lvm_first + 59)
Global Const $lvm_getcolumnwidth = ($lvm_first + 29)
Global Const $lvm_getcountperpage = ($lvm_first + 40)
Global Const $lvm_geteditcontrol = ($lvm_first + 24)
Global Const $lvm_getemptytext = ($lvm_first + 204)
Global Const $lvm_getextendedlistviewstyle = ($lvm_first + 55)
Global Const $lvm_getfocusedgroup = ($lvm_first + 93)
Global Const $lvm_getfooterinfo = ($lvm_first + 206)
Global Const $lvm_getfooteritem = ($lvm_first + 208)
Global Const $lvm_getfooteritemrect = ($lvm_first + 207)
Global Const $lvm_getfooterrect = ($lvm_first + 205)
Global Const $lvm_getgroupcount = ($lvm_first + 152)
Global Const $lvm_getgroupinfo = ($lvm_first + 149)
Global Const $lvm_getgroupinfobyindex = ($lvm_first + 153)
Global Const $lvm_getgroupmetrics = ($lvm_first + 156)
Global Const $lvm_getgrouprect = ($lvm_first + 98)
Global Const $lvm_getgroupstate = ($lvm_first + 92)
Global Const $lvm_getheader = ($lvm_first + 31)
Global Const $lvm_gethotcursor = ($lvm_first + 63)
Global Const $lvm_gethotitem = ($lvm_first + 61)
Global Const $lvm_gethovertime = ($lvm_first + 72)
Global Const $lvm_getimagelist = ($lvm_first + 2)
Global Const $lvm_getinsertmark = ($lvm_first + 167)
Global Const $lvm_getinsertmarkcolor = ($lvm_first + 171)
Global Const $lvm_getinsertmarkrect = ($lvm_first + 169)
Global Const $lvm_getisearchstringa = ($lvm_first + 52)
Global Const $lvm_getisearchstringw = ($lvm_first + 117)
Global Const $lvm_getitema = ($lvm_first + 5)
Global Const $lvm_getitemw = ($lvm_first + 75)
Global Const $lvm_getitemcount = ($lvm_first + 4)
Global Const $lvm_getitemindexrect = ($lvm_first + 209)
Global Const $lvm_getitemposition = ($lvm_first + 16)
Global Const $lvm_getitemrect = ($lvm_first + 14)
Global Const $lvm_getitemspacing = ($lvm_first + 51)
Global Const $lvm_getitemstate = ($lvm_first + 44)
Global Const $lvm_getitemtexta = ($lvm_first + 45)
Global Const $lvm_getitemtextw = ($lvm_first + 115)
Global Const $lvm_getnextitem = ($lvm_first + 12)
Global Const $lvm_getnextitemindex = ($lvm_first + 211)
Global Const $lvm_getnumberofworkareas = ($lvm_first + 73)
Global Const $lvm_getorigin = ($lvm_first + 41)
Global Const $lvm_getoutlinecolor = ($lvm_first + 176)
Global Const $lvm_getselectedcolumn = ($lvm_first + 174)
Global Const $lvm_getselectedcount = ($lvm_first + 50)
Global Const $lvm_getselectionmark = ($lvm_first + 66)
Global Const $lvm_getstringwidtha = ($lvm_first + 17)
Global Const $lvm_getstringwidthw = ($lvm_first + 87)
Global Const $lvm_getsubitemrect = ($lvm_first + 56)
Global Const $lvm_gettextbkcolor = ($lvm_first + 37)
Global Const $lvm_gettextcolor = ($lvm_first + 35)
Global Const $lvm_gettileinfo = ($lvm_first + 165)
Global Const $lvm_gettileviewinfo = ($lvm_first + 163)
Global Const $lvm_gettooltips = ($lvm_first + 78)
Global Const $lvm_gettopindex = ($lvm_first + 39)
Global Const $lvm_getunicodeformat = 8192 + 6
Global Const $lvm_getview = ($lvm_first + 143)
Global Const $lvm_getviewrect = ($lvm_first + 34)
Global Const $lvm_getworkareas = ($lvm_first + 70)
Global Const $lvm_hasgroup = ($lvm_first + 161)
Global Const $lvm_hittest = ($lvm_first + 18)
Global Const $lvm_insertcolumna = ($lvm_first + 27)
Global Const $lvm_insertcolumnw = ($lvm_first + 97)
Global Const $lvm_insertgroup = ($lvm_first + 145)
Global Const $lvm_insertgroupsorted = ($lvm_first + 159)
Global Const $lvm_insertitema = ($lvm_first + 7)
Global Const $lvm_insertitemw = ($lvm_first + 77)
Global Const $lvm_insertmarkhittest = ($lvm_first + 168)
Global Const $lvm_isgroupviewenabled = ($lvm_first + 175)
Global Const $lvm_isitemvisible = ($lvm_first + 182)
Global Const $lvm_mapidtoindex = ($lvm_first + 181)
Global Const $lvm_mapindextoid = ($lvm_first + 180)
Global Const $lvm_movegroup = ($lvm_first + 151)
Global Const $lvm_redrawitems = ($lvm_first + 21)
Global Const $lvm_removeallgroups = ($lvm_first + 160)
Global Const $lvm_removegroup = ($lvm_first + 150)
Global Const $lvm_scroll = ($lvm_first + 20)
Global Const $lvm_setbkcolor = ($lvm_first + 1)
Global Const $lvm_setbkimagea = ($lvm_first + 68)
Global Const $lvm_setbkimagew = ($lvm_first + 138)
Global Const $lvm_setcallbackmask = ($lvm_first + 11)
Global Const $lvm_setcolumna = ($lvm_first + 26)
Global Const $lvm_setcolumnw = ($lvm_first + 96)
Global Const $lvm_setcolumnorderarray = ($lvm_first + 58)
Global Const $lvm_setcolumnwidth = ($lvm_first + 30)
Global Const $lvm_setextendedlistviewstyle = ($lvm_first + 54)
Global Const $lvm_setgroupinfo = ($lvm_first + 147)
Global Const $lvm_setgroupmetrics = ($lvm_first + 155)
Global Const $lvm_sethotcursor = ($lvm_first + 62)
Global Const $lvm_sethotitem = ($lvm_first + 60)
Global Const $lvm_sethovertime = ($lvm_first + 71)
Global Const $lvm_seticonspacing = ($lvm_first + 53)
Global Const $lvm_setimagelist = ($lvm_first + 3)
Global Const $lvm_setinfotip = ($lvm_first + 173)
Global Const $lvm_setinsertmark = ($lvm_first + 166)
Global Const $lvm_setinsertmarkcolor = ($lvm_first + 170)
Global Const $lvm_setitema = ($lvm_first + 6)
Global Const $lvm_setitemw = ($lvm_first + 76)
Global Const $lvm_setitemcount = ($lvm_first + 47)
Global Const $lvm_setitemindexstate = ($lvm_first + 210)
Global Const $lvm_setitemposition = ($lvm_first + 15)
Global Const $lvm_setitemposition32 = ($lvm_first + 49)
Global Const $lvm_setitemstate = ($lvm_first + 43)
Global Const $lvm_setitemtexta = ($lvm_first + 46)
Global Const $lvm_setitemtextw = ($lvm_first + 116)
Global Const $lvm_setoutlinecolor = ($lvm_first + 177)
Global Const $lvm_setselectedcolumn = ($lvm_first + 140)
Global Const $lvm_setselectionmark = ($lvm_first + 67)
Global Const $lvm_settextbkcolor = ($lvm_first + 38)
Global Const $lvm_settextcolor = ($lvm_first + 36)
Global Const $lvm_settileinfo = ($lvm_first + 164)
Global Const $lvm_settileviewinfo = ($lvm_first + 162)
Global Const $lvm_settilewidth = ($lvm_first + 141)
Global Const $lvm_settooltips = ($lvm_first + 74)
Global Const $lvm_setunicodeformat = 8192 + 5
Global Const $lvm_setview = ($lvm_first + 142)
Global Const $lvm_setworkareas = ($lvm_first + 65)
Global Const $lvm_sortgroups = ($lvm_first + 158)
Global Const $lvm_sortitems = ($lvm_first + 48)
Global Const $lvm_sortitemsex = ($lvm_first + 81)
Global Const $lvm_subitemhittest = ($lvm_first + 57)
Global Const $lvm_update = ($lvm_first + 42)
Global Const $lvn_first = -100
Global Const $lvn_last = -199
Global Const $lvn_begindrag = ($lvn_first - 9)
Global Const $lvn_beginlabeledita = ($lvn_first - 5)
Global Const $lvn_beginlabeleditw = ($lvn_first - 75)
Global Const $lvn_beginlabeledit = $lvn_beginlabeledita
Global Const $lvn_beginrdrag = ($lvn_first - 11)
Global Const $lvn_beginscroll = ($lvn_first - 80)
Global Const $lvn_columnclick = ($lvn_first - 8)
Global Const $lvn_columndropdown = ($lvn_first - 64)
Global Const $lvn_columnoverflowclick = ($lvn_first - 66)
Global Const $lvn_deleteallitems = ($lvn_first - 4)
Global Const $lvn_deleteitem = ($lvn_first - 3)
Global Const $lvn_endlabeledita = ($lvn_first - 6)
Global Const $lvn_endlabeleditw = ($lvn_first - 76)
Global Const $lvn_endlabeledit = $lvn_endlabeledita
Global Const $lvn_endscroll = ($lvn_first - 81)
Global Const $lvn_getdispinfoa = ($lvn_first - 50)
Global Const $lvn_getdispinfow = ($lvn_first - 77)
Global Const $lvn_getdispinfo = $lvn_getdispinfoa
Global Const $lvn_getemptymarkup = ($lvn_first - 87)
Global Const $lvn_getinfotipa = ($lvn_first - 57)
Global Const $lvn_getinfotipw = ($lvn_first - 58)
Global Const $lvn_getinfotip = $lvn_getinfotipa
Global Const $lvn_hottrack = ($lvn_first - 21)
Global Const $lvn_incrementalsearcha = ($lvn_first - 62)
Global Const $lvn_incrementalsearchw = ($lvn_first - 63)
Global Const $lvn_insertitem = ($lvn_first - 2)
Global Const $lvn_itemactivate = ($lvn_first - 14)
Global Const $lvn_itemchanged = ($lvn_first - 1)
Global Const $lvn_itemchanging = ($lvn_first - 0)
Global Const $lvn_keydown = ($lvn_first - 55)
Global Const $lvn_linkclick = ($lvn_first - 84)
Global Const $lvn_marqueebegin = ($lvn_first - 56)
Global Const $lvn_odcachehint = ($lvn_first - 13)
Global Const $lvn_odfinditema = ($lvn_first - 52)
Global Const $lvn_odfinditemw = ($lvn_first - 79)
Global Const $lvn_odfinditem = $lvn_odfinditema
Global Const $lvn_odstatechanged = ($lvn_first - 15)
Global Const $lvn_setdispinfoa = ($lvn_first - 51)
Global Const $lvn_setdispinfow = ($lvn_first - 78)
Global Const $lvn_setdispinfo = $lvn_setdispinfoa
Global Const $lvni_above = 256
Global Const $lvni_below = 512
Global Const $lvni_toleft = 1024
Global Const $lvni_toright = 2048
Global Const $lvni_all = 0
Global Const $lvni_cut = 4
Global Const $lvni_drophilited = 8
Global Const $lvni_focused = 1
Global Const $lvni_selected = 2
Global Const $lvscw_autosize = -1
Global Const $lvscw_autosize_useheader = -2
Global Const $lvsicf_noinvalidateall = 1
Global Const $lvsicf_noscroll = 2
Global Const $lvsil_normal = 0
Global Const $lvsil_small = 1
Global Const $lvsil_state = 2
Global Const $gui_ss_default_listview = BitOR($lvs_showselalways, $lvs_singlesel)
Global Const $__listviewconstant_ws_maximizebox = 65536
Global Const $__listviewconstant_ws_minimizebox = 131072
Global Const $hdf_left = 0
Global Const $hdf_right = 1
Global Const $hdf_center = 2
Global Const $hdf_justifymask = 3
Global Const $hdf_bitmap_on_right = 4096
Global Const $hdf_bitmap = 8192
Global Const $hdf_string = 16384
Global Const $hdf_ownerdraw = 32768
Global Const $hdf_displaymask = 61440
Global Const $hdf_rtlreading = 4
Global Const $hdf_sortdown = 512
Global Const $hdf_image = 2048
Global Const $hdf_sortup = 1024
Global Const $hdf_flagmask = 3588
Global Const $hdi_width = 1
Global Const $hdi_text = 2
Global Const $hdi_format = 4
Global Const $hdi_param = 8
Global Const $hdi_bitmap = 16
Global Const $hdi_image = 32
Global Const $hdi_di_setitem = 64
Global Const $hdi_order = 128
Global Const $hdi_filter = 256
Global Const $hht_nowhere = 1
Global Const $hht_onheader = 2
Global Const $hht_ondivider = 4
Global Const $hht_ondivopen = 8
Global Const $hht_onfilter = 16
Global Const $hht_onfilterbutton = 32
Global Const $hht_above = 256
Global Const $hht_below = 512
Global Const $hht_toright = 1024
Global Const $hht_toleft = 2048
Global Const $hdm_first = 4608
Global Const $hdm_clearfilter = $hdm_first + 24
Global Const $hdm_createdragimage = $hdm_first + 16
Global Const $hdm_deleteitem = $hdm_first + 2
Global Const $hdm_editfilter = $hdm_first + 23
Global Const $hdm_getbitmapmargin = $hdm_first + 21
Global Const $hdm_getfocuseditem = $hdm_first + 27
Global Const $hdm_getimagelist = $hdm_first + 9
Global Const $hdm_getitem = $hdm_first + 3
Global Const $hdm_getitemw = $hdm_first + 11
Global Const $hdm_getitemcount = $hdm_first + 0
Global Const $hdm_getitemdropdownrect = $hdm_first + 25
Global Const $hdm_getitemrect = $hdm_first + 7
Global Const $hdm_getorderarray = $hdm_first + 17
Global Const $hdm_getoverflowrect = $hdm_first + 26
Global Const $hdm_getunicodeformat = 8192 + 6
Global Const $hdm_hittest = $hdm_first + 6
Global Const $hdm_insertitem = $hdm_first + 1
Global Const $hdm_insertitemw = $hdm_first + 10
Global Const $hdm_layout = $hdm_first + 5
Global Const $hdm_ordertoindex = $hdm_first + 15
Global Const $hdm_setbitmapmargin = $hdm_first + 20
Global Const $hdm_setfilterchangetimeout = $hdm_first + 22
Global Const $hdm_setfocuseditem = $hdm_first + 28
Global Const $hdm_sethotdivider = $hdm_first + 19
Global Const $hdm_setimagelist = $hdm_first + 8
Global Const $hdm_setitem = $hdm_first + 4
Global Const $hdm_setitemw = $hdm_first + 12
Global Const $hdm_setorderarray = $hdm_first + 18
Global Const $hdm_setunicodeformat = 8192 + 5
Global Const $hdn_begindrag = -310
Global Const $hdn_begintrack = -306
Global Const $hdn_dividerdblclick = -305
Global Const $hdn_enddrag = -311
Global Const $hdn_endtrack = -307
Global Const $hdn_filterbtnclick = -313
Global Const $hdn_filterchange = -312
Global Const $hdn_getdispinfo = -309
Global Const $hdn_itemchanged = -301
Global Const $hdn_itemchanging = -300
Global Const $hdn_itemclick = -302
Global Const $hdn_itemdblclick = -303
Global Const $hdn_track = -308
Global Const $hdn_begintrackw = -326
Global Const $hdn_dividerdblclickw = -325
Global Const $hdn_endtrackw = -327
Global Const $hdn_getdispinfow = -329
Global Const $hdn_itemchangedw = -321
Global Const $hdn_itemchangingw = -320
Global Const $hdn_itemclickw = -322
Global Const $hdn_itemdblclickw = -323
Global Const $hdn_trackw = -328
Global Const $hds_buttons = 2
Global Const $hds_checkboxes = 1024
Global Const $hds_dragdrop = 64
Global Const $hds_filterbar = 256
Global Const $hds_flat = 512
Global Const $hds_fulldrag = 128
Global Const $hds_hidden = 8
Global Const $hds_horz = 0
Global Const $hds_hottrack = 4
Global Const $hds_nosizing = 2048
Global Const $hds_overflow = 4096
Global Const $hds_default = 70
Global $_ghhdrlastwnd
Global $debug_hdr = False
Global Const $__headerconstant_classname = "SysHeader32"
Global Const $__headerconstant_ws_visible = 268435456
Global Const $__headerconstant_ws_child = 1073741824
Global Const $__headerconstant_default_gui_font = 17
Global Const $__headerconstant_swp_showwindow = 64

Func _guictrlheader_additem($hwnd, $stext, $iwidth = 50, $ialign = 0, $iimage = -1, $fonright = False)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _guictrlheader_insertitem($hwnd, _guictrlheader_getitemcount($hwnd), $stext, $iwidth, $ialign, $iimage, $fonright)
EndFunc

Func _guictrlheader_clearfilter($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_clearfilter, $iindex) <> 0
EndFunc

Func _guictrlheader_clearfilterall($hwnd)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_clearfilter, -1) <> 0
EndFunc

Func _guictrlheader_create($hwnd, $istyle = 70)
	Local $hheader, $trect, $twindowpos, $iflags, $nctrlid
	$istyle = BitOR($istyle, $__headerconstant_ws_child, $__headerconstant_ws_visible)
	$nctrlid = _udf_getnextglobalid($hwnd)
	If @error Then Return SetError(@error, @extended, 0)
	$hheader = _winapi_createwindowex(0, $__headerconstant_classname, "", $istyle, 0, 0, 0, 0, $hwnd, $nctrlid)
	$trect = _winapi_getclientrect($hwnd)
	$twindowpos = _guictrlheader_layout($hheader, $trect)
	$iflags = BitOR(DllStructGetData($twindowpos, "Flags"), $__headerconstant_swp_showwindow)
	_winapi_setwindowpos($hheader, DllStructGetData($twindowpos, "InsertAfter"), DllStructGetData($twindowpos, "X"), DllStructGetData($twindowpos, "Y"), DllStructGetData($twindowpos, "CX"), DllStructGetData($twindowpos, "CY"), $iflags)
	_winapi_setfont($hheader, _winapi_getstockobject($__headerconstant_default_gui_font))
	_guictrlheader_setunicodeformat($hheader, False)
	Return $hheader
EndFunc

Func _guictrlheader_createdragimage($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_createdragimage, $iindex)
EndFunc

Func _guictrlheader_debugprint($stext, $iline = @ScriptLineNumber)
	ConsoleWrite("!===========================================================" & @LF & "+======================================================" & @LF & "-->Line(" & StringFormat("%04d", $iline) & "):" & @TAB & $stext & @LF & "+======================================================" & @LF)
EndFunc

Func _guictrlheader_deleteitem($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_deleteitem, $iindex) <> 0
EndFunc

Func _guictrlheader_destroy(ByRef $hwnd)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $iresult, $destroyed
	If _winapi_isclassname($hwnd, $__headerconstant_classname) Then
		If IsHWnd($hwnd) Then
			If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
				Local $nctrlid = _winapi_getdlgctrlid($hwnd)
				Local $hparent = _winapi_getparent($hwnd)
				$destroyed = _winapi_destroywindow($hwnd)
				$iresult = _udf_freeglobalid($hparent, $nctrlid)
				If NOT $iresult Then
				EndIf
			Else
				_winapi_showmsg("Not Allowed to Destroy Other Applications Control(s)")
				Return SetError(1, 1, False)
			EndIf
		Else
			$destroyed = GUICtrlDelete($hwnd)
		EndIf
		If $destroyed Then $hwnd = 0
		Return $destroyed <> 0
	EndIf
	Return SetError(2, 2, False)
EndFunc

Func _guictrlheader_editfilter($hwnd, $iindex, $fdiscard = True)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_editfilter, $iindex, $fdiscard) <> 0
EndFunc

Func _guictrlheader_getbitmapmargin($hwnd)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_getbitmapmargin)
EndFunc

Func _guictrlheader_getimagelist($hwnd)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_getimagelist)
EndFunc

Func _guictrlheader_getitem($hwnd, $iindex, ByRef $titem)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $iitem, $pitem, $pmemory, $tmemmap, $iresult
	Local $funicode = _guictrlheader_getunicodeformat($hwnd)
	$pitem = DllStructGetPtr($titem)
	If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
		If $funicode Then
			$iresult = _sendmessage($hwnd, $hdm_getitemw, $iindex, $pitem, 0, "wparam", "ptr")
		Else
			$iresult = _sendmessage($hwnd, $hdm_getitem, $iindex, $pitem, 0, "wparam", "ptr")
		EndIf
	Else
		$iitem = DllStructGetSize($titem)
		$pmemory = _meminit($hwnd, $iitem, $tmemmap)
		_memwrite($tmemmap, $pitem)
		If $funicode Then
			$iresult = _sendmessage($hwnd, $hdm_getitemw, $iindex, $pmemory, 0, "wparam", "ptr")
		Else
			$iresult = _sendmessage($hwnd, $hdm_getitem, $iindex, $pmemory, 0, "wparam", "ptr")
		EndIf
		_memread($tmemmap, $pmemory, $pitem, $iitem)
		_memfree($tmemmap)
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrlheader_getitemalign($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Switch BitAND(_guictrlheader_getitemformat($hwnd, $iindex), $hdf_justifymask)
		Case $hdf_left
			Return 0
		Case $hdf_right
			Return 1
		Case $hdf_center
			Return 2
		Case Else
			Return -1
	EndSwitch
EndFunc

Func _guictrlheader_getitembitmap($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_bitmap)
	_guictrlheader_getitem($hwnd, $iindex, $titem)
	Return DllStructGetData($titem, "hBmp")
EndFunc

Func _guictrlheader_getitemcount($hwnd)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_getitemcount)
EndFunc

Func _guictrlheader_getitemdisplay($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $iformat, $iresult = 0
	$iformat = _guictrlheader_getitemformat($hwnd, $iindex)
	If BitAND($iformat, $hdf_bitmap) <> 0 Then $iresult = BitOR($iresult, 1)
	If BitAND($iformat, $hdf_bitmap_on_right) <> 0 Then $iresult = BitOR($iresult, 2)
	If BitAND($iformat, $hdf_ownerdraw) <> 0 Then $iresult = BitOR($iresult, 4)
	If BitAND($iformat, $hdf_string) <> 0 Then $iresult = BitOR($iresult, 8)
	Return $iresult
EndFunc

Func _guictrlheader_getitemflags($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $iformat, $iresult = 0
	$iformat = _guictrlheader_getitemformat($hwnd, $iindex)
	If BitAND($iformat, $hdf_image) <> 0 Then $iresult = BitOR($iresult, 1)
	If BitAND($iformat, $hdf_rtlreading) <> 0 Then $iresult = BitOR($iresult, 2)
	If BitAND($iformat, $hdf_sortdown) <> 0 Then $iresult = BitOR($iresult, 4)
	If BitAND($iformat, $hdf_sortup) <> 0 Then $iresult = BitOR($iresult, 8)
	Return $iresult
EndFunc

Func _guictrlheader_getitemformat($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_format)
	_guictrlheader_getitem($hwnd, $iindex, $titem)
	Return DllStructGetData($titem, "Fmt")
EndFunc

Func _guictrlheader_getitemimage($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_image)
	_guictrlheader_getitem($hwnd, $iindex, $titem)
	Return DllStructGetData($titem, "Image")
EndFunc

Func _guictrlheader_getitemorder($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_order)
	_guictrlheader_getitem($hwnd, $iindex, $titem)
	Return DllStructGetData($titem, "Order")
EndFunc

Func _guictrlheader_getitemparam($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_param)
	_guictrlheader_getitem($hwnd, $iindex, $titem)
	Return DllStructGetData($titem, "Param")
EndFunc

Func _guictrlheader_getitemrect($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $trect, $arect[4]
	$trect = _guictrlheader_getitemrectex($hwnd, $iindex)
	$arect[0] = DllStructGetData($trect, "Left")
	$arect[1] = DllStructGetData($trect, "Top")
	$arect[2] = DllStructGetData($trect, "Right")
	$arect[3] = DllStructGetData($trect, "Bottom")
	Return $arect
EndFunc

Func _guictrlheader_getitemrectex($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $irect, $prect, $trect, $pmemory, $tmemmap
	$trect = DllStructCreate($tagrect)
	$prect = DllStructGetPtr($trect)
	If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
		_sendmessage($hwnd, $hdm_getitemrect, $iindex, $prect, 0, "wparam", "ptr")
	Else
		$irect = DllStructGetSize($trect)
		$pmemory = _meminit($hwnd, $irect, $tmemmap)
		_memwrite($tmemmap, $prect)
		_sendmessage($hwnd, $hdm_getitemrect, $iindex, $pmemory, 0, "wparam", "ptr")
		_memread($tmemmap, $pmemory, $prect, $irect)
		_memfree($tmemmap)
	EndIf
	Return $trect
EndFunc

Func _guictrlheader_getitemtext($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $pbuffer, $tbuffer, $iitem, $pitem, $titem, $pmemory, $tmemmap, $ptext
	Local $funicode = _guictrlheader_getunicodeformat($hwnd)
	If $funicode Then
		$tbuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tbuffer = DllStructCreate("char Text[4096]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$titem = DllStructCreate($taghditem)
	$pitem = DllStructGetPtr($titem)
	DllStructSetData($titem, "Mask", $hdi_text)
	DllStructSetData($titem, "TextMax", 4096)
	If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
		DllStructSetData($titem, "Text", $pbuffer)
		If $funicode Then
			_sendmessage($hwnd, $hdm_getitemw, $iindex, $pitem, 0, "wparam", "ptr")
		Else
			_sendmessage($hwnd, $hdm_getitem, $iindex, $pitem, 0, "wparam", "ptr")
		EndIf
	Else
		$iitem = DllStructGetSize($titem)
		$pmemory = _meminit($hwnd, $iitem + 4096, $tmemmap)
		$ptext = $pmemory + $iitem
		DllStructSetData($titem, "Text", $ptext)
		_memwrite($tmemmap, $pitem, $pmemory, $iitem)
		If $funicode Then
			_sendmessage($hwnd, $hdm_getitemw, $iindex, $pmemory, 0, "wparam", "ptr")
		Else
			_sendmessage($hwnd, $hdm_getitem, $iindex, $pmemory, 0, "wparam", "ptr")
		EndIf
		_memread($tmemmap, $ptext, $pbuffer, 4096)
		_memfree($tmemmap)
	EndIf
	Return DllStructGetData($tbuffer, "Text")
EndFunc

Func _guictrlheader_getitemwidth($hwnd, $iindex)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_width)
	_guictrlheader_getitem($hwnd, $iindex, $titem)
	Return DllStructGetData($titem, "XY")
EndFunc

Func _guictrlheader_getorderarray($hwnd)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $ii, $ibuffer, $pbuffer, $tbuffer, $iitems, $pmemory, $tmemmap
	$iitems = _guictrlheader_getitemcount($hwnd)
	$tbuffer = DllStructCreate("int[" & $iitems & "]")
	$pbuffer = DllStructGetPtr($tbuffer)
	If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
		_sendmessage($hwnd, $hdm_getorderarray, $iitems, $pbuffer, 0, "wparam", "ptr")
	Else
		$ibuffer = DllStructGetSize($tbuffer)
		$pmemory = _meminit($hwnd, $ibuffer, $tmemmap)
		_sendmessage($hwnd, $hdm_getorderarray, $iitems, $pmemory, 0, "wparam", "ptr")
		_memread($tmemmap, $pmemory, $pbuffer, $ibuffer)
		_memfree($tmemmap)
	EndIf
	Local $abuffer[$iitems + 1]
	$abuffer[0] = $iitems
	For $ii = 1 To $iitems
		$abuffer[$ii] = DllStructGetData($tbuffer, 1, $ii)
	Next
	Return $abuffer
EndFunc

Func _guictrlheader_getunicodeformat($hwnd)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_getunicodeformat) <> 0
EndFunc

Func _guictrlheader_hittest($hwnd, $ix, $iy)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $itest, $ptest, $ttest, $pmemory, $tmemmap, $iflags, $atest[11]
	$ttest = DllStructCreate($taghdhittestinfo)
	$ptest = DllStructGetPtr($ttest)
	DllStructSetData($ttest, "X", $ix)
	DllStructSetData($ttest, "Y", $iy)
	If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
		$atest[0] = _sendmessage($hwnd, $hdm_hittest, 0, $ptest, 0, "wparam", "ptr")
	Else
		$itest = DllStructGetSize($ttest)
		$pmemory = _meminit($hwnd, $itest, $tmemmap)
		_memwrite($tmemmap, $ptest)
		$atest[0] = _sendmessage($hwnd, $hdm_hittest, 0, $pmemory, 0, "wparam", "ptr")
		_memread($tmemmap, $pmemory, $ptest, $itest)
		_memfree($tmemmap)
	EndIf
	$iflags = DllStructGetData($ttest, "Flags")
	$atest[1] = BitAND($iflags, $hht_nowhere) <> 0
	$atest[2] = BitAND($iflags, $hht_onheader) <> 0
	$atest[3] = BitAND($iflags, $hht_ondivider) <> 0
	$atest[4] = BitAND($iflags, $hht_ondivopen) <> 0
	$atest[5] = BitAND($iflags, $hht_onfilter) <> 0
	$atest[6] = BitAND($iflags, $hht_onfilterbutton) <> 0
	$atest[7] = BitAND($iflags, $hht_above) <> 0
	$atest[8] = BitAND($iflags, $hht_below) <> 0
	$atest[9] = BitAND($iflags, $hht_toright) <> 0
	$atest[10] = BitAND($iflags, $hht_toleft) <> 0
	Return $atest
EndFunc

Func _guictrlheader_insertitem($hwnd, $iindex, $stext, $iwidth = 50, $ialign = 0, $iimage = -1, $fonright = False)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $ibuffer, $pbuffer, $tbuffer, $iitem, $pitem, $titem, $pmemory, $tmemmap, $ptext, $imask, $ifmt, $iresult
	Local $aalign[3] = [$hdf_left, $hdf_right, $hdf_center]
	Local $funicode = _guictrlheader_getunicodeformat($hwnd)
	$ibuffer = StringLen($stext) + 1
	If $funicode Then
		$ibuffer *= 2
		$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
	Else
		$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$titem = DllStructCreate($taghditem)
	$pitem = DllStructGetPtr($titem)
	$ifmt = $aalign[$ialign]
	$imask = BitOR($hdi_width, $hdi_format)
	If $stext <> "" Then
		$imask = BitOR($imask, $hdi_text)
		$ifmt = BitOR($ifmt, $hdf_string)
	EndIf
	If $iimage <> -1 Then
		$imask = BitOR($imask, $hdi_image)
		$ifmt = BitOR($ifmt, $hdf_image)
	EndIf
	If $fonright Then $ifmt = BitOR($ifmt, $hdf_bitmap_on_right)
	DllStructSetData($tbuffer, "Text", $stext)
	DllStructSetData($titem, "Mask", $imask)
	DllStructSetData($titem, "XY", $iwidth)
	DllStructSetData($titem, "Fmt", $ifmt)
	DllStructSetData($titem, "Image", $iimage)
	If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
		DllStructSetData($titem, "Text", $pbuffer)
		If $funicode Then
			$iresult = _sendmessage($hwnd, $hdm_insertitemw, $iindex, $pitem, 0, "wparam", "ptr")
		Else
			$iresult = _sendmessage($hwnd, $hdm_insertitem, $iindex, $pitem, 0, "wparam", "ptr")
		EndIf
	Else
		$iitem = DllStructGetSize($titem)
		$pmemory = _meminit($hwnd, $iitem + $ibuffer, $tmemmap)
		$ptext = $pmemory + $iitem
		DllStructSetData($titem, "Text", $ptext)
		_memwrite($tmemmap, $pitem, $pmemory, $iitem)
		_memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
		If $funicode Then
			$iresult = _sendmessage($hwnd, $hdm_insertitemw, $iindex, $pmemory, 0, "wparam", "ptr")
		Else
			$iresult = _sendmessage($hwnd, $hdm_insertitem, $iindex, $pmemory, 0, "wparam", "ptr")
		EndIf
		_memfree($tmemmap)
	EndIf
	Return $iresult
EndFunc

Func _guictrlheader_layout($hwnd, ByRef $trect)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $ilayout, $playout, $tlayout, $iwindowpos, $pwindowpos, $twindowpos, $irect, $prect, $pmemory, $tmemmap
	$tlayout = DllStructCreate($taghdlayout)
	$playout = DllStructGetPtr($tlayout)
	$prect = DllStructGetPtr($trect)
	$twindowpos = DllStructCreate($tagwindowpos)
	$pwindowpos = DllStructGetPtr($twindowpos)
	If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
		DllStructSetData($tlayout, "Rect", $prect)
		DllStructSetData($tlayout, "WindowPos", $pwindowpos)
		_sendmessage($hwnd, $hdm_layout, 0, $playout, 0, "wparam", "ptr")
	Else
		$ilayout = DllStructGetSize($tlayout)
		$irect = DllStructGetSize($trect)
		$iwindowpos = DllStructGetSize($twindowpos)
		$pmemory = _meminit($hwnd, $ilayout + $irect + $iwindowpos, $tmemmap)
		DllStructSetData($tlayout, "Rect", $pmemory + $ilayout)
		DllStructSetData($tlayout, "WindowPos", $pmemory + $ilayout + $irect)
		_memwrite($tmemmap, $playout, $pmemory, $ilayout)
		_memwrite($tmemmap, $prect, $pmemory + $ilayout, $irect)
		_sendmessage($hwnd, $hdm_layout, 0, $pmemory, 0, "wparam", "ptr")
		_memread($tmemmap, $pmemory + $ilayout + $irect, $pwindowpos, $iwindowpos)
		_memfree($tmemmap)
	EndIf
	Return $twindowpos
EndFunc

Func _guictrlheader_ordertoindex($hwnd, $iorder)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_ordertoindex, $iorder)
EndFunc

Func _guictrlheader_setbitmapmargin($hwnd, $iwidth)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_setbitmapmargin, $iwidth)
EndFunc

Func _guictrlheader_setfilterchangetimeout($hwnd, $itimeout)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_setfilterchangetimeout, 0, $itimeout)
EndFunc

Func _guictrlheader_sethotdivider($hwnd, $iflag, $iinputvalue)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_sethotdivider, $iflag, $iinputvalue)
EndFunc

Func _guictrlheader_setimagelist($hwnd, $himage)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_setimagelist, 0, $himage, 0, "wparam", "hwnd", "hwnd")
EndFunc

Func _guictrlheader_setitem($hwnd, $iindex, ByRef $titem)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $iitem, $pitem, $pmemory, $tmemmap, $iresult
	Local $funicode = _guictrlheader_getunicodeformat($hwnd)
	$pitem = DllStructGetPtr($titem)
	If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
		If $funicode Then
			$iresult = _sendmessage($hwnd, $hdm_setitemw, $iindex, $pitem, 0, "wparam", "ptr")
		Else
			$iresult = _sendmessage($hwnd, $hdm_setitem, $iindex, $pitem, 0, "wparam", "ptr")
		EndIf
	Else
		$iitem = DllStructGetSize($titem)
		$pmemory = _meminit($hwnd, $iitem, $tmemmap)
		_memwrite($tmemmap, $pitem)
		If $funicode Then
			$iresult = _sendmessage($hwnd, $hdm_setitemw, $iindex, $pmemory, 0, "wparam", "ptr")
		Else
			$iresult = _sendmessage($hwnd, $hdm_setitem, $iindex, $pmemory, 0, "wparam", "ptr")
		EndIf
		_memfree($tmemmap)
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrlheader_setitemalign($hwnd, $iindex, $ialign)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $iformat, $aalign[3] = [$hdf_left, $hdf_right, $hdf_center]
	$iformat = _guictrlheader_getitemformat($hwnd, $iindex)
	$iformat = BitAND($iformat, BitNOT($hdf_justifymask))
	$iformat = BitOR($iformat, $aalign[$ialign])
	Return _guictrlheader_setitemformat($hwnd, $iindex, $iformat)
EndFunc

Func _guictrlheader_setitembitmap($hwnd, $iindex, $hbmp)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", BitOR($hdi_format, $hdi_bitmap))
	DllStructSetData($titem, "Fmt", $hdf_bitmap)
	DllStructSetData($titem, "hBMP", $hbmp)
	Return _guictrlheader_setitem($hwnd, $iindex, $titem)
EndFunc

Func _guictrlheader_setitemdisplay($hwnd, $iindex, $idisplay)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $iformat
	$iformat = BitAND(_guictrlheader_getitemformat($hwnd, $iindex), NOT $hdf_displaymask)
	If BitAND($idisplay, 1) <> 0 Then $iformat = BitOR($iformat, $hdf_bitmap)
	If BitAND($idisplay, 2) <> 0 Then $iformat = BitOR($iformat, $hdf_bitmap_on_right)
	If BitAND($idisplay, 4) <> 0 Then $iformat = BitOR($iformat, $hdf_ownerdraw)
	If BitAND($idisplay, 8) <> 0 Then $iformat = BitOR($iformat, $hdf_string)
	Return _guictrlheader_setitemformat($hwnd, $iindex, $iformat)
EndFunc

Func _guictrlheader_setitemflags($hwnd, $iindex, $iflags)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $iformat
	$iformat = _guictrlheader_getitemformat($hwnd, $iindex)
	$iformat = BitAND($iformat, BitNOT($hdf_flagmask))
	If BitAND($iflags, 1) <> 0 Then $iformat = BitOR($iformat, $hdf_image)
	If BitAND($iflags, 2) <> 0 Then $iformat = BitOR($iformat, $hdf_rtlreading)
	If BitAND($iflags, 4) <> 0 Then $iformat = BitOR($iformat, $hdf_sortdown)
	If BitAND($iflags, 8) <> 0 Then $iformat = BitOR($iformat, $hdf_sortup)
	Return _guictrlheader_setitemformat($hwnd, $iindex, $iformat)
EndFunc

Func _guictrlheader_setitemformat($hwnd, $iindex, $iformat)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_format)
	DllStructSetData($titem, "Fmt", $iformat)
	Return _guictrlheader_setitem($hwnd, $iindex, $titem)
EndFunc

Func _guictrlheader_setitemimage($hwnd, $iindex, $iimage)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_image)
	DllStructSetData($titem, "Image", $iimage)
	Return _guictrlheader_setitem($hwnd, $iindex, $titem)
EndFunc

Func _guictrlheader_setitemorder($hwnd, $iindex, $iorder)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_order)
	DllStructSetData($titem, "Order", $iorder)
	Return _guictrlheader_setitem($hwnd, $iindex, $titem)
EndFunc

Func _guictrlheader_setitemparam($hwnd, $iindex, $iparam)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_param)
	DllStructSetData($titem, "Param", $iparam)
	Return _guictrlheader_setitem($hwnd, $iindex, $titem)
EndFunc

Func _guictrlheader_setitemtext($hwnd, $iindex, $stext)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $ibuffer, $pbuffer, $tbuffer, $iitem, $pitem, $titem, $pmemory, $tmemmap, $ptext, $iresult
	Local $funicode = _guictrlheader_getunicodeformat($hwnd)
	$ibuffer = StringLen($stext) + 1
	If $funicode Then
		$ibuffer *= 2
		$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
	Else
		$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$titem = DllStructCreate($taghditem)
	$pitem = DllStructGetPtr($titem)
	DllStructSetData($tbuffer, "Text", $stext)
	DllStructSetData($titem, "Mask", $hdi_text)
	DllStructSetData($titem, "TextMax", $ibuffer)
	If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
		DllStructSetData($titem, "Text", $pbuffer)
		If $funicode Then
			$iresult = _sendmessage($hwnd, $hdm_setitemw, $iindex, $pitem, 0, "wparam", "ptr")
		Else
			$iresult = _sendmessage($hwnd, $hdm_setitem, $iindex, $pitem, 0, "wparam", "ptr")
		EndIf
	Else
		$iitem = DllStructGetSize($titem)
		$pmemory = _meminit($hwnd, $iitem + $ibuffer, $tmemmap)
		$ptext = $pmemory + $iitem
		DllStructSetData($titem, "Text", $ptext)
		_memwrite($tmemmap, $pitem, $pmemory, $iitem)
		_memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
		If $funicode Then
			$iresult = _sendmessage($hwnd, $hdm_setitemw, $iindex, $pmemory, 0, "wparam", "ptr")
		Else
			$iresult = _sendmessage($hwnd, $hdm_setitem, $iindex, $pmemory, 0, "wparam", "ptr")
		EndIf
		_memfree($tmemmap)
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrlheader_setitemwidth($hwnd, $iindex, $iwidth)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $titem
	$titem = DllStructCreate($taghditem)
	DllStructSetData($titem, "Mask", $hdi_width)
	DllStructSetData($titem, "XY", $iwidth)
	Return _guictrlheader_setitem($hwnd, $iindex, $titem)
EndFunc

Func _guictrlheader_setorderarray($hwnd, ByRef $aorder)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Local $ii, $ibuffer, $pbuffer, $tbuffer, $pmemory, $tmemmap, $iresult
	$tbuffer = DllStructCreate("int[" & $aorder[0] & "]")
	$pbuffer = DllStructGetPtr($tbuffer)
	For $ii = 1 To $aorder[0]
		DllStructSetData($tbuffer, 1, $aorder[$ii], $ii)
	Next
	If _winapi_inprocess($hwnd, $_ghhdrlastwnd) Then
		$iresult = _sendmessage($hwnd, $hdm_setorderarray, $aorder[0], $pbuffer, 0, "wparam", "ptr")
	Else
		$ibuffer = DllStructGetSize($tbuffer)
		$pmemory = _meminit($hwnd, $ibuffer, $tmemmap)
		_memwrite($tmemmap, $pbuffer)
		$iresult = _sendmessage($hwnd, $hdm_setorderarray, $aorder[0], $pmemory, 0, "wparam", "ptr")
		_memfree($tmemmap)
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrlheader_setunicodeformat($hwnd, $funicode)
	If $debug_hdr Then _guictrlheader_validateclassname($hwnd)
	Return _sendmessage($hwnd, $hdm_setunicodeformat, $funicode)
EndFunc

Func _guictrlheader_validateclassname($hwnd)
	_guictrlheader_debugprint("This is for debugging only, set the debug variable to false before submitting")
	_winapi_validateclassname($hwnd, $__headerconstant_classname)
EndFunc

Global $_lv_ghlastwnd
Global $debug_lv = False
Global Const $__listviewconstant_classname = "SysListView32"
Global $illistviewsortinfosize = 11
Global $alistviewsortinfo[1][$illistviewsortinfosize]
Global Const $__listviewconstant_gui_rundefmsg = "GUI_RUNDEFMSG"
Global Const $__listviewconstant_ws_visible = 268435456
Global Const $__listviewconstant_ws_child = 1073741824
Global Const $__listviewconstant_wm_setredraw = 11
Global Const $__listviewconstant_wm_setfont = 48
Global Const $__listviewconstant_wm_notify = 78
Global Const $__listviewconstant_default_gui_font = 17
Global Const $__listviewconstant_ild_transparent = 1
Global Const $__listviewconstant_ild_blend25 = 2
Global Const $__listviewconstant_ild_blend50 = 4
Global Const $__listviewconstant_ild_mask = 16
Global Const $__listviewconstant_vk_down = 40
Global Const $__listviewconstant_vk_end = 35
Global Const $__listviewconstant_vk_home = 36
Global Const $__listviewconstant_vk_left = 37
Global Const $__listviewconstant_vk_next = 34
Global Const $__listviewconstant_vk_prior = 33
Global Const $__listviewconstant_vk_right = 39
Global Const $__listviewconstant_vk_up = 38

Func _guictrllistview_addarray($hwnd, ByRef $aitems)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $pbuffer, $tbuffer, $iitem, $pitem, $titem, $tmemmap, $pmemory, $ptext, $ii, $ij
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$titem = DllStructCreate($taglvitem)
	$pitem = DllStructGetPtr($titem)
	If $funicode Then
		$tbuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tbuffer = DllStructCreate("char Text[4096]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	DllStructSetData($titem, "Mask", $lvif_text)
	DllStructSetData($titem, "Text", $pbuffer)
	DllStructSetData($titem, "TextMax", 4096)
	_guictrllistview_beginupdate($hwnd)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			For $ii = 0 To UBound($aitems) - 1
				DllStructSetData($titem, "Item", $ii)
				DllStructSetData($titem, "SubItem", 0)
				DllStructSetData($tbuffer, "Text", $aitems[$ii][0])
				If $funicode Then
					_sendmessage($hwnd, $lvm_insertitemw, 0, $pitem, 0, "wparam", "ptr")
				Else
					_sendmessage($hwnd, $lvm_insertitema, 0, $pitem, 0, "wparam", "ptr")
				EndIf
				For $ij = 1 To UBound($aitems, 2) - 1
					DllStructSetData($titem, "SubItem", $ij)
					DllStructSetData($tbuffer, "Text", $aitems[$ii][$ij])
					If $funicode Then
						_sendmessage($hwnd, $lvm_setitemw, 0, $pitem, 0, "wparam", "ptr")
					Else
						_sendmessage($hwnd, $lvm_setitema, 0, $pitem, 0, "wparam", "ptr")
					EndIf
				Next
			Next
		Else
			$iitem = DllStructGetSize($titem)
			$pmemory = _meminit($hwnd, $iitem + 4096, $tmemmap)
			$ptext = $pmemory + $iitem
			DllStructSetData($titem, "Text", $ptext)
			For $ii = 0 To UBound($aitems) - 1
				DllStructSetData($titem, "Item", $ii)
				DllStructSetData($titem, "SubItem", 0)
				DllStructSetData($tbuffer, "Text", $aitems[$ii][0])
				_memwrite($tmemmap, $pitem, $pmemory, $iitem)
				_memwrite($tmemmap, $pbuffer, $ptext, 4096)
				If $funicode Then
					_sendmessage($hwnd, $lvm_insertitemw, 0, $pmemory, 0, "wparam", "ptr")
				Else
					_sendmessage($hwnd, $lvm_insertitema, 0, $pmemory, 0, "wparam", "ptr")
				EndIf
				For $ij = 1 To UBound($aitems, 2) - 1
					DllStructSetData($titem, "SubItem", $ij)
					DllStructSetData($tbuffer, "Text", $aitems[$ii][$ij])
					_memwrite($tmemmap, $pitem, $pmemory, $iitem)
					_memwrite($tmemmap, $pbuffer, $ptext, 4096)
					If $funicode Then
						_sendmessage($hwnd, $lvm_setitemw, 0, $pmemory, 0, "wparam", "ptr")
					Else
						_sendmessage($hwnd, $lvm_setitema, 0, $pmemory, 0, "wparam", "ptr")
					EndIf
				Next
			Next
			_memfree($tmemmap)
		EndIf
	Else
		For $ii = 0 To UBound($aitems) - 1
			DllStructSetData($titem, "Item", $ii)
			DllStructSetData($titem, "SubItem", 0)
			DllStructSetData($tbuffer, "Text", $aitems[$ii][0])
			If $funicode Then
				GUICtrlSendMsg($hwnd, $lvm_insertitemw, 0, $pitem)
			Else
				GUICtrlSendMsg($hwnd, $lvm_insertitema, 0, $pitem)
			EndIf
			For $ij = 1 To UBound($aitems, 2) - 1
				DllStructSetData($titem, "SubItem", $ij)
				DllStructSetData($tbuffer, "Text", $aitems[$ii][$ij])
				If $funicode Then
					GUICtrlSendMsg($hwnd, $lvm_setitemw, 0, $pitem)
				Else
					GUICtrlSendMsg($hwnd, $lvm_setitema, 0, $pitem)
				EndIf
			Next
		Next
	EndIf
	_guictrllistview_endupdate($hwnd)
EndFunc

Func _guictrllistview_addcolumn($hwnd, $stext, $iwidth = 50, $ialign = -1, $iimage = -1, $fonright = False)
	Return _guictrllistview_insertcolumn($hwnd, _guictrllistview_getcolumncount($hwnd), $stext, $iwidth, $ialign, $iimage, $fonright)
EndFunc

Func _guictrllistview_additem($hwnd, $stext, $iimage = -1, $iparam = 0)
	Return _guictrllistview_insertitem($hwnd, $stext, -1, $iimage, $iparam)
EndFunc

Func _guictrllistview_addsubitem($hwnd, $iindex, $stext, $isubitem, $iimage = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $imask, $ibuffer, $pbuffer, $tbuffer, $iitem, $pitem, $titem, $pmemory, $tmemmap, $ptext, $iresult
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$ibuffer = StringLen($stext) + 1
	If $funicode Then
		$ibuffer *= 2
		$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
	Else
		$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$titem = DllStructCreate($taglvitem)
	$pitem = DllStructGetPtr($titem)
	$imask = $lvif_text
	If $iimage <> -1 Then $imask = BitOR($imask, $lvif_image)
	DllStructSetData($tbuffer, "Text", $stext)
	DllStructSetData($titem, "Mask", $imask)
	DllStructSetData($titem, "Item", $iindex)
	DllStructSetData($titem, "SubItem", $isubitem)
	DllStructSetData($titem, "Image", $iimage)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($titem, "Text", $pbuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_setitemw, 0, $pitem, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_setitema, 0, $pitem, 0, "wparam", "ptr")
			EndIf
		Else
			$iitem = DllStructGetSize($titem)
			$pmemory = _meminit($hwnd, $iitem + $ibuffer, $tmemmap)
			$ptext = $pmemory + $iitem
			DllStructSetData($titem, "Text", $ptext)
			_memwrite($tmemmap, $pitem, $pmemory, $iitem)
			_memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_setitemw, 0, $pmemory, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_setitema, 0, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($titem, "Text", $pbuffer)
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setitemw, 0, $pitem)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setitema, 0, $pitem)
		EndIf
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_approximateviewheight($hwnd, $icount = -1, $icx = -1, $icy = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return BitShift((_sendmessage($hwnd, $lvm_approximateviewrect, $icount, BitOR(BitShift($icy, -16), BitAND($icx, 65535)))), 16)
	Else
		Return BitShift((GUICtrlSendMsg($hwnd, $lvm_approximateviewrect, $icount, BitOR(BitShift($icy, -16), BitAND($icx, 65535)))), 16)
	EndIf
EndFunc

Func _guictrllistview_approximateviewrect($hwnd, $icount = -1, $icx = -1, $icy = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iview, $aview[2]
	If IsHWnd($hwnd) Then
		$iview = _sendmessage($hwnd, $lvm_approximateviewrect, $icount, BitOR(BitShift($icy, -16), BitAND($icx, 65535)))
	Else
		$iview = GUICtrlSendMsg($hwnd, $lvm_approximateviewrect, $icount, BitOR(BitShift($icy, -16), BitAND($icx, 65535)))
	EndIf
	$aview[0] = BitAND($iview, 65535)
	$aview[1] = BitShift($iview, 16)
	Return $aview
EndFunc

Func _guictrllistview_approximateviewwidth($hwnd, $icount = -1, $icx = -1, $icy = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return BitAND((_sendmessage($hwnd, $lvm_approximateviewrect, $icount, BitOR(BitShift($icy, -16), BitAND($icx, 65535)))), 65535)
	Else
		Return BitAND((GUICtrlSendMsg($hwnd, $lvm_approximateviewrect, $icount, BitOR(BitShift($icy, -16), BitAND($icx, 65535)))), 65535)
	EndIf
EndFunc

Func _guictrllistview_arrange($hwnd, $iarrange = 0)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $aarrange[4] = [$lva_default, $lva_alignleft, $lva_aligntop, $lva_snaptogrid]
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_arrange, $aarrange[$iarrange]) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_arrange, $aarrange[$iarrange], 0) <> 0
	EndIf
EndFunc

Func _guictrllistview_arraydelete(ByRef $avarray, $ielement)
	Local $icntr = 0, $iupper = 0
	If (NOT IsArray($avarray)) Then
		SetError(1)
		Return ""
	EndIf
	$iupper = UBound($avarray)
	If $iupper = 1 Then
		SetError(2)
		Return ""
	EndIf
	Local $avnewarray[$iupper - 1][$illistviewsortinfosize]
	$avnewarray[0][0] = $avarray[0][0]
	If $ielement < 0 Then
		$ielement = 0
	EndIf
	If $ielement > ($iupper - 1) Then
		$ielement = ($iupper - 1)
	EndIf
	If $ielement > 0 Then
		For $icntr = 0 To $ielement - 1
			For $x = 1 To $illistviewsortinfosize - 1
				$avnewarray[$icntr][$x] = $avarray[$icntr][$x]
			Next
		Next
	EndIf
	If $ielement < ($iupper - 1) Then
		For $icntr = ($ielement + 1) To ($iupper - 1)
			For $x = 1 To $illistviewsortinfosize - 1
				$avnewarray[$icntr - 1][$x] = $avarray[$icntr][$x]
			Next
		Next
	EndIf
	$avarray = $avnewarray
	SetError(0)
	Return 1
EndFunc

Func _guictrllistview_beginupdate($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $__listviewconstant_wm_setredraw) = 0
EndFunc

Func _guictrllistview_canceleditlabel($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		_sendmessage($hwnd, $lvm_canceleditlabel)
	Else
		GUICtrlSendMsg($hwnd, $lvm_canceleditlabel, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_clickitem($hwnd, $iindex, $sbutton = "left", $fmove = False, $iclicks = 1, $ispeed = 1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Local $apos, $trect, $ix, $iy, $tpoint, $imode
	_guictrllistview_ensurevisible($hwnd, $iindex, False)
	$trect = _guictrllistview_getitemrectex($hwnd, $iindex, $lvir_label)
	$tpoint = _winapi_pointfromrect($trect, True)
	$tpoint = _winapi_clienttoscreen($hwnd, $tpoint)
	_winapi_getxyfrompoint($tpoint, $ix, $iy)
	$imode = Opt("MouseCoordMode", 1)
	If NOT $fmove Then
		$apos = MouseGetPos()
		_winapi_showcursor(False)
		MouseClick($sbutton, $ix, $iy, $iclicks, $ispeed)
		MouseMove($apos[0], $apos[1], 0)
		_winapi_showcursor(True)
	Else
		MouseClick($sbutton, $ix, $iy, $iclicks, $ispeed)
	EndIf
	Opt("MouseCoordMode", $imode)
EndFunc

Func _guictrllistview_copyitems($hwnd_source, $hwnd_destination, $fdelflag = False)
	If $debug_lv Then
		_guictrllistview_validateclassname($hwnd_source)
		_guictrllistview_validateclassname($hwnd_destination)
	EndIf
	Local $a_indices, $i, $items, $titem = DllStructCreate($taglvitem), $iindex
	Local $cols = _guictrllistview_getcolumncount($hwnd_source)
	$items = _guictrllistview_getitemcount($hwnd_source)
	_guictrllistview_beginupdate($hwnd_source)
	_guictrllistview_beginupdate($hwnd_destination)
	If BitAND(_guictrllistview_getextendedlistviewstyle($hwnd_source), $lvs_ex_checkboxes) == $lvs_ex_checkboxes Then
		For $i = 0 To $items - 1
			If (_guictrllistview_getitemchecked($hwnd_source, $i)) Then
				If IsArray($a_indices) Then
					ReDim $a_indices[UBound($a_indices) + 1]
				Else
					Local $a_indices[2]
				EndIf
				$a_indices[0] = $a_indices[0] + 1
				$a_indices[UBound($a_indices) - 1] = $i
			EndIf
		Next
		If (IsArray($a_indices)) Then
			For $i = 1 To $a_indices[0]
				DllStructSetData($titem, "Mask", BitOR($lvif_groupid, $lvif_image, $lvif_indent, $lvif_param, $lvif_state))
				DllStructSetData($titem, "Item", $a_indices[$i])
				DllStructSetData($titem, "SubItem", 0)
				DllStructSetData($titem, "StateMask", -1)
				_guictrllistview_getitemex($hwnd_source, $titem)
				$iindex = _guictrllistview_additem($hwnd_destination, _guictrllistview_getitemtext($hwnd_source, $a_indices[$i], 0), DllStructGetData($titem, "Image"))
				_guictrllistview_setitemchecked($hwnd_destination, $iindex)
				For $x = 1 To $cols - 1
					DllStructSetData($titem, "Item", $a_indices[$i])
					DllStructSetData($titem, "SubItem", $x)
					_guictrllistview_getitemex($hwnd_source, $titem)
					_guictrllistview_addsubitem($hwnd_destination, $iindex, _guictrllistview_getitemtext($hwnd_source, $a_indices[$i], $x), $x, DllStructGetData($titem, "Image"))
				Next
			Next
			If $fdelflag Then
				For $i = $a_indices[0] To 1 Step -1
					_guictrllistview_deleteitem($hwnd_source, $a_indices[$i])
				Next
			EndIf
		EndIf
	EndIf
	If (_guictrllistview_getselectedcount($hwnd_source)) Then
		$a_indices = _guictrllistview_getselectedindices($hwnd_source, 1)
		For $i = 1 To $a_indices[0]
			DllStructSetData($titem, "Mask", BitOR($lvif_groupid, $lvif_image, $lvif_indent, $lvif_param, $lvif_state))
			DllStructSetData($titem, "Item", $a_indices[$i])
			DllStructSetData($titem, "SubItem", 0)
			DllStructSetData($titem, "StateMask", -1)
			_guictrllistview_getitemex($hwnd_source, $titem)
			$iindex = _guictrllistview_additem($hwnd_destination, _guictrllistview_getitemtext($hwnd_source, $a_indices[$i], 0), DllStructGetData($titem, "Image"))
			For $x = 1 To $cols - 1
				DllStructSetData($titem, "Item", $a_indices[$i])
				DllStructSetData($titem, "SubItem", $x)
				_guictrllistview_getitemex($hwnd_source, $titem)
				_guictrllistview_addsubitem($hwnd_destination, $iindex, _guictrllistview_getitemtext($hwnd_source, $a_indices[$i], $x), $x, DllStructGetData($titem, "Image"))
			Next
		Next
		_guictrllistview_setitemselected($hwnd_source, -1, False)
		If $fdelflag Then
			For $i = $a_indices[0] To 1 Step -1
				_guictrllistview_deleteitem($hwnd_source, $a_indices[$i])
			Next
		EndIf
	EndIf
	_guictrllistview_endupdate($hwnd_source)
	_guictrllistview_endupdate($hwnd_destination)
EndFunc

Func _guictrllistview_create($hwnd, $sheadertext, $ix, $iy, $iwidth = 150, $iheight = 150, $istyle = 13, $iexstyle = 0, $fcoinit = False)
	If NOT IsHWnd($hwnd) Then _winapi_showerror("Invalid Window handle for _GUICtrlListViewCreate 1st parameter")
	If NOT IsString($sheadertext) Then _winapi_showerror("2nd parameter not a string for _GUICtrlListViewCreate")
	If $iwidth = -1 Then $iwidth = 150
	If $iheight = -1 Then $iheight = 150
	If $istyle = -1 Then $istyle = 13
	If $iexstyle = -1 Then $iexstyle = 0
	Local $hlist, $str_len, $aresult, $nctrlid
	Local Const $s_ok = 0
	Local Const $s_false = 1
	Local Const $rpc_e_changed_mode = -2147417850
	Local Const $e_invalidarg = -2147024809
	Local Const $e_outofmemory = -2147024882
	Local Const $e_unexpected = -2147418113
	Local $separatorchar = Opt("GUIDataSeparatorChar")
	Local Const $coinit_apartmentthreaded = 2
	$str_len = StringLen($sheadertext)
	If $str_len Then $sheadertext = StringSplit($sheadertext, $separatorchar)
	$istyle = BitOR($__listviewconstant_ws_child, $__listviewconstant_ws_visible, $istyle)
	If $fcoinit Then
		$aresult = DllCall("ole32.dll", "long", "CoInitializeEx", "int", 0, "long", $coinit_apartmentthreaded)
		Switch $aresult[0]
			Case $s_ok
				If $debug_lv Then _guictrllistview_debugprint("The COM library was initialized successfully on the calling thread.")
			Case $s_false
				If $debug_lv Then _guictrllistview_debugprint("The COM library is already initialized on the calling thread.")
			Case $rpc_e_changed_mode
				If $debug_lv Then _guictrllistview_debugprint("A previous call to CoInitializeEx specified a different concurrency model for the calling thread," & @LF & "-->or the thread that called CoInitializeEx currently belongs to the neutral threaded apartment.")
			Case $e_invalidarg
				If $debug_lv Then _guictrllistview_debugprint("Invalid Arg")
			Case $e_outofmemory
				If $debug_lv Then _guictrllistview_debugprint("Out of memory")
			Case $e_unexpected
				If $debug_lv Then _guictrllistview_debugprint("Unexpected error")
		EndSwitch
	EndIf
	$nctrlid = _udf_getnextglobalid($hwnd)
	If @error Then Return SetError(@error, @extended, 0)
	$hlist = _winapi_createwindowex($iexstyle, $__listviewconstant_classname, "", $istyle, $ix, $iy, $iwidth, $iheight, $hwnd, $nctrlid)
	_guictrllistview_setunicodeformat($hlist, False)
	_sendmessage($hlist, $__listviewconstant_wm_setfont, _winapi_getstockobject($__listviewconstant_default_gui_font), True)
	If $str_len Then
		For $x = 1 To $sheadertext[0]
			_guictrllistview_insertcolumn($hlist, $x - 1, $sheadertext[$x], 75)
		Next
	EndIf
	Return $hlist
EndFunc

Func _guictrllistview_createdragimage($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $tmemmap, $pmemory, $ipoint, $ppoint, $tpoint, $adrag[3]
	$tpoint = DllStructCreate($tagpoint)
	$ppoint = DllStructGetPtr($tpoint)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			$adrag[0] = _sendmessage($hwnd, $lvm_createdragimage, $iindex, $ppoint, 0, "wparam", "ptr", "hwnd")
		Else
			$ipoint = DllStructGetSize($tpoint)
			$pmemory = _meminit($hwnd, $ipoint, $tmemmap)
			$adrag[0] = _sendmessage($hwnd, $lvm_createdragimage, $iindex, $pmemory, 0, "wparam", "ptr", "hwnd")
			_memread($tmemmap, $pmemory, $ppoint, $ipoint)
			_memfree($tmemmap)
		EndIf
	Else
		$adrag[0] = GUICtrlSendMsg($hwnd, $lvm_createdragimage, $iindex, $ppoint)
	EndIf
	$adrag[1] = DllStructGetData($tpoint, "X")
	$adrag[2] = DllStructGetData($tpoint, "Y")
	Return $adrag
EndFunc

Func _guictrllistview_createsolidbitmap($hwnd, $icolor, $iwidth, $iheight)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _winapi_createsolidbitmap($hwnd, $icolor, $iwidth, $iheight)
EndFunc

Func _guictrllistview_debugprint($stext, $iline = @ScriptLineNumber)
	ConsoleWrite("!===========================================================" & @LF & "+======================================================" & @LF & "-->Line(" & StringFormat("%04d", $iline) & "):" & @TAB & $stext & @LF & "+======================================================" & @LF)
EndFunc

Func _guictrllistview_deleteallitems($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ctrlid, $index
	If _guictrllistview_getitemcount($hwnd) == 0 Then Return True
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_deleteallitems) <> 0
	Else
		For $index = _guictrllistview_getitemcount($hwnd) - 1 To 0 Step -1
			$ctrlid = _guictrllistview_getitemparam($hwnd, $index)
			If $ctrlid Then GUICtrlDelete($ctrlid)
		Next
		If _guictrllistview_getitemcount($hwnd) == 0 Then Return True
	EndIf
	Return False
EndFunc

Func _guictrllistview_deletecolumn($hwnd, $icol)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_deletecolumn, $icol) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_deletecolumn, $icol, 0) <> 0
	EndIf
EndFunc

Func _guictrllistview_deleteitem($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ctrlid
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_deleteitem, $iindex) <> 0
	Else
		$ctrlid = _guictrllistview_getitemparam($hwnd, $iindex)
		If $ctrlid Then Return GUICtrlDelete($ctrlid) <> 0
	EndIf
	Return False
EndFunc

Func _guictrllistview_deleteitemsselected($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $i, $itemcount
	$itemcount = _guictrllistview_getitemcount($hwnd)
	If (_guictrllistview_getselectedcount($hwnd) == $itemcount) Then
		Return _guictrllistview_deleteallitems($hwnd)
	Else
		Local $items = _guictrllistview_getselectedindices($hwnd, 1)
		If NOT IsArray($items) Then Return SetError($lv_err, $lv_err, 0)
		_guictrllistview_setitemselected($hwnd, -1, False)
		For $i = $items[0] To 1 Step -1
			If NOT _guictrllistview_deleteitem($hwnd, $items[$i]) Then Return False
		Next
		Return True
	EndIf
EndFunc

Func _guictrllistview_destroy(ByRef $hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $destroyed, $iresult
	If _winapi_isclassname($hwnd, $__listviewconstant_classname) Then
		If IsHWnd($hwnd) Then
			If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
				Local $nctrlid = _winapi_getdlgctrlid($hwnd)
				Local $hparent = _winapi_getparent($hwnd)
				$destroyed = _winapi_destroywindow($hwnd)
				$iresult = _udf_freeglobalid($hparent, $nctrlid)
				If NOT $iresult Then
				EndIf
			Else
				_winapi_showmsg("Not Allowed to Destroy Other Applications ListView(s)")
				Return SetError(1, 1, False)
			EndIf
		Else
			$destroyed = GUICtrlDelete($hwnd)
		EndIf
		If $destroyed Then $hwnd = 0
		Return $destroyed <> 0
	EndIf
	Return SetError(2, 2, False)
EndFunc

Func _guictrllistview_draw($hwnd, $iindex, $hdc, $ix, $iy, $istyle = 0)
	Local $iflags, $aresult
	If BitAND($istyle, 1) <> 0 Then $iflags = BitOR($iflags, $__listviewconstant_ild_transparent)
	If BitAND($istyle, 2) <> 0 Then $iflags = BitOR($iflags, $__listviewconstant_ild_blend25)
	If BitAND($istyle, 4) <> 0 Then $iflags = BitOR($iflags, $__listviewconstant_ild_blend50)
	If BitAND($istyle, 8) <> 0 Then $iflags = BitOR($iflags, $__listviewconstant_ild_mask)
	$aresult = DllCall("ComCtl32.dll", "int", "ImageList_Draw", "hwnd", $hwnd, "int", $iindex, "hwnd", $hdc, "int", $ix, "int", $iy, "uint", $iflags)
	Return $aresult[0] <> 0
EndFunc

Func _guictrllistview_drawdragimage(ByRef $hwnd, ByRef $adrag)
	Local $tpoint, $hdc
	$hdc = _winapi_getwindowdc($hwnd)
	$tpoint = _winapi_getmousepos(True, $hwnd)
	_winapi_invalidaterect($hwnd)
	_guictrllistview_draw($adrag[0], 0, $hdc, DllStructGetData($tpoint, "X"), DllStructGetData($tpoint, "Y"))
	_winapi_releasedc($hwnd, $hdc)
EndFunc

Func _guictrllistview_editlabel($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	If IsHWnd($hwnd) Then
		DllCall("User32.dll", "hwnd", "SetFocus", "hwnd", $hwnd)
		If $funicode Then
			Return _sendmessage($hwnd, $lvm_editlabelw, $iindex, 0, 0, "wparam", "lparam", "hwnd")
		Else
			Return _sendmessage($hwnd, $lvm_editlabel, $iindex, 0, 0, "wparam", "lparam", "hwnd")
		EndIf
	Else
		DllCall("User32.dll", "hwnd", "SetFocus", "hwnd", GUICtrlGetHandle($hwnd))
		If $funicode Then
			Return GUICtrlSendMsg($hwnd, $lvm_editlabelw, $iindex, 0)
		Else
			Return GUICtrlSendMsg($hwnd, $lvm_editlabel, $iindex, 0)
		EndIf
	EndIf
EndFunc

Func _guictrllistview_enablegroupview($hwnd, $fenable = True)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_enablegroupview, $fenable)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_enablegroupview, $fenable, 0)
	EndIf
EndFunc

Func _guictrllistview_endupdate($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	Return _sendmessage($hwnd, $__listviewconstant_wm_setredraw, 1) = 0
EndFunc

Func _guictrllistview_ensurevisible($hwnd, $iindex, $fpartialok = False)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_ensurevisible, $iindex, $fpartialok)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_ensurevisible, $iindex, $fpartialok)
	EndIf
EndFunc

Func _guictrllistview_findintext($hwnd, $stext, $istart = -1, $fwrapok = True, $freverse = False)
	Local $ii, $ij, $icount, $icolumns, $slist
	$icount = _guictrllistview_getitemcount($hwnd)
	$icolumns = _guictrllistview_getcolumncount($hwnd)
	If $icolumns = 0 Then $icolumns = 1
	If $freverse AND $istart = -1 Then Return -1
	If $freverse Then
		For $ii = $istart - 1 To 0 Step -1
			For $ij = 0 To $icolumns - 1
				$slist = _guictrllistview_getitemtext($hwnd, $ii, $ij)
				If StringInStr($slist, $stext) Then Return $ii
			Next
		Next
	Else
		For $ii = $istart + 1 To $icount - 1
			For $ij = 0 To $icolumns - 1
				$slist = _guictrllistview_getitemtext($hwnd, $ii, $ij)
				If StringInStr($slist, $stext) Then Return $ii
			Next
		Next
	EndIf
	If (($istart = -1) OR NOT $fwrapok) AND NOT $freverse Then Return -1
	If $freverse AND $fwrapok Then
		For $ii = $icount - 1 To $istart + 1 Step -1
			For $ij = 0 To $icolumns - 1
				$slist = _guictrllistview_getitemtext($hwnd, $ii, $ij)
				If StringInStr($slist, $stext) Then Return $ii
			Next
		Next
	Else
		For $ii = 0 To $istart - 1
			For $ij = 0 To $icolumns - 1
				$slist = _guictrllistview_getitemtext($hwnd, $ii, $ij)
				If StringInStr($slist, $stext) Then Return $ii
			Next
		Next
	EndIf
	Return -1
EndFunc

Func _guictrllistview_finditem($hwnd, $istart, ByRef $tfindinfo, $stext = "")
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ibuffer, $tbuffer, $pbuffer, $ifindinfo, $pfindinfo, $pmemory, $tmemmap, $ptext, $iresult
	$ibuffer = StringLen($stext) + 1
	$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	$pbuffer = DllStructGetPtr($tbuffer)
	$pfindinfo = DllStructGetPtr($tfindinfo)
	DllStructSetData($tbuffer, "Text", $stext)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($tfindinfo, "Text", $pbuffer)
			$iresult = _sendmessage($hwnd, $lvm_finditem, $istart, $pfindinfo, 0, "wparam", "ptr")
		Else
			$ifindinfo = DllStructGetSize($tfindinfo)
			$pmemory = _meminit($hwnd, $ifindinfo + $ibuffer, $tmemmap)
			$ptext = $pmemory + $ifindinfo
			DllStructSetData($tfindinfo, "Text", $ptext)
			_memwrite($tmemmap, $pfindinfo, $pmemory, $ifindinfo)
			_memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
			$iresult = _sendmessage($hwnd, $lvm_finditem, $istart, $pmemory, 0, "wparam", "ptr")
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($tfindinfo, "Text", $pbuffer)
		$iresult = GUICtrlSendMsg($hwnd, $lvm_finditem, $istart, $pfindinfo)
	EndIf
	Return $iresult
EndFunc

Func _guictrllistview_findnearest($hwnd, $ix, $iy, $idir = 0, $istart = -1, $fwrapok = True)
	Local $tfindinfo, $iflags, $adir[8] = [$__listviewconstant_vk_left, $__listviewconstant_vk_right, $__listviewconstant_vk_up, $__listviewconstant_vk_down, $__listviewconstant_vk_home, $__listviewconstant_vk_end, $__listviewconstant_vk_prior, $__listviewconstant_vk_next]
	$tfindinfo = DllStructCreate($taglvfindinfo)
	$iflags = $lvfi_nearestxy
	If $fwrapok Then $iflags = BitOR($iflags, $lvfi_wrap)
	DllStructSetData($tfindinfo, "Flags", $iflags)
	DllStructSetData($tfindinfo, "X", $ix)
	DllStructSetData($tfindinfo, "Y", $iy)
	DllStructSetData($tfindinfo, "Direction", $adir[$idir])
	Return _guictrllistview_finditem($hwnd, $istart, $tfindinfo)
EndFunc

Func _guictrllistview_findparam($hwnd, $iparam, $istart = -1)
	Local $tfindinfo
	$tfindinfo = DllStructCreate($taglvfindinfo)
	DllStructSetData($tfindinfo, "Flags", $lvfi_param)
	DllStructSetData($tfindinfo, "Param", $iparam)
	Return _guictrllistview_finditem($hwnd, $istart, $tfindinfo)
EndFunc

Func _guictrllistview_findtext($hwnd, $stext, $istart = -1, $fpartialok = True, $fwrapok = True)
	Local $tfindinfo, $iflags
	$tfindinfo = DllStructCreate($taglvfindinfo)
	$iflags = $lvfi_string
	If $fpartialok Then $iflags = BitOR($iflags, $lvfi_partial)
	If $fwrapok Then $iflags = BitOR($iflags, $lvfi_wrap)
	DllStructSetData($tfindinfo, "Flags", $iflags)
	Return _guictrllistview_finditem($hwnd, $istart, $tfindinfo, $stext)
EndFunc

Func _guictrllistview_getbkcolor($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $v_color
	If IsHWnd($hwnd) Then
		$v_color = _sendmessage($hwnd, $lvm_getbkcolor)
	Else
		$v_color = GUICtrlSendMsg($hwnd, $lvm_getbkcolor, 0, 0)
	EndIf
	Return _guictrllistview_reversecolororder($v_color)
EndFunc

Func _guictrllistview_getbkimage($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $pbuffer, $tbuffer, $pmemory, $tmemmap, $ptext, $iimage, $pimage, $timage, $aimage[4], $iresult
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	If $funicode Then
		$tbuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tbuffer = DllStructCreate("char Text[4096]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$timage = DllStructCreate($taglvbkimage)
	$pimage = DllStructGetPtr($timage)
	DllStructSetData($timage, "ImageMax", 4096)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($timage, "Image", $pbuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_getbkimagew, 0, $pimage, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_getbkimagea, 0, $pimage, 0, "wparam", "ptr")
			EndIf
		Else
			$iimage = DllStructGetSize($timage)
			$pmemory = _meminit($hwnd, $iimage + 4096, $tmemmap)
			$ptext = $pmemory + $iimage
			DllStructSetData($timage, "Image", $ptext)
			_memwrite($tmemmap, $pimage, $pmemory, $iimage)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_getbkimagew, 0, $pmemory, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_getbkimagea, 0, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memread($tmemmap, $pmemory, $pimage, $iimage)
			_memread($tmemmap, $ptext, $pbuffer, 4096)
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($timage, "Image", $pbuffer)
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getbkimagew, 0, $pimage)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getbkimagea, 0, $pimage)
		EndIf
	EndIf
	Switch BitAND(DllStructGetData($timage, "Flags"), $lvbkif_source_mask)
		Case $lvbkif_source_hbitmap
			$aimage[0] = 1
		Case $lvbkif_source_url
			$aimage[0] = 2
	EndSwitch
	$aimage[1] = DllStructGetData($tbuffer, "Text")
	$aimage[2] = DllStructGetData($timage, "XOffPercent")
	$aimage[3] = DllStructGetData($timage, "YOffPercent")
	Return SetError($iresult <> 0, 0, $aimage)
EndFunc

Func _guictrllistview_getcallbackmask($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iflags = 0, $imask
	$imask = _sendmessage($hwnd, $lvm_getcallbackmask)
	If BitAND($imask, $lvis_cut) <> 0 Then $iflags = BitOR($iflags, 1)
	If BitAND($imask, $lvis_drophilited) <> 0 Then $iflags = BitOR($iflags, 2)
	If BitAND($imask, $lvis_focused) <> 0 Then $iflags = BitOR($iflags, 4)
	If BitAND($imask, $lvis_selected) <> 0 Then $iflags = BitOR($iflags, 8)
	If BitAND($imask, $lvis_overlaymask) <> 0 Then $iflags = BitOR($iflags, 16)
	If BitAND($imask, $lvis_stateimagemask) <> 0 Then $iflags = BitOR($iflags, 32)
	Return $iflags
EndFunc

Func _guictrllistview_getcolumn($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $pbuffer, $tbuffer, $icolumn, $pcolumn, $tcolumn, $pmemory, $tmemmap, $ptext, $acolumn[9], $iresult
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	If $funicode Then
		$tbuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tbuffer = DllStructCreate("char Text[4096]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$tcolumn = DllStructCreate($taglvcolumn)
	$pcolumn = DllStructGetPtr($tcolumn)
	DllStructSetData($tcolumn, "Mask", $lvcf_alldata)
	DllStructSetData($tcolumn, "TextMax", 4096)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($tcolumn, "Text", $pbuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_getcolumnw, $iindex, $pcolumn, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_getcolumna, $iindex, $pcolumn, 0, "wparam", "ptr")
			EndIf
		Else
			$icolumn = DllStructGetSize($tcolumn)
			$pmemory = _meminit($hwnd, $icolumn + 4096, $tmemmap)
			$ptext = $pmemory + $icolumn
			DllStructSetData($tcolumn, "Text", $ptext)
			_memwrite($tmemmap, $pcolumn, $pmemory, $icolumn)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_getcolumnw, $iindex, $pmemory, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_getcolumna, $iindex, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memread($tmemmap, $pmemory, $pcolumn, $icolumn)
			_memread($tmemmap, $ptext, $pbuffer, 4096)
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($tcolumn, "Text", $pbuffer)
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getcolumnw, $iindex, $pcolumn)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getcolumna, $iindex, $pcolumn)
		EndIf
	EndIf
	Switch BitAND(DllStructGetData($tcolumn, "Fmt"), $lvcfmt_justifymask)
		Case $lvcfmt_right
			$acolumn[0] = 1
		Case $lvcfmt_center
			$acolumn[0] = 2
		Case Else
			$acolumn[0] = 0
	EndSwitch
	$acolumn[1] = BitAND(DllStructGetData($tcolumn, "Fmt"), $lvcfmt_image) <> 0
	$acolumn[2] = BitAND(DllStructGetData($tcolumn, "Fmt"), $lvcfmt_bitmap_on_right) <> 0
	$acolumn[3] = BitAND(DllStructGetData($tcolumn, "Fmt"), $lvcfmt_col_has_images) <> 0
	$acolumn[4] = DllStructGetData($tcolumn, "CX")
	$acolumn[5] = DllStructGetData($tbuffer, "Text")
	$acolumn[6] = DllStructGetData($tcolumn, "SubItem")
	$acolumn[7] = DllStructGetData($tcolumn, "Image")
	$acolumn[8] = DllStructGetData($tcolumn, "Order")
	Return SetError($iresult = 0, 0, $acolumn)
EndFunc

Func _guictrllistview_getcolumncount($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Return _sendmessage(_guictrllistview_getheader($hwnd), 4608)
EndFunc

Func _guictrllistview_getcolumnorder($hwnd)
	Local $a_cols = _guictrllistview_getcolumnorderarray($hwnd), $s_cols = ""
	Local $separatorchar = Opt("GUIDataSeparatorChar")
	For $i = 1 To $a_cols[0]
		$s_cols &= $a_cols[$i] & $separatorchar
	Next
	$s_cols = StringTrimRight($s_cols, 1)
	Return $s_cols
EndFunc

Func _guictrllistview_getcolumnorderarray($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ii, $ibuffer, $pbuffer, $tbuffer, $icolumns, $pmemory, $tmemmap
	$icolumns = _guictrllistview_getcolumncount($hwnd)
	$tbuffer = DllStructCreate("int[" & $icolumns & "]")
	$pbuffer = DllStructGetPtr($tbuffer)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			_sendmessage($hwnd, $lvm_getcolumnorderarray, $icolumns, $pbuffer, 0, "wparam", "ptr")
		Else
			$ibuffer = DllStructGetSize($tbuffer)
			$pmemory = _meminit($hwnd, $ibuffer, $tmemmap)
			_sendmessage($hwnd, $lvm_getcolumnorderarray, $icolumns, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $pbuffer, $ibuffer)
			_memfree($tmemmap)
		EndIf
	Else
		GUICtrlSendMsg($hwnd, $lvm_getcolumnorderarray, $icolumns, $pbuffer)
	EndIf
	Local $abuffer[$icolumns + 1]
	$abuffer[0] = $icolumns
	For $ii = 1 To $icolumns
		$abuffer[$ii] = DllStructGetData($tbuffer, 1, $ii)
	Next
	Return $abuffer
EndFunc

Func _guictrllistview_getcolumnwidth($hwnd, $icol)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getcolumnwidth, $icol)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getcolumnwidth, $icol, 0)
	EndIf
EndFunc

Func _guictrllistview_getcounterpage($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getcountperpage)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getcountperpage, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_geteditcontrol($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_geteditcontrol)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_geteditcontrol, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getemptytext($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ttext = DllStructCreate("char[4096]")
	Local $iresult, $itext, $ptext, $pmemory, $pbuffer = DllStructGetPtr($ttext), $tmemmap
	If IsHWnd($hwnd) Then
		$itext = DllStructGetSize($ttext)
		$pmemory = _meminit($hwnd, $itext + 4096, $tmemmap)
		$ptext = $pmemory + $itext
		DllStructSetData($ttext, "Text", $ptext)
		_memwrite($tmemmap, $ptext, $pmemory, $itext)
		$iresult = _sendmessage($hwnd, $lvm_getemptytext, 4096, $pmemory)
		_memread($tmemmap, $ptext, $pbuffer, 4096)
		_memfree($tmemmap)
		If $iresult = 0 Then Return SetError(-1, 0, "")
		Return DllStructGetData($ttext, 1)
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_getemptytext, 4096, DllStructGetPtr($ttext))
		If $iresult = 0 Then Return SetError(-1, 0, "")
		Return DllStructGetData($ttext, 1)
	EndIf
EndFunc

Func _guictrllistview_getextendedlistviewstyle($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getextendedlistviewstyle)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getextendedlistviewstyle, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getfocusedgroup($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getfocusedgroup)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getfocusedgroup, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getgroupcount($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getgroupcount)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getgroupcount, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getgroupinfo($hwnd, $igroupid)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $igroup, $pgroup, $tgroup, $agroup[2], $tmemmap, $pmemory, $iresult
	$tgroup = DllStructCreate($taglvgroup)
	$pgroup = DllStructGetPtr($tgroup)
	$igroup = DllStructGetSize($tgroup)
	DllStructSetData($tgroup, "Size", $igroup)
	DllStructSetData($tgroup, "Mask", BitOR($lvgf_header, $lvgf_align))
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			$iresult = _sendmessage($hwnd, $lvm_getgroupinfo, $igroupid, $pgroup, 0, "wparam", "ptr")
		Else
			$pmemory = _meminit($hwnd, $igroup, $tmemmap)
			_memwrite($tmemmap, $pgroup, $pmemory, $igroup)
			$iresult = _sendmessage($hwnd, $lvm_getgroupinfo, $igroupid, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $pgroup, $igroup)
			_memfree($tmemmap)
		EndIf
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_getgroupinfo, $igroupid, $pgroup)
	EndIf
	$agroup[0] = _winapi_widechartomultibyte(DllStructGetData($tgroup, "Header"))
	Select 
		Case BitAND(DllStructGetData($tgroup, "Align"), $lvga_header_center) <> 0
			$agroup[1] = 1
		Case BitAND(DllStructGetData($tgroup, "Align"), $lvga_header_right) <> 0
			$agroup[1] = 2
		Case Else
			$agroup[1] = 0
	EndSelect
	Return SetError($iresult <> $igroupid, 0, $agroup)
EndFunc

Func _guictrllistview_getgroupinfobyindex($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $igroup, $pgroup, $tgroup, $agroup[2], $tmemmap, $pmemory, $iresult
	$tgroup = DllStructCreate($taglvgroup)
	$pgroup = DllStructGetPtr($tgroup)
	$igroup = DllStructGetSize($tgroup)
	DllStructSetData($tgroup, "Size", $igroup)
	DllStructSetData($tgroup, "Mask", BitOR($lvgf_header, $lvgf_align))
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			$iresult = _sendmessage($hwnd, $lvm_getgroupinfobyindex, $iindex, $pgroup, 0, "wparam", "ptr")
		Else
			$pmemory = _meminit($hwnd, $igroup, $tmemmap)
			_memwrite($tmemmap, $pgroup, $pmemory, $igroup)
			$iresult = _sendmessage($hwnd, $lvm_getgroupinfobyindex, $iindex, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $pgroup, $igroup)
			_memfree($tmemmap)
		EndIf
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_getgroupinfobyindex, $iindex, $pgroup)
	EndIf
	$agroup[0] = _winapi_widechartomultibyte(DllStructGetData($tgroup, "Header"))
	Select 
		Case BitAND(DllStructGetData($tgroup, "Align"), $lvga_header_center) <> 0
			$agroup[1] = 1
		Case BitAND(DllStructGetData($tgroup, "Align"), $lvga_header_right) <> 0
			$agroup[1] = 2
		Case Else
			$agroup[1] = 0
	EndSelect
	Return SetError($iresult = 0, 0, $agroup)
EndFunc

Func _guictrllistview_getgrouprect($hwnd, $igroupid, $iget = $lvggr_group)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $igroup, $pgroup, $tgroup, $agroup[4], $tmemmap, $pmemory, $iresult
	$tgroup = DllStructCreate($tagrect)
	DllStructSetData($tgroup, "Left", $iget)
	$pgroup = DllStructGetPtr($tgroup)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			$iresult = _sendmessage($hwnd, $lvm_getgrouprect, $igroupid, $pgroup, 0, "wparam", "ptr")
		Else
			$pmemory = _meminit($hwnd, $igroup, $tmemmap)
			_memwrite($tmemmap, $pgroup, $pmemory, $igroup)
			$iresult = _sendmessage($hwnd, $lvm_getgrouprect, $igroupid, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $pgroup, $igroup)
			_memfree($tmemmap)
		EndIf
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_getgrouprect, $igroupid, $pgroup)
	EndIf
	For $x = 0 To 3
		$agroup[$x] = DllStructGetData($tgroup, $x + 1)
	Next
	Return SetError($iresult = 0, 0, $agroup)
EndFunc

Func _guictrllistview_getgroupstate($hwnd, $igroupid, $imask)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getgroupstate, $igroupid, $imask)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getgroupstate, $igroupid, $imask)
	EndIf
EndFunc

Func _guictrllistview_getgroupviewenabled($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_isgroupviewenabled) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_isgroupviewenabled, 0, 0) <> 0
	EndIf
EndFunc

Func _guictrllistview_getheader($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getheader)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getheader, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_gethotcursor($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_gethotcursor, 0, 0, 0, "wparam", "lparam", "hwnd")
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_gethotcursor, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_gethotitem($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_gethotitem)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_gethotitem, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_gethovertime($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_gethovertime)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_gethovertime, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getimagelist($hwnd, $iimagelist)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $aimagelist[3] = [$lvsil_normal, $lvsil_small, $lvsil_state]
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getimagelist, $aimagelist[$iimagelist], 0, 0, "wparam", "lparam", "hwnd")
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getimagelist, $aimagelist[$iimagelist], 0)
	EndIf
EndFunc

Func _guictrllistview_getinsertmark($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $imark, $pmark, $tmark, $pmemory, $tmemmap, $amark[2], $iresult
	$tmark = DllStructCreate($taglvinsertmark)
	$pmark = DllStructGetPtr($tmark)
	$imark = DllStructGetSize($tmark)
	DllStructSetData($tmark, "Size", $imark)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			$iresult = _sendmessage($hwnd, $lvm_getinsertmark, 0, $pmark, 0, "wparam", "ptr")
		Else
			$pmemory = _meminit($hwnd, $imark, $tmemmap)
			_memwrite($tmemmap, $pmark)
			$iresult = _sendmessage($hwnd, $lvm_getinsertmark, 0, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $pmark, $imark)
			_memfree($tmemmap)
		EndIf
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_getinsertmark, 0, $pmark)
	EndIf
	$amark[0] = DllStructGetData($tmark, "Flags") = $lvim_after
	$amark[1] = DllStructGetData($tmark, "Item")
	Return SetError($iresult = 0, 0, $amark)
EndFunc

Func _guictrllistview_getinsertmarkcolor($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getinsertmarkcolor, $lvsil_state)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getinsertmarkcolor, $lvsil_state, 0)
	EndIf
EndFunc

Func _guictrllistview_getinsertmarkrect($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $irect, $prect, $trect, $pmemory, $tmemmap, $arect[5]
	$trect = DllStructCreate($tagrect)
	$prect = DllStructGetPtr($trect)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			$arect[0] = _sendmessage($hwnd, $lvm_getinsertmarkrect, 0, $prect, 0, "wparam", "ptr") <> 0
		Else
			$irect = DllStructGetSize($trect)
			$pmemory = _meminit($hwnd, $irect, $tmemmap)
			$arect[0] = _sendmessage($hwnd, $lvm_getinsertmarkrect, 0, $pmemory, 0, "wparam", "ptr") <> 0
			_memread($tmemmap, $pmemory, $prect, $irect)
			_memfree($tmemmap)
		EndIf
	Else
		$arect[0] = GUICtrlSendMsg($hwnd, $lvm_getinsertmarkrect, 0, $prect) <> 0
	EndIf
	$arect[1] = DllStructGetData($trect, "Left")
	$arect[2] = DllStructGetData($trect, "Top")
	$arect[3] = DllStructGetData($trect, "Right")
	$arect[4] = DllStructGetData($trect, "Bottom")
	Return $arect
EndFunc

Func _guictrllistview_getisearchstring($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ibuffer, $pbuffer, $tbuffer, $pmemory, $tmemmap
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	If IsHWnd($hwnd) Then
		If $funicode Then
			$ibuffer = _sendmessage($hwnd, $lvm_getisearchstringw) + 1
		Else
			$ibuffer = _sendmessage($hwnd, $lvm_getisearchstringa) + 1
		EndIf
	Else
		If $funicode Then
			$ibuffer = GUICtrlSendMsg($hwnd, $lvm_getisearchstringw, 0, 0) + 1
		Else
			$ibuffer = GUICtrlSendMsg($hwnd, $lvm_getisearchstringa, 0, 0) + 1
		EndIf
	EndIf
	If $ibuffer = 1 Then Return ""
	If $funicode Then
		$ibuffer *= 2
		$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
	Else
		$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			If $funicode Then
				_sendmessage($hwnd, $lvm_getisearchstringw, 0, $pbuffer)
			Else
				_sendmessage($hwnd, $lvm_getisearchstringa, 0, $pbuffer)
			EndIf
		Else
			$pmemory = _meminit($hwnd, $ibuffer, $tmemmap)
			If $funicode Then
				_sendmessage($hwnd, $lvm_getisearchstringw, 0, $pmemory)
			Else
				_sendmessage($hwnd, $lvm_getisearchstringa, 0, $pmemory)
			EndIf
			_memread($tmemmap, $pmemory, $pbuffer, $ibuffer)
			_memfree($tmemmap)
		EndIf
	Else
		If $funicode Then
			GUICtrlSendMsg($hwnd, $lvm_getisearchstringw, 0, $pbuffer)
		Else
			GUICtrlSendMsg($hwnd, $lvm_getisearchstringa, 0, $pbuffer)
		EndIf
	EndIf
	Return DllStructGetData($tbuffer, "Text")
EndFunc

Func _guictrllistview_getitem($hwnd, $iindex, $isubitem = 0)
	Local $istate, $titem, $aitem[8]
	$titem = DllStructCreate($taglvitem)
	DllStructSetData($titem, "Mask", BitOR($lvif_groupid, $lvif_image, $lvif_indent, $lvif_param, $lvif_state))
	DllStructSetData($titem, "Item", $iindex)
	DllStructSetData($titem, "SubItem", $isubitem)
	DllStructSetData($titem, "StateMask", -1)
	_guictrllistview_getitemex($hwnd, $titem)
	$istate = DllStructGetData($titem, "State")
	If BitAND($istate, $lvis_cut) <> 0 Then $aitem[0] = BitOR($aitem[0], 1)
	If BitAND($istate, $lvis_drophilited) <> 0 Then $aitem[0] = BitOR($aitem[0], 2)
	If BitAND($istate, $lvis_focused) <> 0 Then $aitem[0] = BitOR($aitem[0], 4)
	If BitAND($istate, $lvis_selected) <> 0 Then $aitem[0] = BitOR($aitem[0], 8)
	$aitem[1] = _guictrllistview_overlayimagemasktoindex($istate)
	$aitem[2] = _guictrllistview_stateimagemasktoindex($istate)
	$aitem[3] = _guictrllistview_getitemtext($hwnd, $iindex, $isubitem)
	$aitem[4] = DllStructGetData($titem, "Image")
	$aitem[5] = DllStructGetData($titem, "Param")
	$aitem[6] = DllStructGetData($titem, "Indent")
	$aitem[7] = DllStructGetData($titem, "GroupID")
	Return $aitem
EndFunc

Func _guictrllistview_getitemchecked($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $tlvitem = DllStructCreate($taglvitem)
	Local $iresult, $tmemmap, $pmemory, $pitem, $isize
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$isize = DllStructGetSize($tlvitem)
	$pitem = DllStructGetPtr($tlvitem)
	If @error Then Return SetError($lv_err, $lv_err, False)
	DllStructSetData($tlvitem, "Mask", $lvif_state)
	DllStructSetData($tlvitem, "Item", $iindex)
	DllStructSetData($tlvitem, "StateMask", 65535)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_getitemw, 0, $pitem, 0, "wparam", "ptr") <> 0
			Else
				$iresult = _sendmessage($hwnd, $lvm_getitema, 0, $pitem, 0, "wparam", "ptr") <> 0
			EndIf
		Else
			$pmemory = _meminit($hwnd, $isize, $tmemmap)
			_memwrite($tmemmap, $pitem)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_getitemw, 0, $pmemory, 0, "wparam", "ptr") <> 0
			Else
				$iresult = _sendmessage($hwnd, $lvm_getitema, 0, $pmemory, 0, "wparam", "ptr") <> 0
			EndIf
			_memread($tmemmap, $pmemory, $pitem, $isize)
			_memfree($tmemmap)
		EndIf
	Else
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getitemw, 0, $pitem) <> 0
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getitema, 0, $pitem) <> 0
		EndIf
	EndIf
	If NOT $iresult Then Return SetError($lv_err, $lv_err, False)
	Return BitAND(DllStructGetData($tlvitem, "State"), 8192) <> 0
EndFunc

Func _guictrllistview_getitemcount($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getitemcount)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getitemcount, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getitemcut($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Return _guictrllistview_getitemstate($hwnd, $iindex, $lvis_cut) <> 0
EndFunc

Func _guictrllistview_getitemdrophilited($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Return _guictrllistview_getitemstate($hwnd, $iindex, $lvis_drophilited) <> 0
EndFunc

Func _guictrllistview_getitemex($hwnd, ByRef $titem)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iitem, $pitem, $pmemory, $tmemmap, $iresult
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$pitem = DllStructGetPtr($titem)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_getitemw, 0, $pitem, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_getitema, 0, $pitem, 0, "wparam", "ptr")
			EndIf
		Else
			$iitem = DllStructGetSize($titem)
			$pmemory = _meminit($hwnd, $iitem, $tmemmap)
			_memwrite($tmemmap, $pitem)
			If $funicode Then
				_sendmessage($hwnd, $lvm_getitemw, 0, $pmemory, 0, "wparam", "ptr")
			Else
				_sendmessage($hwnd, $lvm_getitema, 0, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memread($tmemmap, $pmemory, $pitem, $iitem)
			_memfree($tmemmap)
		EndIf
	Else
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getitemw, 0, $pitem)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getitema, 0, $pitem)
		EndIf
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_getitemfocused($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Return _guictrllistview_getitemstate($hwnd, $iindex, $lvis_focused) <> 0
EndFunc

Func _guictrllistview_getitemgroupid($hwnd, $iindex)
	Local $titem
	$titem = DllStructCreate($taglvitem)
	DllStructSetData($titem, "Mask", $lvif_groupid)
	DllStructSetData($titem, "Item", $iindex)
	_guictrllistview_getitemex($hwnd, $titem)
	Return DllStructGetData($titem, "GroupID")
EndFunc

Func _guictrllistview_getitemimage($hwnd, $iindex, $isubitem = 0)
	Local $titem
	$titem = DllStructCreate($taglvitem)
	DllStructSetData($titem, "Mask", $lvif_image)
	DllStructSetData($titem, "Item", $iindex)
	DllStructSetData($titem, "SubItem", $isubitem)
	_guictrllistview_getitemex($hwnd, $titem)
	Return DllStructGetData($titem, "Image")
EndFunc

Func _guictrllistview_getitemindent($hwnd, $iindex)
	Local $titem
	$titem = DllStructCreate($taglvitem)
	DllStructSetData($titem, "Mask", $lvif_indent)
	DllStructSetData($titem, "Item", $iindex)
	_guictrllistview_getitemex($hwnd, $titem)
	Return DllStructGetData($titem, "Indent")
EndFunc

Func _guictrllistview_getitemoverlayimage($hwnd, $iindex)
	Return BitShift(_guictrllistview_getitemstate($hwnd, $iindex, $lvis_overlaymask), 8)
EndFunc

Func _guictrllistview_getitemparam($hwnd, $iindex)
	Local $titem
	$titem = DllStructCreate($taglvitem)
	DllStructSetData($titem, "Mask", $lvif_param)
	DllStructSetData($titem, "Item", $iindex)
	_guictrllistview_getitemex($hwnd, $titem)
	Return DllStructGetData($titem, "Param")
EndFunc

Func _guictrllistview_getitemposition($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ipoint, $ppoint, $tpoint, $pmemory, $tmemmap, $apoint[2], $iresult
	$tpoint = DllStructCreate($tagpoint)
	$ppoint = DllStructGetPtr($tpoint)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			If NOT _sendmessage($hwnd, $lvm_getitemposition, $iindex, $ppoint, 0, "wparam", "ptr") Then Return $apoint
		Else
			$ipoint = DllStructGetSize($tpoint)
			$pmemory = _meminit($hwnd, $ipoint, $tmemmap)
			If NOT _sendmessage($hwnd, $lvm_getitemposition, $iindex, $pmemory, 0, "wparam", "ptr") Then Return $apoint
			_memread($tmemmap, $pmemory, $ppoint, $ipoint)
			_memfree($tmemmap)
		EndIf
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_getitemposition, $iindex, $ppoint)
		If NOT $iresult Then Return $apoint
	EndIf
	$apoint[0] = DllStructGetData($tpoint, "X")
	$apoint[1] = DllStructGetData($tpoint, "Y")
	Return $apoint
EndFunc

Func _guictrllistview_getitempositionx($hwnd, $iindex)
	Local $apoint = _guictrllistview_getitemposition($hwnd, $iindex)
	Return $apoint[0]
EndFunc

Func _guictrllistview_getitempositiony($hwnd, $iindex)
	Local $apoint = _guictrllistview_getitemposition($hwnd, $iindex)
	Return $apoint[1]
EndFunc

Func _guictrllistview_getitemrect($hwnd, $iindex, $ipart = 3)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $trect, $arect[4]
	$trect = _guictrllistview_getitemrectex($hwnd, $iindex, $ipart)
	$arect[0] = DllStructGetData($trect, "Left")
	$arect[1] = DllStructGetData($trect, "Top")
	$arect[2] = DllStructGetData($trect, "Right")
	$arect[3] = DllStructGetData($trect, "Bottom")
	Return $arect
EndFunc

Func _guictrllistview_getitemrectex($hwnd, $iindex, $ipart = 3)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $irect, $prect, $trect, $pmemory, $tmemmap
	$trect = DllStructCreate($tagrect)
	$prect = DllStructGetPtr($trect)
	DllStructSetData($trect, "Left", $ipart)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			_sendmessage($hwnd, $lvm_getitemrect, $iindex, $prect, 0, "wparam", "ptr")
		Else
			$irect = DllStructGetSize($trect)
			$pmemory = _meminit($hwnd, $irect, $tmemmap)
			_memwrite($tmemmap, $prect, $pmemory, $irect)
			_sendmessage($hwnd, $lvm_getitemrect, $iindex, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $prect, $irect)
			_memfree($tmemmap)
		EndIf
	Else
		GUICtrlSendMsg($hwnd, $lvm_getitemrect, $iindex, $prect)
	EndIf
	Return $trect
EndFunc

Func _guictrllistview_getitemselected($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Return _guictrllistview_getitemstate($hwnd, $iindex, $lvis_selected) <> 0
EndFunc

Func _guictrllistview_getitemspacing($hwnd, $fsmall = False)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ispace, $aspace[2]
	If IsHWnd($hwnd) Then
		$ispace = _sendmessage($hwnd, $lvm_getitemspacing, $fsmall)
	Else
		$ispace = GUICtrlSendMsg($hwnd, $lvm_getitemspacing, $fsmall, 0)
	EndIf
	$aspace[0] = BitAND($ispace, 65535)
	$aspace[1] = BitShift($ispace, 16)
	Return $aspace
EndFunc

Func _guictrllistview_getitemspacingx($hwnd, $fsmall = False)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return BitAND(_sendmessage($hwnd, $lvm_getitemspacing, $fsmall, 0), 65535)
	Else
		Return BitAND(GUICtrlSendMsg($hwnd, $lvm_getitemspacing, $fsmall, 0), 65535)
	EndIf
EndFunc

Func _guictrllistview_getitemspacingy($hwnd, $fsmall = False)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return BitShift(_sendmessage($hwnd, $lvm_getitemspacing, $fsmall, 0), 16)
	Else
		Return BitShift(GUICtrlSendMsg($hwnd, $lvm_getitemspacing, $fsmall, 0), 16)
	EndIf
EndFunc

Func _guictrllistview_getitemstate($hwnd, $iindex, $imask)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getitemstate, $iindex, $imask)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getitemstate, $iindex, $imask)
	EndIf
EndFunc

Func _guictrllistview_getitemstateimage($hwnd, $iindex)
	Return BitShift(_guictrllistview_getitemstate($hwnd, $iindex, $lvis_stateimagemask), 12)
EndFunc

Func _guictrllistview_getitemtext($hwnd, $iindex, $isubitem = 0)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $pbuffer, $tbuffer, $iitem, $pitem, $titem, $pmemory, $tmemmap, $ptext
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	If $funicode Then
		$tbuffer = DllStructCreate("wchar Text[4096]")
	Else
		$tbuffer = DllStructCreate("char Text[4096]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$titem = DllStructCreate($taglvitem)
	$pitem = DllStructGetPtr($titem)
	DllStructSetData($titem, "SubItem", $isubitem)
	DllStructSetData($titem, "TextMax", 4096)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($titem, "Text", $pbuffer)
			If $funicode Then
				_sendmessage($hwnd, $lvm_getitemtextw, $iindex, $pitem, 0, "wparam", "ptr")
			Else
				_sendmessage($hwnd, $lvm_getitemtexta, $iindex, $pitem, 0, "wparam", "ptr")
			EndIf
		Else
			$iitem = DllStructGetSize($titem)
			$pmemory = _meminit($hwnd, $iitem + 4096, $tmemmap)
			$ptext = $pmemory + $iitem
			DllStructSetData($titem, "Text", $ptext)
			_memwrite($tmemmap, $pitem, $pmemory, $iitem)
			If $funicode Then
				_sendmessage($hwnd, $lvm_getitemtextw, $iindex, $pmemory, 0, "wparam", "ptr")
			Else
				_sendmessage($hwnd, $lvm_getitemtexta, $iindex, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memread($tmemmap, $ptext, $pbuffer, 4096)
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($titem, "Text", $pbuffer)
		If $funicode Then
			GUICtrlSendMsg($hwnd, $lvm_getitemtextw, $iindex, $pitem)
		Else
			GUICtrlSendMsg($hwnd, $lvm_getitemtexta, $iindex, $pitem)
		EndIf
	EndIf
	Return DllStructGetData($tbuffer, "Text")
EndFunc

Func _guictrllistview_getitemtextarray($hwnd, $iitem = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $vitems[1], $separatorchar = Opt("GUIDataSeparatorChar")
	$vitems = _guictrllistview_getitemtextstring($hwnd, $iitem)
	If @error OR $vitems = "" Then Return SetError($lv_err, $lv_err, $vitems)
	Return StringSplit($vitems, $separatorchar)
EndFunc

Func _guictrllistview_getitemtextstring($hwnd, $iitem = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $srow = "", $separatorchar = Opt("GUIDataSeparatorChar")
	If $iitem <> -1 Then
		For $x = 0 To _guictrllistview_getcolumncount($hwnd) - 1
			$srow &= _guictrllistview_getitemtext($hwnd, $iitem, $x) & $separatorchar
		Next
		Return StringTrimRight($srow, 1)
	Else
		For $x = 0 To _guictrllistview_getcolumncount($hwnd) - 1
			$srow &= _guictrllistview_getitemtext($hwnd, _guictrllistview_getnextitem($hwnd), $x) & $separatorchar
		Next
		Return StringTrimRight($srow, 1)
	EndIf
EndFunc

Func _guictrllistview_getnextitem($hwnd, $istart = -1, $isearch = 0, $istate = 8)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iflags, $asearch[5] = [$lvni_all, $lvni_above, $lvni_below, $lvni_toleft, $lvni_toright]
	$iflags = $asearch[$isearch]
	If BitAND($istate, 1) <> 0 Then $iflags = BitOR($iflags, $lvni_cut)
	If BitAND($istate, 2) <> 0 Then $iflags = BitOR($iflags, $lvni_drophilited)
	If BitAND($istate, 4) <> 0 Then $iflags = BitOR($iflags, $lvni_focused)
	If BitAND($istate, 8) <> 0 Then $iflags = BitOR($iflags, $lvni_selected)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getnextitem, $istart, $iflags)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getnextitem, $istart, $iflags)
	EndIf
EndFunc

Func _guictrllistview_getnumberofworkareas($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ibuffer, $pbuffer, $tbuffer, $tmemmap, $pmemory
	$tbuffer = DllStructCreate("int Data")
	$pbuffer = DllStructGetPtr($tbuffer)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			_sendmessage($hwnd, $lvm_getnumberofworkareas, 0, $pbuffer, 0, "wparam", "ptr")
		Else
			$ibuffer = DllStructGetSize($tbuffer)
			$pmemory = _meminit($hwnd, $ibuffer, $tmemmap)
			_sendmessage($hwnd, $lvm_getnumberofworkareas, 0, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $pbuffer, $ibuffer)
			_memfree($tmemmap)
		EndIf
	Else
		GUICtrlSendMsg($hwnd, $lvm_getnumberofworkareas, 0, $pbuffer)
	EndIf
	Return DllStructGetData($tbuffer, "Data")
EndFunc

Func _guictrllistview_getorigin($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ipoint, $ppoint, $tpoint, $pmemory, $tmemmap, $aorigin[2], $iresult
	$tpoint = DllStructCreate($tagpoint)
	$ppoint = DllStructGetPtr($tpoint)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			$iresult = _sendmessage($hwnd, $lvm_getorigin, 0, $ppoint, 0, "wparam", "ptr")
		Else
			$ipoint = DllStructGetSize($tpoint)
			$pmemory = _meminit($hwnd, $ipoint, $tmemmap)
			$iresult = _sendmessage($hwnd, $lvm_getorigin, 0, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $ppoint, $ipoint)
			_memfree($tmemmap)
		EndIf
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_getorigin, 0, $ppoint)
	EndIf
	$aorigin[0] = DllStructGetData($tpoint, "X")
	$aorigin[1] = DllStructGetData($tpoint, "Y")
	Return SetError(@error, $iresult = 1, $aorigin)
EndFunc

Func _guictrllistview_getoriginx($hwnd)
	Local $aorigin = _guictrllistview_getorigin($hwnd)
	Return $aorigin[0]
EndFunc

Func _guictrllistview_getoriginy($hwnd)
	Local $aorigin = _guictrllistview_getorigin($hwnd)
	Return $aorigin[1]
EndFunc

Func _guictrllistview_getoutlinecolor($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getoutlinecolor)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getoutlinecolor, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getselectedcolumn($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getselectedcolumn)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getselectedcolumn, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getselectedcount($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getselectedcount)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getselectedcount, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getselectedindices($hwnd, $farray = False)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $sindices, $aindices[1] = [0]
	Local $iresult, $icount = _guictrllistview_getitemcount($hwnd)
	For $iitem = 0 To $icount
		If IsHWnd($hwnd) Then
			$iresult = _sendmessage($hwnd, $lvm_getitemstate, $iitem, $lvis_selected)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getitemstate, $iitem, $lvis_selected)
		EndIf
		If $iresult Then
			If (NOT $farray) Then
				If StringLen($sindices) Then
					$sindices &= "|" & $iitem
				Else
					$sindices = $iitem
				EndIf
			Else
				ReDim $aindices[UBound($aindices) + 1]
				$aindices[0] = UBound($aindices) - 1
				$aindices[UBound($aindices) - 1] = $iitem
			EndIf
		EndIf
	Next
	If (NOT $farray) Then
		Return String($sindices)
	Else
		Return $aindices
	EndIf
EndFunc

Func _guictrllistview_getselectionmark($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getselectionmark)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getselectionmark, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getstringwidth($hwnd, $sstring)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ibuffer, $pbuffer, $tbuffer, $pmemory, $tmemmap, $iresult
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$ibuffer = StringLen($sstring) + 1
	If $funicode Then
		$ibuffer *= 2
		$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
	Else
		$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	DllStructSetData($tbuffer, "Text", $sstring)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_getstringwidthw, 0, $pbuffer, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_getstringwidtha, 0, $pbuffer, 0, "wparam", "ptr")
			EndIf
		Else
			$pmemory = _meminit($hwnd, $ibuffer, $tmemmap)
			_memwrite($tmemmap, $pbuffer, $pmemory, $ibuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_getstringwidthw, 0, $pmemory, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_getstringwidtha, 0, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memread($tmemmap, $pmemory, $pbuffer, $ibuffer)
			_memfree($tmemmap)
		EndIf
	Else
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getstringwidthw, 0, $pbuffer)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_getstringwidtha, 0, $pbuffer)
		EndIf
	EndIf
	Return $iresult
EndFunc

Func _guictrllistview_getsubitemrect($hwnd, $iindex, $isubitem, $ipart = 0)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $irect, $prect, $trect, $pmemory, $tmemmap, $arect[4], $apart[2] = [$lvir_bounds, $lvir_icon]
	$trect = DllStructCreate($tagrect)
	$prect = DllStructGetPtr($trect)
	DllStructSetData($trect, "Top", $isubitem)
	DllStructSetData($trect, "Left", $apart[$ipart])
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			_sendmessage($hwnd, $lvm_getsubitemrect, $iindex, $prect, 0, "wparam", "ptr")
		Else
			$irect = DllStructGetSize($trect)
			$pmemory = _meminit($hwnd, $irect, $tmemmap)
			_memwrite($tmemmap, $prect, $pmemory, $irect)
			_sendmessage($hwnd, $lvm_getsubitemrect, $iindex, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $prect, $irect)
			_memfree($tmemmap)
		EndIf
	Else
		GUICtrlSendMsg($hwnd, $lvm_getsubitemrect, $iindex, $prect)
	EndIf
	$arect[0] = DllStructGetData($trect, "Left")
	$arect[1] = DllStructGetData($trect, "Top")
	$arect[2] = DllStructGetData($trect, "Right")
	$arect[3] = DllStructGetData($trect, "Bottom")
	Return $arect
EndFunc

Func _guictrllistview_gettextbkcolor($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_gettextbkcolor)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_gettextbkcolor, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_gettextcolor($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_gettextcolor)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_gettextcolor, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_gettooltips($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return HWnd(_sendmessage($hwnd, $lvm_gettooltips))
	Else
		Return HWnd(GUICtrlSendMsg($hwnd, $lvm_gettooltips, 0, 0))
	EndIf
EndFunc

Func _guictrllistview_gettopindex($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_gettopindex)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_gettopindex, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_getunicodeformat($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_getunicodeformat) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_getunicodeformat, 0, 0) <> 0
	EndIf
EndFunc

Func _guictrllistview_getview($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $view
	If IsHWnd($hwnd) Then
		$view = _sendmessage($hwnd, $lvm_getview)
	Else
		$view = GUICtrlSendMsg($hwnd, $lvm_getview, 0, 0)
	EndIf
	Switch $view
		Case $lv_view_details
			Return 0
		Case $lv_view_icon
			Return 1
		Case $lv_view_list
			Return 2
		Case $lv_view_smallicon
			Return 3
		Case $lv_view_tile
			Return 4
		Case Else
			Return -1
	EndSwitch
EndFunc

Func _guictrllistview_getviewdetails($hwnd)
	Return _guictrllistview_getview($hwnd) = 0
EndFunc

Func _guictrllistview_getviewlarge($hwnd)
	Return _guictrllistview_getview($hwnd) = 1
EndFunc

Func _guictrllistview_getviewlist($hwnd)
	Return _guictrllistview_getview($hwnd) = 2
EndFunc

Func _guictrllistview_getviewsmall($hwnd)
	Return _guictrllistview_getview($hwnd) = 3
EndFunc

Func _guictrllistview_getviewtile($hwnd)
	Return _guictrllistview_getview($hwnd) = 4
EndFunc

Func _guictrllistview_getviewrect($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iview, $irect, $prect, $trect, $pmemory, $tmemmap, $arect[4] = [0, 0, 0, 0]
	$iview = _guictrllistview_getview($hwnd)
	If ($iview <> 1) AND ($iview <> 3) Then Return $arect
	$trect = DllStructCreate($tagrect)
	$prect = DllStructGetPtr($trect)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			_sendmessage($hwnd, $lvm_getviewrect, 0, $prect, 0, "wparam", "ptr")
		Else
			$irect = DllStructGetSize($trect)
			$pmemory = _meminit($hwnd, $irect, $tmemmap)
			_sendmessage($hwnd, $lvm_getviewrect, 0, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $prect, $irect)
			_memfree($tmemmap)
		EndIf
	Else
		GUICtrlSendMsg($hwnd, $lvm_getviewrect, 0, $prect)
	EndIf
	$arect[0] = DllStructGetData($trect, "Left")
	$arect[1] = DllStructGetData($trect, "Top")
	$arect[2] = DllStructGetData($trect, "Right")
	$arect[3] = DllStructGetData($trect, "Bottom")
	Return $arect
EndFunc

Func _guictrllistview_hidecolumn($hwnd, $icol)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setcolumnwidth, $icol) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setcolumnwidth, $icol, 0) <> 0
	EndIf
EndFunc

Func _guictrllistview_hittest($hwnd, $ix = -1, $iy = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iflags, $itest, $ttest, $ptest, $pmemory, $tmemmap, $atest[10]
	Local $imode, $apos, $tpoint
	$imode = Opt("MouseCoordMode", 1)
	$apos = MouseGetPos()
	Opt("MouseCoordMode", $imode)
	$tpoint = DllStructCreate($tagpoint)
	DllStructSetData($tpoint, "X", $apos[0])
	DllStructSetData($tpoint, "Y", $apos[1])
	DllCall("User32.dll", "int", "ScreenToClient", "hwnd", $hwnd, "ptr", DllStructGetPtr($tpoint))
	If $ix = -1 Then $ix = DllStructGetData($tpoint, "X")
	If $iy = -1 Then $iy = DllStructGetData($tpoint, "Y")
	$ttest = DllStructCreate($taglvhittestinfo)
	$ptest = DllStructGetPtr($ttest)
	DllStructSetData($ttest, "X", $ix)
	DllStructSetData($ttest, "Y", $iy)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			$atest[0] = _sendmessage($hwnd, $lvm_hittest, 0, $ptest, 0, "wparam", "ptr")
		Else
			$itest = DllStructGetSize($ttest)
			$pmemory = _meminit($hwnd, $itest, $tmemmap)
			_memwrite($tmemmap, $ptest, $pmemory, $itest)
			$atest[0] = _sendmessage($hwnd, $lvm_hittest, 0, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $ptest, $itest)
			_memfree($tmemmap)
		EndIf
	Else
		$atest[0] = GUICtrlSendMsg($hwnd, $lvm_hittest, 0, $ptest)
	EndIf
	$iflags = DllStructGetData($ttest, "Flags")
	$atest[1] = BitAND($iflags, $lvht_nowhere) <> 0
	$atest[2] = BitAND($iflags, $lvht_onitemicon) <> 0
	$atest[3] = BitAND($iflags, $lvht_onitemlabel) <> 0
	$atest[4] = BitAND($iflags, $lvht_onitemstateicon) <> 0
	$atest[5] = BitAND($iflags, $lvht_onitem) <> 0
	$atest[6] = BitAND($iflags, $lvht_above) <> 0
	$atest[7] = BitAND($iflags, $lvht_below) <> 0
	$atest[8] = BitAND($iflags, $lvht_toleft) <> 0
	$atest[9] = BitAND($iflags, $lvht_toright) <> 0
	Return $atest
EndFunc

Func _guictrllistview_indextooverlayimagemask($iindex)
	Return BitShift($iindex, -8)
EndFunc

Func _guictrllistview_indextostateimagemask($iindex)
	Return BitShift($iindex, -12)
EndFunc

Func _guictrllistview_insertcolumn($hwnd, $iindex, $stext, $iwidth = 50, $ialign = -1, $iimage = -1, $fonright = False)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ibuffer, $pbuffer, $tbuffer, $icolumn, $pcolumn, $tcolumn, $pmemory, $tmemmap, $ptext, $imask, $ifmt, $iresult
	Local $aalign[3] = [$lvcfmt_left, $lvcfmt_right, $lvcfmt_center]
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$ibuffer = StringLen($stext) + 1
	If $funicode Then
		$ibuffer *= 2
		$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
	Else
		$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$tcolumn = DllStructCreate($taglvcolumn)
	$pcolumn = DllStructGetPtr($tcolumn)
	$imask = BitOR($lvcf_fmt, $lvcf_width, $lvcf_text)
	If $ialign < 0 OR $ialign > 2 Then $ialign = 0
	$ifmt = $aalign[$ialign]
	If $iimage <> -1 Then
		$imask = BitOR($imask, $lvcf_image)
		$ifmt = BitOR($ifmt, $lvcfmt_col_has_images, $lvcfmt_image)
	EndIf
	If $fonright Then $ifmt = BitOR($ifmt, $lvcfmt_bitmap_on_right)
	DllStructSetData($tbuffer, "Text", $stext)
	DllStructSetData($tcolumn, "Mask", $imask)
	DllStructSetData($tcolumn, "Fmt", $ifmt)
	DllStructSetData($tcolumn, "CX", $iwidth)
	DllStructSetData($tcolumn, "TextMax", $ibuffer)
	DllStructSetData($tcolumn, "Image", $iimage)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($tcolumn, "Text", $pbuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_insertcolumnw, $iindex, $pcolumn, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_insertcolumna, $iindex, $pcolumn, 0, "wparam", "ptr")
			EndIf
		Else
			$icolumn = DllStructGetSize($tcolumn)
			$pmemory = _meminit($hwnd, $icolumn + $ibuffer, $tmemmap)
			$ptext = $pmemory + $icolumn
			DllStructSetData($tcolumn, "Text", $ptext)
			_memwrite($tmemmap, $pcolumn, $pmemory, $icolumn)
			_memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_insertcolumnw, $iindex, $pmemory, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_insertcolumna, $iindex, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($tcolumn, "Text", $pbuffer)
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_insertcolumnw, $iindex, $pcolumn)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_insertcolumna, $iindex, $pcolumn)
		EndIf
	EndIf
	If $ialign > 0 Then _guictrllistview_setcolumn($hwnd, $iresult, $stext, $iwidth, $ialign, $iimage, $fonright)
	Return $iresult
EndFunc

Func _guictrllistview_insertgroup($hwnd, $iindex, $igroupid, $sheader, $ialign = 0)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iheader, $pheader, $theader, $igroup, $pgroup, $tgroup, $pmemory, $tmemmap, $ptext, $imask, $iresult
	Local $aalign[3] = [$lvga_header_left, $lvga_header_center, $lvga_header_right]
	If $ialign < 0 OR $ialign > 2 Then $ialign = 0
	$theader = _winapi_multibytetowidechar($sheader)
	$ptext = DllStructGetPtr($theader)
	$pheader = DllStructGetPtr($theader)
	$iheader = StringLen($sheader)
	$tgroup = DllStructCreate($taglvgroup)
	$pgroup = DllStructGetPtr($tgroup)
	$igroup = DllStructGetSize($tgroup)
	$imask = BitOR($lvgf_header, $lvgf_align, $lvgf_groupid)
	DllStructSetData($tgroup, "Size", $igroup)
	DllStructSetData($tgroup, "Mask", $imask)
	DllStructSetData($tgroup, "HeaderMax", $iheader)
	DllStructSetData($tgroup, "GroupID", $igroupid)
	DllStructSetData($tgroup, "Align", $aalign[$ialign])
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($tgroup, "Header", $pheader)
			$iresult = _sendmessage($hwnd, $lvm_insertgroup, $iindex, $pgroup, 0, "wparam", "ptr")
		Else
			$pmemory = _meminit($hwnd, $igroup + $iheader, $tmemmap)
			$ptext = $pmemory + $igroup
			DllStructSetData($tgroup, "Header", $ptext)
			_memwrite($tmemmap, $pgroup, $pmemory, $igroup)
			_memwrite($tmemmap, $pheader, $ptext, $iheader)
			$iresult = _sendmessage($hwnd, $lvm_insertgroup, $iindex, $pgroup, 0, "wparam", "ptr")
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($tgroup, "Header", $pheader)
		$iresult = GUICtrlSendMsg($hwnd, $lvm_insertgroup, $iindex, $pgroup)
	EndIf
	Return $iresult
EndFunc

Func _guictrllistview_insertitem($hwnd, $stext, $iindex = -1, $iimage = -1, $iparam = 0)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ibuffer, $pbuffer, $tbuffer, $iitem, $pitem, $titem, $pmemory, $tmemmap, $ptext, $imask, $iresult
	If $iindex = -1 Then $iindex = 999999999
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$titem = DllStructCreate($taglvitem)
	$pitem = DllStructGetPtr($titem)
	DllStructSetData($titem, "Param", $iparam)
	If $stext <> -1 Then
		$ibuffer = StringLen($stext) + 1
		If $funicode Then
			$ibuffer *= 2
			$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
		Else
			$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
		EndIf
		$pbuffer = DllStructGetPtr($tbuffer)
		DllStructSetData($tbuffer, "Text", $stext)
		DllStructSetData($titem, "Text", $pbuffer)
		DllStructSetData($titem, "TextMax", $ibuffer)
	Else
		DllStructSetData($titem, "Text", -1)
	EndIf
	$imask = BitOR($lvif_text, $lvif_param)
	If $iimage >= 0 Then $imask = BitOR($imask, $lvif_image)
	DllStructSetData($titem, "Mask", $imask)
	DllStructSetData($titem, "Item", $iindex)
	DllStructSetData($titem, "Image", $iimage)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) OR ($stext = -1) Then
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_insertitemw, 0, $pitem, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_insertitema, 0, $pitem, 0, "wparam", "ptr")
			EndIf
		Else
			$iitem = DllStructGetSize($titem)
			$pmemory = _meminit($hwnd, $iitem + $ibuffer, $tmemmap)
			$ptext = $pmemory + $iitem
			DllStructSetData($titem, "Text", $ptext)
			_memwrite($tmemmap, $pitem, $pmemory, $iitem)
			_memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_insertitemw, 0, $pmemory, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_insertitema, 0, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memfree($tmemmap)
		EndIf
	Else
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_insertitemw, 0, $pitem)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_insertitema, 0, $pitem)
		EndIf
	EndIf
	Return $iresult
EndFunc

Func _guictrllistview_insertmarkhittest($hwnd, $ix = -1, $iy = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ipoint, $ppoint, $tpoint, $imark, $tmark, $pmark, $pmemm, $pmemp, $tmemmap, $atest[2]
	Local $imode, $apos
	$imode = Opt("MouseCoordMode", 1)
	$apos = MouseGetPos()
	Opt("MouseCoordMode", $imode)
	$tpoint = DllStructCreate($tagpoint)
	DllStructSetData($tpoint, "X", $apos[0])
	DllStructSetData($tpoint, "Y", $apos[1])
	DllCall("User32.dll", "int", "ScreenToClient", "hwnd", $hwnd, "ptr", DllStructGetPtr($tpoint))
	If $ix = -1 Then $ix = DllStructGetData($tpoint, "X")
	If $iy = -1 Then $iy = DllStructGetData($tpoint, "Y")
	$ppoint = DllStructGetPtr($tpoint)
	$tmark = DllStructCreate($taglvinsertmark)
	$pmark = DllStructGetPtr($tmark)
	$imark = DllStructGetSize($tmark)
	DllStructSetData($tpoint, "X", $ix)
	DllStructSetData($tpoint, "Y", $iy)
	DllStructSetData($tmark, "Size", $imark)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			_sendmessage($hwnd, $lvm_insertmarkhittest, $ppoint, $pmark, 0, "wparam", "ptr")
		Else
			$ipoint = DllStructGetSize($tpoint)
			$pmemm = _meminit($hwnd, $ipoint + $imark, $tmemmap)
			$pmemp = $pmemp + $ipoint
			_memwrite($tmemmap, $pmark, $pmemm, $imark)
			_memwrite($tmemmap, $ppoint, $pmemp, $ipoint)
			_sendmessage($hwnd, $lvm_insertmarkhittest, $pmemp, $pmemm, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemm, $pmark, $imark)
			_memfree($tmemmap)
		EndIf
	Else
		GUICtrlSendMsg($hwnd, $lvm_insertmarkhittest, $ppoint, $pmark)
	EndIf
	$atest[0] = DllStructGetData($tmark, "Flags") = $lvim_after
	$atest[1] = DllStructGetData($tmark, "Item")
	Return $atest
EndFunc

Func _guictrllistview_isitemvisible($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_isitemvisible, $iindex) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_isitemvisible, $iindex, 0) <> 0
	EndIf
EndFunc

Func _guictrllistview_justifycolumn($hwnd, $iindex, $ialign = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $icolumn, $pcolumn, $tcolumn, $pmemory, $tmemmap, $imask, $ifmt, $iresult
	Local $aalign[3] = [$lvcfmt_left, $lvcfmt_right, $lvcfmt_center]
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$tcolumn = DllStructCreate($taglvcolumn)
	$pcolumn = DllStructGetPtr($tcolumn)
	If $ialign < 0 OR $ialign > 2 Then $ialign = 0
	$imask = $lvcf_fmt
	$ifmt = $aalign[$ialign]
	DllStructSetData($tcolumn, "Mask", $imask)
	DllStructSetData($tcolumn, "Fmt", $ifmt)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_setcolumnw, $iindex, $pcolumn, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_setcolumna, $iindex, $pcolumn, 0, "wparam", "ptr")
			EndIf
		Else
			$icolumn = DllStructGetSize($tcolumn)
			$pmemory = _meminit($hwnd, $icolumn, $tmemmap)
			_memwrite($tmemmap, $pcolumn, $pmemory, $icolumn)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_setcolumnw, $iindex, $pmemory, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_setcolumna, $iindex, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memfree($tmemmap)
		EndIf
	Else
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setcolumnw, $iindex, $pcolumn)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setcolumna, $iindex, $pcolumn)
		EndIf
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_mapidtoindex($hwnd, $iid)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_mapidtoindex, $iid)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_mapidtoindex, $iid, 0)
	EndIf
EndFunc

Func _guictrllistview_mapindextoid($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_mapindextoid, $iindex)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_mapindextoid, $iindex, 0)
	EndIf
EndFunc

Func _guictrllistview_movegroup($hwnd, $igroupid, $iindex = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_movegroup, $igroupid, $iindex)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_movegroup, $igroupid, $iindex)
	EndIf
EndFunc

Func _guictrllistview_overlayimagemasktoindex($imask)
	Return BitShift(BitAND($lvis_overlaymask, $imask), 8)
EndFunc

Func _guictrllistview_redrawitems($hwnd, $ifirst, $ilast)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_redrawitems, $ifirst, $ilast) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_redrawitems, $ifirst, $ilast) <> 0
	EndIf
EndFunc

Func _guictrllistview_registersortcallback($hwnd, $fnumbers = True, $farrows = True)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iindex, $hheader
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	$hheader = _guictrllistview_getheader($hwnd)
	ReDim $alistviewsortinfo[UBound($alistviewsortinfo) + 1][$illistviewsortinfosize]
	$alistviewsortinfo[0][0] = UBound($alistviewsortinfo) - 1
	$iindex = $alistviewsortinfo[0][0]
	$alistviewsortinfo[$iindex][1] = $hwnd
	$alistviewsortinfo[$iindex][2] = DllCallbackRegister("_GUICtrlListView_Sort", "int", "int;int;hwnd")
	$alistviewsortinfo[$iindex][3] = -1
	$alistviewsortinfo[$iindex][4] = -1
	$alistviewsortinfo[$iindex][5] = 1
	$alistviewsortinfo[$iindex][6] = -1
	$alistviewsortinfo[$iindex][7] = 0
	$alistviewsortinfo[$iindex][8] = $fnumbers
	$alistviewsortinfo[$iindex][9] = $farrows
	$alistviewsortinfo[$iindex][10] = $hheader
	Return $alistviewsortinfo[$iindex][2] <> 0
EndFunc

Func _guictrllistview_removeallgroups($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		_sendmessage($hwnd, $lvm_removeallgroups)
	Else
		GUICtrlSendMsg($hwnd, $lvm_removeallgroups, 0, 0)
	EndIf
EndFunc

Func _guictrllistview_removegroup($hwnd, $igroupid)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_removegroup, $igroupid)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_removegroup, $igroupid, 0)
	EndIf
EndFunc

Func _guictrllistview_reversecolororder($icolor)
	Local $tc = Hex(String($icolor), 6)
	Return "0x" & StringMid($tc, 5, 2) & StringMid($tc, 3, 2) & StringMid($tc, 1, 2)
EndFunc

Func _guictrllistview_scroll($hwnd, $idx, $idy)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_scroll, $idx, $idy) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_scroll, $idx, $idy) <> 0
	EndIf
EndFunc

Func _guictrllistview_setbkcolor($hwnd, $icolor)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iresult
	If IsHWnd($hwnd) Then
		$iresult = _sendmessage($hwnd, $lvm_setbkcolor, 0, $icolor)
		_winapi_invalidaterect($hwnd)
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_setbkcolor, 0, $icolor)
		_winapi_invalidaterect(GUICtrlGetHandle($hwnd))
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_setbkimage($hwnd, $surl = "", $istyle = 0, $ixoffset = 0, $iyoffset = 0)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then Return SetError($lv_err, $lv_err, False)
	Local $ibuffer, $pbuffer, $tbuffer, $iimage, $pimage, $timage, $pmemory, $tmemmap, $ptext, $iresult
	Local $astyle[2] = [$lvbkif_style_normal, $lvbkif_style_tile]
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$ibuffer = StringLen($surl) + 1
	If $funicode Then
		$ibuffer *= 2
		$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
	Else
		$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	EndIf
	If @error Then Return SetError($lv_err, $lv_err, $lv_err)
	$pbuffer = DllStructGetPtr($tbuffer)
	$timage = DllStructCreate($taglvbkimage)
	$pimage = DllStructGetPtr($timage)
	If $surl <> "" Then $iresult = $lvbkif_source_url
	$iresult = BitOR($iresult, $astyle[$istyle])
	DllStructSetData($tbuffer, "Text", $surl)
	DllStructSetData($timage, "Flags", $iresult)
	DllStructSetData($timage, "XOffPercent", $ixoffset)
	DllStructSetData($timage, "YOffPercent", $iyoffset)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($timage, "Image", $pbuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_setbkimagew, 0, $pimage, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_setbkimagea, 0, $pimage, 0, "wparam", "ptr")
			EndIf
		Else
			$iimage = DllStructGetSize($timage)
			$pmemory = _meminit($hwnd, $iimage + $ibuffer, $tmemmap)
			$ptext = $pmemory + $iimage
			DllStructSetData($timage, "Image", $ptext)
			_memwrite($tmemmap, $pimage, $pmemory, $iimage)
			_memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_setbkimagew, 0, $pmemory, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_setbkimagea, 0, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($timage, "Image", $pbuffer)
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setbkimagew, 0, $pimage)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setbkimagea, 0, $pimage)
		EndIf
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_setcallbackmask($hwnd, $imask)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iflags
	If BitAND($imask, 1) <> 0 Then $iflags = BitOR($iflags, $lvis_cut)
	If BitAND($imask, 2) <> 0 Then $iflags = BitOR($iflags, $lvis_drophilited)
	If BitAND($imask, 4) <> 0 Then $iflags = BitOR($iflags, $lvis_focused)
	If BitAND($imask, 8) <> 0 Then $iflags = BitOR($iflags, $lvis_selected)
	If BitAND($imask, 16) <> 0 Then $iflags = BitOR($iflags, $lvis_overlaymask)
	If BitAND($imask, 32) <> 0 Then $iflags = BitOR($iflags, $lvis_stateimagemask)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setcallbackmask, $iflags) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setcallbackmask, $iflags, 0) <> 0
	EndIf
EndFunc

Func _guictrllistview_setcolumn($hwnd, $iindex, $stext, $iwidth = -1, $ialign = -1, $iimage = -1, $fonright = False)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ibuffer, $pbuffer, $tbuffer, $icolumn, $pcolumn, $tcolumn, $pmemory, $tmemmap, $ptext, $imask, $ifmt, $iresult
	Local $aalign[3] = [$lvcfmt_left, $lvcfmt_right, $lvcfmt_center]
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$ibuffer = StringLen($stext) + 1
	If $funicode Then
		$ibuffer *= 2
		$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
	Else
		$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$tcolumn = DllStructCreate($taglvcolumn)
	$pcolumn = DllStructGetPtr($tcolumn)
	$imask = $lvcf_text
	If $ialign < 0 OR $ialign > 2 Then $ialign = 0
	$imask = BitOR($imask, $lvcf_fmt)
	$ifmt = $aalign[$ialign]
	If $iwidth <> -1 Then $imask = BitOR($imask, $lvcf_width)
	If $iimage <> -1 Then
		$imask = BitOR($imask, $lvcf_image)
		$ifmt = BitOR($ifmt, $lvcfmt_col_has_images, $lvcfmt_image)
	Else
		$iimage = 0
	EndIf
	If $fonright Then $ifmt = BitOR($ifmt, $lvcfmt_bitmap_on_right)
	DllStructSetData($tbuffer, "Text", $stext)
	DllStructSetData($tcolumn, "Mask", $imask)
	DllStructSetData($tcolumn, "Fmt", $ifmt)
	DllStructSetData($tcolumn, "CX", $iwidth)
	DllStructSetData($tcolumn, "TextMax", $ibuffer)
	DllStructSetData($tcolumn, "Image", $iimage)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($tcolumn, "Text", $pbuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_setcolumnw, $iindex, $pcolumn, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_setcolumna, $iindex, $pcolumn, 0, "wparam", "ptr")
			EndIf
		Else
			$icolumn = DllStructGetSize($tcolumn)
			$pmemory = _meminit($hwnd, $icolumn + $ibuffer, $tmemmap)
			$ptext = $pmemory + $icolumn
			DllStructSetData($tcolumn, "Text", $ptext)
			_memwrite($tmemmap, $pcolumn, $pmemory, $icolumn)
			_memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_setcolumnw, $iindex, $pmemory, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_setcolumna, $iindex, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($tcolumn, "Text", $pbuffer)
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setcolumnw, $iindex, $pcolumn)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setcolumna, $iindex, $pcolumn)
		EndIf
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_setcolumnorder($hwnd, $sorder)
	Local $separatorchar = Opt("GUIDataSeparatorChar")
	Return _guictrllistview_setcolumnorderarray($hwnd, StringSplit($sorder, $separatorchar))
EndFunc

Func _guictrllistview_setcolumnorderarray($hwnd, $aorder)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ii, $ibuffer, $pbuffer, $tbuffer, $pmemory, $tmemmap, $iresult
	$tbuffer = DllStructCreate("int[" & $aorder[0] & "]")
	$pbuffer = DllStructGetPtr($tbuffer)
	For $ii = 1 To $aorder[0]
		DllStructSetData($tbuffer, 1, $aorder[$ii], $ii)
	Next
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			$iresult = _sendmessage($hwnd, $lvm_setcolumnorderarray, $aorder[0], $pbuffer, 0, "wparam", "ptr")
		Else
			$ibuffer = DllStructGetSize($tbuffer)
			$pmemory = _meminit($hwnd, $ibuffer, $tmemmap)
			_memwrite($tmemmap, $pbuffer, $pmemory, $ibuffer)
			$iresult = _sendmessage($hwnd, $lvm_setcolumnorderarray, $aorder[0], $pmemory, 0, "wparam", "ptr")
			_memfree($tmemmap)
		EndIf
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_setcolumnorderarray, $aorder[0], $pbuffer)
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_setcolumnwidth($hwnd, $icol, $iwidth)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setcolumnwidth, $icol, $iwidth)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setcolumnwidth, $icol, $iwidth)
	EndIf
EndFunc

Func _guictrllistview_setextendedlistviewstyle($hwnd, $iexstyle, $iexmask = 0)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iresult
	If IsHWnd($hwnd) Then
		$iresult = _sendmessage($hwnd, $lvm_setextendedlistviewstyle, $iexmask, $iexstyle)
		_winapi_invalidaterect($hwnd)
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_setextendedlistviewstyle, $iexmask, $iexstyle)
		_winapi_invalidaterect(GUICtrlGetHandle($hwnd))
	EndIf
	Return $iresult
EndFunc

Func _guictrllistview_setgroupinfo($hwnd, $igroupid, $sheader, $ialign = 0, $istate = $lvgs_normal)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iheader, $pheader, $theader, $igroup, $pgroup, $tgroup, $pmemory, $tmemmap, $ptext, $imask, $iresult
	Local $aalign[3] = [$lvga_header_left, $lvga_header_center, $lvga_header_right]
	If $ialign < 0 OR $ialign > 2 Then $ialign = 0
	$theader = _winapi_multibytetowidechar($sheader)
	$pheader = DllStructGetPtr($theader)
	$iheader = StringLen($sheader)
	$tgroup = DllStructCreate($taglvgroup)
	$pgroup = DllStructGetPtr($tgroup)
	$igroup = DllStructGetSize($tgroup)
	$imask = BitOR($lvgf_header, $lvgf_align, $lvgf_state)
	DllStructSetData($tgroup, "Size", $igroup)
	DllStructSetData($tgroup, "Mask", $imask)
	DllStructSetData($tgroup, "HeaderMax", $iheader)
	DllStructSetData($tgroup, "Align", $aalign[$ialign])
	DllStructSetData($tgroup, "State", $istate)
	DllStructSetData($tgroup, "StateMask", $istate)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($tgroup, "Header", $pheader)
			$iresult = _sendmessage($hwnd, $lvm_setgroupinfo, $igroupid, $pgroup)
			DllStructSetData($tgroup, "Mask", $lvgf_groupid)
			DllStructSetData($tgroup, "GroupID", $igroupid)
			_sendmessage($hwnd, $lvm_setgroupinfo, 0, $pgroup)
		Else
			$pmemory = _meminit($hwnd, $igroup + $iheader, $tmemmap)
			$ptext = $pmemory + $igroup
			DllStructSetData($tgroup, "Header", $ptext)
			_memwrite($tmemmap, $pgroup, $pmemory, $igroup)
			_memwrite($tmemmap, $pheader, $ptext, $iheader)
			$iresult = _sendmessage($hwnd, $lvm_setgroupinfo, $igroupid, $pmemory)
			DllStructSetData($tgroup, "Mask", $lvgf_groupid)
			DllStructSetData($tgroup, "GroupID", $igroupid)
			_sendmessage($hwnd, $lvm_setgroupinfo, 0, $pmemory)
			_memfree($tmemmap)
		EndIf
		_winapi_invalidaterect($hwnd)
	Else
		DllStructSetData($tgroup, "Header", $pheader)
		$iresult = GUICtrlSendMsg($hwnd, $lvm_setgroupinfo, $igroupid, $pgroup)
		DllStructSetData($tgroup, "Mask", $lvgf_groupid)
		DllStructSetData($tgroup, "GroupID", $igroupid)
		GUICtrlSendMsg($hwnd, $lvm_setgroupinfo, 0, $pgroup)
		_winapi_invalidaterect(GUICtrlGetHandle($hwnd))
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_sethotcursor($hwnd, $hcursor)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_sethotcursor, 0, $hcursor, 0, "wparam", "hwnd", "hwnd")
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_sethotcursor, 0, $hcursor)
	EndIf
EndFunc

Func _guictrllistview_sethotitem($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_sethotitem, $iindex)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_sethotitem, $iindex, 0)
	EndIf
EndFunc

Func _guictrllistview_sethovertime($hwnd, $itime)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_sethovertime, 0, $itime)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_sethovertime, 0, $itime)
	EndIf
EndFunc

Func _guictrllistview_seticonspacing($hwnd, $icx, $icy)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iresult, $apadding[2]
	If IsHWnd($hwnd) Then
		$iresult = _sendmessage($hwnd, $lvm_seticonspacing, 0, BitOR(BitShift($icy, -16), BitAND($icx, 65535)))
		_winapi_invalidaterect($hwnd)
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_seticonspacing, 0, BitOR(BitShift($icy, -16), BitAND($icx, 65535)))
		_winapi_invalidaterect(GUICtrlGetHandle($hwnd))
	EndIf
	$apadding[0] = BitAND($iresult, 65535)
	$apadding[1] = BitShift($iresult, 16)
	Return $apadding
EndFunc

Func _guictrllistview_setimagelist($hwnd, $hhandle, $itype = 0)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $atype[3] = [$lvsil_normal, $lvsil_small, $lvsil_state]
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setimagelist, $atype[$itype], $hhandle, 0, "wparam", "hwnd", "hwnd")
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setimagelist, $atype[$itype], $hhandle)
	EndIf
EndFunc

Func _guictrllistview_setinfotip($hwnd, $iindex, $stext, $isubitem = 0)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ibuffer, $pbuffer, $tbuffer, $iinfo, $pinfo, $tinfo, $pmemory, $tmemmap, $ptext, $iresult
	$tbuffer = _winapi_multibytetowidechar($stext)
	$pbuffer = DllStructGetPtr($tbuffer)
	$ibuffer = StringLen($stext)
	$tinfo = DllStructCreate($taglvsetinfotip)
	$pinfo = DllStructGetPtr($tinfo)
	$iinfo = DllStructGetSize($tinfo)
	DllStructSetData($tinfo, "Size", $iinfo)
	DllStructSetData($tinfo, "Item", $iindex)
	DllStructSetData($tinfo, "SubItem", $isubitem)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($tinfo, "Text", $pbuffer)
			$iresult = _sendmessage($hwnd, $lvm_setinfotip, 0, $pinfo, 0, "wparam", "ptr")
		Else
			$pmemory = _meminit($hwnd, $iinfo + $ibuffer, $tmemmap)
			$ptext = $pmemory + $iinfo
			DllStructSetData($tinfo, "Text", $ptext)
			_memwrite($tmemmap, $pinfo, $pmemory, $iinfo)
			_memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
			$iresult = _sendmessage($hwnd, $lvm_setinfotip, 0, $pmemory, 0, "wparam", "ptr")
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($tinfo, "Text", $pbuffer)
		$iresult = GUICtrlSendMsg($hwnd, $lvm_setinfotip, 0, $pinfo)
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_setinsertmark($hwnd, $iindex, $fafter = False)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $imark, $pmark, $tmark, $pmemory, $tmemmap, $iresult
	$tmark = DllStructCreate($taglvinsertmark)
	$pmark = DllStructGetPtr($tmark)
	$imark = DllStructGetSize($tmark)
	DllStructSetData($tmark, "Size", $imark)
	If $fafter Then DllStructSetData($tmark, "Flags", $lvim_after)
	DllStructSetData($tmark, "Item", $iindex)
	DllStructSetData($tmark, "Reserved", 0)
	If IsHWnd($hwnd) Then
		$pmemory = _meminit($hwnd, $imark, $tmemmap)
		_memwrite($tmemmap, $pmark, $pmemory, $imark)
		$iresult = _sendmessage($hwnd, $lvm_setinsertmark, 0, $pmemory, 0, "wparam", "ptr")
		_memfree($tmemmap)
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_setinsertmark, 0, $pmark)
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_setinsertmarkcolor($hwnd, $icolor)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setinsertmarkcolor, 0, $icolor)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setinsertmarkcolor, 0, $icolor)
	EndIf
EndFunc

Func _guictrllistview_setitem($hwnd, $stext, $iindex = 0, $isubitem = 0, $iimage = -1, $iparam = -1, $iindent = -1)
	Local $ibuffer, $pbuffer, $tbuffer, $titem, $imask
	$ibuffer = StringLen($stext) + 1
	If _guictrllistview_getunicodeformat($hwnd) Then
		$ibuffer *= 2
		$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
	Else
		$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$titem = DllStructCreate($taglvitem)
	$imask = $lvif_text
	If $iimage <> -1 Then $imask = BitOR($imask, $lvif_image)
	If $iparam <> -1 Then $imask = BitOR($imask, $lvif_param)
	If $iindent <> -1 Then $imask = BitOR($imask, $lvif_indent)
	DllStructSetData($tbuffer, "Text", $stext)
	DllStructSetData($titem, "Mask", $imask)
	DllStructSetData($titem, "Item", $iindex)
	DllStructSetData($titem, "SubItem", $isubitem)
	DllStructSetData($titem, "Text", $pbuffer)
	DllStructSetData($titem, "TextMax", $ibuffer)
	DllStructSetData($titem, "Image", $iimage)
	DllStructSetData($titem, "Param", $iparam)
	DllStructSetData($titem, "Indent", $iindent)
	Return _guictrllistview_setitemex($hwnd, $titem)
EndFunc

Func _guictrllistview_setitemchecked($hwnd, $iindex, $fcheck = True)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iitem, $pitem, $titem, $pmemory, $tmemmap, $iresult
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$titem = DllStructCreate($taglvitem)
	$pitem = DllStructGetPtr($titem)
	$iitem = DllStructGetSize($titem)
	If @error Then Return SetError($lv_err, $lv_err, $lv_err)
	If $iindex <> -1 Then
		DllStructSetData($titem, "Mask", $lvif_state)
		DllStructSetData($titem, "Item", $iindex)
		If ($fcheck) Then
			DllStructSetData($titem, "State", 8192)
		Else
			DllStructSetData($titem, "State", 4096)
		EndIf
		DllStructSetData($titem, "StateMask", 61440)
		If IsHWnd($hwnd) Then
			If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
				If $funicode Then
					Return _sendmessage($hwnd, $lvm_setitemw, 0, $pitem, 0, "wparam", "ptr") <> 0
				Else
					Return _sendmessage($hwnd, $lvm_setitema, 0, $pitem, 0, "wparam", "ptr") <> 0
				EndIf
			Else
				$pmemory = _meminit($hwnd, $iitem, $tmemmap)
				_memwrite($tmemmap, $pitem)
				If $funicode Then
					$iresult = _sendmessage($hwnd, $lvm_setitemw, 0, $pmemory, 0, "wparam", "ptr")
				Else
					$iresult = _sendmessage($hwnd, $lvm_setitema, 0, $pmemory, 0, "wparam", "ptr")
				EndIf
				_memfree($tmemmap)
				Return $iresult <> 0
			EndIf
		Else
			If $funicode Then
				Return GUICtrlSendMsg($hwnd, $lvm_setitemw, 0, $pitem) <> 0
			Else
				Return GUICtrlSendMsg($hwnd, $lvm_setitema, 0, $pitem) <> 0
			EndIf
		EndIf
	Else
		For $x = 0 To _guictrllistview_getitemcount($hwnd) - 1
			DllStructSetData($titem, "Mask", $lvif_state)
			DllStructSetData($titem, "Item", $x)
			If ($fcheck) Then
				DllStructSetData($titem, "State", 8192)
			Else
				DllStructSetData($titem, "State", 4096)
			EndIf
			DllStructSetData($titem, "StateMask", 61440)
			If IsHWnd($hwnd) Then
				If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
					If $funicode Then
						If NOT _sendmessage($hwnd, $lvm_setitemw, 0, $pitem, 0, "wparam", "ptr") <> 0 Then Return SetError($lv_err, $lv_err, $lv_err)
					Else
						If NOT _sendmessage($hwnd, $lvm_setitema, 0, $pitem, 0, "wparam", "ptr") <> 0 Then Return SetError($lv_err, $lv_err, $lv_err)
					EndIf
				Else
					$pmemory = _meminit($hwnd, $iitem, $tmemmap)
					_memwrite($tmemmap, $pitem)
					If $funicode Then
						$iresult = _sendmessage($hwnd, $lvm_setitemw, 0, $pmemory, 0, "wparam", "ptr")
					Else
						$iresult = _sendmessage($hwnd, $lvm_setitema, 0, $pmemory, 0, "wparam", "ptr")
					EndIf
					_memfree($tmemmap)
					If NOT $iresult <> 0 Then Return SetError($lv_err, $lv_err, $lv_err)
				EndIf
			Else
				If $funicode Then
					If NOT GUICtrlSendMsg($hwnd, $lvm_setitemw, 0, $pitem) <> 0 Then Return SetError($lv_err, $lv_err, $lv_err)
				Else
					If NOT GUICtrlSendMsg($hwnd, $lvm_setitema, 0, $pitem) <> 0 Then Return SetError($lv_err, $lv_err, $lv_err)
				EndIf
			EndIf
		Next
		Return True
	EndIf
	Return False
EndFunc

Func _guictrllistview_setitemcount($hwnd, $iitems)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setitemcount, $iitems, BitOR($lvsicf_noinvalidateall, $lvsicf_noscroll)) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setitemcount, $iitems, BitOR($lvsicf_noinvalidateall, $lvsicf_noscroll)) <> 0
	EndIf
EndFunc

Func _guictrllistview_setitemcut($hwnd, $iindex, $fenabled = True)
	Local $istatemask = 0
	If $fenabled Then $istatemask = $lvis_cut
	Return _guictrllistview_setitemstate($hwnd, $iindex, $lvis_cut, $istatemask)
EndFunc

Func _guictrllistview_setitemdrophilited($hwnd, $iindex, $fenabled = True)
	Local $istatemask = 0
	If $fenabled Then $istatemask = $lvis_drophilited
	Return _guictrllistview_setitemstate($hwnd, $iindex, $lvis_drophilited, $istatemask)
EndFunc

Func _guictrllistview_setitemex($hwnd, ByRef $titem)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iitem, $pitem, $ibuffer, $pbuffer, $pmemory, $tmemmap, $ptext, $iresult
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	$pitem = DllStructGetPtr($titem)
	If IsHWnd($hwnd) Then
		$iitem = DllStructGetSize($titem)
		$ibuffer = DllStructGetData($titem, "TextMax")
		If $funicode Then $ibuffer *= 2
		$pbuffer = DllStructGetData($titem, "Text")
		$pmemory = _meminit($hwnd, $iitem + $ibuffer, $tmemmap)
		$ptext = $pmemory + $iitem
		DllStructSetData($titem, "Text", $ptext)
		_memwrite($tmemmap, $pitem, $pmemory, $iitem)
		If $pbuffer <> 0 Then _memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
		If $funicode Then
			$iresult = _sendmessage($hwnd, $lvm_setitemw, 0, $pmemory, 0, "wparam", "ptr")
		Else
			$iresult = _sendmessage($hwnd, $lvm_setitema, 0, $pmemory, 0, "wparam", "ptr")
		EndIf
		_memfree($tmemmap)
	Else
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setitemw, 0, $pitem)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setitema, 0, $pitem)
		EndIf
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_setitemfocused($hwnd, $iindex, $fenabled = True)
	Local $istatemask = 0
	If $fenabled Then $istatemask = $lvis_focused
	Return _guictrllistview_setitemstate($hwnd, $iindex, $lvis_focused, $istatemask)
EndFunc

Func _guictrllistview_setitemgroupid($hwnd, $iindex, $igroupid)
	Local $titem
	$titem = DllStructCreate($taglvitem)
	DllStructSetData($titem, "Mask", $lvif_groupid)
	DllStructSetData($titem, "Item", $iindex)
	DllStructSetData($titem, "GroupID", $igroupid)
	_guictrllistview_setitemex($hwnd, $titem)
EndFunc

Func _guictrllistview_setitemimage($hwnd, $iindex, $iimage, $isubitem = 0)
	Local $titem
	$titem = DllStructCreate($taglvitem)
	DllStructSetData($titem, "Mask", $lvif_image)
	DllStructSetData($titem, "Item", $iindex)
	DllStructSetData($titem, "SubItem", $isubitem)
	DllStructSetData($titem, "Image", $iimage)
	Return _guictrllistview_setitemex($hwnd, $titem)
EndFunc

Func _guictrllistview_setitemindent($hwnd, $iindex, $iindent)
	Local $titem
	$titem = DllStructCreate($taglvitem)
	DllStructSetData($titem, "Mask", $lvif_indent)
	DllStructSetData($titem, "Item", $iindex)
	DllStructSetData($titem, "Indent", $iindent)
	Return _guictrllistview_setitemex($hwnd, $titem)
EndFunc

Func _guictrllistview_setitemoverlayimage($hwnd, $iindex, $iimage)
	Return _guictrllistview_setitemstate($hwnd, $iindex, _guictrllistview_indextooverlayimagemask($iimage), $lvis_overlaymask)
EndFunc

Func _guictrllistview_setitemparam($hwnd, $iindex, $iparam)
	Local $titem
	$titem = DllStructCreate($taglvitem)
	DllStructSetData($titem, "Mask", $lvif_param)
	DllStructSetData($titem, "Item", $iindex)
	DllStructSetData($titem, "Param", $iparam)
	Return _guictrllistview_setitemex($hwnd, $titem)
EndFunc

Func _guictrllistview_setitemposition($hwnd, $iindex, $icx, $icy)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setitemposition, $iindex, BitOR(BitShift($icy, -16), BitAND($icx, 65535))) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setitemposition, $iindex, BitOR(BitShift($icy, -16), BitAND($icx, 65535))) <> 0
	EndIf
EndFunc

Func _guictrllistview_setitemposition32($hwnd, $iindex, $icx, $icy)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ipoint, $ppoint, $tpoint, $pmemory, $tmemmap, $iresult
	$tpoint = DllStructCreate($tagpoint)
	$ppoint = DllStructGetPtr($tpoint)
	DllStructSetData($tpoint, "X", $icx)
	DllStructSetData($tpoint, "Y", $icy)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			$iresult = _sendmessage($hwnd, $lvm_setitemposition32, $iindex, $ppoint, 0, "wparam", "ptr")
		Else
			$ipoint = DllStructGetSize($tpoint)
			$pmemory = _meminit($hwnd, $ipoint, $tmemmap)
			_memwrite($tmemmap, $ppoint)
			$iresult = _sendmessage($hwnd, $lvm_setitemposition32, $iindex, $pmemory, 0, "wparam", "ptr")
			_memfree($tmemmap)
		EndIf
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_setitemposition32, $iindex, $ppoint)
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_setitemselected($hwnd, $iindex, $fselected = True, $ffocused = False)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $tstruct = DllStructCreate($taglvitem)
	Local $pitem = DllStructGetPtr($tstruct)
	Local $iresult, $iselected = 0, $ifocused = 0, $isize, $tmemmap, $pmemory
	If ($fselected = True) Then $iselected = $lvis_selected
	If ($ffocused = True AND $iindex <> -1) Then $ifocused = $lvis_focused
	DllStructSetData($tstruct, "Mask", $lvif_state)
	DllStructSetData($tstruct, "Item", $iindex)
	DllStructSetData($tstruct, "State", BitOR($iselected, $ifocused))
	DllStructSetData($tstruct, "StateMask", BitOR($lvis_selected, $ifocused))
	$isize = DllStructGetSize($tstruct)
	If IsHWnd($hwnd) Then
		$pmemory = _meminit($hwnd, $isize, $tmemmap)
		_memwrite($tmemmap, $pitem, $pmemory, $isize)
		$iresult = _sendmessage($hwnd, $lvm_setitemstate, $iindex, $pmemory)
		_memfree($tmemmap)
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_setitemstate, $iindex, $pitem)
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_setitemstate($hwnd, $iindex, $istate, $istatemask)
	Local $titem
	$titem = DllStructCreate($taglvitem)
	DllStructSetData($titem, "Mask", $lvif_state)
	DllStructSetData($titem, "Item", $iindex)
	DllStructSetData($titem, "State", $istate)
	DllStructSetData($titem, "StateMask", $istatemask)
	Return _guictrllistview_setitemex($hwnd, $titem) <> 0
EndFunc

Func _guictrllistview_setitemstateimage($hwnd, $iindex, $iimage)
	Return _guictrllistview_setitemstate($hwnd, $iindex, BitShift($iimage, -12), $lvis_stateimagemask)
EndFunc

Func _guictrllistview_setitemtext($hwnd, $iindex, $stext, $isubitem = 0)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $ibuffer, $pbuffer, $tbuffer, $iitem, $pitem, $titem, $pmemory, $tmemmap, $ptext, $iresult
	Local $i_cols, $a_text, $separatorchar = Opt("GUIDataSeparatorChar")
	Local $funicode = _guictrllistview_getunicodeformat($hwnd)
	If $isubitem = -1 Then
		$i_cols = _guictrllistview_getcolumncount($hwnd)
		$a_text = StringSplit($stext, $separatorchar)
		If $i_cols > $a_text[0] Then $i_cols = $a_text[0]
		For $i = 1 To $i_cols
			$iresult = _guictrllistview_setitemtext($hwnd, $iindex, $a_text[$i], $i - 1)
			If NOT $iresult Then ExitLoop
		Next
		Return $iresult
	EndIf
	$ibuffer = StringLen($stext) + 1
	If $funicode Then
		$ibuffer *= 2
		$tbuffer = DllStructCreate("wchar Text[" & $ibuffer & "]")
	Else
		$tbuffer = DllStructCreate("char Text[" & $ibuffer & "]")
	EndIf
	$pbuffer = DllStructGetPtr($tbuffer)
	$titem = DllStructCreate($taglvitem)
	$pitem = DllStructGetPtr($titem)
	DllStructSetData($tbuffer, "Text", $stext)
	DllStructSetData($titem, "Mask", $lvif_text)
	DllStructSetData($titem, "item", $iindex)
	DllStructSetData($titem, "SubItem", $isubitem)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			DllStructSetData($titem, "Text", $pbuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_setitemw, 0, $pitem, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_setitema, 0, $pitem, 0, "wparam", "ptr")
			EndIf
		Else
			$iitem = DllStructGetSize($titem)
			$pmemory = _meminit($hwnd, $iitem + $ibuffer, $tmemmap)
			$ptext = $pmemory + $iitem
			DllStructSetData($titem, "Text", $ptext)
			_memwrite($tmemmap, $pitem, $pmemory, $iitem)
			_memwrite($tmemmap, $pbuffer, $ptext, $ibuffer)
			If $funicode Then
				$iresult = _sendmessage($hwnd, $lvm_setitemw, 0, $pmemory, 0, "wparam", "ptr")
			Else
				$iresult = _sendmessage($hwnd, $lvm_setitema, 0, $pmemory, 0, "wparam", "ptr")
			EndIf
			_memfree($tmemmap)
		EndIf
	Else
		DllStructSetData($titem, "Text", $pbuffer)
		If $funicode Then
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setitemw, 0, $pitem)
		Else
			$iresult = GUICtrlSendMsg($hwnd, $lvm_setitema, 0, $pitem)
		EndIf
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_setoutlinecolor($hwnd, $icolor)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setoutlinecolor, 0, $icolor)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setoutlinecolor, 0, $icolor)
	EndIf
EndFunc

Func _guictrllistview_setselectedcolumn($hwnd, $icol)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		_sendmessage($hwnd, $lvm_setselectedcolumn, $icol)
		_winapi_invalidaterect($hwnd)
	Else
		GUICtrlSendMsg($hwnd, $lvm_setselectedcolumn, $icol, 0)
		_winapi_invalidaterect(GUICtrlGetHandle($hwnd))
	EndIf
EndFunc

Func _guictrllistview_setselectionmark($hwnd, $iindex)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setselectionmark, 0, $iindex)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setselectionmark, 0, $iindex)
	EndIf
EndFunc

Func _guictrllistview_settextbkcolor($hwnd, $icolor)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_settextbkcolor, 0, $icolor) <> 0
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_settextbkcolor, 0, $icolor) <> 0
	EndIf
EndFunc

Func _guictrllistview_settextcolor($hwnd, $icolor)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $iresult
	If IsHWnd($hwnd) Then
		$iresult = _sendmessage($hwnd, $lvm_settextcolor, 0, $icolor)
		_winapi_invalidaterect($hwnd)
	Else
		$iresult = GUICtrlSendMsg($hwnd, $lvm_settextcolor, 0, $icolor)
		_winapi_invalidaterect(GUICtrlGetHandle($hwnd))
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_settooltips($hwnd, $htooltip)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return HWnd(_sendmessage($hwnd, $lvm_settooltips, 0, $htooltip, 0, "wparam", "hwnd", "hwnd"))
	Else
		Return HWnd(GUICtrlSendMsg($hwnd, $lvm_settooltips, 0, $htooltip))
	EndIf
EndFunc

Func _guictrllistview_setunicodeformat($hwnd, $funicode)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setunicodeformat, $funicode)
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setunicodeformat, $funicode, 0)
	EndIf
EndFunc

Func _guictrllistview_setview($hwnd, $iview)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $aview[5] = [$lv_view_details, $lv_view_icon, $lv_view_list, $lv_view_smallicon, $lv_view_tile]
	If IsHWnd($hwnd) Then
		Return _sendmessage($hwnd, $lvm_setview, $aview[$iview]) <> -1
	Else
		Return GUICtrlSendMsg($hwnd, $lvm_setview, $aview[$iview], 0) <> -1
	EndIf
EndFunc

Func _guictrllistview_setworkareas($hwnd, $ileft, $itop, $iright, $ibottom)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $irect, $prect, $trect, $tmemmap, $pmemory
	$trect = DllStructCreate($tagrect)
	$prect = DllStructGetPtr($trect)
	DllStructSetData($trect, "Left", $ileft)
	DllStructSetData($trect, "Top", $itop)
	DllStructSetData($trect, "Right", $iright)
	DllStructSetData($trect, "Bottom", $ibottom)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			_sendmessage($hwnd, $lvm_setworkareas, 1, $prect, 0, "wparam", "ptr")
		Else
			$irect = DllStructGetSize($trect)
			$pmemory = _meminit($hwnd, $irect, $tmemmap)
			_memwrite($tmemmap, $prect, $pmemory, $irect)
			_sendmessage($hwnd, $lvm_setworkareas, 1, $pmemory, 0, "wparam", "ptr")
			_memfree($tmemmap)
		EndIf
	Else
		GUICtrlSendMsg($hwnd, $lvm_setworkareas, 1, $prect)
	EndIf
EndFunc

Func _guictrllistview_simplesort($hwnd, ByRef $vdescending, $icol)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $x, $y, $z, $b_desc, $columns, $items, $v_item, $temp_item, $ifocused = -1
	Local $separatorchar = Opt("GUIDataSeparatorChar")
	If _guictrllistview_getitemcount($hwnd) Then
		If (IsArray($vdescending)) Then
			$b_desc = $vdescending[$icol]
		Else
			$b_desc = $vdescending
		EndIf
		$columns = _guictrllistview_getcolumncount($hwnd)
		$items = _guictrllistview_getitemcount($hwnd)
		For $x = 1 To $columns
			$temp_item = $temp_item & " " & $separatorchar
		Next
		$temp_item = StringTrimRight($temp_item, 1)
		Local $a_lv[$items][$columns + 1], $i_selected
		$i_selected = StringSplit(_guictrllistview_getselectedindices($hwnd), $separatorchar)
		For $x = 0 To UBound($a_lv) - 1 Step 1
			If $ifocused = -1 Then
				If _guictrllistview_getitemfocused($hwnd, $x) Then $ifocused = $x
			EndIf
			_guictrllistview_setitemselected($hwnd, $x, False)
			For $y = 0 To UBound($a_lv, 2) - 2 Step 1
				$v_item = StringStripWS(_guictrllistview_getitemtext($hwnd, $x, $y), 2)
				If (StringIsFloat($v_item) OR StringIsInt($v_item)) Then
					$a_lv[$x][$y] = Number($v_item)
				Else
					$a_lv[$x][$y] = $v_item
				EndIf
			Next
			$a_lv[$x][$y] = $x
		Next
		_arraysort($a_lv, $b_desc, 0, 0, $icol)
		For $x = 0 To UBound($a_lv) - 1 Step 1
			For $y = 0 To UBound($a_lv, 2) - 2 Step 1
				_guictrllistview_setitemtext($hwnd, $x, $a_lv[$x][$y], $y)
			Next
			For $z = 1 To $i_selected[0]
				If $a_lv[$x][UBound($a_lv, 2) - 1] = $i_selected[$z] Then
					If $a_lv[$x][UBound($a_lv, 2) - 1] = $ifocused Then
						_guictrllistview_setitemselected($hwnd, $x, True, True)
					Else
						_guictrllistview_setitemselected($hwnd, $x, True)
					EndIf
					ExitLoop
				EndIf
			Next
		Next
		If (IsArray($vdescending)) Then
			$vdescending[$icol] = NOT $b_desc
		Else
			$vdescending = NOT $b_desc
		EndIf
	EndIf
EndFunc

Func _guictrllistview_sort($nitem1, $nitem2, $hwnd)
	Local $iindex, $tinfo, $val1, $val2, $nresult
	$tinfo = DllStructCreate($taglvfindinfo)
	DllStructSetData($tinfo, "Flags", $lvfi_param)
	For $x = 1 To $alistviewsortinfo[0][0]
		If $hwnd = $alistviewsortinfo[$x][1] Then
			$iindex = $x
			ExitLoop
		EndIf
	Next
	If $alistviewsortinfo[$iindex][3] = $alistviewsortinfo[$iindex][4] Then
		If NOT $alistviewsortinfo[$iindex][7] Then
			$alistviewsortinfo[$iindex][5] *= -1
			$alistviewsortinfo[$iindex][7] = 1
		EndIf
	Else
		$alistviewsortinfo[$iindex][7] = 1
	EndIf
	$alistviewsortinfo[$iindex][6] = $alistviewsortinfo[$iindex][3]
	DllStructSetData($tinfo, "Param", $nitem1)
	$val1 = _guictrllistview_finditem($hwnd, -1, $tinfo)
	DllStructSetData($tinfo, "Param", $nitem2)
	$val2 = _guictrllistview_finditem($hwnd, -1, $tinfo)
	$val1 = _guictrllistview_getitemtext($hwnd, $val1, $alistviewsortinfo[$iindex][3])
	$val2 = _guictrllistview_getitemtext($hwnd, $val2, $alistviewsortinfo[$iindex][3])
	If $alistviewsortinfo[$iindex][8] Then
		If (StringIsFloat($val1) OR StringIsInt($val1)) Then $val1 = Number($val1)
		If (StringIsFloat($val2) OR StringIsInt($val2)) Then $val2 = Number($val2)
	EndIf
	$nresult = 0
	If $val1 < $val2 Then
		$nresult = -1
	ElseIf $val1 > $val2 Then
		$nresult = 1
	EndIf
	$nresult = $nresult * $alistviewsortinfo[$iindex][5]
	Return $nresult
EndFunc

Func _guictrllistview_sortitems($hwnd, $icol)
	Local $iresult, $iindex, $pfunction, $hheader, $iformat
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	For $x = 1 To $alistviewsortinfo[0][0]
		If $hwnd = $alistviewsortinfo[$x][1] Then
			$iindex = $x
			ExitLoop
		EndIf
	Next
	$pfunction = DllCallbackGetPtr($alistviewsortinfo[$iindex][2])
	$alistviewsortinfo[$iindex][3] = $icol
	$alistviewsortinfo[$iindex][7] = 0
	$alistviewsortinfo[$iindex][4] = $alistviewsortinfo[$iindex][6]
	$iresult = _sendmessage($hwnd, $lvm_sortitems, $hwnd, $pfunction, 0, "hwnd", "ptr")
	If $iresult <> 0 Then
		If $alistviewsortinfo[$iindex][9] Then
			$hheader = $alistviewsortinfo[$iindex][10]
			For $x = 0 To _guictrlheader_getitemcount($hheader) - 1
				$iformat = _guictrlheader_getitemformat($hheader, $x)
				If BitAND($iformat, $hdf_sortdown) Then
					_guictrlheader_setitemformat($hheader, $x, BitXOR($iformat, $hdf_sortdown))
				ElseIf BitAND($iformat, $hdf_sortup) Then
					_guictrlheader_setitemformat($hheader, $x, BitXOR($iformat, $hdf_sortup))
				EndIf
			Next
			$iformat = _guictrlheader_getitemformat($hheader, $icol)
			If $alistviewsortinfo[$iindex][5] = 1 Then
				_guictrlheader_setitemformat($hheader, $icol, BitOR($iformat, $hdf_sortup))
			Else
				_guictrlheader_setitemformat($hheader, $icol, BitOR($iformat, $hdf_sortdown))
			EndIf
		EndIf
	EndIf
	Return $iresult <> 0
EndFunc

Func _guictrllistview_stateimagemasktoindex($imask)
	Return BitShift(BitAND($imask, $lvis_stateimagemask), 12)
EndFunc

Func _guictrllistview_subitemhittest($hwnd, $ix = -1, $iy = -1)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	Local $itest, $ptest, $ttest, $pmemory, $tmemmap, $iflags, $atest[11]
	If $ix = -1 Then $ix = _winapi_getmouseposx(True, $hwnd)
	If $iy = -1 Then $iy = _winapi_getmouseposy(True, $hwnd)
	$ttest = DllStructCreate($taglvhittestinfo)
	$ptest = DllStructGetPtr($ttest)
	DllStructSetData($ttest, "X", $ix)
	DllStructSetData($ttest, "Y", $iy)
	If IsHWnd($hwnd) Then
		If _winapi_inprocess($hwnd, $_lv_ghlastwnd) Then
			_sendmessage($hwnd, $lvm_subitemhittest, 0, $ptest, 0, "wparam", "ptr")
		Else
			$itest = DllStructGetSize($ttest)
			$pmemory = _meminit($hwnd, $itest, $tmemmap)
			_memwrite($tmemmap, $ptest)
			_sendmessage($hwnd, $lvm_subitemhittest, 0, $pmemory, 0, "wparam", "ptr")
			_memread($tmemmap, $pmemory, $ptest, $itest)
			_memfree($tmemmap)
		EndIf
	Else
		GUICtrlSendMsg($hwnd, $lvm_subitemhittest, 0, $ptest)
	EndIf
	$iflags = DllStructGetData($ttest, "Flags")
	$atest[0] = DllStructGetData($ttest, "Item")
	$atest[1] = DllStructGetData($ttest, "SubItem")
	$atest[2] = BitAND($iflags, $lvht_nowhere) <> 0
	$atest[3] = BitAND($iflags, $lvht_onitemicon) <> 0
	$atest[4] = BitAND($iflags, $lvht_onitemlabel) <> 0
	$atest[5] = BitAND($iflags, $lvht_onitemstateicon) <> 0
	$atest[6] = BitAND($iflags, $lvht_onitem) <> 0
	$atest[7] = BitAND($iflags, $lvht_above) <> 0
	$atest[8] = BitAND($iflags, $lvht_below) <> 0
	$atest[9] = BitAND($iflags, $lvht_toleft) <> 0
	$atest[10] = BitAND($iflags, $lvht_toright) <> 0
	Return $atest
EndFunc

Func _guictrllistview_unregistersortcallback($hwnd)
	If $debug_lv Then _guictrllistview_validateclassname($hwnd)
	If NOT IsHWnd($hwnd) Then $hwnd = GUICtrlGetHandle($hwnd)
	For $x = 1 To $alistviewsortinfo[0][0]
		If $hwnd = $alistviewsortinfo[$x][1] Then
			DllCallbackFree($alistviewsortinfo[$x][2])
			_guictrllistview_arraydelete($alistviewsortinfo, $x)
			$alistviewsortinfo[0][0] -= 1
			ExitLoop
		EndIf
	Next
EndFunc

Func _guictrllistview_validateclassname($hwnd)
	_guictrllistview_debugprint("This is for debugging only, set the debug variable to false before submitting")
	_winapi_validateclassname($hwnd, $__listviewconstant_classname)
EndFunc

Global $szdrive, $szdir, $szfname, $szext
Const $gb = 1073741824, $mb = 1048576
$location = FileSelectFolder("Select location to rename folders in...", "", 2)
If $location <> "" Then
	rename_folders($location)
EndIf
Exit

Func rename_folders($location)
	Global $renamelist[1][2]
	recursivefolderscan($location)
	If UBound($renamelist) > 1 Then
		_arraydelete($renamelist, 0)
		For $i = 0 To UBound($renamelist) - 1
			If DirMove($renamelist[$i][0], $renamelist[$i][1]) = 0 Then ConsoleWrite("error")
		Next
	Else
		$renamelist = -1
	EndIf
EndFunc

Func recursivefolderscan($folder)
	If StringRight($folder, 1) <> "\" Then $folder &= "\"
	$search = FileFindFirstFile($folder & "*.*")
	While $search <> -1
		$file = FileFindNextFile($search)
		If @error Then ExitLoop
		$filefullpath = $folder & $file
		If StringInStr(FileGetAttrib($filefullpath), "D") Then recursivefolderscan($filefullpath)
		If StringRegExp($file, "\.mkv$") Then
			If DirGetSize(StringTrimRight($filefullpath, StringLen($file))) < FileGetSize($filefullpath) + 5 * $gb Then
				Dim $parentfolder = "", $labelname = "", $labelyear = "", $labelsize = ""
				$regexresult = StringRegExp($filefullpath, "(.+\\)(.+)\\", 2)
				If NOT @error Then
					$pre = $regexresult[1]
					$parentfolder = $regexresult[2]
				EndIf
				$regexresult = StringRegExp($parentfolder, "(.+?)(\(|$)", 2)
				If NOT @error Then $labelname = $regexresult[1]
				$regexresult = StringRegExp($parentfolder, ".+\(([0-9]{4})\)", 2)
				If NOT @error Then $labelyear = " (" & $regexresult[1] & ")"
				$labelsize = " (" & Round(FileGetSize($filefullpath) / $gb, 2) & "G)"
				$newname = StringReplace($labelname & $labelyear & $labelsize, "  ", " ")
				If $parentfolder <> $newname AND StringLen($newname) > 1 Then
					$index = UBound($renamelist)
					ReDim $renamelist[$index + 1][2]
					$renamelist[$index][0] = $pre & $parentfolder
					$renamelist[$index][1] = $pre & $newname
				EndIf
			EndIf
		EndIf
	WEnd
	FileClose($search)
EndFunc
