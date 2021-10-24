INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
	ld bc, $0010	
	ld a, $ff
	LD [BC],A
	inc b 			
	ld b, $ff		
	ld c, $12		
	ld b, c			
	ei
