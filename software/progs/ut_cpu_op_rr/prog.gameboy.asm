INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM
SECTION "Header", ROM0[$00] 
	ld sp, $fffe

	ld hl, values
	ld e, $09

next_val:
	ld a, [hl+]
	ld c, a
	push hl
	push de

	ld e, $09
	ld hl, values

inner_val:
	ld a, [hl+]
	ld b, a
	push hl
	push de
	push bc

	; run instr here
	; operands are in b and c
	nop
	ld a, c
	scf
	rrca

	push af
	pop bc	; flags is in c
	ld b, a	; result is in a

	ld hl, $C000
	ld a, [hl]
	ld e, a
	inc a
	ld [hl], a

	ld hl, $C100
	ld a, l
	add a, e
	ld l, a
	ld [hl], b

	ld hl, $C200
	ld a, l
	add a, e
	ld l, a
	ld [hl], c


	pop bc
	pop de
	pop hl
	dec e
	jr nz, inner_val

	pop de
	pop hl
	dec e
	jr nz, next_val

	die	

values:
    DB $00,$01,$0F,$10,$1F,$7F,$80,$F0,$FF

