.586
.model flat, c

.data 
cote dd ?
.code

Mul_N_32_LONGOP proc

	local ct:DWORD
	push ebp
	mov ebp,esp
	mov esi, [ebp+28] 
	mov ebx, [ebp+24] 
	mov edi, [ebp+20] 
	mov ecx, [ebp+16]

	shr ecx, 2 
	mov ct, ecx
	xor ecx, ecx

	cycle1: 
		mov eax, [esi+4*ecx]
		mul ebx
		mov [edi+4*ecx], eax
		mov [edi+4*ecx+4], edx
		inc ecx
		inc ecx
		cmp ecx, ct
		jl cycle1
		xor ecx, ecx
		inc ecx
	cycle2: 
		mov eax, [esi+4*ecx]
		mul ebx
		add [edi+4*ecx], eax
		adc [edi+4*ecx+4], edx
		adc byte ptr [edi+4*ecx+8], 0
		inc ecx
		inc ecx
		cmp ecx, ct
	jl cycle2

	pop ebp
	ret 16

Mul_N_32_LONGOP endp

DIV1_LONGOP proc

	push ebp
	mov ebp, esp
	
	mov esi, [ebp + 20]   ;адреса числа
	mov edi, [ebp + 16]   ;адреса цілої частини
	mov edx, [ebp + 12]   ;адреса залишку
	mov eax, [ebp + 8]    ;кількість байтів

	push edi
	push eax
	mov ecx, eax
	xor eax, eax
	rep stosd
	pop eax
	pop edi
	
	push esi
	push edi
	push edx
	push eax

	shl eax, 5
	sub eax, 4
	mov ecx, eax

	cycle:
	pop eax
	dec eax
	rcr dword ptr [esi+4*eax], 1
	push ecx
	rcr ecx,1
	cmp dword ptr [esi+4*eax], 050000000h
	jb @no
	sub dword ptr [esi+4*eax], 050000000h
	rcl ecx,1
	rcl dword ptr [esi+4*eax], 1
	inc dword ptr [edi]
	jmp @cont
	
	@no:
	rcl ecx,1
	rcl dword ptr [esi+4*eax], 1
	@cont:
	pop ecx

	inc eax

	push ecx
	push edx
	
	mov ecx, eax
	clc
	xor edx, edx
	cycle2:
	mov ebx, dword ptr [edi+4*edx]
	rcl ebx,1
	mov dword ptr [edi+4*edx], ebx
	inc edx
	loop cycle2

	mov ecx, eax
	clc
	xor edx, edx
	cycle1:
	mov ebx, dword ptr [esi+4*edx]
	rcl ebx,1
	mov dword ptr [esi+4*edx], ebx
	inc edx
	loop cycle1

	pop edx
	pop ecx

	push eax

	loop cycle

	dec eax
	rcr dword ptr [esi+4*eax], 1
	rcr ecx,1
	cmp dword ptr [esi+4*eax], 050000000h
	jb @no1
	rcl ecx,1
	sub dword ptr [esi+4*eax], 050000000h
	rcl dword ptr [esi+4*eax], 1
	inc dword ptr [edi]
	jmp @cont1
	
	@no1:
	rcl ecx,1
	rcl dword ptr [esi+4*eax], 1
	@cont1:

	pop eax

	pop edx 
	push eax
	xor eax, eax
	mov dword ptr[edx], eax
	pop eax
	mov ecx, eax
	push eax
	dec ecx
	shl ecx, 2
	add ecx, 3
	mov al, byte ptr [esi+ecx]
	shr al,4
	mov byte ptr[edx],al
	pop eax
	pop edi
	pop esi

	pop ebp

	ret 16

DIV1_LONGOP endp

DIV2_LONGOP proc

	push ebp
	mov ebp, esp
	
	mov esi, [ebp + 20]   ;адрес числа
	mov edi, [ebp + 16]	  ;адрес целой части
	mov ebx, [ebp + 12]   ;адрес остатка
	mov ecx, [ebp + 8]    ;к-ство 32 битных частей

	push ebx
	xor edx, edx
	mov ebx, ecx
	dec ebx
	@cycle :
		push ecx
		mov ecx, 10
		mov eax, dword ptr[esi + 4 *  ebx]
		div ecx
		mov dword ptr[edi + 4 * ebx], eax
		dec ebx
		pop ecx
		dec ecx
	jnz @cycle

	pop ebx
	mov dword ptr[ebx], edx

	pop ebp

	ret 16
	
DIV2_LONGOP endp


StrToDec_LONGOP proc 
	
	push ebp
	mov ebp, esp

	mov esi, [ebp + 20] ;число
	mov edi, [ebp + 16] ;буфер
	mov eax, [ebp + 12] ;разрядность
	mov ebx, [ebp + 8] ;текст

	xor ecx,ecx
	mov cote, ecx

	shr eax, 5
	push ebx
	@cycle:

	push ecx
	push eax
	push ebx

	push esi ;число
	push edi ;буфер
	push ebx ;текст
	push eax ;кол. 32-бит групп
	call DIV2_LONGOP

	; В остаток добавляем 48 что бы получить знак цифры
	pop ebx
	push eax
	mov al, byte ptr[ebx]
	add al, 48
	mov byte ptr[ebx], al
	pop eax

	pop eax
	pop ecx

	inc ebx
	;Переписываем в буфер целую часть
	push esi
	push edi
	push eax
	mov eax, esi
	mov esi, edi
	mov edi, eax
	pop eax
	push ecx
	mov ecx, eax
	rep movsd
	pop ecx
	pop edi
	pop esi
	
	push ebx

	;Проверка не равна ли целая часть 0 (количество груп бит ненулевых записывается в ЕВХ)
	xor ebx, ebx
	xor ecx, ecx

	@cyclep:
	push eax
	mov eax, dword ptr [esi+4*ecx]
	inc ecx
	cmp eax, 0
	jz @cyclex
	inc ebx
	@cyclex:
	pop eax
	cmp ecx, eax
	jne @cyclep

	;Количество цифр в десятичном числе
	
	push ecx
	mov ecx, cote
	inc ecx
	mov cote, ecx
	pop ecx

	mov ecx, ebx
	pop ebx
	cmp ecx,0
	jnz @cycle

	;Обнуляем целую часть
	pop ebx

	;push edi
	;mov eax, ecx
	;mov ecx, 10
	;rep stosd
	;pop edi

	;Перевернутую часть записываем в целую часть
	mov ecx, cote
	xor eax, eax
	@cycleA:
	xor edx, edx
	dec ecx
	mov dl, byte ptr [ebx+ecx]
	mov byte ptr [edi+eax], dl
	inc eax
	cmp ecx, 0
	jnz @cycleA

	;Переписываем в текстовую переменную с целой части
	mov ecx, cote
	mov esi, edi
	mov edi, ebx
	rep movsb 
	
	pop ebp
	ret 16

StrToDec_LONGOP endp

end