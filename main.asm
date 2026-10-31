format ELF64
public _start


section '.data' writable
a db "qwerty",0
alen = $ - a
b db "qwerty",0
blen = $ - b

msg db "watermelon",0
msg_l = $ - msg
msg_2 db "128",0
_buffer.size equ 32


section '.bss' writable
buffer_char rb 1
_buffer rb _buffer.size


section '.main' executable
_start:
	call exit


; INPUT
; rax - str
; rbx - str
; OUTPUT
; rcx - num (0/1)
section '.cmpStr' executable
cmpStr:
	push rax
	push rbx
	push rdx
	push r8
	push r9

	push rax ; сохраняем строку
	push rbx ; сохраняем строку
	call lenStr ; измеряем размер первой строки
	mov rdx,rax ; сохраняем значение
	mov rax,rbx ; вторую строку перемещаем в регистр rax
	call lenStr ; измеряем размер второй строки
	cmp rax,rdx ; сравниваем размеры
	je .yes ; если размеры равны то переход в .yes
	.no: ; если размеры не совпадают то
		pop rbx ; возвращаем строки в регистры
		pop rax ; возвращаем строки в регистры
		xor rcx,rcx ; обнуление счётчика, превращаем в возращаемое значение
		jmp .close ; завершаем работу функции
	.yes: ; размеры равны
		pop rbx ; возвращаем строки в регистры
		pop rax ; возвращаем строки в регистры
		xor rcx,rcx ; обнуление счётчика
	.iter:
		movzx r8,byte [rax + rcx] ; перемещение символов первой строки в регистр r8
		movzx r9,byte [rbx + rcx] ; перемещение символов второй строки в регистр r9
		cmp r8,r9 ; сравнение символов
		je .nextCheck ; если символы равны, то переход в .nextCheck
		jne .notEqual ; если символы не равны, то переход в .notEqual
	.nextCheck: ; 
		cmp rcx,rdx ; сравнение счётчика и размера строки
		je .done ; если дошли до конца с строки, то перемещение в .done
		inc rcx ; rcx++
		jmp .iter ; возвращаемся к .iter
	.notEqual: ; строки не одинаковые
		xor rcx,rcx ; обнуление счётчика, превращаем в возращаемое значение
		jmp .close ; завершаем работу функции
	.done: ; строки одиннаковые
		mov rcx,1 ; Возвращаем true если строки равны
	.close:
		pop r9
		pop r8
		pop rdx
		pop rbx
		pop rax
		ret


; INPUT
; rax = str
; OUTPUT
; rax = unsigned number
section '.lenStr' executable
lenStr:
	push rbx
	push rcx
	push rdx
	xor rcx,rcx ; обнуление счётчика
	.iter:
		cmp [rax + rcx], byte 0 ; сравнивает значение символа с нулевым терминаторм
		je .close ; если нулевой терминатор нашёлся переход .close
		inc rcx ; rcx++
		jmp .iter ; возвращаемся к .iter
	.close:
		mov rax,rcx
		pop rdx
		pop rcx
		pop rbx
		ret


; INPUT
; rax = unsigned number
; rbx = buffer
; rcx = buffer.size
; OUTPUT
; rax = buffer
; rbx = buffer.size
section '.uNumToStr' executable
uNumToStr:
	push rcx
	push rdx
	push rdi
	mov rsi,rcx ; помещаем число букв в строке регистр rsi
	dec rsi ;rsi-- это делается для помещения в конце нулевого терминатора
	xor rcx,rcx ; обнуление счётчика
	.next_iter:
		push rbx ; сохраняем буфер в стэке
		mov rbx,10 ; помещаем в rbx 10
		xor rdx,rdx ; обнуляем остаток от деления
		div rbx ; rax = rax / rbx
		pop rbx ; вытаскиваем буфер из стэка
		add rdx,'0' ; прибавляем к rdx числовое значение ASCII символа '0'
		inc rcx ; rcx++
		push rdx ; пушим значения числа в стэк
		cmp rax,0 ; сравнения rax с 0
		je .next_step ; если это так то переход в .next_step
		jmp .next_iter ; возвращаемся к .next_iter
	.next_step: 
		mov rdx,rcx ; rdx = rcx в rdx теперь количество букв в будущей строке
		xor rcx,rcx ; обнуляем счётчик
	.to_string:
		cmp rcx,rsi ; сравнения rcx и rsi
		je .pop_iter ; если rcx == rsi переход к .pop_iter
		cmp rcx,rdx ; сравниваем rcx и rdx
		je .null_char ; если rcx == rdx переходим в .null_char
		pop rax ; вытаскиваем char из стэка в обратном порядке
		mov [rbx + rcx],al ; перемещаем в адрес строки значение al 
		inc rcx ; rcx++
		jmp .to_string ; возвращаемся к .to_string
	.pop_iter: ; вызавется в случае переполнения строки
		cmp rcx,rdx ; rcx сравнивается с rdx
		je .close ; если rcx == rdx переходим к .close
		pop rax ; вытаскиваем лишние значения из стэка
		inc rcx ; rcx++
		jmp .pop_iter ; возвращаемся к .pop_iter
	.null_char:
		mov rsi,rdx ; помещаем из rsi = rdx
	.close:
		mov [rbx + rsi],byte 0 ; перемещаем нулевой терминатор в конце строки
		mov rax,rbx
        mov rbx,rsi
		pop rsi
		pop rdx
		pop rcx
		ret


; INPUT
; rax = str
; OUTPUT
; rax = unsigned number
section '.strToUNum' executable
strToUNum:
	push rbx
	push rcx
	push rdx
	xor rcx,rcx ; обнуление счётчика
	xor rbx,rbx ; обнуление значения для перевода из строки в число
	.iter:
		cmp [rax+rcx],byte 0 ; сравнение значение ASCII символа строки с нулевым терминатором
		je .next ; если это так то переход в .next
		mov bl,[rax+rcx] ; перемещаем ASCII символ в строке в bl
		sub bl, '0' ; вычисляем какое число было в строке, путём bl - '0'
		push rbx ; помещаем получившиеся число в rbx в стэк
		inc rcx ; rcx++
		jmp .iter ; возвращаемся к .iter
	.next:
		xor rax,rax ; обнуляем rax
		mov rbx,1 ; помещаем в rbx значение 1
	.to_int: 
		cmp rcx,0 ; сравнение rcx и 0
		je .close ; если rcx == 0 то переход в .close
		pop rdx ; вытаскиваем из стэка задом напёред, ранние помещённые значения rbx, в rdx
		imul rdx,rbx ; умножаем rdx на rbx
		imul rbx,10 ; умножаем rbx на 10
		add rax,rdx ; rax = rax + rdx
		dec rcx ; rcx--
		jmp .to_int ; возвращаемся к .to_int
	.close: ; завершение программы
		pop rdx
		pop rcx
		pop rbx
		ret


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

	mov [buffer_char],al ; Помещаем в буфер значение регистра al, в регистре al хранится номер ASCII символа
	mov rax,1 ; консоль
	mov rdi,1 ; 1 - stdout - вывод
	mov rsi, buffer_char ; помещение буфера в регистр
	mov rdx,1 ; размер строки
	syscall ; Вызов ядра
	
	; Вытаскиваем из стэка
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret ; возвращаемся туда, откуда вызвали


section '.exit' executable
exit:
	mov rax,60 ; Код выхода из программы
	xor rdi,rdi ; Программа завершена без ошибок
	syscall ; Вызов ядра
