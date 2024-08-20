.data

shell: .asciiz "\nMAN-SHELL>>"
boas_vindas: .asciiz "Seja Bem Vindo ao MAN, o seu sistema gerenciador de condomínio!"
comandos: .asciiz "\nComandos do Sistema exemplo(comando --<option1> --<option2>):\naddMorador --<ap> --<nome> \nrmvMorador --<ap> --<nome>\nAddAuto --<ap> --<tipo> --<modelo> --<placa>\nrmvAuto --<ap> --<placa>\nlimparAp <ap>\ninfoAp --<ap>\ninfoGeral\nsalvar\nrecarregar\nformatar"
linha: .asciiz "\n"

input_buffer: .space 100
apartamentos: .space 4320 #12 andares * 2ap/a * 6 moradores * tamanho string | 180 para cada ap | 30 para cada morador
veiculos: .space  1440 #24 ap * 30 string * 2 veiculos| 1 para tipo de veiculo | 7 para placa | 22 para modelo


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

.macro comparar_comando %string_comando, %string_digitada
    la $a0, %string_comando
    la $a1, %string_digitada
    jal string_compare_command
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
    comparar_comando cmd1, input_buffer
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
    print_string(boas_vindas)
    la $a0, input_buffer
    jal extract_options
    
    j terminal_loop  # Retorna da função
 
    
    
    
    
    
    
extract_options:
    # $a0 contém a string digitada (após a validação do comando)
    # $a1 aponta para o início das opções
    li $t0, 32          # ASCII para ' '
    li $t1, 0x2D2D      # '--' em ASCII

find_space:
    lb $t2, 0($a0)      # Carrega o próximo caractere
    beq $t2, $t0, found_space  # Se for um espaço, encontrou o início das opções
    beq $t2, 0, end_extract    # Se for o fim da string, encerra a extração
    addi $a0, $a0, 1    # Avança para o próximo caractere
    j find_space

found_space:
    addi $a0, $a0, 1    # Pula o espaço
    lb $t3, 0($a0)      # Carrega o próximo byte
    lb $t4, 1($a0)      # Carrega o byte seguinte
    sll $t3, $t3, 8     # Shift para combinar '--'
    or $t3, $t3, $t4

    bne $t3, $t1, end_extract # Se não for '--', encerra (opção inválida)
    addi $a0, $a0, 2    # Pula o '--'
    move $a1, $a0       # Salva o início da opção
    j extract_next_option

extract_next_option:
    lb $t2, 0($a0)      # Carrega o próximo caractere
    beq $t2, $t0, save_option  # Se for um espaço, salva a opção
    beq $t2, 0, save_option    # Se for o fim da string, salva a última opção
    addi $a0, $a0, 1    # Avança para o próximo caractere
    j extract_next_option

save_option:
    print_string(boas_vindas)
    jr $ra

end_extract:
print_string(boas_vindas)
    jr $ra              # Retorna para a função chamadora

    
    
    
    
    
    
    
    
    
string_compare_command:
    # Loop para comparar caractere por caractere
string_compare_command_loop:
    lb $t0, 0($a0)        # Carrega o byte da primeira string (comando esperado)
    lb $t1, 0($a1)        # Carrega o byte da segunda string (entrada do usuário)
    beq $t0, $t1, check_next_char  # Se os caracteres são iguais, verifica o próximo

    li $v0, 1             # Se não são iguais, define $v0 como 1 (strings diferentes)
    jr $ra                # Retorna para a função chamadora

check_next_char:
    beq $t0, 0, check_space  # Se chegou ao final do comando, verifica o próximo caractere na entrada
    addi $a0, $a0, 1        # Avança para o próximo caractere da primeira string (comando esperado)
    addi $a1, $a1, 1        # Avança para o próximo caractere da segunda string (entrada do usuário)
    j string_compare_command_loop  # Repete o loop

check_space:
    lb $t1, 0($a1)        # Carrega o próximo byte da segunda string (entrada do usuário)
    li $t2, 32            # Caractere espaço (' ')
    beq $t1, $t2, strings_equal # Se é um espaço, as strings são iguais
    beq $t1, 0, strings_equal   # Ou se é o final da string de entrada
    li $v0, 1             # Caso contrário, as strings são diferentes
    jr $ra                # Retorna para a função chamadora

strings_equal:
    li $v0, 0             # Define $v0 como 0 (strings iguais)
    jr $ra                # Retorna para a função chamadora
