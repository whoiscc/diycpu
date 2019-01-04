lui $t0, 0
xori $t1, $t0, 42
xori $t2, $t0, 43
mult $t1, $t2
mfhi $s0
mflo $s1
div $t2, $t1
mfhi $s2
mflo $s3