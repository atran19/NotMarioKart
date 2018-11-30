TITLE Not Mario Kart

; Amon R Sthapit , Anna Tran

INCLUDE Irvine32.inc
INCLUDE GraphWin.inc

DTFLAGS = 25h  ; Needed for drawtext

;==================== DATA =======================
.data

AppLoadMsgTitle BYTE "Application Loaded",0
AppLoadMsgText  BYTE "This window displays when the WM_CREATE "
	            BYTE "message is received",0

PopupTitle BYTE "Popup Window",0
PopupText  BYTE "This window was activated by a "
	       BYTE "WM_LBUTTONDOWN message",0

GreetTitle BYTE "Main Window Active",0
GreetText  BYTE "This window is shown immediately after "
	       BYTE "CreateWindow and UpdateWindow are called.",0

CloseMsg   BYTE "WM_CLOSE message received",0

HelloStr   BYTE "Hello World",0
rc RECT <0,0,200,200>
ps PAINTSTRUCT <?>
hdc DWORD ?

ErrorTitle  BYTE "Error",0
WindowName  BYTE "ASM Windows App",0
className   BYTE "ASMWin",0

msg	     MSGStruct <>
winRect   RECT <>
hMainWnd  DWORD ?
hInstance DWORD ?

xloc SDWORD 50   ; x location of the box
yloc SDWORD 50   ; y location of the box
xdir SDWORD 3    ; direction of box in x
ydir SDWORD 5    ; direction of box in y

; Define the Application's Window class structure.
MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL, \
	COLOR_WINDOW,NULL,className>



;=================== CODE =========================
.code
main PROC
; Get a handle to the current process.
	INVOKE GetModuleHandle, NULL
	mov hInstance, eax
	mov MainWin.hInstance, eax

; Load the program's icon and cursor.
	INVOKE LoadIcon, NULL, IDI_APPLICATION
	mov MainWin.hIcon, eax
	INVOKE LoadCursor, NULL, IDC_ARROW
	mov MainWin.hCursor, eax

; Register the window class.
	INVOKE RegisterClass, ADDR MainWin
	.IF eax == 0
	  call ErrorHandler
	  jmp Exit_Program
	.ENDIF

; Create the application's main window.
; Returns a handle to the main window in EAX.
	INVOKE CreateWindowEx, 0, ADDR className,
	  ADDR WindowName,MAIN_WINDOW_STYLE,
	  CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,
	  CW_USEDEFAULT,NULL,NULL,hInstance,NULL
	mov hMainWnd,eax

; If CreateWindowEx failed, display a message & exit.
	.IF eax == 0
	  call ErrorHandler
	  jmp  Exit_Program
	.ENDIF

; Display a greeting message.
	INVOKE MessageBox, hMainWnd, ADDR GreetText,
	  ADDR GreetTitle, MB_OK

; Setup a timer
	INVOKE SetTimer, hMainWnd, 0, 30, 0

; Show and draw the window.
	INVOKE ShowWindow, hMainWnd, SW_SHOW
	INVOKE UpdateWindow, hMainWnd

; Begin the program's message-handling loop.
Message_Loop:
	; Get next message from the queue.
	INVOKE GetMessage, ADDR msg, NULL,NULL,NULL

	; GET KEYBOARD INPUT HERE ?

	; Quit if no more messages.
	.IF eax == 0
	  jmp Exit_Program
	.ENDIF

	; Relay the message to the program's WinProc.
	INVOKE DispatchMessage, ADDR msg
    jmp Message_Loop

Exit_Program:
	  INVOKE ExitProcess,0
main ENDP

;-----------------------------------------------------
WinProc PROC,
	hWnd:DWORD, localMsg:DWORD, wParam:DWORD, lParam:DWORD
; The application's message handler, which handles
; application-specific messages. All other messages
; are forwarded to the default Windows message
; handler.
;-----------------------------------------------------
	mov eax, localMsg
	.IF eax == WM_LBUTTONDOWN		; mouse button?
	  INVOKE MessageBox, hWnd, ADDR PopupText,
	    ADDR PopupTitle, MB_OK
	  jmp WinProcExit
	; GET KEYBOARD INPUT HERE ???
	.ELSEIF eax == WM_CREATE		; create window?
	  INVOKE MessageBox, hWnd, ADDR AppLoadMsgText,
	    ADDR AppLoadMsgTitle, MB_OK
	  jmp WinProcExit
	.ELSEIF eax == WM_CLOSE		; close window?
	  INVOKE MessageBox, hWnd, ADDR CloseMsg,
	    ADDR WindowName, MB_OK
	  INVOKE PostQuitMessage,0
	  jmp WinProcExit
	.ELSEIF eax == WM_TIMER     ; did a timer fire?
	  INVOKE InvalidateRect, hWnd, 0, 1
	  jmp WinProcExit
	.ELSEIF eax == WM_PAINT		; window needs redrawing? 
	  INVOKE BeginPaint, hWnd, ADDR ps 
	  mov hdc, eax

	  ; inc x position of the box
	  mov ebx, xloc         
	  add ebx, xdir
	  mov xloc, ebx

	  ; inc y position of the box
	  mov ecx, yloc
	  add ecx, ydir
	  mov yloc, ecx
	  
	  ; draw the box
	  INVOKE MoveToEx, hdc, xloc, yloc, 0
	  mov ebx, xloc
	  add ebx, 50
	  INVOKE LineTo, hdc, ebx, yloc
	  mov ebx, xloc
	  add ebx, 50
	  mov ecx, yloc
	  add ecx, 50	  	  
	  INVOKE LineTo, hdc, ebx, ecx
	  mov ecx, yloc
	  add ecx, 50
	  INVOKE LineTo, hdc, xloc,   ecx
	  INVOKE LineTo, hdc, xloc,   yloc

		; we're not reflecting
			; ; reflect xdir
			; ; Bug in assembler can't use .IF here for some reason...
			; cmp xloc, 200
			; jl L1
			;    mov eax, 0
			;    sub eax, xdir
			;    mov xdir, eax
			; L1:

			; cmp xloc, 0
			; jg L2
			;    mov eax, 0
			;    sub eax, xdir
			;    mov xdir, eax
			; L2:

			; ; reflect ydir
			; cmp yloc, 200
			; jl L3
			;    mov eax, 0
			;    sub eax, ydir
			;    mov ydir, eax
			; L3:

			; cmp yloc, 0
			; jg L4
			;    mov eax, 0
			;    sub eax, ydir
			;    mov ydir, eax
			; L4:

	  ; output text
	  INVOKE DrawTextA, hdc, ADDR HelloStr, -1, ADDR rc, DTFLAGS 
	  INVOKE EndPaint, hWnd, ADDR ps
	  jmp WinProcExit
	.ELSE		; other message?
	  INVOKE DefWindowProc, hWnd, localMsg, wParam, lParam
	  jmp WinProcExit
	.ENDIF

WinProcExit:
	ret
WinProc ENDP

;---------------------------------------------------
ErrorHandler PROC
; Display the appropriate system error message.
;---------------------------------------------------
.data
pErrorMsg  DWORD ?		; ptr to error message
messageID  DWORD ?
.code
	INVOKE GetLastError	; Returns message ID in EAX
	mov messageID,eax

	; Get the corresponding message string.
	INVOKE FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER + \
	  FORMAT_MESSAGE_FROM_SYSTEM,NULL,messageID,NULL,
	  ADDR pErrorMsg,NULL,NULL

	; Display the error message.
	INVOKE MessageBox,NULL, pErrorMsg, ADDR ErrorTitle,
	  MB_ICONERROR+MB_OK

	; Free the error message string.
	INVOKE LocalFree, pErrorMsg
	ret
ErrorHandler ENDP

END