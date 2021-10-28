INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	ld bc, $ff
	inc bc

	ld de, $abcd
	inc de

	ld hl, $ffff
	inc hl
	inc hl
	inc hl
	inc bc

	inc b
	inc b
	dec b


	db $fd
