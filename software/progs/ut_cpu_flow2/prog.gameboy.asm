INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	ld sp, $8030
	call func
	db $fd
	db $fd
	db $fd
	db $fd
	db $fd
	db $fd
func: 
	ld a, $ff
	ld b, $ff
	sub a, b
	call nz, func2
	call func3
	ld b, $bc
	db $fd
	db $fd
	db $fd
	db $fd
	db $fd

func2:
	ld b, $ab
	ld e, $1
	add a, e
	ret nz
	ret z
	db $fd
	db $fd
	db $fd
	db $fd
	db $fd

func3:
	ld e, $ee
	pop af
	db $fd
