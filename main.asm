.data

shell: .asciiz "MAN-SHELL>>"
boas_vindas: .asciiz "Seja Bem Vindo ao MAN, o seu sistema gerenciador de condomínio!\n"
comandos: .asciiz "\nComandos do Sistema exemplo(comando --<option1> --<option2>):\naddMorador --<ap> --<nome> \nrmvMorador --<ap> --<nome>\nAddAuto --<ap> --<tipo> --<modelo> --<placa>\nrmvAuto --<ap> --<placa>\nlimparAp <ap>\ninfoAp --<ap>\ninfoGeral\nsalvar\nrecarregar\nformatar\n"
linha: .asciiz "\n"
pedir_ap: .asciiz "\nDigite o número do apartamento(0...23): "
pedir_nome: .asciiz "\nDigite o nome do morador: "
inv_command: .asciiz "COMANDO INVÁLIDO\n"
inv_ap: .asciiz "APARTAMENTO INVÁLIDO\n"
sair: .asciiz "Saindo..."
ap_lotado: .asciiz "\nImpossível adicionar morador, apartamento lotado!\n"
morador_inexistente: .asciiz "Morador não encontrado\n"
morador_retirado: .asciiz "Morador Removido\n"

input_buffer: .space 100 #string digitada
apartamentos: .space 4320 #12 andares * 2ap/a * 6 moradores * tamanho string | 180 para cada ap | 30 para cada morador
veiculos: .space  1440 #24 ap * 30 string * 2 veiculos| 1 para tipo de veiculo | 7 para placa | 22 para modelo
input_nome:   .space 30       # Buffer para a string de saída (primeira palavra)

#comandos disponiveis
cmd1: .asciiz "addMorador"
cmd2: .asciiz "rmvMorador"
cmd3: .asciiz "addAuto"
cmd4: .asciiz "rmvAuto"
cmd5: .asciiz "limparAp --"
cmd6: .asciiz "infoAp --"
cmd7: .asciiz "infoGeral"
cmd8: .asciiz "salvar"
cmd9: .asciiz "recarregar"
cmd10: .asciiz "formatar"
cmd11: .asciiz "sair"

.macro print_string %string
    li $v0, 4
    la $a0, %string
    syscall
.end_macro

.macro read_string %register, %stringLimit
    li $v0, 8
    la $a0, %register
    li $a1, %stringLimit
    syscall
.end_macro

.macro read_int %register
    li $v0, 5
    syscall
    move %register, $v0
.end_macro

.macro print_int %register
    li $v0, 1
    move $a0, %register
    syscall
.end_macro

.text

#printamos o inicio do app
#print_string(boas_vindas)

#loop de printar o shell
loop_shell:
	print_string(shell)#printar o shell
	read_string(input_buffer, 100)#pega a string do usuário
#=======================================
	#comparar com os comandos existentes
	la $a0, cmd1 #compara com addMorador
    	la $a1, input_buffer #passa oq foi digitado
    	li $a2, 10 #limite de caracteres
    	jal strncmp #compara
    
    	move $t0, $v0 # resposta, 0 são iguais
	beq $t0, $zero, handlerAddMorador #se for igual a addMorador, vai processar isso
#=======================================
	la $a0, cmd2 #compara com rmvMorador
    	la $a1, input_buffer #passa oq foi digitado
    	li $a2, 10 #limite de caracteres
    	jal strncmp #compara
    	
    	move $t0, $v0 # resposta, 0 são iguais
	beq $t0, $zero, handlerRmvMorador #se for igual a addMorador, vai processar isso
#=======================================
	
	print_string(inv_command) #vai printar que foi comando invalido
	j loop_shell #volta pro loop de comando
	
	
handlerAddMorador:
	li $t9, 23 # coloca em t9 23 que é o numero máximo de aos
	
	li $v0, 4 #carrega o codigo de printar uma string
    	la $a0, pedir_ap # carrega a frase
    	syscall # pede o apartamento
    	
	li $v0, 5 # codigo de ler int
	syscall # le o ap
	move $t0, $v0 #salva o ap em t0
	
	print_string(pedir_nome) # Pede nome do morador
	read_string(input_nome, 30) # lê nome do morador
	
	la $t1, input_nome #carrega o endereco de onde salvou o nome digitado
	
	blt $t0, $zero, invalida # verifica se é valido o numero do ap
	bgt $t0, $t9, invalida # verifica se é válido o numero do ap
	
	configurar_morador:
		#calcular o endereço a salvar
		li $t2, 180 # carrega 180, quantia por ap
		mul $t0, $t0, $t2 #multiplica pelo ap em si, ex: ap 12 * 180 = x
		
		configurar_disponibilidade:
			li $t3, 0 #contador de moradores
			li $t4, 30 #tamanho de um morador do ap
			verificar_disponibilidade:
				lb $t5, apartamentos($t0) #carrega o primeiro valor do ap
				beqz $t5, adicionar_morador #se for zero, ja adiciona
				addi $t3, $t3, 1 # do contrario aumenta o contador de morador
				add $t0, $t4, $t0 # vai pro endereco do proximo morador
				bne $t3, 6, verificar_disponibilidade # fica no loop ate achar uma vago
				
				print_string(ap_lotado) #se nao achar avisa que esta lotado
				
				j loop_shell # volta pro loop de comando
		adicionar_morador:
			move $a1, $t1 # move o endereco da origem do nome digitado
			la $a0, apartamentos($t0) # carrega o endereco do destino a salvar o nome digitado
			jal strcpy #salva o nome copiando da origem pro destino
	
	j loop_shell #volta pro loop de comando


handlerRmvMorador:
	li $t9, 23 # coloca em t9 23 que é o numero máximo de aps
	
	li $v0, 4 #carrega o codigo de printar uma string
    	la $a0, pedir_ap # carrega a frase
    	syscall # pede o apartamento
    	
	li $v0, 5 # codigo de ler int
	syscall # le o ap
	move $t0, $v0 #salva o ap em t0
	
	print_string(pedir_nome) # Pede nome do morador
	read_string(input_nome, 30) # lê nome do morador
	
	la $t1, input_nome #carrega o endereco de onde salvou o nome digitado
	
	blt $t0, $zero, invalida # verifica se é valido o numero do ap
	bgt $t0, $t9, invalida # verifica se é válido o numero do ap
	configurar_removedor:
		#calcular o endereço a verificar
		li $t2, 180 # carrega 180, quantia por ap
		mul $t0, $t0, $t2 #multiplica pelo ap em si, ex: ap 12 * 180 = x
			configurar_igualdade:
				li $t3, 0 #contador de moradores
				li $t4, 30 #tamanho de um morador do ap
				verificar_igualdade:
					
					la $t7, apartamentos
					add $t7, $t7, $t0
					
					la $a1, input_nome #move o nome salvo para passar para a comparação
					move $a0, $t7 # move o nome digitado para passar para a comparação
					
					jal strcmp # vai comparar a string
					move $t6, $v0 #salva o resultado, 0 = strings iguais
					beqz $t6, removerMorador # vai remover o morador
					addi $t3, $t3, 1 # aumenta o contador de morador/indice
					add $t0, $t4, $t0 # vai para o endereco do proximo morador
					bne $t3, 6, verificar_igualdade # repete o ciclo
					
					print_string(morador_inexistente)
					
					j loop_shell # volta pro loop de comando
					
					
				removerMorador:
					li $t4, 30 # $t4 = número de bytes a serem limpos
    					li $t5, 0 # $t5 = valor a ser armazenado (0)
    					loop_remover_morador:
    						beq $t4, $zero, morador_removido
    						sb $t5, apartamentos($t0)  
    						addi $t0, $t0, 1 
    						subi $t4, $t4, 1  
    						j loop_remover_morador
    						
					morador_removido:
						print_string(morador_retirado)
						j loop_shell
		
		
		
		
		
		
#comando invalido
invalida:
	print_string(inv_ap) #printa quando o comando e invalido
	j loop_shell #volta pro loop de comando


strncmp:
    move $t2, $a2 #salva o numero maximo de comparacoes

strncmp_iteration: #funcao de comparar, mas com uma num maximo de vezes
    beqz $t2, strncmp_exit #vai para a saida quando acabar o numero de comparacoes
    lb $t0, 0($a0) #carrega o primeiro caractere
    lb $t1, 0($a1) #carrega o segundo caractere
    beq $t0, $t1, strncmp_next #se forem iguais vai pro proximo caractere
    sub $v0, $t0, $t1 #se chegar aqui eh pq sao diferentes, entao ao subtrair, se str1>str2 = retorno positivo, se str1<str2 = retorno negativo
    jr $ra #retorna pra onde foi chamado

strncmp_next:
    beq $t0, $zero, strncmp_exit #se for 0 ele já sai
    addi $a0, $a0, 1 #vai pro proximo caractere
    addi $a1, $a1, 1 #vai pro proximo caractere
    addi $t2, $t2, -1 #diminui a quantia de comparacoes
    j strncmp_iteration #volta pra funcao e continua a comparar

strncmp_exit:
    move $v0, $zero #salva o retorno
    jr $ra #volta para onde foi chamado

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