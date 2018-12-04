TITLE Not Mario Kart

; Amon R Sthapit , Anna Tran

INCLUDE Irvine32.inc
INCLUDE GraphWin.inc
INCLUDELIB User32.lib

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
	leftleft BYTE "left <.<",0
	rightright BYTE "right >.>",0

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

	ImageName db "spaceship.bmp",0 ;"C:\masm32\BIN\louis.bmp" 
	; http://www.asmcommunity.net/forums/topic/?id=11141

	; Define the Application's Window class structure.
	MainWin WNDCLASS <NULL,WinProc,NULL,NULL,NULL,NULL,NULL, \
		COLOR_WINDOW,NULL,className>

.data?
	hBitmap dd ?


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
	LOCAL hMemDC:DWORD 
	
	mov eax, localMsg
	.IF eax == WM_LBUTTONDOWN		; mouse button?
		;   INVOKE MessageBox, hWnd, ADDR PopupText,
		;     ADDR PopupTitle, MB_OK
		;   jmp WinProcExit
		invoke LoadImage, hInstance,ADDR ImageName,0,100,100,LR_LOADFROMFILE  ;https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-loadimagea
		mov hBitmap,eax 
		invoke InvalidateRect,hWnd,NULL,TRUE 
	.ENDIF
	; GET KEYBOARD INPUT HERE
	.IF eax == WM_KEYDOWN
		.IF wParam == VK_LEFT
			; GO LEFT
			; inc x position of the box
			mov ebx, xloc         
			add ebx, -10
			mov xloc, ebx
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == VK_RIGHT
			; GO RIGHT
			mov ebx, xloc         
			add ebx, 10
			mov xloc, ebx
	  	jmp WinProcExit
		.ENDIF
		.IF wParam == VK_UP
			;GO UP, inc y position of the box
			mov ecx, yloc
	  		add ecx, -20
	  		mov yloc, ecx
		jmp WinProcExit
		.ENDIF
		.IF wParam == VK_DOWN
			;GO DOWN
			mov ecx, yloc
	  		add ecx, 20
	  		mov yloc, ecx
	  	jmp WinProcExit
		.ENDIF
	.ENDIF

	.IF eax == WM_CLOSE		; close window?
	  	INVOKE MessageBox, hWnd, ADDR CloseMsg,
	    	ADDR WindowName, MB_OK
	  	INVOKE PostQuitMessage,0
	  	jmp WinProcExit
	.ELSEIF eax == WM_TIMER     ; did a timer fire?
	  	INVOKE InvalidateRect, hWnd, 0, 1
	  	jmp WinProcExit
	.ENDIF


	.IF eax == WM_PAINT		; window needs redrawing? 
		INVOKE BeginPaint, hWnd, ADDR ps  
	  	mov hdc, eax

		; draw tracks
			INVOKE MoveToEx, hdc, 100, 0, 0
			INVOKE LineTo, hdc, 100, 9999

			INVOKE MoveToEx, hdc, 700, 0, 0
			INVOKE LineTo, hdc, 700, 9999

		;spc
		mov hdc, eax 
		invoke CreateCompatibleDC,hdc 
		mov hMemDC,eax 
		invoke SelectObject, hMemDC,hBitmap 
		invoke GetClientRect,hWnd,addr rc
		invoke BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY 
		invoke DeleteDC,hMemDC 

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

		; x limits
			; reflect xdir
			; Bug in assembler can't use .IF here for some reason...
			cmp xloc, 700
			jl L1
			   mov eax, 700
			   sub eax, 50
			   mov xloc, eax
			L1:

			cmp xloc, 100
			jg L2
			   mov eax,100
			   mov xloc, eax
			L2:

			; reflect ydir    vjhyfguofgvikb
			cmp yloc, 700
			jl L3
			   mov eax, 0
			   sub eax, ydir
			   mov ydir, eax
			L3:

			cmp yloc, 0
			jg L4
			   mov eax, 0
			   sub eax, ydir
			   mov ydir, eax
			L4:

	  	; ; output text
	  	; INVOKE DrawTextA, hdc, ADDR HelloStr, -1, ADDR rc, DTFLAGS 
	  	; INVOKE EndPaint, hWnd, ADDR ps
	  	; jmp WinProcExit
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