; Библиотека функций связанная с математическими вычислениями
format ELF64


public gCD
public fibonachi
public factorial


; INPUT
; rax - num
; OUTPUT
; rax - num
section '.fibonachi' executable
fibonachi:
	push rbx
	push rcx
	mov rbx,0
	mov rcx,1
	cmp rax,0
	je .step
	.iter:
		cmp rax,1
		je .close
		push rcx
		add rcx,rbx
		pop rbx
		dec rax
		jmp .iter
	.step:
		xor rcx,rcx
	.close:
		mov rax,rcx
		pop rcx
		pop rbx
		ret


; INPUT
; rax - num
; OUTPUT
; rax - num
section '.factorial' executable
factorial:
	push rbx
	mov rbx,1
	.iter:
		cmp rax,0
		jle .close
		imul rbx,rax
		dec rax
		jmp .iter
	.close:
		mov rax,rbx
		pop rbx
		ret


; INPUT
; rax - num 1
; rbx - num 2
; OUTPUT
; rax - num
section '.gCD' executable
gCD:
	push rbx
	push rdx
	.iter:
		cmp rbx,0
		je .close
		xor rdx,rdx
		div rbx
		push rbx
		mov rbx,rdx
		pop rax
		jmp .iter
	.close:
	pop rdx
	pop rbx
		ret