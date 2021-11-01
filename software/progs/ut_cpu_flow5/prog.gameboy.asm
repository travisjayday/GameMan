INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 

	ld sp, $8050
	LD B,$01		; $0096     and store in Video RAM
Addr_0098:
	PUSH BC		; $0098
	RL C			; $0099
	RLA			; $009b
	POP BC		; $009c
	RL C			; $009d
	RLA			; $009f
	DEC B			; $00a0
	JR NZ, Addr_0098	; $00a1
	db $fd