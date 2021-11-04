masm
model small

; Task #3
; Variant 8: 
; 1. C=A+B*2
; 2. Zero all even bits of C


; Task #4
; Variant 8: 
; 1. proc for printing result
; 2. proc for numbers enter
; 3. proc for calculations
; use stack

data segment para public 'data'
    space_str db ' $'

    enter_A_hex_number_msg db 'Enter two digits of A hex number:$'
    enter_B_hex_number_msg db 'Enter two digits of B hex number:$'
    A_bits_msg db 'A bits:$'
    B_bits_msg db 'B bits:$'
    B_mul_2_bits_msg db 'B*2 bits(High Low):$'
    C_bits_msg db 'C=A+B*2 bits(High Low):$'
    C_with_even_bits_setted_to_zero_msg db 'C with even bits setted to zero(High Low):$'
    
    param_a db '?'
    param_b db '?'
    
data ends
    
stk segment stack
    db 256 dup('?')
stk ends
    
.code

printSpace proc near  
    push   dx
    push   ax
  
    mov    dx, offset space_str
    mov    ah, 9h
    int    21h     

    pop    ax
    pop    dx
    ret
printSpace endp
printNewLine proc near  
    push   ax
    
    mov    ah, 0eh 
    mov    al, 0ah
    int    10H        

    mov    ah, 0eh
    mov    al, 0dh
    int    10h        

    pop    ax
    ret
printNewLine endp

; inputs: dl - number
printBitsOfDl proc near
    mov    cx, 8
    
    push   dx
    push   ax
    mov    bl, dl
printByte:
    xor    dx, dx
    sal    bl, 1; 1 to cf
    adc    dl, 30h
    
    mov    ah, 02h
    int    21h
    
    loop   printByte ; if cx!=0 then --cx and loop
    
    pop    ax
    pop    dx
    ret
printBitsOfDl endp
printBitsOfBytePretty macro message:REQ, srcByte:REQ
    call   printNewLine
    xor    ax, ax
    mov    dx, offset message
    mov    ah, 9h
    int    21h
    xor    dx, dx
    mov    dl, srcByte
    call   printNewLine
    call   printBitsOfDl
endm

; inputs: ax - number
printBitsOfAx proc near
    push   ax
    mov    dl, ah 
    call   printNewLine
    call   printBitsOfDl
    pop    ax
    
    mov    dl, al
    call   printSpace
    call   printBitsOfDl
    ret
printBitsOfAx endp
printBitsOfAxPretty macro message:REQ
    call   printNewLine
    push   dx
    push   ax
    xor    ax, ax
    mov    dx, offset message
    mov    ah, 9h
    int    21h
    pop    ax
    pop    dx
    call   printBitsOfAx
endm

; returns: dl - hex number
getHexNumberFromAsciiCharsToDl proc near  
    xor   ax, ax
    
    mov   ah, 1h
    int   21h
    mov   dl, al

    sub   dl, 30h 
    cmp   dl, 9h
    jle   M1
    sub   dl, 7h
    
M1:
    mov   cl, 4h
    shl   dl, cl
    
    xor   ax, ax
    mov   ah, 1h
    int   21h
    
    sub   al, 30h
    cmp   al, 9h
    jle   M2
    sub   al, 7h
M2: 
    add   dl, al
    ret
getHexNumberFromAsciiCharsToDl endp
enterHexNumberToByteMacro macro message:REQ, dstByte:REQ
    call   printNewLine
    mov    dx, offset message
    mov    ah, 9h
    int    21h
    call   printNewLine
    call   getHexNumberFromAsciiCharsToDl
    mov    dstByte, dl
endm

; stack: 
;   [bp+4] -> param_a 1 byte
;   [bp+5] -> param_b 1 byte
; effects:
;   1. prints result of (param_a + param_b * 2)
;   2. set to zero even bits of result from p.1 and print them all
calculate proc near
    push   bp
    mov    bp,sp

    xor    dx, dx
    xor    ax, ax
    
    ; B*2
    mov    al, [bp+5]
    sal    ax, 1
    adc    ah, 0
    
    printBitsOfAxPretty B_mul_2_bits_msg
    
    ; A+B*2
    add    al, [bp+4]
    adc    ah, 0
    
    printBitsOfAxPretty C_bits_msg
    
    ; Zero all even bits of C
    mov    bx, 1010101010101010b
    and    ax, bx

    printBitsOfAxPretty C_with_even_bits_setted_to_zero_msg

    mov    sp,bp
    pop    bp
    
    ret 2
calculate endp

main proc
    assume ds:data, ss:stk
    mov    ax, data
    mov    ds, ax
    
    enterHexNumberToByteMacro enter_A_hex_number_msg, param_a
    enterHexNumberToByteMacro enter_B_hex_number_msg, param_b
    
    printBitsOfBytePretty A_bits_msg, param_a
    printBitsOfBytePretty B_bits_msg, param_b
    
    mov    dh, param_b
    mov    dl, param_a
    push   dx
    call   calculate
    
    mov    al, 00h
    mov    ah, 4ch
    int    21h
       
main endp

end main

