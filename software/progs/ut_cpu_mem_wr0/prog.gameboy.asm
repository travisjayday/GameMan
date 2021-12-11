INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	/* Load start VRAM */
	ld bc, $8000
	ld a, $aa
	ld [bc], a

	/* Load into hl*/
	ld hl, $8000
	ld e, [hl]

	db $fd
