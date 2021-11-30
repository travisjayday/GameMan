INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM

SECTION "Shadow OAM", WRAM0,ALIGN[8]

wShadowOAM:
  ds 4 * 40 ; This is the buffer we'll write sprite data to

SECTION "Header", ROM0[$00] 
  jp  main
CopyDMARoutine:
  ld  hl, DMARoutine
  ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
  ld  c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
  ld  a, [hli]
  ldh [c], a
  inc c
  dec b
  jr  nz, .copy
  ret

DMARoutine:
  ld  hl, $c000
  ld  [hl], a

  ldh [$46], a
  
  ld  a, 40
.wait
  ld  e, [hl]
  dec a
  jr  nz, .wait
  ret
DMARoutineEnd:

; Run dma transfer while accessing illegal memory
PopulateShadowOAM:
	ld hl, wShadowOAM
	ld a, 160
.loop:
	ld [hl+], a
	dec a
	jr nz, .loop
	ret

main: 
	call CopyDMARoutine
	call PopulateShadowOAM
	ld a, HIGH(wShadowOAM)
	call hOAMDMA
	die

SECTION "OAM DMA", HRAM

hOAMDMA::
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to
