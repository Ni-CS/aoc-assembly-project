.data
	shell: .asciiz "MAN-SHELL>>"

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



.text

