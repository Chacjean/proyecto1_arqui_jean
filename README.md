# proyecto1_arqui_jean
Project 1_Arquitectura_Jean

Explicación paso a paso de la lógica de cada procedimiento

1. Leer el archivo de configuración:
        El programa comienza abriendo el archivo config.txt mediante la llamada al sistema open (syscall 2). Se verifica si el archivo se abrió correctamente y, si es así, se procede a leer el archivo con la syscall read (syscall 0).
        Los datos leídos se almacenan en un buffer llamado config_buffer. Posteriormente, se imprime un mensaje de éxito y el contenido del archivo de configuración.

2. Leer el archivo de datos:
        Después, el programa abre el archivo estudiantes.txt, de la misma manera que el archivo de configuración. Si la apertura es exitosa, el contenido se lee en un buffer denominado data_buffer.
        Al igual que en el paso anterior, se imprime un mensaje de éxito y el contenido del archivo de datos.

3. Conversión de texto a enteros:
        En este paso, el programa recorre el data_buffer para extraer las calificaciones de los estudiantes y las convierte de texto (ASCII) a números enteros utilizando la función text_to_int. Esta conversión se realiza caracter por caracter, sumando el valor correspondiente de cada dígito y multiplicando el número acumulado por 10 para desplazar los dígitos hacia la izquierda.
        Una vez convertido cada número, se almacena en el arreglo array. El contador de números leídos se guarda en num_count.
   
4. Ordenamiento de los datos:
        Después de convertir y almacenar los datos, el programa realiza un ordenamiento utilizando el algoritmo de ordenamiento por burbuja (bubble_sort).
        El algoritmo compara elementos adyacentes en el arreglo y los intercambia si están en el orden incorrecto. Este proceso se repite hasta que el arreglo está completamente ordenado.

5. Imprimir los datos ordenados:
        Tras completar el ordenamiento, el programa imprime los números ordenados. Para ello, se utiliza la función print_array, que recorre el arreglo de números y llama a int_to_text para convertir cada número a una cadena de texto, la cual luego se imprime con print_string.

Problemas encontrados

1. Intento fallido de imprimir los datos ordenados:
        En la salida, se observa que no se imprimieron los datos ordenados, aunque se muestra el mensaje de que el ordenamiento fue completado. Esto sugiere que la función print_array no estaba funcionando correctamente para mostrar los valores. Puede haber algún problema en el cálculo de la cantidad de elementos a imprimir o en cómo se maneja el buffer para convertir los números.

2. No se pudo hacer el ordenamiento numérico:
        Aunque el algoritmo de ordenamiento por burbuja está presente, no parece estar funcionando correctamente, ya que no se muestran los datos ordenados. Esto podría ser causado por un error en el intercambio de los valores dentro del arreglo, o una confusión en el tamaño de los datos a procesar.

3. Segmentation fault:
        El error más crítico reportado es el Segmentation fault (core dumped), que indica que el programa intentó acceder a una zona de memoria que no le corresponde. Esto generalmente ocurre cuando se hace un acceso fuera de los límites de un arreglo o cuando se pasa un puntero incorrecto. Posibles causas incluyen:
            El cálculo incorrecto de la cantidad de elementos (num_count).
            El uso incorrecto de las direcciones de memoria en las funciones print_array o text_to_int.
            El uso del puntero rsi sin validación adecuada, lo que podría haber llevado a un acceso ilegal a memoria.

Sugerencias para la solución de problemas

1. Verificar el número de elementos leídos:
        Es importante asegurarse de que el valor de num_count refleje correctamente la cantidad de números leídos y que este valor se pase correctamente a las funciones que imprimen o manipulan el arreglo.

2. Revisar el algoritmo de ordenamiento:
        Asegúrate de que el índice de comparación (rdi) esté dentro de los límites del arreglo. Podrías añadir mensajes de depuración para verificar que las comparaciones e intercambios de los elementos del arreglo se estén realizando correctamente.

3. Asegurar la correcta conversión de texto a número:
        La función text_to_int podría tener problemas si el formato de entrada no es el esperado. Es recomendable revisar si la cadena de texto tiene caracteres adicionales o incorrectos que podrían interferir con la conversión.

4. Depuración y trazado de errores:
        Agregar más mensajes de depuración (print_string) en puntos clave del código, como antes de la conversión, después de la lectura de los archivos y durante el ordenamiento, para detectar el lugar exacto donde ocurre el fallo.
