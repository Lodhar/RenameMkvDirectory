#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>


$iSize = DirGetSize ( "I:\_MKV\Physician, The (2013)")
ConsoleWrite( "Size: " & Round($iSize / 1024 / 1024 / 1024,2) & "G" & @CRLF )