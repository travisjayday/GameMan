INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	/* Load start VRAM */
	ld bc, $8000
	ld a, $aa
	ld [bc], a

	/* Load end VRAM */
	ld bc, $9fff
	ld a, $bb
	ld [bc], a

	/* Load start WRAM */
	ld bc, $c000
	ld a, $cc
	ld [bc], a

	/* Load end WRAM */
	ld bc, $dfff
	ld a, $cc
	ld [bc], a

	/* Load start OAM */
	ld bc, $fe00
	ld a, $dd
	ld [bc], a

	/* Load end OAM */
	ld bc, $fe9f
	ld a, $ee
	ld [bc], a

	/* Load start HRAM */
	ld bc, $ff80
	ld a, $ff
	ld [bc], a

	/* Load end HRAM */
	ld bc, $fffe
	ld a, $11
	ld [bc], a

	ld hl, $fffe
	ld b, [hl]

	ld hl, $dfff
	ld c, [hl]

	ld hl, $fe00
	ld e, [hl]

	db $fd
