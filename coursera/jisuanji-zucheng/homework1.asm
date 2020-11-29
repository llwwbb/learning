       .text
       .globl main

	.macro print_str (%str)
	.data
myLabel: .asciiz %str
    .text
    li $v0, 4
    la $a0, myLabel
    syscall
    j main
    .end_macro

main:  
    li $v0, 12
    syscall

    beq $v0, '?', exit
    beq $v0, 'A', printA
    beq $v0, 'N', printN
    beq $v0, '1', print1
    beq $v0, 'a', printa
    beq $v0, 'n', printn
    beq $v0, 'B', printB
    beq $v0, 'O', printO
    beq $v0, '2', print2
    beq $v0, 'b', printb
    beq $v0, 'o', printo
    beq $v0, 'C', printC
    beq $v0, 'P', printP
    beq $v0, '3', print3
    beq $v0, 'c', printc
    beq $v0, 'p', printp
    beq $v0, 'D', printD
    beq $v0, 'Q', printQ
    beq $v0, '4', print4
    beq $v0, 'd', printd
    beq $v0, 'q', printq
    beq $v0, 'E', printE
    beq $v0, 'R', printR
    beq $v0, '5', print5
    beq $v0, 'e', printe
    beq $v0, 'r', printr
    beq $v0, 'F', printF
    beq $v0, 'S', printS
    beq $v0, '6', print6
    beq $v0, 'f', printf
    beq $v0, 's', prints
    beq $v0, 'G', printG
    beq $v0, 'T', printT
    beq $v0, '7', print7
    beq $v0, 'g', printg
    beq $v0, 't', printt
    beq $v0, 'H', printH
    beq $v0, 'U', printU
    beq $v0, '8', print8
    beq $v0, 'h', printh
    beq $v0, 'u', printu
    beq $v0, 'I', printI
    beq $v0, 'V', printV
    beq $v0, '9', print9
    beq $v0, 'i', printi
    beq $v0, 'v', printv
    beq $v0, 'J', printJ
    beq $v0, 'W', printW
    beq $v0, '0', print0
    beq $v0, 'j', printj
    beq $v0, 'w', printw
    beq $v0, 'K', printK
    beq $v0, 'X', printX
    beq $v0, 'k', printk
    beq $v0, 'x', printx
    beq $v0, 'L', printL
    beq $v0, 'Y', printY
    beq $v0, 'l', printl
    beq $v0, 'y', printy
    beq $v0, 'M', printM
    beq $v0, 'Z', printZ
    beq $v0, 'm', printm
    beq $v0, 'z', printz
    print_str("*")
    j main
    
printA: print_str("Alpha")
printN: print_str("November")
print1: print_str("First")
printa: print_str("alpha")
printn: print_str("november")

printB: print_str("Bravo")
printO: print_str("Oscar")
print2: print_str("Second")
printb: print_str("bravo")
printo: print_str("oscar")

printC: print_str("China")
printP: print_str("Paper")
print3: print_str("Third")
printc: print_str("china")
printp: print_str("paper")

printD: print_str("Delta")
printQ: print_str("Quebec")
print4: print_str("Fourth")
printd: print_str("delta")
printq: print_str("quebec")

printE: print_str("Echo")
printR: print_str("Research")
print5: print_str("Fifth")
printe: print_str("echo")
printr: print_str("research")

printF: print_str("Foxtrot")
printS: print_str("Sierra")
print6: print_str("Sixth")
printf: print_str("foxtrot")
prints: print_str("sierra")

printG: print_str("Golf")
printT: print_str("Tango")
print7: print_str("Seventh")
printg: print_str("golf")
printt: print_str("tango")

printH: print_str("Hotel")
printU: print_str("Uniform")
print8: print_str("Eighth")
printh: print_str("hotel")
printu: print_str("uniform")

printI: print_str("India")
printV: print_str("Victor")
print9: print_str("Ninth")
printi: print_str("india")
printv: print_str("victor")

printJ: print_str("Juliet")
printW: print_str("Whisky")
print0: print_str("zero")
printj: print_str("juliet")
printw: print_str("whisky")

printK: print_str("Kilo")
printX: print_str("X-ray")
printk: print_str("kilo")
printx: print_str("x-ray")

printL: print_str("Lima")
printY: print_str("Yankee")
printl: print_str("lima")
printy: print_str("yankee")

printM: print_str("Mary")
printZ: print_str("Zulu")
printm: print_str("mary")
printz: print_str("zulu")
exit:
