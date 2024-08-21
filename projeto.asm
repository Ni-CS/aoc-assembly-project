.data

shell: .asciiz "MAN-SHELL>>"
boas_vindas: .asciiz "Seja Bem Vindo ao MAN, o seu sistema gerenciador de condomínio!\n"
comandos: .asciiz "\nComandos do Sistema exemplo(comando --<option1> --<option2>):\naddMorador --<ap> --<nome> \nrmvMorador --<ap> --<nome>\nAddAuto --<ap> --<tipo> --<modelo> --<placa>\nrmvAuto --<ap> --<placa>\nlimparAp <ap>\ninfoAp --<ap>\ninfoGeral\nsalvar\nrecarregar\nformatar\n"
linha: .asciiz "\n"
pedir_ap: .asciiz "\nDigite o número do apartamento(0...23): "
pedir_nome: .asciiz "\nDigite o nome do morador: "

input_buffer: .space 100
apartamentos: .space 4320 #12 andares * 2ap/a * 6 moradores * tamanho string | 180 para cada ap | 30 para cada morador
veiculos: .space  1440 #24 ap * 30 string * 2 veiculos| 1 para tipo de veiculo | 7 para placa | 22 para modelo


cmd1: .asciiz "addMorador --"
cmd2: .asciiz "rmvMorador --"
cmd3: .asciiz "addAuto --"
cmd4: .asciiz "rmvAuto --"
cmd5: .asciiz "limparAp --"
cmd6: .asciiz "infoAp --"
cmd7: .asciiz "infoGeral"
cmd8: .asciiz "salvar"
cmd9: .asciiz "recarregar"
cmd10: .asciiz "formatar"



.macro print_shell
    li $v0, 4
    la $a0, shell
    syscall
.end_macro

.macro print_string %string
    li $v0, 4
    la $a0, %string
    syscall
.end_macro

.macro read_string %register
    li $v0, 8
    move $a0, %register
    syscall
.end_macro

.macro read_int %register
    li $v0, 5
    syscall
    move %register, $v0
.end_macro

.macro comparar_comando %string_comando, %string_digitada, %qtd_caracteres
    la $a0, %string_comando
    la $a1, %string_digitada
    la $a0, %qtd_caracteres
    jal strncmp
.end_macro


.text
.globl main

main:
    print_string(boas_vindas)
    print_string(comandos)
    # Loop principal do terminal
terminal_loop:
    print_shell
    
    # Captura a entrada do usuário
    la $a0, input_buffer  # Carrega o endereço do buffer
    li $a1, 100  # Define o tamanho máximo da entrada
    jal read_line  # Chama a função para ler a linha
    
    # Interpreta e executa o comando
    la $a0, input_buffer  # Carrega o endereço do buffer
    jal execute_command  # Chama a função para executar o comando
    
    # Volta ao início do loop
    j main
    
# Função para ler uma linha do terminal
# A string lida é armazenada em $a0 e termina com '\n'
read_line:
    li $t0, 0  # Índice para o buffer
read_line_loop:
    li $v0, 12  # Syscall para leitura de um caractere (getc)
    syscall
    move $t1, $v0  # Carrega o caractere lido
    
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
execute_command:
    # Compara o comando com 'addMorador'
    comparar_comando cmd1, input_buffer, 
    beq $v0, 0, handle_addMorador
    # compara com rmvMorador
    #comparar_comando cmd2, input_buffer
    #beq $v0, 0, handle_rmvMorador
    # comparar limparAp
    #comparar_comando cmd5, input_buffer
    #beq $v0, 0, handle_limparAp
    
    # Se não for 'addMorador', podemos adicionar mais checagens para outros comandos aqui
    
    j terminal_loop  # Retorna da função
    
handle_addMorador:
    la $a0, input_buffer
    
    print_string(pedir_ap)
    read_int($t0)
    
    print_string(pedir_ap)
    read_int($t0)
    j terminal_loop  # Retorna da função



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

