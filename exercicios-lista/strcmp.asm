#str1 = $a0
#srt2 = $a1

.text

strcmp: #comparar strings
	lb $t0, 0($a0) #carrega o valor da string 1
	lb $t1, 0($a1) #carrega o valor da string 2
	beq $t0, $t1, strcmp_iteration #se forem iguais parte pro proximo endereco so verificando se chegou no 0 antes de incrementar 
	sub $v0, $t0, $t1 #se chegar aqui eh pq sao diferentes, entao ao subtrair, se str1>str2 = retorno positivo, se str1<str2 = retorno negativo
	jr $ra #volta para onde foi chamado
	
strcmp_iteration:
	beq $t0, $zero, strcmp_exit #se for igual a zero quer dizer que acabou, entao vai para a saida
	addi $a0, $a0, 1 #adiciona 1 para ir pro proximo caractere
	addi $a1, $a1, 1 #adiciona 1 para ir pro proximo caractere 
	j strcmp #volta para a funcao e continua a comparar
	
strcmp_exit:
	move $v0, $zero #salva o valor em v0 para retornar
	jr $ra #volta para onde foi chamado