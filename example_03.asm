.386
.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "MINESWEEPER",0
area_width EQU 525
area_height EQU 616
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12		; pozitiile din stiva relative la ebp
arg3 EQU 16   	; unde se afla argumentele
arg4 EQU 20

button_x equ 10 
button_y equ 101
dim_patrat equ 505

butonx dd 0
butony dd 0
buton dd 0

button_size equ 29

matrice dd 225 dup (0)

	 
lin  dd 129,129,129,129,129,129,129,129,129,129,129,129,129,129,129
	 dd 163,163,163,163,163,163,163,163,163,163,163,163,163,163,163
	 dd 197,197,197,197,197,197,197,197,197,197,197,197,197,197,197
	 dd 231,231,231,231,231,231,231,231,231,231,231,231,231,231,231
	 dd 265,265,265,265,265,265,265,265,265,265,265,265,265,265,265
	 dd 299,299,299,299,299,299,299,299,299,299,299,299,299,299,299
	 dd 333,333,333,333,333,333,333,333,333,333,333,333,333,333,333
	 dd 367,367,367,367,367,367,367,367,367,367,367,367,367,367,367
	 dd 401,401,401,401,401,401,401,401,401,401,401,401,401,401,401
	 dd 435,435,435,435,435,435,435,435,435,435,435,435,435,435,435
	 dd 469,469,469,469,469,469,469,469,469,469,469,469,469,469,469
	 dd 503,503,503,503,503,503,503,503,503,503,503,503,503,503,503
	 dd 537,537,537,537,537,537,537,537,537,537,537,537,537,537,537
	 dd 571,571,571,571,571,571,571,571,571,571,571,571,571,571,571
	 dd 605,605,605,605,605,605,605,605,605,605,605,605,605,605,605
	 
col dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	dd 10,44,78,112,146,180,214,248,282,316,350,384,418,452,486
	
format db "%d", 13,10,0

symbol_width EQU 10
symbol_height EQU 20 ;pt counter - dimensiuni
include digits.inc
include letters.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

asezare_bombe macro 
local bucla_bombe
	pusha
	mov ecx,25
	bucla_bombe:
	push ecx
	rdtsc
	mov edx, 0
	mov ecx, 225
	div ecx
	xor ebx, ebx
	mov ebx, 9
	mov matrice[edx*4],ebx
	
	; xor eax, eax
	; mov eax, lin[edx*4]
	; sub eax, 24               ; fac astea 2 ca sa pozitionez B in mijlocul casetei
	
	; xor edi, edi
	; mov edi, col[edx*4]
	; add edi, 9
	
	;make_text_macro 'B', area, edi, eax

	pop ecx
	loop bucla_bombe
		
	popa
	
	
endm

parcurgere macro 
local bucla,sus_stanga, sus_dreapta, jos_dreapta, jos_stanga,coloana_dreapta, coloana_stanga, linie_jos, linie_sus, next, buclaa

	pusha
	mov ecx, 0
	
	bucla:
	push ecx
	cmp matrice[ecx*4], 9
	jl next
	
	;colturi
	cmp ecx, 0 
	je sus_stanga
	cmp ecx, 210
	je jos_stanga
	cmp ecx, 14
	je sus_dreapta
	cmp ecx, 224
	je jos_dreapta
	
	;margini

	xor edx, edx
	xor eax, eax
	mov eax, ecx
	push ecx
	mov ecx, 15
	div ecx
	pop ecx
	
	cmp edx, 0
	je coloana_stanga
	cmp edx, 14
	je coloana_dreapta

	cmp ecx, 14 
	jl linie_sus
	cmp ecx, 210
	jg linie_jos
	
	
	;caz general
	add matrice[ecx*4-4*15-4],1
	add matrice[ecx*4-4*15],1
	add matrice[ecx*4-4*15+4],1
	add matrice[ecx*4-4],1
	add matrice[ecx*4+4],1
	add matrice[ecx*4+4*15-4],1
	add matrice[ecx*4+4*15],1
	add matrice[ecx*4+4*15+4],1
	jmp next
	
	sus_stanga:
		add matrice[ecx*4+4], 1
		add matrice[ecx*4+4*15], 1 
		add matrice[ecx*4+4*15+4], 1 
		jmp next
		
	jos_stanga:
		add matrice[ecx*4-4*15], 1 
		add matrice[ecx*4-4*15+4], 1 
		add matrice[ecx*4+4], 1
		jmp next
		
	sus_dreapta:
		add matrice[ecx*4-4], 1
		add matrice[ecx*4+4*15], 1 
		add matrice[ecx*4+4*15-4], 1 
		jmp next
	
	jos_dreapta:
		add matrice[ecx*4-4], 1 
		add matrice[ecx*4-4*15], 1 
		add matrice[ecx*4-4*15-4], 1
		jmp next
	
	coloana_stanga:
		add matrice[ecx*4-4*15],1
		add matrice[ecx*4-4*15+4],1
		add matrice[ecx*4+4],1
		add matrice[ecx*4+4*15],1
		add matrice[ecx*4+4*15+4],1
		jmp next
	
	coloana_dreapta:
		add matrice[ecx*4-4*15],1
		add matrice[ecx*4-4*15-4],1
		add matrice[ecx*4-4],1
		add matrice[ecx*4+4*15],1
		add matrice[ecx*4+4*15-4],1
		jmp next
	
	linie_sus:
		add matrice[ecx*4-4],1
		add matrice[ecx*4-4*15-4],1
		add matrice[ecx*4+4],1
		add matrice[ecx*4+4*15],1
		add matrice[ecx*4+4*15+4],1
		jmp next
		
	linie_jos:
		add matrice[ecx*4-4],1
		add matrice[ecx*4-4*15-4],1
		add matrice[ecx*4+4],1
		add matrice[ecx*4-4*15],1
		add matrice[ecx*4-4*15+4],1
		jmp next
		
	next:
		pop ecx
		inc ecx
		cmp ecx, 224
		jle bucla

	popa
endm

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
	
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
	
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
	
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
	
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_gri
	mov dword ptr [edi], 0 ;culoare schimbata
	jmp simbol_pixel_next
	
simbol_pixel_gri:
	mov dword ptr [edi], 0808080h ;culoare fundal counter/scris
	
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

line_horizontal macro x, y, len, color  ; coordonatele, lungimea si culoare
local bucla_line
	mov eax, y 			;eax=y
	mov ebx, area_width
	mul ebx             ;eax= y * area_width
	add eax, x 			;eax= y * area_width + x
	shl eax, 2 			;eax=(y * area_width + x) *4
	add eax, area
	mov ecx, len
	
bucla_line:
	mov dword ptr[eax], color
	add eax, 4 ;deplasare la dreapta
	loop bucla_line
endm

line_vertical macro x, y, len, color  ; coordonatele, lungimea si culoare
local bucla_line
	mov eax, y 			;eax=y
	mov ebx, area_width
	mul ebx             ;eax= y * area_width
	add eax, x 			;eax= y * area_width + x
	shl eax, 2 			;eax=(y * area_width + x) *4
	add eax, area
	mov ecx, len
	
bucla_line:
	mov dword ptr[eax], color
	add eax, area_width * 4 ; deplasare in jos
	loop bucla_line
endm

initializare_tabla macro

;desenare linii orizontale cadru
		
	line_horizontal 0, 0, area_width, 0
	line_horizontal 0, 1, area_width, 0		
	line_horizontal 0, 2, area_width, 0
	line_horizontal 0, 3, area_width, 0
	line_horizontal 0, 4, area_width, 0
	line_horizontal 0, 5, area_width, 0
	line_horizontal 0, 6, area_width, 0
	line_horizontal 0, 7, area_width, 0
	line_horizontal 0, 8, area_width, 0
	line_horizontal 0, 9, area_width, 0

	line_horizontal 0, 91, area_width, 0
	line_horizontal 0, 92, area_width, 0
	line_horizontal 0, 93, area_width, 0
	line_horizontal 0, 94, area_width, 0
	line_horizontal 0, 95, area_width, 0
	line_horizontal 0, 96, area_width, 0
	line_horizontal 0, 97, area_width, 0
	line_horizontal 0, 98, area_width, 0
	line_horizontal 0, 99, area_width, 0
	line_horizontal 0, 100, area_width, 0
	
	line_horizontal 0, 606, area_width, 0
	line_horizontal 0, 607, area_width, 0
	line_horizontal 0, 608, area_width, 0
	line_horizontal 0, 609, area_width, 0
	line_horizontal 0, 610, area_width, 0
	line_horizontal 0, 611, area_width, 0
	line_horizontal 0, 612, area_width, 0
	line_horizontal 0, 613, area_width, 0
	line_horizontal 0, 614, area_width, 0
	line_horizontal 0, 615, area_width, 0
	
	; desenare linii vertical cadru, pun la y = 0 deoarece linia merge in jos, =>y sta pe loc, cu x aleg doar coloanele
	line_vertical 0, 0, area_height, 0
	line_vertical 1, 0, area_height, 0
	line_vertical 2, 0, area_height, 0  
	line_vertical 3, 0, area_height, 0 
	line_vertical 4, 0, area_height, 0	
	line_vertical 5, 0, area_height, 0
	line_vertical 6, 0, area_height, 0
	line_vertical 7, 0, area_height, 0
	line_vertical 8, 0, area_height, 0
	line_vertical 9, 0, area_height, 0
	
	line_vertical 515, 0, area_height, 0
	line_vertical 516, 0, area_height, 0
	line_vertical 517, 0, area_height, 0
	line_vertical 518, 0, area_height, 0
	line_vertical 519, 0, area_height, 0
	line_vertical 520, 0, area_height, 0
	line_vertical 521, 0, area_height, 0
	line_vertical 522, 0, area_height, 0
	line_vertical 523, 0, area_height, 0
	line_vertical 524, 0, area_height, 0
	
	;tarsare linii orizontale tabla
	line_horizontal 0, 130, area_width, 0
	line_horizontal 0, 131, area_width, 0
	line_horizontal 0, 132, area_width, 0
	line_horizontal 0, 133, area_width, 0
	line_horizontal 0, 134, area_width, 0
	
	line_horizontal 0, 164, area_width, 0
	line_horizontal 0, 165, area_width, 0
	line_horizontal 0, 166, area_width, 0
	line_horizontal 0, 167, area_width, 0
	line_horizontal 0, 168, area_width, 0
	
	line_horizontal 0, 198, area_width, 0
	line_horizontal 0, 199, area_width, 0
	line_horizontal 0, 200, area_width, 0
	line_horizontal 0, 201, area_width, 0
	line_horizontal 0, 202, area_width, 0
	
	line_horizontal 0, 232, area_width, 0
	line_horizontal 0, 233, area_width, 0
	line_horizontal 0, 234, area_width, 0
	line_horizontal 0, 235, area_width, 0
	line_horizontal 0, 236, area_width, 0
	
	line_horizontal 0, 266, area_width, 0
	line_horizontal 0, 267, area_width, 0
	line_horizontal 0, 268, area_width, 0
	line_horizontal 0, 269, area_width, 0
	line_horizontal 0, 270, area_width, 0
	
	line_horizontal 0, 300, area_width, 0
	line_horizontal 0, 301, area_width, 0
	line_horizontal 0, 302, area_width, 0
	line_horizontal 0, 303, area_width, 0
	line_horizontal 0, 304, area_width, 0
	
	line_horizontal 0, 334, area_width, 0
	line_horizontal 0, 335, area_width, 0
	line_horizontal 0, 336, area_width, 0
	line_horizontal 0, 337, area_width, 0
	line_horizontal 0, 338, area_width, 0
	
	line_horizontal 0, 368, area_width, 0
	line_horizontal 0, 369, area_width, 0
	line_horizontal 0, 370, area_width, 0
	line_horizontal 0, 371, area_width, 0
	line_horizontal 0, 372, area_width, 0
	
	line_horizontal 0, 402, area_width, 0
	line_horizontal 0, 403, area_width, 0
	line_horizontal 0, 404, area_width, 0
	line_horizontal 0, 405, area_width, 0
	line_horizontal 0, 406, area_width, 0
	
	line_horizontal 0, 436, area_width, 0
	line_horizontal 0, 437, area_width, 0
	line_horizontal 0, 438, area_width, 0
	line_horizontal 0, 439, area_width, 0
	line_horizontal 0, 440, area_width, 0
	
	line_horizontal 0, 470, area_width, 0
	line_horizontal 0, 471, area_width, 0
	line_horizontal 0, 472, area_width, 0
	line_horizontal 0, 473, area_width, 0
	line_horizontal 0, 474, area_width, 0
	
	line_horizontal 0, 504, area_width, 0
	line_horizontal 0, 505, area_width, 0
	line_horizontal 0, 506, area_width, 0
	line_horizontal 0, 507, area_width, 0
	line_horizontal 0, 508, area_width, 0
	
	line_horizontal 0, 538, area_width, 0
	line_horizontal 0, 539, area_width, 0
	line_horizontal 0, 540, area_width, 0
	line_horizontal 0, 541, area_width, 0
	line_horizontal 0, 542, area_width, 0
	
	line_horizontal 0, 572, area_width, 0
	line_horizontal 0, 573, area_width, 0
	line_horizontal 0, 574, area_width, 0
	line_horizontal 0, 575, area_width, 0
	line_horizontal 0, 576, area_width, 0
	
	;trasare linii verticale tabla
	line_vertical 39, 101, 506, 0  ; 576 (pozitia primei linii din ultima serie de linii orizontale) - 130 (pozitia ultimei linii din linia 2 orizontala din cadru) + 60 (30 pixeli pt primul si ultimul rand de casete);
	line_vertical 40, 101, 506, 0
	line_vertical 41, 101, 506, 0
	line_vertical 42, 101, 506, 0
	line_vertical 43, 101, 506, 0
	
	line_vertical 73, 101, 506, 0
	line_vertical 74, 101, 506, 0
	line_vertical 75, 101, 506, 0
	line_vertical 76, 101, 506, 0
	line_vertical 77, 101, 506, 0
	
	line_vertical 107, 101, 506, 0
	line_vertical 108, 101, 506, 0
	line_vertical 109, 101, 506, 0
	line_vertical 110, 101, 506, 0
	line_vertical 111, 101, 506, 0
	
	line_vertical 141, 101, 506, 0
	line_vertical 142, 101, 506, 0
	line_vertical 143, 101, 506, 0
	line_vertical 144, 101, 506, 0
	line_vertical 145, 101, 506, 0
	
	line_vertical 175, 101, 506, 0
	line_vertical 176, 101, 506, 0
	line_vertical 177, 101, 506, 0
	line_vertical 178, 101, 506, 0
	line_vertical 179, 101, 506, 0
	
	line_vertical 209, 101, 506, 0
	line_vertical 210, 101, 506, 0
	line_vertical 211, 101, 506, 0
	line_vertical 212, 101, 506, 0
	line_vertical 213, 101, 506, 0
	
	line_vertical 243, 101, 506, 0
	line_vertical 244, 101, 506, 0
	line_vertical 245, 101, 506, 0
	line_vertical 246, 101, 506, 0
	line_vertical 247, 101, 506, 0
	
	line_vertical 277, 101, 506, 0
	line_vertical 278, 101, 506, 0
	line_vertical 279, 101, 506, 0
	line_vertical 280, 101, 506, 0
	line_vertical 281, 101, 506, 0
	
	line_vertical 311, 101, 506, 0
	line_vertical 312, 101, 506, 0
	line_vertical 313, 101, 506, 0
	line_vertical 314, 101, 506, 0
	line_vertical 315, 101, 506, 0
	
	line_vertical 345, 101, 506, 0
	line_vertical 346, 101, 506, 0
	line_vertical 347, 101, 506, 0
	line_vertical 348, 101, 506, 0
	line_vertical 349, 101, 506, 0
	
	line_vertical 379, 101, 506, 0
	line_vertical 380, 101, 506, 0
	line_vertical 381, 101, 506, 0
	line_vertical 382, 101, 506, 0
	line_vertical 383, 101, 506, 0
	
	line_vertical 413, 101, 506, 0
	line_vertical 414, 101, 506, 0
	line_vertical 415, 101, 506, 0
	line_vertical 416, 101, 506, 0
	line_vertical 417, 101, 506, 0
	
	line_vertical 447, 101, 506, 0
	line_vertical 448, 101, 506, 0
	line_vertical 449, 101, 506, 0
	line_vertical 450, 101, 506, 0
	line_vertical 451, 101, 506, 0
	
	line_vertical 481, 101, 506, 0
	line_vertical 482, 101, 506, 0
	line_vertical 483, 101, 506, 0
	line_vertical 484, 101, 506, 0
	line_vertical 485, 101, 506, 0

endm

buton_creare macro x, y, len, inaltime, color
local fill, line
	mov eax, y ; pun in EAX coordonata lui y
	mov ecx, area_width
	mul ecx
	add eax, x
	shl eax, 2
	add eax,area
	mov ecx, inaltime
	
	fill:
		push ecx
		mov ecx, len
		line:
		mov dword ptr[EAX+4*ECX], color	
		loop line
		add eax, area_width*4
		pop ecx
	loop fill
endm

make_smiley_face macro 
	; galben ffff00
	; gri 808080
	; spatii 0h
	;buton_creare 220, 30, 50, 50, 0808080h ;fundal buton
	
	line_horizontal 241, 40, 11, 0ffff00h ;creare smiley de sus in jos
	line_horizontal 241, 41, 11, 0ffff00h
	line_horizontal 237, 42, 19, 0ffff00h
	line_horizontal 237, 43, 19, 0ffff00h
	line_horizontal 235, 44, 23, 0ffff00h
	line_horizontal 235, 45, 23, 0ffff00h
	line_horizontal 233, 46, 27, 0ffff00h
	line_horizontal 233, 47, 27, 0ffff00h
	line_horizontal 233, 48, 27, 0ffff00h
	line_horizontal 233, 49, 27, 0ffff00h	
	line_horizontal 231, 50, 6, 0ffff00h ;sprancene
	line_horizontal 237, 50, 6, 0
	line_horizontal 243, 50, 7, 0ffff00h
	line_horizontal 250, 50, 6, 0
	line_horizontal 256, 50, 6, 0ffff00h
	line_horizontal 231, 51, 4, 0ffff00h
	line_horizontal 235, 51, 2, 0
	line_horizontal 237, 51, 19, 0ffff00h
	line_horizontal 256, 51, 2, 0
	line_horizontal 258, 51, 4, 0ffff00h
	line_horizontal 231, 52, 31, 0ffff00h
	line_horizontal 231, 53, 8, 0ffff00h ;ochi
	line_horizontal 239, 53, 4, 0
	line_horizontal 243, 53, 7, 0ffff00h
	line_horizontal 250, 53, 4, 0
	line_horizontal 254, 53, 8, 0ffff00h
	line_horizontal 231, 54, 6, 0ffff00h
	line_horizontal 237, 54, 2, 0
	line_horizontal 239, 54, 4, 0ffff00h
	line_horizontal 243, 54, 2, 0
	line_horizontal 245, 54, 3, 0ffff00h
	line_horizontal 248, 54, 2, 0
	line_horizontal 250, 54, 4, 0ffff00h
	line_horizontal 254, 54, 2, 0
	line_horizontal 256, 54, 6, 0ffff00h
	line_horizontal 231, 55, 31, 0ffff00h ;intre ochi si gura
	line_horizontal 231, 56, 31, 0ffff00h
	line_horizontal 231, 57, 31, 0ffff00h
	line_horizontal 231, 58, 31, 0ffff00h
	line_horizontal 233, 59, 27, 0ffff00h
	line_horizontal 233, 60, 27, 0ffff00h
	line_horizontal 233, 61, 7, 0ffff00h ;gura
	line_horizontal 240, 61, 2, 0
	line_horizontal 242, 61, 9, 0ffff00h
	line_horizontal 251, 61, 2, 0
	line_horizontal 253, 61, 7, 0ffff00h
	line_horizontal 233, 62, 9, 0ffff00h
	line_horizontal 242, 62, 9, 0
	line_horizontal 251, 62, 9, 0ffff00h
	line_horizontal 235, 63, 23, 0ffff00h ;barba
	line_horizontal 235, 64, 23, 0ffff00h
	line_horizontal 237, 65, 19, 0ffff00h
	line_horizontal 237, 66, 19, 0ffff00h
	line_horizontal 241, 67, 11, 0ffff00h
	line_horizontal 241, 68, 11, 0ffff00h
endm

make_bomb macro x, y
	buton_creare x-1, y-28, button_size, button_size , 0808080h ;fundal buton  -> la x-1 si y-28 se mai adauga un +1 pt ca area_width e cu unu mai mult decat numerotarea pixelilor
	
	line_horizontal x+8, y-1, 7, 0 ;bomba de jos in sus
	line_horizontal x+4, y-2, 4, 0
	line_horizontal x+8, y-2, 7, 0c8a2c8h
	line_horizontal x+15, y-2, 4, 0
	line_horizontal x+3, y-3, 1, 0
	line_horizontal x+4, y-3, 15, 0c8a2c8h
	line_horizontal x+19, y-3, 1, 0
	line_horizontal x+3, y-4, 1, 0
	line_horizontal x+4, y-4, 15, 0c8a2c8h
	line_horizontal x+19, y-4, 1, 0
	line_horizontal x+2, y-5, 1, 0
	line_horizontal x+3, y-5, 17, 0c8a2c8h
	line_horizontal x+20, y-5, 1, 0
	line_horizontal x+2, y-6, 1, 0
	line_horizontal x+3, y-6, 17, 0c8a2c8h
	line_horizontal x+20, y-6, 1, 0
	line_horizontal x+2, y-7, 1, 0
	line_horizontal x+3, y-7, 17, 0c8a2c8h
	line_horizontal x+20, y-7, 1, 0
	line_horizontal x+1, y-8, 1, 0
	line_horizontal x+2, y-8, 19, 0c8a2c8h
	line_horizontal x+21, y-8, 1, 0
	line_horizontal x+1, y-9, 1, 0
	line_horizontal x+2, y-9, 19, 0c8a2c8h
	line_horizontal x+21, y-9, 1, 0
	line_horizontal x+1, y-10, 1, 0
	line_horizontal x+2, y-10, 19, 0c8a2c8h
	line_horizontal x+21, y-10, 1, 0
	line_horizontal x+1, y-11, 1, 0 ;bottom plus
	line_horizontal x+2, y-11, 4, 0c8a2c8h
	line_horizontal x+6, y-11, 2, 0ffffffh
	line_horizontal x+8, y-11, 13, 0c8a2c8h
	line_horizontal x+21, y-11, 1, 0
	line_horizontal x+1, y-12, 1, 0
	line_horizontal x+2, y-12, 4, 0c8a2c8h
	line_horizontal x+6, y-12, 2, 0ffffffh
	line_horizontal x+8, y-12, 13, 0c8a2c8h
	line_horizontal x+21, y-12, 1, 0
	line_horizontal x+2, y-13, 1, 0 
	line_horizontal x+3, y-13, 1, 0c8a2c8h
	line_horizontal x+4, y-13, 6, 0ffffffh
	line_horizontal x+10, y-13, 10, 0c8a2c8h
	line_horizontal x+20, y-13, 1, 0
	line_horizontal x+2, y-14, 1, 0
	line_horizontal x+3, y-14, 1, 0c8a2c8h
	line_horizontal x+4, y-14, 6, 0ffffffh
	line_horizontal x+10, y-14, 10, 0c8a2c8h
	line_horizontal x+20, y-14, 1, 0
	line_horizontal x+2, y-15, 1, 0
	line_horizontal x+3, y-15, 3, 0c8a2c8h
	line_horizontal x+6, y-15, 2, 0ffffffh
	line_horizontal x+8, y-15, 12, 0c8a2c8h
	line_horizontal x+20, y-15, 1, 0
	line_horizontal x+3, y-16, 1, 0 ;bottom up
	line_horizontal x+4, y-16, 2, 0c8a2c8h
	line_horizontal x+6, y-16, 2, 0ffffffh
	line_horizontal x+8, y-16, 11, 0c8a2c8h
	line_horizontal x+19, y-16, 1, 0
	line_horizontal x+3, y-17, 1, 0 ; up plus
	line_horizontal x+4, y-17, 15, 0c8a2c8h
	line_horizontal x+19, y-17, 1, 0
	line_horizontal x+4, y-18, 4, 0
	line_horizontal x+8, y-18, 7, 0c8a2c8h
	line_horizontal x+15, y-18, 4, 0
	line_horizontal x+8, y-19, 7, 0
	line_horizontal x+11, y-20, 1, 0 ;fir
	line_horizontal x+11, y-21, 1, 0
	line_horizontal x+11, y-22, 1, 0
	line_horizontal x+20, y-22, 1, 0
	line_horizontal x+12, y-23, 2, 0
	line_horizontal x+19, y-23, 1, 0
	line_horizontal x+14, y-24, 5, 0
	line_horizontal x+20, y-25, 1, 0ff24004h; artific
	line_horizontal x+25, y-25, 1, 0ff24004h
	line_horizontal x+20, y-24, 1, 0ff24004h
	line_horizontal x+21, y-24, 1, 0ffffffh
	line_horizontal x+22, y-24, 1, 0ff24004h
	line_horizontal x+23, y-24, 2, 0ffffffh
	line_horizontal x+25, y-24, 1, 0ff24004h
	line_horizontal x+20, y-23, 2, 0ff24004h
	line_horizontal x+22, y-23, 1, 0ffffffh
	line_horizontal x+23, y-23, 4, 0ff24004h
	line_horizontal x+19, y-22, 1, 0ff24004h
	line_horizontal x+21, y-22, 1, 0ffffffh
	line_horizontal x+22, y-22, 1, 0ff24004h
	line_horizontal x+23, y-22, 1, 0ffffffh
	line_horizontal x+24, y-22, 2, 0ff24004h
	line_horizontal x+19, y-21, 1, 0ff24004h
	line_horizontal x+20, y-21, 3, 0ffffffh
	line_horizontal x+23, y-21, 1, 0ff24004h
	line_horizontal x+24, y-21, 1, 0ffffffh
	line_horizontal x+15, y-21, 1, 0ff24004h
	line_horizontal x+20, y-20, 7, 0ff24004h
	line_horizontal x+21, y-19, 5, 0ff24004h
	line_horizontal x+21, y-18, 1, 0ffffffh
	line_horizontal x+22, y-18, 1, 0ff24004h
	line_horizontal x+23, y-18, 1, 0ffffffh
	line_horizontal x+24, y-18, 1, 0ff24004h
	
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y

draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli gri
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 128 ;valoare decimala pt gri
	push area
	call memset
	add esp, 12
	
	initializare_tabla ;pt trasarea liniilor
	make_smiley_face 
	;make_bomb 10, 605
	asezare_bombe
	parcurgere
	
	;afisare matrice
	; pusha
	; xor esi, esi
	; buclaa:
		; push matrice[esi*4]
		; push offset format
		; call printf
		; add esp,8
		; inc esi
		; cmp esi, 224
		; jle buclaa
	; popa
	
	
	
evt_click:
	mov eax, [ebp+arg2]
	cmp eax, button_x
	jl button_fail
	cmp eax, button_x + dim_patrat
	jg button_fail
	
	mov eax, [ebp+arg3]
	cmp eax, button_y
	jl button_fail
	cmp eax, button_y + dim_patrat
	jg button_fail
	
	; s a dat click pe buton
	pusha
	xor edx, edx
	xor eax, eax
	mov eax, [ebp+arg2]
	sub eax, 10
	xor ecx, ecx
	mov ecx,34
	div ecx
	mov butonx, eax
	
	
	xor edx, edx
	xor eax, eax
	mov eax, [ebp+arg3]
	sub eax, 101
	xor ecx, ecx
	mov ecx,34
	div ecx
	mov butony, eax
	
	xor eax, eax
	xor edx,edx
	mov edx, 15
	add eax, butony
	mul edx
	add eax, butonx
	
	xor esi, esi
	mov esi, eax
	
	xor ecx, ecx
	xor edx, edx
	mov ecx, col[eax*4]
	mov edx, lin[eax*4]
	

		xor eax, eax
		mov eax, lin[esi*4]
		sub eax, 24               ; fac astea 2 ca sa pozitionez in mijlocul casetei
		
		xor edi, edi
		mov edi, col[esi*4]
		add edi, 9
		
		cmp matrice[esi*4], 0
		je b0
		cmp matrice[esi*4], 1
		je b1
		cmp matrice[esi*4], 2
		je b2
		cmp matrice[esi*4], 3
		je b3
		cmp matrice[esi*4], 4
		je b4
		cmp matrice[esi*4], 5
		je b5
		cmp matrice[esi*4], 6
		je b6
		cmp matrice[esi*4], 7
		je b7
		cmp matrice[esi*4], 8
		je b8
		cmp matrice[esi*4], 9
		jge b9
		jmp final
		
		b0:
			make_text_macro '0', area, edi, eax
			jmp final
		b1:
			make_text_macro '1', area, edi, eax
			jmp final
		b2:
			make_text_macro '2', area, edi, eax
			jmp final
		b3:
			make_text_macro '3', area, edi, eax
			jmp final
		b4:
			make_text_macro '4', area, edi, eax
			jmp final
		b5:
			make_text_macro '5', area, edi, eax
			jmp final
		b6:
			make_text_macro '6', area, edi, eax
			jmp final
		b7:
			make_text_macro '7', area, edi, eax
			jmp final
		b8:
			make_text_macro '8', area, edi, eax
			jmp final
			
		b9:
			; game_over:	
			
			make_text_macro 'G', area, 200, 300
			make_text_macro 'A', area, 210, 300
			make_text_macro 'M', area, 220, 300
			make_text_macro 'E', area, 230, 300
			
			make_text_macro 'O', area, 250, 300
			make_text_macro 'V', area, 260, 300
			make_text_macro 'E', area, 270, 300
			make_text_macro 'R', area, 280, 300
			jmp final
			
		final:

	 
	popa
	
	jmp afisare_counter

button_fail:
	jmp afisare_counter
	
	
evt_timer:
	inc counter
	
afisare_counter:

	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 50, 40
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 40, 40
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 40
    jmp final_draw

	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret

draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2 ;aici inmultin cu 4 pt ca fiecare pixel ocupa un DW (4bytes)
	push eax
	call malloc ;alocare memorie pentru zona de desenat
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw ; draw=procedura principala din program
					 ; se apeleaza de fiecare data cand apare un eveniment
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing ; apelam functia de desenat
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
