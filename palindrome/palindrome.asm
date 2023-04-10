.MODEL SMALL
.STACK 100h

.DATA   

    mensagem  DB 'Digite uma palavra com ate 30 caracteres: ', 13, 10, '$'
    mensagem2 DB 'Eh palindrome!', 13, 10, '$'
    mensagem3 DB 'Nao eh palindrome!', 13, 10, '$'
    frase     DB 30,?,30 dup ('$')
    invertida DB 30,?,30 dup ('$')

.CODE 
inicio:
    mov ax, @data
    mov ds, ax 

    ; printa a mensagem "digite uma palavra com até 30 caracteres"
    mov ah,09h                ; prepara para printar uma string que fica localizada em dx
    mov dx, OFFSET mensagem   ; move a string para dx
    int 21h                   ; executa a função (printa a mensagem)

    ; lê a frase/palavra do teclado
    mov ah, 0Ah               ; prepara para ler algo do teclado
    mov dx, OFFSET frase      ; a string será colocada em frase
    int 21h                   ; executa a função (lê string do teclado e guarda em frase)

    ; pula linha
    ; 1 - volta ao inicio da linha
    mov dl, 0dh               ; o codigo de voltar para o inicio da linha é colocado em dl
    mov ah, 02h               ; modo 02h é de escrever o caractere guardado em dl (\r)
    int 21h                   ; realiza a função
    ; 2 - pula para a próxima linha
    mov dl, 0Ah               ; o código para pular linha é colocado em dl para ser printado         
    mov ah, 02h               ; modo 02h é de escrever o caractere guardado em dl (\n)
    int 21h                   ; realiza a função

    ; posiciona bx no inicio da frase
    mov bx, OFFSET frase     ; posiciona bx no endereço da frase
    inc bx                   ; pega o caractere que mostra quantas letras tem a string
    mov cl, [bx]             ; cl recebe o tamanho da string
    add bx, cx               ; bx vai para o ultimo caractere da string
    
    mov di, OFFSET invertida ; di é posicionado no endereço da string invertida
    inc di
    mov [di], cl
    inc di                ; di vai para a pos. do primeiro caractere da string invertida

    inverteString: 
        mov al, [bx]
        mov [di], al              ; dl recebe o caractere que esta em bx
        dec bx                    ; vai pro caractere anterior (decrementa bx)
        inc di
        dec cl                    ; decrementa cl, que tinha o tamanho da string inteira
        jne inverteString         ; jump if not equal -  se o cl nao for 0 a gente n terminou de printar, entao volta pro loop  

    mov bx, OFFSET frase     ; bx fica no endereço da string normal
    inc bx 
    mov cl, [bx]
    inc bx
    mov di, OFFSET invertida ; di fica no endereço da string invertida
    inc di
    inc di

    ; compara a string invertida com a string normal
    comparaStrings:
        mov dl, [di]
        mov al, [bx]
        cmp dl, al
        jne naoEhPalindrome

        inc di
        inc bx
        dec cl

        jne comparaStrings

    ; printa a mensagem "é palindrome!"
    mov ah,9                   ; prepara para printar uma string que fica localizada em dx
    mov dx, OFFSET mensagem2   ; move a string para dx
    int 21h                    ; executa a função (printa a mensagem)
    jmp fim

    naoEhPalindrome:
        mov ah,9                   ; prepara para printar uma string que fica localizada em dx
        mov dx, OFFSET mensagem3   ; move a string para dx
        int 21h                    ; executa a função (printa a mensagem)

    fim:
        ; termina o programa
        mov ah,4Ch
        int 21h

end inicio 