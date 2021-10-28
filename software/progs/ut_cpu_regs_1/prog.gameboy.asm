INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	ld bc, $0100	
	ld a, $bb
	ld [bc], a
	ld a, $aa
	ld a, [bc]
	ld bc, $8000
	ld a, $aa
	ld [bc], a
	ld a, [bc]
	db $fd
	/*
	ld a, $ff
	LD [BC],A
	inc b 			
	ld b, $ff		
	ld c, $12		
	ld b, c			
	stop*/
