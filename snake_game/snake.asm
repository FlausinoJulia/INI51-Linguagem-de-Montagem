; SNAKE GAME - ASSEMBLY 8086
; Danyelle Nogueira França - RA: 21232
; Julia Flausino da Silva  - RA: 21241

.MODEL small
.STACK 100h

.DATA
    ; Limites tela do jogo (200x200)
    limite_inicio dw 5
    limite_fim    dw 190

    ; Labels para o MENU
    titulo db 'SNAKE GAME', '$' ; Título do jogo
    jogar  db 'J - Jogar', '$'  ; Para iniciar o jogo
    sair   db 'S - Sair', '$'   ; Para sair do jogo

    ; Labels para a tela de GAME OVER
    go_titulo db 'GAME OVER', '$'           ; Título da tela de GAME OVER
    go_jogar  db 'J - Jogar novamente', '$' ; Para iniciar o jogo
    go_sair   db 'S - Sair do jogo', '$'    ; Para sair do jogo

    ; Variáveis para desenho
    cor db ?
    inicio_x dw ?
    inicio_y dw ?
    fim_x dw ?
    fim_y dw ?

    ; Variáveis SNAKE
    tamanho_snake dw 0               ; A snake começa com apenas 1 de tamanho
    snake_x_pos   dw 10, 100 dup(?) ; Vetor para acompanhar as posiçães X das casinhas que a snake ocupa
    snake_y_pos   dw 10, 100 dup(?) ; Vetor para acompanhar as posiçães Y das casinhas que a snake ocupa
        ; variáveis auxiliares de movimento
    snake_novo_x  dw 10              ; Vai indicar para onde a snake está se movendo (coordenada X)
    snake_novo_y  dw 10              ; Vai indicar para onde a snake está se movendo (coordenada X)

    ; Variável que define o tamanho dos quadradinhos a serem desenhados
    pixel_dimensao dw 5

    ; Variáveis MAÇÃ
    seed dw 0          ; Variável para a semente do gerador de números aleatórios.
    num_aleatorio dw 1 ; Para gerar a posicao da maça
    maca_x dw 5        ; Para guardar a coordenada X da maçã
    maca_y dw 5        ; Para guardar a coordenada Y da maçã
    pegouMaca dw 0     ; Para auxiliar o crescimento da snake


    ultimo_timestamp db 0
    houveColisao dw 0  ; Auxilia no tratamento de colisões (0 - falso; 1 - verdadeiro)
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
   
    call desenha_menu ; Chama o procedimento que desenha o menu do jogo
    call fim          ; Encerra o programa

    inicia_jogo proc  ; Reinicia variáveis e inicia o loop do jogo

        call limpa_tela     ; Limpando a tela para desenhar arena
        mov tecla, 'd'      ; A snake começa indo para a direita
        mov houveColisao, 0 ; Não houve colisão ainda

        call desenha_arena  ; Desenhando os limites do jogo

        ; Resetando variaveis SNAKE
        mov snake_x_pos[0], 10  ; O primeiro pixel da snake fica na coluna 2
        mov snake_y_pos[0], 10  ; O primeiro pixel da snake fica na linha 2
        mov tamanho_snake, 0    ; A snake ainda não cresceu
      
        mov snake_novo_x, 10    ; A snake ainda não andou, então resetamos as variáveis auxiliares de movimento
        mov snake_novo_y, 10    ; A snake ainda não andou, então resetamos as vairáveis auxiliares de movimento

        call desenha_snake      ; Desenhando a snake nas coordenadas iniciais

        mov pegouMaca, 0  ; Ainda não pegou maçã
        call desenha_maca ; Desenhando a maçã
        call executa_jogo ; Inicia loop do jogo
        ret

    inicia_jogo endp

    desenha_maca proc ; Desenha a maçã em uma coordenada aleatória
        push cx ; Guarando o valor de CX
        push ax ; Guardando o valor de AX
        push bx ; Guardadno o valor de BX

        gerar_pos:
            ; Gerando coordenada X da maçã
            ; Gerando número aleatório 1 a 37
            call srand ; Preparando a variável seed 
            mov cx, 37 ; Definindo limite final do intervalo como 38 
            call rand  ; Gerando o número aleatório dentro do intervalo
            mov num_aleatorio, ax ; Armazenando o número aleatório

            ; Multiplicando numero aleatorio por 5
            mov ax, num_aleatorio
            mov cx, 5
            mul cx ; AX = AX * 5
            mov maca_x, ax ; Guardando a coordenada X da maçã

            ; Gerando coordenada Y da maçã
            ; Gerando número aleatório de 1 a 37
            call srand
            mov cx, 37
            call rand
            mov num_aleatorio, ax

            ; Multiplicando numero aleatorio por 5
            mov ax, num_aleatorio
            mov cx, 5
            mul cx ; AX = AX * 5
            mov maca_y, ax ; Guardando coordenada Y da maçã

            ; Verifica se essas coordenadas são válidas (se tem algum elemento desenhado lá)
            mov ah, 0dh ; Para ler um pixel
            mov bh, 00h ; Page number = 0 
            mov cx, maca_x ; Coluna = AX
            mov dx, maca_y ; Linha  = AX
            int 10h     ; Verifica o pixel (a cor do pixel é armazenada em AL)

            cmp al, 00h     ; Vê se o espaço tá vazio (cor = preto)
            je print_maca   ; Se ta vazio, desenha
            jmp gerar_pos   ; Se não, gera nova posicao para a maça

        print_maca:
            ; Desenhando maca
            mov cor, 04h ; Definindo a cor como vermelho

            ; Definindo em qual pixel da linha vai estar o inicio do desenho
            mov ax, maca_x  
            mov inicio_x, ax

            ; Definindo em qual pixel da linha vai estar o fim do desenho
            mov bx, maca_x
            add bx, pixel_dimensao
            mov fim_x, bx      

            ; Definindo em qual pixel da coluna vai estar o inicio do desenho
            mov ax, maca_y          
            mov inicio_y, ax 

            ; Definindo em qual pixel da coluna vai estar o fim do desenho
            mov bx, maca_y
            add bx, pixel_dimensao
            mov fim_y, bx  
            
            ; Pinta os pixels definidos de vermelho
            call desenha 

            pop bx ; O valor de BX volta ao normal
            pop ax ; O valor de AX volta ao normal
            pop cx ; O valor de CX volta ao normal

            ret

    desenha_maca endp
    
    ; Inicializamos a semente do gerador de números aleatórios com base no tempo atual
    srand proc          
        mov  ah,2
        int  1ah
        add  dx,cx
        mov  seed,dx
        ret
    srand endp

    ; Calculamos um número aleatório entre 1 e um limite N fornecido
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
        
    executa_jogo proc ; Loop do jogo

        game_loop:
            ; loop para atualizar o frame a cada time delta
            atualizar_frame:
                mov  ah, 2ch                               ; função para obter o timestamp
                int  21h                                   ; executa a função

                cmp  dl, ultimo_timestamp                  ; compara o timestamp atual (dl) com o último timestamp
                je   atualizar_frame                       ; se for igual, repete o loop

            mov  ultimo_timestamp, dl                  ; se não, atualiza o último timestamp
            call verifica_teclado   ; Vê se o usuário pressionou alguma tecla
            call move_snake         ; Move a snake (mesmo se nenhuma tecla foi pressionada)
            jmp  game_loop          ; Mantém o loop do jogo
        ret

    executa_jogo endp

    verifica_colisao_cauda proc ; Para verificar se a snake colidiu com a própria cauda

        ; Guarda os valores dos registradores que vao ser alterados na pilha
        push cx
        push bx
        push si

        ; Se a snake ainda não cresceu, não tem como colidir com a cauda
        cmp tamanho_snake, 0
        je verifica_colisao_cauda_ret

        mov cx, tamanho_snake   ; Contador
        mov si, tamanho_snake   ; Indice para acessar o vetor

        verificando_colisao_cauda:
            ; Verificando coordenada X
            mov bx, snake_x_pos[si] ; Coordenada x que vai ser comparada com a coordenada da cabeça da snake
            cmp snake_novo_x, bx    ; Verifica se a coordenada X para a qual a snake esta andando é igual à coordenada X da cauda
            je verifica_y           ; Se é igual, tem que ver se o Y é igual também
            jmp continua_loop       ; Se não, vemos a próxima parte da cauda

            verifica_y:
            ; Verificando coordenada Y
            mov bx, snake_y_pos[si] ; Coordenada Y que vai ser comparada com a coordenada da cabeça da snake
            cmp snake_novo_y, bx    ; Verifica se a coordenada Y para a qual a snake esta andando é igual à coordenada Y da cauda
            je colidiu_com_cauda    ; As coordenadas são iguais, então colidiu
            
            continua_loop:
            dec si  ; Vai para o próximo quadradinho da cauda
            ;dec cx  ; Diminui o contador (já verificamos um pixel da snake)
        loop verificando_colisao_cauda

        verifica_colisao_cauda_ret:
            ; Os valores dos registradores voltam ao normal
            pop si
            pop bx
            pop cx
            ret

        colidiu_com_cauda:
            ; AtuaLizamos a variável houveColisao para TRUE
            mov houveColisao, 1
            jmp verifica_colisao_cauda_ret

    verifica_colisao_cauda endp

    verifica_colisao_parede proc ; Para verificar se a snake colidiu com os limites da arena do jogo

        push ax

        ; Verificando para qual direção a snake está andando
        cmp tecla, 'd'  ; Se a tecla é D, a snake está se movendo para DIREITA
        je verifica_direita

        cmp tecla, 'a' ; Se a tecla é A, a snake está se movendo para ESQUERDA
        je verifica_esquerda

        cmp tecla, 'w' ; Se a tecla é W, a snake está se movendo para CIMA
        je verifica_cima

        cmp tecla, 's' ; Se a tecla é S, a snake está se movendo para BAIXO
        je verifica_baixo

        verifica_direita:
            mov bx, limite_fim     ; Para comparar snake_x com limite_fim
            cmp snake_x_pos[0], bx ; Compara a posição da cabeça da snake com limite_fim
            je  atualiza_colisao   ; Se a snake ja esta no limite final da linha, ela nao pode andar para direita
            
            ; Calculando a posicao nova da snake para ver o que tem naquele quadrado
            mov ax, snake_x_pos[0] 
            add ax, pixel_dimensao  
            mov snake_novo_x, ax   ; Guardamos a possivel nova coordenada X na variável auxiliar  

            pop ax
            ret ; Não houve colisão com a parede

        verifica_esquerda:
            mov bx, limite_inicio  ; Para comparar snake_x com limite_inicio
            cmp snake_x_pos[0], bx ; Compara a posição da cabeça da snake com limite_inicio
            je atualiza_colisao    ; Se a snake ja esta no inicio da linha, ela nao pode andar para esquerda  

            ; Calculando a posicao nova da snake
            mov ax, snake_x_pos[0] 
            sub ax, pixel_dimensao   
            mov snake_novo_x, ax   ; Guardamos a possivel nova coordenada X na variável auxiliar         
            
            pop ax
            ret ; Não houve colisão com a parede

        atualiza_colisao:
            mov houveColisao, 1 ; Atualiza houve colisão para TRUE
            pop ax
            ret

        verifica_cima:
            mov bx, limite_inicio  ; Para comparar snake_y com limite_inicio
            cmp snake_y_pos[0], bx ; Compara a posição da cabeça da snake com limite_inicio
            je atualiza_colisao    ; Se a snake ja esta no inicio da coluna, ela nao pode andar para cima

            ; Calculando a posicao nova da snake
            mov ax, snake_y_pos[0]
            sub ax, pixel_dimensao          
            mov snake_novo_y, ax   ; Guardamos a possivel nova coordenada Y na variável auxiliar  

            pop ax
            ret ; Não houve colisão com a parede

        verifica_baixo:
            mov bx, limite_fim     ; Para comparar snake_x com limite_fim
            cmp snake_y_pos[0], bx ; Compara a posição da cabeça da snake com limite_fim
            je atualiza_colisao    ; Se a snake ja esta no final da coluna, ela nao pode andar para baixo

            ; Calculando a posicao nova da snake
            mov ax, snake_y_pos[0] 
            add ax, pixel_dimensao      
            mov snake_novo_y, ax   ; Guardamos a possivel nova coordenada Y na variável auxiliar    

            pop ax
            ret ; Não houve colisão com a parede

    verifica_colisao_parede endp

    atualiza_coordenadas proc ; Para quando a snake andar ou crescer
        push dx
        push cx
        push si

        ; Se a snake nao cresceu, ainda nao temos que atualizar as coordenadas
        mov cx, tamanho_snake        ; CX será usado como contador, determina quando o loop acaba
        cmp cx, 0 
        je  atualiza_coordenadas_ret

        mov si, tamanho_snake        ; Para indexar o vetor - determina qual dos pixels da snake estamos consultando

        atualizando_coordenadas:     ; O que está na posicao atual recebe o que está na posicao seguinte
            ; Atualizando coordenada X
            dec si
            mov dx, snake_x_pos[si]
            inc si
            mov snake_x_pos[si], dx

            ; Atualizando coordenada y
            dec si
            mov dx, snake_y_pos[si]
            inc si
            mov snake_y_pos[si], dx

            ;dec cx
        loop atualizando_coordenadas ; O indice 0 não tem seus valores alterados

        atualiza_coordenadas_ret:
        pop si
        pop cx
        pop dx
        ret

    atualiza_coordenadas endp

    verifica_colisoes proc ; Verifica colisões com o limite do arena e com a cauda

        ; Verificando se colidiu com o limite da arena do jogo
        call verifica_colisao_parede
        cmp houveColisao, 1
        je verifica_colisoes_ret    ; Não precisamos verificar se colidiu com a cauda, o jogo ja acabou

        ; Verificando se colidiu com a cauda
        call verifica_colisao_cauda

        verifica_colisoes_ret:
            ret

    verifica_colisoes endp

    verifica_pegou_maca proc ; Vê se as coordenadas da maçã sao as mesmas da nova coordenada da snake

        push bx
        
        ; Verifica coordenada X
        mov bx, maca_x 
        cmp snake_novo_x, bx
        je verifica_maca_y          ; Ver se Y é igual
        jmp verifica_pegou_maca_ret ; Se Y não é igual, a snake nao pegou maca

        verifica_maca_y:
        ; Verifica coordenada Y
            mov bx, maca_y
            cmp snake_novo_y, bx
            je pegou_maca               ; As duas coordenadas são iguais, então a snake pegou a maça
            jmp verifica_pegou_maca_ret ; As coordenadas nao sao iguais, a snake não pegou maca

        pegou_maca:
            mov pegouMaca, 1 ; Atualiza pegouMaca para true

        verifica_pegou_maca_ret:
            pop bx
            ret

    verifica_pegou_maca endp

    move_snake proc 
        push dx

        ; Verificando para qual direção a snake deve se mover
        cmp tecla, 'd'   ; Se a tecla é D, a snake está se movendo para DIREITA
        je move_direita

        cmp tecla, 'a'   ; Se a tecla é A, a snake está se movendo para ESQUERDA
        je move_esquerda

        cmp tecla, 'w'   ; Se a tecla é W, a snake está se movendo para CIMA
        je move_cima

        cmp tecla, 's'   ; Se a tecla é S, a snake está se movendo para BAIXO
        je move_baixo

        houve_colisao_1:
            call desenha_game_over

        move_direita:
            call verifica_colisoes   ; Verifica se ao andar para a direita há colisoes e atualiza houveColisao
            cmp houveColisao, 1      ; Se houveColisao = true
            je houve_colisao_1       ; Game over

            ; Se nao colidiu, checar se pegou uma maca
            call verifica_pegou_maca
            cmp pegouMaca, 1         ; Se pegou maca
            je pegou_maca_x_1        ; A snake cresce
            
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
            call verifica_colisoes
            cmp houveColisao, 1
            je houve_colisao

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
            call verifica_colisoes
            cmp houveColisao, 1
            je houve_colisao

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
            call verifica_colisoes
            cmp houveColisao, 1
            je houve_colisao

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

        push ax ; Guardando AX na pilha
        push si ; Guardando SI na pilha

        ; Pintando o ultimo pixel da snake de preto
        mov cor, 00h ; Cor preta

        mov si, tamanho_snake

        mov ax, snake_x_pos[si]
        mov inicio_x, ax

        add ax, pixel_dimensao
        mov fim_x, ax      

        mov ax, snake_y_pos[si]          
        mov inicio_y, ax

        add ax, pixel_dimensao
        mov fim_y, ax
        call desenha

        pop si ; SI volta ao valor inicial
        pop ax ; AX volta ao valor inicial
        
        ret
        
    pinta_ultima_casa_de_preto endp
    
    verifica_teclado proc

        ; Verificando se alguma tecla foi pressionada
        mov ah, 01h               ; Get the state of the keyboard buffer
        int 16h                   ; 01h - ZF = 0 if a key pressed; AL = ASCII character or zero if special function key
        jnz verifica_teclado_loop ; Se nenhuma tecla foi pressionada
        ret

        verifica_teclado_loop:
            call ignorar_direcao_contraria ; Imposibilita o jogador a ir para a direcao contraria à atual
            mov tecla, al         ; Guardando a tecla nova
            mov ah, 00h           ; Get tecla
            int 16h 
            jmp verifica_teclado

    verifica_teclado endp

    ignorar_direcao_contraria proc ; Para que a snake nao possa andar na direcao oposta

        cmp tecla, 'd'
        je ignora_a ; A direcao contraria a D é A

        cmp tecla, 'a'
        je ignora_d ; A direcao contraria a A é D

        cmp tecla, 'w'
        je ignora_s ; A direcao contraria a W é S

        cmp tecla, 's'
        je ignora_w ; A direcao contraria a S é W

        ignora_a: ; A direcao atual é D (direita)
            cmp al, 'a' ; Se o jogador clicou em a, ignoramos a nova tecla
            je ignora_direcao   
            ret

        ignora_d: ; A direcao atual é A (esquerda)
            cmp al, 'd' ; Se o jogador clicou em d, ignoramos a nova tecla
            je ignora_direcao
            ret

        ignora_direcao:
            ; AL (nova tecla) = tecla atual, ou seja, a direcao nova é ignorada e a direcao velha permanece
            mov al, tecla 
            ret

        ignora_s: ; A direcao atual é W (cima)
            cmp al, 's' ; Se o jogador clicou em s, ignoramos a nova tecla
            je ignora_direcao
            ret

        ignora_w: ; A direcao atual é S (baixo)
            cmp al, 'w' ; Se o jogador clicou em w, ignoramos a nova tecla
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
        
        desenha_horizontal: ; Loop que desenha horizontalmente (coluna a coluna)
            inc cx
            int 10h                ; Desenha o pixel (AL = cor, BH = pagina, CX = coluna (x), DX = linha (y))
            cmp cx, fim_x          ; Vê se ja foram desenhadas todas as colunas
            jne desenha_horizontal ; Se não terminou de desenhar horizontalmente

        ; Vai para a próxima linha
        mov cx, inicio_x           ; Reseta a coluna
        inc dx                     ; Vai para a próxima linha
        cmp dx, fim_y              ; Vê se ja foram desenhadas todas as linhas
        jne desenha_horizontal     ; Se não terminou de desenhar todas as linhas, desenha a próxima
        
        ; Volta aos valores iniciais
        pop dx
        pop cx
        pop ax

        ret
    desenha endp

    desenha_snake proc

        push ax 
        ;push bx
        ;push cx

        mov cor, 02h

        ;mov cx, tamanho_snake

        ;desenha_snake_loop:
            mov ax, snake_x_pos[0]
            mov inicio_x, ax  

            ;mov bx, snake_x_pos[0]
            add ax, pixel_dimensao
            mov fim_x, ax

            mov ax, snake_y_pos[0]          
            mov inicio_y, ax

            ;mov bx, snake_y_pos[0]
            add ax, pixel_dimensao
            mov fim_y, ax
            call desenha
            ;dec cx
        ;    loop desenha_snake_loop

        ;pop cx
        ;pop bx
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