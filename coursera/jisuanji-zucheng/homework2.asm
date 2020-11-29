
       .text
       .globl main
	.macro print_str (%str)
	.data
myLabel: .asciiz %str
    .text
    li $v0, 4
    la $a0, myLabel
    syscall
    .end_macro
    
 main:
    li $v0, 8
    li $a1,500
    la $a0,value
    syscall
    move $t0,$a0
 input:
    li $v0,12
    syscall
    beq $v0,'?',exit
    li $t2,0
 loop:
    add $t3,$t0,$t2
    lb $t4,0($t3)
    beq $t4,0,fail
    beq $v0,$t4,success
    add $t2,$t2,1
    j loop
    
success:
    print_str("\nSuccess! Location:")
    add $a0,$t2,1
    li $v0, 1
    syscall
    print_str("\n")
    j input
fail:
    print_str("\nFail!\n")
    j input
exit:

.data
value: .space 500
