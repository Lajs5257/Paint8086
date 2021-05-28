org 100h

numero macro num ;;Macro que se encarga de mostrar la ubicacion del raton
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
 shr ax,8d 
 mov dl,al
 add dl,30h
 mov ah,02h
 int 21h
endm
; Dibuja indicaciones para uso del programa
texto macro cad
mov c,2d
mov r,27d
call pos
mov ah,09h
lea dx,cad
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

;Variable que almacena el color
color db 0

herra db 0 
; Herramientas
; 0 Sin seleccionar
; 1 Lapiz
; 2 Goma
; 3 Spray
; 4 Crayola
; 5 Brocha
; 6 barrica
; 7 Linea
; 8 Rectangulo orillas
; 9 Rectangulo relleno

; Declaracion de textos para informar al usuario
 cad0 db '-> Seleccione una herramienta                               $'
 cad1 db '-> Lapiz seleccionado: Use clic izquierdo para dibujar      $'
 cad2 db '-> Goma seleccionada: Use clic izquierdo para borrar        $'
 cad3 db '-> Spray seleccionado: Use clic izquierdo para dibujar      $'
 cad4 db '-> Crayola seleccionada: Use clic izquierdo para dibujar    $'
 cad5 db '-> Brocha seleccionada: Use clic izquierdo para dibujar     $'
 cad6 db '-> Barril selecciondo: Use clic izquierdo para rellenar     $'
 cad7 db '-> Linea seleccionada: Clic izquiedo marca punto inicial    $'
 cad71 db '-> Linea seleccionada: En espera de derecho para punto final$'
 cad8 db '-> Cuadro seleccionado: Clic izquiedo marca punto inicial   $'
 cad9 db '-> Cuadro relleo seleccionado: Clic izquiedo par iniciar    $'
 cad10 db '-> Seleccione una herramienta$'

tam db 0
;Tamaños de lapiz
; 0 Tamaño normal
; 1 Tamaño mediano
; 2 Tamaño grande

;ren dw ?
bot dw ?
c db ?
r db ?
cT db ?
rT db ?
;**************
eti0:
mov ah,3dh ;Funcion 3DH, abre un archivo existente
mov al,0 ;AL=Modos de Acceso, 0=Solo Lectura, 1=Escritura, 2=Lectura/Escritura
 mov dx,offset filename ;DX=Direccion de la cadena de RUTA
 int 21h ;INT 21H función 3DH, abre un archivo. Esta funcion altera la bandera CF (Carry 
;Flag), si el archivo se pudo abrir sin error CF=0, y en AX esta el Manejador de Archivo
;(Handle), caso contrario CF=1, y en AX esta el codigo de error
 jc err ;Si hay error, salta a la etiqueta ERR
 mov handle,ax ;Caso contrario HANDLE=Manejador de Archivo
;*************** 
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
;***************
 mov ah,00h ;Funcion 00H para la INT 10H (Resolucion de Pantalla)
 mov al,18d ;AL=Modo de despliegue o resolución, 18 = 640x480 a 16 colores
 int 10h ;INT 10H funcion 00H, inicializar resolucion
 ;***************
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
 ;*************** 
 ; Aqui iniciara el proceso para poder validar areas y darle vida a todo esto
 ;mov ah,07h
 jmp inicio

inicio:
mov ah,00h
mov al,18d 
texto cad0
mov c,65d
mov r,27d
call pos
call ColFal

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
mov c,70d
mov r,27d
call pos
numero col
mov ah,02h
mov dl,' ' ;Mover a DL un espacio en blanco
int 21h
numero ren
cmp bot,1d
jne eti3
;Validacion salir
cmp col,588d
jb etiAT ;JB=Jump if Below (Brinca si esta abajo)
cmp col,637d
ja etiAT ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,1d
jb etiAT
cmp ren,26d
ja etiAT
jmp etiext
;***************
;Validacion de area de dibujo
etiAT:
cmp col,150d
jb etiAH ;JB=Jump if Below (Brinca si esta abajo)
cmp col,618d
ja etiAH ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,53d
jb etiAH ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,397d
ja etiAH ;JA=Jmp if Above (Brinca si esta arriba)
;Mandar a area de trabajo correspondiente
etiH0:
cmp herra,0d
jne etiH1
etiH1:
cmp herra,1d
jne etiH2
call lapiz
jmp eti3
etiH2:
cmp herra,2d
jne etiH3
call goma
jmp eti3
etiH3:
cmp herra,3d
jne etiH4
call spray
jmp eti3
etiH4:
cmp herra,4d
jne etiH5
etiH5:
cmp herra,5d
jne etiH6
etiH6:
cmp herra,6d
jne etiH7
call Barril
jmp eti3
etiH7:
cmp herra,7d
jne etiH8
etiH8:
cmp herra,8d
jne etiH9
jmp eti4
etiH9:
cmp herra,9d
jne eti3
jmp eti4
;comparaciones 
etiAH:
;Validacion de area para herramienta de lapiz
cmp col,15d
jb etiAH2 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,45d
ja etiAH2 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,78d
jb etiAH2 ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,108d
ja etiAH2 ;JA=Jmp if Above (Brinca si esta arriba)
mov herra,1d
texto cad1
jmp eti3

etiAH2:
;Validacion de area para herramienta de goma
cmp col,54d
jb etiAH3 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,84d
ja etiAH3 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,78d
jb etiAH3 ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,108d
ja etiAH3 ;JA=Jmp if Above (Brinca si esta arriba)
mov herra,2d
texto cad2
jmp eti3

etiAH3:
;Validacion de area para herramienta de spray
cmp col,91d
jb etiAH4 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,122d
ja etiAH4 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,78d
jb etiAH4 ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,108d
ja etiAH4 ;JA=Jmp if Above (Brinca si esta arriba)
mov herra,3d
texto cad3
jmp eti3

etiAH4:
;Validacion de area para herramienta de crayola
cmp col,15d
jb etiAH5 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,45d
ja etiAH5 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,117d
jb etiAH5 ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,148d
ja etiAH5 ;JA=Jmp if Above (Brinca si esta arriba)
mov herra,4d
texto cad4
jmp eti3
etiAH5:
;Validacion de area para herramienta de brocha
cmp col,53d
jb etiAH6 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,83d
ja etiAH6 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,117d
jb etiAH6 ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,148d
ja etiAH6 ;JA=Jmp if Above (Brinca si esta arriba)
mov herra,5d
texto cad5
jmp eti3
etiAH6:
;Validacion de area para herramienta de barril
cmp col,91d
jb etiAH7 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,121d
ja etiAH7 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,117d
jb etiAH7 ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,148d
ja etiAH7 ;JA=Jmp if Above (Brinca si esta arriba)
mov herra,6d
texto cad6
jmp eti3
etiAH7:
;Validacion de area para herramienta de linea
cmp col,15d
jb etiAH8 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,45d
ja etiAH8 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,155d
jb etiAH8 ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,185d
ja etiAH8 ;JA=Jmp if Above (Brinca si esta arriba)
mov herra,7d
texto cad7
jmp eti3
;Valiacion de area para herramienta rectangulo contorno
etiAH8:
cmp col,54d
jb etiAH9 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,85d
ja etiAH9 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,155d
jb etiAH9 ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,185d
ja etiAH9 ;JA=Jmp if Above (Brinca si esta arriba)
mov herra,8d
texto cad8
jmp eti3
;Valiacion de area para herramienta rectangulo relleno
etiAH9:
cmp col,91d
jb etiAC ;JB=Jump if Below (Brinca si esta abajo)
cmp col,121d
ja etiAC ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,155d
jb etiAC ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,185d
ja etiAC ;JA=Jmp if Above (Brinca si esta arriba)
mov herra,9d
texto cad9
jmp eti3
etiAC:
;***************
; Area de validacion de todos los colores
;*******Validacion para color negro********+++
 
cmp col,15d
jb etiC1 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,35d
ja etiC1 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,242d
jb etiC1
cmp ren,262d
ja etiC1
mov color,0d ; Se asigna color negro
call ColSel 
jmp eti3
etiC1: ;*******************   


cmp col,43d
jb etiC2 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,63d
ja etiC2 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,242d
jb etiC2
cmp ren,262d
ja etiC2  
mov color,7d ; Se asigna color Gris
call ColSel
jmp eti3
etiC2: 


cmp col,71d
jb etiC3 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,91d
ja etiC3 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,244d
jb etiC3
cmp ren,264d
ja etiC3
mov color,12d ; Se asigna color Rojo bajo
call ColSel
jmp eti3
etiC3: 


cmp col,96d
jb etiC4 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,116d
ja etiC4 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,244d
jb etiC4
cmp ren,264d
ja etiC4
mov color,4d ; Se asigna color Rojo fuerte
call ColSel
jmp eti3
etiC4: 


cmp col,15d
jb etiC5 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,35d
ja etiC5 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,273d
jb etiC5
cmp ren,293d
ja etiC5
mov color,6d ; Se asigna color amarillo fuerte
call ColSel
jmp eti3
etiC5: 


cmp col,43d
jb etiC6 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,63d
ja etiC6 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,273d
jb etiC6
cmp ren,293d
ja etiC6
mov color,10d ; Se asigna color verde
call ColSel
jmp eti3
etiC6:


cmp col,71d
jb etiC7 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,91d
ja etiC7 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,273d
jb etiC7
cmp ren,293d
ja etiC7
mov color,15d ; Se asigna color blanco
call ColSel
jmp eti3
etiC7: 


cmp col,99d
jb etiC8 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,119d
ja etiC8 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,273d
jb etiC8
cmp ren,293d
ja etiC8
mov color,14d ; Se asigna color amarillo bajo
call ColSel
jmp eti3
etiC8: 

cmp col,15d
jb etiC9 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,35d
ja etiC9 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,303d
jb etiC9
cmp ren,323d
ja etiC9
mov color,1d ; Se asigna color azul fuerte
call ColSel
jmp eti3
etiC9:   


cmp col,43d
jb etiC10 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,63d
ja etiC10 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,303d
jb etiC10
cmp ren,323d
ja etiC10
mov color,9d ; Se asigna color azul medio 
call ColSel
jmp eti3
etiC10:


cmp col,71d
jb etiC11 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,91d
ja etiC11 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,303d
jb etiC11
cmp ren,323d
ja etiC11
mov color,5d ; Se asigna color morado fuerte 
call ColSel
jmp eti3
etiC11:    


cmp col,98d
jb etiC12 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,118d
ja etiC12 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,303d
jb etiC12
cmp ren,323d
ja etiC12
mov color,13d ; Se asigna color morado bajito
call ColSel
jmp eti3
etiC12: 


cmp col,15d
jb etiC13 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,35d
ja etiC13 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,335d
jb etiC13
cmp ren,355d
ja etiC13
mov color,3d ; Se asigna color azul cielo 
call ColSel
jmp eti3
etiC13: 


cmp col,42d
jb etiC14 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,62d
ja etiC14 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,335d
jb etiC14
cmp ren,355d
ja etiC14
mov color,11d ; Se asigna color azul cian 
call ColSel
jmp eti3

etiC14:
cmp col,71d
jb etiC15 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,91d
ja etiC15 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,335d
jb etiC15
cmp ren,355d
ja etiC15
mov color,8d ; Se asigna color gris oscuro
call ColSel
jmp eti3

etiC15:

cmp col,96d
jb eti3 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,117d
ja eti3 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,335d
jb eti3
cmp ren,355d
ja eti3
mov color,2d ; Se asigna color verde 
call ColSel
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
cmp col,150d
jb eti4 ;JB=Jump if Below (Brinca si esta abajo)
cmp col,618d
ja eti4 ;JA=Jmp if Above (Brinca si esta arriba)
cmp ren,53d
jb eti4 ;JB=Jump if Below (Brinca si esta abajo)
cmp ren,397d
ja eti4 ;JA=Jmp if Above (Brinca si esta arriba)
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
cmp herra,8
jne etiCRe
call cuadro
jmp etirepin
etiCRe:
call cuadroRe
etiRepin:
mov ax,1d
int 33h
 jmp eti3
 
mov ah,07h
int 21h

;***************
err: ;Se llega hasta aqui solo si hay error en la lectura del archivo
 mov ah,09h
 lea dx,cad
 int 21h ;Despliega cad
 mov ah,07h
 int 21h ;Espera a que se oprima tecla
 int 20h ;Fin del Programa (Cuando NO se carga la imagen)

;***************
; Procedimiento que nos devuelve la posicion del cursor
pos proc
 mov ah,02h
 mov dl,c
 mov dh,r
 mov bh,0d
 int 10h
 ret
endp
;***************
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

ColSel proc
 mov dx,378d 
eti9:
 mov cx,90d
eti10: 
 mov ah,0ch
 mov al,color
 int 10h
 inc cx
 cmp cx,111d
 jbe eti10 ;JBE=Jump if Below or Equal (Salta si esta abajo, o si es Igual)
 inc dx
 cmp dx,398d
 jbe eti9
ret
endp
; Pinta el colores de la paleta por que no se pudo igualar el color deseado
ColFal proc
 mov dx,335d 
eti11:
 mov cx,96d
eti12: 
 mov ah,0ch
 mov al,2d
 int 10h
 inc cx
 cmp cx,117d
 jbe eti12 ;JBE=Jump if Below or Equal (Salta si esta abajo, o si es Igual)
 inc dx
 cmp dx,355d
 jbe eti11
ret
endp
; Herramienta de lapiz pinta un pixel 
lapiz proc
 ;Apaga el raton
 mov ax,2d
 int 33h
 ; Pinta pixel
 mov ah,0Ch ;Funcion 12d=0Ch para pintar o desplegar PIXEL
 mov al,color ;AL=Atributos de color, parte baja: 1010b=10d=Color Verde (vea Paleta de Color)
 mov cx,col1 ;Cx=Columna donde se despliega PIXEL (empieza desde cero)
 mov dx,ren1 ;Dx=Renglon donde se despliega PIXEL (empieza desde cero)
 int 10h ;INT 10H funcion 0CH, despliega PIXEL de color en posicion CX (Columna), DX (Renglon)
 ;prende el raton
 mov ax,1d
 int 33h
endm 
ret
endp
; herramienta de goma pinta un pixel de color blanco
goma proc
 ;Apaga el raton
 mov ax,2d
 int 33h
 mov ah,0Ch ;Funcion 12d=0Ch para pintar o desplegar PIXEL
 mov al,15d ;AL=Atributos de color, parte baja: 1010b=10d=Color Verde (vea Paleta de Color)
 mov cx,col1 ;Cx=Columna donde se despliega PIXEL (empieza desde cero)
 mov dx,ren1 ;Dx=Renglon donde se despliega PIXEL (empieza desde cero)
 int 10h ;INT 10H funcion 0CH, despliega PIXEL de color en posicion CX (Columna), DX (Renglon)
 ;prende el raton
 mov ax,1d
 int 33h
endm 
ret
endp
; Herramienta barril pinta toda el area de dibujo del color seleccionado
Barril proc 
;Apaga el raton
 mov ax,2d
 int 33h 
 mov dx,51d 
eti13:
 mov cx,150d
eti14: 
 mov ah,0ch
 mov al,color
 int 10h
 inc cx
 cmp cx,620d
 jbe eti14 ;JBE=Jump if Below or Equal (Salta si esta abajo, o si es Igual)
 inc dx
 cmp dx,397d
 jbe eti13
 ;prende el raton
 mov ax,1d
 int 33h
ret
endp
; procedimiento de cuadrado relleno
CuadroRe proc ;Se encargo de pintar el cuadrado que va relleno
;Apaga el raton
 mov ax,2d
 int 33h 
 mov dx,ren1
eti15:
 mov cx,col1
eti16:
 mov ah,0ch
 mov al,color
 int 10h
 inc cx
 cmp cx,col2
 jbe eti16 ;JBE=Jump if Below or Equal (Salta si esta abajo, o si es Igual)
 inc dx
 cmp dx,ren2
 jbe eti15
 ;prende el raton
 mov ax,1d
 int 33h
ret
endp
; procedimiento de cuadrado relleno
spray proc
 ;Apaga el raton
 mov bx,0
 mov ax,2d
 int 33h
 mov cx,col
 mov dx,ren
 inc cx
 call VaCor; Mandamos validar el area donde ira el pixel y tambien lo pintamos
 add cx,5
 add dx,10
 call VaCor; Mandamos validar el area donde ira el pixel y tambien lo pintamos
 inc cx
 sub dx,5
 call VaCor; Mandamos validar el area donde ira el pixel y tambien lo pintamos
 add cx,6
 add dx,10
 call VaCor; Mandamos validar el area donde ira el pixel y tambien lo pintamos
 sub cx,15
 inc dx
 call VaCor; Mandamos validar el area donde ira el pixel y tambien lo pintamos
 add cx,2
 sub dx,1
 call VaCor; Mandamos validar el area donde ira el pixel y tambien lo pintamos
 inc cx
 sub dx,2
 call VaCor; Mandamos validar el area donde ira el pixel y tambien lo pintamos
;prende el raton
 mov ax,1d
 int 33h
ret
endp
;Procedimiento que valida el area en que se pondra el pixel, una vez que sea validad la pintara
VaCor proc
cmp cx,150d
jb etiRCol ;JB=Jump if Below (Brinca si esta abajo)
cmp cx,618d
ja etiRCol ;JA=Jmp if Above (Brinca si esta arriba)
etiVR:
cmp dx,53d
jb etiRRen ;JB=Jump if Below (Brinca si esta abajo)
cmp dx,397d
ja etiRRen ;JA=Jmp if Above (Brinca si esta arriba)
jmp etiFinV
etiRCol:;regresa dentro de los limites
mov cx,col
jmp etiVR
etiRRen:;regresa dentro de los limites
mov dx,ren
etiFinV:
call ponpix 
ret
endp
; procedimiento que pinta el pixel del color que este seleccionado
ponpix proc
 mov ah,0Ch ;Funcion 12d=0Ch para poner PIXEL
 mov al,color ;Atributos de color, 1010b=10d=Verde
 int 10h
 ret
endp 
proc

