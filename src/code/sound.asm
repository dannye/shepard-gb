WAVE_SIZE EQU 16


SECTION "Sound WRAM", WRAM0

wPitch1:  ds 1
wOctave1: ds 1
wFreq1:   ds 2
wVolume1: ds 1

wPitch2:  ds 1
wOctave2: ds 1
wFreq2:   ds 2
wVolume2: ds 1

wPitch3:  ds 1
wOctave3: ds 1
wFreq3:   ds 2
wVolume3: ds 1


SECTION "Sound", ROM0

InitSound::
	put [rNR52], %10000000 ; sound enabled
	put [rNR51], %01110111 ; all output
	put [rNR50], $77       ; stereo panning

	put [rNR10], %00000000 ; no sweep
	put [rNR11], %10000000 ; square wave
	put [rNR12], %00010000 ; 1/15th volume
	put [rNR14], %00000000 ; counter mode off

	put [rNR21], %10000000 ; square wave
	put [rNR22], %11110000 ; 100% volume
	put [rNR24], %00000000 ; counter mode off

	put [rNR32], %00100000 ; 100% volume
	put [rNR34], %00000000 ; counter mode off

	put [wPitch1], 0
	put [wOctave1], 7
	put [wVolume1], 1
	put [wPitch2], 0
	put [wOctave2], 5
	put [wVolume2], $F
	put [wPitch3], 0
	put [wOctave3], 3
	put [wVolume3], $F

	call LoadWave

	call PlayNote

	ret

LoadWave:
	put [rNR30], %00000000 ; ch3 off
	put b, [wVolume3]
	swap a
	or b
	ld hl, rWave
	REPT 8
	ld [hli], a
	ENDR
	xor a
	REPT 8
	ld [hli], a
	ENDR
	put [rNR30], %10000000 ; ch3 on
	ret

PlayNote::
	call PlayNote1
	call PlayNote2
	call PlayNote3
	ret

PlayNote1:
	put b, [wOctave1]
	ld a, [wPitch1]
	call CalculateFrequency
	ld a, e
	ld [rNR13], a
	ld [wFreq1], a
	ld a, d
	res 6, a
	ld [rNR14], a
	ld [wFreq1 + 1], a
	ret

PlayNote2:
	put b, [wOctave2]
	ld a, [wPitch2]
	call CalculateFrequency
	ld a, e
	ld [rNR23], a
	ld [wFreq2], a
	ld a, d
	res 6, a
	ld [rNR24], a
	ld [wFreq2 + 1], a
	ret

PlayNote3:
	put b, [wOctave3]
	dec b
	ld a, [wPitch3]
	call CalculateFrequency
	ld a, e
	ld [rNR33], a
	ld [wFreq3], a
	ld a, d
	res 6, a
	ld [rNR34], a
	ld [wFreq3 + 1], a
	ret

SetFrequency1::
	ld a, e
	ld [rNR13], a
	ld [wFreq1], a
	ld a, d
	res 6, a
	res 7, a
	ld [rNR14], a
	ld [wFreq1 + 1], a
	ret

SetFrequency2::
	ld a, e
	ld [rNR23], a
	ld [wFreq2], a
	ld a, d
	res 6, a
	res 7, a
	ld [rNR24], a
	ld [wFreq2 + 1], a
	ret

SetFrequency3::
	ld a, e
	ld [rNR33], a
	ld [wFreq3], a
	ld a, d
	res 6, a
	res 7, a
	ld [rNR34], a
	ld [wFreq3 + 1], a
	ret

GetFrequencyPair1::
	put b, [wOctave1]
	ld a, [wPitch1]
	call CalculateFrequency
	push de
	put b, [wOctave1]
	ld a, [wPitch1]
	inc a
	jne 12, .okay
	xor a
	dec b
.okay
	call CalculateFrequency
	pop bc
	ret

GetFrequencyPair2::
	put b, [wOctave2]
	ld a, [wPitch2]
	call CalculateFrequency
	push de
	put b, [wOctave2]
	ld a, [wPitch2]
	inc a
	jne 12, .okay
	xor a
	dec b
.okay
	call CalculateFrequency
	pop bc
	ret

GetFrequencyPair3::
	put b, [wOctave3]
	dec b
	ld a, [wPitch3]
	call CalculateFrequency
	push de
	put b, [wOctave3]
	dec b
	ld a, [wPitch3]
	inc a
	jne 12, .okay
	xor a
	dec b
.okay
	call CalculateFrequency
	pop bc
	ret

NextNote::
	call NextNote1
	call NextNote2
	call NextNote3
	call SetVolume1
	call SetVolume2
	call SetVolume3
	ret

NextNote1:
	put b, [wOctave1]
	ld a, [wPitch1]
	inc a
	jne 12, .okay
	dec b
	ld a, b
	jne 1, .okay2
	ld b, 7
.okay2
	xor a
.okay
	ld [wPitch1], a
	put [wOctave1], b
	ret

NextNote2:
	put b, [wOctave2]
	ld a, [wPitch2]
	inc a
	jne 12, .okay
	dec b
	ld a, b
	jne 1, .okay2
	ld b, 7
.okay2
	xor a
.okay
	ld [wPitch2], a
	put [wOctave2], b
	ret

NextNote3:
	put b, [wOctave3]
	ld a, [wPitch3]
	inc a
	jne 12, .okay
	dec b
	ld a, b
	jne 1, .okay2
	ld b, 7
.okay2
	xor a
.okay
	ld [wPitch3], a
	put [wOctave3], b
	ret

SetVolume1:
	ld a, [wOctave1]
	sub 2
	ld d, a
	ld e, 12
	call Multiply
	ld a, [wPitch2]
	ldr bc, a
	add hl, bc
	ld bc, Volumes
	add hl, bc
	ld a, [wVolume1]
	ld b, a
	ld a, [hl]
	je b, .same

	ld [wVolume1], a
	swap a
	ld [rNR12], a

	put [rNR13], [wFreq1]
	ld a, [wFreq1 + 1]
	set 7, a
	ld [rNR14], a

.same
	ret

SetVolume2:
	ld a, [wOctave2]
	sub 2
	ld d, a
	ld e, 12
	call Multiply
	ld a, [wPitch2]
	ldr bc, a
	add hl, bc
	ld bc, Volumes
	add hl, bc
	ld a, [wVolume2]
	ld b, a
	ld a, [hl]
	je b, .same

	ld [wVolume2], a
	swap a
	ld [rNR22], a

	put [rNR23], [wFreq2]
	ld a, [wFreq2 + 1]
	set 7, a
	ld [rNR24], a

.same
	ret

SetVolume3:
	ld a, [wOctave3]
	sub 2
	ld d, a
	ld e, 12
	call Multiply
	ld a, [wPitch3]
	ldr bc, a
	add hl, bc
	ld bc, Volumes
	add hl, bc
	ld a, [wVolume3]
	ld b, a
	ld a, [hl]
	je b, .same

	ld [wVolume3], a
	call LoadWave

	put [rNR33], [wFreq3]
	ld a, [wFreq3 + 1]
	set 7, a
	ld [rNR34], a

.same
	ret

Volumes:
	;  C_  C#  D_  D#  E_  F_  F#  G_  G#  A_  A#  B_
	db $6, $6, $5, $5, $4, $4, $3, $3, $2, $2, $1, $1 ; 2
	db $F, $F, $E, $D, $C, $B, $A, $9, $8, $8, $7, $7 ; 3
	db $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F ; 4
	db $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F ; 5
	db $D, $E, $F, $F, $F, $F, $F, $F, $F, $F, $F, $F ; 6
	db $1, $2, $3, $4, $5, $6, $7, $8, $9, $A, $B, $C ; 7

; return the frequency for note a, octave b in de
CalculateFrequency:
	ld h, 0
	ld l, a
	add hl, hl
	ld d, h
	ld e, l
	ld hl, Pitches
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, b
.loop
	cp 7
	jr z, .done
	sra d
	rr e
	inc a
	jr .loop
.done
	ret

Pitches:
	dw $F82C ; C_
	dw $F89D ; C#
	dw $F907 ; D_
	dw $F96B ; D#
	dw $F9CA ; E_
	dw $FA23 ; F_
	dw $FA77 ; F#
	dw $FAC7 ; G_
	dw $FB12 ; G#
	dw $FB58 ; A_
	dw $FB9B ; A#
	dw $FBDA ; B_
