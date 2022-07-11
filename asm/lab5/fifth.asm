.model tiny
.code
org 80h
length_cmd      db ?
line_cmd        db ?
org 100h
    
start:
    mov cl, [length_cmd]
    cmp cl, 1
    jle loop_param

    mov si, 0
    mov di, offset line_cmd

find_param:
    inc di
    mov ax, [di]
    mov ah, 0
    cmp al, ' '
    je next_param
    cmp al, 0Dh
    je too_low
    mov file_name[si], al
    inc si
    jmp find_param

too_low:
    mov ah, 9
    mov dx, offset too_low_str
    int 21h
    ret

next_param:
    mov file_name[si], 0
    mov si, 0

loop_param:
    inc di
    mov ax, [di]
    mov ah, 0
    cmp al, 0Dh
    je end_param
    mov maxnum[si], al
    inc si
    jmp loop_param

end_param:
    mov maxnum[si], '$'
    
    mov maxnumlength, si
    mov si, 0
   
    sub maxnumlength, 1
    mov si, offset maxnum[0]

    cmp maxnumlength, 0
    je skip

str2int:
        mov ax, 0
        cld
        lodsb

        mov bl, 30h
        sub al, bl  ;�������� ������ �� ������

        mov bx, 10
        mov cx, maxnumlength
        power:
            mul bx
            loop power
                                ;�������� ��� � �����
    
        add maxnumber, ax

        sub maxnumlength, 1
        cmp maxnumlength, 0
        jne str2int

        

    skip:
        mov ax, 0
        cld
        lodsb

        mov bl, 30h
        sub al, bl          ;��������� ������ 
        add maxnumber, ax        

    ;�� ����� ������� ��� �������� �������
    ;STR 2 INT END
    
    mov dx, offset file_name
    mov ah, 3Dh
    mov al, 00h
    int 21h
    jc nofile
    jmp open_success

    nofile:
    mov ah, 9
    mov dx, offset cant_opens
    int 21h
    ret

open_success:
    mov [file_descriptor], ax
    mov bx, ax
    mov si, 0
    mov di, 0

    mov ah, 42h
    mov cx, 0
    mov dx, 0 
    mov al, 0
    int 21h

read_buffer:
    mov cx, 1
    mov dx, offset symb
    mov ah, 3Fh
    int 21h

    inc di

    jc close_file
    mov cx, ax
    jcxz close_file

    cmp symb, 0Dh
    cmp symb, 0Ah
    je enter_here
    jmp read_buffer
    enter_here:
        sub di, 2
        mov cx, di
        mov di, 0
        cmp cx, maxnumber
        jng continue
        add count, 1
continue:
    jmp read_buffer
to_exit:
    jmp exit

close_file:
    mov bx, [file_descriptor]
    mov ah, 3Eh
    int 21h

    mov cx, di
    mov di, 0
    cmp cx, maxnumber
    jng exit
    add count, 1

    ;��� ���� ������


exit:
   
countdisplay: ;;142
    mov si, 0
    mov di, 0

    decadecount:
        inc si
        mov cx, si
        mov ax, 1
        mov bx, 10
        lp:
            mul bx
            loop lp

        mov bx, ax
        mov ax, count
        div bx

        cmp ax, 0
        jne decadecount         ;������ � �������� ���������� ��������(�������, �����, ������)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    second:
        dec si                      ;;1
        cmp si, 0
        je finish                   ;;
        
        mov cx, si
        mov ax, 1
        mov bx, 10
        lp1:
            mul bx
            loop lp1
        mov bx, ax
        mov ax, count
        div bx
        
        mov bx, ax      ;;;;bx = 4

        mov cx, si
        mov ax, 1
        mov dx, 10
        lp2:
            mov dx, 10
            mul dx
            loop lp2
        mov dx, bx
        mul dx
        sub count, ax       ;; count = 2
        
        add bx, 30h
        cmp bx, 39h
        jng allisgood
        sub bx, 10
        allisgood:
        mov count_str[di], bl 

        inc di
        jmp second

    finish:
        mov ax, count
        add ax, 30h
        mov count_str[di], al
        inc di
        mov count_str[di], '$'


    mov ah, 9
    mov dx, offset count_str
    int 21h


mov ax, 4C00h
int 21h
ret


    
    cant_open:
    mov ah, 9
    mov dx, offset cant_opens
    int 21h
    ret

    file_name       db 14 dup(0)
    length_line     dw 0
    maxnum          db 16 dup('?')
    count_str       db 16 dup(0)
    maxnumlength    dw ?
    symb            db ?
    cur             dw ?
    maxnumber       dw ?
    file_descriptor dw ?
    count           dw ?
    too_low_str     db "Too low arguments!",0Ah,0Dh,'$'
    cant_opens      db "Cant open file!",0Ah,0Dh,'$'
    calc            db 0

end start
