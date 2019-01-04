lui $t0, 0
xori $t1, $t0, 1
jal inc
sll $t1, $t1, 1
jal inc
j end

inc:
add $t0, $t0, $t1
jr $ra

end:
nop