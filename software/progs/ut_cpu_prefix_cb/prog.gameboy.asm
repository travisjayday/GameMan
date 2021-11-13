INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	ld sp, $8030
	ld b, $A3
	rlc b
	ld a, $f3
	ld hl, $8000
	ld [hl], a
	bit 4, a
	push af
	rlc [hl]
	ld e, $9a
	ld d, $9a
	rlc l
	rrc h
	bit 7, h
	push af
	rl d
	rr e
	rl [hl]

	ld d, $39
	srl d
	ld l, $f3
	sra l
	srl h
	sla b
	
	ld c, a
	xor a, a
	bit 0, A

	ld hl, $8005
	ld [hl], $f0
	bit 0, [hl]

	add a, $ff
	bit 1, A
	res 5, a
	res 2, a

	set 6, [hl]


	set 7, e
	set 1, a
	push af
	res 5, h

	ld b, b
	nop
