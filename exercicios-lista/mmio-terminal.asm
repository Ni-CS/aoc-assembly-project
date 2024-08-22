.text

#IMPORTANTE: DAR UM RESET NO TERMINAL ANTES DE DIGITAR, DEPOIS DE CONECTAR

#carregar os endereços em registradores temporários
li $t0, 0xFFFF0000 #receiver control/ controle da entrada
li $t1, 0xFFFF0004 #receiver data/ dados de entrada
li $t2, 0xFFFF0008 #transmiter control/ controle da saída
li $t3, 0xFFFF000C #transmiter data/ dados da saída

loop_entrada:
	lw $t4, 0($t0) #carrega o status de entra/ para ver se já foi algo digitado
	andi $t4, $t4, 0x01 #verifica se o ultimo bit é 1 e salva o resultado em t4
	beqz $t4, loop_entrada #se for igual a 0, nenhum caractere foi digitado, então continua no loop
	
	lw $t5, 0($t1) #carrega o valor que foi digitado
	j loop_saida #se um caractere foi digitado, vai imprimir

loop_saida:
	lw $t6, 0($t2) #carrega o status de saida/ para ver se pode imprimir
    	andi $t6, $t6, 0x01 #verifica se o ultimo bit pe 1 e salva em t6
    	beqz $t6, loop_saida #se for igual a 0, volta pro loop

    	sw $t5, 0($t3) #se estiver pronto pra imprimir, salva o valor no registrador de impressao
    	j loop_entrada #volta pro loop de leitura