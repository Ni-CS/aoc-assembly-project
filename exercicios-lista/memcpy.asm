.text

#$a0 = destination
#$a1 = source
#num = $a2

memcpy: #funcao de copiar qualquer conteudo de um endereco pro outro
	move $v0, $a0 #ja salva o destino para retornar em v0
	li $t0, 1 #contador para comparar com num
	
memcpy_iteration:
	bgt $t0, $a2, memcpy_exit #se o contador for maior que num ele sai do loop
	lb $t1, 0($a1) #carrega o valor da origem para salvar no destino
	sb $t1, 0($a0) #salva no destino o valor carregado da origem
	addi $a1, $a1, 1 #passa para o proximo valor
	addi $a0, $a0, 1 #passa para o proximo valor
	addi $t0, $t0, 1 #aumenta o contador
	j memcpy_iteration #volta pro loop

memcpy_exit:
	jr $ra #volta para onde foi chamado
