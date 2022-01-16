INCLUDE "hardware.inc"
MACRO die 
	db $fd
	nop
ENDM
SECTION "Header", ROM0[$00] 
	ld sp, $fffe
	ld a, $00

	ldh [$05], a	; TIMA = 0
	ldh [$06], a 	; TMA = 0

	ld a, $05
	ldh [$07], a	; TAC = 110
	ld hl, $00

	ld a, $04
	ldh [$ff], a
	ei 

	xor a, a
	ld e, $1
loop:
	halt
	cp e
	jr nz, loop
	die	

SECTION "TIMER_ISR", ROM0[$50]
	push af
	dec d
	ld a, b
	xor a, $ff
	ld b, a
	ld c, a
	dec e
	pop af
	reti
