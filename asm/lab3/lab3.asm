.model small
.stack 100h

.data
buf db 7 dup ('$') 

message_enter db "Enter two nums", 0Dh,0Ah,'$'
message_entered_matrix db 0Dh,0Ah,"Entered nums:",0Dh,0Ah,'$'
message_wrong db 0Dh,0Ah,"Wrong input",0Dh,0Ah,'$'
message_final_matrix db 0Dh, 0Ah, "Sum of two numbers", 0Dh,0Ah,'$'            
subOfTwoNumbers db 0Dh, 0Ah, "Sub of two numbers", 0Dh,0Ah,'$' 
mulOfTwoNumbers db 0Dh, 0Ah, "Multiplication of two numbers", 0Dh,0Ah,'$'
divOfTwoNumbers db 0Dh, 0Ah, "Division of two numbers", 0Dh,0Ah,'$'   
andOfTwoNumbers db 0Dh, 0Ah, "Logical AND of two numbers", 0Dh,0Ah,'$'
orOfTwoNumbers  db 0Dh, 0Ah, "Logical OR of two numbers", 0Dh,0Ah,'$'  
xorOfTwoNumbers db 0Dh, 0Ah, "Logical XOR of two numbers", 0Dh,0Ah,'$'
notOfTwoNumbers db 0Dh, 0Ah, "Logical NOT of the first number", 0Dh,0Ah,'$'
input dw 2 dup ('$')
ANSWER dw 9 dup ('$') 
endl db 0Dh,0Ah,'$'  
OVERFLOW_str db 0Dh, 0Ah, "Overflow!", 0Dh, 0Ah, '$'
message_no_divide_at_null db 0Dh, 0Ah, "Say no divide at null!", 0Dh, 0Ah, '$'
negtrig1 db 0 
negtrig2 db 5


.code
start:
mov AX, @data
mov DS, AX

print_str macro out_str
    mov AH, 9h
    mov DX, offset out_str
    int 21h
endm

print_str message_enter

xor CX,CX
xor DX,DX
mov CX,2                    

enter_numbers:
    push CX
    push DX
    mov SI, offset buf
    mov CX, 6
    mov BX, SI              ;bx is at the beginning of the line

enter_string:
    mov AH,1h
    int 21h
    mov [SI],AL
    mov AH,0Dh
    cmp AL,AH
    JE part_1
    inc SI
loop enter_string


part_1:

    mov WORD PTR[SI],24h
    print_str endl

    mov SI,BX ;si at the beginning of the line
    xor BX,BX
    xor CX,CX
    xor DX,DX
    xor AX,AX
    xor DI,DI

    cmp BYTE PTR[SI], '-'
    JNE convert
    mov DI,1 ;if number is <0
    inc SI

convert:
    mov CX,10
    call convert_string_to_number

    cmp DI,1
    JNE part_2
    neg AX 
    JMP part_2

part_2:
    pop CX                              ; DX moves to CX
    mov SI,offset input
    mov DX,CX
    cmp CX,0
    JE write_number_into_matrix 
    
skip_occupied_positions:
    add SI, 2
loop skip_occupied_positions

write_number_into_matrix:
    inc DX                              ;position occupied
    mov [SI],AX
    pop CX
    loop enter_numbers  
    
;OUTPUT MATRIX

print_str message_entered_matrix

    xor DX,DX
    xor DI,DI
    xor CX,CX
    mov CX,2 

convert_number_to_string:
    push CX
    xor CX,CX
    mov SI,offset input
    mov CX,DI
    cmp CX,0
    JE output_part_2 
    
skip_occupied_positions_for_output:
   add SI, 2
loop skip_occupied_positions_for_output

output_part_2:
    inc DI
    xor AX,AX
    mov BX,10

    xor CX,CX
    call number_to_string_procedure
    pop CX
    loop convert_number_to_string

    xor DX,DX
    xor DI,DI

    xor CX,CX
    xor AX,AX
    mov SI,offset input
   ; mov DI,offset sum   
    
    ;MAIN PROGRAM
    
    mov SI, offset input    

    mov CX, 2
    xor AX, AX
    
arraySum:  
   add AX, [SI]  
   JNO not_overflow
   JMP overflow
   not_overflow:
   add SI, 2
   loop arraySum  
   
writeSumIntoVariable:
   mov SI, offset ANSWER
   mov [SI], AX 
      
mov SI, offset input
xor CX,CX
xor AX,AX
mov CX, 2
   
arraySub:
    add AX, [SI]
    add SI, 2
    sub AX, [SI]  
    JNO writeSubIntoVariable
    JMP overflow
    
writeSubIntoVariable:
   mov SI, offset ANSWER
   add SI, 2
   mov [SI], AX 
      
mov SI, offset input
xor CX,CX
xor AX,AX
mov CX, 2

arrayMul:
    add AX, [SI]
    add SI, 2 
    mov BX, [SI]
    imul BX
    JNO writeMulIntoVariable
    JMP overflow
        
writeMulIntoVariable:
   mov SI, offset ANSWER
   add SI, 4
   mov [SI], AX    
   
mov SI, offset input
xor CX,CX
xor AX,AX
mov CX, 2

arrayDiv:
    xor DI, DI
    add AX, [SI]
    add SI, 2
    
    mov BX, [SI]
    cmp BX, 0
    JE noNullDiv

    cmp BX, 0
    JL bxisneg
    jmp letsDivide

    bxisneg:
    neg AX
    neg BX
    jmp letsDivide

    letsDivide:
    idiv BX ;ax div bx
    JMP writeDivIntoVariable

    minusone:
    neg ax
    xor DX, DX
    xor DI, DI
    JMP writeDivIntoVariable
    
    noNullDiv:

    mov ax, 0
    mov dx, 0
    jmp nullDivide

writeDivIntoVariable:
   mov SI, offset ANSWER
   add SI, 6
   mov [SI], AX 
   inc SI
     
backfromnull:

mov SI, offset input
xor CX,CX
xor AX,AX
mov CX, 2   

cmp BX, 0
JE writeDoubleIntoVariable

arrayDouble:
    add SI, 2
    xor AX,AX
    mov AX,DX
    xor BX,BX
    mov BX, 1000
    mul BX
    xor BX, BX
    mov BX, [SI]
    div BX
    
        
writeDoubleIntoVariable:
   mov SI, offset ANSWER
   add SI, 8
   mov [SI], AX 
   inc SI
     
     
mov SI, offset input
xor CX,CX
xor AX,AX
mov CX, 2

arrayAND:
    add AX, [SI]
    add SI, 2
    mov BX, [SI]
    AND AX,BX
    ;add AX, 65280
        
writeANDIntoVariable:
   mov SI, offset ANSWER
   add SI, 10
   mov [SI], AX 
   
mov SI, offset input
xor CX,CX
xor AX,AX
mov CX, 2

arrayOR:
    add AX, [SI]
    add SI, 2
    mov BX, [SI]
    OR AX,BX
    ;add AX, 65280
        
writeORIntoVariable:
   mov SI, offset ANSWER
   add SI, 12
   mov [SI], AX 
   
mov SI, offset input
xor CX,CX
xor AX,AX
mov CX, 2

arrayXOR:
    add AX, [SI]
    add SI, 2
    mov BX, [SI]
    XOR AX,BX
    ;add AX, 65280
        
writeXORIntoVariable:
   mov SI, offset ANSWER
   add SI, 14
   mov [SI], AX 
   
mov SI, offset input
xor CX,CX
xor AX,AX
mov CX, 2

arrayNOT:

    add AX, [SI] 
    sub AX, 1
    NOT AX
    
    ;add AX, 65280
        
writeNOTIntoVariable:
   mov SI, offset ANSWER
   add SI, 16
   mov [SI], AX
 

   
end_of_sort:    
    ;END OF MAIN PROGRAM  
    
    ;OUTPUT FINAL MATRIX
    ;print_str message_final_matrix

    xor DX,DX
    xor DI,DI
    xor CX,CX
    mov CX, 9 

convert_number_to_string_2:
    push CX  
    cmp CX, 9
    JNE sumBack
    JMP printSUM
    sumBack: 
    cmp CX, 8
    JNE subBack 
    JMP printSUB 
    subBack:
    cmp CX, 7
    JNE mulBack
    JMP printMUL
    mulBack:   
    cmp CX, 6
    JNE divBack
    JMP printDIV
    divBack: 
    cmp CX, 5
    JNE dotBack
    JMP printDOT
    dotBack:
    cmp CX, 4
    JNE andBack
    JMP printAND
    andBack:
    cmp CX, 3
    JNE orBack
    JMP printOR
    orBack:
    cmp CX, 2
    JNE xorBack
    JMP printXOR
    xorBack:
    cmp CX, 1
    JNE notBack
    JMP printNOT
    notBack:
    xor CX,CX
    mov SI,offset ANSWER
    mov CX,DI
    cmp CX,0
    JE output_part_2_2     
    
skip_occupied_positions_for_output_2:
   add SI, 2
loop skip_occupied_positions_for_output_2    

output_part_2_2:
    inc DI
    xor AX,AX
    mov BX,10
    
    xor CX,CX
    call number_to_string_procedure
    pop CX
    loop convert_number_to_string_2

    xor DX,DX
    xor DI,DI

    xor CX,CX
    xor AX,AX
    JMP end_of_program
    
    ;END_OF_OUTPUT
    

wrong_input:
print_str message_wrong
JMP end_of_program  

convert_string_to_number proc near

again:
    mov BL,[SI]
    cmp BL,'$'
    JE exit_proc
    sub BL,'0'
    mul CX
    add AX,BX
    cmp AH,80h ;check if number is >32767
    JNAE noneed         ;if < 80h no need to check if its neg 
    cmp buf,'-'
    JNE wrong_input
    cmp al, 0
    JNE wrong_input
    noneed:
    inc SI
    jmp again

exit_proc: 
    ret
convert_string_to_number endp 

number_to_string_procedure proc 
    
    mov AX,[SI]
    test AX,AX
    JNS positive
    push AX
    mov AH,2h
    mov DL, '-'
    int 21h
    pop AX
    neg AX

positive:
    xor DX,DX
    div BX
    push DX 
    inc CX
    test AX,AX
    JNZ positive
    mov AH,2h
    
print_number: 
    
    pop DX
    add DL,'0'   ;.....................
    int 21h

loop print_number

    mov AX,DI
    mov BL,6
    div BL
    cmp AH,0
    JNE space 
    print_str endl
    ;print_str enter
    ret

space:
    mov AH,2h
    mov DL,' '
    int 21h
ret
number_to_string_procedure endp   

overflow:
    print_str OVERFLOW_str
    JMP end_of_program

nullDivide:
    print_str message_no_divide_at_null
    JMP end_of_program

printSum:
    print_str message_final_matrix  
    JMP sumBack 
    
printSub:
    print_str subOfTwoNumbers
    JMP subBack
    
printMUL:
    print_str mulOfTwoNumbers
    JMP mulBack

printDIV:
    print_str divOfTwoNumbers
    JMP divBack

printAND:
    print_str andOfTwoNumbers
    JMP andBack 

printOR:
    print_str orOfTwoNumbers 
    JMP orBack

printXOR:
    print_str xorOfTwoNumbers
    JMP xorBack 

printNOT:
    print_str notOfTwoNumbers
    JMP notBack 

printDOT:
    mov AH, 2h
    mov DL, ','
    int 21h
    JMP dotBack

end_of_program:
    mov ax,4C00h
    int 21h

end start
