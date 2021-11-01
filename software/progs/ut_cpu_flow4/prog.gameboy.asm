INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	jr z, label1
	ld a, $ff
	jp done
label1: 
	ld a, $bc
done: 
	db $fd