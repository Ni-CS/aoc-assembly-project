.text

#a0 = destino
#a1 = origem

strcpy: #funcao de copia de strings
	move $v0, $a0 #ja salva o endereco do destino para retornar em v0
	
strcpy_iteration: #loop para copiar cada caractere da string
	lb $t0, 0($a1) #carrega o caractere da string que esta na origem
	sb $t0, 0($a0) #salva o mesmo caractere na string de destino
	beq $t0, $zero, strcpy_exit #se esse caractere copiado foi o null(que deve ser copiado tbm), ele encerra a funcao e vai para a saida
	addi $a0, $a0, 1 #aumenta o endereco para o proximo caractere no destino
	addi $a1, $a1, 1 #aumenta o endereco para o proximo caractre na origem
	j strcpy_iteration #volta para a label e repete o loop
	
strcpy_exit:
	jr $ra #volta para onde foi chamado