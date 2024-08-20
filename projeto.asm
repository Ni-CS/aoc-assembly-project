#estrutura dos dados -> (NUM_APARTAMENTOS * ((MAX_MORADORES * TAMANHO_MAX_NOME) + (2 * (4 + TAMANHO_MAX_MODELO + TAMANHO_MAX_PLACA))))
#NUM_APARTAMENTOS = 24
#MAX_MORADORES = 6
#TAMANHO_MAX_NOME = 50
#TAMANHO_MAX_MODELO = 20
#TAMANHO_MAX_PLACA = 10

#exemplo AP1
# 0 a 367 -> AP 1 |0...299(nomes moradores)/0...49(joao)| 300...303(tipo de veiculo)/0=nulo, 1=carro, 2=moto | 304...323(modelo) | 324...333(placa) | 334...337(tipo de veiculo) | 338...357(modelo) | 358...367(placa)

.data
	shell: .asciiz "MAN-SHELL>>"
	boas_vindas: .asciiz "Seja Bem Vindo ao MAN, o seu sistema gerenciador de condomínio!"
	comandos: .asciiz "\nComandos do Sistema exemplo(comando --<option1> --<option2>):\naddMorador --<ap> --<nome> \nrmvMorador --<ap> --<nome>\nAddAuto --<ap> --<tipo> --<modelo> --<placa>\nrmvAuto --<ap> --<placa>\nlimparAp <ap>\ninfoAp --<ap>\ninfoGeral\nsalvar\nrecarregar\nformatar"
	linha: .asciiz "\n"
	
.macro print_shell
	li $v0, 4
	la $a0, shell
	syscall
.end_macro

.macro print_string(%string)
	li $v0, 4
	la $a0, %string
	syscall
.end_macro

.macro read_string(%register)
	li $v0, 8
	syscall
	move %register, $v0
.end_macro

.data
# Definição do banner do terminal
banner: .asciiz "NCS-shell>> "

# Buffer para armazenar a entrada do usuário
input_buffer: .space 100  # Buffer de 100 bytes para armazenar a entrada

.text
.globl main

main:
    # Loop principal do terminal
terminal_loop:
    # Imprime o banner
    la $a0, banner
    li $v0, 4  # Syscall para imprimir string
    syscall
    
    # Captura a entrada do usuário
    la $a0, input_buffer  # Carrega o endereço do buffer
    li $a1, 100  # Define o tamanho máximo da entrada
    jal read_line  # Chama a função para ler a linha
    
    # Interpreta e executa o comando
    la $a0, input_buffer  # Carrega o endereço do buffer
    jal execute_command  # Chama a função para executar o comando
    
    # Volta ao início do loop
    j terminal_loop
    
# Função para ler uma linha do terminal
# A string lida é armazenada em $a0 e termina com '\n'
read_line:
    li $t0, 0  # Índice para o buffer
read_line_loop:
    li $v0, 8  # Syscall para leitura de um caractere
    syscall
    lb $t1, 0($a0)  # Carrega o caractere lido
    
    # Verifica se é uma quebra de linha (Enter)
    li $t2, 10  # Valor ASCII para '\n'
    beq $t1, $t2, read_line_done
    
    # Armazena o caractere no buffer
    sb $t1, 0($a0)
    addi $a0, $a0, 1  # Avança para o próximo byte no buffer
    addi $t0, $t0, 1  # Incrementa o índice
    
    # Limita o tamanho da string (evita overflow)
    li $t3, 99
    bge $t0, $t3, read_line_done
    
    # Continua lendo
    j read_line_loop
    
read_line_done:
    # Adiciona o terminador null à string
    li $t1, 0
    sb $t1, 0($a0)
    jr $ra  # Retorna da função

# Função para interpretar e executar o comando
# No momento, apenas verifica o comando e imprime uma mensagem
execute_command:
    # Aqui você pode implementar a lógica para verificar qual comando foi digitado
    # Por enquanto, vamos apenas imprimir a string recebida como um exemplo

    # Carrega a string do comando
    la $a0, shell
    li $v0, 4  # Syscall para imprimir string
    syscall
    
    # Imprime uma nova linha para separar a saída
    li $a0, 10  # ASCII para '\n'
    li $v0, 11  # Syscall para imprimir caractere
    syscall
    
    jr $ra  # Retorna da função
