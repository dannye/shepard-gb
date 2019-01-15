put: macro
	ld a, \2
	ld \1, a
endm

ldx: macro
	rept _NARG
	ld \1, a
	shift
	endr
endm

farcall: macro
	rst FarCall
	db  bank(\1)
	dw  \1
endm

callback: macro
	ld a, bank(\1)
	ld hl, \1
	call Callback
endm

task: macro
	ld a, bank(\1)
	ld de, \1
	call CreateTask
endm

fill: macro
	ld hl, \1
	ld bc, \2
.loop\@
	ld [hl], \3
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .loop\@
endm


; jp to \2 if a == \1
je: MACRO
	IF "\1" == "0"
		and a
	ELSE
		cp \1
	ENDC
	jp z, \2
ENDM

; jp to \2 if a != \1
jne: MACRO
	IF "\1" == "0"
		and a
	ELSE
		cp \1
	ENDC
	jp nz, \2
ENDM

; jp to \2 if a < \1
jl: MACRO
	cp \1
	jp c, \2
ENDM

; jp to \2 if a > \1
jg: MACRO
	cp \1
	jr z, .notGreater\@
	jr c, .notGreater\@
	jp , \2
.notGreater\@
ENDM

; jp to \2 if a <= \1
jle: MACRO
	cp \1
	jp z, \2
	jp c, \2
ENDM

; jp to \2 if a >= \1
jge: MACRO
	cp \1
	jp nc, \2
ENDM

; jp to \1 if a == 0
jz: MACRO
	je 0, \1
ENDM

; jp to \1 if a != 0
jnz: MACRO
	jne 0, \1
ENDM

; jp to \3 if bit \1 of register \2 == 1
; or
; jp to \2 if bit \1 of register a == 1
jb: MACRO
	IF _NARG > 2
		bit \1, \2
		jp nz, \3
	ELSE
		bit \1, a
		jp nz, \2
	ENDC
ENDM

; jp to \3 if bit \1 of register \2 == 0
; or
; jp to \2 if bit \1 of register a == 0
jbz: MACRO
	IF _NARG > 2
		bit \1, \2
		jp z, \3
	ELSE
		bit \1, a
		jp z, \2
	ENDC
ENDM

; ld 8-bit register \2 into 16-bit register \1
ldr: MACRO
	IF "\1" == "bc"
		ld c, \2
		ld b, 0
	ENDC
	IF "\1" == "de"
		ld e, \2
		ld d, 0
	ENDC
	IF "\1" == "hl"
		ld l, \2
		ld h, 0
	ENDC
ENDM


RGB: macro
	db (\1) + (\2) << 5 + (\3) << 10
endm


enum_start: macro
	if _NARG
__enum__ = \1
	else
__enum__ = 0
	endc
endm

enum: macro
	rept _NARG
\1 = __enum__
__enum__ = __enum__ + 1
	shift
	endr
endm
