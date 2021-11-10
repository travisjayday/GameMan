INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	ld hl, $ffff
loop:
	ld a, [hl-]
	xor a, a
	cp h
	jr nz, loop

loop2: 
	ld a, [hl-]
	xor a, a
	cp l
	jr nz, loop2

	nop
	ld b, b
	nop
