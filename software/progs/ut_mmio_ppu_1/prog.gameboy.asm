INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM
SECTION "Header", ROM0[$00] 

	LD H,A		; $0055  Initialize scroll count, H=0
	LD A,$64		; $0056
	LD D,A		; $0058  set loop count, D=$64
	LDH [$42],A	; $0059  Set vertical scroll register
	LD A,$91		; $005b
	LDH [$40],A	; $005d  Turn on LCD, showing Background
	INC B			; $005f  Set B=1

Addr_0064:
	LDH A,[$44]	; $0064  wait for screen frame
	CP $90		; $0066
	JR NZ, Addr_0064	; $0068

	die	
