org 100h

numero macro num ;Macro que se encarga de mostrar la ubicacion del raton
 mov ax,num 
 mov bl,100d
 div bl 
 mov dl,al 
 add dl,30h 
 push ax 
 mov ah,02h 
 int 21h 
 pop ax 
 shr ax,8 
 mov bl,10d
 div bl
 mov dl,al
 add dl,30h
 push ax
 mov ah,02h
 int 21h
 pop ax
 shr ax,8 
 mov dl,al
 add dl,30h
 mov ah,02h
 int 21h
endm
jmp eti0
;Zona de declaracion de Cadenas e Identificadores creados por el usuario (variables)
cad db 'Error, archivo no encontrado!...presione una tecla para terminar.$' 
filename db "C:\IMA.bmp" ;Unidad Logica, Ruta, Nombre y Extension del archivo de imagen a utilizar
handle dw ? ;DW=Define Word, para almacenar valores entre 0 y 65535, o sea 16 bits
col dw 0 ;COL=0
ren dw 479 ;REN=479d
buffer db ? ;DB=Define Byte, para almacenar valores entre 0 y 255, o sea 8 bits
colo db ? ; ? = Valor NO definido de inicio
;Variables necesarias para poder pintar, y poder mantener la ubicacion
col1 dw ?
ren1 dw ?
col2 dw ?
ren2 dw ?
color db 0
;ren dw ?
bot dw ?
c db ?
r db ?
;**************************************************************************************************************************
eti0:
mov ah,3dh ;Funcion 3DH, abre un archivo existente
mov al,0 ;AL=Modos de Acceso, 0=Solo Lectura, 1=Escritura, 2=Lectura/Escritura
 mov dx,offset filename ;DX=Direccion de la cadena de RUTA
 int 21h ;INT 21H función 3DH, abre un archivo. Esta funcion altera la bandera CF (Carry 
;Flag), si el archivo se pudo abrir sin error CF=0, y en AX esta el Manejador de Archivo
;(Handle), caso contrario CF=1, y en AX esta el codigo de error
 jc err ;Si hay error, salta a la etiqueta ERR
 mov handle,ax ;Caso contrario HANDLE=Manejador de Archivo
;************************************************************************************************************************* 
 mov cx,118d ;Se prepara ciclo de 118 vueltas (Para leer archivo en formato BMP)
eti1:
 push cx
 mov ah,3fh ;3FH=Leer del archivo
 mov bx,handle
 mov dx,offset buffer
 mov cx,1 ;CX=Numero de Bytes a leer
 int 21h ;INT 21H funcion 3FH, leer del archivo
 pop cx
 loop eti1
;*************************************************************************************************************************
 mov ah,00h ;Funcion 00H para la INT 10H (Resolucion de Pantalla)
 mov al,18d ;AL=Modo de despliegue o resolución, 18 = 640x480 a 16 colores
 int 10h ;INT 10H funcion 00H, inicializar resolucion
 ;***********************************************************************************************************************
eti2: 
 mov ah,3fh ;3FH=Leer del archivo
 mov bx,handle
 mov dx,offset buffer
 mov cx,1
 int 21h ;INT 21H funcion 3FH, leer del archivo. En BUFFER se almacenaran los datos leidos
 
 mov al,buffer ;AL=BUFFER, en los 4 bits superiores esta el color de un PRIMER Pixel
 and al,11110000b
 ror al,4
 mov colo,al ;COLO=Color de un PRIMER Pixel
 mov ah,0ch ;Funcion 0CH para despliegue de un solo PIXEL con atributos
 mov al,colo ;AL=Atributos del Pixel
 mov cx,col ;CX=Columna de despliegue del PixelInstituto Tecnológico de Durango Lenguajes de Interfaz 
 mov dx,ren ;DX=Renglon de desplieguie del Pixel
 int 10h ;INT 10H funcion 0CH, pinta Pixel en coordenadas CX, DX
 
 mov al,buffer ;AL=BUFFER, en los 4 bits inferiores esta el color de un SEGUNDO Pixel
 and al,00001111b
 mov colo,al ;COLO=Color de un SEGUNDO Pixel
 inc col
 mov ah,0ch ;Funcion 0CH para despliegue de un solo PIXEL con atributos
 mov al,colo ;AL=Atributos del Pixel
 mov cx,col ;CX=Columna de despliegue del Pixel
 mov dx,ren ;DX=Renglon de desplieguie del Pixel
 int 10h ;INT 10H funcion 0CH, pinta Pixel en coordenadas CX, DX
 inc col ;Se debe desplegar otro Pixel para dar FORMATO a la imagen
 mov ah,0ch ;Funcion 0CH para despliegue de un solo PIXEL con atributos
 mov al,colo ;AL=Atributos del Pixel
 mov cx,col ;CX=Columna de despliegue del Pixel
 mov dx,ren ;DX=Renglon de desplieguie del Pixel
 int 10h ;INT 10H funcion 0CH, pinta Pixel en coordenadas CX, DX
 
 cmp col,639d
 jbe eti2 ;JBE=Jump if Below or Equal (salta si esta abajo o si es igual)
 
 mov col,0
 dec ren
 cmp ren,-1 ;Se compara con -1 para llegar hasta el ultimo renglon, que es el CERO
 jne eti2 ;JNE=Jump if Not Equal (salta si no es igual)
 ;*********************************************************************************************************************** 
 ; Aqui iniciara el proceso para poder validar areas y darle vida a todo esto
 ;mov ah,07h
 jmp inicio
 cadS db 'SALIR$'
inicio:
mov ah,00h
mov al,18d
;int 10h 
mov c,37d
mov r,11d
call pos
mov ah,09h
lea dx,cadS
int 21h
mov ax,1d
int 33h
eti3:
mov ax,3d
int 33h
mov col,cx
mov ren,dx
mov col1,cx
mov ren1,dx
mov bot,bx
mov c,65d
mov r,3d
call pos
numero col
mov ah,02h
mov dl,' ' ;Mover a DL un espacio en blanco
int 21h
numero ren
cmp bot,1d
jne eti3
cmp col,297d
jb etiAT ;JB=Jump if Below (Brinca si esta abajo)
cmp col,334d
ja etiAT ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,175d
jb etiAT
cmp ren,186d
ja etiAT
jmp etiext
;Valicion de area de dibujo
etiAT:
cmp ren,450d
ja etiAC ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,30d
jb etiAC ;JB=Jump if Below (Brinca si esta abajo)
cmp col,110d
jb etiAC
jmp eti4
etiAC:; Area de validacion de todos los colores
;Validacion para color negro
cmp col,10d
jb etiC1 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,55d
ja eti3 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,215d
jb etiC1
cmp ren,244d
ja etiC1
mov color,0d; Se asigna color Negro
etiC1:
cmp col,55d
jb etiC2 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,100d
ja etiC2 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,215d
jb etiC2
cmp ren,244d
ja etiC2
mov color,1d; Se asigna color Negro
etiC2:
cmp col,10d
jb etiC3 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,55d
ja etiC3 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,244d
jb etiC3
cmp ren,273d
ja etiC3
mov color,2d; Se asigna color Negro
etiC3:
cmp col,55d
jb etiC4 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,100d
ja etiC4 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,244d
jb etiC4
cmp ren,273d
ja etiC4
mov color,3d; Se asigna color Negro
etiC4:
cmp col,10d
jb etiC5 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,55d
ja etiC5 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,273d
jb etiC5
cmp ren,302d
ja etiC5
mov color,4d; Se asigna color Negro
etiC5:
cmp col,55d
jb etiC6 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,100d
ja etiC6 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,273d
jb etiC6
cmp ren,302d
ja etiC6
mov color,5d; Se asigna color Negro
etiC6:
cmp col,10d
jb etiC7 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,55d
ja etiC7 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,302d
jb etiC7
cmp ren,331d
ja etiC7
mov color,6d; Se asigna color Negro
etiC7:
cmp col,55d
jb etiC8 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,100d
ja etiC8 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,331d
jb etiC8
cmp ren,360d
ja etiC8
mov color,7d; Se asigna color Negro
etiC8:
cmp col,10d
jb eti3 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,55d
ja eti3 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,360d
jb eti3
cmp ren,389d
ja eti3
mov color,8d; Se asigna color Negro
jmp eti3
etiExt:
mov ah,00h
mov al,3d
int 10h
int 20h
eti4:
mov col,cx
mov ren,dx
call pos
numero col
mov ah,02h
mov dl,' ' ;Almacena en DL un espacio en blanco
int 21h ;Despliega un espacio en blanco
numero ren
mov ax,3d
int 33h
cmp bx,2d
jne eti4
;Empieza la validacion del area de dibujo
cmp ren,450d
ja eti4 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,30d
jb eti4 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,110d
jb eti4
;Termina la area de validado de area de dibujo
mov col2,cx
mov ren2,dx


mov cx,col1
mov dx,col2
cmp cx,dx
ja etiRC
jmp etiCR
etiRC:
    mov col1,dx
    mov col2,cx
etiCR:
    mov cx,ren1
    mov dx,ren2
    cmp cx,dx
    ja etiRR 
    jmp etiFV
etiRR:
    mov ren1,dx
    mov ren2,cx
etiFV:
mov ax,2d
int 33h
call cuadro
call repintar
mov ax,1d
int 33h
 jmp eti3
 
mov ah,07h
int 21h

;***********************************************************************************************************************
err: ;Se llega hasta aqui solo si hay error en la lectura del archivo
 mov ah,09h
 lea dx,cad
 int 21h ;Despliega cad
 mov ah,07h
 int 21h ;Espera a que se oprima tecla
 int 20h ;Fin del Programa (Cuando NO se carga la imagen)

;***********************************************************************************************************************
; Procedimiento que nos devuelve la posicion del cursor
pos proc
 mov ah,02h
 mov dl,c
 mov dh,r
 mov bh,0d
 int 10h
 ret
endp
;***********************************************************************************************************************
; Procedimiento necesario para poder dibujar el cuadrado
cuadro proc
 mov cx,col1
 mov dx,ren1
 eti5: ;Inicia proceso para dibujar linea superior horizontal
 mov ah,0ch
 mov al,color
 int 10h
 inc cx
 cmp cx,col2
 jbe eti5 ;JBE=Jump if Below or Equal (Salta si esta abajo, o si es Igual)
 
 mov cx,col1
 mov dx,ren2
 eti6: ;Inicia proceso para dibujar linea inferior horizontal
 mov ah,0ch
 mov al,color
 int 10h
 inc cx
 cmp cx,col2
 jbe eti6
 
 mov cx,col1
 mov dx,ren1
 eti7: ;Inicia proceso para dibujar linea izquierda vertical
 mov ah,0ch
 mov al,color
 int 10h
 inc dx
 cmp dx,ren2
 jbe eti7
 
 mov cx,col2
 mov dx,ren1
 eti8: ;Inicia proceso para dibujar linea derecha vertical
 mov ah,0ch
 mov al,color
 int 10h
 inc dx
 cmp dx,ren2
 jbe eti8
ret
endp
repintar proc
mov c,37d
mov r,11d
call pos
mov ah,09h
lea dx,cadS
int 21h
mov ax,1d
int 33h
ret
endp