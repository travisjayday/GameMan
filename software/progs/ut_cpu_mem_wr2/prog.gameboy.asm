INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	ld sp, $ffff
	ld hl, sp+$20
	add sp, -1
	ld sp, $8008
	push af

	ld bc, $1244
	add sp, $10
	push bc

	push af
	add sp, -5
	push bc

	add sp, $4
	push bc

	ld hl, label
	jp hl

	/* Load start VRAM */
	ld bc, $8000
	ld a, $aa
	ld [bc], a

	/* Load end VRAM */
	ld bc, $9fff
	ld a, $bb
	ld [bc], a

label:

	/* Load start WRAM */
	ld bc, $c000
	ld a, $cc
	ld [bc], a

	ld [$8040], a
	ld [$8050], a

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

	ld bc, $ff90
	ld a, $ab
	ld [bc], a

	/* Load end HRAM */
	ld bc, $fffe
	ld a, $11
	ld [bc], a

	ldh a, [$90]
	ld b, a
	ldh [$90], a

	ld a, $33
	ldh [$95], a
	ld e, a
	ldh a, [$95]
	ld a, $00
	ld c, $95
	ld a, [c]
	ld d, a

	ld a, $38
	ld c, $98
	ld [c], a

	ld sp, hl

	ld a, [$8000]
	ld c, a
	ld a, [$ff95]

	db $fd
