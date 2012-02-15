#Calculadora Polaca
========
   Practica 1.3 realizada para la materia Organizacion de computadores.

  **Por:**
   *    Esteban Arango Medina
   *    Daniel Duque Tirado
   *     Daniel Zuluaga Suarez

Esta practica fue realizada en el lenguaje *assembler* de procesadores Intel para Linux, usando el compilador NASM ([The net wide assembler](http://repo.or.cz/w/nasm.git "NASM git")).

###Instalacion NASM
 Para la instalación de NASM en las distribuciones Debian y Ubuntu basta con abrir la 'terminal' y escribir:
    
	$ sudo apt-get install nasm

###__Ejecucion__
 Para correr la Calculadora simplemente 'compilamos' *Calculadora.asm* y creamos el paquete ejecutable.
    
	nasm -f elf Calculadora.asm 
    ld Calculadora.o -o Calculadora
    ./Calculadora`
