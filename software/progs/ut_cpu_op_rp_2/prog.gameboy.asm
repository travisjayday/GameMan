INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM
SECTION "Header", ROM0[$00] 
	ld hl, $0001
	ld de, $7FFF
	add hl, de

	die	
values:
     DW $0000,$0001,$000F,$0010,$001F,$007F,$0080,$00FF
     DW $0100,$0F00,$1F00,$1000,$7FFF,$8000,$FFFF
values_end:
     DW $0000,$0001,$000F,$0010,$001F,$007F,$0080,$00FF
     DW $0100,$0F00,$1F00,$1000,$7FFF,$8000,$FFFF

