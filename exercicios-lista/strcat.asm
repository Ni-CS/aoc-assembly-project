.data

.text

strcat:
    move $t0, $a0          # $t0 = endereço da string de destino
    li $t1, 0              # Inicializar contador para iteração

ache_fim:
    lb $t2, 0($t0)         # Carrega o byte atual da string de destino
    beqz $t2, comeca_concat  # Se for o final da string 
    addi $t0, $t0, 1       # Avança para o próximo byte da string de destino
    j ache_fim             # Repete até encontrar o final

comeca_concat:
    move $t3, $a1          # $t3 = endereço da string fonte

concat_loop:
    lb $t4, 0($t3)         # Carrega o byte atual da string fonte
    sb $t4, 0($t0)         # Armazena o byte na posição atual de destino
    beqz $t4, fim   	   # Quando chegar no fim da concatenação, termina o programa
    addi $t0, $t0, 1       # Avança para o próximo byte na string de destino
    addi $t3, $t3, 1       # Avança para o próximo byte na string fonte
    j concat_loop          # Repetir até copiar toda a string fonte

fim:
    move $v0, $a0         
    jr $ra                 