;-----------------------------------
; Proyecto 1 Arqui
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
	; Convertir los datos de texto a enteros y almacenarlos en el arreglo
	;------------------------------
	mov rsi, data_buffer   ; Dirección del buffer
	mov rbx, 0             ; Contador de números leídos
convert_loop_data:
    ; Verificar si hemos leído todos los datos
    cmp byte [rsi], 0
    je end_conversion

    ; Llamar a la función text_to_int para convertir el número
    mov rdi, rsi
    call text_to_int

    ; Almacenar el número convertido en el arreglo
    mov [array + rbx * 4], rax
    inc rbx

    ; Avanzar al siguiente byte en el buffer
    inc rsi
    jmp convert_loop_data

end_conversion:
    mov [num_count], rbx ; Guardar la cantidad de números leídos
    ; Continuar con el procesamiento de datos
    mov rdi, msg_processing_data
    call print_string

    ;------------------------------
	; Ordenamiento de los datos
	;------------------------------
    call bubble_sort

	mov rdi, msg_sorting_done
	call print_string

    ; Imprimir los datos ordenados
    mov rdi, msg_processing_done
    call print_string
    mov rsi, array        ; Dirección del arreglo
    mov rdx, [num_count]  ; Número de elementos en el arreglo
    call print_array

	;------------------------------
	; Fin del programa
	;------------------------------
	jmp exit_program

;-----------------------------------
; Función: bubble_sort
;-----------------------------------
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
; Función: text_to_int
;-----------------------------------
; Convierte una cadena de texto (ASCII) en un número entero
text_to_int:
    xor rax, rax                ; Limpiar rax (registro acumulador)
    xor rcx, rcx                ; Limpiar rcx (registro contador)
convert_loop:
    movzx rbx, byte [rdi + rcx] ; Cargar el siguiente byte de la cadena
    test rbx, rbx                ; Comprobar si es el final de la cadena (0)
    jz convert_done              ; Si es 0, hemos terminado
    sub rbx, '0'                 ; Convertir el carácter ASCII a su valor numérico
    imul rax, rax, 10            ; Multiplicar rax por 10 (desplazar un dígito)
    add rax, rbx                 ; Sumar el valor del dígito
    inc rcx                      ; Mover al siguiente carácter
    jmp convert_loop             ; Repetir para el siguiente carácter
convert_done:
    ret

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

;-----------------------------------
; Función: print_array
;-----------------------------------
print_array:
    xor rbx, rbx                  ; Inicializar contador
print_loop:
    cmp rbx, [num_count]          ; Comprobar si hemos imprimido todos los elementos
    jge print_done_array
    mov rdi, [array + rbx * 4]    ; Cargar número del arreglo
    call int_to_text              ; Convertir entero a texto
    mov rdi, rsi                  ; Dirección del texto
    call print_string             ; Imprimir el número
    inc rbx                       ; Avanzar al siguiente número
    jmp print_loop
print_done_array:
    ret

;-----------------------------------
; Función: int_to_text
;-----------------------------------
; Convierte un número entero en una cadena de texto
int_to_text:
    xor rcx, rcx
    mov rbx, 10
    mov rdx, rsi
    add rdx, 10
reverse_digits:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rdx
    mov [rdx], dl
    test rax, rax
    jnz reverse_digits
    mov rsi, rdx
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
