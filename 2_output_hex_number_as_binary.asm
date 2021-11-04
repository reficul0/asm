masm
model small dos

data segment para public 'data'
    enter_first_hex_number_msg db 'Enter two digits of first hex number:$'
    enter_second_hex_number_msg db 'Enter two digits of second hex number:$'
    first_number_bits_msg db 'First number bits:$'
    second_number_bits_msg db 'Second number bits:$'
    space_str db ' $'
    number label byte
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

main proc
    assume ds:data, ss:stk
    mov    ax, data
    mov    ds, ax
    
    mov    dx, offset enter_first_hex_number_msg
    mov    ah, 9h
    int    21h
    call   printNewLine
    
    call   getHexNumberFromAsciiCharsToDl
    mov    number, dl
    
    mov    dx, offset enter_second_hex_number_msg
    call   printNewLine
    mov    ah, 9h
    int    21h
    call   printNewLine
    call   getHexNumberFromAsciiCharsToDl
    
    call   printNewLine
    push   dx
    xor    ax, ax
    mov    dx, offset first_number_bits_msg
    mov    ah, 9h
    int    21h
    pop    dx
    xor    ax,ax
    mov    al, dl
    mov    dl, number
    mov    number, al
    call   printNewLine
    call   printBitsOfDl
    
    call   printNewLine
    xor    ax, ax
    mov    dx, offset second_number_bits_msg
    mov    ah, 9h
    int    21h
    xor    dx,dx
    mov    dl, number
    call   printNewLine
    call   printBitsOfDl
    
        
    mov    al, 00h
    mov    ah, 4ch
    int    21h
       
main endp

end main

