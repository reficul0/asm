masm
model small dos

data segment para public 'data'
    enter_first_hex_number_msg db 'Enter two digits of first hex number:$'
    enter_second_hex_number_msg db 'Enter two digits of second hex number:$'
    first_number_bytes_msg db 'First number bits:$'
    second_number_bytes_msg db 'Second number bits:$'
    space_str db ' $'
    number label word
data ends
    
stk segment stack
    db 256 dup('?')
stk ends
    
.code

printSpace proc near  
    push dx
    push ax
  
    mov dx, offset space_str
    mov ah, 9h
    int 21h     

    pop ax
    pop dx
    ret;
printSpace endp

printNewLine proc near  
    push ax

    mov ah, 0eh 
    mov al, 0ah
    int 10H        

    mov ah, 0eh
    mov al, 0dh
    int 10h        

    pop ax
    ret;
printNewLine endp

; принимает: dl - цифра, которую надо напечатать
printBitsOfDlHexDigit proc near
    mov cx, 8
    
    push dx
    mov bl, dl
    printByte:
        xor dx, dx ; зануляем dl, чтобы он не накапливался
        sal bl, 1  ; сдвигаемся на 1 байт, сдвинутый байт попадёт в cf
        adc dl, 30h ; dl=dl+30h+cf
        
        mov ah, 02h ; ????? ??????? ?????? ???????
        int 21h
        
        loop printByte ; ???? cx<>0 ?? cx=cx-1 ? ??????? ?? ????? m1
        
        pop dx
        ret;
printBitsOfDlHexDigit endp

; принимает: dl - число, которое надо напечатать
printBitsOfDlHexNumber proc near
        mov bl, 16
        xor ax, ax
        mov al, dl
        div bl ; ax делим на bl, в al частное, ah остаток
        
        push ax
        mov dl, al
        call printNewLine
        call printBitsOfDlHexDigit
        pop ax ; ??????? ax ?? ?????
        mov dl, ah ; ??????? ? ?????? ?????? ????? ?????
        
        call printSpace
        call printBitsOfDlHexDigit
        ret;
printBitsOfDlHexNumber endp

; возвращает: dl - введённое число
getHexNumberFromAsciiCharsToDl proc near  
    xor ax, ax ; clear ax
    
    mov ah, 1h ; see al for ascii code
    int 21h
    mov dl, al

    sub dl, 30h ; из аски кода в реальное число
    cmp dl, 9h
    jle M1
    sub dl, 7h
    
    M1: mov cl, 4h
        shl dl, cl ; shift left for 4 bits
        
        xor ax, ax ; clear ax
        mov ah, 1h ; see al for ascii code
        int 21h
        
        sub al, 30h ; из аски кода в реальное число
        cmp al, 9h
        jle M2
        sub al, 7h
        
    M2: add dl, al
        ret;
getHexNumberFromAsciiCharsToDl endp

main proc
    assume ds:data, ss:stk
    
    ; output message
    mov ax, data
    mov ds, ax
    
    mov dx, offset enter_first_hex_number_msg
    mov ah, 9h
    int 21h
    call printNewLine
    
    call getHexNumberFromAsciiCharsToDl
    mov number, dx; результат
    
    mov dx, offset enter_second_hex_number_msg
    call printNewLine
    mov ah, 9h
    int 21h
    call printNewLine
    call getHexNumberFromAsciiCharsToDl
    
    call printNewLine
    push dx
    mov dx, offset first_number_bytes_msg
    mov ah, 9h
    int 21h
    pop dx
    mov ax, number
    mov number, dx
    mov dx, ax
    call printBitsOfDlHexNumber
    
    call printNewLine
    mov dx, offset second_number_bytes_msg
    mov ah, 9h
    int 21h
    mov dx, number
    call printBitsOfDlHexNumber
        
    mov al, 00h
    mov ah, 4ch
    int 21h
       
main endp

end main

