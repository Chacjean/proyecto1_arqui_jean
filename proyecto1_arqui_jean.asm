section .data
	;Mensajes de error y exito
	msg_config_success 	db "Archivo de configuracion cargado exitosamente", 10, 0
	msg_config_error 	db "Error al cargar archivo de configuracion", 10, 0
	msg_data_success 	db "Archivo de datos cargado exitosamente", 10, 0
	msg_data_error		db "Error al cargar archivo de datos", 10, 0

	;Variables para leer archivos
	config_filename 	db "config.txt", 0
	data_filename		db "estudiantes.txt", 0

section .bss
	config_buffer		resb 128
	data_buffer 		resb 128

section .text
	global_start

_start:
	;Paso 1: leer archivo de configuracion
	mov rax, 2			;syscall open
	mov rdi, config_filename 	;nombre del archivo
	mov rsi, 0 			;modo lectura
	syscall

	;comprobar si se abrio correctamente
	test rax, rax
	js config_error

	mov r12, rax 			;guardar descriptor de archivo
	;leer archivo de configuracion
	mov rdi, r12
	mov rax, 0 			;syscall read
	mov rsi, config_buffer
	mov rdx, 128 			;tamaio del buffer
	syscall

	;cerrar archivo de configuracion
	mov rdi, r12
	mov rax, 3 			;syscall close
	syscall

	;mostrar mensaje de exito
	mov rdi, msg_config_success
	call print_string

	;paso 2: leer el archivo de datos (estudiantes)
	mov rax, 2
	mov rdi, data_filename 		;nombre del archivo
	mov rsi, 0 			;modo lectura
	syscall

	;comprobrar si se abrio correctamente
	test rax, rax
	js data_error

	mov r13, rax		;guardar el descriptor de archivo
	;leer el archivo de datos
	mov rdi, r13
	mov rax, 0
	mov rsi, data_buffer
	mov rdx, 128 		;tamanio del buffer
	syscall

	;cerrar archivo de datos
	mov rdi, r13
	mov rax, 3 		;syscall close
	syscall

	;imprimir exito en la carga de datos
	mov rdi, msg_data_success
	call print_string

	;fin del programa
	jmp exit_program

config_error:
	mov rdi, msg_config_error
	call print_string
	jmp exit_program

data_error:
	mov rdi, msg_data_error
	call print_string
	jmp exit_program

exit_program:
	mov rax, 60
	xor rdi, rdi
	syscall

print_string:
	push rdi
	xor rcx, rcx

count_loop:
	cmp byte [rdi + rcx], 0
	je print_done
	inc rcx
	jmp count_loop

print_done:
	mov rax, 1
	mov rsi, rdi
	mov rdx, rcx
	mov rdi, 1
	syscall
	pop rdi
	ret
