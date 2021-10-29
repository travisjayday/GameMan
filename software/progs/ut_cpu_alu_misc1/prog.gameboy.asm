INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	ld a, $12
	ld b, $a2
	ld bc, $8000
	add a, b
	daa
	ld [bc], a
	ld a, $02
	ld b, $f1
	sub a, b
	daa
	dec hl
	inc l 
	cpl
	ld hl, $8002
	inc [hl]
	inc [hl]
	dec [hl]
	inc hl
	ld [hl], $f3

	ccf
	ld bc, $8000
	ld a, [bc]

	ld hl, $8005
	adc a, [hl]
	adc a, b
	ld [hl], l
	add a, [hl]
	adc a, b
	ld [hl+], a
	ld [hl], a

	sbc a, [hl]
	sbc a, b
	ld [hl], h
	sub a, [hl]
	sbc a, b

	ld b, $ff
	sbc a, b

	ld c, $13
	xor c
	ld h, $f5
	and h

	ld e, a
	adc a, e

	or e 
	cp e

	db $fd
	
	db $fd