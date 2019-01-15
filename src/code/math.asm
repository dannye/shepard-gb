SECTION "Math", ROM0

; multiply d x e
; return result in hl
Multiply::
	ld hl, 0
	ld a, d
	ld d, 0
	and a
.loop
	jr z, .done
	add hl, de
	dec a
	jr .loop
.done
	ret

; lerp from bc to de by a/256
; assume de is bigger than bc
; and assume de - bc is 8-bit
Lerp::
	push bc
	ld d, a
	ld a, e
	sub c
	ld e, a
	call Multiply
	ldr bc, h
	pop hl
	add hl, bc
	ret
