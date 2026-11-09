format ELF64
public _start


include "sys.inc"
include "str.inc"
include "math.inc"


section '.main' executable
_start:
	call exit
