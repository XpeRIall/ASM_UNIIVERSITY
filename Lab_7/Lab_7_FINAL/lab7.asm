.586 
.model flat, stdcall 
	include \masm32\include\kernel32.inc 
	include \masm32\include\user32.inc 
	include module.inc 
	include longop.inc 
	includelib \masm32\lib\kernel32.lib 
	includelib \masm32\lib\user32.lib 
 
option casemap :none 
 
.data 
 
	caption1 db 'n!', 0  	
	caption2 db 'f(x)', 0 
 
	ct dd 32  	
	X dd 0FFFFFFFDh  	
	M db 03h  	
	result dd 0h 
	res_text db 128 dup (0) 
 
	fact_result db 1, 31 dup (0)  	
	buf db 72 dup (0)  	
	fact_text db 72 dup (0) 
	decCode1 db 72 dup(0) 
 	 
.code 
  	start: 
 	 
	@cycle: 
		mov esi, offset fact_result  	
		mov edi, offset buf  	
		mov ecx, 8  	
		rep movsd 
		mov eax, 0 
		mov edi, offset fact_result  	
		mov ecx, 8  	
		rep stosd 
		push offset buf 
		push ct 
		push offset fact_result  	
		push 32 
		call Mul_N_32_LONGOP  	
		dec ct  	
		cmp ct, 1  	
	jg @cycle 

	push offset fact_text 
	push offset fact_result  	
	push 256  	
	call StrHex_MY 
	invoke MessageBoxA, 0, ADDR fact_text, ADDR caption1, 0  
		
	push offset fact_result 
	push offset buf 
	push 256 
	push offset decCode1  	
	call StrToDec_LONGOP  
	invoke MessageBoxA, 0, ADDR decCode1, ADDR caption1, 40h 
 
	mov eax, X  	
	and eax, 0FFFF0000h  	
	shr eax, 16  
	xor dx,dx  	
	add dx, ax   	
	mov eax, X  	
	mov ebx, X  	
	add ebx, 1  	
	idiv bx  	
	shl eax, 16  	
	add ax, dx  	
	mov cl, M  	
	add cl, 0  	
	shl eax, cl 
	mov result, eax 
 
	push offset res_text 
	push offset result  	
	push 32  	
	call StrHex_MY 
	invoke MessageBoxA, 0, ADDR res_text, ADDR caption2, 0 
 
	invoke ExitProcess, 0 
end start 
 
