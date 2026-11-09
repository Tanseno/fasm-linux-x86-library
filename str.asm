; Библиотека функций связанная со строками
format ELF64


public cmpStr
public lenStr
public strToUNum
public uNumToStr
public strToNum
public numToStr


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
	push rsi
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
; rax = str
; OUTPUT
; rax = signed number
section '.strToNum' executable
strToNum:
	push rbx
	push rcx
	push rdx
	push r8
	xor rcx,rcx ; обнуление счётчика
	xor rbx,rbx ; обнуление значения для перевода из строки в число
	xor r8,r8 ; Флаг который означает что перед нами отрицательное число
	cmp [rax],byte '-'
	je .yes
	.no:
		jmp .iter
	.yes:
		mov r8,1
		inc rcx
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
		cmp r8,1
		jne .to_int
		dec rcx
	.to_int: 
		cmp rcx,0 ; сравнение rcx и 0
		je .check ; если rcx == 0 то переход в .close
		pop rdx ; вытаскиваем из стэка задом напёред, ранние помещённые значения rbx, в rdx
		imul rdx,rbx ; умножаем rdx на rbx
		imul rbx,10 ; умножаем rbx на 10
		add rax,rdx ; rax = rax + rdx
		dec rcx ; rcx--
		jmp .to_int ; возвращаемся к .to_int
	.check:
		cmp r8,1
		jne .close
		neg rax
	.close: ; завершение программы
		pop r8
		pop rdx
		pop rcx
		pop rbx
		ret


; INPUT
; rax = signed number
; rbx = buffer
; rcx = buffer.size
; OUTPUT
; rax = buffer
; rbx = buffer.size
section '.numToStr' executable
numToStr:
	push rcx
	push rdx
	push rsi
	push r8
	mov rsi,rcx ; помещаем число букв в строке регистр rsi
	dec rsi ;rsi-- это делается для помещения в конце нулевого терминатора
	xor rcx,rcx ; обнуление счётчика
	xor r8,r8 ;  Флаг который показывает что число отрицательное
	cmp rax,0
	jg .next_iter
	cmp rax,0
	je .next_iter
	cmp rax,0
	jl .minus
	.minus:
		mov r8,1
		push rax
		mov rax,'-'
		mov byte [rbx],al
		pop rax
		;inc rcx
		neg rax
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
		cmp r8,1
		je .step_minus
		jmp .to_string
	.step_minus:
		mov rax,'-'
		mov [rbx + rcx],al ; перемещаем в адрес строки значение al (-)
		inc rcx
		inc rdx
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
		pop r8
		pop rsi
		pop rdx
		pop rcx
		ret