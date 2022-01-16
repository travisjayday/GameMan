INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM
SECTION "Header", ROM0[$00] 

	ld hl, values
	ld e, $0f

next_val:
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	push hl
	push de

	; inner val 
	ld hl, values
	ld e, $0f
inner:
	push de
	push bc
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	ld d, b
	ld e, c
	pop bc

	; instruction to test
	push hl
	push de
	push bc

	nop
	ld h, b
	ld l, c
	add hl, de

	push af
	pop de
	ld d, e ; flags are in d

	ld b, h
	ld c, l

	; result is in bc
	ld hl, $C000
	ld a, [hl]
	ld e, a
	inc e
	ld a, e
	ld [hl], a

	ld hl, $C004
	ld a, l
	add a, e
	ld l, a
	ld [hl], b

	ld hl, $C104
	ld a, l
	add a, e
	ld l, a
	ld [hl], c

	ld hl, $C204
	ld a, l
	add a, e
	ld l, a
	ld [hl], d

	pop bc
	pop de
	pop hl
	; end instruction to test

	pop de
	dec e
	jr nz, inner

	pop de
	pop hl
	dec e
	jr nz, next_val

	die	
values:
     DW $0000,$0001,$000F,$0010,$001F,$007F,$0080,$00FF
     DW $0100,$0F00,$1F00,$1000,$7FFF,$8000,$FFFF
values_end:
     DW $0000,$0001,$000F,$0010,$001F,$007F,$0080,$00FF
     DW $0100,$0F00,$1F00,$1000,$7FFF,$8000,$FFFF

