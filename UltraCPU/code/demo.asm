lui $zero, 0
xori $t0, $zero, 1
sw $t0, 0($gp)  # fib(0) = 1
sw $t0, 4($gp)  # fib(1) = 1

xori $t1, $zero, 8
xori $t2, $zero, 400
init_loop:
sub $t3, $t1, $t2
bgtz $t3, init_loop_end
add $t4, $gp, $t1
sw $zero, 0($t4)
addi $t1, $t1, 4
j init_loop
init_loop_end:

xori $a0, $zero, 40
jal cal_fib
j end

cal_fib:
xori $t0, $zero, 4
mult $t0, $a0
mflo $t0
add $t1, $gp, $t0
lw $t2, 0($t1)
beq $t2, $zero, recusive_call
xor $a0, $zero, $t2
jr $ra
recusive_call:
sw $ra, 0($sp)
addi $sp, $sp, -4
sw $s0, 0($sp)
addi $sp, $sp, -4
sw $s1, 0($sp)
addi $sp, $sp, -4
sw $t1, 0($sp)
addi $sp, $sp, -4

addi $s0, $a0, -2
addi $a0, $a0, -1
jal cal_fib
xori $s1, $a0, 0
ori $a0, $s0, 0
jal cal_fib
add $a0, $a0, $s1

addi $sp, $sp, 4
lw $t1, 0($sp)
sw $a0, 0($t1)

addi $sp, $sp, 4
lw $s1, 0($sp)
addi $sp, $sp, 4
lw $s0, 0($sp)
addi $sp, $sp, 4
lw $ra, 0($sp)
jr $ra

end:
nop
