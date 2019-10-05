; TODO:
; Read filename until '0' symbol and write only necessary symbols
; (now first 20 symbols for write)

		.model tiny
		.code
		org 100h

start:
		mov 	dx, offset message_ext
		mov 	ah, 9
		int 	21h
		mov		dx, offset ext_buffer
		mov		ah, 0Ah
		int 	21h
		lea 	di, ext_buffer
		xor		cx, cx
		mov 	cl, ext_buffer[1]
		mov		byte ptr [di], '*'
		inc		di
		mov		byte ptr [di], '.'
		dec		di
		add 	di, cx
		add		di, 2
		mov 	byte ptr [di], '$'
		mov		ah, 9
		lea 	dx, ext_buffer
		int 	21h
		lea 	dx, endl
		int 	21h
		int 	21h
		
		lea 	dx, message_result
		int 	21h
		mov		dx, offset result_buffer
		mov		ah, 0Ah
		int 	21h
		lea 	di, result_buffer
		xor		cx, cx
		mov 	cl, result_buffer[1]
		add		di, cx
		add 	di, 2
		mov 	byte ptr [di], 0
		inc 	di
		mov 	byte ptr [di], '$'
		mov		ah, 9
		lea 	dx, result_buffer + 2
		int 	21h
		lea 	dx, endl
		int 	21h
		int 	21h
		
		mov 	ah, 5Bh
		mov		al, 02h
		lea 	dx, result_buffer + 2
		int 	21h
		cmp		ax, 50h
		jz		file_exists
		
file_opened:		
		push 	ax
		
		xor 	ax, ax
		mov 	ah, 4Eh
		xor		cx, cx
		mov 	dx, offset ext_buffer
		
file_finding:
		int		21h
		jc		no_more_files
		
		pop 	bx
		mov 	ah, 42h
		mov		al, 02h
		mov		cx, 0
		xor		dx, dx
		int 	21h
		
		mov 	dx, 80h+1Eh
		mov 	cx, 20
		mov 	ah, 40h
		int 	21h
		push	bx

find_next:
		mov 	ah, 4fh
		mov		dx, 80h
		jmp		short file_finding
		
no_more_files:
		mov 	ah, 3eh
		pop		bx
		int 	21h
		ret
		
file_exists:
		mov		ah, 3Dh
		mov		al, 02h
		int 	21h
		jmp		file_opened

		
message_ext 	db 		"Input extension (txt, com, ...): ", 10, 13, "$"
message_result 	db 		"Input result file: ", 10, 13, "$"
endl			db		10, 13, '$'
ext_buffer		db 		255, 0, 254 dup(?)
result_buffer   db 		255, 0, 254 dup(?)
bcontent:

end start