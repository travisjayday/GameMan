INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM
SECTION "Header", ROM0[$00] 
	ld sp, $fffe
	ld b, $12
	ld c, $34
	push bc
	push bc
	push bc
	push bc
	push bc
	push bc
	push bc
	ld hl, sp-13

	die	
