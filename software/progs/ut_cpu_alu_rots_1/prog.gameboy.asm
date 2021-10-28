INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	ld a, $85
	rlca;
	ld sp, $abcd
	ld [$8000], sp
	ld hl, $1230
	ld bc, $4410
	add hl, bc
	add hl, bc
	add hl, bc
	add hl, bc
	add hl, bc

	; test half-carry flag
	ld h, $0f
	add hl, bc

	inc bc
	inc bc
	dec bc

	dec c
	inc c
	inc c

	rrca 
	rrca 

	db $fd
