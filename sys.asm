; Библиотека функций связанная с системными вызовами
format ELF64


public exit
public printChar
public printLine
public printStr
public printUNum


section '.bss' executable
bufferChar rb 1


section '.exit' executable
exit:
	mov rax,60 ; Код выхода из программы
	xor rdi,rdi ; Программа завершена без ошибок
	syscall ; Вызов ядра


; INPUT
; rax = unsigned number
section '.printUNum' executable
printUNum:
	push rax
	push rbx
	push rcx
	push rdx
	xor rcx,rcx ; обнуляем счётчик
	.iter:
		xor rdx,rdx ; обнуляем остаток от деления
		mov rbx,10 ; помещаем в rbx число 10
		div rbx ; rax / rbx
		add rdx,'0' ; прибавляем к rdx числовое значение ASCII символа '0'
		push rdx ; помещаем в стэк
		inc rcx ; прибавляем к rcx +1
		cmp rax,0 ; сравниваем rax с 0
		je .print_iter ; переход к .print_iter, если rax == 0
		jmp .iter ; возвращаемся к .iter
	.print_iter:
		cmp rcx,0 ; сравниваем rcx с 0
		je .close ; если rcx == 0, переходим в .close
		dec rcx ; rcx--
		pop rax ; вытаскиваем из стэка, задом наперёд рание помещённые значения регистра rdx, в регистр rax, для последующего вывода в консоль
		call printChar ; вызов функции вывода символа в консоль
		jmp .print_iter ; возвращаемся к .print_iter
	.close: ; завершение фунцкии
		pop rdx
		pop rcx
		pop rbx
		pop rax
		retsection '.printUNum' executable
printUNum:
	push rax
	push rbx
	push rcx
	push rdx
	xor rcx,rcx ; обнуляем счётчик
	.iter:
		xor rdx,rdx ; обнуляем остаток от деления
		mov rbx,10 ; помещаем в rbx число 10
		div rbx ; rax / rbx
		add rdx,'0' ; прибавляем к rdx числовое значение ASCII символа '0'
		push rdx ; помещаем в стэк
		inc rcx ; прибавляем к rcx +1
		cmp rax,0 ; сравниваем rax с 0
		je .print_iter ; переход к .print_iter, если rax == 0
		jmp .iter ; возвращаемся к .iter
	.print_iter:
		cmp rcx,0 ; сравниваем rcx с 0
		je .close ; если rcx == 0, переходим в .close
		dec rcx ; rcx--
		pop rax ; вытаскиваем из стэка, задом наперёд рание помещённые значения регистра rdx, в регистр rax, для последующего вывода в консоль
		call printChar ; вызов функции вывода символа в консоль
		jmp .print_iter ; возвращаемся к .print_iter
	.close: ; завершение фунцкии
		pop rdx
		pop rcx
		pop rbx
		pop rax
		ret


; INPUT
; rax = str
; rbx = lenght str
section '.printStr' executable
printStr:
	; Помещаем в стэк
	push rax
	push rbx
	push rcx
	push rdx

	mov rsi,rax ; адрес строки
	mov rdx,rbx ; размер строки
	mov rax,1 ; консоль
	mov rdi,1 ; 1 - stdout - вывод
	syscall ; Вызов ядра

	; Вытаскиваем из стэка
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret ; Возвращаемся туда, откуда вызвали


section '.printLine' executable
printLine:
	; Помещаем в стэк
	push rax

	mov rax,10 ; 10 - символ новой строки
	call printChar ; вызов функции отвечающая за вывод символа
	
	; Вытаскиваем из стэка
	pop rax
	ret ; Возвращаемся туда, откуда вызвали


; INPUT
; rax = char
section 'printChar' executable
printChar:
	; Помещаем в стэк
	push rax
	push rbx
	push rcx
	push rdx

	mov [bufferChar],al ; Помещаем в буфер значение регистра al, в регистре al хранится номер ASCII символа
	mov rax,1 ; консоль
	mov rdi,1 ; 1 - stdout - вывод
	mov rsi, bufferChar ; помещение буфера в регистр
	mov rdx,1 ; размер строки
	syscall ; Вызов ядра
	
	; Вытаскиваем из стэка
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret ; возвращаемся туда, откуда вызвали