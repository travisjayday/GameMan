INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM
SECTION "Header", ROM0[$00] 
	ld a, $2		; 2
	ld b, $0F		; 2 div->1
	ld b, $0d		; 2 div->2
	ldh [$4], a
	ldh [$4], a
	ld a, $ff
	ldh [$7], a
	ldh [$6], a
	ldh a, [$7]
	nop
	nop
	xor a, a
	ldh [$7], a
	ld a, $ff
	ldh [$5], a
	;ld a, 7
	;ld b, a
	;ld a, [$6]
	;ld e, a
	;ld a, $2

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
