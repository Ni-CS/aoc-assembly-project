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
	read_string(input_buffer, 100)#pega a string do usuário
	
	li $t8, 1
	
	la $a0, cmd1
    la $a1, input_buffer
    jal strcmp 
    
	beq $v0, $zero, handlerAddMorador
	
	print_string(inv_command)
	j loop_shell
	
	
handlerAddMorador:
	li $t9, 23 # coloca em t9 23
	li $v0, 4
    la $a0, pedir_ap
    syscall
	li $v0, 5 # Lê apartamento
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


strncmp:
    move $t2, $a3 #salva o numero maximo de comparacoes

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
	
get_first_word:
    move $t0, $a0           # $t0 aponta para a string de entrada
    move $t1, $a1           # $t1 aponta para o buffer de saída

loop:
    lb $t2, 0($t0)          # Carrega o próximo caractere da string
    beqz $t2, end_copy      # Se o caractere for nulo, termine
    beq $t2, ' ', end_copy  # Se o caractere for espaço, termine
    sb $t2, 0($t1)          # Copia o caractere para o buffer de saída
    addi $t0, $t0, 1        # Avança para o próximo caractere na entrada
    addi $t1, $t1, 1        # Avança para o próximo caractere no buffer de saída
    j loop                  # Repete o processo

end_copy:
    sb $zero, 0($t1)        # Adiciona o caractere nulo ao final da string de saída
    jr $ra                  # Retorna da função

strcmp:
    subi $sp, $sp, 4           #reserva dois espaços na pilha
    sw $ra, 0($sp)             #salva o endereço de retorno

comparaLoop:
    lb $t0, 0($a0)             #carrega um byte da posição n de a0 em t0
    lb $t1, 0($a1)             #carrega um byte da posição n de a1 em t1
    beq $t0, $t1, procuraFinal #se forem iguais, entra em procuraFinal
    li $v0, 1                  #strings são diferentes, carrega 1 em v0
    j final #pula pra final

procuraFinal:
    beqz $t0, stringsIguais    #se $t0 é nulo, as strings são iguais e entra em stringsIguais
    addi $a0, $a0, 1           #incrementa as posições
    addi $a1, $a1, 1
    j comparaLoop #volta para comparaLoop

stringsIguais:
    move $v0, $zero            #strings são iguais, carrega $zero em v0

final:
    lw $ra, 0($sp)             #recupera o endereço de retorno
    addi $sp, $sp, 4           #libera um espaço na pilha
    jr $ra                     #retorna para o chamador
