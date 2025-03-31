;-----------------------------------
; Programa en ensamblador x86-64 para Linux
; Procesamiento de archivos de configuración y datos
;-----------------------------------

section .data
	;Mensajes de error y éxito
	msg_config_success  db "Archivo de configuracion cargado exitosamente", 10, 0
	msg_config_error    db "Error al cargar archivo de configuracion", 10, 0
	msg_data_success    db "Archivo de datos cargado exitosamente", 10, 0
	msg_data_error      db "Error al cargar archivo de datos", 10, 0

	msg_config_contents db "Contenido del archivo de configuracion:", 10, 0
	msg_data_contents   db "Contenido del archivo de datos:", 10, 0

	msg_processing_data db "Procesando datos del archivo...", 10, 0
	msg_processing_done db "Procesamiento completado.", 10, 0
	msg_sorting_done    db "Ordenamiento completado.", 10, 0

	;Variables para los nombres de archivos
	config_filename     db "config.txt", 0
	data_filename       db "estudiantes.txt", 0

section .bss
	config_buffer       resb 512
	data_buffer         resb 512
	array               resd 128     ; Espacio para hasta 128 números enteros
	num_count           resd 1       ; Cantidad de números leídos

section .text
	global _start

_start:
	;------------------------------
	; Paso 1: leer archivo de configuracion
	;------------------------------
	mov rax, 2            ; syscall open
	mov rdi, config_filename ; nombre del archivo
	mov rsi, 0            ; modo lectura
	syscall

	; comprobar si se abrió correctamente
	test rax, rax
	js config_error

	mov r12, rax          ; guardar descriptor de archivo

	; leer archivo de configuracion
	mov rdi, r12
	mov rax, 0            ; syscall read
	mov rsi, config_buffer
	mov rdx, 512          ; tamaño del buffer
	syscall

	mov r14, rax          ; cantidad de bytes leídos

	; cerrar archivo de configuracion
	mov rdi, r12
	mov rax, 3            ; syscall close
	syscall

	; mostrar mensaje de éxito
	mov rdi, msg_config_success
	call print_string

	; mostrar contenido leído del archivo de configuración
	mov rdi, msg_config_contents
	call print_string

	mov rsi, config_buffer ; dirección del buffer
	mov rdx, r14          ; cantidad de bytes leídos
	call print_buffer

	;------------------------------
	; Paso 2: leer el archivo de datos (estudiantes)
	;------------------------------
	mov rax, 2
	mov rdi, data_filename ; nombre del archivo
	mov rsi, 0            ; modo lectura
	syscall

	; comprobar si se abrió correctamente
	test rax, rax
	js data_error

	mov r13, rax          ; guardar el descriptor de archivo

	; leer el archivo de datos
	mov rdi, r13
	mov rax, 0
	mov rsi, data_buffer
	mov rdx, 512          ; tamaño del buffer
	syscall

	mov r15, rax          ; cantidad de bytes leídos

	; cerrar archivo de datos
	mov rdi, r13
	mov rax, 3            ; syscall close
	syscall

	; imprimir éxito en la carga de datos
	mov rdi, msg_data_success
	call print_string

	; mostrar contenido leído del archivo de datos
	mov rdi, msg_data_contents
	call print_string

	mov rsi, data_buffer   ; dirección del buffer
	mov rdx, r15          ; cantidad de bytes leídos
	call print_buffer

	;------------------------------
	; Procesamiento del archivo de datos
	;------------------------------
	mov rdi, msg_processing_data
	call print_string

	; Aquí se agregará la lógica para el Bubble Sort
	call bubble_sort

	mov rdi, msg_sorting_done
	call print_string

	;------------------------------
	; Fin del programa
	;------------------------------
	jmp exit_program

bubble_sort:
	mov rsi, 0
	next_pass:
	mov rdi, 0
	next_compare:
	mov rax, [array + rdi * 4]
	mov rbx, [array + rdi * 4 + 4]
	cmp rax, rbx
	jle no_swap

	; Intercambiar
	mov [array + rdi * 4], rbx
	mov [array + rdi * 4 + 4], rax

no_swap:
	inc rdi
	cmp rdi, [num_count]
	jge pass_done
	jmp next_compare

pass_done:
	inc rsi
	cmp rsi, [num_count]
	jl next_pass
	ret

;-----------------------------------
; Manejo de errores
;-----------------------------------
config_error:
	mov rdi, msg_config_error
	call print_string
	jmp exit_program

data_error:
	mov rdi, msg_data_error
	call print_string
	jmp exit_program

;-----------------------------------
; Salir del programa
;-----------------------------------
exit_program:
	mov rax, 60
	xor rdi, rdi
	syscall

;-----------------------------------
; Función: print_string
;-----------------------------------
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

;-----------------------------------
; Función: print_buffer
;-----------------------------------
print_buffer:
	mov rax, 1
	mov rdi, 1
	syscall
	ret
