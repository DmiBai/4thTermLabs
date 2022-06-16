;Запустить. Обязательно продемонстрировать обработку вызова программы, когда она уже до этого загружена в память. Обязательно продемонстрировать возврат всех используемых обработчиков прерываний. Вводить данные через командную строку и показать обработку ошибок при некорректных данных.

;1. Функции 35, 25 и их параметры входные и выходные и их назначение.

;2. Создание резидентной программы. Номер функции и прерывания. Цель создания резидентной программы.

;3. Рассказать, как происходила проверка того, что программа уже является резидентной.

;4. Какие сегменты нужно сохранять, чтобы программа корректно работала в резидентном режиме. С помощью какого механизима получаем доступ к коду, который хранится в резидентной программе.

;Вот и всё. Если человек проходится по всем пунктам, то он сразу сдаёт лабораторную без дополнительных вопросов. Прошу обратить пристальное внимание к описанием параметров. Если человек мне говорит, что в dx помещается имя файла, если мы говорим о функции 4Bh например, то это сразу будет некорректный ответ. Будем отвечать до трёх ошибок(если человек ошибётся три раза на 6-8 лабе, то просто сразу сдаёт следующий), чтобы те люди, которые лучше подготовились и стараются могли сразу закрыть все свои лабораторные, поэтому удачи.


.model tiny
	.386
	locals
	.code
	org 100h
	
start:
	readStringFrom macro pointer ; print string 
		mov ah, 09h
		lea dx, pointer
		int 21h
	endm
	mov ax, 0f100h
	int 2Fh

	cmp al, 0ffh
	je loaded

	jmp setHandler	

	insertMessageInVideoMemory macro message, lenght ; print string with attribute
	mov ax, cs
	mov es, ax
	mov ah, 03h
	mov bh, 0
	int 10h                      ; position of cursor
	
	mov ah, 13h                  ; print string with attribute
	mov al, 00000001b
	mov bh, 0
	mov bl, 07h                  ; attribute
	mov cx, lenght
	lea bp, message
	int 10h

	endm
	
	new2Fh proc
		cmp ah, 0f1h												;check multiplex. int. function number
		jne out_2fh												;not f1h -> out
		cmp al, 00h												;try to repeat installation?
		je inst											;tell it's restricted
    
		jmp short out_2fh										;function is undefined -> out
		inst:  
			mov al, 0ffh								;program is already resident
			iret
		out_2fh:
			jmp dword ptr ds:orig2Fh
			iret 
	new2Fh endp
	
	IRQ0 proc far               ; timer interuption IRQ)))))))))))))))))))))))))))))))))))zaebl teryatsya
	pusha
	push ds
	push es
	
	mov ax, cs
	mov ds, ax
	
	cmp saveFlag, 1
	je saveCMD
	
	cmp returnOldInteruptFlag, 1 ; if 1 -> return old interruption
	je returnInteruptions
	
	jmp IRQ0End
saveCMD:
	mov cs:saveFlag, 0
openFile:
	mov ah, 3dh                  ; open file
	mov al, 00000001b
	lea dx, fileName
	cli                          ; block interruptions
	int 21h
	sti                          ; enable interruptions
	jc fileOpenError
	
	mov fileDescriptor, ax
	jmp grabConsole
	
fileOpenError:                		; file error
	insertMessageInVideoMemory fileOpenErrorString, fileOpenErrorStringLenght
	mov cs:returnOldInteruptFlag, 1 ; set busy-flag
	jmp IRQ0End
	
	
grabConsole:
	mov ax, 0B800h               	; segment-address of video memory
	mov es, ax
	
	mov di, 0
	mov cx, screenHeight         	; height of window
getCLLoop:
	push cx
	lea si, rawBufer
	lea dx, rawBufer
	mov cx, screenWidth          	; Width
getRawLoop:
	; rewriting in file by byte
	mov al, es:[di]
	mov [si], al
	inc si
	add di, 2
	loop getRawLoop
	mov ah, 40h                  ; Write in file
	mov bx, fileDescriptor
	mov cx, screenWidth
	inc cx
	lea dx, rawBufer
	int 21h
	
	pop cx
	loop getCLLoop
	
closeFile:
	mov ah, 3Eh
	mov bx, fileDescriptor
	cli
	int 21h
	sti
	
	insertMessageInVideoMemory grabString, grabStringLenght
	
	jmp IRQ0End
	
returnInteruptions:           			; setting old interrupt addresses
installOldInteruptionsAddressed:
	mov ah, 25h
	mov al, 08h                  		; IRQ0
	mov dx, word ptr cs:originalIRQ0
	mov ds, word ptr cs:originalIRQ0 + 2
	int 21h                      		; set old interrupt addresses
	
	mov ah, 25h
	mov al, 09h                  		; IRQ1
	mov dx, word ptr cs:originalIRQ1
	mov ds, word ptr cs:originalIRQ1 + 2 	; set old interrupt addresses
	int 21h

	mov ah, 25h
	mov al, 2Fh                  		; IRQ1
	mov dx, word ptr cs:originalIRQ1
	mov ds, word ptr cs:originalIRQ1 + 2 	; set old interrupt addresses
	int 21h

printInteruptionMessage:
	insertMessageInVideoMemory interuptionsReturnString, interuptionsReturnStringLenght
IRQ0End:
	pushf
	call cs:dword ptr originalIRQ0 		; call old handler
	pop es
	pop ds
	popa
	iret
	IRQ0 endp
	
	IRQ1 proc far					; keyboard interuption )))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
	pusha
	pushf
	call cs:dword ptr originalIRQ1		; call old handler
	cli
	mov ah, 01h
	int 16h                      	; wait for input
	sti
	jz IRQ1end                   	; if nothing
	
	mov dh, ah                   	; save scan-code
	
	mov ah, 02h
	int 16h
	and al, 4                    	; check for CTRL
	cmp al, 0
	jne checkExecuteKey
	jmp IRQ1end                  	; if not CTRL
	
checkExecuteKey:
	cmp dh, cs:keyCode            		; if scan code is Q
	jne checkQ
	
	mov cs:saveFlag, 1
	mov ah, 00h
	int 16h
	
	jmp IRQ1end
	
checkQ:
	cmp dh, 10h                  	; if Q is pressed, shut down our programm
	jne IRQ1end
mov cs:returnOldInteruptFlag, 1 	; flag of busy set in 1
	
	mov ah, 00h
	int 16h
IRQ1end:
	popa
	iret
	IRQ1 endp
	
	
setHandler:
getCommandLineParameters:
	mov ch, 0
	mov cl, es:[80h]              ; size of command line
	
	cmp cl, 1
	jbe noParamError
	
	mov si, 81h                  ; parameters start on space
	lea di, fileName
getInfoLoop:
spaceCheck:                   	 ; find space
	mov bl, es:[si]
	cmp bl, ' '
	je spaceFound                ; find
	movsb
	jmp endGetInfoLoop
spaceFound:                   	 ; skip space
	inc si
	
endGetInfoLoop:
	loop getInfoLoop
	
createFile:
	mov ah, 3Ch                  ; create file
	mov cx, 00000000b
	lea dx, fileName             ; name
	int 21h
	
	jc cantCreateFile            ; check for creating
	mov fileDescriptor, ax
	
closeNewFile:
	mov ah, 3Eh                  ; close file 
	mov bx, fileDescriptor       ; file descriptor
	int 21h
	
	readStringFrom pressKeyString
	
getExecuteKeyCode:
	mov ah, 00h                  ; waiting for keyboard input
	int 16h						 ; ah - scan code, al - symba
	
	cmp ah, 10h                  ; if Q pressed
	je Qpressed
	jmp gotKey
	
Qpressed:
	readStringFrom QKeyPressedString 	; print message
	jmp setHandler           		; and waiting for input again
	
gotKey:
	mov keyCode, ah              		; save scan-code of key
	readStringFrom keyPressedString
	
	
getOriginalInterruptionsAddresses: 		; get address of original interrupt-handler
	mov ah, 35h           
	mov al, 09h                  		; IRQ1
	int 21h
	mov word ptr originalIRQ1, bx 		; offset of handler
	mov word ptr originalIRQ1 + 2, es 	; segment of handler
	
	mov ah, 35h              
	mov al, 08h							; IRQ0
	int 21h
	mov word ptr originalIRQ0, bx 
	mov word ptr originalIRQ0 + 2, es

	mov ah, 35h              
	mov al, 2Fh							; IRQ0
	int 21h
	mov word ptr orig2Fh, bx 
	mov word ptr orig2Fh + 2, es
	
setOwnInterruptions:
	mov ah, 25h                  					; set address of interruption handler
	mov al, 09h                  					; IRQ1 interruption number
	mov dx, offset IRQ1          					; offset of handler in segment
	int 21h
	
	mov ah, 25h                  					; the same for IRQ0
	mov al, 08h
	mov dx, offset IRQ0			
	int 21h

	mov ah, 25h                  					; the same for IRQ0
	mov al, 2Fh
	mov dx, offset new2Fh			
	int 21h

stayResident:
	mov ah, 31h                  					; stay programm resident
																																													;mov dx, (setHandler - start + 16Fh) / 16 	; size of resident programm in 16-byte paragraph
	mov dx, offset setHandler
	int 21h
	
noParamError:                 						; error message
	readStringFrom cmdError
	jmp setHandlerEnd
cantCreateFile:
	readStringFrom fileCreationError
	jmp setHandlerEnd
loaded:
	readStringFrom programAlreadyInMemoryString
	
setHandlerEnd:
	mov ax, 4C00h
    int 21h
	; / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /

	;DATA
	flag db "Grabber"

	;interuptions
	returnOldInteruptFlag db 0
	originalIRQ0 dd ?
	originalIRQ1 dd ?
	orig2Fh dd ?

	keyCode db 0
	saveFlag db 0
	screenWidth equ 80
	rawBufer db screenWidth dup (?)
	superThing db 0Ah
	screenHeight equ 25
	
	fileName db 125 dup (?),0
	fileDescriptor dw ?
	
	cmdError db "cmd params error. format : executable name file name", 0Dh, 0Ah, '$'
	
	fileCreationError db "file wasnt created.", 0Dh, 0Ah, '$'
	
	pressKeyString db "press the key (not 'Q').", 0Dh, 0Ah, '$'
	keyPressedString db "ctrl + entered key to grab.", 0Dh, 0Ah, "ctrl + 'Q' quit resident program.", 0Dh, 0Ah, '$'
	QKeyPressedString db "'Q' is reserved for exiting the program.", 0Dh, 0Ah, '$'
	
	programAlreadyInMemoryString db "program is already in memory.", 0Dh, 0Ah, '$'
	interuptionsReturnStringLenght equ 49
	interuptionsReturnString db 0Dh, 0Ah, "original interruptions returned successfully.", 0Dh, 0Ah, '$'
	
	fileOpenErrorStringLenght equ 27
	fileOpenErrorString db 0Dh, 0Ah, "error in save proccess!", 0Dh, 0Ah
	
	grabStringLenght equ 9
	grabString db 0Dh, 0Ah, "grab!", 0Dh, 0Ah
	; / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / 
	end start
