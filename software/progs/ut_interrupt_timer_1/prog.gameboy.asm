INCLUDE "hardware.inc"
MACRO die 
	db $fd
	nop
ENDM
SECTION "Header", ROM0[$00] 
	ld a, $04
	ld sp, $fffe
	ldh [$0F], a
	ldh [$FF], a
	ei
	ld e, $ff
	nop
	nop
	die

SECTION "TIMER_ISR", ROM0[$50]
	ld bc, $bbb0
	nop
	reti
	