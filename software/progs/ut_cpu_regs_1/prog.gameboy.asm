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
	ld hl, $8002
	ld [hl+], a
	ld a, $ee
	ld [hl+], a
	ld hl, $8010
	ld a, $bb
	ld [hl-], a
	ld [hl-], a
	db $fd
	/*
	ld a, $ff
	LD [BC],A
	inc b 			
	ld b, $ff		
	ld c, $12		
	ld b, c			
	stop*/
