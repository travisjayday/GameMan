INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	ld hl, $ffff
	ret c
	ld a, $ff
	ldh [$90], a
	ld sp, $8030
	ld bc, $ff32
	push bc
	ld bc, $0000
	pop bc
	add a, $12
	jp nz, label1
	ld b, $ff
	db $fd
	db $fd
label2: 
	ld e, $33
	push bc
	ld hl, $0023
	add a, $ff
	scf
	rst $00
	or l
	db $fd

label1: 
	ld b, $f2
	jp label2
	db $fd
