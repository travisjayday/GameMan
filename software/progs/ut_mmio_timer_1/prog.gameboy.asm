INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM
SECTION "Header", ROM0[$00] 
	ld a, $2		; 2
	ld b, $0F		; 2 div->1
	ld b, $0d		; 2 div->2
loop: 
	dec b			; 1
	jr nz, loop		; 4 / 3
	; the above are exactly 64 machien cyels
	dec a			; 1
	ld b, $0d		; 2
	jr nz, loop		; 4 / 3
	nop
	nop
	nop
	nop
	nop
	nop
	nop; e


	die	
