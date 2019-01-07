#pragma compile(Out, MkvRenameDirectory.exe)
; Uncomment to use the following icon. Make sure the file path is correct and matches the installation of your AutoIt install path.
#pragma compile(Icon,"C:\Users\Lodhar\Documents\_workspace\Ico\maker-movie-fenetres-icone-9140.ico")
;~ #pragma compile(ExecLevel, highestavailable)
#pragma compile(Compatibility, win7)
;~ #pragma compile(UPX, False)
;~ #pragma compile(FileDescription, myProg - a description of the application)
#pragma compile(ProductName, MKV Rename Directory)
#pragma compile(ProductVersion, 1.0)
#pragma compile(FileVersion, 0.9) ; The last parameter is optional.
#pragma compile(LegalCopyright, © Lodhar)
#pragma compile(LegalTrademarks, 'GPL License')
#pragma compile(CompanyName, 'Bad Company')

#include <Array.au3> ; Only required to display the arrays
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <String.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include <TreeViewConstants.au3>
#include <GuiListView.au3>
#include <ListViewConstants.au3>
#include <Debug.au3>

_DebugSetup("Renaming MKV directory", True,4,'log.txt',True)

;~ @ProgramFilesDir Path to Program Files folder
;~ @FavoritesCommonDir Path to Favorites
;~ @FavoritesDir Path to current user's Favorites
;~ @ScriptFullPath Equivalent to @ScriptDir & "\" & @ScriptName
;~ @ScriptDir Directory containing the running script. Only includes a trailing backslash when the script is located in the root of a drive.
Global $folder
$folder = SelectFolder()
;~ ConsoleWrite($folder & @CRLF)
while 1
   GetFilesAndFolders($folder)
WEnd


Func GetFilesAndFolders($filePath)

   $include = "*.part1.rar;*.part01.rar"
   $exclude = ""
   $Exclude_Folders = "_Séries;_VU;Beeg.com;"
;~    $Exclude_Folders = "_*"

;~    Local $aArray = _FileListToArrayRec($filePath, $include & "|" & $exclude & "|" & $Exclude_Folders, $FLTAR_FOLDERS , $FLTAR_RECUR, $FLTAR_SORT, $FLTAR_RELPATH )
;~    Local $aArray = _FileListToArrayRec($filePath, "*", $FLTAR_FOLDERS , $FLTAR_RECUR, $FLTAR_SORT, $FLTAR_RELPATH )
;~    $filePath = "f:\_mkv"
;~    ConsoleWrite($filePath & @CRLF)
   Local $aArray = _FileListToArrayRec($filePath, "*.mkv", $FLTAR_FILES , $FLTAR_RECUR , $FLTAR_SORT, $FLTAR_FULLPATH  ) ; Get MKV files

   Local $sDrive = "", $sDir = "", $sFilename = "", $sExtension = ""
   Local $arrayResult[0]
   For $i = 0 To UBound ($aArray) - 1 ; get rid of everything exept the directory
	  Local $aPathSplit = _PathSplit($aArray[$i], $sDrive, $sDir, $sFilename, $sExtension)
;~ 	  ConsoleWrite($sDrive & $sDir & @CRLF)
	  $split = StringReplace(StringReplace($sDrive & $sDir,$filePath & "\",""),"\",""); enlève le path en début et le \ en fin de répertoire
;~ 	  ConsoleWrite($split & @CRLF)
	  _ArrayAdd($arrayResult, $split )
;~ 	  _ArrayAdd($arrayResult, $sDir)
   Next

   Local $aArray = _ArrayUnique($arrayResult) ; enlève les doublons
   _ArrayDelete($aArray, 0) ; enlève le count
   Local $iIndex = _ArraySearch($aArray, "")
   ($iIndex=-1) ? "" : _ArrayDelete($aArray, $iIndex); enlève les éléments vide
;~    Local $iIndex = _ArraySearch($aArray, $filePath & "\")
;~    ($iIndex=-1) ? "" : _ArrayDelete($aArray, $iIndex) ; enlève le path
;~    $aSplit = StringSplit(,"\")
;~    _ArrayDisplay($aArray, "Sorted tree", Default, 32, Default, "Title", Default, "0xF0F0F0", Default)




   Dim $resultArray[0]
   For $vElement In $aArray

	  $result = StringRegExpReplace($vElement,'(\.)',' ') ; Replace punt by space
	  $result = StringRegExpReplace($result,'(19\d{2}|20\d{2})','($1)') ; Put the date in ()
	  $result = StringRegExpReplace($result,'(\(\()','(') ; kill the double (
	  $result = StringRegExpReplace($result,'(\)\))',')') ; kill the double )
	  $result = StringRegExpReplace($result,'((\(19\d{2}\)|\(20\d{2}\)))((.*){1,})','$1') ; take everything after the date and erase it
	  $result = StringRegExpReplace($result,'(\A(The ))((.*){1,})((\(19\d{2}\)|\(20\d{2}\)))','$3, $2$5') ; Take care of the 'The'
	  $result = StringRegExpReplace($result,'( ,)',',') ; Kill the space before the ,
	  $result = StringRegExpReplace($result,'  ',' ') ; Replace double space by one space
;~ 	  (@error) ?  ConsoleWrite("Error:" & @error & @CRLF) : ConsoleWrite("Ok:" & @error & @CRLF)
;~ 	  errorDisplay()
;~ 	  $result = StringRegExpReplace($result,'(\(19\d{2}\)|\(20\d{2}\))','$1')
;~ 	  $result = StringRegExp($result,"19\d{2}|20\d{2}",2)
;~ 	  For $i = 0 To UBound($result) - 1
;~ 		 ConsoleWrite("Result: " & $result & @CRLF)
		 _ArrayAdd($resultArray,$result)
;~ 		 MsgBox($MB_SYSTEMMODAL, "RegExp Test with Option 2 - " & $i, $aArray[$i])

   Next

   ViewList($aArray,$resultArray)

EndFunc


Func ViewList($aArray,$resultArray)
   Opt("GUICoordMode", 1) ;1=absolute, 0=relative, 2=cell
    ; Create a GUI with various controls.
;~     Local $hGUI = GUICreate("Example",700,500,Default,Default,BitOR( $WS_SIZEBOX,$WS_SYSMENU ))
   Local $hGUI = GUICreate("Rename My Movies",700,500,Default,Default,Default)
   Local $idOK = GUICtrlCreateButton("OK", 5, 470, 85, 25)
   Local $idInfo = GUICtrlCreateButton("&Info", 100, 470, 85, 25)
   Local $idRefresh = GUICtrlCreateButton("&Refresh", 195, 470, 85, 25)
   Local $idExit = GUICtrlCreateButton("&Exit", 290, 470, 85, 25)
   GUICtrlCreateGroup("File to rename", 20, 420, 250, 40)
   Local $idRadio1 = GUICtrlCreateRadio("Checked", 40, 435, 80, 20)
   Local $idRadio2 = GUICtrlCreateRadio("Not checked", 140, 435, 100, 20)
   GUICtrlCreateGroup("", -99, -99, 1, 1) ;close group
   GUICtrlSetState($idRadio1, $GUI_CHECKED)

   Dim $idCheckbox[0]

	  $left = 6;
	  $top = 6;
;~ 	  For $vElement In $aArray

   Local $idListview = GUICtrlCreateListView("", 10, 10,650,400) ;,$LVS_SORTDESCENDING)
   _GUICtrlListView_SetExtendedListViewStyle($idListview, Default,BitOR($LVS_EX_FULLROWSELECT,$LVS_EX_GRIDLINES,$LVS_EX_HEADERDRAGDROP,$LVS_EX_CHECKBOXES))
   _GUICtrlListView_AddColumn($idListview, "Directory", 350)
   _GUICtrlListView_AddColumn($idListview, "To rename", 200)

      For $i = 0 To UBound ($aArray) - 1
		 _GUICtrlListView_AddItem($idListview, $aArray[$i])
		 _GUICtrlListView_AddSubItem($idListview, $i, $resultArray[$i], 1, 1)

;~ 		$result = GUICtrlCreateCheckbox($aArray[$i], $left, $top )
;~ 	    _ArrayAdd($idCheckbox,$result)
;~ 		errorDisplay()
		$top = $top+18
	  Next
;~ 	 GUICtrlSetState(-1, $GUI_CHECKED)

    ; Display the GUI.
    GUISetState(@SW_SHOW, $hGUI)

    ; Loop until the user exits.
    While 1
        $idMsg = GUIGetMsg()
        Select
		Case $idMsg = $GUI_EVENT_CLOSE Or $idMsg = $idExit
		   GUIDelete()
		   Exit
		Case $idMsg = $idRefresh
		   GUIDelete()
		   Return $hGUI
		Case $idMsg = $idOK
		    $whatToRename = True
			   If (BitAND(GUICtrlRead($idRadio1), $GUI_CHECKED) = $GUI_CHECKED) Then
				  $whatToRename = True
			   EndIf
			   If (BitAND(GUICtrlRead($idRadio2), $GUI_CHECKED) = $GUI_CHECKED) Then
				  $whatToRename = False
			   EndIf
		    For $i = 0 To _GUICtrlListView_GetItemCount($idListview) - 1
;~ 					 ConsoleWrite("Info" & $i & ": " & _GUICtrlListView_GetItemChecked($idListview, $i) & @CRLF)
               If  _GUICtrlListView_GetItemChecked($idListview, $i) = $whatToRename Then
				  DirMove($folder & "\" & $aArray[$i],$folder & "\" & $resultArray[$i])
				  (@error) ? ConsoleWrite("Error:" & @error & "-" & $aArray[$i] & @CRLF) : ConsoleWrite(@error &"-" &" Directory renamed in " & $resultArray[$i] & @CRLF)
               Else

               EndIf
			Next


		 Case $idMsg = $idInfo
;~ 				_GUICtrlListView_GetItemChecked($idListview, 1)
			   ConsoleWrite("" & @CRLF)
			   ConsoleWrite("---------------------------------------------------" & @CRLF)
			   ConsoleWrite("Info List" & @CRLF)
			   ConsoleWrite("---------------------------------------------------" & @CRLF)
			   $whatToRename = True
			   If (BitAND(GUICtrlRead($idRadio1), $GUI_CHECKED) = $GUI_CHECKED) Then
				  ConsoleWrite('Radio 1 is Checked.' & @CRLF)
				  $whatToRename = True
			   EndIf
			   If (BitAND(GUICtrlRead($idRadio2), $GUI_CHECKED) = $GUI_CHECKED) Then
				  ConsoleWrite('Radio 2 is Checked.' & @CRLF)
				  $whatToRename = False
			   EndIf

			   For $i = 0 To _GUICtrlListView_GetItemCount($idListview) - 1
;~ 					 ConsoleWrite("Info" & $i & ": " & _GUICtrlListView_GetItemChecked($idListview, $i) & @CRLF)
                   If  _GUICtrlListView_GetItemChecked($idListview, $i) = $whatToRename Then
                        ConsoleWrite($aArray[$i] &" will be renamed in " & $resultArray[$i] & @CRLF)
                   Else

                   EndIf
			   Next


         EndSelect
    WEnd

    ; Delete the previous GUI and all controls.
    GUIDelete($hGUI)
EndFunc   ;==>Example


Func SelectFolder()
    ; Create a constant variable in Local scope of the message to display in FileSelectFolder.
    Local Const $sMessage = "Select a folder"


   Local $sFileSelectFolder = FileSelectFolder($sMessage, @WorkingDir, Default, @WorkingDir)


    If @error Then
        ; Display the error message.
;~         MsgBox($MB_SYSTEMMODAL, "", )
		ConsoleWrite("ERROR: " & @error & " - " & "No folder was selected." & @CRLF)
		Exit
    Else
        ; Display the selected folder.
;~         MsgBox($MB_SYSTEMMODAL, "", "You chose the following folder:" & @CRLF & $sFileSelectFolder)
		ConsoleWrite("SUCCES: " & "You chose the following folder:" & $sFileSelectFolder & @CRLF)
	 EndIf
	 Return $sFileSelectFolder
  EndFunc   ;==>Example

Func errorDisplay()
;~    (@error) ?  ConsoleWrite("Error:" & @error & @CRLF) : ConsoleWrite("Ok:" & @error & @CRLF)
   If @error Then
	  ConsoleWrite("Error:" & @error & @CRLF)
   Else
	  ConsoleWrite("Ok:" & @error & @CRLF)
   EndIf
EndFunc
