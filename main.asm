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

input_buffer: .space 100 #string digitada
apartamentos: .space 4320 #12 andares * 2ap/a * 6 moradores * tamanho string | 180 para cada ap | 30 para cada morador
veiculos: .space  1440 #24 ap * 30 string * 2 veiculos| 1 para tipo de veiculo | 7 para placa | 22 para modelo
input_nome:   .space 100       # Buffer para a string de saída (primeira palavra)

#comandos disponiveis
cmd1: .asciiz "addMorador"
cmd2: .asciiz "rmvMorador --"
cmd3: .asciiz "addAuto --"
cmd4: .asciiz "rmvAuto --"
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
    syscall
.end_macro

.text

#printamos o inicio do app
#print_string(boas_vindas)

#loop de printar o shell
loop_shell:
	print_string(shell)#printar o shell
	read_string(input_buffer, 11)#pega a string do usuário

	la $a0, cmd1
    	la $a1, input_buffer
    	jal strcmp
    
    	move $t0, $v0
    
	beq $t0, $zero, handlerAddMorador
	
	print_int($t0)
	
	print_string(inv_command)
	j loop_shell
	
	
handlerAddMorador:

	print_string(comandos)

	li $t9, 23 # coloca em t9 23
	
	li $v0, 4
    	la $a0, pedir_ap
    	syscall
    	
	li $v0, 5 # Lê apartamento
	syscall
	move $t0, $v0
	
	print_string(pedir_nome) # Pede nome do morador
	read_string(input_nome, 100) # lê nome do morador
	
	blt $t0, $zero, invalida
	bgt $t0, $t9, invalida
	
	print_string(comandos)
	j loop_shell

invalida:
	print_string(inv_ap)
	j loop_shell


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
