; Lista de exercicios de INI51 - 18/04/23
; Giovanna do Amaral Brigo - RA 21685
; Julia Flausino da Silva  - RA 21241

; EXERCICIO 3
; Escreva um programa para ler um dígito hexadecimal de A a F (maiúsculo) e exibi-lo em decimal na próxima linha.
; Utilize mensagens convenientes.

.MODEL small

.STACK 100h

.DATA

    mensagem  DB 'Digite o digito em hexadecimal: ', 13, 10, '$'
    erro      DB 'Digito invalido (nao esta entre A e F)!', 13, 10, '$'

.CODE

start: 

    ; aponta ds para o segmento de dados definido anteriormente
    MOV AX, @data
    MOV DS, AX                  ; ds é a regiao da memoria onde vamos ter todos os dados do programa

    MOV AH,09h                  ; prepara para printar            
    MOV DX, OFFSET mensagem     ; coloca mensagem em dx para ser printada
    INT 21h                     ; printa mensagem

    MOV AH, 01h                 ; prepara para ler um dígito e guardá-lo em al
    INT 21h                     ; lê o digito
    MOV BL, AL
    ; o caractere lido está em al

    ; vê se o caractere é menor que 'A'
    CMP BL, 41h                 ; compara o caractere com 'A'
    JB  caractereIncorreto      ; se ele for menor, o digito esta incorreto (tem que estar entre A e F)

    ; vê se o caractere é maior que 'F'
    CMP BL, 46h                 ; compara o caractere com 'F'
    JG  caractereIncorreto      ; se ele for maior, o digito esta incorreto (tem que estar entre A e F)

    ; os hexadecimais de A a F correspondem aos números de 10 a 15 em decimal
    ; então, como podemos ver, sempre vamos ter um número de dois dígitos,
    ; sendo o primeiro dígito sempre 1 e o segundo variando de 0 a 5
    ; por isso, como o 1 se mantém, o que falta é descobrir o segundo dígito

    ; quando imprimimos um valor usando a interrupção 21h, esse valor é tratado como sendo um caractere ascii
    ; por isso, vamos subtrair 11h do nosso hexadecimal lido para descobrir o numero hexadecimal correspondente
    ; aos caracteres de 0 a 5, que são os segundos dígitos possíveis
    SUB BL, 11h                 ; subtrai 11h do digito

    ; pula linha
    MOV DL, 0dh              
    MOV AH, 02h              
    INT 21h            
    MOV DL, 0Ah                 
    MOV AH, 02h          
    INT 21h      

    ; printando o hexadecimal correspondente
    ; printamos o primeiro dígito (1)
    MOV AL, 05h
    MOV DL, '1'
    INT 21H

    ; printamos o segundo dígito descoberto
    MOV DL, BL                
    INT 21H

    JMP fim ; encerramos o programa

    caractereIncorreto:
        ; pula linha
        MOV DL, 0dh              
        MOV AH, 02h              
        INT 21h            
        MOV DL, 0Ah                 
        MOV AH, 02h          
        INT 21h      

        MOV AH,09h              ; prepara para printar o que estiver em dx          
        MOV DX, OFFSET erro     ; move a mensagem de caractere invalido para dx
        INT 21h                 ; printa que o caractere é inválido

    fim: 
        MOV AH, 4Ch
        INT 21h

end start