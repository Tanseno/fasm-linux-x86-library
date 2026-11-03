format ELF64
public _start

include "sys.inc"
include "str.inc"
include "math.inc"


section '.data' executable
msg db "Melon"


section '.main' executable
_start:
	mov rax,msg
	push rax
	call lenStr
	mov rbx,rax
	pop rax
	call printStr
	call exit
