lui $t0, 0
xori $t1, $t0, 1
xori $t2, $t0, 2
beq $t0, $t0, label1
nop
label1:
beq $t0, $t1, label2
bgtz $t1, label3
nop
label3:
nop
nop
label2:
