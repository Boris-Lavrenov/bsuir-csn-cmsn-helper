.model tiny
.code
org 100h  

;------------------------START---------------------------------------------------------------	
start:
	jmp main  
	
;-------------------DATA----------------------------------------------------------------
startHour db 0        ;\
startMinutes db 0     ; - ����� ������ ������
startSeconds db 0     ;/

durationHour db 0     ;\                     
durationMinutes db 0  ; - ����������������� ������� 
durationSeconds db 0  ;/                     

stopHour db 0         ;\                     
stopMinutes db 0      ; - ����� ��������� ������ �������
stopSeconds db 0      ;/                     

badCMDArgsMessage db "ERROR! INCORRECT PARAMETERS! (Format: HH MM SS HH MM SS)", '$'   
endProgramMessage db "THE END!", '$'
startProgramMessage db "THE ALARM SET!", '$'

AlarmON db 0

widthOfBanner equ 40
allWidth equ 80  

W equ 2057h
A equ 2041h
Q equ 2051h 
E equ 2045h 

U equ 2055h
P equ 2050h
 
H equ 2048h
O equ 2030h

tchk equ 2021h

green equ 2020h
black equ 0020h 

wakeUpText 	dw widthOfBanner dup(green) 
			dw green, 38 dup(black), green
			dw green, 12 dup(green), W, A, Q, E, green, U, P, green, H, E, O, tchk, tchk ,tchk,  12 dup(green), green 
			dw green, 38 dup(black), green
			dw widthOfBanner dup(green)

offWakeUp	dw widthOfBanner dup(black)
			dw widthOfBanner dup(black)
			dw widthOfBanner dup(black)
			dw widthOfBanner dup(black)
			dw widthOfBanner dup(black)

oldInterruptHandler dd 0  

;-------------------DATA END------------------------------------------------------------

;*******************[PRINT BANNER]***************************** 
;����: SI: �� ��� ���� ����������.
printMatrix PROC
	push es
	push 0B800h             ; � si ��������� �������� ���������� ���������
	pop es

	mov di, 3*allWidth*2 + (allWidth - widthOfBanner)
    
	mov cx, 5
loopPrintMatrix:
	push cx

	mov cx, widthOfBanner
	rep movsw

	add di, 2*(allWidth - widthOfBanner)

	pop cx
	loop loopPrintMatrix

	pop es  
	
	ret
ENDP
;*******************[PRINT BANNER END]*************************  


;**************[����� ���������� ����������]**************************
interruptHandler PROC                             ; ����� ���������� ����������.                                                     
  
startProc:  
    pushf                                         ; ��������� �����.                                                                               
	                                                                                                         
	   
    call cs:oldInterruptHandler                   ; �������� ������ ���������� ����������.                                          
	push    ds          ;\                                                                                                   
    push    es          ; \                                                                                                          
	push    ax          ;  \                                                                                                        
	push    bx          ;   \                                                                                
    push    cx          ;    - ��������� ��������.                                                                                                       
    push    dx          ;   /                                                                                                        
	push    di          ;  /                                                                                                                                                                                                                                       
	push    cs          ; /                                                                                                             
	pop     ds          ;/                                                                               
                                                                                                                                   
	call getTime
    
onClock:                                                 
	cmp ch, startHour                            
	jne offClock                                 
	cmp cl, startMinutes                                                                                                           
	jne offClock                                 ;�������� �� ����������� ��������� ����������.                                    
	cmp dh, startSeconds                         ;���� ������� ����� �� ����� ������� ������������ ���������� - ���������� �������                                                                                 
	jne offClock                                 
	                                                                                                                                                                                                                                                           
	mov dl, AlarmON                              ; ���������� ������� ��������� ����������                                                                                                            
	cmp dl, 0                                                                                                                                                                                            
	jne offClock                                 ; ���� �������� �� ������� - ���������� ��������                                
                                                                                                                        
    call printMsgClock                                                                                                                                                                                                                                                                          
                                                                                                                                    
	jmp exitFromProc                                                                                                                  
                                                 ; �������� �� ����������� ���������� ����������                                
offClock:                                                                                                                         	                                                                                                                                
	cmp ch, stopHour                             ; ���� ������� ����� != ����� ���������� - ���������� ��������                 
	jne exitFromProc                                                                                                                
	cmp cl, stopMinutes                                                                                                             
	jne exitFromProc                                                                                                                 
	cmp dh, stopSeconds                                                                  
	jne exitFromProc                                                                                                                 
 	                                                                                                                                                                                                
	mov dl, AlarmON                              ; ���������� ������� ��������� ����������                                                                                
	cmp dl, 1                                    ; ���� ��������� �� ������� - ����������� ��������                                                                              
	jne exitFromProc                                                    
    
    call printMsgBlack    
                                                                                                      
exitFromProc:                                                                                                                        
    pop     di      ;\                                                                                                               
	pop     dx      ; \                                                                                                              
	pop     cx      ;  \                                                                                     
	pop     bx      ;   - ��������������� ��������                                                                                                            
	pop     ax      ;  /                                                                                                             
	pop     es      ; /                                                                                                              
	pop     ds      ;/
		                                                                                                                   
	iret   
    
ENDP    

getTime PROC
    mov     ah,02h                               ;02H ������ ����� �� ���������� (CMOS) ����� ��������� �������             
	int     1Ah                                  ;�����: CH = ���� � ���� BCD   (������: CX = 1243H = 12:43)                     
                                                 ;CL = ������ � ���� BCD                                                   
                                                 ;DH = ������� � ���� BCD                                                  
                                                 ;CF = 1, ���� ���� �� �������� 
    ret
ENDP
                
;-------����� �� ����� ����������-------------
printMsgClock PROC
	mov si, offset wakeUpText                       ; ��������� � si ����������� ���������                                                              
	call printMatrix                                ; �������� ����� ���������, ������������ � si                                                                                 
	mov dl, 1                                       ; ������������� ��������� ���������� � 1                                        
	mov AlarmON, dl                                 ; ����������� ��������� 
	
	ret
ENDP    

;-------����� �� ����� ������� ��������------
printMsgBlack PROC                                                                                                                                            
	mov si, offset offWakeUp                    ; ������� ��������� ����������                                                      
	call printMatrix                            ; ��������� � si, ���������, ���������� ���������� "Wake Up"                       
	mov dl, 0                                                                                                              
	mov AlarmON, dl                             ; ������������� ��������� ���������� � 0    
	
	ret
ENDP                                                                                                                       
;**************[����� ���������� ���������� �����]********************      
;���������� ������� ������ ���������.  


sizeOfProgram:
;---------------------------------------------------------------------------------------      

;******************[SET NEW HANDLER]***************************
;��������� � AX. ���� ��� ������ - 0, ���� ��� 1
setNewInterrupt PROC
	push bx dx        ;���������.

	cli                ; ��������� ����������    
	
    call getInterrupt       
    call setInterrupt  

	sti              ; ��������� ����������

	mov ax, 0        ;������������ ��������.

	pop dx
	pop bx 
	
	ret
ENDP       
      
;--��������� ������ ����������------------------       
getInterrupt PROC
	mov ah, 35h        ;�������� ����� ����������� ����������.
	mov al, 1Ch        ;����� ����������, 1C - ���������� �������
	int 21h  
	
	mov word ptr [offset oldInterruptHandler], bx      ;��������� �������� �����������.
	mov word ptr [offset oldInterruptHandler + 2], es  ;��������� �������� �����������.

	push ds			;�������������� ������ �������� ES. DS - ����� ����������� ����������. 
	pop es    
	
	ret
ENDP 
       
;--������������� ����� ����������---------------               
setInterrupt PROC  
	
	mov ah, 25h     ;������������� ����� ����������� ����������
	mov al, 1Ch     ;����������� ����������. ���������� 18,2 ���� � ������� ������������ ���������� �������.
	mov dx, offset interruptHandler
	int 21h
	
	ret
	
ENDP
;******************[SET NEW HANDLER END]*********************** 
                                                               
;******************[NEW LINE]**********************************
newline PROC
	push ax
	push dx

	;--����� ����� ������--------------------
	mov dl, 10
	mov ah, 02h
	int 21h

	mov dl, 13
	mov ah, 02h
	int 21h

	pop dx
	pop ax
	ret
ENDP
;******************[NEW LINE END]*******************************

;******************[PRINT]**************************************
println PROC
	push ax
	push dx

	mov ah, 09h
	int 21h

	call newline

	pop dx
	pop ax
	ret
ENDP
;******************[PRINT END]*********************************
   
;******************[PARSE CONCOLE]************************************ 
;��������� � AX. ���� ��� ������ - 0, ���� ��� 1
parseCMD PROC   
    
    push bx             ;\
	push cx             ; \
	push dx             ;  - ��������� �������� ���������.
	push si             ; /
	push di             ;/                            
                                                                                               
	cld                                   ;������� �����.  
    
    call parseFirstArg                                                                
                                                                                               
parseCMDloop:                                                                                  
	mov dl, [si]                                                                               
	inc si                                ;��������� � dl ��������� ������ �� ��������� ������.   
	cmp dl, ' '                           ;��������� �������.                                                     
	je spaceFounded                       ;���� ������, �� ������� � SpaceIsFound             
                                                                                               
	cmp dl, '0'                                                                                
	jl badCMDArgs                         ;��������� �� ������������ ����� (0-9).                                                     
	cmp dl, '9'                                     
	jg badCMDArgs                                                                              
                                                                                               
	sub dl, '0'                                                                                
	mov bl, 10                            ;��������� � �����, �� ��� ���������� � DL.                                                     
	mul bl                                                                                     
	add ax, dx                                                                                 
                                          ;��������� �  ������, ���� >= 60.                       
	cmp ax, 60                                                                                 
	jae badCMDArgs				          ;��������� ������������.                          
	cmp ax, 24                            ;���� ������ 24, ��������� �������� �����.                                                     
	jae checkHour

	loop parseCMDloop

spaceFounded:
	mov byte ptr es:[di], al
	cmp di, offset durationSeconds        ; ���� ��������� ��������� ������� - ����������������� � �������� - ���� ����������.
	je setExitCode

	inc di 
	
	call skipAllSpacesProc
	
	dec si
	inc cx
	    	    
	xor ax, ax

	loop parseCMDloop
	jmp setExitCode

checkHour:
	cmp si, offset startHour              ; ���������, ���� ������� �������� �������� - 
	                                      ; ��� ������ ��� ����������������� � ����� - ���� �����������
	je badCMDArgs
	cmp si, offset durationHour
	je badCMDArgs
	
	loop parseCMDloop
	jmp spaceFounded

badCMDArgs:
	mov dx, offset badCMDArgsMessage
	call println
	mov ax, 1

	jmp endProc

setExitCode:
	mov ax, 0

endProc:
	pop di                 ;\
	pop si                 ; \
	pop dx                 ;  - ;������� �� �����. 
	pop cx                 ; /
	pop bx                 ;/     
	
	ret	
	
ENDP 

;---������� ������� ��������(����)---------------------
parseFirstArg PROC                                      
	mov bx, 80h                         ;�������� �� 80h, �������� � 81h ������              
	mov cl, cs:[bx]                                                         
	xor ch, ch                                                                                 
                                                                                               
	xor dx, dx                                                                                 
	mov di, 81h                                                                                
                                                                                               
    call skipSpacesInBeginning
	                                                                                  
	xor ax, ax                                                                                 
                                        ;������� � ��������� ����.                           
	mov si, di                                                                                 
	mov di, offset startHour   
       
    ret
ENDP

;---������� �������� ����� 0 ���������-------------------
skipSpacesInBeginning PROC
                                                                                                                                                                   
	mov al, ' '                         ;���������� ������� � ������.                          
	repne scasb	                        ;������� �������� � ������. 
	                                    ;���������� ��
	mov al, ' '
	repe scasb
	dec di
	inc cx 
	
	ret
ENDP

;---������� �������� ����� ������� ���������------------
skipAllSpacesProc PROC
	skipAllSpaces: 
	    push bx
	    
	    mov al, ' '
	    mov bl, [si]   
	    inc si
	    dec cx
	    
	    cmp bl, al
	    
	    pop bx
	    je skipAllSpaces
	
	ret
ENDP
;******************[PARSE CONCOLE END]************************* 
     
;******************[CALCULATE]*********************************
calcucateStopTime PROC  
    
    call calculateSeconds
    call calculateMinutes
    call calculateHours     
 
   
   ; ��������� �������� ������� ������/ �����������������/ ��������� ������� � BCD ���
   ; ��� ������������ ���������� �������������� � ��������� �������� ��������� �������
    
    mov cx, 9                     ; ��������� � cx 9, ����� ��������� ��� �����                                                    
	mov bl, 10                    ; �.�. 9 = 3*3 = (���� + ������ + �������) * (����� ������ + ����������������� + ����� ���������)
	mov si, offset startHour      ; =//= � bx 10                                                                                   
                                  ; ������������� si �� startHour, �.� ����� ������ ���������� � �����  

convertLoop:                                                 
	xor ah, ah                    ; �������� ah                                                                                                                             
	mov al, [si]                  ; ��������� ��������� ������                                                                    
	div bl                        ; ����� �� 10. ������� - al, ������� - ah                                                       
                                                                                        
	mov dl, al                    ; ��������� � dl al, �.�.  �������  �� ������� �� 10                                                                                                
                                                                              
	shl dl, 4                     ; ����� ����� �� 4 (���������� ��� BCD �������)                                                                                                      
	add dl, ah                    ; ��������� � dl ah, �.�  ������� �� ������� �� 10                                               
	mov [si], dl                  ; ������������ ������� � si �� ����� � ������� bcd                                               
                                                                              
	inc si                                                                                                                      
	loop convertLoop

	ret  
ENDP   

;--�������---------------------------------
calculateSeconds PROC  

	xor ah, ah
	mov al, startSeconds
	add al, durationSeconds
	mov bl, 60			
	div bl
	
	mov stopSeconds, ah  ;������� ������ � al, ������� � ah. ������� ������� ���������.
	
	ret
	
ENDP

;--������---------------------------------
calculateMinutes PROC  
          
	xor ah, ah
	add al, startMinutes
	add al, durationMinutes
	mov bl, 60			;������������ �������� ����� + 1.
	div bl

	mov stopMinutes, ah ;������� ������ � al, ������� � ah. 
	                    ;������� ������ ���������. ����� ������� � al ����� ���� 1, �� ���� �������.  
          
    ret
	
ENDP  

;--����-----------------------------------
calculateHours PROC  
	xor ah, ah
	add al, startHour
	add al, durationHour
	mov bl, 24			;������������ �������� ����� + 1.
	div bl

	mov stopHour, ah     ;������� ������ � al, ������� � ah. ������� ���� ���������.    
	
	ret
	
ENDP    
;******************[CALCULATE END]*****************************                                                                                                                             
;---------------------------------------------------------------------------------------

;******************[MAIN]**************************************
main:  
    mov ax, 03
    int 10h
    
	call parseCMD
	cmp ax, 0   
	jne endMain				;���� ������ - ��������� ���������.
	
	mov dx, offset startProgramMessage
	call println   
	 	 
	call calcucateStopTime  ;��������� ����� ������ ����������.                         	                        
	call setNewInterrupt 
	
	cmp ax, 0
	jne endMain				;���� ������ - ��������� ���������

	mov ah, 31h             ; ��������� ��������� �����������
	mov al, 0          
	
	mov dx, (sizeOfProgram - start + 100h) / 16 + 1 ; ������� � dx ������ ��������� + PSP,
	                                                ; ����� ��  16, �.�. � dx ���������� ������� ������ � 16 ������� ����������
	int 21h

endMain:    
	ret
;******************[MAIN END]***********************************
end start  

;------------------------START END------------------------------------------------------