#region file comments
#cs HEADER:
FILE : 		appbarHelper.au3
VERSION : 	0.2
AUTHOR: 	Darren Allen
EMAIL: 		DarrenAllen85@gmail.com
DESCRIPTION:A set of helper functions to make appbars easy in autoit.
Quality: 	Alpha
Change History
Version 0.1
			Initial Release
Version 0.2
			drag and drop with autodock
			allow/disallow edges to be dockable within drag/drop			
#ce

#cs TODO:
	return co-ordinates of taskbar to caller
	respond to all windows messages.
		fullscreen app
		windows arrange, cascade
		wm_activate
	support all appbar functionallity
		auto hide
		drag drop with autodock - done.
		drag drop with autodock - dont allow dragging from controls that are on the bar.
		when dragging display a rectangle to show where we are dragging to
		ability to set dockable edges 
		custom callbacks on state change
			docking edge changed
			resize
			autohide/autoshow
		always on top
	support dynamic sizing ie drag the edge to make it bigger-smaller
	support multiple appbars per application.
	neaten up code
#ce
#endregion


#region include files
#include <misc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>
#endregion
#region PUBLIC ENUMS
Global Enum $ABE_LEFT = 0,$ABE_TOP ,$ABE_RIGHT ,$ABE_BOTTOM 
Global Enum $DOCKABLE_LEFT = 1,$DOCKABLE_TOP ,$DOCKABLE_RIGHT ,$DOCKABLE_BOTTOM 
#endregion

#region PRIVATE WIN32 enums
Global Enum $RECT_LEFT = 1,$RECT_TOP ,$RECT_RIGHT ,$RECT_BOTTOM 
Global Enum $abDockedTop = 1,$abDockedBottom = 2,$abDockedLeft = 3,$abDockedRight = 4,$abFloating = 5

#cs Description of below params
; These constants are used with the $SHAppBarMessage and
; refer to the $APPBARDATA structure defined below.
;
; Returns the handle of the autohide appbar associated
; with an edge of the $Screen. The return value is NULL
; if an error occurs or if no autohide appbar is
; associated with the given edge. You must specify the
; $cbSize, $HWND, and $uEdge members when sending this message,
; all other members are ignored.
;
global enum $ABM_GETAUTOHIDEBAR = 0x7
;
; Registers a $NEW appbar and specifies the message identifier
; that the system should use to send notification messages to
; the appbar. An appbar should send this message before sending
; any other appbar messages. Returns TRUE if successful or FALSE
; if an error occurs or the appbar is already registered. You
; must specify the $cbSize, $HWND, and $uCallbackMessage members
; when sending this message, all other members are ignored.
;
global enum $ABM_NEW = 0x0
;
; Unregisters an appbar, removing it from the system?s internal
; list. The system no longer sends notification messages to the
; appbar nor prevents other applications from using the $Screen
; area occupied by the appbar. This message causes the system to
; send the ABN_POSCHANGED notification message to all appbars.
; You must specify the $cbSize and $HWND members when sending this
; message, all other members are ignored.
;
global enum $ABM_REMOVE = 0x1
;
; Registers or unregisters an autohide appbar for an edge of the
; $Screen. The system allows only one autohide appbar for each edge
; on a first come, first served basis. Returns TRUE if successful
; or FALSE if an error occurs or an autohide appbar is already
; registered for the given edge. The $lParam parameter is set to
; TRUE to register the appbar or FALSE to unregister it. You must
; specify the $cbSize, $HWND, $uEdge, and $lParam members when sending
; this message, all other members are ignored.
;
global enum $ABM_SETAUTOHIDEBAR = 0x8
;
; Sets the size and $Screen position of an appbar. The message specifies
; a $Screen edge to and the bounding rectangle for the appbar. The system
; may adjust the bounding rectangle so that the appbar does not interfere
; with the Windows taskbar or any other appbars. Always returns TRUE.
; This message causes the system to send the ABN_POSCHANGED notification
; message to all appbars. The $uEdge member specifies a $Screen edge, and the
; $rc member contains the bounding rectangle. When the $SHAppBarMessage
; function returns, $rc contains the approved bounding rectangle. You must
; specify the $cbSize, $HWND, $uEdge, and $rc members when sending this message,
; all other members are ignored.
;
global enum $ABM_SETPOS = 0x3


#ce
global enum  $ABM_NEW = 0x00000000;
global enum  $ABM_REMOVE = 0x00000001;
global enum  $ABM_QUERYPOS = 0x00000002;
global enum  $ABM_SETPOS = 0x00000003;
global enum  $ABM_GETSTATE = 0x00000004;
global enum  $ABM_GETTASKBARPOS = 0x00000005;
global enum  $ABM_ACTIVATE = 0x00000006;
global enum  $ABM_GETAUTOHIDEBAR = 0x00000007;
global enum  $ABM_SETAUTOHIDEBAR = 0x00000008;
global enum  $ABM_WINDOWPOSCHANGED = 0x00000009;

; app bar notifications - 
; these are parameters used when the os calls us back
; with our unique msgid 
global enum $ABN_STATECHANGE=0,$ABN_POSCHANGED,$ABN_FULLSCREENAPP,$ABN_WINDOWARRANGE

#endregion

#region global variables
global $_AppbarCallbackFunc
global $_AppbarIsAppbar=False
global $_AppbarCurrentEdge=$ABE_TOP
global $_AppbarIdealWidth;
global $_AppbarIdealHeight;
global $_AppbarIsDragging=False;
global $_AppbarMouseIsDown=False;
global $_AppbarHwnd
global $_AppbarDragHwnd
global $_AppbarDockableEdges[5]
#endregion


#region PUBLIC Appbar Routines

Func _AppbarNew($title,$callback_func)
	; register the msg id with windows
	local $msgid=_RegisterWindowMessage($callback_func)
	$_AppbarCallbackFunc=$callback_func

	; now register the callbacks
	GUIRegisterMsg($msgid,"_AppbarOnNotify")
	
	; now initialize the appbar
	local $hwnd=_AppbarGUICreate($title)	
	$_AppbarHwnd=$hwnd
	_AppbarRegister($hwnd,$msgid)
	
	GUISetOnEvent($GUI_EVENT_PRIMARYUP,"_AppbarOnMouse",$hwnd)
	GUISetOnEvent($GUI_EVENT_PRIMARYDOWN,"_AppbarOnMouse",$hwnd)
	GUISetOnEvent($GUI_EVENT_MOUSEMOVE,"_AppbarOnMouse",$hwnd)
	GUISetOnEvent($GUI_EVENT_RESIZED,"_AppbarOnMouse",$hwnd)
	
	; mark all edges as dockable
	_AppbarSetDockingEdges()
	
	return $hwnd	
EndFunc

Func _AppbarRemove($hwnd)
	_AppbarUnregister($hwnd);
	GUIDelete($hwnd)
endfunc 

Func _AppbarDock($HWND,$edge,$idealWidth,$idealHeight)
	
	; remember these as the last call params
	$_AppbarIdealHeight=$idealHeight
	$_AppbarIdealWidth=$idealWidth
	$_AppbarCurrentEdge=$edge
	
	local $AppBarData=_AppbarDataAlloc()
	local $left,$top,$right,$bottom

	DllStructSetData($AppBarData,1,DllStructGetSize($AppBarData))
    DllStructSetData($AppBarData,2,$HWND)
    DllStructSetData($AppBarData,4,$edge)

	; setup the proposed size in AppbarData
	if ($edge == $ABE_LEFT or $edge == $ABE_RIGHT) Then
		$top = 0;
		$bottom = @DesktopHeight;
		if ($edge == $ABE_LEFT) then
			$right =$idealWidth;
		else 
			$right = @DesktopWidth;
			$left = $right - $idealWidth;
		EndIf
	else 
		$left = 0;
		$right = @DesktopWidth;
		if ($edge == $ABE_TOP) then
			$bottom = $idealHeight;
		else 
			$bottom = @DesktopHeight;
			$top = $bottom - $idealHeight;
		endif
	EndIf

	local $rect=_RectAlloc()
	_RectSet($rect,$left,$top,$right,$bottom)
	_AppbarDataSetRect($AppbarData,$rect)
	
	; Query the system for an approved size and position. 
	_SHAppBarMessage($ABM_QUERYPOS, $AppbarData); 

	$rect=_AppbarDataGetRect($AppbarData)
	_RectGet($rect,$left,$top,$right,$bottom)
	
	; Adjust the rectangle, depending on the edge to which the 
	; appbar is anchored. 
	switch ($edge) 	 
		case $ABE_LEFT
			$right = $left + $idealWidth;
		case $ABE_RIGHT 
			$left= $right - $idealWidth;
		case $ABE_TOP
			$bottom = $top + $idealHeight;
		case $ABE_BOTTOM
			$top = $bottom - $idealHeight;
	EndSwitch

	; update  $AppbarData with the new co-ordinates
	_RectSet($rect,$left,$top,$right,$bottom)
	_AppbarDataSetRect($AppbarData,$rect)

	; Pass the final bounding rectangle to the system. 
	_SHAppBarMessage($ABM_SETPOS, $AppbarData); 

	;; Move and size the appbar so that it conforms to the 
	; bounding rectangle passed to the system. 
	local $lResult=_MoveWindow($HWND, $left, $top, $right - $left, $bottom - $top, true); 
	Return $lResult
EndFunc

Func _AppbarGetTaskbarPos($hAppbar,byref $left,byref $top,byref $right,byref $bottom)
	#cs structure definition
	;~ 		DWORD cbSize;
	;~     	HWND hWnd;
	;~     	UINT uCallbackMessage;
	;~     	UINT uEdge;
	;~     	RECT rc;
	;~     	LPARAM lParam;
	#ce 
	local $AppBarData=_AppbarDataAlloc()
    DllStructSetData($AppBarData,1,DllStructGetSize($AppBarData))
    DllStructSetData($AppBarData,2,$hAppbar)
	local $lResult = _ShAppBarMessage($ABM_GETTASKBARPOS,$AppBarData)
    If Not @error Then
        If ($lResult[0]) Then
			$left=DllStructGetData($AppBarData,5);
			$top=DllStructGetData($AppBarData,6);
			$right=DllStructGetData($AppBarData,7);
			$bottom=DllStructGetData($AppBarData,8);
		    SetError(0)
			Return 1;
        EndIf
    EndIf
    SetError(1)
    Return -1
EndFunc

Func _AppbarSetDockingEdges($left=true,$right=true,$top=true,$bottom=true)
	$_AppbarDockableEdges[$DOCKABLE_LEFT]=$left
	$_AppbarDockableEdges[$DOCKABLE_TOP]=$top
	$_AppbarDockableEdges[$DOCKABLE_BOTTOM]=$bottom
	$_AppbarDockableEdges[$DOCKABLE_RIGHT]=$right
EndFunc

#endregion


#region PRIVATE Appbar Routines
func _AppbarAutoHideBarGet($edge)
	local $AppBarData = _AppbarDataAlloc();
    DllStructSetData($AppBarData,1,DllStructGetSize($AppBarData))
	;DllStructSetData($AppBarData,2,$HWND)	
	DllStructSetData($AppBarData,4,$edge)		
	local $hwnd=_ShAppBarMessage($ABM_GETAUTOHIDEBAR,$AppBarData)
	return ($hwnd)
EndFunc

func _AppbarAutoHideBarSet($hwnd,$hide)
	local $AppBarData = _AppbarDataAlloc();
    DllStructSetData($AppBarData,1,DllStructGetSize($AppBarData))
	DllStructSetData($AppBarData,2,$HWND)	
	DllStructSetData($AppBarData,4,$_AppbarCurrentEdge)	
	DllStructSetData($AppBarData,9,_iif($hide=True,1,0))
	_ShAppBarMessage($ABM_SETAUTOHIDEBAR,$AppBarData)
EndFunc

func _AppbarOnActivate($hwnd)
	local $AppBarData = _AppbarDataAlloc();
    DllStructSetData($AppBarData,1,DllStructGetSize($AppBarData))
	DllStructSetData($AppBarData,2,$hwnd)	
	_ShAppBarMessage($ABM_ACTIVATE,$AppBarData)
EndFunc

func _AppbarOnNotify($hwnd, $MsgID, $WParam, $LParam)
	;This function handles message notifications from the os to appbar
	if ($_AppbarIsAppbar) Then
		local $msgType=$WParam
		Switch $msgType
			case $ABN_POSCHANGED
				_AppbarDock($hwnd,$_AppbarCurrentEdge,$_AppbarIdealWidth,$_AppbarIdealHeight);
		EndSwitch
		; .. handle msgs here.
		Call($_AppbarCallbackFunc,$hWnd, $MsgID, $WParam, $LParam)
	EndIf
EndFunc


Func _AppbarRegister($HWND,$msgid)
	local $AppBarData = _AppbarDataAlloc();
    DllStructSetData($AppBarData,1,DllStructGetSize($AppBarData))
	DllStructSetData($AppBarData,2,$HWND)	
	DllStructSetData($AppBarData,3,$msgid)	
	; register the appbar
	local $lResult = _SHAppBarMessage($ABM_NEW, $AppBarData);
	If Not @error Then
        If ($lResult[0]) Then		
			;registration worked - we will now be capable of doing a callback
			$_AppbarIsAppbar=True
			return $msgid
		EndIf
	EndIf
	SetError(1);
	return -1
EndFunc

Func _AppbarUnregister($HWND)
	local $AppBarData = _AppbarDataAlloc();
    DllStructSetData($AppBarData,1,DllStructGetSize($AppBarData))
	DllStructSetData($AppBarData,2,$HWND)	
	_SHAppBarMessage($ABM_REMOVE, $AppBarData);
EndFunc

#endregion

#region PRIVATE AppBarData Routines

Func _AppbarDataAlloc()
	#cs structure definition
	;~ 		DWORD cbSize;
	;~     	HWND hWnd;
	;~     	UINT uCallbackMessage;
	;~     	UINT uEdge;
	;~     	RECT rc;
	;~     	LPARAM lParam;
	#ce 
    local $AppBarData = DllStructCreate("dword;int;uint;uint;int;int;int;int;int")
	Return $AppBarData
EndFunc

Func _AppbarDataGetRect($AppBarData)
	local $rect=_RectAlloc();
	for $i=1 to 4
		DllStructSetData($rect,$i,DllStructGetData($AppBarData,4+$i));
	next
	Return $rect
EndFunc

Func _AppbarDataSetRect(byref $AppBarData,$rect)
	local $i;
	for $i=1 to 4
		DllStructSetData($AppBarData,4+$i,DllStructGetData($rect,$i));
	next
EndFunc

#endregion

#region PRIVATE Gui Handling Code
	Func _AppbarGUICreate($title)
		GUICreate($title,0,0,0,0,$WS_POPUPWINDOW)
		return WinGetHandle($title)
	EndFunc
	
	Func _AppbarGetClosestEdge()
		local $pos = MouseGetPos()
		local $x=$pos[0]
		local $y=$pos[1]
		local $left=$x
		local $right=@DesktopWidth-$x
		local $top=$y
		local $bottom=@DesktopHeight-$y
		if ($left<$top and $left < $right and $left < $bottom) Then
			return $ABE_LEFT
		elseif ($right<$top and $right < $left and $right < $bottom) Then
			return $ABE_RIGHT
		elseif ($top<$right and $top < $left and $top < $bottom) Then
			return $ABE_TOP
		else
			return $ABE_BOTTOM
		EndIf
	EndFunc

	Func _AppbarOnMouse()
		Switch @GUI_CTRLID
		case $GUI_EVENT_MOUSEMOVE
			if ($_AppbarMouseIsDown=true) Then
				  $_AppbarIsDragging=True
			endif
		case $GUI_EVENT_PRIMARYDOWN
			$_AppbarMouseIsDown=True
		case $GUI_EVENT_PRIMARYUP
			if ($_AppbarIsDragging) Then				
				local $edge=_AppbarGetClosestEdge()
				if ($_AppbarDockableEdges[$edge+1]) then
					_AppbarDock($_AppbarHwnd,$edge,$_AppbarIdealWidth,$_AppbarIdealHeight);
				Else
					_AppbarDock($_AppbarHwnd,$_AppbarCurrentEdge,$_AppbarIdealWidth,$_AppbarIdealHeight);
				EndIf
				$_AppbarMouseIsDown=False
				$_AppbarIsDragging=False
			EndIf
		case $GUI_EVENT_RESIZED
			
			
	EndSwitch
	EndFunc

	Func _AppbarDrawDragRect()
		
		$_AppbarDragHwnd=GUICreate("drag window");
	EndFunc
	

#endregion

#region PRIVATE RECT handling code
Func _RectAlloc()
	local $rect = DllStructCreate("int;int;int;int")
	return $rect
EndFunc

Func _RectSet(byref $rect,$left,$top,$right,$bottom)
	DllStructSetData($rect,1,$left);
	DllStructSetData($rect,2,$top);
	DllStructSetData($rect,3,$right);
	DllStructSetData($rect,4,$bottom);
	Return $rect
EndFunc

Func _RectGet(ByRef $rect,byref $left,byref $top,byref $right,byref $bottom)
	$left=DllStructGetData($rect,1);
	$top=DllStructGetData($rect,2);
	$right=DllStructGetData($rect,3);
	$bottom=DllStructGetData($rect,4);
	Return
EndFunc

Func _RectGetDimension(ByRef $rect,$side)
	Return DllStructGetData($rect,$side);	 
EndFunc

#endregion


#region PRIVATE Native Code Interfaces
Func _ShAppBarMessage($dwMessage,ByRef $AppBarData)
	local $lResult = DllCall("shell32.dll","int","SHAppBarMessage","int",$dwMessage,"ptr",DllStructGetPtr($AppBarData))
	Return $lResult
EndFunc
Func _RegisterWindowMessage($msg_str)
	local $msgid=DllCall("User32.dll","int","RegisterWindowMessage","str",$msg_str)
	return $msgid
EndFunc

Func _MoveWindow($HWND, $left, $top, $width, $height, $redraw)
	;; Move and size the appbar so that it conforms to the 
	; bounding rectangle passed to the system. 
	;MoveWindow($HWND, $left, $top, $right - $left, $bottom - $top, true); 
	local $lResult = DllCall("user32.dll","int","MoveWindow","hwnd",$HWND,"int",$left,"int", $top,"int", $width, "int",$height,"int", $redraw); 
	Return $lResult
EndFunc

#endregion
