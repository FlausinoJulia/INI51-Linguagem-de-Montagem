; Lista de exercicios de INI51 - 18/04/23
; Giovanna do Amaral Brigo - RA 21685
; Julia Flausino da Silva  - RA 21241

; EXERCICIO 1
; Escreva um programa para (a) exibir um ‘?’, (b) ler dois dígitos
; decimais cuja soma seja menor que 10 e (c) exibir sua soma na
; próxima linha.

.MODEL small
.STACK 100h
.DATA

    msg  db '?$'
    msg2 db 'A soma dos dois caracteres eh maior que dez!', 13, 10, '$'
    soma db 'A soma eh: $'

.CODE
inicio: 
    mov ax, @data
    mov ds, ax

    ; imprimimos a "?"
    mov ah, 09h
    mov dx, offset msg
    int 21h

    ; lemos o primeiro caracter
    mov ah, 01h
    int 21h
    sub al, 30h ; subtraimos 30 para pegar o decimal correspondente
    mov bl, al

    ; lemos o segundo caracter
    mov ah, 01h
    int 21h
    sub al, 30h ; subtraimos 30 para pegar o decimal correspondente

    ; somamos os dois numeros
    add bl, al

    ; verificamos se a soma eh maior que dez
    cmp bl, 0Ah
    jg  ehMaior ; se for >...

    ; se a soma for < 10
    ; pulamos uma linha
    mov dl, 0dh
    mov ah, 02h 
    int 21h
    mov dl, 0ah
    mov ah, 02h
    int 21h
    mov dl, 0dh
    mov ah, 02h 
    int 21h
    mov dl, 0ah
    mov ah, 02h
    int 21h

    mov ah, 09h ; printamos uma msg
    mov dx, offset soma
    int 21h

    ; printamos a soma
    add bl, 30h
    mov ah, 02h
    mov dl, bl
    int 21h

    jmp skip ; pulamos para o fim do programa

    ehMaior: ; avisamos o usuario que a soma eh maior
    
    ; pulamos uma linha
    mov dl, 0dh
    mov ah, 02h 
    int 21h
    mov dl, 0ah
    mov ah, 02h
    int 21h
    
    mov ah, 09h       
    mov dx, offset msg2  
    int 21h 

    skip: ; final do programa
    mov ah, 4ch
    int 21h

end inicio