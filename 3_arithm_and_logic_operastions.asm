masm
model small dos

; Variant 8: 
; 1. C=A+B*2
; 2. Zero all even bits of C

data segment para public 'data'
    space_str db ' $'

    enter_A_hex_number_msg db 'Enter two digits of A hex number(use uppercase letters):$'
    enter_B_hex_number_msg db 'Enter two digits of B hex number(use uppercase letters):$'
    A_bits_msg db 'A bits:$'
    B_bits_msg db 'B bits:$'
    B_mul_2_bits_msg db 'B*2 bits(High Low):$'
    C_bits_msg db 'C=A+B*2 bits(High Low):$'
    C_with_zero_even_bits_msg db 'C with zero even bits(High Low):$'

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
    ret;
getHexNumberFromAsciiCharsToDl endp

main proc
    assume ds:data, ss:stk
    
    mov    ax, data
    mov    ds, ax
    
    mov    dx, offset enter_A_hex_number_msg
    mov    ah, 9h
    int    21h
    call   printNewLine
    call   getHexNumberFromAsciiCharsToDl
    mov    param_a, dl
    
    mov    dx, offset enter_B_hex_number_msg
    call   printNewLine
    mov    ah, 9h
    int    21h
    call   printNewLine
    call   getHexNumberFromAsciiCharsToDl
    mov    param_b, dl
    
    call   printNewLine
    xor    ax, ax
    mov    dx, offset A_bits_msg
    mov    ah, 9h
    int    21h
    xor    dx, dx
    mov    dl, param_a
    call   printNewLine
    call   printBitsOfDl
    
    call   printNewLine
    xor    ax, ax
    mov    dx, offset B_bits_msg
    mov    ah, 9h
    int    21h
    xor    dx, dx
    mov    dl, param_b
    call   printNewLine
    call   printBitsOfDl
    
    xor    dx, dx
    xor    ax, ax
    
    ; B*2
    mov    al, param_b
    sal    ax, 1
    adc    ah, 0
    
    call   printNewLine
    push   dx
    push   ax
    xor    ax, ax
    mov    dx, offset B_mul_2_bits_msg
    mov    ah, 9h
    int    21h
    pop    ax
    pop    dx
    call   printBitsOfAx
    
    ; A+B*2
    add    al, param_a
    adc    ah, 0
    
    call   printNewLine
    push   dx
    push   ax
    mov    dx, offset C_bits_msg
    mov    ah, 9h
    int    21h
    pop    ax
    pop    dx
    call   printBitsOfAx
    
    ; Zero all even bits of C
    mov    bx, 1010101010101010b
    and    ax, bx
    
    call   printNewLine
    push   dx
    push   ax
    mov    dx, offset C_with_zero_even_bits_msg
    mov    ah, 9h
    int    21h
    pop    ax
    pop    dx
    call   printBitsOfAx
    
    mov    al, 00h
    mov    ah, 4ch
    int    21h
       
main endp

end main

