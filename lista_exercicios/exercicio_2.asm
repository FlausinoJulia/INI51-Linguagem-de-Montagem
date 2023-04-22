; Giovanna do Amaral Brigo - RA 21685
; Julia Flausino da Silva  - RA 21241

; lista de exercicios de INI51 - exercicio 2

.MODEL small
.STACK 100h
.DATA
    msg   db 'Quais sao as suas 3 (tres) primeiras iniciais?', 13, 10, '$'
    msg2  db 'Qtd errada de caracteres! Digite apenas 3 (tres)!', 13, 10, '$'
    dados db  10,?,20 dup(?)

.CODE
inicio:
    mov ax,@data
    mov ds,ax

    ; imprimimos a msg
    mov ah, 9
    mov dx, offset msg
    int 21h
    
    ; lemos os dados do teclado
    mov ah, 0Ah
    mov dx, offset dados
    int 21h

    mov bx, offset dados ; movemos esse dado para bx
    inc bx  
    mov cl, [bx] ; passamos o tamanho de bc para cl
    inc bx

    mov al, 3 ; movemos a qtd de carac. q podem ser digitados para al
    cmp al, cl ; comparamos se al eh igual a cl(tamanho do dado recebido)
    jne maiorOuMenor ; se os tamanhos nao forem iguais, pulamos para o proc

    ; caso os tamanhos sejam iguais, entramos no loop
    loop1: ; loop para printar os caracteres
    mov dl, 0ah
    mov ah, 02h ; pulamos uma linha
    int 21h

    ; printamos o caractere na posicao de bx
    mov dl, [bx]
    mov ah,02h
    int 21h
    
    inc bx ; incrementamos o bx
    dec cl
    jne loop1 ; se nao for igual, continuamos o loop

    skip: ; final do programa
    mov al, 0
    mov ah, 4ch
    int 21h

    maiorOuMenor proc
    mov dl, 0ah
    mov ah, 02h ; pulamos uma linha
    int 21h

    mov ah, 9
    mov dx, offset msg2 ; avisamos o usuario que a qtd digitada esta errada
    int 21h

    jne skip ; pulamos para o final do programa
    ret
    maiorOuMenor endp

end inicio