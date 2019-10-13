		.model tiny
		.code
		org 100h

start:
		mov		dx, offset message_ext					; выводим сообщение на экран
		mov		ah, 9
		int		21h
		mov		dx, offset ext_buffer					; принимаем ввод строки с расширением с клавиатуры
		mov		ah, 0Ah
		int		21h
		lea		di, ext_buffer							; загружаем смещение строки с расширением
		xor		cx, cx
		mov		cl, ext_buffer[1]						; считываем реальную длину строки с расширением
		mov		byte ptr [di], '*'						; первый байт строки с расширением заменяем на символ '*'
		inc		di
		mov		byte ptr [di], '.'						; второй байт строки с расширением заменяем на символ '.'
		dec		di
		add		di, cx
		add		di, 2
		mov		byte ptr [di], '$'						; в конец строки с расширением кладем символ конца строки
		mov		ah, 9
		lea		dx, ext_buffer							; выводим измененную строку на экран
		int		21h
		lea		dx, endl
		int		21h
		int		21h
		
		lea		dx, message_result
		int		21h										; выводим сообщение на экран
		mov		dx, offset result_buffer				; принимаем ввод строки с именем файла с клавиатуры
		mov		ah, 0Ah
		int		21h
		lea		di, result_buffer						; загружаем смещение строки
		xor		cx, cx
		mov		cl, result_buffer[1]					; считываем реальную длину строки 
		add		di, cx
		add		di, 2
		mov		byte ptr [di], 0
		inc		di
		mov		byte ptr [di], '$'						; в конец строки кладем символ конца строки
		mov		ah, 9
		lea		dx, result_buffer + 2
		int		21h
		lea		dx, endl
		int		21h
		int		21h
		
		mov		ah, 5Bh
		mov		al, 02h
		lea		dx, result_buffer + 2
		int		21h										; пробуем открыть файл для записи
		cmp		ax, 50h	
		jz		file_exists								; если файл уже существует, обрабатываем по-другому
		
file_opened:		
		push		ax
		
		xor		ax, ax
		mov		ah, 4Eh									; начинаем поиск файлов с расширением ext_buffer
		xor		cx, cx
		mov		dx, offset ext_buffer
		
file_finding:
		int		21h
		jc		no_more_files							; cf = 1 -> нет больше файлов с указанным расширением
		
		pop		bx										; перемещаем указатель в конец файла
		mov		ah, 42h
		mov		al, 02h
		mov		cx, 0
		xor		dx, dx
		int		21h
		
		mov		di, 80h+1Eh	
		mov		al, 0
		mov		cx, 20									; предполагаемая макс. длина имени файла
		repne		scasb
		mov		byte ptr [di], 10						; переносим каретку
		
		mov		dx, 80h+1Eh
		mov		ax, 20
		sub		ax, cx
		mov		cx, ax
		inc		cx										; теперь cx содержит реальную длину имени файла
		mov		ah, 40h									; записываем имя файла в конец результирующего файла
		int		21h
		push		bx

find_next:
		mov		ah, 4fh									; ищем следующий подходящий файл
		mov		dx, 80h								
		jmp		short file_finding	
		
no_more_files:
		mov		ah, 3eh									; закрывем файл
		pop		bx
		int		21h
		ret												; завершение .com программы
		
file_exists:
		mov		ah, 3Dh									; используем другую функцию
		mov		al, 02h
		int		21h
		jmp		file_opened

		
message_ext		db		"Input extension (txt, com, ...): ", 10, 13, "$"
message_result		db		"Input result file: ", 10, 13, "$"
endl			db		10, 13, '$'
ext_buffer		db		255, 0, 254 dup(?)
result_buffer		db		255, 0, 254 dup(?)

end start