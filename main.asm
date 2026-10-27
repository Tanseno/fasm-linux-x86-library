format ELF64
public _start


section '.data' writable
msg db "watermelon",0
msg_l = $ - msg
msg_2 db "128",0
_buffer.size equ 32


section '.bss' writable
buffer_char rb 1
_buffer rb _buffer.size


section '.main' executable
_start:
	mov rax,msg
	call lenStr
	call print_number
	call exit


section '.lenStr' executable
lenStr:
	push rbx
	push rcx
	push rdx
	.iter:
		cmp [rax + rcx], byte 0
		je .close
		inc rcx
		jmp .iter
	.close:
		mov rax,rcx
		pop rdx
		pop rcx
		pop rbx
		ret

; INPUT
; rax = int
; rbx = buffer
; rcx = buffer.size
section '.intToStr' executable
int_to_str:
	push rax
	push rbx
	push rcx
	push rdx
	push rdi
	mov rsi,rcx
	dec rsi
	xor rcx,rcx
	.next_iter:
		push rbx
		mov rbx,10
		xor rdx,rdx
		div rbx
		pop rbx
		add rdx,'0'
		inc rcx
		push rdx
		cmp rax,0
		je .next_step
		jmp .next_iter
	.next_step:
		mov rdx,rcx
		xor rcx,rcx
	.to_string:
		cmp rcx,rsi
		je .pop_iter
		cmp rcx,rdx
		je .null_char
		pop rax
		mov [rbx + rcx],al
		inc rcx
		jmp .to_string
	.pop_iter:
		cmp rcx,rdx
		je .close
		pop rax
		inc rcx
		jmp .pop_iter
	.null_char:
		mov rsi,rdx
	.close:
		mov [rbx + rsi],byte 0
		pop rsi
		pop rdx
		pop rcx
		pop rbx
		pop rax
		ret


; INPUT
; rax = str
; OUTPUT
; rax = int
section '.strToInt' executable
str_to_int:
	push rbx
	push rcx
	push rdx
	xor rcx,rcx
	xor rbx,rbx
	.iter:
		cmp [rax+rcx],byte 0
		je .next
		mov bl,[rax+rcx]
		sub bl, '0'
		push rbx
		inc rcx
		jmp .iter
	.next:
		xor rax,rax
		mov rbx,1
	.to_int:
		cmp rcx,0
		je .close
		pop rdx
		imul rdx,rbx
		imul rbx,10
		add rax,rdx
		dec rcx
		jmp .to_int
	.close:
		pop rdx
		pop rcx
		pop rbx
		ret


; INPUT
; rax = int
section '.printNumber' executable
print_number:
	push rax
	push rbx
	push rcx
	push rdx
	xor rcx,rcx
	.iter:
		xor rdx,rdx
		mov rbx,10
		div rbx
		add rdx,'0'
		push rdx
		inc rcx
		cmp rax,0
		je .print_iter
		jmp .iter
	.print_iter:
		cmp rcx,0
		je .close
		dec rcx
		pop rax
		call print_char
		jmp .print_iter
	.close:
		pop rdx
		pop rcx
		pop rbx
		pop rax
		ret


; INPUT
; rax = str
; rbx = lenght str
section '.printString' executable
print_string:
	push rax
	push rbx
	push rcx
	push rdx
	mov rsi,rax
	mov rdx,rbx
	mov rax,1
	mov rdi,1
	syscall
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret
	

section '.printLine' executable
print_line:
	push rax
	mov rax,10
	call print_char
	pop rax
	ret


; INPUT
; rax = char
section 'printChar' executable
print_char:
	push rax
	push rbx
	push rcx
	push rdx

	mov [buffer_char],al
	mov rax,1
	mov rdi,1
	mov rsi, buffer_char
	mov rdx,1
	syscall
	
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret


section '.exit' executable
exit:
	mov rax,60
	mov rdi,0
	syscall
