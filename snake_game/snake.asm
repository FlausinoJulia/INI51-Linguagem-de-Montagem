; SNAKE GAME - ASSEMBLY 8086
; Danyelle Nogueira França - RA: 21232
; Julia Flausino da Silva  - RA: 21241

.MODEL small
.STACK 100h

.DATA
    ; Limites tela do jogo (200x200)
    ;tela_largura dw 0c8h        ; Largura = 200 pixels
    ;tela_altura  dw 0c8h        ; Altura  = 200 pixel
    limite_inicio dw 5
    limite_fim    dw 190

    ; CRIAR VARIAVEL PARA GUARDAR A ULTIMA CELULA DA SNAKE

    ; Labels para o MENU
    titulo db 'SNAKE GAME', '$' ; Título do jogo
    jogar  db 'J - Jogar', '$'  ; Para iniciar o jogo
    sair   db 'S - Sair', '$'   ; Para sair do jogo

    ; Labels para a tela de GAME OVER
    go_titulo db 'GAME OVER', '$' ; Título da tela de GAME OVER
    go_jogar  db 'J - Jogar novamente', '$'    ; Para iniciar o jogo
    go_sair   db 'S - Sair do jogo', '$'     ; Para sair do jogo

    ; Variáveis para desenho
    cor db ?
    inicio_x dw ?
    inicio_y dw ?
    fim_x dw ?
    fim_y dw ?

    ; Variáveis SNAKE
    tamanho_snake dw 0               ; A snake começa com apenas 1 de tamanho 
    snake_x_pos   dw 10, 1443 dup(?) ; Vetor para acompanhar as posiçães X das casinhas que a snake ocupa
    snake_y_pos   dw 10, 1443 dup(?) ; Vetor para acompanhar as posiçães Y das casinhas que a snake ocupa
    snake_novo_x  dw 10              ; Variável auxiliar para guardar a nova coordenada X da snake
    snake_novo_y  dw 10              ; Vaiável auxiliar para guardar a nova coordenada Y da snake
    ;snake_x dw 10
    ;snake_y dw 10
    ;snake_casa_anterior_x dw 10
    ;snake_casa_anterior_y dw 10

    ; Variável que define o tamanho dos quadradinhos a serem desenhados
    pixel_dimensao dw 5

    ; Variáveis MAÇÃ
    num_aleatorio dw 1 ; Para gerar a posicao da maça
    maca_x dw 5      
    maca_y dw 5
    seed dw 0          ; Variável para a semente do gerador de números aleatórios.

    houveColisao dw 0  ; Variável para verificar se tem colisao, funciona como um bool (0 - falso; 1 - verdadeiro)
    pegouMaca    dw 0
    tecla db 'd'       ; W - cima; S - baixo; A - esquerda; D - direita

.CODE

inicio:
  
    ; Configuração dos segmentos de dados
    mov  ax, @data
    mov  ds, ax

    ; Habilita o modo gráfico VGA
    mov  ah,00h
    mov  al, 13h
    int  10h
   
    call desenha_menu
    call fim

    inicia_jogo proc 

        call limpa_tela     ; Limpando a tela para desenhar arena
        mov tecla, 'd'
        mov houveColisao, 0 ; Não houve colisão ainda

        call desenha_arena  ; Desenhando os limites do jogo

        ; Resetando variaveis SNAKE
        
        mov snake_x_pos[0], 10  ; O primeiro pixel da snake fica na coluna 10
        mov snake_y_pos[0], 10  ; O primeiro pixel da snake fica na linha 10
        mov tamanho_snake, 0
        ;mov snake_x_pos[bx], 10 ; O último pixel da snake fica na posi
        ;mov snake_y_pos[bx], 10
        mov snake_novo_x, 10    ; A snake ainda não andou, então resetamos as variáveis auxiliares de movimento
        mov snake_novo_y, 10    ; A snake ainda não andou, então resetamos as vairáveis auxiliares de movimento
        call desenha_snake      ; Desenhando a snake nas coordenadas iniciais

        call desenha_maca   ; Desenhando a maça
        call executa_jogo   ; Inicia loop do jogo
        ret

    inicia_jogo endp

    desenha_maca proc
        push cx
        push ax
        push bx

        gerar_pos:
            ; Gerando posição maça x
            ; Gerando numero aleatorio 1 a 38
            call srand 
            mov cx, 38
            call rand
            mov num_aleatorio, ax

            ; Multiplicando numero aleatorio por 5
            mov ax, num_aleatorio
            mov cx, 5
            mul cx ; AX = AX * 5
            mov maca_x, ax

            ; Gerando pos. maça y
            ; Gerando número aleatório de 1 a 38
            call srand
            mov cx, 38
            call rand
            mov num_aleatorio, ax

            ; Multiplicando numero aleatorio por 5
            mov ax, num_aleatorio
            mov cx, 5
            mul cx ; AX = AX * 5
            mov maca_y, ax

            ; Verifica se essa pos é valida
            mov ah, 0dh ; Para ler um pixel
            mov bh, 00h ; Page number = 0 
            mov cx, maca_x   ; Coluna = AX
            mov dx, maca_y   ; Linha  = AX
            int 10h     ; Verifica o pixel (a cor do pixel é armazenada em AL)

            cmp al, 00h     ; Vê se o espaço tá vazio (cor = preto)
            je print_maca   ; Se ta vazio, desenha
            jmp gerar_pos   ; Se não, gera nova pos. para a maça

        print_maca:
            ; Desenhando maca
            mov cor, 04h

            mov ax, maca_x
            mov inicio_x, ax  

            mov bx, maca_x
            add bx, pixel_dimensao
            mov fim_x, bx      

            mov ax, maca_y          
            mov inicio_y, ax

            mov bx, maca_y
            add bx, pixel_dimensao
            mov fim_y, bx
            call desenha

            pop bx
            pop ax 
            pop cx

            ret

    desenha_maca endp
    
    ; Inicializamos a semente do gerador de números aleatórios com base no tempo atual.
    srand proc          
        mov  ah,2
        int  1ah
        add  dx,cx
        mov  seed,dx
        ret
    srand endp

    ; Calculamos um número aleatório entre 1 e um limite N fornecido.
    rand proc           
        mov  ax,seed
        mov  dx,13
        mul  dx
        add  ax,1313
        adc  dx,0
        div  cx

        ; se cx for zero, não há espaço livre
        mov  ax,dx
        mov  seed,ax
        inc  ax
        ret 

    rand endp
        
    executa_jogo proc ; Loop do jogo

        game_loop:
            call delay              ; Espera um tempo (ajusta velocidade da snake)
            call verifica_teclado   ; Vê se o usuário pressionou alguma tecla
            call move_snake
            jmp  game_loop          ; Mantém o loop do jogo

        ret

    executa_jogo endp

    ; Procedimento para delay, introduz um atraso no jogo
    delay PROC          
                  mov  cx,1
                  mov  ax,0
        delay_loop:     
                  sub  ax,1
                  test ax,ax
                  jnz  delay_loop
                  loop delay_loop
                  ret
    delay ENDP 

    verifica_colisao_cauda proc

        push cx
        push bx
        push si

        cmp tamanho_snake, 0
        je verifica_colisao_cauda_ret

        mov cx, tamanho_snake   ; contador
        mov si, tamanho_snake   ; indice para acessar o vetor

        verificando_colisao_cauda:
            mov bx, snake_x_pos[si] ; coordenada x que vai ser comparada com a coordenada da cabeça da snake
            cmp snake_novo_x, bx
            je verifica_y
            jmp continua_loop

            verifica_y:
            mov bx, snake_y_pos[si] ; coordenada x que vai ser comparada com a coordenada da cabeça da snake
            cmp snake_novo_y, bx
            je colidiu_com_cauda
            
            continua_loop:
            dec si
            dec cx
        loop verificando_colisao_cauda

        verifica_colisao_cauda_ret:
            pop si
            pop bx
            pop cx
            ret

        colidiu_com_cauda:
            mov houveColisao, 1
            jmp verifica_colisao_cauda_ret

    verifica_colisao_cauda endp

    verifica_colisao_parede proc

        cmp tecla, 'd'
        je verifica_direita

        cmp tecla, 'a'
        je verifica_esquerda

        cmp tecla, 'w'
        je verifica_cima

        cmp tecla, 's'
        je verifica_baixo

        verifica_direita:
            mov bx, limite_fim     ; Para comparar snake_x com limite_fim
            cmp snake_x_pos[0], bx ; Compara a posição da inicial da snake com limite_fim
            je  atualiza_colisao   ; Se a snake ja esta no limite da linha, ela nao pode andar para direita
            
            ; Calculando a posicao nova da snake para ver o que tem naquele quadrado
            mov ax, snake_x_pos[0]    
            add ax, pixel_dimensao  
            mov snake_novo_x, ax   ; Guardamos a possivel nova coordenada X na variável auxiliar  

            ret   ; Não houve colisão com a parede

        verifica_esquerda:
            ; checar se colidiu com  a parede
            mov bx, limite_inicio
            cmp snake_x_pos[0], bx
            je atualiza_colisao ; Se a snake ja esta no limite da linha, ela nao pode andar para esquerda  
        
            ; Calculando a posicao nova da snake
            mov ax, snake_x_pos[0] 
            sub ax, pixel_dimensao   
            mov snake_novo_x, ax   ; Guardamos a possivel nova coordenada X na variável auxiliar         
            
            ret   ; Não houve colisão

        atualiza_colisao:
            mov houveColisao, 1 ; Atualiza houve colisão para true
            ret

        verifica_cima:
        ; checar se colidiu com  a parede
            mov bx, limite_inicio
            cmp snake_y_pos[0], bx
            je atualiza_colisao    ; Se a snake ja esta no limite da linha, ela nao pode andar para cima

        ; Calculando a posicao nova da snake
            mov ax, snake_y_pos[0]
            sub ax, pixel_dimensao          
            mov snake_novo_y, ax   ; Guardamos a possivel nova coordenada Y na variável auxiliar  

            ret   ; Não houve colisão

        verifica_baixo:
        ; checar se colidiu com  a parede
            mov bx, limite_fim
            cmp snake_y_pos[0], bx
            je atualiza_colisao ; Se a snake ja esta no limite da linha, ela nao pode andar para baixo

        ; Calculando a posicao nova da snake
            mov ax, snake_y_pos[0] 
            add ax, pixel_dimensao      
            mov snake_novo_y, ax   ; Guardamos a possivel nova coordenada Y na variável auxiliar    

            ret   ; Não houve colisão

    verifica_colisao_parede endp

    atualiza_coordenadas proc ; Pega todos os 
        push dx
        ;push ax
        push cx
        push si

        mov cx, tamanho_snake   ; cx será usado como contador, determina quando o loop acaba
        cmp cx, 0 
        je  atualiza_coordenadas_ret
        mov si, tamanho_snake              ; determina qual dos pixels estamos alterando

        atualizando_coordenadas:
            ; Atualizando coordenada X
            dec si
            mov dx, snake_x_pos[si]
            ;mov ax, dx
            inc si
            mov snake_x_pos[si], dx

            ; Atualizando coordenada y
            dec si
            mov dx, snake_y_pos[si]
            ;mov ax, dx
            inc si
            mov snake_y_pos[si], dx

            dec cx
        jnz atualizando_coordenadas

        atualiza_coordenadas_ret:
        pop si
        pop cx
        ;pop ax
        pop dx
        ret

    atualiza_coordenadas endp

    verifica_colisoes proc

        call verifica_colisao_parede
        cmp houveColisao, 1
        je verifica_colisoes_ret

        call verifica_colisao_cauda
        cmp houveColisao, 1
        je verifica_colisoes_ret

        verifica_colisoes_ret:
            ret

    verifica_colisoes endp

    verifica_pegou_maca proc

        push bx
        
        mov bx, maca_x 
        cmp snake_novo_x, bx
        je verifica_maca_y
        jmp verifica_pegou_maca_ret

        verifica_maca_y:
            mov bx, maca_y
            cmp snake_novo_y, bx
            je pegou_maca
            jmp verifica_pegou_maca_ret

        pegou_maca:
            mov pegouMaca, 1

        verifica_pegou_maca_ret:
            pop bx
            ret

    verifica_pegou_maca endp

    move_snake proc ; Se esse proc é chamado, a snake PODE andar para a casa desejada (nao há colisao)

        push dx

        cmp tecla, 'd'
        je move_direita

        cmp tecla, 'a'
        je move_esquerda

        cmp tecla, 'w'
        je move_cima

        cmp tecla, 's'
        je move_baixo

        houve_colisao_1:
            call desenha_game_over

        move_direita:
            call verifica_colisoes
            cmp houveColisao, 1      ; Vê se houve colisão
            je houve_colisao_1         ; Se houve, game over

            ; Se nao colidiu, checar se pegou uma maca
            call verifica_pegou_maca
            cmp pegouMaca, 1
            je pegou_maca_x_1
            
            ; Se não pegou maça e não colidiu, a snake apenas anda (pinta nova casa de verde e pinta a última casa de preto)
            call pinta_ultima_casa_de_preto
            call atualiza_coordenadas
            mov dx, snake_novo_x
            mov snake_x_pos[0], dx          ; Atualiza o valor de snake_x (move para direita)[]
            call desenha_snake

            jmp move_snake_ret

            pegou_maca_x_1:
                jmp pegou_maca_x

        move_esquerda:
            ; checar se colidiu com a parede ou com a cauda
            call verifica_colisao_parede
            cmp houveColisao, 1      ; Vê se houve colisão
            je houve_colisao         ; Se houve, game over
            ; Se nao colidiu, checar se pegou uma maca
            call verifica_pegou_maca
            cmp pegouMaca, 1
            je pegou_maca_x
            ; Se não pegou maça e não colidiu redesenha snake (pinta nova casa de verde e pinta a última casa de preto)
            call pinta_ultima_casa_de_preto
            call atualiza_coordenadas
            mov dx, snake_novo_x
            mov snake_x_pos[0], dx          ; Atualiza o valor de snake_x (move para esquerda)
            call desenha_snake
            jmp move_snake_ret

        move_cima:
            ; checar se colidiu com a parede ou com a cauda
            call verifica_colisao_parede
            cmp houveColisao, 1      ; Vê se houve colisão
            je houve_colisao         ; Se houve, game over
            ; Se nao colidiu, checar se pegou uma maça
            call verifica_pegou_maca
            cmp pegouMaca, 1
            je pegou_maca_y
            ; Se não pegou maça e não colidiu redesenha snake (pinta nova casa de verde e pinta a última casa de preto)
            call pinta_ultima_casa_de_preto
            call atualiza_coordenadas
            mov dx, snake_novo_y
            mov snake_y_pos[0], dx          ; Atualiza o valor de snake_y (move para cima)
            call desenha_snake
            jmp move_snake_ret

        move_baixo:
            ; checar se colidiu com a parede ou com a cauda
            call verifica_colisao_parede
            cmp houveColisao, 1      ; Vê se houve colisão
            je houve_colisao         ; Se houve, game over
            ; Se nao colidiu, checar se pegou uma maca
            call verifica_pegou_maca
            cmp pegouMaca, 1
            je pegou_maca_y
            ; Se não pegou maça e não colidiu redesenha snake (pinta nova casa de verde e pinta a última casa de preto)
            call pinta_ultima_casa_de_preto
            call atualiza_coordenadas
            mov dx, snake_novo_y
            mov snake_y_pos[0], dx          ; Atualiza o valor de snake_y (move para baixo)
            call desenha_snake

            jmp move_snake_ret
       
        houve_colisao:
            call desenha_game_over
            
        pegou_maca_x:
            inc tamanho_snake
            call atualiza_coordenadas
            mov dx, snake_novo_x
            mov snake_x_pos[0], dx
            call desenha_snake
            mov pegouMaca, 0
            call desenha_maca
            jmp move_snake_ret

        pegou_maca_y:
            inc tamanho_snake
            call atualiza_coordenadas
            mov dx, snake_novo_y
            mov snake_y_pos[0], dx
            call desenha_snake
            mov pegouMaca, 0
            call desenha_maca
            jmp move_snake_ret

        move_snake_ret:
            pop dx
            ret
    move_snake endp

    pinta_ultima_casa_de_preto proc
        push ax 
        push bx
        push cx

        ; Pintando o ultimo pixel da snake de preto
        mov cor, 00h ; Cor preta

        mov si, tamanho_snake

        mov ax, snake_x_pos[si]
        mov inicio_x, ax

        mov bx, snake_x_pos[si]
        add bx, pixel_dimensao
        mov fim_x, bx      

        mov ax, snake_y_pos[si]          
        mov inicio_y, ax

        mov bx, snake_y_pos[si]
        add bx, pixel_dimensao
        mov fim_y, bx
        call desenha

        pop cx
        pop bx  ; BX volta ao valor inicial
        pop ax  ; AX volta a conter a info da nova posicao da snake
        

        ret

    pinta_ultima_casa_de_preto endp
    
    verifica_teclado proc

        ; Verificando se alguma tecla foi pressionada
        mov ah, 01h              ; Get the state of the keyboard buffer
        int 16h                 ; 01h - ZF = 0 if a key pressed; AL = ASCII character or zero if special function key
        jnz verifica_teclado_loop ; Se nenhuma tecla foi pressionada
        ;call move_snake     ; Mesmo se o usuário não apertar nenhuma tecla, movimentamos a snake
        ret

        verifica_teclado_loop:
            call ignorar_direcao_contraria
            mov tecla, al
            mov ah, 00h
            int 16h 
            jmp verifica_teclado

    verifica_teclado endp

    ignorar_direcao_contraria proc

        cmp tecla, 'd'
        je ignora_a

        cmp tecla, 'a'
        je ignora_d

        cmp tecla, 'w'
        je ignora_s

        cmp tecla, 's'
        je ignora_w

        ignora_a:
            cmp al, 'a'
            je ignora_direcao   
            ret

        ignora_d:
            cmp al, 'd'
            je ignora_direcao
            ret

        ignora_direcao:
            mov al, tecla
            ret

        ignora_s:
            cmp al, 's'
            je ignora_direcao
            ret

        ignora_w:
            cmp al, 'w'
            je ignora_direcao
            ret

    ignorar_direcao_contraria endp

    limpa_tela proc

        ; Habilita o modo gráfico VGA
        mov ah, 00h   ; Para configurar o modo de vídeo
        mov al, 13h   ; Escolhe o modo de vídeo VGA
        int 10h       ; Executa a configuração

        ; Cor de fundo
        mov ah,0Bh    ; Definindo cor de fundo
        mov bh,00h 
        mov bl,00h
        int 10h
        ret

    limpa_tela endp
    
    desenha proc

        push ax ; Guarda o valor de AX na pilha
        push cx ; Guarda o valor de CX na pilha
        push dx ; Guarda o valor de DX na pilha
        
        mov dx, inicio_y  ; Setamos a linha
        mov cx, inicio_x  ; Setamos a coluna
        mov ah, 0ch       ; Para desenhar um pixel
        mov al, cor       ; Setamos a cor
        
        desenha_horizontal:
            inc cx
            int 10h                ; Desenha o pixel (AL = cor, BH = pagina, CX = coluna (x), DX = linha (y))
            cmp cx, fim_x
            jne desenha_horizontal ; Se não terminou de desenhar horizontalmente

        ; Vai para a próxima linha
        mov cx, inicio_x           ; Reseta a coluna
        inc dx                     ; Vai para a próxima linha
        cmp dx, fim_y               
        jne desenha_horizontal     ; Se não terminou de desenhar todas as linhas, desenha a próxima
        
        ; Volta aos valores iniciais
        pop dx
        pop cx
        pop ax

        ret
    desenha endp

    desenha_snake proc

        push ax 
        push bx
        ;push cx

        mov cor, 02h

        ;mov cx, tamanho_snake

        ;desenha_snake_loop:
            mov ax, snake_x_pos[0]
            mov inicio_x, ax  

            mov bx, snake_x_pos[0]
            add bx, pixel_dimensao
            mov fim_x, bx      

            mov ax, snake_y_pos[0]          
            mov inicio_y, ax

            mov bx, snake_y_pos[0]
            add bx, pixel_dimensao
            mov fim_y, bx
            call desenha
            ;dec cx
        ;    loop desenha_snake_loop

        ;pop cx
        pop bx
        pop ax

        ret
    desenha_snake endp

    desenha_arena proc
        mov cor, 0Fh ; Seta a cor para branco   

        ; 200 x 200
        ; Topo
        mov inicio_x, 0
        mov fim_x, 200   
        mov inicio_y, 0
        mov fim_y, 5
        call desenha

        ; Direita
        mov inicio_x, 195
        mov fim_x, 200
        mov inicio_y, 5
        mov fim_y, 200
        call desenha

        ; Esquerda
        mov inicio_x, 0
        mov fim_x, 5
        mov inicio_y, 5
        mov fim_y, 200
        call desenha

        ; Baixo
        mov inicio_x, 0
        mov fim_x, 200
        mov inicio_y, 195
        mov fim_y, 200
        call desenha 
    
        ret
    desenha_arena endp

    desenha_menu proc 

        call limpa_tela

        ; Printa o título do jogo
        mov ah, 02h           ; Para setar a posição do cursor
        mov bh, 00h           ; Setar qual página
        mov dh, 04h           ; Setar linha
        mov dl, 04h           ; Setar coluna
        int 10h

        mov ah, 09h           ; Para printar string
        mov dx, offset titulo ; Define que vamos printar o título
        int 21h

        ; Printa a opcao "Jogar"
        mov ah, 02h           ; Para setar a posição do cursor
        mov bh, 00h           ; Setar qual página
        mov dh, 06h           ; Setar linha
        mov dl, 04h           ; Setar coluna
        int 10h

        mov ah, 09h           ; Para printar string
        mov dx, offset jogar  ; Define que vamos printar o título
        int 21h

        ; Printa a opcao "Sair"
        mov ah, 02h           ; Para setar a posição do cursor
        mov bh, 00h           ; Setar qual página
        mov dh, 08h           ; Setar linha
        mov dl, 04h           ; Setar coluna
        int 10h

        mov ah, 09h           ; Para printar string
        mov dx, offset sair   ; Define que vamos printar o título
        int 21h

        menu_espera_tecla:
            ; Espera a opcao escolhida pelo jogador
            mov ah, 00h
            int 16h

            ; Trata a tecla pressioanda
            cmp al, 'j'
            je  menu_inicia_jogo   ; Se a tecla pressionada for j
            ;cmp al, 'J'
            ;je  menu_inicia_jogo  ; Se a tecla pressionada for J

            cmp al, 's'
            je  menu_fim           ; Se a tecla pressionada for s
            ;cmp al, 'S'
            ;je  menu_fim          ; Se a tecla pressionada for S
        
            jmp menu_espera_tecla  ; Nenhuma das duas teclas foi pressionada

            menu_inicia_jogo:
                call inicia_jogo
            ret

            menu_fim:
                call fim
            ret

    desenha_menu endp 

    desenha_game_over proc
        call limpa_tela

        ; Printa "GAME OVER"
        mov ah, 02h           ; Para setar a posição do cursor
        mov bh, 00h           ; Setar qual página
        mov dh, 04h           ; Setar linha
        mov dl, 04h           ; Setar coluna
        int 10h

        mov ah, 09h              ; Para printar string
        mov dx, offset go_titulo ; Define que vamos printar o título
        int 21h

        ; Printa a opcao "Jogar"
        mov ah, 02h           ; Para setar a posição do cursor
        mov bh, 00h           ; Setar qual página
        mov dh, 06h           ; Setar linha
        mov dl, 04h           ; Setar coluna
        int 10h

        mov ah, 09h             ; Para printar string
        mov dx, offset go_jogar ; Define que vamos printar o título
        int 21h

        ; Printa a opcao "Sair"
        mov ah, 02h           ; Para setar a posição do cursor
        mov bh, 00h           ; Setar qual página
        mov dh, 08h           ; Setar linha
        mov dl, 04h           ; Setar coluna
        int 10h

        mov ah, 09h            ; Para printar string
        mov dx, offset go_sair ; Define que vamos printar o título
        int 21h

        go_espera_tecla:
            ; Espera a opcao escolhida pelo jogador
            mov ah, 00h
            int 16h

            ; Trata a tecla pressioanda
            cmp al, 'j'
            je  go_inicia_jogo  ; Se a tecla pressionada for j
            ;cmp al, 'J'
            ;je  go_inicia_jogo  ; Se a tecla pressionada for J

            cmp al, 's'
            je  go_fim       ; Se a tecla pressionada for s
            ;cmp al, 'S'
            ;je  go_fim       ; Se a tecla pressionada for S
        
            jmp go_espera_tecla ; Nenhuma das duas teclas foi pressionada

            go_inicia_jogo:
                call inicia_jogo
            ret

            go_fim:
                call fim
            ret

    desenha_game_over endp

    fim proc
        mov ah, 00h
        mov al, 02h   ; Voltamos para o modo de texto
        int  10h

        mov  ax,4c00h ; Terminamos o programa
        int  21h

        ret
    fim endp

end inicio