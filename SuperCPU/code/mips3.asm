lui $t0, 0
lui $t1, 0
beq $t0, $t1, label1
addiu $t0, $t0, 1  # pass
label1:
addiu $t0, $t0, 2