.586
.model flat, c 
.code
Copy_LONGOP proc 
	push ebp
	mov ebp, esp

	mov edi, [ebp + 16]   
	mov edx, [ebp + 12]   
	mov eax, [ebp + 8]   

	dec ecx
	@copy_my:
		mov eax, [ebx + 4 * ecx]
		mov [edi + 4 * ecx], eax 
		dec ecx
		jge @copy_my

	ret 12
Copy_LONGOP endp

.data
	counter1 dd 0h
	counter2 dd 0h
	maxCounter1 dd 0h
	maxCounter2 dd 0h

	divider dd 1
end
Mul_N_x_32_LONGOP proc
	local x:DWORD
	
	push ebp
	mov ebp, esp

	mov esi, [ebp + 16]
	mov edi, [ebp + 12]
	mov ebx, [ebp + 8]
	mov x, ebx

	mov ecx, 5
	xor ebx, ebx
	@cycle1:
			
		mov eax, dword ptr[edi + 8 * ebx]
		mul x
		mov dword ptr[esi + 8 * ebx], eax
		mov dword ptr[esi + 8 * ebx + 4], edx

		inc ebx
		dec ecx

		jnz @cycle1


	mov ecx, 5
	xor ebx, ebx
	
	@cycle2:
			
		mov eax, dword ptr[edi + 8 * ebx + 4]									
		mul x
		
		clc
		adc eax, dword ptr[esi + 8 * ebx + 4]
		mov dword ptr[esi + 8 * ebx + 4], eax
		clc
		adc edx, dword ptr[esi + 8 * ebx + 8]
		mov dword ptr[esi + 8 * ebx + 8], edx
			
		inc ebx
		dec ecx

		jnz @cycle2


	pop ebp
	ret 12


Mul_N_x_32_LONGOP endp
MySaveFileName proc

		LOCAL ofn : OPENFILENAME

		invoke RtlZeroMemory, ADDR ofn, SIZEOF ofn ;спочатку усі поля обнулюємо

		mov ofn.lStructSize, SIZEOF ofn
		mov ofn.lpstrFile, OFFSET myFileName
		mov ofn.nMaxFile, SIZEOF myFileName

		invoke GetSaveFileName,ADDR ofn ;виклик вікна File Save As
		ret

	MySaveFileName endp
end