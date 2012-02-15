;; PRACTICA 1.3, ORGANIZACIÓN DE COMPUTADORES, EAFIT 2011
;;
;;	POR:
;;		ESTEBAN ARANGO MEDINA
;;		DANIEL DUQUE TIRADO		
;;		DANIEL ZULUAGA SUAREZ
;;
;: 	linux, nasm, intel 8086
;;	
global _start

section .data
;;---------------Mensajes de iteracción e impresión-----------------
;;------------------------------------------------------------------
msgNeg: db "-"		
lenNeg: equ $ - msgNeg
msgEnter: db "",0xa
lenEnter: equ $ - msgEnter
msgCero: dd "0"
lenCero: equ $ - msgCero
msgBienvenido: db "***********Bienvenido a la Calculadora Polaca!************",0xa,"*                    Notación Prefija                    *",0xa,"*        Comandos Aceptados: M+,M-,MR,MC,OFF,HELP        *",0xa,"*           Operaciones Aceptadas: +,-,*,/               *",0xa,"*    Nota: Los datos deben ser separados por espacios    *",0xa,"**********************************************************",0xa
lenBienvenido: equ $ - msgBienvenido
	
msgHelp:db "                               Menu Ayuda                                 ",0xa,"*          Nota:La operación debe ser ingresada correctamente!           *",0xa,"* Comando M+: Sumar el último resultado en la memoria de la calculadora  *",0xa,"* Comando M-: Restar el último resultado en la memoria de la calculadora *",0xa,"* Comando MR: Mostrar el contenido de la memoria de la calculadora       *",0xa,"* Comando MC: Borrar la memoria de la calculadora                        *",0xa,"* Comando OFF: Terminar Programa                                         *",0xa,"* Ejemplos: a. / 10 5   b. + - 5 3 2    c. - * + 5 5 * 1 2 5             *",0xa
lenHelp:equ $ - msgHelp

	
msgRespuesta: db "El resultado es:",0xa
lenRespuesta: equ $ - msgRespuesta	
msgNuevo:db "Ingrese datos para una nueva operación o un comando:",0xa
lenNuevo:equ $ - msgNuevo	
msgRespuestamas: db "Resultado agregado a la memoria!",0xa
lenRespuestamas: equ $ - msgRespuestamas	
msgRespuestamenos: db "Memoria restada por el resultado!",0xa
lenRespuestamenos: equ $ - msgRespuestamenos
msgRespuestamostrar: db "El valor actual en la memoria es:",0xa
lenRespuestamostrar: equ $ - msgRespuestamostrar	
msgRespuestaborrar: db "Memoria Borrada!",0xa
lenRespuestaborrar: equ $ - msgRespuestaborrar

;;---------------------------------------------------------------
;;-----------Caracteres para comparaciones-----------------------		
sumar: dd '+'     		;Caracter '+', para comparaciones
restar: dd '-'			;Caracter '-', para comparaciones
multip: dd '*'			;Caracter '*', para comparaciones
dividir: dd '/'			;Caracter '/', para comparaciones
espacio: dd ' '			;Caracter ' ', para comparaciones
OFF: dd "OFF"			;"OOF" termina el programa
M_mas: dd "M+"			;"M+" sumar el ultimo resultado
M_menos: dd "M-"		;"M-" resta el ultimo resultado
MR: dd "MR"			;"MR" mostra contenido memoria
MC: dd "MC"			;"MC" borra contenido memoria
punto: dd '.'			;Caracter '.', para comparaciones
off: dd "off"			;"OFF" termina el programa
m_mas: dd "m+"			;"M+" sumar el ultimo resultado
m_menos: dd "m-"		;"M-" resta el ultimo resultado
mr: dd "mr"			;"MR" mostra contenido memoria
mc: dd "mc"			;"MC" borra contenido memoria
help:	dd "help"		;"HELP" Menu ayuda
HELP:	dd "HELP"		;"HELP" Menu ayuda

;;----------Constantes------------------------------------------
;;--------------------------------------------------------------
c_10:	dd 10	                ;Constante 10 
C_0: dd 0			;Constante 0
i: dd 0
negativo: dd -1
esNeg: dd 0
signoF: dd -1.0

diez: dd 10	
diezF: dd 10.0 
cpuno: dd 0.1
mulF: dd 0.1

iDes: dd 1     			;contador para el vector desbordante
contPila: dd 0 			;contador para los numeros que meto en la pila

desborDe: dd 0

;;----------Variables con Espacio Reservado----------------------
;;---------------------------------------------------------------	
section .bss

numEnt: resd 1			;Parte entera del numero antes de mostrar
numDeci: resd 1			;Parte decimal del numero convertida a entera para mostrar

numReal: resd 10
memoria: resd 1
resultado: resd 1

tempDiv1: resd 1
tempDiv2: resd 2

flt1: resd 1			;Numero ya convertido para meter al vector
digt: resd 1			;Digito para ir mostrando el numero

numMostrar: resd 20 		;Array de 20 posiciones para guardar el numero a mostrar
buffer: resd  256		;Buffer para entrar los datos (Tamaño del buffer '256')

vectorNumeros: resd 100		;Vector para almacenar los números en el primer recorrido
vectorDesbordante: resd 100	;Vector para ir metiendo los numeros por si se desborda

;;----------Variables para voltear el stack cuando se llena-------
Psto: resd 1			
Pst1: resd 1
Pst2: resd 1
Pst3: resd 1
Pst4: resd 1
Pst5: resd 1
Pst6: resd 1
Pst7: resd 1
;;-----------------------------------------------------------------

section .text
	
_start:								; Bienvenida
	mov ecx, msgEnter					; Impresión de enter para ordenar
	mov edx, lenEnter
	call escribir
	mov ecx,msgBienvenido					; Mensajes de bienvenida
	mov edx,lenBienvenido
	call escribir
	FLD dword [C_0]						
	FSTP dword [memoria]					; Inicializa memoria en 0 antes de ejecución
	
inicio:	
	; Se inicializan las variables necesarias.
	mov dword[iDes],0
	mov dword[contPila],0
	mov dword[iDes],1
	mov eax,dword[iDes]
	mul dword [negativo]
	mov dword[iDes],eax
	
	
	mov ecx, msgEnter					; Impresión de enter para ordenar
	mov edx, lenEnter
	call escribir

	mov ecx,msgNuevo					; Mensaje de nueva operación u comando
	mov edx,lenNuevo
	call escribir

	mov ecx,buffer						; Comienza a leer caracteres
	mov edx,256
	call leer
		
	call validar						; Proceso de validación de comandos aceptados

	mov ecx, msgRespuesta					; Mensaje de respuesta al finalizar la operación
	mov edx, lenRespuesta
	call escribir
		
	mov dword[esNeg],0	; vuelvo inicializo el indicador de negativo (1, hay numero negativo; -0, no es numero negativo)
	mov edi,[C_0]

;-----------------------------Identificación de caracteres------------------------------------
;--------------------------------------------------------------------------------------------

recorrerBuffer:			;Recorre el buffer de izq-der primero para obtener todos los números,
				;estos se almacenan en 'vectorNumeros'

	mov dword [flt1],0	

	mov al, [buffer + edi]
	cmp al,32		;¿Es un 'espacio'?	
	je retCiclo
	cmp al,[sumar]		;¿Es un '+'?	
	je retCiclo
	cmp al,[restar]		;¿Es un '-'?	
	je numNeg
	cmp al,[multip]		;¿Es un '*'?	
	je retCiclo
	cmp al,[dividir]	;¿Es un '/'?	
	je retCiclo

	;;Es un digito...
	sub al,48		;Resta '0' en ASCII
	mov [flt1],al		;Lo muevo a flt1, donde voy a ir calculando el número

cicloNumero:
	add edi,1		
	mov al, [buffer + edi]
	cmp al, 10		;¿Es 'enter'?
	je convertirPrimero
	cmp al,32		;¿Es un 'espacio'?	
	je convertirPrimero
	cmp al,[punto]		;¿Es un '.'?	
	je precicloDec

	;;Es otro digito del número....
	mov eax,[flt1]
	mul dword [c_10]
	mov [flt1],eax
	mov al, [buffer + edi]
	sub al,48
	add [flt1],al
	mov eax,[flt1]
	jmp cicloNumero

numNeg:
	add edi,1
	mov al, [buffer + edi]
	sub edi,1
	cmp al,32		;¿Es un 'espacio'?, si es un espacio entonces el signo '-' es uno operación y 
	je retCiclo		;no pertenece a un número negativo				
	
	mov dword[esNeg],1	;indicador de un número negativo
	jmp retCiclo

convertirPrimero:		;Convierte número entero en flotante para guardarlo en vector como flotante
	fild dword[flt1]
	fstp dword[flt1]

guardarEnVector:
	mov eax,[esNeg]
	cmp eax,0		;Pregunta si el número que voy a ingresar es un negativo.
	jg guardarEnVectorNeg
	
	FLD dword[flt1]

	mov esi,[i]
	FSTP dword [vectorNumeros + esi]
	add esi,8
	mov [i],esi

	mov al, [buffer + edi]
	cmp al, 10		;¿Es 'enter'?
	je devolverBuffer
	jmp retCiclo

guardarEnVectorNeg:

	FLD dword[flt1]
	fmul dword[signoF]

	mov esi,[i]
	FSTP dword [vectorNumeros + esi]
	add esi,8
	mov [i],esi

	mov dword[esNeg],0

	mov al, [buffer + edi]
	cmp al, 10		;¿Es 'enter'
	je devolverBuffer
	jmp retCiclo



precicloDec:
	fild dword [flt1]	;Convierto numero entero a deciaml
	fstp dword [flt1]
	fld dword [cpuno]	;Reinicio el divisor para los decimales
	fstp dword[mulF]	

cicloParteDecimal:
	

	add edi,1
	mov al, [buffer + edi]
	
	cmp al, 10		;¿Es 'enter'?
	je guardarEnVector
	cmp al,32		;¿Es un 'espacio'?	
	je guardarEnVector
	sub al,48

	mov [numDeci],al
	fild dword[numDeci]
	fmul dword[mulF]
	fadd dword[flt1]
	fstp dword[flt1]

	fld  dword[diez]
	fdiv dword[mulF]
	fstp dword[mulF]
	
	jmp cicloParteDecimal

;----------------------------------Proceso de operaciones--------------------------------	
;----------------------------------------------------------------------------------------	

devolverBuffer:
	FST dword [resultado]	
	sub edi,1
	cmp edi,0
dios:	jl concluir

	mov al, [buffer + edi]
	cmp al,32		;¿Es un 'espacio'?	
	je addToStack
	cmp al,[sumar]		;¿Es un '+'?	
	je sumarEnStack
	cmp al,[restar]		;¿Es un '-'?	
	je compSigNeg
	cmp al,[multip]		;¿Es un '*'?	
	je multiEnStack
	cmp al,[dividir]	;¿Es un '/'?	
	je divEnStack
	jmp devolverBuffer

compSigNeg:
	add edi,1
	mov al, [buffer + edi]
	sub edi,1
	cmp al,32		;¿Es un 'espacio'?	
	je restarEnStack
	sub edi,1
	jmp addToStack


addToStack:	
	mov eax,[contPila]
	cmp eax, 8
	je meterAVectorDes
	
noHayDesborde:	
	mov esi,[i]
	sub esi,8
	mov [i],esi


	fld dword [vectorNumeros + esi]
	
	mov esi,[contPila]	;Aumento el contador de los numeros ingresados a la pila
	add esi,1
	mov [contPila],esi

	jmp devolverBuffer

;;-------------Meter en la pila el último valor guardado en el vector de desboramiento------------

tomarDeVectorDes:
	fstp dword [tempDiv1]
	mov esi,[iDes]
	fld dword [vectorDesbordante + esi]
	fld dword [tempDiv1]
	
	mov eax,[iDes]
	sub eax,4
	mov [iDes],eax
	
	mov esi,[contPila]	;Aumento el contador de los numeros ingresados a la pila
	add esi,1
	mov [contPila],esi
	
	add edi,1

	jmp devolverBuffer

;;-----------------Meter al vector de desbordamiento el valor de la base de la pila----------------

meterAVectorDes:

	FXCH ST7,ST0
	mov esi,[iDes]
	add esi,4
	mov [iDes],esi
	fstp dword [vectorDesbordante + esi]
	fldz
	;--------------------- Voltea toda la pila
	fstp dword [Psto]
	fstp dword [Psto]
	fstp dword [Pst1]
	fstp dword [Pst2]
	fstp dword [Pst3]
	fstp dword [Pst4]
	fstp dword [Pst5]
	fstp dword [Pst6]

	fld dword [Pst5]
	fld dword [Pst4]
	fld dword [Pst3]
	fld dword [Pst2]
	fld dword [Pst1]
	fld dword [Psto]
	fld dword [Pst6]
	;----------------------
	mov esi,[contPila]	;Aumento el contador de los numeros ingresados a la pila
	sub esi,1
	mov [contPila],esi
	jmp noHayDesborde

;;---------------------Operaciones dependiendo del operador encontrado-------------------------------
;;---------------------------------------------------------------------------------------------------

sumarEnStack:

	mov eax,[contPila]
	cmp eax, 1
	je tomarDeVectorDes

	fadd
	sub edi,1
	
	mov esi,[contPila]	;Decremento el contador de los numeros ingresados a la pila
	sub esi,1
	mov [contPila],esi
	
	jmp devolverBuffer

restarEnStack:

	mov eax,[contPila]
	cmp eax, 1
	je tomarDeVectorDes

	;Voltea sto y st1 (la fpu opera en forma diferente o se necesita)
	FSTP dword [tempDiv1]
	FSTP dword [tempDiv2]
	fld dword [tempDiv1]
	fld dword [tempDiv2]	
	
	fsub
	sub edi,1

	mov esi,[contPila]	;Decremento el contador de los numeros ingresados a la pila
	sub esi,1
	mov [contPila],esi	

	jmp devolverBuffer

multiEnStack:

	mov eax,[contPila]
	cmp eax, 1
	je tomarDeVectorDes

	fmul
	sub edi,1
	
	mov esi,[contPila]	;Decremento el contador de los numeros ingresados a la pila
	sub esi,1
	mov [contPila],esi

	jmp devolverBuffer

divEnStack:

	mov eax,[contPila]
	cmp eax, 1
	je tomarDeVectorDes
	
	;Voltea sto y st1 (la fpu opera en forma diferente o se necesita)
	FSTP dword [tempDiv1]
	FSTP dword [tempDiv2]
	fld dword [tempDiv1]
	fld dword [tempDiv2]
		
	fdiv
	sub edi,1

	mov esi,[contPila]	;Decremento el contador de los numeros ingresados a la pila
	sub esi,1
	mov [contPila],esi

	jmp devolverBuffer

;;-------------- Impresión de resultados y números -----------------------------

concluir:
	
	FTST			; Validación Jump if Less (JL)
	FSTSW ax		; a partir de conversión de flags		
	SAHF			
	jc cicloImpresionNeg	

	FSTP dword[flt1]

	mov edi, 0
	jmp operacionFlotantes	
	
cicloImpresionNeg:

	fmul dword[signoF]
	FSTP dword[flt1]

	mov ecx,msgNeg
	mov edx,lenNeg
	call escribir

	mov edi, 0

	jmp operacionFlotantes


operacionFlotantes:	

	fld dword [flt1]
	fst dword [flt1]
	fisttp dword[numEnt]
	mov eax,[numEnt]
	fld dword [flt1]
	fild dword [numEnt]
	fsub

	fmul dword[diezF]
	fmul dword[diezF]	

	fistp dword[numDeci]
	
	mov eax,[numDeci]

;---------------------Impresión---------------	
		
		;Imprimir parte entera
		mov eax,[numEnt]
		mov [numReal],eax
		mov edi,0
		call separarEntero

		;Imprimir punto
		mov edx,1h
		mov ecx,punto
		call escribir
		
		;Imprimir parte decimal
		mov eax,[numDeci]
		cmp eax,10
		jl imprimaCero	


volverImp:	mov eax,[numDeci]	
		mov [numReal],eax
		mov edi,0
		call separarEntero
		call enter
imprimaCero:
		mov edx,lenCero
		mov ecx,msgCero
		call escribir
		call volverImp

separarEntero:
		mov edx,0
		mov eax,[numReal]
		div dword [diez]
		mov [digt],edx
		mov [numReal],eax

		mov eax,[digt]
		add eax,48
	
		mov [numMostrar + edi], eax
	
		inc edi

		mov eax,[numReal]
		cmp eax,0
		jnz separarEntero
		call mostrarNumero
		ret

mostrarNumero:

	mov eax, [numMostrar  + edi]
	mov [digt],eax
	mov ecx,digt
	mov edx,1h
	call escribir

	sub edi,1

	cmp edi,0
	jge mostrarNumero
	ret
	

retCiclo:			;Retornar al recorrerBuffer
	add edi,1
	jmp recorrerBuffer

enter:				
	mov ecx, msgEnter	; Impresión de enter para ordenar despues de resultado
	mov edx, lenEnter
	call escribir
	jmp inicio

;----------------------- Validaciones de comandos -----------------------------
;------------------------------------------------------------------------------
validar:
		mov ax,[buffer]	
		cmp [M_mas],ax
	     	je MemMas
		cmp [m_mas],ax
		je MemMas
		cmp [M_menos],ax
	        je MemMenos
		cmp [m_menos],ax
		je MemMenos
		cmp [MR],ax
	        je MemMostrar
		cmp [mr],ax
	        je MemMostrar
		cmp [MC],ax
	        je MemBorrar
		cmp [mc],ax
	        je MemBorrar
		cmp [OFF],ax
	        je salir
		cmp [off],ax
	        je salir
	
		mov eax,[buffer]
		cmp [HELP],eax
	        je menuHelp
		mov eax,[buffer]
		cmp [help],eax
	        je menuHelp
		ret
	
;------------------------- Operaciones de memoria -----------------------------
;------------------------------------------------------------------------------
MemMas:
		
		FLD dword [memoria]
		FADD dword [resultado]
		FSTP dword [memoria]
		mov edx,lenRespuestamas
		mov ecx,msgRespuestamas
		call escribir
		call inicio
		
MemMenos:	
		FLD dword [memoria]
		FSUB dword [resultado]
		FSTP dword [memoria]
		mov edx,lenRespuestamenos
		mov ecx,msgRespuestamenos
		call escribir
		call inicio
	
MemMostrar:
		mov edx,lenRespuestamostrar
		mov ecx,msgRespuestamostrar
		call escribir

		FLD dword [memoria]
		call concluir
		call inicio
MemBorrar:
		FLD dword [memoria]
		FSUB dword [memoria]
		FSTP dword [memoria]
		mov edx,lenRespuestaborrar
		mov ecx,msgRespuestaborrar
		call escribir
		call inicio

menuHelp:					; Impresión Ayuda
		mov ecx,msgHelp
		mov edx,lenHelp
		call escribir
		call inicio

;;-----------Funciones básicas para  leer, escribir & salir------
;;---------------------------------------------------------------
escribir:
	mov eax,4
	mov ebx,1
	int 80h
	ret
leer:	
	mov eax,3
	mov ebx,0
	int 80h
	ret
salir:
	;Imprimimos el enter antes de salir

	mov ecx, msgEnter
	mov edx, lenEnter
	call escribir
	

	mov ebx,0
	mov eax,1
	int 80h
;;---------------------------------------------------------------

