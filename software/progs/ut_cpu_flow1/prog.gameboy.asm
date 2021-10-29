INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	jr label1
label2:
	nop
	nop
	ld e, $cc

	inc b
	dec b

	jr z, label3

	ld b, $ee

done: 
	ld c, $34
	db $fc

label1: 
	ld a, $ff
	ld e, $bb
	jr label2

label3: 

	ld b, $12
	inc b

	jr nz, done
	ld c, $56

	db $fd
