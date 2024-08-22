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
pedir_tipo_veiculo: .asciiz "\nDigite o tipo do veículo(M) ou (C): " 
pedir_placa: .asciiz "\nDigite a placa do veículo: "
pedir_modelo: .asciiz "\nDigite o modelo do veículo: "
vaga_lotada: .asciiz "\nA vaga está ocupada\n"
tipo_invalido: .asciiz "\nTipo de veículo inserido é inválido\n"
veiculo_inexistente: .asciiz "\nVeículo da placa digitada não existe nesse apartamento\n"
veiculo_retirado: .asciiz "\nVeículo Removido\n"
ap_morador_vazio: .asciiz "\nMoradores Removidos\n"
ap_veiculo_vazio: .asciiz "\nVeiculos do apartamento Removidos\n"

input_buffer: .space 100 #string digitada
apartamentos: .space 4320 #12 andares * 2ap/a * 6 moradores * tamanho string | 180 para cada ap | 30 para cada morador
veiculos: .space  1440 #24 ap * 30 string * 2 veiculos| 1 para tipo de veiculo | 7 para placa | 22 para modelo
input_nome:   .space 30       # Buffer para a string de saída (primeira palavra)
input_tipo: .space 1
input_placa: .space 7
input_modelo: .space 22
zero: .space 1

#comandos disponiveis
cmd1: .asciiz "addMorador"
cmd2: .asciiz "rmvMorador"
cmd3: .asciiz "addAuto"
cmd4: .asciiz "rmvAuto"
cmd5: .asciiz "limparAp"
cmd6: .asciiz "infoAp"
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
	la $a0, cmd3 #compara com rmvMorador
    	la $a1, input_buffer #passa oq foi digitado
    	li $a2, 7 #limite de caracteres
    	jal strncmp #compara
    	
    	move $t0, $v0 # resposta, 0 são iguais
	beq $t0, $zero, handlerAddAuto #se for igual a addMorador, vai processar isso
#=======================================	
	la $a0, cmd4 #compara com rmvMorador
    	la $a1, input_buffer #passa oq foi digitado
    	li $a2, 7 #limite de caracteres
    	jal strncmp #compara
    	
    	move $t0, $v0 # resposta, 0 são iguais
	beq $t0, $zero, handlerRmvAuto #se for igual a addMorador, vai processar isso
	
	
#=======================================	
	la $a0, cmd5 #compara com rmvMorador
    	la $a1, input_buffer #passa oq foi digitado
    	li $a2, 8 #limite de caracteres
    	jal strncmp #compara
    	
    	move $t0, $v0 # resposta, 0 são iguais
	beq $t0, $zero, handlerLmpAp #se for igual a addMorador, vai processar isso
	
#=======================================	
	la $a0, cmd7 #compara com rmvMorador
    	la $a1, input_buffer #passa oq foi digitado
    	li $a2, 9 #limite de caracteres
    	jal strncmp #compara
    	
    	move $t0, $v0 # resposta, 0 são iguais
	beq $t0, $zero, handlerInfoGeral #se for igual a addMorador, vai processar isso
	
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
	move $s1, $v0 #salva o ap em t0
	
	print_string(pedir_nome) # Pede nome do morador
	read_string(input_nome, 30) # lê nome do morador
	
	la $t1, input_nome #carrega o endereco de onde salvou o nome digitado
	
	blt $s1, $zero, invalida # verifica se é valido o numero do ap
	bgt $s1, $t9, invalida # verifica se é válido o numero do ap
	configurar_removedor:
		#calcular o endereço a verificar
		li $t2, 180 # carrega 180, quantia por ap
		mul $s1, $s1, $t2 #multiplica pelo ap em si, ex: ap 12 * 180 = x
			configurar_igualdade:
				li $t3, 0 #contador de moradores
				li $t4, 30 #tamanho de um morador do ap
				verificar_igualdade:
					
					la $t7, apartamentos # carrega o endereco base do array de apartamentos
					add $t7, $t7, $s1 # soma com o endereco do apartamento
					
					la $a1, input_nome #move o nome salvo para passar para a comparação
					move $a0, $t7 # move o nome digitado para passar para a comparação
					li $a2, 30
					
					jal strncmp # vai comparar a string
					move $t6, $v0 #salva o resultado, 0 = strings iguais
					beqz $t6, removerMorador # vai remover o morador
					addi $t3, $t3, 1 # aumenta o contador de morador/indice
					add $s1, $t4, $s1 # vai para o endereco do proximo morador
					bne $t3, 5, verificar_igualdade # repete o ciclo
					
					print_string(morador_inexistente) # printa quando nao tem um morador com o nome digitado nesse apartamento
					
					j loop_shell # volta pro loop de comando
					
					
				removerMorador:
					li $t4, 30 # $t4 = número de bytes a serem limpos
    					li $t5, 0 # $t5 = valor a ser armazenado (0)
    					loop_remover_morador:
    						beq $t4, $zero, morador_removido # terminou de iterar pelo nome e zerou ele todo
    						sb $t5, apartamentos($s1) # guarda 0 no caractere atual
    						addi $s1, $s1, 1 # passa para o proximo caractere
    						subi $t4, $t4, 1 # diminui do contador de caracteres a remover
    						j loop_remover_morador # continua no ciclo
    						
					morador_removido:
						print_string(morador_retirado) # informa que o morador foi retirado
						j loop_shell # volta para o loop de comando
		
handlerAddAuto:
	li $t9, 23 # coloca em t9 23 que é o numero máximo de aps

	print_string(pedir_ap) # printa a frase de pedir um ap
	read_int($t0) # recebe o ap e salva em t0
	
	print_string(pedir_tipo_veiculo) # pedir o tipo do veiculo
	#receber o tipo em char
	li $v0, 12 # codigo para ler um char(tipo)
	li $a2, 1 # limite de caracteres a ler
	syscall # recebe
	sb $v0, input_tipo # salvou o valor no espaco alocado
	
	blt $t0, $zero, invalida # verifica se é valido o numero do ap
	bgt $t0, $t9, invalida # verifica se é válido o numero do ap
	
	li $t1, 60 # carrega a quantia de espaco para cada apartamento(30 cada veiculo)
	mul $t0, $t0, $t1 # calcula a posicao inicial dos veiculos desse ap
	li $t5, 0
	verificar_endereco_auto:
		lb $t4, input_tipo # carrega o que o tipo de veiculo que o usuario digitou
		
		#verifica se é válido
		li $t3, 'M' # carrega a inicial de moto
		bne $t4, $t3, verifica_validade_carro#sai daqui
		
		j verifica_vaga
		
		verifica_validade_carro:
			#verifica se é válido
			li $t3, 'C' # carrega a inicial de carro
			bne $t4, $t3, input_invalido # sai daqui
			
		verifica_vaga:	
			lb $t2, veiculos($t0) # pega o valor que está na posicao inicial dos veiculos desse ap e salva em t2
			addi $t6, $t0, 30 # calcula a segunda vaga
			lb $t7, veiculos($t6) # pega o valor da segunda vaga
			
			#a segunda vaga esta ocupada? se sim, verifica a primeira, senao vai pro resto
			bne $t7, $zero, verificar_primeira_vaga # verifica se está livre, 0 = livre, M = moto, C = carro		
				j resto_verifica
				verificar_primeira_vaga: #verifica a primeira vaga para procurar veiculo
					beq $t2, $zero, verifica_input_auto
						j vaga_ocupada
						verifica_input_auto:
							beq $t4, $t3, vaga_ocupada
			resto_verifica:	
			
			#se chega aqui, ou as duas vagas estão livres, ou a segunda vaga está ocupada e você quer colocar uma moto na primeira vaga
			beq $t2, $zero, inserir_auto # se estiver livre, insere
			
			#não estando livre, verifica se o cadastrado na vaga atual é um carro
			li $t3, 'C' # carrega a inicial de carro
			beq $t2, $t3, vaga_ocupada # compara a posicao inicial, quando nao está livre, se tem um carro, se tiver avisa que está ocupado
		
			#não sendo um carro, verifica se o tipo digitado pelo usuário é um carro
			li $t3, 'C' # carrega a inicial de carro
			beq $t4, $t3, vaga_ocupada # se ele quer cadastrar um carro(aqui já tem uma moto obrigatoriamente), vai falhar
		
			addi $t0, $t0, 30 # foi para o proxima vaga
			bge $t5, 2, vaga_ocupada # se passar de 2 vagas ele diz que está ocupado
			j verifica_vaga
		
		inserir_auto:
			print_string(pedir_placa) # pede a placa
			read_string(input_placa, 7) # le a placa
			
			print_string(pedir_modelo) # pede o modelo
			read_string(input_modelo, 22) # le o modelo
			
			inserir_tipo_auto:
				la $a1, input_tipo # carrega o endereco do tipo
				la $a0, veiculos($t0) # carrega o endereco de onde salvar o tipo na posicao correta
				jal strcpy # salva o tipo
			
			inserir_placa_auto:
				la $a1, input_placa # carrega o endereco da placa
				addi $t0, $t0, 1 # adiciona 1 posicao no endereco dessa vaga desse ap 1(tipo)|7(placa)|22(modelo) 
				la $a0, veiculos($t0) # carrega o endereco de onde salvar a placa na posicao correta
				jal strcpy # salva a placa
				
			inserir_modelo_veiculo:
				la $a1, input_modelo # carrega o endereco do modelo
				addi $t0, $t0, 7 # adiciona 7 para chegar na parte do modelo dessa vaga desse ap
				la $a0, veiculos($t0) # acrrega o endereco de onde salvar na posicao correta
				jal strcpy # salva o modelo
				
			j loop_shell		
		
		vaga_ocupada:
			print_string(vaga_lotada) # printa que a vaga esta ocupada
			j loop_shell # volta para loop comando
			
		input_invalido:
			print_string(tipo_invalido) # printa que o tipo digitado esta errado
			j loop_shell # volta para o loop comando
			
handlerRmvAuto:
	li $t9, 23 # coloca em t9 23 que é o numero máximo de aps

	print_string(pedir_ap) # printa a frase de pedir um ap
	read_int($s0) # recebe o ap e salva em t0

	print_string(pedir_placa) # pede a placa
	read_string(input_placa, 7) # le a placa
	
	blt $s0, $zero, invalida # verifica se é valido o numero do ap
	bgt $s0, $t9, invalida # verifica se é válido o numero do ap
	
	li $t1, 60 # carrega a quantia de espaco para cada apartamento(30 cada veiculo)
	mul $s0, $s0, $t1 # calcula a posicao inicial dos veiculos desse ap
	li $t8, 0 # limite de vagas que pode olhar
	li $t3, 30 # casas para ir pra proxima vaga
	
	la $t4, veiculos # carrega o endereco base do array de veiculos
	add $t4, $t4, $s0 # soma com o endereco do apartamento
	addi $t4, $t4, 1 # soma para chegar na placa
	encontrar_veiculo:
		
		la $a1, input_placa #move a placa salva para passar para a comparação
		move $a0, $t4 # move a placa digitada para passar para a comparação
		li $a2, 7
						
		jal strncmp # vai comparar a placa
		move $t5, $v0 #salva o resultado, 0 = strings iguais
		
		beqz $t5, removerVeiculo # vai remover o veiculo se as placas forem iguais
		
		addi $t8, $t8, 1 # aumenta o contador de vaga/indice
		add $s0, $t4, $t3 # vai para o endereco da proxima vaga
		beq $t8, 2, veiculo_nao_existe # repete o ciclo
			
		j encontrar_veiculo
		
		veiculo_nao_existe:		
			print_string(veiculo_inexistente) # printa quando nao tem um morador com o nome digitado nesse apartamento
			
		j loop_shell # volta pro loop de comando
		
	removerVeiculo:
	beq $t8, 1, tira_um
		j resto_remover_veiculo
		tira_um:
			subi $s0, $s0, 1
		resto_remover_veiculo:
		li $t4, 30 # $t4 = número de bytes a serem limpos
    		#lb $t5, zero # $t5 = valor a ser armazenado (0)
    		li $t5, 0
    		loop_remover_veiculo:
    			beq $t4, $zero, veiculo_removido # terminou de iterar pelo nome e zerou ele todo
    			#sb $t5, veiculos($t0) # guarda 0 no caractere atual
    			
    			sb $t5, veiculos($s0)
    			
    			addi $s0, $s0, 1 # passa para o proximo caractere
    			subi $t4, $t4, 1 # diminui do contador de caracteres a remover
    			j loop_remover_veiculo # continua no ciclo
    						
		veiculo_removido:
			print_string(veiculo_retirado) # informa que o veiculo foi retirado
			j loop_shell # volta para o loop de comando






handlerLmpAp:

		li $t9, 23 # coloca em t9 23 que é o numero máximo de aps
	
		print_string(pedir_ap) # printa a frase de pedir um ap
		read_int($s2) # recebe o ap e salva em t0
		
		
		move $t6, $s2 # salvei o s2 em t6 para usa-lo no remover veiculo
	
		blt $s2, $zero, invalida # verifica se é valido o numero do ap
		bgt $s2, $t9, invalida # verifica se é válido o numero do ap
	
		li $t8, 0 #contador de moradores
		li $t7, 180 # 180 bytes pra serem limpos
		mul $s2, $s2, $t7 #multiplica pelo ap em si, ex: ap 12 * 180 = x
	
	remove_ap_morador:
	
    			loop_remover_ap_morador:
    				beq $t7, $zero, moradorees_ap_removido # terminou de iterar pelo nome e zerou ele todo
    				sb $t8, apartamentos($s2) # guarda 0 no caractere atual
    				addi $s2, $s2, 1 # passa para o proximo caractere
    				subi $t7, $t7, 1 # diminui do contador de caracteres a remover
    				j loop_remover_ap_morador # continua no ciclo
		
						moradorees_ap_removido:
							print_string(ap_morador_vazio)
							j remove_ap_veiculo


	remove_ap_veiculo:
	
				li $t7, 60 # 60 bytes pra serem limpos
				mul $t6, $t6, $t7 #multiplica pelo ap em si, ex: ap 12 * 60 = x
	
		
				loop_remover_ap_veiculo:
    				beq $t7, $zero, veiculos_ap_removido # terminou de iterar pelo nome e zerou ele todo
    				sb $t8, veiculos($t6) # guarda 0 no caractere atual
    				addi $t6, $t6, 1 # passa para o proximo caractere
    				subi $t7, $t7, 1 # diminui do contador de caracteres a remover
    				j loop_remover_ap_veiculo # continua no ciclo
		
						veiculos_ap_removido:
							print_string(ap_veiculo_vazio)
							j loop_shell
					

handlerInfoGeral:
			
		
				
						
				
		






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
