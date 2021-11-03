masm
model small

data segment para public 'data'
    msg db 'hello world!$'
data ends
    
stk segment stack
    db 256 dup('?')
stk ends
    
.code
	main proc
		assume ds:data, ss:stk
		mov ax, data
		mov ds, ax;
		
		mov dx, offset msg
		mov ah, 9h
		int 21h
		
		mov ah, 8h
		int 21h
		
		mov al, 00h
		mov ah, 4ch
		int 21h
	main endp
end main